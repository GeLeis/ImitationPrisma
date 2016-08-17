//
//  PMImageManager.swift
//  PrismaDemo
//
//  Created by zhaoP on 16/8/11.
//  Copyright © 2016年 langya. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos
import CoreImage
import Accelerate

public enum RotateOrientation:Int{
	case Up
	case Down
	case Left
	case Right
	case UpMirrored
	case DownMirrored
	case LeftMirrored
	case RightMirrored
}

class PMImageManager: UIView {
	class func captureAuthorization(shouldCapture:((Bool)->Void)) {
		let captureStatues = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
		switch captureStatues {
		case .NotDetermined:
			AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted:Bool) in
				runOnMainQuene({ () -> Void in
					shouldCapture(granted)
				})
			})
			break
		case .Authorized:
			shouldCapture(true)
			break
		default:
			shouldCapture(false)
			break
		}
	}
	class func runOnMainQuene(callBack:(()->Void)?){
		if NSThread.currentThread().isMainThread {
			if let call = callBack {
				call()
			}
		}else{
			dispatch_async(dispatch_get_main_queue(), { 
				if let call = callBack{
					call()
				}
			})
		}
	}
	
	class func cropImageAffterCapture(originImage:UIImage,toSize:CGSize)->UIImage{
		let ratio = toSize.height/toSize.width
		let width = originImage.size.width
		let height = width * ratio
		let x = CGFloat(0)
		let y = (originImage.size.height - height)/2
		
		let finalRect = CGRectMake(x, y, width, height)
		let croppedImage = UIImage.init(CGImage: CGImageCreateWithImageInRect(originImage.CGImage, finalRect)!,scale: originImage.scale,orientation: originImage.imageOrientation)
		return croppedImage
	}
	
	class func cropImageToRect(originImage:UIImage,toRect:CGRect)->UIImage{
		let croppedimage = UIImage.init(CGImage: CGImageCreateWithImageInRect(originImage.CGImage, toRect)!,scale: originImage.scale,orientation: originImage.imageOrientation)
		return croppedimage
		
	}
	
	class func photoAuthorization(cangoAssets:((Bool)->Void)!){
		let PhotoStatus:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
		switch PhotoStatus {
		case .NotDetermined:
			PHPhotoLibrary.requestAuthorization{ (status:PHAuthorizationStatus) in
				dispatch_async(dispatch_get_main_queue(), { 
					switch status {
					case .Authorized:
						cangoAssets(true)
						break;
					default:
						cangoAssets(false)
						break;
					}
				})
			}
			break;
		case .Authorized:
			cangoAssets(true)
			break;
		default:
			cangoAssets(false)
			break;
		}
		
	}
	
	class func photoLibrarys()->[PHAssetCollection]{
		var  photoGroups:[PHAssetCollection] = [PHAssetCollection]()
		
		let cameraRoll: PHAssetCollection = (PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil).lastObject as? PHAssetCollection)!
		if cameraRoll.photosCount > 0 {
			photoGroups.append(cameraRoll)
		}
		
		let favorites:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumFavorites, options: nil)
		favorites.enumerateObjectsWithOptions(.Reverse) { (obj, index: Int, stop:UnsafeMutablePointer<ObjCBool>) in
			let collection = obj as! PHAssetCollection
			guard collection.photosCount > 0 else{
				return
			}
			photoGroups.append(collection)
		}
		
		
		if #available(iOS 9.0, *){
			let screenShots:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumScreenshots, options: nil)
			screenShots.enumerateObjectsWithOptions(.Reverse, usingBlock: { (obj, index: Int, stoo: UnsafeMutablePointer<ObjCBool>) in
				let collection = obj as! PHAssetCollection
				guard collection.photosCount > 0 else{
					return
				}
				photoGroups.append(collection)
			})
		}
		
		let assetCollections:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .AlbumRegular, options: nil)
		assetCollections.enumerateObjectsWithOptions(.Reverse) { (obj, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
			let collection = obj as! PHAssetCollection
			guard collection.photosCount > 0 else{
				return
			}
			photoGroups.append(collection)
		}
		
		return photoGroups
		
	}
	
	
	
	class func photoAssetsForAlbum(collection:PHAssetCollection)->[PHAsset]{
		var photoAssets:[PHAsset] = [PHAsset]()
		let assets:PHFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
		assets.enumerateObjectsWithOptions(.Reverse) { (obj, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
			photoAssets.append(obj as! PHAsset)
		}
		return photoAssets
	}
	
	class func imageFromAsset(asset:PHAsset, isOriginal original:Bool,toSize: CGSize?, resultHandler:(UIImage?)->Void){
		
		let  options = PHImageRequestOptions()
		options.synchronous = true
		options.resizeMode = .Fast
		options.deliveryMode = .FastFormat
		var size = CGSizeMake(100, 100)
		if original {
			size = CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelWidth))
		}else if let _toSize = toSize {
			size = _toSize
		}
		PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: options) { (image:UIImage?, info:[NSObject : AnyObject]?) in
			resultHandler(image)
		}
	}
	
	class func imageOrientationFromDegress(angle:CGFloat)->UIImageOrientation{
		var orientataion = UIImageOrientation.Up
		let ratio = (angle/CGFloat(M_PI/2))%4
		switch ratio {
		case 0:
			orientataion = .Up
			break
		case 1, -3:
			orientataion = .Right
			break
		case 2, -2:
			orientataion = .Down
			break
		case 3, -1:
			orientataion = .Left
			break
		default:
			orientataion = .Up
			break
		}
		return orientataion
	}

}

extension UIImage{
	func imageWithColor(color:UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		let context = UIGraphicsGetCurrentContext()
		CGContextTranslateCTM(context, 0, self.size.height)
		CGContextScaleCTM(context, 1.0, -1.0)
		CGContextSetBlendMode(context, CGBlendMode.Normal)
		let rect = CGRectMake(0, 0, self.size.width, self.size.height)
		CGContextClipToMask(context, rect, self.CGImage)
		color.setFill()
		CGContextFillRect(context, rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage
		
	}
	
	class func imageWithColor(color: UIColor, size: CGSize) -> UIImage  {
		let rect = CGRectMake(0, 0, size.width, size.height)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		CGContextSetFillColorWithColor(context, color.CGColor)
		CGContextFillRect(context, rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
	
	func fixOrientation() -> UIImage {
		return fixOrientation(imageOrientation)
	}
	
	func rotateImageTo(rotateOrientation:RotateOrientation)->UIImage{
		var imageOrientation = UIImageOrientation.Up
		switch rotateOrientation {
		case .Up:
			imageOrientation = .Up;
			break
		case .UpMirrored:
			imageOrientation = .UpMirrored;
			break
		case .Left:
			imageOrientation = .Right;
			break
		case .LeftMirrored:
			imageOrientation = .RightMirrored;
			break
		case .Right:
			imageOrientation = .LeftMirrored;
			break
		case .RightMirrored:
			imageOrientation = .LeftMirrored;
			break
		case .Down:
			imageOrientation = .Down;
			break
		case .DownMirrored:
			imageOrientation = .DownMirrored;
			break
		}
		return fixOrientation(imageOrientation);
	}
	
	
	func rotateImageFromInterfaceOrientation(orientation: UIDeviceOrientation) -> UIImage {
		var rotateOrientation = RotateOrientation.Up
		switch orientation {
		case .Portrait:
			rotateOrientation = .Up
			break
		case .LandscapeLeft:
			rotateOrientation = .Right
			break
		case .LandscapeRight:
			rotateOrientation = .Left
			break
		case .PortraitUpsideDown:
			rotateOrientation = .Down
			break
		default:
			rotateOrientation = .Up
			break
		}
		
		return rotateImageTo(rotateOrientation)
		
	}
	
	func fixOrientation(imageOrientation: UIImageOrientation) -> UIImage {
		if imageOrientation == UIImageOrientation.Up {
			return self
		}
		
		var transform: CGAffineTransform = CGAffineTransformIdentity
		
		switch imageOrientation {
		case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
			transform = CGAffineTransformTranslate(transform, size.width, size.height)
			transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
			break
		case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
			transform = CGAffineTransformTranslate(transform, size.width, 0)
			transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
			break
		case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, size.height)
			transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
			break
		case UIImageOrientation.Up, UIImageOrientation.UpMirrored:
			break
		}
		
		switch imageOrientation {
		case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
			CGAffineTransformTranslate(transform, size.width, 0)
			CGAffineTransformScale(transform, -1, 1)
			break
		case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
			CGAffineTransformTranslate(transform, size.height, 0)
			CGAffineTransformScale(transform, -1, 1)
		case UIImageOrientation.Up, UIImageOrientation.Down, UIImageOrientation.Left, UIImageOrientation.Right:
			break
		}
		
		let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), CGImageGetBitsPerComponent(CGImage), 0, CGImageGetColorSpace(CGImage), CGImageAlphaInfo.PremultipliedLast.rawValue)!
		
		CGContextConcatCTM(ctx, transform)
		
		switch imageOrientation {
		case UIImageOrientation.Left, UIImageOrientation.LeftMirrored, UIImageOrientation.Right, UIImageOrientation.RightMirrored:
			CGContextDrawImage(ctx, CGRectMake(0, 0, size.height, size.width), CGImage)
			break
		default:
			CGContextDrawImage(ctx, CGRectMake(0, 0, size.width, size.height), CGImage)
			break
		}
		
		let cgImage: CGImageRef = CGBitmapContextCreateImage(ctx)!
		return UIImage(CGImage: cgImage)
	}
}



extension UIColor {
	class func RGBColor(red:CGFloat,green:CGFloat,blue:CGFloat)->UIColor{
		return RGBAlphaColor(red, green: green, blue: blue, alpha: 1.0)
	}
	
	class func RGBAlphaColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
		return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
	}
	
	class func RGBHexColor(rgbHex: UInt32)->UIColor{
		let r = (rgbHex >> 16) & 0xFF
		let g = (rgbHex >> 8) & 0xFF
		let b = (rgbHex) & 0xFF
		return UIColor.RGBColor(CGFloat(r), green: CGFloat(g), blue: CGFloat(b))
	}
	
}

extension UIDevice {
	
}
