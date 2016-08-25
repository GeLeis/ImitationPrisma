//
//  PMImageGroupCell.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/23.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import SnapKit

class PMImageGroupCell: UITableViewCell {
	var groupCover: UIImageView!
	var groupTitle: UILabel!
	var groupContent: UILabel!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		groupCover = UIImageView.init()
		weak var weakSelf = self
		addSubview(groupCover)
		groupCover.snp.makeConstraints { (make) in
			make.width.height.equalTo(79)
			make.centerY.equalTo(weakSelf!)
			make.left.equalTo(weakSelf!).offset(14)
		}
		
		
		
		
		groupTitle = UILabel.init()
		groupTitle.font = UIFont.systemFontOfSize(17)
		groupTitle.textColor = UIColor.blackColor()
		addSubview(groupTitle)
		groupTitle.snp.makeConstraints { (make) in
			make.bottom.equalTo(weakSelf!.groupCover.snp.centerY).offset(-2)
			make.left.equalTo(weakSelf!.groupCover.snp.right).offset(10)
		}
		
		
		groupContent = UILabel.init()
		groupContent.font = UIFont.systemFontOfSize(14)
		groupContent.textColor = UIColor.blackColor()
		
		addSubview(groupContent)
		groupContent.snp.makeConstraints { (make) in
			make.top.equalTo(weakSelf!.groupCover.snp.centerY).offset(2)
			make.left.equalTo(weakSelf!.groupCover.snp.right).offset(10)
		}
		
		
		selectedBackgroundView = UIView.init(frame: self.bounds)
		selectedBackgroundView?.backgroundColor = UIColor.init(white: 0.85, alpha: 1)
	}
	
	func configGroupCell(group:PMGroupModel) {
		groupCover.image = group.image
		groupTitle.text = group.title
		groupContent.text = group.content
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
