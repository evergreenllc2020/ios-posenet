//
//  CGPoint+Extension.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/28/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    
    init(_ cell: PoseNetOutput.Cell)
    {
        self.init(x: CGFloat(cell.xIndex), y: CGFloat(cell.yIndex))
    }
    
    func squaredDistance(to other: CGPoint) -> CGFloat {
        
        let diffX = other.x - x
        let diffY = other.y - y
        return diffX * diffX + diffY * diffY
        
    }
    
    func distance(to other: CGPoint) -> Double
    {
        return Double(squaredDistance(to: other).squareRoot())
    }
     
    static func + (_ lhs: CGPoint, _ rhs: CGVector) -> CGPoint
    {
        return CGPoint(x: lhs.x + rhs.dx , y: lhs.y + rhs.dy)
    }
    
    static func += (_ lhs: inout CGPoint, _ rhs: CGVector) {
        lhs.x += rhs.dx
        lhs.y += rhs.dy
    }
    
    static func * (_ lhs: CGPoint, _ scale: CGFloat) -> CGPoint
    {
        return CGPoint(x: lhs.x * scale , y: lhs.y * scale)
    }
    
    
    static func * (_ lhs: CGPoint, _ rhs: CGSize) -> CGPoint
    {
        return CGPoint(x: lhs.x * rhs.width , y: lhs.y * rhs.height)
    }
    
    
    
    
    
    
    
    
    
}

