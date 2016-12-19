//
//  SessionClientViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import AlamofireImage

class SessionClientViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    // MARK: Init
    func initTableView() {
        self.logTableView.estimatedRowHeight = 120
    }
    
    // MARK: UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogComingTableViewCell") as! LogComingTableViewCell
        
        cell.nameLB.text = "Sarah"
        cell.messageLB.text = "TUE 19th DEC"
        cell.timeLB.text = "4PM"
        
        let prefix = "http://api.pummel.fit/api/uploads/235/render?width=125.0&height=125.0"
        if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
            let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
            cell.avatarIMV.image = imageRes
        } else {
            Alamofire.request(.GET, prefix)
                .responseImage { response in
                    if (response.response?.statusCode == 200) {
                        let imageRes = response.result.value! as UIImage
                        cell.avatarIMV.image = imageRes
                    }
            }
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
