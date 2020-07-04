//
//  ViewController.swift
//  posenet
//
//  Created by Evergreen Technologies on 6/26/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var previewImageView: PoseImageView!
    
    private let videoCapture = VideoCapture()
    private var poseNet : PoseNet!
    private var currentFrame: CGImage?
    
    private var algorithm: Algorithm = .multiple
    
    private var poseBuilderConfiguration = PoseBuilderConfiguration()
    
    private var popOverPresentationManager : PopOverPresentationManager?
    
    
    
    
    @IBAction func cameraFlipped(_ sender: UIButton) {
        
        videoCapture.flipCamera {error in
            if let error = error
            {
                print("Failed to set up camera with error \(error)")
                return
            }
            
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UIApplication.shared.isIdleTimerDisabled = true
        
        do
        {
            poseNet = try PoseNet()
        }
        catch{
            fatalError("Failed to load model. \(error.localizedDescription)")
        }
        
        poseNet.delegate = self
        setupBeginCapturingVideoFrames()
        
    }
    
    private func setupBeginCapturingVideoFrames()
    {
        videoCapture.setUpAVCapture { error in
            if let error = error
            {
                print("Fauiled to set up camera with error \(error)")
                return
            }
            
            self.videoCapture.delegate = self
            self.videoCapture.startCapturing()
            
            
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setupBeginCapturingVideoFrames()
    }
    

}

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let uiNavigationController = segue.destination as? UINavigationController else {return}
        
        guard let configurationViewController = uiNavigationController.viewControllers.first as? ConfigurationViewController else { return }
        
        configurationViewController.configuration = poseBuilderConfiguration
        configurationViewController.algorithm = algorithm
        configurationViewController.delegate = self
        
        popOverPresentationManager = PopOverPresentationManager(presenting: self, presented : uiNavigationController)
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = popOverPresentationManager
        
        
    }
    
    
}

extension ViewController: ConfigurationViewControllerDelegate
{
    func configurationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateAlgorithm algorithm: Algorithm)
    {
        self.algorithm = algorithm
    }
    
    func configutationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateConfiguration configuration: PoseBuilderConfiguration) {
        poseBuilderConfiguration = configuration
    }
}


extension ViewController : VideoCaptureDelegate {
    func videoCapture(_ VideoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {return}
        guard let image = capturedImage else {fatalError ("captured image is null")}
        
        currentFrame = image
        poseNet.predict(image)
        
    }
    
    
}


extension ViewController: PoseNetDelegate {
    
    func posnet(_ posenet: PoseNet, didPredict predictions: PoseNetOutput) {
        
        defer {
            self.currentFrame = nil
        }
        
        guard let currentFrame = currentFrame else {return}
        
        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)
        
        let poses = algorithm == .single ?[poseBuilder.pose] : poseBuilder.poses
        
        previewImageView.show(poses: poses, on:currentFrame)
        
    }
    
    
}





