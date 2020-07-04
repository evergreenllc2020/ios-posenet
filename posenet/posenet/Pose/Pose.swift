//
//  Pose.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/29/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreGraphics

struct Pose
{
    struct Edge{
        let index : Int
        let parent: Joint.Name
        let child: Joint.Name
        
        init(from parent: Joint.Name, to child: Joint.Name, index: Int){
            self.index = index
            self.parent = parent
            self.child = child
        }
        
        
    }
    
    static let edges = [
        Edge(from: .nose, to : .leftEye, index: 0),
        Edge(from: .leftEye, to : .leftEar, index: 1),
        Edge(from: .nose, to : .rightEye, index: 2),
        Edge(from: .rightEye, to : .rightEar, index: 3),
        Edge(from: .nose, to : .leftShoulder, index: 4),
        Edge(from: .leftShoulder, to : .leftElbow, index: 5),
        Edge(from: .leftElbow, to : .leftWrist, index: 6),
        Edge(from: .leftShoulder, to : .leftHip, index: 7),
        Edge(from: .leftHip, to : .leftKnee, index: 8),
        Edge(from: .leftKnee, to : .leftAnkle, index: 9),
        Edge(from: .nose, to : .rightShoulder, index: 10),
        Edge(from: .rightShoulder, to : .rightElbow, index: 11),
        Edge(from: .rightElbow, to : .rightWrist, index: 12),
        Edge(from: .rightShoulder, to : .rightHip, index: 13),
        Edge(from: .rightHip, to : .rightKnee, index: 14),
        Edge(from: .rightKnee, to : .rightAnkle, index: 15)
        
    
    
    
    ]
    
    
    private(set) var joints : [Joint.Name: Joint] = [
        .nose : Joint(name: .nose),
        .leftEye : Joint(name: .leftEye),
        .leftEar : Joint(name: .leftEar),
        .leftShoulder : Joint(name: .leftShoulder),
        .leftElbow : Joint(name: .leftElbow),
        .leftWrist : Joint(name: .leftWrist),
        .leftHip : Joint(name: .leftHip),
        .leftKnee : Joint(name: .leftKnee),
        .leftAnkle : Joint(name: .leftAnkle),
        .rightEye : Joint(name: .rightEye),
        .rightEar : Joint(name: .rightEar),
        .rightShoulder : Joint(name: .rightShoulder),
        .rightElbow : Joint(name: .rightElbow),
        .rightWrist : Joint(name: .rightWrist),
        .rightHip : Joint(name: .rightHip),
        .rightKnee : Joint(name: .rightKnee),
        .rightAnkle : Joint(name: .rightAnkle),
        
            
    
    ]
    
    var confidence : Double = 0.0
    
    subscript(jointName: Joint.Name) -> Joint {
        get {
            assert(joints[jointName] != nil)
            return joints[jointName]!
        }
        set{
            joints[jointName] = newValue
        }
    }
    
    
    static func edges(for jointName: Joint.Name) -> [Edge]
    {
        return Pose.edges.filter {   $0.parent == jointName || $0.child == jointName}
    }
    
    static func edge(from parentJointName : Joint.Name , to childJointName : Joint.Name) -> Edge?
    {
        return Pose.edges.first(where: {$0.parent == parentJointName && $0.child == childJointName})
    }
    
    
    
    
}
