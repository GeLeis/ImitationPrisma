//
//  PMPickerTitleButton.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/23.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit

enum ArrowStatus {
	case up
	case down
}

class PMPickerTitleButton: UIButton {
	var arrowStatus: ArrowStatus = .down
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
		var rect = contentRect
		print("====>\(contentRect)")
		//位子在左，图片在右
		rect.size.width -= contentRect.size.height
		return rect
	}
	
	override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
		print("=====>\(contentRect)")
		var rect = contentRect
		rect.size.width = contentRect.size.height
		rect.origin.x = CGRectGetWidth(contentRect) - CGRectGetWidth(rect)
		return rect
	}
}
