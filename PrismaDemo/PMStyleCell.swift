//
//  PMStyleCell.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/19.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
class PMStyleCell: UICollectionViewCell {
	var styleImageView:UIImageView!
	var styleNameLabel:UILabel!
	var view:UIView!
	var indicator:UIActivityIndicatorView!
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		view = UIView.init(frame: CGRectMake(0, 0, 140, 140))
		view.backgroundColor = UIColor ( red: 0.6667, green: 0.6667, blue: 0.6667, alpha: 0.216998922413793 )
		addSubview(view)
		view.snp.makeConstraints { [weak self](make) in
			make.edges.equalTo(self!)
		}
		
		styleImageView = UIImageView.init()
		view.addSubview(styleImageView)
		styleImageView.snp.makeConstraints { [weak self](make) in
			make.edges.equalTo(self!.view)
		}
		
		styleNameLabel = UILabel.init()
		styleNameLabel.font = UIFont.systemFontOfSize(15)
		styleNameLabel.textColor = UIColor.whiteColor()
		styleNameLabel.backgroundColor = UIColor.blackColor()
		view.addSubview(styleNameLabel)
		styleNameLabel.snp.makeConstraints { [weak self](make) in
			make.left.right.bottom.equalTo(self!.view)
		}
		
		indicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
		view.addSubview(indicator)
		indicator.snp.makeConstraints { [weak self](make) in
			make.centerX.centerY.equalTo(self!.view)
		}
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	func loadImage(data:AnyObject) {
		indicator.hidden = false
		indicator.startAnimating()
		
		let title:String = data.objectForKey("artwork") as! String
		self.styleNameLabel.text = title
		
		let url = NSURL.init(string: data.objectForKey("image_url") as! String)
		styleImageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
			self.indicator.stopAnimating()
			self.indicator.hidden = true
		}
	}
}
