//
//  PoseBuilder+Multiple.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/29/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreGraphics

extension PoseBuilder
{
    
    var poses: [Pose] {
        
        var detectedPoses = [Pose]()
        
        for candidateRoot in candidateRoots
        {
            let maxDistance = configuration.matchingJointDistance
            guard !detectedPoses.contains(candidateRoot, within: maxDistance) else {continue}
            var pose = assemplePose(from: candidateRoot)
            pose.confidence = confidence(for: pose, detectedPoses: detectedPoses)
            
            guard pose.confidence >= configuration.poseConfidenceThreshold else {continue}
            
            detectedPoses.append(pose)
            
            if detectedPoses.count >= configuration.maxPoseCount {
                break
            }
            
            
        }
        
        
        detectedPoses.forEach {pose in
            pose.joints.values.forEach { joint in
                joint.position = joint.position.applying(modelInputTransformation)
            }
        }
        
        return detectedPoses
        
        
    }
    
    
    
    private var candidateRoots : [Joint]
    {
        var candidateRoots = [Joint]()
        
        for jointName in Joint.Name.allCases
        {
            for yIndex in 0..<output.height
            {
                for xIndex in 0..<output.width
                {
                    let cell = PoseNetOutput.Cell(yIndex, xIndex)
                    
                    let jointConfidence = output.confidence(for: jointName, at: cell)
                    
                    guard jointConfidence >= configuration.jointConfidenceThreshold else {continue}
                    
                    let greatestNeighborsConfidence = greatestConfidence(for: jointName, at: cell)
                    
                    guard jointConfidence >= greatestNeighborsConfidence else {continue}
                    
                    let candidate = Joint(name: jointName,
                                          cell: cell,
                                          position: output.position(for: jointName, at: cell),
                                          confidence: jointConfidence,
                                          isValid: true
                                          )
                    
                    candidateRoots.append(candidate)
                    
                    
                    
                }
            }
            
            
        }
        
        return candidateRoots.sorted {$0.confidence > $1.confidence}
        
    }
    
    private func confidence(for pose:Pose, detectedPoses:[Pose]) -> Double
    {
        let joints = nonOverlappingJoints(for: pose, detectedPoses: detectedPoses)
        return joints.map {$0.confidence}.reduce(0, +) / Double(Joint.numberOfJoints)
        
    }
    
    
    
    private func nonOverlappingJoints(for pose: Pose, detectedPoses: [Pose]) -> [Joint] {
        
        return pose.joints.values.filter { joint in
            
            guard joint.isValid else {return false}
            
            for detectedPose in detectedPoses
            {
                let otherJoint = detectedPose[joint.name]
                
                guard otherJoint.isValid else {continue }
                
                if joint.position.distance(to: otherJoint.position) <= configuration.matchingJointDistance
                {
                    return false
                }
                
            
                
            }
             return true
        }
        
        
        
        
    }
    
    
    
    private func greatestConfidence(for jointName: Joint.Name, at cell:PoseNetOutput.Cell) -> Double
    {
        let yLowerBound = max(cell.yIndex - configuration.localSearchRadius, 0)
        let yUpperBound = min(cell.yIndex + configuration.localSearchRadius, output.height-1)
        let yWindowIndices : ClosedRange<Int> = yLowerBound...yUpperBound
        
        let xLowerBound = max(cell.xIndex - configuration.localSearchRadius, 0)
        let xUpperBound = min(cell.xIndex + configuration.localSearchRadius, output.width-1)
        let xWindowIndices : ClosedRange<Int> = xLowerBound...xUpperBound
        
        var greatestConfidence = 0.0
        
        for yIndex in yWindowIndices
        {
            for xIndex in xWindowIndices
            {
                guard yIndex != cell.yIndex, xIndex != cell.xIndex else { continue }
                let localCell = PoseNetOutput.Cell(yIndex, xIndex)
                let localConfidence = output.confidence(for: jointName, at: localCell)
                greatestConfidence = max(greatestConfidence, localConfidence)
            }
        }
        
        return greatestConfidence
        
    }
    
    
    private func assemplePose(from rootJoint: Joint) -> Pose
    {
        var pose = Pose()
        pose[rootJoint.name] = rootJoint
        
        var queryJoints = [rootJoint]
        
        while !queryJoints.isEmpty {
            let joint = queryJoints.removeFirst()
            
            for edge in Pose.edges(for: joint.name)
            {
                let parentJoint = pose[edge.parent]
                let childJoint = pose[edge.child]
                
                guard !(parentJoint.isValid && childJoint.isValid) else {continue}
                
                let sourceJoint = parentJoint.isValid ? parentJoint : childJoint
                let adjecentJoint = parentJoint.isValid ? childJoint : parentJoint
                
                configure(joint: adjecentJoint, from: sourceJoint, given: edge)
                if adjecentJoint.isValid
                {
                    queryJoints.append(adjecentJoint)
                }
                
            }
            
        }
        return pose
        
        
        
    }
    
    
    
    private func configure(joint: Joint,
                           from sourceJoint: Joint,
                           given edge: Pose.Edge)
    {
        
        var displacementVector = CGVector.zero
        
        if edge.parent == sourceJoint.name
        {
            displacementVector = output.forwardDisplacement(for : edge.index, at : sourceJoint.cell)
        }
        else
        {
            displacementVector = output.backwardDisplacement(for : edge.index, at : sourceJoint.cell)
        }
        
        var approximateJointPosition = sourceJoint.position + displacementVector
        
        for _ in 0..<configuration.adjecentJointOffsetRefinementSteps {
            guard let jointCell = output.cell(for: approximateJointPosition) else {break}
            let offset = output.offset(for: joint.name, at: jointCell)
            approximateJointPosition.x = CGFloat(jointCell.xIndex) * CGFloat(output.modelOutputStride) + offset.dx
            approximateJointPosition.y = CGFloat(jointCell.yIndex) * CGFloat(output.modelOutputStride) + offset.dy
            
        }
        
        
        guard let jointCell = output.cell(for: approximateJointPosition) else {return}
        
        joint.cell = jointCell
        joint.position = approximateJointPosition
        joint.confidence = output.confidence(for: joint.name, at: joint.cell)
        joint.isValid = joint.confidence >= configuration.jointConfidenceThreshold
        
        
        
        
        
        
        
    }
}










private extension Array where Element == Pose {
    
    func contains(_ candidate : Joint, within distance: Double) -> Bool
    {
        for pose in self
        {
            let matchingJoint = pose[candidate.name]
            
            guard matchingJoint.isValid else { continue}
            if matchingJoint.position.distance(to: candidate.position) <= distance {
                return true
            }
        }
        return false
    }
    
    
    
}
