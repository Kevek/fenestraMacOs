//
//  GridSelectionAppComponent.swift
//  Fenestra
//
//  Created by Kevin Kerr on 9/13/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa

final class GridSelectionAppComponent: AppComponent {
	var windows : [NSWindowController?] = [];

	func doIt() {
		NotificationCenter.default.addObserver(forName: .openFenestraSelection, object: nil, queue: nil) {
			[weak self] (notification) in self?.openGridSelectionWindows();
		}
		NotificationCenter.default.addObserver(forName: .fenestraSelectionComplete, object: nil, queue: nil) {
			[weak self] (notification) in self?.closeGridSelectionWindows();
		}
	}

	func openGridSelectionWindows() {
		closeGridSelectionWindows();
		let frontmostApplication=NSWorkspace.shared.frontmostApplication;
		let storyboard = NSStoryboard(name: "Main", bundle: nil);
		for screen in NSScreen.screens {
			guard let windowController = storyboard.instantiateController(withIdentifier:"FenestraGridSelectionWindowConroller") as? NSWindowController else {
				fatalError("Error getting main window controller")
			}
			if let gridSelection = windowController.contentViewController as? GridSelectionViewController {
				gridSelection.screen=screen;
				gridSelection.frontmostApplication=frontmostApplication;
			}
			setExtraGridSelectionWindowProperties(window: windowController.window, screen: screen);
			windows.append(windowController);
		}
		for window in windows {
			window?.showWindow(self);
		}
	}

	func setExtraGridSelectionWindowProperties(window:NSWindow?, screen:NSScreen) {
		window?.level = .floating;
		window?.hasShadow = false;
		window?.isOpaque = false;
		window?.isMovable = false;
		window?.backgroundColor = NSColor.fenestraBackgroundColor;

		let frameOrigin=NSPoint(x: screen.visibleFrame.midX - (window?.frame.width ?? 0) / 2,
														y: screen.visibleFrame.midY - (window?.frame.height ?? 0) / 2);
		window?.setFrameOrigin(frameOrigin);

		window?.titlebarAppearsTransparent = true;
		window?.titleVisibility = .hidden;
		window?.standardWindowButton(.miniaturizeButton)?.isHidden=true;
		window?.standardWindowButton(.zoomButton)?.isHidden=true;
	}

	func closeGridSelectionWindows() {
		for window in windows {
			window?.close();
		}
		windows.removeAll();
	}
}
