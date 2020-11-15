//
//  AppDelegate.swift
//  FenestraLauncher
//
//  Created by Kevin Kerr on 6/17/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa;
import FenestraCommonLib;

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let isFenestraRunning = !NSWorkspace.shared.runningApplications.filter { $0.bundleIdentifier==FenestraPreferences.fenestraBundleIdentifier.rawValue }.isEmpty;
        
        if (!isFenestraRunning) {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(stopLauncher), name: .fenestraStopLauncher, object: FenestraPreferences.fenestraBundleIdentifier.rawValue);
            
            var pathComponents = (Bundle.main.bundlePath as NSString).pathComponents;
            pathComponents.removeLast();
            pathComponents.removeLast();
            pathComponents.removeLast();
            pathComponents.removeLast();
            let newPath = NSString.path(withComponents: pathComponents);
            NSWorkspace.shared.launchApplication(newPath);
        } else {
            stopLauncher();
        }
    }
    
    @objc func stopLauncher() {
        NSApp.terminate(nil);
    }
}

