//
//  AVCaptureVideoOrientation.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/27/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import AVFoundation
import UIKit

extension AVCaptureVideoOrientation {
    init(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .landscapeLeft :
            self = .landscapeLeft
       case .landscapeRight :
            self = .landscapeRight
       case .portrait :
            self = .portrait
       case .portraitUpsideDown :
            self = .portraitUpsideDown
        default:
            self = .portrait
            
        }
        
        
        
        
    }
    
}
