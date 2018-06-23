//
//  FenestraConstants.swift
//  Fenestra
//
//  Created by Kevin Kerr on 6/3/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa;

public extension NSColor {
	static let fenestraBorderColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0);
	static let fenestraTextColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0);
	static let fenestraBackgroundColor = NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.6);

	static let fenestraSelectionBorder = NSColor(red: 0.067, green: 0.2, blue: 1.0, alpha: 1);
	static let fenestraSelectionFill = NSColor(red: 0.13, green: 0.6, blue: 1.0, alpha:  0.40)
	static let fenestraSelectedCell = NSColor(red: 0.086, green: 0.60, blue: 1, alpha: 0.67)
}

public extension Notification.Name  {
	// Sent when the grid selection is complete
	static let fenestraSelectionComplete = Notification.Name("fenestraSelectionComplete");
	// Sent when the settings window is closed (to hook up HotKeys)
	static let fenestraPreferencesOnClosed = Notification.Name("fenestraPreferencesOnClosed");
	// Sent when the main Fenestra applicaiton starts to close the FenestraLauncher process
	static let fenestraStopLauncher = Notification.Name("fenestraStopLauncherProcess");
}

public enum FenestraPreferences : String {
	case fenestraBundleIdentifier = "net.codingpanda.Fenestra";
	case fenestraLauncherBundleIdentifier = "net.codingpanda.FenestraLauncher";

	case preferences="fenestraPreferencesUserDefaults";

	case numberOfRows="numberOfRows";
	case numberOfColumns="numberOfColumns";
	case startAtLogin="startAtLogin";
	case hotkeyCombo="hotkeyCombo";
}

public enum FenestraGridSelectionRange : Int {
	case minValue = 2;
	case maxValue = 24;
}
