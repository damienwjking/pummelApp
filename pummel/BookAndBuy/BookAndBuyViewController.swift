//
//  BookAndBuyViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/24/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class BookAndBuyViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var coachID = ""
    var productOffset = 0
    var isStopGetProduct = false
    var productList: [ProductModel] = []
    
    var productBought: ProductModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.productBought == nil) {
            self.getProduct()
        } else {
            self.performSegue(withIdentifier: "goPurchaseDetail", sender: self.productBought)
        }
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
        
        // Right button
        self.navigationItem.rightBarButtonItem = nil
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
        if (self.isStopGetProduct == false) {
            if (self.productOffset == 0) {
                self.view.makeToastActivity()
            }
            
            ProductRouter.getProductList(userID: self.coachID, offset: self.productOffset) { (result, error) in
                self.view.hideToastActivity()
                
                if (error == nil) {
                    let productList = result as! [ProductModel]
                    
                    if (productList.count == 0) {
                        self.isStopGetProduct = true
                    } else {
                        for product in productList {
                            if (product.existInList(productList: self.productList) == false) {
                                product.checkIsPurchase()
                                
                                self.productList.append(product)
                            }
                        }
                    }
                    
                    self.productOffset = self.productOffset + 20
                    self.tableView.reloadData()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.isStopGetProduct = true
                }
                }.fetchdata()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goPurchaseDetail") {
            let product: ProductModel = sender as! ProductModel
            let destination = segue.destination as! ProductDetailViewController
            
            destination.product = product
        }
    }
    
}

// MARK: - UITableViewDelegate
extension BookAndBuyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.productBought != nil) {
            return 0
        }
        
        return self.productList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductUserCell") as! ProductUserCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookAndBuyCell") as! BookAndBuyCell
            
            let product = self.productList[indexPath.row - 1]
            cell.setupData(product: product)
            cell.delegate = self
            
            return cell
        }
    }
    
}

extension BookAndBuyViewController: BookAndBuyCellDelegate {
    func bookAndBuyBuyNowButtonClicked(cell: BookAndBuyCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        
        if (indexPath != nil) {
            let product = self.productList[(indexPath?.row)! - 1]
            
            self.performSegue(withIdentifier: "goPurchaseDetail", sender: product)
        }
    }
}
