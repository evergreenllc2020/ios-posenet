//
//  PoseBuilderConfiguration.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/29/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreGraphics

enum Algorithm : Int {
    case single
    case multiple
}

struct PoseBuilderConfiguration {
    
    var jointConfidenceThreshold = 0.1
    
    var poseConfidenceThreshold = 0.5
    
    var matchingJointDistance = 40.0
    
    var localSearchRadius = 3
    
    var maxPoseCount = 15
    
    var adjecentJointOffsetRefinementSteps = 3
    
    
}
