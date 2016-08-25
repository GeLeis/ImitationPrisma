//
//  PMImageEditController.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/17.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import SnapKit

class PMImageEditController: UIViewController {
	
	var navigatioBar: UINavigationBar!
	let screenSize = ScreenSize()
    override func viewDidLoad() {
        super.viewDidLoad()
		
		initNavigationBar()
		initMainView()
    }
	
	func initNavigationBar(){
		navigatioBar = UINavigationBar.init(frame: CGRectMake(0, 20, screenSize.width, 44));
		
		self.navigationController?.navigationBar.hidden = true
		view.addSubview(navigatioBar);
		
		navigatioBar.setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor(), size: CGSizeMake(ScreenSize().width, 44)), forBarPosition: UIBarPosition.Top, barMetrics: UIBarMetrics.Default)
		navigatioBar.shadowImage = UIImage.init()
		
		let backBtn = UIButton.init(type: .Custom)
		backBtn.setBackgroundImage(UIImage.init(named: "cross"), forState: .Normal)
		backBtn.setBackgroundImage(UIImage.init(named: "cross")?.imageWithColor(UIColor.lightGrayColor()), forState: .Highlighted)
		backBtn.addTarget(self, action: #selector(self.back(_:)), forControlEvents: .TouchUpInside)
		navigatioBar.addSubview(backBtn)
		weak var weakSelf = self
		backBtn.snp.makeConstraints { (make) in
			make.left.equalTo(weakSelf!.navigatioBar.snp.left).offset(15)
			make.centerY.equalTo(weakSelf!.navigatioBar.snp.centerY)
		}
		
		let titleLabel = UILabel.init()
		titleLabel.text = "Crop Photo"
		titleLabel.font = UIFont.systemFontOfSize(16);
		navigatioBar.addSubview(titleLabel)
		titleLabel.snp.makeConstraints { (make) in
			make.centerX.equalTo(weakSelf!.navigatioBar.snp.centerX)
			make.centerY.equalTo(weakSelf!.navigatioBar.snp.centerY)
		}
		
		let nextBtn = UIButton.init(type: .Custom)
		nextBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
		if #available(iOS 8.2, *) {
			nextBtn.titleLabel?.font = UIFont.systemFontOfSize(15, weight: 2)
		} else {
			nextBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
		}
		nextBtn.setTitle("Next", forState: .Normal)
		nextBtn.addTarget(self, action: #selector(self.next(_:)), forControlEvents: .TouchUpInside)
		navigatioBar.addSubview(nextBtn)
		nextBtn.snp.makeConstraints { (make) in
			make.centerY.equalTo(weakSelf!.navigatioBar.snp.centerY)
			make.right.equalTo(weakSelf!.navigatioBar.snp.right).offset(-15)
		}
		
		
	}
	
	
	func initMainView() {
		let rotateLabel = UILabel.init()
		rotateLabel.font = UIFont.systemFontOfSize(15)
		rotateLabel.text = "Rotate 90°"
		rotateLabel.textColor = UIColor.blackColor()
		view.addSubview(rotateLabel)
		weak var weakSelf = self
		rotateLabel.snp.makeConstraints { (make) in
			make.centerX.equalTo(weakSelf!.view.snp.centerX)
			make.centerY.equalTo(weakSelf!.navigatioBar.snp.bottom).offset((screenSize.height - screenSize.width - 44 - 20) * 0.5)
		}
		
		let rotateRightBtn = UIButton.init(type: .Custom)
		rotateRightBtn.setBackgroundImage(UIImage.init(named: "rotate-right"), forState: .Normal)
		rotateRightBtn.setBackgroundImage(UIImage.init(named: "rotate-right")?.imageWithColor(UIColor.lightGrayColor()), forState: .Highlighted)
		rotateRightBtn.addTarget(self, action: #selector(self.rotateRight(_:)), forControlEvents: .TouchUpInside)
		view.addSubview(rotateRightBtn)
		weak var weakRotateLabel = rotateLabel
		rotateRightBtn.snp.makeConstraints { (make) in
			make.centerY.equalTo(weakRotateLabel!.snp.centerY)
			make.right.equalTo(weakRotateLabel!.snp.left).offset(-15)
		}
		
		
		let rotateLeftBtn = UIButton.init(type: .Custom)
		rotateLeftBtn.setBackgroundImage(UIImage.init(named: "rotate-left"), forState: .Normal)
		rotateLeftBtn.setBackgroundImage(UIImage.init(named: "rotate-left")?.imageWithColor(UIColor.lightGrayColor()), forState: .Highlighted)
		rotateLeftBtn.addTarget(self, action: #selector(self.rotateLeft(_:)), forControlEvents: .TouchUpInside)
		view.addSubview(rotateLeftBtn)
		rotateLeftBtn.snp.makeConstraints { (make) in
			make.centerY.equalTo(weakRotateLabel!.snp.centerY)
			make.left.equalTo(weakRotateLabel!.snp.right).offset(15)
		}
	}
	
	func rotateRight(sender: AnyObject) {
		photoPisplayBoard?.rotateDisplayImage(true)
	}
	
	func rotateLeft(sender:AnyObject) {
		photoPisplayBoard?.rotateDisplayImage(false)
	}
	
	func back(sender: AnyObject) {
		let navigationController = self.navigationController as? PMNavigationController
		navigationController?.popViewControllerAnimated(true, completion: { (isPush: Bool) in
			if !isPush {
				self.photoPisplayBoard?.setState(PMImageDisplayState.Preview, image: nil, selectedRect: CGRectZero, zoomScale: 1, animated: true)
			}
		})
	}
	
	func next(sender: AnyObject) {
		let finalImage = photoPisplayBoard?.croppedImage()
		photoPisplayBoard?.setState(.SingleShow, image: finalImage, selectedRect: CGRectZero, zoomScale: 1, animated: false)
		
		let styleVC = PMImageProcessController.init()
		navigationController?.pushViewController(styleVC, animated: true)
	}
	
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		if navigationController == nil {
			self.photoPisplayBoard?.setState(PMImageDisplayState.Preview, image: nil, selectedRect: CGRectZero, zoomScale: 1, animated: true)
		}
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
