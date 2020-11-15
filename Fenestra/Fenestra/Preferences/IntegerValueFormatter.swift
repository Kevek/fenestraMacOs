//
//  IntegerValueFormatter.swift
//  Fenestra
//
//  Created by Kevin Kerr on 6/23/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Foundation

class IntegerValueFormatter : NumberFormatter {
    override func	isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        return partialString.isEmpty || Int(partialString) != nil;
    }
}
