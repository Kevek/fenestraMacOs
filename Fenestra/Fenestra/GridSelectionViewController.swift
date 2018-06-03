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

		view.wantsLayer=true;
		view.layer?.borderWidth=2;
		view.layer?.borderColor=NSColor.fenestraBorderColor.cgColor;
		view.layer?.cornerRadius=8;
		view.layer?.backgroundColor=NSColor.fenestraBackgroundColor.cgColor;

		frontmostApplicationName?.textColor=NSColor.fenestraTextColor;

		gridSelectionView.gridResizeDelegate=self;
	}

	func getSelectionGridSize() -> (numRows: Int, numColumns: Int) {
		return (6, 6);
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
			let newYPosition=visibleFrame.origin.y + visibleHeight - newHeight - (visibleHeight*CGFloat(yOriginPercent));
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

			var frontmostWindow: AnyObject?;
			let axApplication=AXUIElementCreateApplication(pid);
			AXUIElementCopyAttributeValue(axApplication, focusedWindowAttribute, &frontmostWindow);
			let frontmostWindowElement=frontmostWindow as! AXUIElement
			var error = AXUIElementSetAttributeValue(frontmostWindowElement, positionAttribute, AccessibilityUtil.wrapAXValue(position as AnyObject).axValue)
			guard error == .success else {
				// TODO: throw error
				return;
			}
			error=AXUIElementSetAttributeValue(frontmostWindowElement, sizeAttribute, AccessibilityUtil.wrapAXValue(size as AnyObject).axValue)
			guard error == .success else {
				// TODO: throw error
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
	
	deinit {
		NSWorkspace.shared.notificationCenter.removeObserver(self);
	}
}
