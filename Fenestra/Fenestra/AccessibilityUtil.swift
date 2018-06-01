//
//  Accessibility.swift
//  Fenestra
//
//  Created by Kevin Kerr on 5/27/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Cocoa

struct AccessibilityUtil {
	static func isTrustedAccessibilityProcess(showPrompt:Bool = false) -> Bool {
		let checkOptionPrompt=kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String;
		let options = [checkOptionPrompt : showPrompt] as CFDictionary;
		return AXIsProcessTrustedWithOptions(options);
	}

	static func unwrapAXValue(_ value: AnyObject) -> (success:Bool, value:Any) {
		switch CFGetTypeID(value) {
		case AXUIElementGetTypeID():
			// TODO: Do something with the UIElement...
			return (false, value);
		case AXValueGetTypeID():
			let type = AXValueGetType(value as! AXValue);
			switch type {
			case .axError:
				var result: AXError = .success;
				let success = AXValueGetValue(value as! AXValue, type, &result);
				assert(success);
				return (true, result);
			case .cfRange:
				var result: CFRange = CFRange();
				let success = AXValueGetValue(value as! AXValue, type, &result);
				assert(success);
				return (true, result);
			case .cgPoint:
				var result: CGPoint = CGPoint.zero;
				let success = AXValueGetValue(value as! AXValue, type, &result);
				assert(success);
				return (true, result);
			case .cgRect:
				var result: CGRect = CGRect.zero;
				let success = AXValueGetValue(value as! AXValue, type, &result);
				assert(success);
				return (true, result);
			case .cgSize:
				var result: CGSize = CGSize.zero;
				let success = AXValueGetValue(value as! AXValue, type, &result);
				assert(success);
				return (true, result);
			case .illegal:
				return (false, value);
			}
		default:
			return (false, value);
		}
	}

	static func wrapAXValue(_ value: AnyObject) -> (success:Bool, axValue:AnyObject) {
		switch value {
		case var range as CFRange:
			let axValue: AXValue = AXValueCreate(AXValueType(rawValue: kAXValueCFRangeType)!, &range)!
			return (true, axValue);
		case var point as CGPoint:
			let axValue: AXValue = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &point)!
			return (true, axValue);
		case var rect as CGRect:
			let axValue:AXValue = AXValueCreate(AXValueType(rawValue: kAXValueCGRectType)!, &rect)!;
			return (true, axValue);
		case var size as CGSize:
			let axValue:AXValue = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &size)!;
			return (true, axValue);
		default:
			return (false, value); // must be an object to pass to AX
		}
	}
}
