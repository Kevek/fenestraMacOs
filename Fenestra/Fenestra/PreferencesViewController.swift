//
//  SettingsViewController.swift
//  Fenestra
//
//  Created by Kevin Kerr on 6/1/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa;
import HotKey;

class PreferencesViewController: NSViewController, NSWindowDelegate {
	@IBOutlet weak var numberOfRows:NSTextField!;
	@IBOutlet weak var numberOfColumns:NSTextField!;
	@IBOutlet weak var startAtLogin:NSButton!;
	@IBOutlet weak var hotKeyTextField:NSTextField!;

	var hotKeySelectionFieldEditor:HotKeySelectionView = HotKeySelectionView();

	override func viewDidLoad() {
		hotKeySelectionFieldEditor.isFieldEditor=true;

		let data=NSUbiquitousKeyValueStore.default.dictionary(forKey: FenestraPreferences.preferences.rawValue);

		numberOfRows.stringValue="\(data?["numberOfRows"] as? Int ?? 6)";
		numberOfColumns.stringValue="\(data?["numberOfColumns"] as? Int ?? 6)";
		startAtLogin.state=(data?["startAtLogin"] as? Bool ?? false) ? NSControl.StateValue.on : NSControl.StateValue.off;
		hotKeySelectionFieldEditor.keyCombo=KeyCombo(dictionary: (data?["hotkeyCombo"] as? [String: Any] ??
			KeyCombo(key: .d, modifiers: [.command, .shift]).dictionary));
		// This seems to be required to show the initial value loaded above
		hotKeyTextField.stringValue=hotKeySelectionFieldEditor.string;
	}

	func windowWillReturnFieldEditor(_ sender: NSWindow, to client: Any?) -> Any? {
		if let textField = client as? NSTextField, textField.identifier == hotKeyTextField.identifier {
			return hotKeySelectionFieldEditor;
		}
		return nil;
	}

	@IBAction func applyButtonClicked(_ sender:Any) {
		let hotKeyCombo=hotKeySelectionFieldEditor.keyCombo?.dictionary ?? [String:Any]();

		let data:[String:Any] = [
		"numberOfRows":Int(numberOfRows.stringValue) ?? 6,
		"numberOfColumns":Int(numberOfColumns.stringValue) ?? 6,
		"startAtLogin":startAtLogin.state==NSControl.StateValue.on,
		"hotkeyCombo":hotKeyCombo,
		];

		// 1. Save the settings
		NSUbiquitousKeyValueStore.default.set(data, forKey: FenestraPreferences.preferences.rawValue);

		// 2. Set the Start At Login logic

		// 3. Close this window
		self.view.window?.close();
	}

	override func viewWillDisappear() {
		NotificationCenter.default.post(name: Notification.Name.fenestraPreferencesOnClosed, object: nil);
		super.viewWillDisappear();
	}
}
