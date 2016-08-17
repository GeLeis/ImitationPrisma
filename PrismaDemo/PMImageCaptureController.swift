//
//  PMImageCaptureController.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/12.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos
import CoreImage
import RxSwift
import RxCocoa

let kPushDuration = 0.32

struct ScreenSize {
	let width: CGFloat = UIScreen.mainScreen().bounds.size.width
	let height: CGFloat = UIScreen.mainScreen().bounds.size.height
}

class PMImageCaptureController: UIViewController{
	var captureButton: PMCaptureButton!
	var navigationBar: UINavigationBar!
	var flashBarItem: UIBarButtonItem!
	var selectPhotoButton: UIButton!
	
	var session:AVCaptureSession! = AVCaptureSession()
	var deviceIntput: AVCaptureDeviceInput?
	var stillImageOutPut: AVCaptureStillImageOutput?
	var previewLayer:AVCaptureVideoPreviewLayer?
	var photoGroups = [PHAssetCollection]()
	var photoAssets = [PHAsset]()
	var isUsingFrontFacingCamera: Bool = false
	var currentFlashMode: AVCaptureFlashMode = .Off
	let screenSize = ScreenSize()
	let orientationManger:PMDeviceOrientation = PMDeviceOrientation()
	
	var disposeBag = DisposeBag()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		selectPhotoButton = UIButton.init()
		view.addSubview(selectPhotoButton)
		
		selectPhotoButton.rx_tap.subscribeNext { [weak self]  in
		 	self!.selectPhoto(self!.selectPhotoButton)
		}.addDisposableTo(disposeBag)
		
		selectPhotoButton.snp.makeConstraints { (make) in
			make.bottom.equalTo(view).offset(-20)
			make.right.equalTo(view);
			make.width.height.equalTo(64)
		}
		//拍照按钮
		captureButton = PMCaptureButton.init(frame: CGRectMake(0, 0, 75, 75))
		view.addSubview(captureButton)
		
		captureButton.rx_tap.subscribeNext { [weak self]  in
			self!.capturePhoto(self!.captureButton)
			}.addDisposableTo(disposeBag)
		
//		captureButton.rx_tap.subscribeNext { [weak self] in
//			self!.capturePhoto(self!.captureButton)
//		}.addDisposableTo(disposeBag)
	
		
		
		captureButton.snp.makeConstraints { (make) in
			make.centerX.equalTo(view)
			make.centerY.equalTo(view)
			make.width.height.equalTo(75)
		}
		
		navigationBar = UINavigationBar.init()
		view.addSubview(navigationBar)
		navigationBar.snp.makeConstraints { (make) in
			make.height.equalTo(44)
			make.top.trailing.leading.equalTo(view)
		}
		
		
		initNavigationBar()
		
		
		PMImageManager.captureAuthorization { (canCapture:Bool) in
			if canCapture {
				self.initAVCapture()
				self.session.startRunning()
			}else {
				self.session.stopRunning()
			}
		}
		
		PMImageManager.photoAuthorization { (canAssets:Bool) in
			if canAssets {
				self.photoGroups = PMImageManager.photoLibrarys()
				self.photoAssets = PMImageManager.photoAssetsForAlbum(self.photoGroups.first!)
				PMImageManager.imageFromAsset(self.photoAssets.first!, isOriginal: false, toSize: CGSizeMake(150, 150), resultHandler: { (image:UIImage?) in
					self.selectPhotoButton.setBackgroundImage(image, forState: .Normal)
				})
			}
		}
		
		photoPisplayBoard?.singleTapHeaderAction = {(tap: UITapGestureRecognizer) in
			self.tapToChangeFocus(tap)
		}
		
		
    }
	
	func initNavigationBar() {
		//取出黑线
		navigationBar.setBackgroundImage(UIImage.init(), forBarMetrics: .Default)
		navigationBar.shadowImage = UIImage.init()
		let navigationItem = navigationBar.topItem
		
		
		//flashButton
		let leftButton  = UIButton.init(type: .System)
		leftButton.frame = CGRectMake(-10, 0, 44, 44);
		leftButton.setImage(UIImage.init(named: "flash"), forState: .Normal)
		leftButton.addTarget(self, action: #selector(self.changeFlash(_:)), forControlEvents: .TouchUpInside)
		let leftBarItem = UIBarButtonItem.init(customView: leftButton)
		leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10)
		navigationItem?.leftBarButtonItem = leftBarItem
		
		//camera possion 前后摄像头
		let image = UIImage.init(named: "flip")
		let hImage = image?.imageWithColor(UIColor.grayColor())
		let titleButton = UIButton.init(type: .Custom)
		titleButton.setImage(image, forState: .Normal)
		titleButton.setImage(hImage, forState: .Selected)
		titleButton.setImage(hImage, forState: .Highlighted)
		titleButton.sizeToFit()
		titleButton.addTarget(self, action: #selector(self.changeCameraPossion), forControlEvents: .TouchUpInside)
		navigationItem?.titleView = titleButton
		
	}
	
	func initAVCapture(){
		let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
		try! device.lockForConfiguration()
		if device.hasFlash {
			device.flashMode = AVCaptureFlashMode.Off
		}
		
		if device.isFocusModeSupported(.AutoFocus) {
			device.focusMode = .AutoFocus
		}
		
		if device.isWhiteBalanceModeSupported(.AutoWhiteBalance) {
			device.whiteBalanceMode = .AutoWhiteBalance
		}
		
		if device.exposurePointOfInterestSupported {
			device.exposureMode = .ContinuousAutoExposure
		}
		device.unlockForConfiguration()
		
		deviceIntput = try! AVCaptureDeviceInput(device: device)
		stillImageOutPut = AVCaptureStillImageOutput()  //
		stillImageOutPut?.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG,AVVideoScalingModeKey:AVVideoScalingModeResize]
		
		if session.canAddInput(deviceIntput) {
			session.addInput(deviceIntput)
		}
		
		if session.canAddOutput(stillImageOutPut) {
			session.addOutput(stillImageOutPut)
		}
		//会话预置模式
		session.sessionPreset = AVCaptureSessionPresetPhoto
		
		previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
		
		//???
		previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
		
		photoPisplayBoard?.setAVCapturepreviewLayer(previewLayer!)
		
	}
	
	func changeFlash(sender: AnyObject?){
		var image: UIImage? = nil
		let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
		//???
		try! device.lockForConfiguration()
		if device.hasFlash {
			switch device.flashMode {
			case .Off:
				device.flashMode = .On
				currentFlashMode = .On
				image = UIImage.init(named: "flash-on")
				break
			case .On:
				device.flashMode = .Auto
				currentFlashMode = .Auto
				image = UIImage.init(named: "flash-auto")
			case .Auto:
				device.flashMode = .Off
				currentFlashMode = .Off
				image = UIImage.init(named: "flash")
				
			}
			let leftButton = navigationBar.topItem?.leftBarButtonItem?.customView as? UIButton
			leftButton?.setImage(image, forState: .Normal)
		}
		device.unlockForConfiguration()
	}
	
	func changeCameraPossion() {
		var desiredPosition : AVCaptureDevicePosition
		let navigationItem = navigationBar.topItem
		
		if isUsingFrontFacingCamera {
			desiredPosition = .Back
			navigationItem?.leftBarButtonItem?.customView?.userInteractionEnabled = true
			navigationItem?.leftBarButtonItem?.highlighted = false
		}else{
			desiredPosition = AVCaptureDevicePosition.Front
			navigationItem?.leftBarButtonItem?.customView?.userInteractionEnabled = false
			navigationItem?.leftBarButtonItem?.highlighted = true
		}
		
		for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
			let device = device as! AVCaptureDevice
			if device.position == desiredPosition {
				try! device.lockForConfiguration()
				if device.hasFlash {
					device.flashMode = currentFlashMode
				}
				
				if device.isFocusModeSupported(.AutoFocus) {
					device.focusMode = .ContinuousAutoFocus
				}
				
				//白平衡
				if device.isWhiteBalanceModeSupported(.AutoWhiteBalance) {
					device.whiteBalanceMode = .AutoWhiteBalance
				}
				
				//曝光
				if device.exposurePointOfInterestSupported {
					device.exposureMode = .ContinuousAutoExposure
				}
				
				device.unlockForConfiguration()
				
				let input = try! AVCaptureDeviceInput(device: device)
				session.removeInput(deviceIntput)
				session.addInput(input)
				deviceIntput = input
				break;
			}
		}
		isUsingFrontFacingCamera = !isUsingFrontFacingCamera
	}

	func capturePhoto(sender:AnyObject) {
		captureButton.enabled = false
		
		let stillImageConnection = stillImageOutPut?.connectionWithMediaType(AVMediaTypeVideo)
		
		let avCaptureOrientaion = AVCaptureVideoOrientation(rawValue:UIDevice.currentDevice().orientation.rawValue)!
		if stillImageConnection!.supportsVideoOrientation {
			stillImageConnection!.videoOrientation = avCaptureOrientaion
		}
		stillImageConnection!.videoScaleAndCropFactor = 1
		
		stillImageOutPut?.captureStillImageAsynchronouslyFromConnection(stillImageConnection, completionHandler: { (imageDataSampleBuffer: CMSampleBuffer!, error: NSError!) in
			let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
			
			if var image = UIImage(data: jpegData){
				image = image.fixOrientation()
				image = PMImageManager.cropImageAffterCapture(image, toSize: self.previewLayer!.frame.size)
				if !self.orientationManger.deviceOrientationMatchesInterfaceOrientation() {
					let interfaceOrientaion = self.orientationManger.orientation()
					image = image.rotateImageFromInterfaceOrientation(interfaceOrientaion)
				}
				
				if self.isUsingFrontFacingCamera {
					image = UIImage.init(CGImage: image.CGImage!, scale: image.scale, orientation: .UpMirrored)
					let imageV = UIImageView.init(frame: self.previewLayer!.bounds)
					imageV.image = image;
					self.view.addSubview(imageV)
				}
				
				let authorStatus = ALAssetsLibrary.authorizationStatus()
				if (authorStatus == ALAuthorizationStatus.Restricted) || (authorStatus == ALAuthorizationStatus.Denied) {
					return
				}
				
				let library = ALAssetsLibrary()
				if self.isUsingFrontFacingCamera {
					let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate)
					
					library.writeImageToSavedPhotosAlbum(image.CGImage, metadata: attachments as? [NSObject:AnyObject], completionBlock: { (url:NSURL!, error:NSError!) in
						
					})
				}else {
					library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation.UpMirrored, completionBlock: { (url:NSURL!, error:NSError!) in
						
					})
				}
				
				self.photoPisplayBoard?.setState(.SingleShow, image: image, selectedRect: CGRectZero, zoomScale: 1, animated: false)
				let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
				let styleVC = storyBoard.instantiateViewControllerWithIdentifier("styleImageController") as? PMImageProcessController
				styleVC?.fromCapture = true
				self.navigationController?.pushViewController(styleVC!, animated: true)
			}
			self.session.stopRunning()
		})
	}
	
	func tapToChangeFocus(tap:UITapGestureRecognizer){
		guard !isUsingFrontFacingCamera else {
			return
		}
		
		let point = tap.locationInView(photoPisplayBoard?.displayheaderView)
		
		showSquareBox(point)
		
		let pointIncamera = previewLayer!.captureDevicePointOfInterestForPoint(point)
		let device = deviceIntput?.device
		try! device?.lockForConfiguration()
		
		//对焦点
		if device!.focusPointOfInterestSupported {
			device!.focusPointOfInterest = pointIncamera
		}
		
		//连续自动对焦
		if device!.isFocusModeSupported(.ContinuousAutoFocus) {
			device!.focusMode = .ContinuousAutoFocus
		}
		
		//改变曝光电
		if device!.exposurePointOfInterestSupported {
			device!.exposureMode = .ContinuousAutoExposure
			device!.exposurePointOfInterest = pointIncamera
		}
		//允许捕捉
		device?.subjectAreaChangeMonitoringEnabled = true
		
		device?.focusPointOfInterest = pointIncamera
		device?.unlockForConfiguration()
		
	}
	
	func selectPhoto(sender:AnyObject){
		
		let nav = PMImagePickerController.init()
		nav.pmDelegate = self
		nav.photoGroups = photoGroups
		nav.photoAssets = photoAssets
		weak var weakself = self
		self.presentViewController(nav, animated: true) { 
			weakself?.session.stopRunning()
		}
	}
	
	
	
	func showSquareBox(point: CGPoint) {
		guard let header = photoPisplayBoard?.displayheaderView else {
			return
		}
		
		for layer in header.layer.sublayers! {
			if layer.name == "box" {
				layer.removeFromSuperlayer()
			}
		}
		
		let width = CGFloat(60)
		let box = CAShapeLayer.init()
		box.frame = CGRectMake(point.x - width/2, point.y - width/2, width, width)
		box.borderWidth = 1
		box.borderColor = UIColor.whiteColor().CGColor
		box.name = "box"
		header.layer.addSublayer(box)
		
		let alphaAnimation = CABasicAnimation.init(keyPath: "opacity")
		alphaAnimation.fromValue = 1
		alphaAnimation.toValue = 0
		alphaAnimation.duration = 0.01
		alphaAnimation.beginTime = CACurrentMediaTime()
		
		let scaleAnimation = CABasicAnimation.init(keyPath: "transfrom.scale")
		scaleAnimation.fromValue = 1.2
		scaleAnimation.toValue = 1
		scaleAnimation.duration = 0.35
		scaleAnimation.beginTime = CACurrentMediaTime()
		
		box.addAnimation(alphaAnimation, forKey: nil)
		box.addAnimation(scaleAnimation, forKey: nil)
		
		let time = dispatch_time(DISPATCH_TIME_NOW, Int64((0.35 + 0.2) * Double(NSEC_PER_SEC)))
		dispatch_after(time, dispatch_get_main_queue()) { 
			box.removeFromSuperlayer()
		}
	}
	
	
	private func convertToPointOfInterestFromViewCoordiantes(point:CGPoint) -> CGPoint {
		var interestPoint = CGPointMake(0.5, 0.5)
		for _port in deviceIntput!.ports {
			if let port = _port as? AVCaptureInputPort {
				let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(port.formatDescription, true)
				let apertureSize = cleanAperture.size
				let frameSize = previewLayer?.bounds.size
				let apertureRation = apertureSize.height / apertureSize.width
				let viewRatio = frameSize!.width / frameSize!.height
				var xc = CGFloat(0.5)
				var yc = CGFloat(0.5)
				
				if viewRatio > apertureRation {
					let y2 = apertureSize.width * (frameSize!.width / apertureSize.height)
					xc  = (point.y + ((y2 - frameSize!.height) / 2)) / y2
					yc = (frameSize!.width - point.x) / frameSize!.width
				}else {
					let x2 = apertureSize.height * (frameSize!.height / apertureSize.width)
					yc = 1.0 - ((point.x + ((x2 - frameSize!.width) / 2)) / x2)
				}
				interestPoint = CGPointMake(xc, yc)
				break
			}
		}
		return interestPoint
	}
	
	//MARK: PMimagepickerControllerDelegate
	func imagePickerControllerDidCancel(picker: PMImagePickerController) {
		session.startRunning()
	}
	
	func imagePickerController(picker: PMImagePickerController, didFinishPickingImage image: UIImage) {
		
	}
	
	func imagePickerController(picker: PMImagePickerController, didFinishPickingImage originalImage: UIImage, selectedRect: CGRect, zoomScale: CGFloat) {
		photoPisplayBoard?.setState(.EditImage, image: originalImage, selectedRect: selectedRect, zoomScale: zoomScale, animated: false)
		let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
		let editVC = storyBoard.instantiateViewControllerWithIdentifier("imageEditController") as? PMImageEditController
		navigationController?.pushViewController(editVC!, animated: false)
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class PushAnimator: NSObject,UIViewControllerAnimatedTransitioning {
	var push:Bool = true
	var isInteractive:Bool = false
	
	override init() {
		super.init()
	}
	
	
	convenience init(isPush:Bool) {
		self.init()
		self.push = isPush
	}
	
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return kPushDuration
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
		let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
		let containView = transitionContext.containerView()
		
		containView?.addSubview(fromViewController!.view)
		containView?.addSubview(toViewController!.view)
		var fromFrame = fromViewController?.view.frame
		var toFrame = toViewController?.view.frame
		let screenWidth = UIScreen.mainScreen().bounds.size.width
		var animationOption = UIViewAnimationOptions.CurveEaseInOut
		
		if isInteractive {
			animationOption = UIViewAnimationOptions.CurveLinear
		}
		
		if push {
			toFrame?.origin.x = screenWidth
			toViewController?.view.frame = toFrame!
			UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: animationOption, animations: { 
				fromFrame?.origin.x = -screenWidth
				fromViewController?.view.frame = fromFrame!
				toFrame?.origin.x = 0
				toViewController?.view.frame = toFrame!
				}, completion: { (com:Bool) in
					let complete  = !transitionContext.transitionWasCancelled()
					if complete {
						if let nav = fromViewController?.navigationController as? PMNavigationController{
							if let completion = nav.completionHandler {
								completion(isPush: false)
							}
						}
					}
					transitionContext.completeTransition(complete)

			})
		}else {
			toFrame?.origin.x = -screenWidth
			toViewController?.view.frame = toFrame!
			UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: animationOption, animations: { 
				fromFrame?.origin.x = -screenWidth
				fromViewController?.view.frame = fromFrame!
				toFrame?.origin.x = 0
				toViewController?.view.frame = toFrame!
				}, completion: { (com:Bool) in
					let complete = !transitionContext.transitionWasCancelled()
					if complete {
						if let nav = toViewController?.navigationController as? PMNavigationController  {
							if let completion = nav.completionHandler {
								completion(isPush: false)
							}
						}
					}
					transitionContext.completeTransition(complete)
			})
		}
	}
}

extension UIBarButtonItem {
	var highlighted: Bool{
		set {
			if let button = customView as? UIButton {
				button.highlighted = newValue
			}
		}
		
		get {
			if let button = customView as? UIButton {
				return button.highlighted
			}
			return false
		}
	}
}

extension PMImageCaptureController: PMImagePickerControllerDelegate {

}

extension UIViewController {
	var photoPisplayBoard: PMImageProtocol? {
	get {
	let vc = UIApplication.sharedApplication().keyWindow?.rootViewController
		if let rootVC = vc as? ViewController {
			return rootVC
		}
		return nil
	}
	}
}