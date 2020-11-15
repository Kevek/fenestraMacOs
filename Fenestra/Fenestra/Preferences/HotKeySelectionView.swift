//
//  HotKeySelectionView.swift
//  Fenestra
//
//  Created by Kevin Kerr on 6/9/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa;
import HotKey;
import FenestraCommonLib;

public class HotKeySelectionView : NSTextView {
    var keyCombo:KeyCombo? {
        didSet {
            if let keyCombo = keyCombo {
                var keys=[String]();
                for kvp in modifiers {
                    if(keyCombo.modifiers.contains(kvp.value)) {
                        keys.append(kvp.key);
                    }
                }
                keys.append("\(keyCombo.key!)");
                self.string=keys.intercalate(intercaland: "-");
            }
        }
    };
    
    let modifiers:[String:NSEvent.ModifierFlags] = [
        "cmd": .command,
        "ctrl": .control,
        "option": .option,
        "shift": .shift,
    ];
    
    public override func keyDown(with event: NSEvent) {
        keyCombo=KeyCombo(carbonKeyCode: UInt32(event.keyCode), carbonModifiers: event.modifierFlags.carbonFlags);
    }
}
