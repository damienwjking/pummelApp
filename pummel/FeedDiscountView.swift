//
//  FeedDiscountView.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 6/12/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

@objc protocol FeedDiscountViewDelegate {
    func goToDetailDiscount(discountDetail: NSDictionary)
    func loadMoreDiscount()
}

class FeedDiscountView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var cv: UICollectionView!
    var cvLayout: UICollectionViewFlowLayout!
    var arrayResult : [NSDictionary] = [] {
        didSet {
            self.cv.reloadData()
        }
    }
    var widthCell : CGFloat = 0.0
    weak var delegate : FeedDiscountViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.widthCell = (self.bounds.size.width - 50)
        
        
        self.cvLayout = UICollectionViewFlowLayout()
        self.cvLayout.itemSize = CGSize(width: (self.bounds.size.width - 50), height: self.bounds.height)
        self.cvLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 0)
        self.cvLayout.minimumLineSpacing = 10
        self.cvLayout.scrollDirection = .Horizontal
        
        self.cv = UICollectionView.init(frame: self.bounds, collectionViewLayout: self.cvLayout)
        let nibName = UINib(nibName: "DiscountColectionViewCell", bundle: nil)
        self.cv.register(nibName, forCellWithReuseIdentifier: "DiscountColectionViewCell")
        self.cv.delegate = self
        self.cv.dataSource = self
        self.cv.isScrollEnabled = false
        self.cv.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.addSubview(self.cv)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DiscountColectionViewCell", for: indexPath) as! DiscountColectionViewCell
        
        // add Swipe gesture
        if cell.gestureRecognizers?.count < 2 {
            
            let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeLeft))
            swipeLeftGesture.direction = .Left
            cell.addGestureRecognizer(swipeLeftGesture)
            
            let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeRight))
            swipeRightGesture.direction = .Right
            cell.addGestureRecognizer(swipeRightGesture)
        }
        
        if indexPath.row >= self.arrayResult.count {
            return cell
        }
        
        let discountDetail = self.arrayResult[indexPath.row]
        cell.setData(discountDetail)
        
        if indexPath.row == self.arrayResult.count - 1 {
            self.delegate?.loadMoreDiscount()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cvLayout.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= self.arrayResult.count {
            return
        }
        
        let discountDetail = self.arrayResult[indexPath.row]
        self.delegate?.goToDetailDiscount(discountDetail)
    }
    
    func endPagingCarousel(scrollView: UIScrollView) {
        if scrollView == self.cv {
            // custom pageing
            var point = scrollView.contentOffset
            point.x = self.widthCell * CGFloat(Int(round((point.x / self.widthCell))))
            
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
    func carouselSwipeLeft() {
        var offsetX = self.cv.contentOffset.x + self.widthCell
        offsetX = offsetX > self.cv.contentSize.width - self.widthCell ? self.cv.contentSize.width - self.widthCell : offsetX
        
        let newContentOffset = CGPointMake(offsetX, 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.cv.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(self.cv)
        }
    }
    
    func carouselSwipeRight() {
        var offsetX = self.cv.contentOffset.x - self.widthCell
        offsetX = offsetX < 0 ? 0 : offsetX
        
        let newContentOffset = CGPointMake(offsetX, 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.cv.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(self.cv)
        }
    }
}
