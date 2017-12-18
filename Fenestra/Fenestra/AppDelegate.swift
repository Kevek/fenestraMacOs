//
//  AppDelegate.swift
//  Fenestra
//
//  Created by Kevin Kerr on 11/26/17.
//  Copyright © 2017 CodingPanda. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength);


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		if let statusButton = statusItem.button {
			statusButton.image = NSImage(named:NSImage.Name("FenestraStatusBarIcon"));
		}
		createStatusItemMenu();


		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		for screen in NSScreen.screens {
			guard let windowController = storyboard.instantiateController(withIdentifier:NSStoryboard.SceneIdentifier("FenestraGridSelectionWindowConroller")) as? NSWindowController else {
				fatalError("Error getting main window controller")
			}
			windowController.window?.makeKeyAndOrderFront(nil)
			setExtraWindowProperties(window: windowController.window, screen: screen)
		}
	}

	func createStatusItemMenu() {
		let statusItemMenu = NSMenu()
		statusItemMenu.addItem(NSMenuItem(title: "Settings",
																			action: #selector(openSettings),
																			keyEquivalent: ""))
		statusItemMenu.addItem(NSMenuItem.separator())
		statusItemMenu.addItem(NSMenuItem(title: "Quit Fenestra",
																			action: #selector(NSApplication.terminate(_:)),
																			keyEquivalent: "q"))
		statusItem.menu = statusItemMenu
	}

	@objc func openSettings() {
		// TODO: Temp; do nothing
	}

	func setExtraWindowProperties(window:NSWindow?, screen:NSScreen) {
		window?.level = .floating;
		window?.hasShadow = false;
		window?.isOpaque = false;
		window?.isMovable = false;
		// TODO: Figure out how to disable dragging...

		// TODO: Set window center in screen

		let frameOrigin=NSPoint(x: screen.visibleFrame.midX - (window?.frame.width ?? 0) / 2, y: screen.visibleFrame.midY - (window?.frame.height ?? 0) / 2);
		window?.setFrameOrigin(frameOrigin);


		//		window?.backgroundColor = .clear;
		////		window.titlebarAppearsTransparent=true;
		////		window.titleVisibility = .hidden;
		//		let hideWindowButtons: [NSWindow.ButtonType] = [.miniaturizeButton,
		//																										.zoomButton];
		//		hideWindowButtons.forEach({
		//			window.standardWindowButton($0)?.isHidden=true;
		//		})
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

