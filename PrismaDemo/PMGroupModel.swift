//
//  PMGroupModel.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/11.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import Photos

class PMGroupModel: NSObject {

}


extension PHAssetCollection{
	var photosCount:Int {
		let fetchOptions = PHFetchOptions();
		fetchOptions.predicate = NSPredicate(format: "mediaType == %d",PHAssetMediaType.Image.rawValue)
		let result = PHAsset.fetchAssetsInAssetCollection(self, options: fetchOptions);
		return result.count;
	}
	
}