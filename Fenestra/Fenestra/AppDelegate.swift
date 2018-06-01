//
//  AppDelegate.swift
//  Fenestra
//
//  Created by Kevin Kerr on 11/26/17.
//  Copyright © 2017 CodingPanda. All rights reserved.
//

import Cocoa
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength);

	private var openGridSelectionWindowHotKey:HotKey? {
		didSet {
			guard let hotKey = openGridSelectionWindowHotKey else {
				return;
			}
			hotKey.keyDownHandler = { [weak self] in
				self?.openGridSelectionWindows();
			}
		}
	}

	private var closeOutstandingWindowsHotKey:HotKey? {
		didSet {
			guard let hotKey = closeOutstandingWindowsHotKey else {
				return;
			}
			hotKey.keyDownHandler = { [weak self] in
				for window in (self?.windows)! {
					window?.close();
				}
			}
		}
	}

	var windows : [NSWindowController?] = [];


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Check if we're authorized for the Accessibility API
		if (!AccessibilityUtil.isTrustedAccessibilityProcess(showPrompt: true)) {
			let alert = NSAlert.init()
			alert.messageText = "Accessibility Permission Required"
			alert.informativeText = "Fenestra requires access to Accessability to move and resize windows.\n\nPlease give Fenestra access in System Preferences -> Security & Privacy -> Privacy -> Accessibility.\n\nPlease relaunch Fenestra once access has been granted."
			alert.addButton(withTitle: "OK")
			alert.runModal()
			exit(-1);
		}

		if let statusButton = statusItem.button {
			statusButton.image = NSImage(named:NSImage.Name("FenestraStatusBarIcon"));
		}

		NotificationCenter.default.addObserver(forName: Notification.Name.fenestraSelectionComplete, object: nil, queue: nil) { [weak self] (notification) in
			self?.closeGridSelectionWindows();
		}

		createStatusItemMenu();
		openGridSelectionWindowHotKey = HotKey(keyCombo: KeyCombo(key: .d, modifiers: [.command, .shift]));
		closeOutstandingWindowsHotKey = HotKey(keyCombo: KeyCombo(key: .escape));
	}

	func createStatusItemMenu() {
		let statusItemMenu = NSMenu();
		statusItemMenu.addItem(NSMenuItem(title: "Settings",
																			action: #selector(openSettings),
																			keyEquivalent: ""));
		statusItemMenu.addItem(NSMenuItem.separator());
		statusItemMenu.addItem(NSMenuItem(title: "Quit Fenestra",
																			action: #selector(NSApplication.terminate(_:)),
																			keyEquivalent: "q"));
		statusItem.menu = statusItemMenu;
	}

	@objc func openSettings() {
		// TODO: Temp; do nothing
	}

	func openGridSelectionWindows() {
		closeGridSelectionWindows()
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let frontmostApplication=NSWorkspace.shared.frontmostApplication;
		for screen in NSScreen.screens {
			guard let windowController = storyboard.instantiateController(withIdentifier:NSStoryboard.SceneIdentifier("FenestraGridSelectionWindowConroller")) as? NSWindowController else {
				fatalError("Error getting main window controller")
			}
			windowController.window?.makeKeyAndOrderFront(nil);
			if let gridSelection = windowController.contentViewController as? GridSelectionViewController {
				gridSelection.screen=screen;
				gridSelection.frontmostApplication=frontmostApplication;
			}
			setExtraWindowProperties(window: windowController.window, screen: screen);
			windows.append(windowController);
		}
		for window in windows {
			window?.showWindow(self);
		}
	}

	func closeGridSelectionWindows() {
		for window in windows {
			window?.close();
		}
		windows.removeAll();
	}

	func setExtraWindowProperties(window:NSWindow?, screen:NSScreen) {
		window?.level = .floating;
		window?.hasShadow = false;
		window?.isOpaque = false;
		window?.isMovable = false;

		let frameOrigin=NSPoint(x: screen.visibleFrame.midX - (window?.frame.width ?? 0) / 2, y: screen.visibleFrame.midY - (window?.frame.height ?? 0) / 2);
		window?.setFrameOrigin(frameOrigin);


		//		window?.backgroundColor = .clear;
		////		window.titlebarAppearsTransparent=true;
		////		window.titleVisibility = .hidden;
		let hideWindowButtons: [NSWindow.ButtonType] = [.miniaturizeButton,
																										.zoomButton];
		hideWindowButtons.forEach({
			window?.standardWindowButton($0)?.isHidden=true;
		})
	}
}
