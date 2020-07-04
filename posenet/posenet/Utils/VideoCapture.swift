//
//  VideoCapture.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/26/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

//import Foundation
import AVFoundation
import CoreVideo
import UIKit
import VideoToolbox


protocol VideoCaptureDelegate : AnyObject {
    func videoCapture(_ VideoCapture: VideoCapture, didCaptureFrame capturedImage : CGImage? )
       
}



class VideoCapture  : NSObject
{
    enum VideoCaptureError : Error {
        case captureSessionIsMissing
        case invalidInput
        case invalidOutput
        case unknown
    }
    
    weak var delegate : VideoCaptureDelegate?
    
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    
    private var cameraPosition = AVCaptureDevice.Position.back
    
    private let sessionQueue = DispatchQueue(label:"com.example.posent.sessionqueue")
    
    
    public func flipCamera(completion: @escaping (Error?)-> Void) {
     
        sessionQueue.async {
                do {
                        self.cameraPosition = self.cameraPosition == .back ? .front : .back
                        self.captureSession.beginConfiguration()
                        try self.setCaptureSessionInput()
                        try self.setCaptureSessionOutput()
                        self.captureSession.commitConfiguration()
                        DispatchQueue.main.async {
                                completion(nil)
                        }
                   
                
                }
                catch {
                            DispatchQueue.main.async {
                               completion(error)
                            }
                
                }
     
        }
    }
    
    public func setUpAVCapture(completion: @escaping (Error?)-> Void) {
        sessionQueue.async {
            
            do {
                try self.setUpAVCapture()
                DispatchQueue.main.async {
                   completion(nil)
                }
            }
            catch
            {
                DispatchQueue.main.async {
                   completion(error)
                }
            }
            
        }
       
    }
    
    
    private func setUpAVCapture() throws {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480
        try setCaptureSessionInput()
        try setCaptureSessionOutput()
        
        captureSession.commitConfiguration()
    }
    
  
   private func setCaptureSessionInput() throws
   {
    guard let captureDevice = AVCaptureDevice.default(
        .builtInWideAngleCamera,
        for: AVMediaType.video,
        position: cameraPosition ) else { throw VideoCaptureError.invalidInput }
    
        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }
        
    guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else { throw VideoCaptureError.invalidInput}
    guard captureSession.canAddInput(videoInput) else {throw VideoCaptureError.invalidInput}
    captureSession.addInput(videoInput)
    
    
   }
    
    private func setCaptureSessionOutput() throws
    {
        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }
        
        // set the pixel type
        let settings : [String: Any] = [
            String(kCVPixelBufferPixelFormatTypeKey) : kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        videoOutput.videoSettings = settings
        
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        guard captureSession.canAddOutput(videoOutput) else {throw VideoCaptureError.invalidOutput}
        captureSession.addOutput(videoOutput)
        
        if let connection = videoOutput.connection(with: .video),
            connection.isVideoOrientationSupported
        {
            connection.videoOrientation = AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation)
            connection.isVideoMirrored = cameraPosition == .front
            if connection.videoOrientation == .landscapeLeft {
                connection.videoOrientation = .landscapeRight
            }
            else if connection.videoOrientation == .landscapeRight {
                connection.videoOrientation = .landscapeLeft
            }
        }
        
        
    }
    
    public func startCapturing(completion completionHandler:(() -> Void)? = nil) {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
            
            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
    
    
    public func stopCapturing(completion completionHandler:(() -> Void)? = nil) {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
            
            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
            
            
        }
        
    }
    
}

extension VideoCapture : AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection)
    {
        
        guard let delegate = delegate else {return}
        if let pixelBuffer = sampleBuffer.imageBuffer {
            
            guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {return}
            var image : CGImage?
            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
            
            DispatchQueue.main.async {
                delegate.videoCapture(self, didCaptureFrame: image)
            }
            
            
        }
        
        
    }
    
    
    
}
