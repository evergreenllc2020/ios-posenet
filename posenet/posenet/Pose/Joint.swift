//
//  Joint.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/29/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreGraphics

class Joint {
    
    enum Name: Int, CaseIterable {
        case nose
        case leftEye
        case rightEye
        case leftEar
        case rightEar
        case leftShoulder
        case rightShoulder
        case leftElbow
        case rightElbow
        case leftWrist
        case rightWrist
        case leftHip
        case rightHip
        case leftKnee
        case rightKnee
        case leftAnkle
        case rightAnkle
        
    }
    
    static var numberOfJoints : Int {
        return self.Name.allCases.count
    }
    
    
    let name: Name
    
    var position : CGPoint
    
    var cell : PoseNetOutput.Cell
    
    var confidence : Double
    
    var isValid : Bool
    
    init(name: Name,
         cell: PoseNetOutput.Cell = .zero,
         position : CGPoint = .zero,
         confidence: Double = 0,
         isValid : Bool = false
        
       )
    
    {
        self.name = name
        self.cell = cell
        self.position = position
        self.confidence = confidence
        self.isValid = isValid
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
}
