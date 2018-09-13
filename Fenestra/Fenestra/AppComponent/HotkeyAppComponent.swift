//
//  HotkeyAppComponent.swift
//  Fenestra
//
//  Created by Kevin Kerr on 9/13/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Foundation
import HotKey
import FenestraCommonLib;

final class HotkeyAppComponent: AppComponent {
	func doIt() {
		NotificationCenter.default.addObserver(forName: .fenestraPreferencesOnClosed, object: nil, queue: nil) {
			[weak self] (notification) in self?.setUpGridSelectionHotKey();
		}
		NotificationCenter.default.addObserver(forName: .disableFenestraSelectionHotKey, object: nil, queue:nil) {
			[weak self] (notification) in self?.openGridSelectionWindowHotKey = nil;
		}
		NotificationCenter.default.addObserver(forName: .setUpCloseOutstandingSelectionHotKey, object: nil, queue: nil) {
			[weak self] (notification) in self?.closeOutstandingSelectionWindowsHotKey = HotKey(keyCombo: KeyCombo(key: .escape));
		}
		NotificationCenter.default.addObserver(forName: .fenestraSelectionComplete, object: nil, queue:nil) {
			[weak self] (notification) in self?.closeOutstandingSelectionWindowsHotKey = nil;
		}

		setUpGridSelectionHotKey();
	}

	func setUpGridSelectionHotKey() {
		let data=UserDefaults.standard.dictionary(forKey: FenestraPreferences.preferences.rawValue);
		let keyCombo=KeyCombo(dictionary: (data?[FenestraPreferences.hotkeyCombo.rawValue] as? [String: Any] ?? KeyCombo(key: .d, modifiers: [.command, .shift]).dictionary))
		openGridSelectionWindowHotKey = HotKey(keyCombo: keyCombo!);
	}

	private var openGridSelectionWindowHotKey:HotKey? {
		didSet {
			guard let hotKey = openGridSelectionWindowHotKey else {
				return;
			}
			hotKey.keyDownHandler = {
				NotificationCenter.default.post(name: .openFenestraSelection, object: nil);
			}
		}
	}

	private var closeOutstandingSelectionWindowsHotKey:HotKey? {
		didSet {
			guard let hotKey = closeOutstandingSelectionWindowsHotKey else {
				return;
			}
			hotKey.keyDownHandler = { [weak self] in
				NotificationCenter.default.post(name: .fenestraSelectionComplete, object: nil);
				self?.closeOutstandingSelectionWindowsHotKey = nil;
			}
		}
	}
}
