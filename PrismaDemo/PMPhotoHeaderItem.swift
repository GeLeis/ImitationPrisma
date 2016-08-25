//
//  PMPhotoHeaderItem.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/11.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit

class PMPhotoHeaderItem: UIScrollView,UIScrollViewDelegate {

	var imageContarinerView = UIView.init();
	var imageView = UIImageView.init()
	var seledctRect = CGRectZero
	var targetZoomScale:CGFloat = 1.0//如果不指明类型，那么默认时double
	
	override var frame: CGRect{
		didSet{
			bounds.origin = CGPointZero
			imageContarinerView.frame = bounds
			imageView.frame = imageContarinerView.bounds;
			resetSubViews()
		}
	}
	
	//相当于block回调
	var scrollViewDidZoom:((scrollView:UIScrollView)->Void)?
	var scrollViewBeganDragging:((scrollView:UIScrollView)->Void)?
	var scrollViewEndDragging:((scrollView:UIScrollView)->Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configSubViews()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init (coder:) has not been")
	}
	
	
	
	func configSubViews (){
		delegate = self;
		bouncesZoom =  true
		maximumZoomScale = 3
		multipleTouchEnabled = true
		bounces = true
		alwaysBounceVertical = true
		alwaysBounceHorizontal = true
		showsVerticalScrollIndicator = false
		showsHorizontalScrollIndicator = false
		
		imageContarinerView.frame = bounds
		imageContarinerView.clipsToBounds = true
		imageContarinerView.backgroundColor = UIColor.whiteColor()
		imageView.clipsToBounds = true
		imageContarinerView.addSubview(imageView)
		addSubview(imageContarinerView)
		
		
		let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(self.doubleTap(_:)))
		doubleTap.numberOfTapsRequired = 2
		addGestureRecognizer(doubleTap)
		
	}
	func setImage(image: UIImage, scrollToRect: CGRect, zoomScale: CGFloat) {
		imageView.image = image
		seledctRect = scrollToRect
		targetZoomScale = zoomScale
		// Reset contentSize
		resetSubViews()
	}
	
	
 	@objc private func doubleTap(tap:UITapGestureRecognizer){
		zoomOutView(tap)
	}
	
	private func zoomOutView(tap:UITapGestureRecognizer){
		guard zoomScale > 1 else{
			return
		}
		zoomScale = 1
		resetSubViews()
	}
	private func resetSubViews(){
		if let image = imageView.image {
			let ratio = image.size.width / image.size.height
			let const = bounds.size.width / bounds.size.height
			
			if ratio > const {
				contentSize = CGSizeMake(ratio * bounds.size.height, bounds.size.height)
			}else{
				contentSize = CGSizeMake(bounds.size.width, bounds.size.width / ratio)
			}
			var frame = imageContarinerView.frame
			frame.size = contentSize
			imageContarinerView.frame = frame
			imageView.frame = imageContarinerView.bounds
			
			var fitRect = CGRectMake((contentSize.width - bounds.size.width)/2, (contentSize.height - bounds.size.height)/2 , bounds.size.width, bounds.size.height)
			
			
			if !CGRectEqualToRect(seledctRect, CGRectZero) {
				fitRect = seledctRect
			}
			
			if targetZoomScale != 1 {
				let contentS = CGSizeApplyAffineTransform(self.contentSize, CGAffineTransformMakeScale(targetZoomScale,targetZoomScale))
				
				fitRect.origin.x = fitRect.origin.x * (contentS.width / image.size.width)
				fitRect.origin.y = fitRect.origin.y * (contentS.height / image.size.height)
				
				fitRect = CGRectApplyAffineTransform(fitRect, CGAffineTransformMakeScale(1.0/targetZoomScale, 1.0/targetZoomScale))
				zoomToRect(fitRect, animated: false)
			}else{
				scrollRectToVisible(fitRect, animated: false)
			}
		}
	}
	
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return imageContarinerView
	}
	
	func scrollViewDidZoom(scrollView: UIScrollView) {
		let subView = imageContarinerView
		
		var offsetX = CGFloat(0)
		if scrollView.bounds.size.width > scrollView.contentSize.width {
			offsetX = (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5
		}
		
		var offsetY = CGFloat(0)
		if scrollView.bounds.size.height > scrollView.contentSize.height {
			offsetY = (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5
		}
		
		subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY)
		if let action = scrollViewDidZoom {
			action(scrollView: scrollView)
		}
	}
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		if let drag = scrollViewBeganDragging {
			drag(scrollView: scrollView)
		}
	}
	
}
