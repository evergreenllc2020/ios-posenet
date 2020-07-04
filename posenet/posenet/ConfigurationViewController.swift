//
//  ConfigurationViewController.swift
//  posenet
//
//  Created by Evergreen Technologies on 7/1/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import UIKit

protocol ConfigurationViewControllerDelegate : AnyObject {
    
    func configutationViewController(_ viewController: ConfigurationViewController, didUpdateConfiguration configuration : PoseBuilderConfiguration)
    
    func configurationViewController(_ viewController: ConfigurationViewController, didUpdateAlgorithm algorithm : Algorithm)
    
    
    
    
}





class ConfigurationViewController: UIViewController {

    
    @IBOutlet weak var algorithmSegmentedControl: UISegmentedControl!
    
    
    
    @IBOutlet weak var jointConfidenceThresholdLabel: UILabel!
    @IBOutlet weak var jointConfidenceThresholdSlider: UISlider!
    
    
    @IBOutlet weak var poseConfidenceThresholdLabel: UILabel!
    @IBOutlet weak var poseConfidenceThresholdSlider: UISlider!
    
    @IBOutlet weak var localJointSearchReadiusLabel: UILabel!
    @IBOutlet weak var localJointSearchRadiusSlider: UISlider!
    
    
    @IBOutlet weak var matchingJointMinimumDistanceLabel: UILabel!
    @IBOutlet weak var matchingJointMinimumDistanceSlider: UISlider!
    
    
    @IBOutlet weak var adjecentJointOffsetRefinementStepsLabel: UILabel!
    @IBOutlet weak var adjecentJointOffsetRefinementStepsSlider: UISlider!
    
    
    let jointConfidenceThresholdText = "Joint Confidence threshold"
    let poseConfidenceThresholdText = "Pose Confidence threshold"
    let localJointSearchRadiusText = "Local Joint Search radius"
    let matchingJointMinimumDistanceText = "Matching Joint Minimum Distance"
    let adjecentJointOffsetRefinementStepsText = "Adjecent Joint Offset Refinement Steps"
    
    
    
    weak var delegate: ConfigurationViewControllerDelegate?
    
    var configuration: PoseBuilderConfiguration! {
        didSet{
            delegate?.configutationViewController(self, didUpdateConfiguration: configuration)
            updateUILabels()
        }
    }
    
    
    var algorithm : Algorithm = .multiple {
        didSet
        {
            delegate?.configurationViewController(self, didUpdateAlgorithm: algorithm)
        }
    }
    
    @IBAction func algorithmValueChanged(_ sender: Any) {
        algorithm = algorithmSegmentedControl.selectedSegmentIndex == 0 ? .single : .multiple
       
    }
    
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func jointConfidenceThresholdValueChanged(_ sender: Any) {
        configuration.jointConfidenceThreshold = Double(jointConfidenceThresholdSlider.value)
        
    }
    
    
    @IBAction func poseConfidenceThresholdValueChanged(_ sender: Any) {
        
        configuration.poseConfidenceThreshold = Double(poseConfidenceThresholdSlider.value)
        
    }
    
    
    @IBAction func localJointSearchRadiusValueChanged(_ sender: Any) {
        configuration.localSearchRadius = Int(localJointSearchRadiusSlider.value)
        
    }
    
    
    @IBAction func matchingJointMinimumDistanceValueChanged(_ sender: Any) {
        configuration.matchingJointDistance = Double(matchingJointMinimumDistanceSlider.value)
    }
    
    
    @IBAction func offsetRefineStepsValueChanged(_ sender: Any) {
        configuration.adjecentJointOffsetRefinementSteps = Int(adjecentJointOffsetRefinementStepsSlider.value)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        algorithmSegmentedControl.selectedSegmentIndex = self.algorithm == Algorithm.single ? 0 : 1
        jointConfidenceThresholdSlider.value = Float(configuration.jointConfidenceThreshold)
        poseConfidenceThresholdSlider.value = Float(configuration.poseConfidenceThreshold)
        localJointSearchRadiusSlider.value = Float(configuration.localSearchRadius)
        matchingJointMinimumDistanceSlider.value = Float(configuration.matchingJointDistance)
        adjecentJointOffsetRefinementStepsSlider.value = Float(configuration.adjecentJointOffsetRefinementSteps)
        updateUILabels()
        

        // Do any additional setup after loading the view.
    }
    
    func updateUILabels()
    {
        guard jointConfidenceThresholdLabel != nil else {return}
        jointConfidenceThresholdLabel.text = jointConfidenceThresholdText
        jointConfidenceThresholdLabel.text! += String(format: "(%.1f)", configuration.jointConfidenceThreshold)
        
        poseConfidenceThresholdLabel.text = poseConfidenceThresholdText
        poseConfidenceThresholdLabel.text! += String(format: "(%.1f)", configuration.poseConfidenceThreshold)
        
        
        matchingJointMinimumDistanceLabel.text = matchingJointMinimumDistanceText
        matchingJointMinimumDistanceLabel.text! += String(format: "(%.1f)", configuration.matchingJointDistance)
        
        
        localJointSearchReadiusLabel.text = localJointSearchRadiusText
        localJointSearchReadiusLabel.text! += String(format: "(%.1f)", configuration.localSearchRadius)
        
        
        adjecentJointOffsetRefinementStepsLabel.text = adjecentJointOffsetRefinementStepsText
        adjecentJointOffsetRefinementStepsLabel.text! +=  "(\(Int(configuration.adjecentJointOffsetRefinementSteps)))"
        
        
        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
