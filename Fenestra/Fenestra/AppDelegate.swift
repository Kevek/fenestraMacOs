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
				self?.closeGridSelectionWindows();
			}
		}
	}

	var windows : [NSWindowController?] = [];

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Check if we're authorized for the Accessibility API
		if (!AccessibilityUtil.isTrustedAccessibilityProcess(showPrompt: true)) {
			let alert = NSAlert.init();
			alert.messageText = "Accessibility Permission Required";
			alert.informativeText = "Fenestra requires access to Accessability to move and resize windows.\n\nPlease give Fenestra access in System Preferences -> Security & Privacy -> Privacy -> Accessibility.\n\nPlease relaunch Fenestra once access has been granted.";
			alert.addButton(withTitle: "OK");
			alert.runModal();
			exit(-1);
		}

		if let statusButton = statusItem.button {
			statusButton.image = NSImage(named:NSImage.Name("FenestraStatusBarIcon"));
		}

		NotificationCenter.default.addObserver(forName: Notification.Name.fenestraSelectionComplete, object: nil, queue: nil) { [weak self] (notification) in
			self?.closeGridSelectionWindows();
		}
		NotificationCenter.default.addObserver(forName: Notification.Name.fenestraPreferencesOnClosed, object: nil, queue: nil) { 			[weak self] (notification) in
			self?.setUpGridSelectionHotKey();
		}

		createStatusItemMenu();
		setUpGridSelectionHotKey();
	}

	func createStatusItemMenu() {
		let statusItemMenu = NSMenu();
		statusItemMenu.addItem(NSMenuItem(title: "Preferences",
																			action: #selector(openPreferences),
																			keyEquivalent: ","));
		statusItemMenu.addItem(NSMenuItem.separator());
		statusItemMenu.addItem(NSMenuItem(title: "Quit Fenestra",
																			action: #selector(NSApplication.terminate(_:)),
																			keyEquivalent: "q"));
		statusItem.menu = statusItemMenu;
	}

	@objc func openPreferences() {
		openGridSelectionWindowHotKey=nil;
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil);
		guard let windowController = storyboard.instantiateController(withIdentifier:NSStoryboard.SceneIdentifier("FenestraPreferencesWindowController")) as? NSWindowController else {
			fatalError("Error getting preferences window controller")
		}
		if let settings = windowController.contentViewController as? PreferencesViewController {
			windowController.window?.delegate=settings;
		}
		windowController.showWindow(self);
		windowController.window?.makeKeyAndOrderFront(self);
	}

	func setUpGridSelectionHotKey() {
		let data=NSUbiquitousKeyValueStore.default.dictionary(forKey: FenestraPreferences.preferences.rawValue);
		let keyCombo=KeyCombo(dictionary: (data?["hotkeyCombo"] as? [String: Any] ?? KeyCombo(key: .d, modifiers: [.command, .shift]).dictionary))
		openGridSelectionWindowHotKey = HotKey(keyCombo: keyCombo!);
	}

	func openGridSelectionWindows() {
		closeGridSelectionWindows();
		let frontmostApplication=NSWorkspace.shared.frontmostApplication;
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil);
		for screen in NSScreen.screens {
			guard let windowController = storyboard.instantiateController(withIdentifier:NSStoryboard.SceneIdentifier("FenestraGridSelectionWindowConroller")) as? NSWindowController else {
				fatalError("Error getting main window controller")
			}
			if let gridSelection = windowController.contentViewController as? GridSelectionViewController {
				gridSelection.screen=screen;
				gridSelection.frontmostApplication=frontmostApplication;
			}
			setExtraGridSelectionWindowProperties(window: windowController.window, screen: screen);
			windows.append(windowController);
		}
		for window in windows {
			window?.showWindow(self);
		}
		closeOutstandingWindowsHotKey = HotKey(keyCombo: KeyCombo(key: .escape));
	}

	func setExtraGridSelectionWindowProperties(window:NSWindow?, screen:NSScreen) {
		window?.level = .floating;
		window?.hasShadow = false;
		window?.isOpaque = false;
		window?.isMovable = false;
		window?.backgroundColor = NSColor.fenestraBackgroundColor;

		let frameOrigin=NSPoint(x: screen.visibleFrame.midX - (window?.frame.width ?? 0) / 2, y: screen.visibleFrame.midY - (window?.frame.height ?? 0) / 2);
		window?.setFrameOrigin(frameOrigin);

		window?.titlebarAppearsTransparent = true;
		window?.titleVisibility = .hidden;
		window?.standardWindowButton(.miniaturizeButton)?.isHidden=true;
		window?.standardWindowButton(.zoomButton)?.isHidden=true;
	}

	func closeGridSelectionWindows() {
		for window in windows {
			window?.close();
		}
		windows.removeAll();
		closeOutstandingWindowsHotKey=nil;
	}
}
