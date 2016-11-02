//
//  NaviUtilityLazyLoad.swift
//  pummel
//
//  Created by Bear Daddy on 8/26/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation

class NaviUtilityLazyLoad
{
    var currentCursor: Int = -1
    var enabled: Bool = true
    var pageSize: Int = -1
    
    init()
    {}
    
    init(withPageSize pSize: Int, andEnabled isEnabled: Bool)
    {
        self.pageSize = pSize
        self.enabled = isEnabled
    }
    
    func nextCursor() -> Int
    {
        if !self.enabled { return -1 }
        
        switch currentCursor
        {
        case -1:
            currentCursor = 0
            break
        case 0:
            currentCursor = self.pageSize
            break
        default:
            currentCursor += pageSize
        }
        return currentCursor
    }
    
    func resetCursor()
    {
        currentCursor = -1
    }
}
