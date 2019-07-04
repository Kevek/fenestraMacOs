//
//  SettingsViewController.swift
//  Fenestra
//
//  Created by Kevin Kerr on 6/1/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa;
import HotKey;
import ServiceManagement;
import FenestraCommonLib;

class PreferencesViewController: NSViewController, NSWindowDelegate, NSTextFieldDelegate {
	@IBOutlet weak var numberOfRows:NSTextField!;
	@IBOutlet weak var numberOfColumns:NSTextField!;
	@IBOutlet weak var startAtLogin:NSButton!;
	@IBOutlet weak var hotKeyTextField:NSTextField!;

	var hotKeySelectionFieldEditor:HotKeySelectionView = HotKeySelectionView();

	override func viewDidLoad() {
		hotKeySelectionFieldEditor.isFieldEditor=true;

		let integerFormatter=IntegerValueFormatter();
		numberOfRows.formatter=integerFormatter;
		numberOfRows.delegate=self;
		numberOfColumns.formatter=integerFormatter;
		numberOfColumns.delegate=self;

		let data=UserDefaults.standard.dictionary(forKey: FenestraPreferences.preferences.rawValue);

		numberOfRows.stringValue="\(data?[FenestraPreferences.numberOfRows.rawValue] as? Int ?? 6)";
		numberOfColumns.stringValue="\(data?[FenestraPreferences.numberOfColumns.rawValue] as? Int ?? 6)";
		startAtLogin.state=(data?[FenestraPreferences.startAtLogin.rawValue] as? Bool ?? false) ? NSControl.StateValue.on : NSControl.StateValue.off;
		hotKeySelectionFieldEditor.keyCombo=KeyCombo(dictionary: (data?[FenestraPreferences.hotkeyCombo.rawValue] as? [String: Any] ??
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

	func controlTextDidChange(_ obj: Notification) {
		if let textField = obj.object as? NSTextField, (numberOfRows.identifier == textField.identifier || numberOfColumns.identifier == textField.identifier), let intValue = Int(textField.stringValue) {
			if (intValue < FenestraGridSelectionRange.minValue.rawValue) {
				textField.stringValue="\(FenestraGridSelectionRange.minValue.rawValue)";
			}
			if (intValue > FenestraGridSelectionRange.maxValue.rawValue) {
				textField.stringValue="\(FenestraGridSelectionRange.maxValue.rawValue)";
			}
		}
	}

	@IBAction func applyButtonClicked(_ sender:Any) {
		let hotKeyCombo=hotKeySelectionFieldEditor.keyCombo?.dictionary ?? [String:Any]();

		let data:[String:Any] = [
		FenestraPreferences.numberOfRows.rawValue:Int(numberOfRows.stringValue) ?? 6,
		FenestraPreferences.numberOfColumns.rawValue:Int(numberOfColumns.stringValue) ?? 6,
		FenestraPreferences.startAtLogin.rawValue:startAtLogin.state==NSControl.StateValue.on,
		FenestraPreferences.hotkeyCombo.rawValue:hotKeyCombo,
		];

		// 1. Save the settings
		UserDefaults.standard.set(data, forKey: FenestraPreferences.preferences.rawValue);

		// 2. Set the Start At Login logic
		SMLoginItemSetEnabled(FenestraPreferences.fenestraLauncherBundleIdentifier.rawValue as CFString, startAtLogin.state==NSControl.StateValue.on);

		// 3. Close this window
		self.view.window?.close();
	}

	override func viewWillDisappear() {
		NotificationCenter.default.post(name: .fenestraPreferencesOnClosed, object: nil);
		super.viewWillDisappear();
	}
}
