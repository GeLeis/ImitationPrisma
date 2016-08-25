//
//  PMImageGroupController.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/23.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import Photos
class PMImageGroupController: UIViewController {
	var tableView: UITableView!
	let topLine:CALayer = CALayer.init()
	var groups: [PMGroupModel] = [PMGroupModel]()
	var photoGroups: [PHAssetCollection]? = [PHAssetCollection]()
	var didSelectGroupAction:((Int)->Void)?
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView = UITableView.init(frame: view.frame, style: .Plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.registerClass(PMImageGroupCell.self, forCellReuseIdentifier: "kgroupCellId")
		tableView.separatorStyle = .None
		view.addSubview(tableView)
        edgesForExtendedLayout = .None
		automaticallyAdjustsScrollViewInsets = false
		
		var contentInset = tableView.contentInset
		contentInset.bottom = 44
		tableView.contentInset = contentInset
		
		let mainScreen: UIScreen = UIScreen.mainScreen()
		let frame = CGRectMake(0, -1/mainScreen.scale, mainScreen.bounds.size.width, 1/mainScreen.scale)
		
		topLine.frame = frame
		topLine.backgroundColor = UIColor.whiteColor().CGColor
		topLine.shadowOffset = CGSizeMake(0, frame.size.height)
		topLine.shadowRadius = 1
		topLine.shadowOpacity = 1
		topLine.shadowColor = UIColor.lightGrayColor().CGColor
		
		view.layer.masksToBounds = true
		view.layer.addSublayer(topLine)
		
		for collection in photoGroups! {
			let groupModel = PMGroupModel.groupModelFromPHAssetCollection(collection)
			groups.append(groupModel)
		}
    }
	
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
}

extension PMImageGroupController: UITableViewDelegate,UITableViewDataSource{
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return groups.count
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UIScreen.mainScreen().bounds.size.width/320 * 80
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("kgroupCellId", forIndexPath: indexPath) as! PMImageGroupCell

		let groupModel = groups[indexPath.item]
		cell.configGroupCell(groupModel)
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let doneAction = didSelectGroupAction {
			doneAction(indexPath.item)
		}
	}
	
}
