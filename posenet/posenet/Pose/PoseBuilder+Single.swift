//
//  PoseBuilder+Single.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/29/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreGraphics

extension PoseBuilder{
    
    var pose: Pose {
        
        var pose = Pose()
        pose.joints.values.forEach{ joint in
            configure(joint: joint)
        }
        
        pose.confidence = pose.joints.values.map {$0.confidence}.reduce(0, +) / Double(Joint.numberOfJoints)
        
        pose.joints.values.forEach { joint in
            joint.position = joint.position.applying(modelInputTransformation)
            
        }
        
        
        
        return pose
        
        
    }
    
    
    private func configure(joint: Joint)
    {
        var bestCell = PoseNetOutput.Cell(0,0)
        var bestConfidence = 0.0
        
        for yIndex in 0..<output.height
        {
            for xIndex in 0..<output.width
            {
                let currentCell = PoseNetOutput.Cell(yIndex, xIndex)
                let currentConfidence = output.confidence(for: joint.name, at: currentCell)
                if currentConfidence > bestConfidence
                {
                    bestConfidence = currentConfidence
                    bestCell = currentCell
                }
                
            }
        }
        
        joint.cell = bestCell
        joint.confidence = bestConfidence
        joint.isValid = joint.confidence >= configuration.jointConfidenceThreshold
        
        
        
    }
    
    
}
