//
//  PMHelper.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/12/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Foundation


class PMHeler {
    class func checkVisibleCell(tableView: UITableView, indexPath: NSIndexPath ) -> Bool {
        var visibleCell = false
        for indexP in (tableView.indexPathsForVisibleRows)! {
            if (indexP.row == indexPath.row &&
                indexP.section == indexPath.section) {
                visibleCell = true
                break
            }
        }
        
        return visibleCell
    }
}
