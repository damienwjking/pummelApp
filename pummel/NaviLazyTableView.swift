//
//  NaviLazyTableView.swift
//  pummel
//
//  Created by Bear Daddy on 8/26/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

@objc protocol NaviLazyTableViewDelegate
{
    optional func tableView(tableView: UITableView, lazyLoadNextCursor cursor: Int)
}

class NaviLazyTableView: UITableView, UITableViewDelegate
{
    var lazyLoadEnabled: Bool!
    var lazyLoadPageSize: Int!
    var currentCursor: Int!
    var lazyLoad: NaviUtilityLazyLoad = NaviUtilityLazyLoad()
    override var delegate: UITableViewDelegate?
        {
        didSet
        {
            super.delegate = self
        }
        
        willSet
        {
            self.senderDelegate = newValue as? NaviLazyTableViewDelegate
        }
    }
    private var senderDelegate: NaviLazyTableViewDelegate?
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        super.delegate = self
    }
    
    override init(frame: CGRect, style: UITableViewStyle)
    {
        super.init(frame: frame, style: style)
        super.delegate = self
    }
    
    // MARK: UITableView UIScrollView Override
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        let endScrolling: CGFloat = scrollView.contentOffset.y + scrollView.frame.size.height
        
        if (endScrolling >= scrollView.contentSize.height)
        {
            self.senderDelegate?.tableView?(self, lazyLoadNextCursor: self.lazyLoad.nextCursor())
            currentCursor = self.lazyLoad.currentCursor
        }
    }
}