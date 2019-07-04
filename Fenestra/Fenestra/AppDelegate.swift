//
//  AppDelegate.swift
//  Fenestra
//
//  Created by Kevin Kerr on 11/26/17.
//  Copyright © 2017 CodingPanda. All rights reserved.
//

import Cocoa;
import FenestraCommonLib;

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	let appCommands = AppCommandsBuilder().build();

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let isLauncherRunning = !NSWorkspace.shared.runningApplications.filter { $0.bundleIdentifier == FenestraPreferences.fenestraLauncherBundleIdentifier.rawValue }.isEmpty;

		if (isLauncherRunning) {
			DistributedNotificationCenter.default().post(name: .fenestraStopLauncher , object: Bundle.main.bundleIdentifier!)
		}

		// Check if we're authorized for the Accessibility API
		if (!AccessibilityUtil.isTrustedAccessibilityProcess(showPrompt: true)) {
			let alert = NSAlert.init();
			alert.messageText = "Accessibility Permission Required";
			alert.informativeText = "Fenestra requires access to Accessability to move and resize windows.\n\nPlease give Fenestra access in System Preferences -> Security & Privacy -> Privacy -> Accessibility.\n\nPlease relaunch Fenestra once access has been granted.";
			alert.addButton(withTitle: "OK");
			alert.runModal();
			exit(-1);
		}

		appCommands.forEach({appCommand in appCommand.doIt()});
	}
}
