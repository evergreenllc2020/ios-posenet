//
//  PoseNet.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/29/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreML
import Vision

protocol PoseNetDelegate : AnyObject
{
    func posnet(_ posenet: PoseNet, didPredict predictions: PoseNetOutput)
}

class PoseNet {
    
    weak var delegate: PoseNetDelegate?
    
    let modelInputSize = CGSize(width: 513, height:513)
    
    let outputStride = 16
    
    private let poseNetModel : MLModel
    
    init() throws
    {
        poseNetModel = try PoseNetMobileNet075S16FP16(configuration: .init()).model
        
    }
    
    func predict(_ image : CGImage)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let input = PoseNetInput(image: image, size: self.modelInputSize)
            
            guard let prediction = try? self.poseNetModel.prediction(from: input) else {return }
            
            let poseNetOutput = PoseNetOutput(prediction: prediction,
                                              modelInputSize: self.modelInputSize,
                                              modelOutputStride: self.outputStride)
            
            DispatchQueue.main.async {
                self.delegate?.posnet(self, didPredict: poseNetOutput)
            }

        }
        
    }
    
    
    
    
}
