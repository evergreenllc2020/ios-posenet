//
//  PosenetInput.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/27/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import CoreML
import Vision


class PoseNetInput : MLFeatureProvider {
    
    private static let imageFeatureName = "image"
    
    var imageFeature : CGImage
    
    let imageFeatureSize : CGSize
    
    var featureNames: Set<String> {
        return [PoseNetInput.imageFeatureName]
    }
    
    
    init(image: CGImage, size: CGSize)
    {
        imageFeature = image
        imageFeatureSize = size
    }
    
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        
        guard featureName == PoseNetInput.imageFeatureName else {return nil}
        
        let options: [MLFeatureValue.ImageOption: Any] = [
            MLFeatureValue.ImageOption.cropAndScale : VNImageCropAndScaleOption.scaleFill.rawValue
        ]
        
        return try? MLFeatureValue(cgImage: imageFeature,
                                   pixelsWide: Int(imageFeatureSize.width),
                                   pixelsHigh: Int(imageFeatureSize.height),
                                   pixelFormatType: imageFeature.pixelFormatInfo.rawValue,
                                   options: options)
        
        
        
    }
    
    
    
    
    
}
