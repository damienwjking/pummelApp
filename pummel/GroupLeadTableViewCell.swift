//
//  GroupLeadTableViewCell.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class GroupLeadTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var titleHeader: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        //layout.estimatedItemSize =  CGSize(width: 70, height: 70)
        self.cv.dataSource = self
        self.cv.delegate = self
        let nibName = UINib(nibName: "LeadCollectionViewCell" , bundle:nil)
        self.cv.registerNib(nibName, forCellWithReuseIdentifier: "LeadCollectionViewCell")
        self.cv.collectionViewLayout = layout
        self.cv.reloadData()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LeadCollectionViewCell", forIndexPath: indexPath) as! LeadCollectionViewCell
        return cell
    }
}
