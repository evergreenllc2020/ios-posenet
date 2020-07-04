//
//  PopupPresentationManager.swift
//  posenet
//
//  Created by Evergreen Technologies on 7/2/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import UIKit

class PopOverPresentationManager: NSObject, UIViewControllerTransitioningDelegate {

    var presentingViewController : UIViewController
    var presentedViewController : UIViewController
    
    
    init(presenting presentingViewController: UIViewController, presented presentedViewController : UIViewController)
    {
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopoverPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
    
    
    

   

}


class PopoverPresentationController : UIPresentationController
{
    private let popOverHeightRatio : CGFloat = 0.9
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        let viewHeight = containerView!.bounds.height * popOverHeightRatio
        let origin = CGPoint(x: 0 , y: containerView!.bounds.height - viewHeight)
        let size = CGSize(width: containerView!.bounds.width, height: viewHeight)
        
        return CGRect(origin: origin, size:size)
                
        
    }
    
    
    
}
