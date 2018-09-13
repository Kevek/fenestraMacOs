//
//  InitializeStatusBarAppComponent.swift
//  Fenestra
//
//  Created by Kevin Kerr on 9/13/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa

final class InitializeStatusBarAppComponent: AppComponent {
	let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength);

	func doIt() {
		if let statusButton = statusItem.button {
			statusButton.image = NSImage(named:NSImage.Name("FenestraStatusBarIcon"));
		}

		let statusItemMenu = NSMenu();
		let preferencesMenuItem=NSMenuItem(title: "Preferences",
																			 action: #selector(createOpenPreferencesNotification),
																			 keyEquivalent: ",");
		preferencesMenuItem.target=self;
		statusItemMenu.addItem(preferencesMenuItem);
		statusItemMenu.addItem(NSMenuItem.separator());
		statusItemMenu.addItem(NSMenuItem(title: "Quit Fenestra",
																			action: #selector(NSApplication.terminate(_:)),
																			keyEquivalent: "q"));
		statusItem.menu = statusItemMenu;
	}

	@objc func createOpenPreferencesNotification(_ sender: Any) {
		NotificationCenter.default.post(name: .fenestraOpenPreferenes, object: nil);
	}
}
