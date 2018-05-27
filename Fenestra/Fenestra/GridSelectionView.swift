//
//  GridSelectionView.swift
//  
//
//  Created by Kevin Kerr on 5/28/18.
//

import Cocoa

class GridSelectionView: NSView {
	var gridResizeDelegate:GridResizeDelegate? {
		didSet {
			createGrid();
		}
	}

	let margin = 4;
	let borderWidth = CGFloat(2);
	let cornerRadius = CGFloat(4);

	var grid = [GridSelectionCell]();
	var startPoint:NSPoint?=nil;
	var endPoint:NSPoint?=nil;

	var gridDimensions:(numRows:Int, numColumns:Int)!;
	var minSelectedCell:GridSelectionCell?;
	var maxSelectedCell:GridSelectionCell?;

	func createGrid() {
		gridDimensions=gridResizeDelegate?.getSelectionGridSize() ?? (numRows:4, numColumns:4);
		let boundsHeight=Int(bounds.maxY - bounds.minY);
		let cellHeight = (boundsHeight / gridDimensions.numRows) - (2 * margin);
		let rowStep = cellHeight + margin;

		let boundsWidth = Int(bounds.maxX - bounds.minX);
		let cellWidth = (boundsWidth / gridDimensions.numColumns) - (2 * margin);
		let columnStep = cellWidth + margin;

		for row in 0...gridDimensions.numRows-1 {
			for column in 0...gridDimensions.numColumns-1 {
				grid.append(GridSelectionCell(rect: NSRect(x: margin + (column * columnStep),
																									 y: margin + (row * rowStep),
																									 width: cellWidth,
																									 height: cellHeight),
																			row: row,
																			column: column));
			}
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		var selectionRect:NSRect?=nil;
		if let startPoint=startPoint, let endPoint=endPoint {
			let x=min(startPoint.x, endPoint.x)
			let y=min(startPoint.y, endPoint.y)
			let width=abs(endPoint.x - startPoint.x);
			let height=abs(endPoint.y - startPoint.y);
			selectionRect=NSRect(x: x, y: y, width: width, height: height);
		}

		for cell in grid {
			let path = NSBezierPath();
			path.lineWidth=borderWidth;
			NSColor.black.set();
			path.appendRoundedRect(cell.rect, xRadius: cornerRadius, yRadius: cornerRadius);
			path.stroke();
			if selectionRect != nil && (selectionRect?.intersects(cell.rect) ?? false || selectionRect?.contains(cell.rect) ?? false) {
				if minSelectedCell==nil || cell<minSelectedCell! {
					minSelectedCell=cell;
				}
				if maxSelectedCell==nil || cell>maxSelectedCell! {
					maxSelectedCell=cell;
				}
				NSColor.yellow.set();
				path.fill()
			}
		}

		if selectionRect != nil {
			NSColor.blue.set();
			let path = NSBezierPath();
			path.lineWidth=borderWidth;
			path.appendRoundedRect(selectionRect!, xRadius: cornerRadius, yRadius: cornerRadius);
			path.stroke();
		}
	}

	override func mouseDown(with event: NSEvent) {
		startPoint=convert(event.locationInWindow, from: nil);
	}

	override func mouseDragged(with event: NSEvent) {
		endPoint=convert(event.locationInWindow, from: nil);
		setNeedsDisplay(bounds);
	}

	override func mouseUp(with event: NSEvent) {
		guard let minSelectedCell=minSelectedCell else {
			return;
		}
		guard let maxSelectedCell=maxSelectedCell else {
			return;
		}
		// Convert values to double
		let numRows=Double(gridDimensions.numRows);
		let numColumns=Double(gridDimensions.numColumns);
		let minRow=Double(minSelectedCell.row);
		let minColumn=Double(minSelectedCell.column);
		let maxRow=Double(maxSelectedCell.row);
		let maxColumn=Double(maxSelectedCell.column);
		// Calculate new origin and window width
		let xOriginPercent=minColumn / numColumns;
		let yOriginPercent=minRow / numRows;
		let screenWidthPercent=(maxColumn-minColumn+1)/numColumns;
		let screenHeightPercent=(maxRow-minRow+1)/numRows;

		gridResizeDelegate!.resizeGrid(xOriginPercent: xOriginPercent, yOriginPercent: yOriginPercent, screenWidthPercent: screenWidthPercent, screenHeightPercent: screenHeightPercent);

		// TODO: Temp: Resetting for debugging purposes...
		self.minSelectedCell=nil;
		self.maxSelectedCell=nil;
	}
}
