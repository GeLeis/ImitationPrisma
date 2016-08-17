//
//  PMCaptureButton.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/12.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit

let touchUpDuration = 0.4

class PMTarget: NSObject {
	var target: AnyObject?
	var action: Selector?
	var touchAction: Selector = #selector(PMTarget.touch(_:))
	
	override init() {
		super.init()
	}
	
	
	
	convenience init(target: AnyObject, action: Selector) {
		self.init()
		self.target = target
		self.action = action
	}
	
	func touch(sender: UIButton){
		let time = dispatch_time(DISPATCH_TIME_NOW, Int64(touchUpDuration * Double(NSEC_PER_SEC)));
		dispatch_after(time, dispatch_get_main_queue()) {
			if let target = self.target as? NSObject {
				target.performSelector(self.action!,withObject: sender)
			}
			
		}
	}
}

class PMCaptureButton: UIButton {
	var lineWidth:CGFloat = 1
	var lineColor = UIColor.RGBColor(78, green: 78, blue: 78)
	var fillColor = UIColor.RGBColor(245, green: 245, blue: 245)
//	var fillColor = UIColor ( red: 0.9608, green: 0.9608, blue: 0.9608, alpha: 1.0 )
	var enabledColor = UIColor.init(white: 0.98, alpha: 0.75)
	let content = PMCaptureButtonContent.init()
	var shouldLayout = true
	var targets : [AnyObject] = [AnyObject]()
	
	
	override var enabled: Bool{
		didSet {
			content.enabled = enabled
		}
	}
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = UIColor.clearColor()
		configViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		backgroundColor = UIColor.clearColor()
		configViews()
	}
	
	
	func configViews() {
		content.backgroundColor = UIColor.clearColor()
		content.frame = bounds;
		content.lineColor = lineColor
		content.lineWidth = lineWidth
		content.fillColro = fillColor
		content.enableColor = enabledColor
		content.userInteractionEnabled = false
		addSubview(content)
		
		addTarget(self, action: #selector(self.touchDown), forControlEvents: .TouchDown)
		super.addTarget(self, action: #selector(self.touchUpInside), forControlEvents: .TouchUpInside)
		addTarget(self, action: #selector(self.touchDragExit), forControlEvents: .TouchDragExit)
		addTarget(self, action: #selector(self.touchDragEnter), forControlEvents: .TouchDragEnter)
		
		
	}
	
	
	override func addTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents) {
		if controlEvents == .TouchUpInside {
			if let tar = target {
				let pmTarget = PMTarget.init(target: tar, action: action)
				//相当于让pmtarget缓冲0.4s后去执行touch
				super.addTarget(pmTarget, action: #selector(pmTarget.touch(_:)), forControlEvents: controlEvents)
				targets.append(pmTarget)
			}
		}else{
			super.addTarget(target, action: action, forControlEvents: controlEvents)
		}
	}
	
	
	
	override func layoutSubviews() {
		guard shouldLayout else{
			return
		}
		content.frame = bounds
	}
	
	func touchDown() {
		setSelectedState(true)
	}
	
	func touchUpInside() {
		setSelectedState(false)
	}
	
	func touchDragExit() {
		setSelectedState(false)
	}
	
	func touchDragEnter() {
		setSelectedState(false)
	}
	
	func setSelectedState(selected:Bool){
		if selected {
			shouldLayout = false
			UIView.animateWithDuration(0.05, delay: 0, options: .CurveLinear, animations: { 
				self.content.transform = CGAffineTransformMakeScale(0.86, 0.86)
				}, completion: { (com:Bool) in
					self.shouldLayout = true
			})
		}else {
			shouldLayout = false
			UIView.animateWithDuration(touchUpDuration, delay: 0, options: .CurveEaseInOut, animations: { 
				self.content.transform = CGAffineTransformIdentity
				}, completion: { (com:Bool) in
					self.shouldLayout = true
			})
		}
	}
}


class PMCaptureButtonContent:UIView{
	var lineWidth: CGFloat = 1
	var lineColor = UIColor.blackColor()
	var fillColro = UIColor.grayColor()
	var enableColor = UIColor.lightGrayColor()
	let screenScale:CGFloat = UIScreen.mainScreen().scale
	var centerOffset:CGFloat = (1.0/UIScreen.mainScreen().scale)/2
	private var _enabled:Bool = true
	var enabled:Bool {
		set {
			_enabled = newValue
			setNeedsDisplay()
		}
		get {
			return _enabled
		}
	}
	
	override func drawRect(rect: CGRect) {
		let edgeInset:CGFloat = 2
		let centerX = CGfloatPixelRound(bounds.size.width/2)
		let centerY = CGfloatPixelRound(bounds.size.height/2)
		let radius = CGfloatPixelRound(bounds.size.width/2 - 2 * edgeInset)
		if lineWidth * screenScale / 2 == 0 {
			centerOffset = 0
		}
		
		let context = UIGraphicsGetCurrentContext()
		CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
		CGContextSetLineWidth(context, lineWidth)
		CGContextSetFillColorWithColor(context, fillColro.CGColor)
		CGContextAddArc(context, centerX + centerOffset, centerY + centerOffset, radius, 0, CGFloat(M_PI) * 2, 0)
		CGContextDrawPath(context, .FillStroke)
		
		if enabled == false {
			CGContextSaveGState(context)
			CGContextSetFillColorWithColor(context, enableColor.CGColor)
			CGContextAddArc(context, centerX + centerOffset, centerY + centerOffset, radius + lineWidth, 0, CGFloat(M_PI) * 2, 0)
			CGContextDrawPath(context, CGPathDrawingMode.Fill)
		}
		
	}
	//四舍五入
	func CGfloatPixelRound(value:CGFloat) -> CGFloat{
		let scale = screenScale
		return round(value * scale) / scale;
	}
}