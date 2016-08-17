//
//  PMImageProtocol.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/12.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import AVFoundation

@objc enum PMImageOrientaion :Int {
	case Up
	case Down
	case left
	case Right
}

@objc enum PMImageDisplayState:Int {
	case Preview
	case EditImage
	case SingleShow
}

@objc protocol PMImageProtocol {
	optional var dispalyImage: UIImage { get }
	var displayheaderView: UIView { get }
	var rotatedImageOrientation:PMImageOrientaion { get }
	var singleTapHeaderAction: ((tap:UITapGestureRecognizer)->Void){ get set }
	func setAVCapturepreviewLayer(layer:AVCaptureVideoPreviewLayer)
	func setState(state:PMImageDisplayState, image:UIImage?,selectedRect: CGRect,zoomScale:CGFloat,animated:Bool)
	func rotateDisplayImage(clockwise:Bool)
	func croppedImage() -> UIImage
}