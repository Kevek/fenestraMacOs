//
//  PreferencesAppComponent.swift
//  Fenestra
//
//  Created by Kevin Kerr on 9/13/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa

final class PreferencesAppComponent: AppComponent {
	func doIt() {
		NotificationCenter.default.addObserver(forName: .fenestraOpenPreferenes, object: nil, queue: nil) {
			[weak self] (notification) in self?.openPreferences();
		}
	}

	func openPreferences() {
		NotificationCenter.default.post(name: .disableFenestraSelectionHotKey, object:nil);
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
}
