//
//  GridSelectionCell.swift
//  Fenestra
//
//  Created by Kevin Kerr on 5/28/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

import Foundation

class GridSelectionCell: Comparable {
	let rect:NSRect;
	let row:Int;
	let column:Int;

	init(rect:NSRect, row:Int, column: Int) {
		self.rect=rect;
		self.row=row;
		self.column=column;
	}

	static func < (lhs: GridSelectionCell, rhs: GridSelectionCell) -> Bool {
		return lhs.row<rhs.row || lhs.column<rhs.column;
	}

	static func == (lhs: GridSelectionCell, rhs: GridSelectionCell) -> Bool {
		return lhs.row==rhs.row && lhs.column==rhs.column;
	}
}
