//
//  PummelWebViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 3/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class PummelWebViewController: UIViewController, UIWebViewDelegate {
    var URL : URL? = nil
    var isShowProduct = false
    var closeButton:UIButton? = nil
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadWeb()
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        // Title
        if (self.isShowProduct == true) {
            self.title = ""
        } else {
            self.title = kNavFeed
        }
        
        // Left button
        let image = UIImage(named: "back")!.withRenderingMode(.alwaysTemplate)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.backButtonClicked))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadWeb() {
        if (self.URL != nil) {
            let request = URLRequest(url: self.URL! as URL)
            self.webView.loadRequest(request)
        }
    }
    
    func backButtonClicked() {
        if (self.isShowProduct == true) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}
