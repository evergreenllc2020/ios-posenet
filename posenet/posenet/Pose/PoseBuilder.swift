//
//  PoseBuilder.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/29/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreGraphics

struct PoseBuilder
{
    
    let output: PoseNetOutput
    
    let modelInputTransformation: CGAffineTransform
    
    var configuration: PoseBuilderConfiguration
    
    init(output: PoseNetOutput,
         configuration: PoseBuilderConfiguration,
         inputImage: CGImage)
    {
        self.output = output
        self.configuration = configuration
        modelInputTransformation = CGAffineTransform( scaleX : inputImage.size.width / output.modelInputSize.width, y:inputImage.size.height / output.modelInputSize.height )
        
    }
    
}
