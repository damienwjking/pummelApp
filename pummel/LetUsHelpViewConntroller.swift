//
//  LetUsHelpViewConntroller.swift
//  pummel
//
//  Created by Bear Daddy on 6/27/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit


class LetUsHelpViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var letUsHelpTF : UILabel!
    @IBOutlet var letUsHelpDetailTF : UILabel!
    @IBOutlet var genderTF : UILabel!
    @IBOutlet var genderResultTF: UILabel!
    @IBOutlet var locationTF : UILabel!
    @IBOutlet var locationResultTF: UILabel!
    @IBOutlet var helpMeReachTheCoachBT : UIButton!
    @IBOutlet var toHelpUsWithTF : UILabel!
    
    let TAGS = ["Tech", "Design", "Humor", "Travel", "Music", "Writing", "Social Media", "Life", "Education", "Edtech", "Education Reform", "Photography", "Startup", "Poetry", "Women In Tech", "Female Founders", "Business", "Fiction", "Love", "Food", "Sports"]
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    var sizingCell: TagCell?
    
    var tags = [Tag]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.letUsHelpTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 33)
        self.letUsHelpDetailTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 15)
        self.genderTF.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.genderResultTF.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.locationTF.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.locationResultTF.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.toHelpUsWithTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 15)
        self.helpMeReachTheCoachBT.layer.cornerRadius = 2
        self.helpMeReachTheCoachBT.layer.borderWidth = 0.5
        self.helpMeReachTheCoachBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.helpMeReachTheCoachBT.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.helpMeReachTheCoachBT.backgroundColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "TagCell")
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        for name in TAGS {
            let tag = Tag()
            tag.name = name
            self.tags.append(tag)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    
    @IBAction func closeLetUsHelp(sender:UIButton!) {
        let tabbarVC = self.presentingViewController?.childViewControllers[0] as! BaseTabBarController
        let findVC = tabbarVC.viewControllers![2] as! FindViewController
        findVC.showLetUsHelp = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func goSearching(sender:UIButton!) {
        performSegueWithIdentifier("searching", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "searching")
        {
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCell", forIndexPath: indexPath) as! TagCell
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
        self.collectionView.reloadData()
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        //cell.tagName.textColor = tag.selected ? UIColor.whiteColor() : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
       // cell.backgroundColor = tag.selected ? UIColor(red: 0, green: 1, blue: 0, alpha: 1) : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    }
    
}