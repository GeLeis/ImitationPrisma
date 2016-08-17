//
//  PMImagePickerController.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/17.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import Photos

@objc protocol PMImagePickerControllerDelegate: NSObjectProtocol{
	optional func imagePickerController(picker:PMImagePickerController, didFinishPickingImage image:UIImage)
	
	optional func imagePickerController(picker:PMImagePickerController, didFinishPickingImage originalImage:UIImage, selectedRect:CGRect,zoomScale:CGFloat)
	
	optional func imagePickerControllerDidCancel(picker:PMImagePickerController)
	
}


class PMImagePickerController: UINavigationController {

	private var _photoGroups:[PHAssetCollection]? = [PHAssetCollection]()
	private var _photoAssets: [PHAsset]? = [PHAsset]()
	
	weak var pmDelegate: PMImagePickerControllerDelegate?
	var photoGroups:[PHAssetCollection]{
		set {
			_photoGroups = newValue
			
		}
		get {
			 return _photoGroups!
		}
	}
	
	var photoAssets: [PHAsset] {
		set {
			_photoAssets = newValue
		}
		
		get {
			return _photoAssets!
		}
	}
	
	
	init() {
		let rootVC = PMImagePickerController(nibName: "PMImageViewController",bundle:nil)
		super.init(rootViewController: rootVC)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let bgImage = UIImage.imageWithColor(UIColor.whiteColor(),size: CGSizeMake(ScreenSize().width, 44))
		navigationBar.tintColor = UIColor.blackColor()
		navigationBar.setBackgroundImage(bgImage, forBarPosition: .Top, barMetrics: .Default)
		navigationBar.shadowImage = UIImage.init()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

