//
//  BookAndBuyViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/24/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class BookAndBuyViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    
    var productList: [ProductModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupTableView()
    }

    func setupNavigationBar() {
        // Titlte
        self.navigationItem.title = kNavBookBuy
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.isTranslucent = false;
        
        // Left button
        let closeImage = UIImage(named: "close")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(self.leftBarButtonClicked(_:)))
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func setupTableView() {
        let cellNib1 = UINib.init(nibName: "ProductUserCell", bundle: nil)
        self.tableView.register(cellNib1, forCellReuseIdentifier: "ProductUserCell")
        
        let cellNib2 = UINib.init(nibName: "BookAndBuyCell", bundle: nil)
        self.tableView.register(cellNib2, forCellReuseIdentifier: "BookAndBuyCell")
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.separatorStyle = .none
    }
    
    func leftBarButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getProduct() {
        
    }
}

// MARK: - UITableViewDelegate
extension BookAndBuyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productList.count + 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductUserCell") as! ProductUserCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookAndBuyCell") as! BookAndBuyCell
            
            //        let product = self.productList[indexPath.row - 1]
            //        cell.setupData(product: product)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goPurchaseDetail", sender: nil)
    }
    
}
