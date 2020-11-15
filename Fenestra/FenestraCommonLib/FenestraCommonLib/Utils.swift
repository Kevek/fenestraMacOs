//
//  Utils.swift
//  Fenestra
//
//  Created by Kevin Kerr on 6/10/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Foundation;

public extension Sequence where Iterator.Element == String {
    func intercalate(intercaland:String? = nil) -> String {
        let intercaland = intercaland ?? ",";
        return self.reduce("") { (extant, new) in
            if (extant==""){
                return new;
            }
            return "\(extant)\(intercaland)\(new)"
        };
    }
}
