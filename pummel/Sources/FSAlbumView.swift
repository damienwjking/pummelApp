//
//  FSAlbumView.swift
//  Fusuma
//
//  Created by Thong Nguyen on 2015/11/14.
//  Copyright © 2015年 Thong Nguyen. All rights reserved.
//

import UIKit
import Photos

@objc public protocol FSAlbumViewDelegate: class {
    
    func albumViewCameraRollUnauthorized()
}

final class FSAlbumView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewConstraintHeight: NSLayoutConstraint!
    
    weak var delegate: FSAlbumViewDelegate? = nil
    var imageSelected : UIImage!
    var images: PHFetchResult<AnyObject>!
    var imageManager: PHCachingImageManager?
    var previousPreheatRect: CGRect = CGRect()
    let cellSize = CGSize(width: 100, height: 100)
    
    // Variables for calculating the position
    enum Direction {
        case Scroll
        case Stop
        case Up
        case Down
    }
    let imageCropViewOriginalConstraintTop: CGFloat = 50
    let imageCropViewMinimalVisibleHeight: CGFloat  = 100
    var dragDirection = Direction.Up
    var imaginaryCollectionViewOffsetStartPosY: CGFloat = 0.0
    
    var cropBottomY: CGFloat  = 0.0
    var dragStartPos: CGPoint = CGPoint()
    let dragDiff: CGFloat     = 20.0
    
    static func instance() -> FSAlbumView {
        
        return UINib(nibName: "FSAlbumView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! FSAlbumView
    }
    
    func initialize() {
        
        if images != nil {
            
            return
        }
		
		self.isHidden = false
        
     
        dragDirection = Direction.Up
        
        let nib = UINib(nibName: "FSAlbumViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "FSAlbumViewCell")
		collectionView.backgroundColor = UIColor.white
        // Never load photos Unless the user allows to access to photo album
        checkPhotoAuth()
        
        // Sorting condition
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        images = PHAsset.fetchAssets(with: .image, options: options) as! PHFetchResult<AnyObject>
        
        if images.count > 0 {
            
            changeImage(asset: images[0] as! PHAsset)
            collectionView.reloadData()
            collectionView.selectItem(at: NSIndexPath(row: 0, section: 0) as IndexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
        }
        
        PHPhotoLibrary.shared().register(self)
        
        self.pickingTheLastImageFromThePhotoLibrary()
    }
    
    deinit {
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FSAlbumViewCell", for: indexPath) as! FSAlbumViewCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let asset = self.images[indexPath.item] as! PHAsset
        self.imageManager?.requestImage(for: asset,
            targetSize: cellSize,
            contentMode: .aspectFill,
            options: nil) {
                result, info in
                
                if cell.tag == currentTag {
                    cell.image = result
                }
                
        }
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images == nil ? 0 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = images[indexPath.row] as! PHAsset
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        self.imageManager?.requestImage(for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFill,
            options: options) {
                result, info in
                self.imageSelected = result
        }
        
        dragDirection = Direction.Up
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    
    // MARK: - ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collectionView {
            self.updateCachedAssets()
        }
    }
    
    func pickingTheLastImageFromThePhotoLibrary() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        if let lastAsset: PHAsset = fetchResult.lastObject {
            let manager = PHImageManager.default()
            let imageRequestOptions = PHImageRequestOptions()
            
            manager.requestImageData(for: lastAsset, options: imageRequestOptions, resultHandler: { (imageData, dataUTI, orientation, info) in
                if let imageDataUnwrapped = imageData, let lastImageRetrieved = UIImage(data: imageDataUnwrapped) {
                    // do stuff with image
                    self.imageSelected = lastImageRetrieved
                }
            })
        }
    }
    
    
    //MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        DispatchQueue.main.async() {
//            
//            let collectionChanges = changeInstance.changeDetails(for: self.images as! PHFetchResult<UIImage>)
//            if collectionChanges != nil {
//                
//                self.images = collectionChanges!.fetchResultAfterChanges
//                
//                let collectionView = self.collectionView!
//                
//                if !collectionChanges!.hasIncrementalChanges || collectionChanges!.hasMoves {
//                    
//                    collectionView.reloadData()
//                    
//                } else {
//                    
//                    collectionView.performBatchUpdates({
//                        let removedIndexes = collectionChanges!.removedIndexes
//                        if (removedIndexes?.count ?? 0) != 0 {
//                            collectionView.deleteItemsAtIndexPaths(removedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
//                        }
//                        let insertedIndexes = collectionChanges!.insertedIndexes
//                        if (insertedIndexes?.count ?? 0) != 0 {
//                            collectionView.insertItemsAtIndexPaths(insertedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
//                        }
//                        let changedIndexes = collectionChanges!.changedIndexes
//                        if (changedIndexes?.count ?? 0) != 0 {
//                            collectionView.reloadItemsAtIndexPaths(changedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
//                        }
//                        }, completion: nil)
//                }
//                
//                self.resetCachedAssets()
//            }
//        }
    }
}



internal extension UICollectionView {
    
    func aapl_indexPathsForElementsInRect(rect: CGRect) -> [NSIndexPath] {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)
        if (allLayoutAttributes?.count ?? 0) == 0 {return []}
        var indexPaths: [NSIndexPath] = []
        indexPaths.reserveCapacity(allLayoutAttributes!.count)
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath as NSIndexPath)
        }
        return indexPaths
    }
}

internal extension NSIndexSet {
    
    func aapl_indexPathsFromIndexesWithSection(section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        indexPaths.reserveCapacity(self.count)
        self.enumerate({idx, stop in
            indexPaths.append(IndexPath(row: idx, section: section) as NSIndexPath)
        })
        return indexPaths
    }
}

private extension FSAlbumView {
    
    func changeImage(asset: PHAsset) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.imageManager?.requestImage(for: asset,
                                            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                            contentMode: .aspectFill,
                                            options: options) {
                                                result, info in
                                                
            }
        }
    }
    
    // Check the status of authorization for PHPhotoLibrary
    func checkPhotoAuth() {
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .authorized:
                self.imageManager = PHCachingImageManager()
                if self.images != nil && self.images.count > 0 {
                    
                    self.changeImage(asset: self.images[0] as! PHAsset)
                }
                
            case .restricted, .denied:
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.delegate?.albumViewCameraRollUnauthorized()
                    
                })
            default:
                break
            }
        }
    }

    // MARK: - Asset Caching
    
    func resetCachedAssets() {
        
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect()
    }
 
    func updateCachedAssets() {
        
        var preheatRect = self.collectionView!.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        if delta > self.collectionView!.bounds.height / 3.0 {
            
            var addedIndexPaths: [NSIndexPath] = []
            var removedIndexPaths: [NSIndexPath] = []
            
            self.computeDifferenceBetweenRect(oldRect: self.previousPreheatRect, andRect: preheatRect, removedHandler: {removedRect in
                let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(rect: removedRect)
                removedIndexPaths += indexPaths
                }, addedHandler: {addedRect in
                    let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(rect: addedRect)
                    addedIndexPaths += indexPaths
            })
            
            let assetsToStartCaching = self.assetsAtIndexPaths(indexPaths: addedIndexPaths)
            let assetsToStopCaching = self.assetsAtIndexPaths(indexPaths: removedIndexPaths)
            
            self.imageManager?.startCachingImages(for: assetsToStartCaching,
                targetSize: cellSize,
                contentMode: .aspectFill,
                options: nil)
            self.imageManager?.stopCachingImages(for: assetsToStopCaching,
                targetSize: cellSize,
                contentMode: .aspectFill,
                options: nil)
            
            self.previousPreheatRect = preheatRect
        }
    }
    
    func computeDifferenceBetweenRect(oldRect: CGRect, andRect newRect: CGRect, removedHandler: (CGRect)->Void, addedHandler: (CGRect)->Void) {
        if newRect.intersects(oldRect) {
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height:(oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height:(newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    func assetsAtIndexPaths(indexPaths: [NSIndexPath]) -> [PHAsset] {
        if indexPaths.count == 0 { return [] }
        
        var assets: [PHAsset] = []
        assets.reserveCapacity(indexPaths.count)
        for indexPath in indexPaths {
            let asset = self.images[indexPath.item] as! PHAsset
            assets.append(asset)
        }
        return assets
    }
}
