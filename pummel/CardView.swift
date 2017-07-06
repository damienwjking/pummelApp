//
//  CardView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/24/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

@objc public protocol CardViewDelegate {
    func cardViewTagClicked()
}

class CardView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
   
    @IBOutlet var connectV : UIView!
    @IBOutlet var nameLB: UILabel!
    @IBOutlet var addressLB: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    @IBOutlet weak var avatarIMV : UIImageView!
    @IBOutlet weak var businessIMV : UIImageView!
    
    weak var delegate : CardViewDelegate? = nil
    var tags = [Tag]()
    var sizingCell: TagCell?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        // Shadow
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSizeMake(0, 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = SCREEN_SCALE
    }
    
    func registerTagCell() {
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        let cellNib = UINib(nibName: kTagCell, bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: kTagCell)
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTagCell, forIndexPath: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        return self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        collectionView.reloadData()
        
        if self.delegate != nil {
            self.delegate?.cardViewTagClicked()
        }
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagName.textColor = UIColor.blackColor()
        cell.layer.borderColor = UIColor.clearColor().CGColor
    }
}
