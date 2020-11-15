//
//  AppComponent.swift
//  Fenestra
//
//  Created by Kevin Kerr on 9/12/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa;

protocol AppComponent {
    func doIt();
}

final class AppCommandsBuilder {
    func build() -> [AppComponent] {
        return [
            InitializeStatusBarAppComponent(),
            GridSelectionAppComponent(),
            HotkeyAppComponent(),
            PreferencesAppComponent(),
        ];
    }
}
