//
//  ViewController.swift
//  Fenestra
//
//  Created by Kevin Kerr on 11/26/17.
//  Copyright © 2017 CodingPanda. All rights reserved.
//

import Cocoa

class GridSelectionViewController: NSViewController, GridResizeDelegate {
	@IBOutlet weak var frontmostApplicationName: NSTextField!;
	@IBOutlet weak var frontmostApplicationIcon: NSImageView!;
	@IBOutlet weak var gridSelectionView: GridSelectionView!;

	var screen: NSScreen? = nil;

	var frontmostApplication:NSRunningApplication? {
		didSet {
			updateFrontmostApplicationInfo();
		}
	};

	override func viewDidLoad() {
		super.viewDidLoad();

		NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(newApplicationSelected), name: NSWorkspace.didActivateApplicationNotification, object: nil)

		frontmostApplicationName?.textColor=NSColor.fenestraTextColor;

		gridSelectionView.gridResizeDelegate=self;
	}

	func getSelectionGridSize() -> (numRows: Int, numColumns: Int) {
		let data=NSUbiquitousKeyValueStore.default.dictionary(forKey: FenestraPreferences.preferences.rawValue);
		let numberOfRows=data?["numberOfRows"] as? Int ?? 6;
		let numberOfColumns=data?["numberOfColumns"] as? Int ?? 6;
		return (numberOfRows, numberOfColumns);
	}

	func resizeGrid(xOriginPercent: Double, yOriginPercent: Double, screenWidthPercent: Double, screenHeightPercent: Double) {
		if let visibleFrame=screen?.visibleFrame {
			let visibleWidth=visibleFrame.maxX-visibleFrame.minX
			let visibleHeight=visibleFrame.maxY-visibleFrame.minY;

			let newWidth=CGFloat(screenWidthPercent) * visibleWidth;
			let newHeight=CGFloat(screenHeightPercent) * visibleHeight;
			let newSize=CGSize(width:newWidth, height:newHeight);

			let newXPosition=visibleFrame.origin.x + CGFloat(xOriginPercent) * visibleWidth;
			// Unfortunately NSViews use a coordinate system where (0,0) is in the bottom-left, whereas NSScreens use a coordinate system where (0,0) is in the top-left so this is transforming for this
			let newYOriginPercent=1-(screenHeightPercent+yOriginPercent);
			var newYPosition=visibleFrame.origin.y + CGFloat(newYOriginPercent) * visibleHeight;
			if (newYPosition != 0) {
				// HACK --  I haven't yet figured out why, this seems to fix the positioning for non-zero y-values.
				newYPosition+=24;
			}
			let newPosition=CGPoint(x:newXPosition, y:newYPosition);

			resizeWindow(position: newPosition, size: newSize);
			// Return focus to the frontmostApplication we've moved (from Fenestra)
			frontmostApplication?.activate(options: []);
			NotificationCenter.default.post(name: Notification.Name.fenestraSelectionComplete, object: nil);
		}
	}

	func resizeWindow(position:CGPoint, size: CGSize) {
		let pid=frontmostApplication?.processIdentifier;
		if let pid:pid_t = pid {
			let focusedWindowAttribute: CFString = kAXFocusedWindowAttribute as CFString
			let positionAttribute=kAXPositionAttribute as CFString;
			let sizeAttribute=kAXSizeAttribute as CFString;

			let axApplication=AXUIElementCreateApplication(pid);
			var frontmostWindow: AnyObject?;
			AXUIElementCopyAttributeValue(axApplication, focusedWindowAttribute, &frontmostWindow);
			let frontmostWindowElement=frontmostWindow as! AXUIElement
			var error = AXUIElementSetAttributeValue(frontmostWindowElement, positionAttribute, AccessibilityUtil.wrapAXValue(position as AnyObject).axValue)
			guard error == .success else {
				print("Error while setting new window position: \(error)");
				return;
			}
			error=AXUIElementSetAttributeValue(frontmostWindowElement, sizeAttribute, AccessibilityUtil.wrapAXValue(size as AnyObject).axValue)
			guard error == .success else {
				print("Error while setting new window size: \(error)");
				return;
			}
		}
	}

	@objc func newApplicationSelected(notification:Notification) {
		let newFrontmostApplication=NSWorkspace.shared.frontmostApplication;

		if newFrontmostApplication?.processIdentifier != NSRunningApplication.current.processIdentifier {
			frontmostApplication=newFrontmostApplication;
		}
	}

	func updateFrontmostApplicationInfo() {
		let name=frontmostApplication?.localizedName ?? "Unknown - Fenestra Unable To Load Frontmost Application Data";
		frontmostApplicationIcon?.image=frontmostApplication?.icon
		frontmostApplicationName?.stringValue=name;
	}

	override func viewWillDisappear() {
		// Ensure any other screen's grid selections are closed
		NotificationCenter.default.post(name: Notification.Name.fenestraSelectionComplete, object: nil);
		super.viewDidDisappear();
	}
	
	deinit {
		NSWorkspace.shared.notificationCenter.removeObserver(self);
	}
}
