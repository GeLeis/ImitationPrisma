//
//  PMImageProcessController.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/17.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import SnapKit
class PMImageProcessController: UIViewController{
	
	var fromCapture: Bool = false
	var navigationBar:UINavigationBar!
	var stylesCollectionView:UICollectionView!
	var styles: [AnyObject]?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		initNavigationBar()
		
		navigationBar.setBackgroundImage(UIImage.init(), forBarPosition: UIBarPosition.Top, barMetrics: UIBarMetrics.Default)
		navigationBar.shadowImage = UIImage.init()
		navigationBar.translucent = true
		
		styles = getStyles() as? [AnyObject]
		
		let layout = UICollectionViewFlowLayout.init()
		layout.itemSize = CGSizeMake(140, 140)
		layout.minimumLineSpacing = 20
		layout.sectionInset = UIEdgeInsetsMake(5, 20, 5, 20)
		layout.scrollDirection = .Horizontal
		
		
		stylesCollectionView = UICollectionView.init(frame: CGRectMake(0, 0, ScreenSize().width, 150), collectionViewLayout: layout)
		stylesCollectionView.backgroundColor = UIColor.whiteColor()
		stylesCollectionView.registerClass(PMStyleCell.self, forCellWithReuseIdentifier: "styleCell")
		stylesCollectionView.delegate = self
		stylesCollectionView.dataSource = self
		view.addSubview(stylesCollectionView)
		stylesCollectionView.snp.makeConstraints { (make) in
			make.left.equalTo(self.view)
			make.top.equalTo(self.view).offset((ScreenSize().height - ScreenSize().width + 44 - 150) * 0.5)
			make.size.equalTo(CGSizeMake(ScreenSize().width, 150))
		}
		
		let navigationController = self.navigationController as? PMNavigationController
		
		//指定两个手势共存,,前者等待后者，确定后者不响应的情况下，前者才会响应
		stylesCollectionView.panGestureRecognizer.requireGestureRecognizerToFail(navigationController!.panGestureRecognizer)
    }
	
	func getStyles()->AnyObject{
		
		
		let dataPath = NSBundle.mainBundle().pathForResource("", ofType: "json")
		let data = NSData.init(contentsOfFile: dataPath!)
		let dataDic: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
		let styles: AnyObject = dataDic.objectForKey("styles")!
		return styles
	}
	
	func initNavigationBar(){
		navigationBar = UINavigationBar.init(frame: CGRectMake(0, 20, ScreenSize().width, 44));
		self.navigationController?.navigationBar.hidden = true
		view.addSubview(navigationBar);
		
		let backBtn = UIButton.init(type: .Custom)
		backBtn.frame = CGRectMake(15, 0, 44, 44);
		backBtn.setImage(UIImage.init(named: "back"), forState: .Normal)
		backBtn.addTarget(self, action: #selector(self.back(_:)), forControlEvents: .TouchUpInside)
		navigationBar.addSubview(backBtn)
		
		
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func back(sener:AnyObject) {
		let navigationController = self.navigationController as? PMNavigationController
		navigationController?.popViewControllerAnimated(true, completion: { (isPush: Bool) in
			if !isPush {
				let state = self.fromCapture ? PMImageDisplayState.Preview:PMImageDisplayState.EditImage
				self.photoPisplayBoard?.setState(state, image: nil, selectedRect: CGRectZero, zoomScale:1, animated: true)
			}
		})
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		if navigationController == nil {
			let state = self.fromCapture ? PMImageDisplayState.Preview : PMImageDisplayState.EditImage
			self.photoPisplayBoard?.setState(state, image: nil, selectedRect: CGRectZero, zoomScale: 1, animated: true)
		}
	}
}

extension PMImageProcessController:UICollectionViewDelegate,UICollectionViewDataSource {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 10
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("styleCell", forIndexPath: indexPath) as? PMStyleCell
		let style: AnyObject = styles![indexPath.row]
		cell?.loadImage(style)
		return cell!
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		print("click item at \(indexPath.item)")
	}
}
