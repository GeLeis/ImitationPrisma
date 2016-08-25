//
//  PMImageViewController.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/23.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

struct ConstParams {
	let headerTopInset:CGFloat = 44
	let minMoveDistance:CGFloat = 44
	let moveHeaderAnimationDuration:CFTimeInterval = 0.28
	let backHeaderAnimationDuration:CFTimeInterval = 0.15
	let presentGroupAnimationDuration:CFTimeInterval = 0.25
	
}

class PMImageViewController: UIViewController {
	
	var displayHeader: PMPhotoHaderView!
	var albumCollection: UICollectionView!
	private var pmNavigationController:PMImagePickerController?{
		get{
			return navigationController as? PMImagePickerController
		}
	}
	
	
	var titleButton: PMPickerTitleButton?
	let screenSize: ScreenSize = ScreenSize()
	let constParams: ConstParams = ConstParams()
	
	let loadingView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
	
	var photoGroups = [PHAssetCollection]?()
	var photoAssets = [PHAsset]?()
	var photos = [UIImage]()
	
	var shouldMoveHeaderUp:Bool = false
	var shouldMoveHeaderDown:Bool = false
	var isHeaderMoving:Bool = false
	var contentOffset = CGPointZero
	var selectedIndex:Int = 0
	var navigatioBar:UINavigationBar!
	var headerTopConstant:CGFloat = 0.00
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		edgesForExtendedLayout = .None
		automaticallyAdjustsScrollViewInsets = false
		
		
		initNavigationBar()
		
		configMianView()
		
		getPhotos()
		
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	

	
	func configMianView() {
		
		weak var weakSelf = self
		
		displayHeader = PMPhotoHaderView.init(frame: CGRectMake(0, 0, screenSize.width, screenSize.width))
		displayHeader.tapAction = { (view:PMPhotoHaderView)  in
			weakSelf?.dropDownHeader(false)
		}
		view.insertSubview(displayHeader, belowSubview: navigatioBar)
		displayHeader.snp.makeConstraints { (make) in
			make.size.equalTo(CGSizeMake(weakSelf!.screenSize.width, weakSelf!.screenSize.width))
			make.centerX.equalTo(weakSelf!.view)
			make.top.equalTo(weakSelf!.navigatioBar.snp.bottom).offset(weakSelf!.headerTopConstant);
		}
		
		let layout = UICollectionViewFlowLayout.init()
		layout.itemSize = CGSizeMake((screenSize.width - 3) / 4, (screenSize.width - 3) / 4)
		layout.minimumLineSpacing = 1
		layout.minimumInteritemSpacing = 1
		layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
		layout.scrollDirection = .Vertical
		
		albumCollection = UICollectionView.init(frame: CGRectMake(0, 0, screenSize.width, screenSize.height - constParams.headerTopInset - constParams.minMoveDistance), collectionViewLayout: layout)
		
		albumCollection.backgroundColor = UIColor.whiteColor()
		albumCollection.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "albumCell")
		albumCollection.delegate = self
		albumCollection.dataSource = self
		view.addSubview(albumCollection)
		albumCollection.snp.makeConstraints { (make) in
			make.size.equalTo(CGSizeMake(weakSelf!.screenSize.width, weakSelf!.screenSize.height - weakSelf!.constParams.headerTopInset - weakSelf!.constParams.minMoveDistance))
			make.top.equalTo(weakSelf!.displayHeader.snp.bottom).offset(1);
		}
		
	}
	
	func initNavigationBar() {
		
		
		navigatioBar = UINavigationBar.init(frame: CGRectMake(0, 0, screenSize.width, constParams.headerTopInset));
		self.navigationController?.navigationBar.hidden = true
		view.addSubview(navigatioBar);
		
		navigatioBar.setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor(), size: CGSizeMake(screenSize.width, constParams.headerTopInset)), forBarPosition: UIBarPosition.Top, barMetrics: UIBarMetrics.Default)
		navigatioBar.shadowImage = UIImage.init()
		
		
		let leftBarItem = UIButton.init(type: .Custom)
		leftBarItem.setTitleColor(UIColor.blackColor(), forState: .Normal)
		leftBarItem.setTitle("Cancel", forState: .Normal)
		leftBarItem.titleLabel?.font = UIFont.systemFontOfSize(16)
		leftBarItem.addTarget(self, action: #selector(self.cancel), forControlEvents: .TouchUpInside)
		
		navigatioBar.addSubview(leftBarItem)
		weak var weakSelf = self
		leftBarItem.snp.makeConstraints { (make) in
			make.left.equalTo(weakSelf!.navigatioBar.snp.left).offset(15)
			make.centerY.equalTo(weakSelf!.navigatioBar.snp.centerY)
		}
		
		let rightBarItem = UIButton.init(type: .Custom)
		rightBarItem.setTitleColor(UIColor.blackColor(), forState: .Normal)
		rightBarItem.setTitle("Use", forState: .Normal)
		rightBarItem.titleLabel?.font = UIFont.systemFontOfSize(16)
		rightBarItem.addTarget(self, action: #selector(self.confirm), forControlEvents: .TouchUpInside)
		navigatioBar.addSubview(rightBarItem)
		rightBarItem.snp.makeConstraints { (make) in
			make.right.equalTo(weakSelf!.navigatioBar.snp.right).offset(-15)
			make.centerY.equalTo(weakSelf!.navigatioBar.snp.centerY)
		}
		
		let image = UIImage.init(named: "albums-arrow")
		let hImage = image?.imageWithColor(UIColor.lightGrayColor())
		
		titleButton = PMPickerTitleButton.init(type: .Custom)
		if #available(iOS 8.2, *) {
			titleButton?.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
		}else{
			titleButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
		}
		titleButton?.setTitle("Camera", forState: .Normal)
		titleButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
		titleButton?.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
		titleButton?.setTitleColor(UIColor.lightGrayColor(), forState: .Selected)
		titleButton?.setImage(image, forState: .Normal)
		titleButton?.setImage(hImage, forState: .Highlighted)
		titleButton?.setImage(hImage, forState: .Selected)
		titleButton?.sizeToFit()
		titleButton?.addTarget(self, action: #selector(self.selectPhotoGroup), forControlEvents: .TouchUpInside)
		navigatioBar.addSubview(titleButton!)
		titleButton?.snp.makeConstraints(closure: { (make) in
			make.centerY.equalTo(weakSelf!.navigatioBar.snp.centerY)
			make.centerX.equalTo(weakSelf!.navigatioBar.snp.centerX)
		})
		
	}
	
	func getPhotos() {
		
		PMImageManager.photoAuthorization { (granted: Bool) in
			if granted {
				// Start loading
				self.loadingView.frame = self.albumCollection.bounds
				self.loadingView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
				self.albumCollection.addSubview(self.loadingView)
				self.loadingView.startAnimating()
				
				// Asynchronous get photos, avoid taking the main thread
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
					if (self.photoGroups == nil) {
						self.photoGroups = PMImageManager.photoLibrarys()
					}
					
					let group = self.photoGroups![0]
					if (self.photoAssets == nil) {
						self.photoAssets = PMImageManager.photoAssetsForAlbum(group)
					}
					
					PMImageManager.imageFromAsset(self.photoAssets!.first!, isOriginal: true, toSize: nil, resultHandler: { (image: UIImage?) in
						// Set header photo
						dispatch_async(dispatch_get_main_queue(), {
							self.displayHeader.setImage(image!, scrollToRect: CGRectZero, zoomScale:1)
							
						})
					})
					
					for asset: PHAsset in self.photoAssets! {
						PMImageManager.imageFromAsset(asset, isOriginal: false, toSize: CGSizeMake(150, 150), resultHandler: { (image: UIImage?) in
							self.photos.append(image!)
						})
					}
					
					dispatch_async(dispatch_get_main_queue(), {
						// Stop loading
						self.loadingView.stopAnimating()
						self.loadingView.removeFromSuperview()
						// Title
						self.titleButton?.setTitle(group.localizedTitle, forState: UIControlState.Normal)
						self.titleButton?.sizeToFit()
						// Reload data
						self.albumCollection.reloadData()
					})
				})
			}
		}
	}
	
	
	
	
	func cancel() {
		dismissViewControllerAnimated(true) {
			let navigationController = self.pmNavigationController
			navigationController?.pmDelegate?.imagePickerControllerDidCancel?(navigationController!)
		}
	}
	
	func confirm() {
		var imageRect = CGRectZero
		var finalImage = displayHeader.image
		var x = fmax(displayHeader.imageView.contentOffset.x, 0)
		var y = fmax(displayHeader.imageView.contentOffset.y, 0)
		x = x/displayHeader.imageView.contentSize.width * finalImage.size.width
		y = y/displayHeader.imageView.contentSize.height * finalImage.size.height
		imageRect = CGRectMake(x, y, finalImage.size.height, finalImage.size.height)
		
		let navigationController = self.pmNavigationController
		let responsOriginal = navigationController?.pmDelegate?.respondsToSelector(#selector(PMImagePickerControllerDelegate.imagePickerController(_:didFinishPickingImage:selectedRect:zoomScale:)))
		if (responsOriginal != nil) {
			// Not crop the image just call delegate with original image
			let zoomScale = displayHeader.imageView.zoomScale
			navigationController?.pmDelegate?.imagePickerController!(navigationController!, didFinishPickingImage: finalImage, selectedRect: imageRect, zoomScale:zoomScale)
		}else {
			// Get the final cropped image
			finalImage = PMImageManager.cropImageToRect(finalImage, toRect: imageRect)
			// Call delegate
			navigationController?.pmDelegate?.imagePickerController?(navigationController!, didFinishPickingImage: finalImage)
		}
		
		dismissViewControllerAnimated(true) {
			
		}
	}
	
	
	
	func selectPhotoGroup() {
		var status = titleButton!.arrowStatus
		switch status {
		case .down://刚开始向下
			let arrow = titleButton?.imageView
			var frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height)
			let groupVC = PMImageGroupController.init()
			groupVC.photoGroups = photoGroups
			groupVC.view.frame = frame 
			view.addSubview(groupVC.view)
			self.addChildViewController(groupVC)
			
			UIView.animateWithDuration(constParams.presentGroupAnimationDuration, delay: 0, options: .CurveLinear, animations: { 
				frame.origin.y = 43
				groupVC.view.frame = frame
				arrow?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI - 0.01))
				self.navigationItem.leftBarButtonItem?.customView?.alpha = 0
				self.navigationItem.rightBarButtonItem?.customView?.alpha = 0
				
				}, completion: { (com:Bool) in
					status = .up
					self.titleButton?.arrowStatus = status
			})
			
			weak var weakSelf = self
			groupVC.didSelectGroupAction = { (index:Int) in

				let groupCollection = weakSelf!.photoGroups![index]
				weakSelf?.photoAssets = PMImageManager.photoAssetsForAlbum(groupCollection)
				PMImageManager.imageFromAsset(weakSelf!.photoAssets!.first!, isOriginal: true, toSize: nil, resultHandler: { (image: UIImage?) in
					if let _image = image {
						weakSelf!.displayHeader.setImage(_image, scrollToRect: CGRectZero, zoomScale: 1)
						
					}
				})
				
				weakSelf!.photos.removeAll()
				for asset: PHAsset in weakSelf!.photoAssets! {
					PMImageManager.imageFromAsset(asset, isOriginal: false, toSize: CGSizeMake(150, 150), resultHandler: { (image: UIImage?) in
						weakSelf!.photos.append(image!)
					})
				}
				
				weakSelf!.titleButton?.setTitle(groupCollection.localizedTitle, forState: .Normal)
				weakSelf!.titleButton?.sizeToFit()
				weakSelf!.selectedIndex = 0
				weakSelf!.albumCollection.reloadData()
				
				weakSelf!.dropDownHeader(true)
				weakSelf?.dismissGroup()
			}
			break
		case .up:
			dismissGroup()
			break
			
		}
	}
	
	func dismissGroup(){
		let arrow = titleButton?.imageView
		let groupVC = childViewControllers.first
		var frame = groupVC?.view.frame
		
		UIView.animateWithDuration(constParams.presentGroupAnimationDuration, delay: 0, options: .CurveLinear, animations: { 
			frame?.origin.y = self.screenSize.height
			groupVC?.view.frame = frame!
			arrow?.transform = CGAffineTransformIdentity
			self.navigationItem.leftBarButtonItem?.customView?.alpha = 1
			self.navigationItem.rightBarButtonItem?.customView?.alpha = 1
			
		}) { (com:Bool) in
			self.titleButton?.arrowStatus = .down
			groupVC?.view.removeFromSuperview()
			groupVC?.removeFromParentViewController()
		}
	}
	
	func dropDownHeader(selectedItem: Bool) {
		if selectedItem {
			if headerTopConstant == 0 {
				if let cell = albumCollection.cellForItemAtIndexPath(NSIndexPath.init(forItem: selectedIndex, inSection: 0)) {
					albumCollection.scrollRectToVisible(cell.frame, animated: true)
				}else {
					albumCollection.setContentOffset(CGPointMake(0, 0), animated: true)
				}
			}else {
				var cellFrame = CGRectZero
				if let cell = albumCollection.cellForItemAtIndexPath(NSIndexPath.init(forItem: selectedIndex, inSection: 0)) {
					cellFrame = cell.frame
				}
				let cellFrameToHeader = displayHeader.convertRect(cellFrame, fromView: albumCollection)
				let lineSpace = (albumCollection.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing
				let moveDistance = -headerTopConstant
				var contentOffset = albumCollection.contentOffset
				let adjustDistance = (displayHeader.bounds.size.height + moveDistance + lineSpace!) - CGRectGetMinY(cellFrameToHeader)
				
				contentOffset.y += moveDistance
				if adjustDistance > 0 {
					contentOffset.y -= adjustDistance
				}
				
				self.headerTopConstant = 0
				self.albumCollection.contentOffset = contentOffset
				
				self.view.setNeedsUpdateConstraints()
				self.view.updateConstraintsIfNeeded()
				
				UIView.animateWithDuration(constParams.moveHeaderAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
					// Tip: set `contentOffset` must after set constant of `headerTopConstraints`, otherwise it will not be effect
					// Also should call `setNeedsLayout` & `layoutIfNeeded` to ensure the animation of collection view, because the cells above the selected cell will be hidden or remove during the animation when we don't call `layoutSubViews` of the collection
					
					self.view.layoutIfNeeded()
					self.albumCollection.setNeedsLayout()
					self.albumCollection.layoutIfNeeded()
					}, completion: { (com: Bool) in
						
				})
			}
		}else {
			guard -headerTopConstant == (screenSize.width - constParams.headerTopInset) else {
				return
			}
			var contentOffset = albumCollection.contentOffset
			let moveDistance = -headerTopConstant
			contentOffset.y += moveDistance
			
			self.albumCollection.contentOffset = contentOffset
			self.headerTopConstant = 0
			
			self.view.setNeedsUpdateConstraints()
			self.view.updateConstraintsIfNeeded()
			UIView.animateWithDuration(constParams.moveHeaderAnimationDuration) {
				
				self.view.layoutIfNeeded()
			}
		}
	}
	
	
	override func updateViewConstraints() {
		weak var weakSelf = self
		displayHeader.snp.updateConstraints { (make) in
			make.size.equalTo(CGSizeMake(weakSelf!.screenSize.width, weakSelf!.screenSize.width))
			make.centerX.equalTo(weakSelf!.view)
			make.top.equalTo(weakSelf!.navigatioBar.snp.bottom).offset(weakSelf!.headerTopConstant);
		}
		super.updateViewConstraints()
	}
	
	
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	
	func scrollViewDidPan(panGestureRecognizer: UIPanGestureRecognizer) {
		let velocity = panGestureRecognizer.velocityInView(albumCollection)
		let tramslation = panGestureRecognizer.translationInView(view)
		let location = panGestureRecognizer.locationInView(displayHeader)
		var touchHeaderBottom: Bool = false
		
		
		// Move up
		if (velocity.y < 0) {
			touchHeaderBottom = location.y < displayHeader!.bounds.size.height
			shouldMoveHeaderDown = false;
			switch (panGestureRecognizer.state) {
			case .Began:
				shouldMoveHeaderUp = location.y < displayHeader!.bounds.size.height && headerTopConstant > -(screenSize.width - constParams.headerTopInset)
				if shouldMoveHeaderUp {
					contentOffset = albumCollection.contentOffset
					panGestureRecognizer.setTranslation(CGPointMake(0, 0), inView: view)
				}
				break;
			case .Changed:
				if isHeaderMoving {
					shouldMoveHeaderUp = true
				}
				if shouldMoveHeaderUp {
					headerTopConstant += tramslation.y;
					
					if headerTopConstant > -(screenSize.width - constParams.headerTopInset) {
						contentOffset.y = fmin(contentOffset.y, albumCollection.contentSize.height - albumCollection.bounds.size.height)
						albumCollection!.contentOffset = contentOffset
						panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
					}else {
						headerTopConstant = -(screenSize.width - constParams.headerTopInset)
						isHeaderMoving = false
					}
					
					self.view.setNeedsUpdateConstraints()
					self.view.updateConstraintsIfNeeded()
					UIView.animateWithDuration(0.1, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveLinear], animations: {
						
						self.view.layoutIfNeeded()
						}, completion: { (finish: Bool) in
							
					})
					
					
				}else {
					shouldMoveHeaderUp = touchHeaderBottom && headerTopConstant > -(screenSize.width - constParams.headerTopInset)
					if shouldMoveHeaderUp {
						isHeaderMoving = true
						contentOffset = albumCollection!.contentOffset
						if albumCollection.contentSize.height <= albumCollection.bounds.size.height {
							contentOffset = CGPointMake(0, 0)
						}
						panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
					}
				}
				break;
			case .Ended:
				shouldMoveHeaderUp = false; isHeaderMoving = false
				let isNotOnTheTop: Bool = headerTopConstant > -(screenSize.width - constParams.headerTopInset)
				if isNotOnTheTop {
					let shouldAnimationToTop = headerTopConstant < -constParams.minMoveDistance
					if shouldAnimationToTop {
						let distance = screenSize.width - (constParams.headerTopInset + constParams.minMoveDistance)
						let duration = CFTimeInterval((distance + (constParams.minMoveDistance + headerTopConstant))/distance) * constParams.moveHeaderAnimationDuration
						self.headerTopConstant = -(self.screenSize.width - self.constParams.headerTopInset)
						self.view.setNeedsUpdateConstraints()
						self.view.updateConstraintsIfNeeded()
						UIView.animateWithDuration(duration, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveLinear], animations: {
							
							self.view.layoutIfNeeded()
							}, completion: { (finish: Bool) in
								
						})
					}else {
						self.headerTopConstant = 0
						self.view.setNeedsUpdateConstraints()
						self.view.updateConstraintsIfNeeded()
						
						UIView.animateWithDuration(self.constParams.backHeaderAnimationDuration, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveLinear], animations: {
							
							self.view.layoutIfNeeded()
							}, completion: { (finish: Bool) in
								
						})
					}
				}
				
				break;
				
			default:
				shouldMoveHeaderUp = false
				break;
			}
		}
			// Move down
		else {
			touchHeaderBottom = location.y < displayHeader!.bounds.size.height && location.y > displayHeader!.bounds.size.height - 20
			shouldMoveHeaderUp = false
			switch (panGestureRecognizer.state) {
			case .Began:
				shouldMoveHeaderDown = albumCollection.contentOffset.y <= 0 && headerTopConstant < 0
				if shouldMoveHeaderDown {
					contentOffset.y = 0
					albumCollection.contentOffset = contentOffset
					panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
				}
				break;
			case .Changed:
				if isHeaderMoving {
					shouldMoveHeaderDown = true
				}
				if shouldMoveHeaderDown {
					headerTopConstant += tramslation.y;
					headerTopConstant = fmin(headerTopConstant, 0)
					
					if headerTopConstant < 0 {
						albumCollection.contentOffset = contentOffset
						panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
					}else {
						headerTopConstant = 0
						isHeaderMoving = false
					}
					
				}else {
					shouldMoveHeaderDown = (albumCollection.contentOffset.y <= 0 || touchHeaderBottom) && headerTopConstant < 0
					if shouldMoveHeaderDown {
						isHeaderMoving = true
						contentOffset.y = fmax(albumCollection.contentOffset.y, 0)
						albumCollection.contentOffset = contentOffset
						panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
					}
				}
				break;
			case .Ended:
				shouldMoveHeaderDown = false; isHeaderMoving = false
				let isNotOnTheBottom: Bool = headerTopConstant < 0
				if isNotOnTheBottom {
					let shouldAnimationToBottom: Bool = headerTopConstant > -(screenSize.width - (constParams.minMoveDistance + constParams.headerTopInset))
					if shouldAnimationToBottom {
						let distance = screenSize.width - (constParams.minMoveDistance + constParams.headerTopInset)
						let duration = CFTimeInterval((-headerTopConstant)/distance) * constParams.moveHeaderAnimationDuration
						self.headerTopConstant = 0
						self.view.setNeedsUpdateConstraints()
						self.view.updateConstraintsIfNeeded()
						UIView.animateWithDuration(duration, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveLinear], animations: {
							
							self.view.layoutIfNeeded()
							}, completion: { (finish: Bool) in
								
						})
						
					}else {
						self.headerTopConstant = -(self.screenSize.width - self.constParams.headerTopInset)
						self.view.setNeedsUpdateConstraints()
						self.view.updateConstraintsIfNeeded()
						UIView.animateWithDuration(constParams.backHeaderAnimationDuration, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveLinear], animations: {
							
							self.view.layoutIfNeeded()
							}, completion: { (finish: Bool) in
								
						})
					}
				}
				break;
				
			default:
				shouldMoveHeaderDown = false
				break;
			}
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PMImageViewController: UICollectionViewDelegate,UICollectionViewDataSource{
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return photos.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("albumCell", forIndexPath: indexPath)
		var imageV  = cell.viewWithTag(888) as? UIImageView
		var maskV = cell.viewWithTag(999)
		if nil == imageV {
			imageV = UIImageView.init(frame: cell.bounds)
			imageV?.tag = 888
			imageV?.contentMode = .ScaleAspectFill
			imageV?.layer.masksToBounds = true
			cell.addSubview(imageV!)
		}
		
		if nil == maskV {
			maskV = UIView.init(frame: cell.bounds)
			maskV?.backgroundColor = UIColor.init(white: 1, alpha: 0.75)
			maskV?.tag = 999
			cell.addSubview(maskV!)
		}
		
		imageV?.image = photos[indexPath.item]
		maskV?.hidden = selectedIndex != indexPath.item
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		guard indexPath.item != selectedIndex else {
			return
		}
		let oldCell = collectionView.cellForItemAtIndexPath(NSIndexPath.init(forItem: selectedIndex, inSection: 0))
		let oldMask = oldCell?.viewWithTag(999)
		oldMask?.hidden = true
		let newCell = collectionView.cellForItemAtIndexPath(indexPath)
		let newMask = newCell?.viewWithTag(999)
		newMask?.hidden = false
		selectedIndex = indexPath.item
		dropDownHeader(true)
		
		// Set image
		PMImageManager.imageFromAsset(photoAssets![indexPath.item], isOriginal: true, toSize: nil, resultHandler: { (image: UIImage?) in
			if let _image = image {
				self.displayHeader.setImage(_image, scrollToRect: CGRectZero, zoomScale:1)
			}
		})
	}
	
}

protocol UIScrollViewPanGestureRecognizer {
	func scrollViewDidPan(pan: UIPanGestureRecognizer)
}

extension UIScrollView {
	public override static func initialize() {
		struct Static {
			static var token: dispatch_once_t = 0
		}
		
		// Make sure not subclass
		if self !== UIScrollView.self {
			return
		}
		
		
		dispatch_once(&Static.token) {
			let originalSelector = NSSelectorFromString("handlePan:")
			let swizzledSelector = NSSelectorFromString("pm_handlePan:")
			
			let originalMethod = class_getInstanceMethod(self, originalSelector)
			let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
			
			let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
			
			if didAddMethod {
				class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
			} else {
				method_exchangeImplementations(originalMethod, swizzledMethod);
			}
		}
	}
	
	// MARK: - Method Swizzling
	func pm_handlePan(pan: UIPanGestureRecognizer) {
		pm_handlePan(pan)
		
		if delegate != nil && delegate!.respondsToSelector(NSSelectorFromString("scrollViewDidPan:")) {
			delegate?.performSelector(NSSelectorFromString("scrollViewDidPan:"), withObject: pan)
		}
	}
}
