//
//  GridResizeDelegate.swift
//  Fenestra
//
//  Created by Kevin Kerr on 5/30/18.
//  Copyright © 2018 CodingPanda. All rights reserved.
//

protocol GridResizeDelegate {
    func getSelectionGridSize() -> (numRows:Int, numColumns:Int);
    func resizeGrid(xOriginPercent:Double, yOriginPercent:Double, screenWidthPercent:Double, screenHeightPercent:Double);
}
