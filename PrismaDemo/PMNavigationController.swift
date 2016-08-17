//
//  PMNavigationController.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/12.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit

class PMNavigationController: UINavigationController,UIGestureRecognizerDelegate,UINavigationControllerDelegate {
	
	var panGestureRecognizer = UIPanGestureRecognizer.init()
	var frameOrigin = CGPointZero
	var interactionController : UIPercentDrivenInteractiveTransition?
	var animator:PushAnimator?
	var isInteractive:Bool = false
	var popEdgeInset:CGFloat = 50
	var completionHandler:((isPush:Bool)->Void)?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	override init(rootViewController: UIViewController) {
		super.init(rootViewController: rootViewController)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		//禁用系统的pop手势，然后自定义
        interactivePopGestureRecognizer?.enabled = false
		delegate = self;
		
		panGestureRecognizer.addTarget(self, action: #selector(self.didPan(_:)))
		view.addGestureRecognizer(panGestureRecognizer)
    }
	
	override func viewDidLayoutSubviews() {
		var frame = view.frame
		frame.origin.y = frameOrigin.y
		frame.size.height = UIScreen.mainScreen().bounds.size.height - frame.origin.y
		view.frame = frame
	}
	
	override func pushViewController(viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)
		if !animated {
			if let completion = completionHandler {
				completion(isPush: true)
			}
		}
	}
	
	override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
		if !animated {
			if let completion = completionHandler {
				completion(isPush: false)
			}
		}
		return super.popViewControllerAnimated(animated)
	}
	
	func pushViewController(viewController:UIViewController, animated:Bool, completion:((isPush: Bool)->Void)?){
		completionHandler = completion
		self.pushViewController(viewController, animated: animated)
	}
	
	func popViewControllerAnimated(animated: Bool, completeion:((isPush: Bool)->Void)?){
		completionHandler = completeion
		self.popViewControllerAnimated(animated)
	}
	
	func navigationContlroller(navigationController: UINavigationController, animationControllerForOperation operation:UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC:UIViewController)->UIViewControllerAnimatedTransitioning?{
		if animator == nil {
			animator = PushAnimator.init(isPush: operation == UINavigationControllerOperation.Push
			)
		}
		animator?.isInteractive = isInteractive
		animator?.push = operation == UINavigationControllerOperation.Push
		return animator
	}
	
	func navigationController(navigationController: UINavigationController,interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return interactionController
	}
	
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  	@objc func didPan(panGesture:UIPanGestureRecognizer) {
		if panGesture.state == .Began {
			isInteractive = true
			animator?.isInteractive = true
			interactionController = UIPercentDrivenInteractiveTransition()
			popViewControllerAnimated(true)
		}else if panGesture.state == .Changed{
			let translation = panGesture.translationInView(view)
			let percent = translation.x / CGRectGetWidth(view.bounds)
			interactionController?.updateInteractiveTransition(percent)
			
		}else if panGesture.state == .Ended{
			if panGesture.velocityInView(view).x > 100 {
				interactionController?.finishInteractiveTransition()
			}else{
				interactionController?.cancelInteractiveTransition()
			}
			
			interactionController = nil
			animator?.isInteractive = false
		}
	}
	
	func gestureRecognizerShouldBegin(gestureRecognizer:UIGestureRecognizer)->Bool{
		let location = gestureRecognizer.locationInView(view)
		if location.y < 64 || location.x > popEdgeInset {
			return false
		}
		return true
	}

}
