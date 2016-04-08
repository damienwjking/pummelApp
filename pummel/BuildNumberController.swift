//
//  BuildNumberController.swift
//  pummel
//
//  Created by ThongNguyen on 4/8/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation
import UIKit
class BuildNumberViewController: UIViewController {
    
    @IBOutlet weak var version: UILabel!

    @IBOutlet weak var region: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.version.text = self.getVersion()
        self.region.text = self.getRegion()
    }
    func getVersion() -> String {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "no version info"
    }
    
    func getRegion() -> String {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            return version
        }
        return "no build number"
    }
}
