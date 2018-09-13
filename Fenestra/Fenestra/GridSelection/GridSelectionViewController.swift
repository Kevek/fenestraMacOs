//
//  ViewController.swift
//  Fenestra
//
//  Created by Kevin Kerr on 11/26/17.
//  Copyright © 2017 CodingPanda. All rights reserved.
//

import Cocoa;
import FenestraCommonLib;

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
		NotificationCenter.default.post(name: .setUpCloseOutstandingSelectionHotKey, object: nil);
	}

	func getSelectionGridSize() -> (numRows: Int, numColumns: Int) {
		let data=UserDefaults.standard.dictionary(forKey: FenestraPreferences.preferences.rawValue);
		let numberOfRows=data?[FenestraPreferences.numberOfRows.rawValue] as? Int ?? 6;
		let numberOfColumns=data?[FenestraPreferences.numberOfColumns.rawValue] as? Int ?? 6;
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
			NotificationCenter.default.post(name: .fenestraSelectionComplete, object: nil);
		}
	}

	func resizeWindow(position:CGPoint, size: CGSize) {
		let pid=frontmostApplication?.processIdentifier;
		if let pid:pid_t = pid {
			let focusedWindowAttribute=kAXFocusedWindowAttribute as CFString
			let positionAttribute=kAXPositionAttribute as CFString;
			let sizeAttribute=kAXSizeAttribute as CFString;

			let axApplication=AXUIElementCreateApplication(pid);
			var frontmostWindow: AnyObject?;
			var result=AXUIElementCopyAttributeValue(axApplication, focusedWindowAttribute, &frontmostWindow);
			guard result == .success else {
				print("Error while getting frontmost application attribute \(result.rawValue)");
				return;
			}
			let frontmostWindowElement=frontmostWindow as! AXUIElement;
			result = AXUIElementSetAttributeValue(frontmostWindowElement, positionAttribute, AccessibilityUtil.wrapAXValue(position as AnyObject).axValue)
			guard result == .success else {
				print("Error while setting new window position: \(result.rawValue)");
				return;
			}
			result=AXUIElementSetAttributeValue(frontmostWindowElement, sizeAttribute, AccessibilityUtil.wrapAXValue(size as AnyObject).axValue)
			guard result == .success else {
				print("Error while setting new window size: \(result.rawValue)");
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
		NSWorkspace.shared.notificationCenter.removeObserver(self);
		super.viewDidDisappear();
	}
}
