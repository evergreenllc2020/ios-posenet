//
//  PoseNetOutput.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/28/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreML
import Vision


struct PoseNetOutput {
    enum Feature : String {
        
        case heatmap = "heatmap"
        case offsets = "offsets"
        case backwardDsiplacementMap = "displacementBwd"
        case forwardDisplacementMap = "displacementFwd"
        
        
    }
    
    struct Cell {
        let yIndex: Int
        let xIndex: Int
        
        init(_ yIndex: Int, _ xIndex: Int)
        {
            self.yIndex = yIndex
            self.xIndex = xIndex
        }
        
        static var zero: Cell {
            return Cell(0,0)
        }
        
    }
    
    
    //stores confidence
    let heatmap: MLMultiArray
    
    //stores x and y coordinate of each joint
    let offsets: MLMultiArray
    
    //parent to child distance
    //[edge][y][x]
    let backwardDisplacementMap : MLMultiArray
    
    //child to parent distance
    //[edge][y][x]
    let forwardDisplacementMap : MLMultiArray
        
    //Possible image size 257 x 257 | 353 x 353 | 513x513
    let modelInputSize : CGSize
    
    
    // 16 or 8
    let modelOutputStride : Int
    
    
    var height: Int
    {
        return heatmap.shape[1].intValue
    }
    
    var width: Int
    {
        return heatmap.shape[2].intValue
    }
    
    
    init(prediction: MLFeatureProvider, modelInputSize: CGSize, modelOutputStride: Int)
    {
        
        guard let heatmap = prediction.multiArrayValue(for : .heatmap) else {fatalError ("Failed to get heatmap")}
        
        guard let offsets = prediction.multiArrayValue(for : .offsets) else {fatalError ("Failed to get offsets")}
        
        
        guard let backwardDisplacementMap = prediction.multiArrayValue(for : .backwardDsiplacementMap) else {fatalError ("Failed to get backwardDisplacementMap")}
        
        
        guard let forwardDisplacementMap = prediction.multiArrayValue(for : .forwardDisplacementMap) else {fatalError ("Failed to get forwardDisplacement map")}
        
        self.heatmap = heatmap
        self.offsets = offsets
        self.backwardDisplacementMap = backwardDisplacementMap
        self.forwardDisplacementMap = forwardDisplacementMap
        
        self.modelInputSize = modelInputSize
        self.modelOutputStride = modelOutputStride
        
        
        
        
    }
    
}

extension PoseNetOutput {
    
    func position(for jointName: Joint.Name, at cell: Cell) -> CGPoint
    {
        let jointOffset = offset(for :jointName, at : cell)
        
        var jointPosition = CGPoint(x: cell.xIndex * modelOutputStride,
                                    y: cell.yIndex * modelOutputStride)
        
        jointPosition += jointOffset
        return jointPosition
        
    }
    
    func cell(for position: CGPoint) -> Cell?
    {
        let yIndex = Int((position.y / CGFloat(modelOutputStride)).rounded())
        let xIndex = Int((position.x / CGFloat(modelOutputStride)).rounded())
        
        guard yIndex >= 0 && yIndex < height && xIndex >= 0 && xIndex < width else {return nil}
        
        return Cell(yIndex, xIndex)
        
    }
    
    func offset(for jointName: Joint.Name, at cell: Cell) -> CGVector
    {
        let yOffsetIndex = [jointName.rawValue, cell.yIndex, cell.xIndex]
        let xOffsetIndex = [jointName.rawValue + Joint.numberOfJoints , cell.yIndex, cell.xIndex]
        
        let offsetY : Double = offsets[yOffsetIndex].doubleValue
        let offsetX : Double = offsets[xOffsetIndex].doubleValue
        
        return CGVector(dx: CGFloat(offsetX), dy: CGFloat(offsetY))
        
    }
    
    func confidence(for jointName: Joint.Name , at cell: Cell) -> Double
    {
        let multiArrayIndex = [jointName.rawValue, cell.yIndex, cell.xIndex]
        return heatmap[multiArrayIndex].doubleValue
    }
    
    
    func forwardDisplacement(for edgeIndex: Int, at cell: Cell) -> CGVector {
        let yEdgeIndex = [edgeIndex, cell.yIndex, cell.xIndex]
        let xEdgeIndex = [edgeIndex + Pose.edges.count, cell.yIndex, cell.xIndex]
        
        let displacementY = forwardDisplacementMap[yEdgeIndex].doubleValue
        let displacementX = forwardDisplacementMap[xEdgeIndex].doubleValue
        
        return CGVector(dx: displacementX, dy: displacementY)
        
        
    }
    
    
    func backwardDisplacement(for edgeIndex: Int, at cell: Cell) -> CGVector {
           let yEdgeIndex = [edgeIndex, cell.yIndex, cell.xIndex]
           let xEdgeIndex = [edgeIndex + Pose.edges.count, cell.yIndex, cell.xIndex]
           
           let displacementY = backwardDisplacementMap[yEdgeIndex].doubleValue
           let displacementX = backwardDisplacementMap[xEdgeIndex].doubleValue
          
           return CGVector(dx: displacementX, dy: displacementY)
           
           
       }
    
    
    
    
    
}







extension MLFeatureProvider {
    
    func multiArrayValue(for feature: PoseNetOutput.Feature) -> MLMultiArray? {
        return featureValue(for: feature.rawValue)?.multiArrayValue
    }
    
}

extension MLMultiArray {
    subscript(index: [Int]) -> NSNumber {
        return self[index.map{ NSNumber(value: $0)}  ]
    }
}
