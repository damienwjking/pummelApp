//
//  BookSessionViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class BookSessionViewController: BaseViewController {
    
    @IBOutlet weak var tbView: UITableView!
    var tags = [TagModel]()
    var tagOffset: Int = 0
    var tagSelect:TagModel?
    
    var isStopLoadTag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        let nibName = UINib(nibName: "BookSessionTableViewCell", bundle:nil)
        self.tbView.register(nibName, forCellReuseIdentifier: "BookSessionTableViewCell")
    
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButtonClicked))
        
        self.getListTags()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kBookSession
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = " "
    }
    
    // MARK: Private function
    func getListTags() {
        if (isStopLoadTag == false) {
            TagRouter.getTagList(offset: self.tagOffset, completed: { (result, error) in
                if (error == nil) {
                    let tagList = result as! [TagModel]
                    
                    if (tagList.count == 0) {
                        self.isStopLoadTag = true
                    } else {
                        for tag in tagList {
                            if (tag.existInList(tagList: self.tags) == false) {
                                self.tags.append(tag)
                            }
                        }
                        
                        self.tagOffset += 10
                        self.tbView.reloadData()
                    }
                    
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.isStopLoadTag = true
                }
            }).fetchdata()
        }
    }
    
    func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectUser" {
            let destination = segue.destination as! BookSessionSelectUserViewController
            destination.tag = tagSelect
        }
    }
}

// MARK: - UITableViewDelegate
extension BookSessionViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookSessionTableViewCell") as! BookSessionTableViewCell
        
        let tag = tags[indexPath.row]
        
        let tagName = tag.name?.uppercased()
        cell.bookTitleLB.text = tagName
        cell.statusIMV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
        
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let tag = tags[indexPath.row]
        tagSelect = tag
        self.performSegue(withIdentifier: "selectUser", sender: nil)
    }
}

