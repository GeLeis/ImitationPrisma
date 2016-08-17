//
//  PMStyleHeaderView.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/12.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit

class PMStyleHeaderView: UIView {
	var imageView = UIImageView.init()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configSubViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	func configSubViews() -> Void {
		imageView.backgroundColor = UIColor.whiteColor()
		imageView.frame = bounds
		addSubview(imageView)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		imageView.frame = bounds
	}
	
	func setImage(image:UIImage) -> Void {
		imageView.image = image;
	}
	
}
