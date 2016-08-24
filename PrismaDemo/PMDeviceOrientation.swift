//
//  PMDeviceOrientation.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/16.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
class PMDeviceOrientation: NSObject {
	var motionManager:CMMotionManager = CMMotionManager()
	
	override init() {
		super.init()
		setupMotionManager()
	}
	
	func orientation() -> UIDeviceOrientation {
		return actualDeviceOrientationFromAccelerometer()
	}
	
	func deviceOrientationMatchesInterfaceOrientation()->Bool {
		return orientation() == UIDevice.currentDevice().orientation
	}
	
	//将画面方向改为设备方向
	class func avOrientationFromDeviceOrientaion(deviceOrientation: UIDeviceOrientation)->AVCaptureVideoOrientation{
		var result = AVCaptureVideoOrientation.Portrait
		//设备方向和画面方向相反
		if deviceOrientation == UIDeviceOrientation.LandscapeLeft {
			result = .LandscapeRight
		}else if deviceOrientation == UIDeviceOrientation.LandscapeRight {
			result = .LandscapeLeft
		}else if deviceOrientation == UIDeviceOrientation.PortraitUpsideDown {
			result = .PortraitUpsideDown
		}
		return result
	}
	
	//启动设备运动通知
	private func setupMotionManager(){
		UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
		motionManager.accelerometerUpdateInterval = 0.005//加速计
		motionManager.startAccelerometerUpdates()
	}
	
	private func actualDeviceOrientationFromAccelerometer()->UIDeviceOrientation{
		let acceleration = motionManager.accelerometerData!.acceleration
		if acceleration.z < -0.75 {
			return .FaceUp
		}
		
		if acceleration.z > 0.75 {
			return .FaceDown
		}
		
		let scaling = 1.0 / (fabs(acceleration.x) + fabs(acceleration.y))
		let x = acceleration.x * scaling
		let y = acceleration.y * scaling
		
		if x < -0.5 {
			return .LandscapeLeft
		}
		
		if x > 0.5 {
			return .LandscapeRight
		}
		
		if y > 0.5 {
			return .PortraitUpsideDown //倒立
		}
		return .Portrait
	}
	
	deinit{
		teardownMotionManager()
	}
	//拆除
	private func teardownMotionManager() {
		UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
		motionManager.stopAccelerometerUpdates()
	}
}
