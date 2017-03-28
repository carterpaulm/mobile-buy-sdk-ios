//
//  CartViewController.swift
//  Storefront
//
//  Created by Shopify.
//  Copyright (c) 2017 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

class CartViewController: ParallaxViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private var totalsViewController: TotalsViewController!
    
    // ----------------------------------
    //  MARK: - Segue -
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier! {
        case "TotalsViewController":
            self.totalsViewController = segue.destination as! TotalsViewController
        default:
            break
        }
    }
    
    // ----------------------------------
    //  MARK: - View Loading -
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureParallax()
        self.configureTableView()
        
        self.updateSubtotal()
    }
    
    private func configureParallax() {
        self.layout       = .headerAbove
        self.headerHeight = self.view.bounds.width * 0.5 // 2:1 ratio
        self.multiplier   = 0.0
    }
    
    private func configureTableView() {
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.register(UINib(nibName: "CartCell", bundle: nil), forCellReuseIdentifier: "CartCell")
    }
    
    // ----------------------------------
    //  MARK: - Update -
    //
    func updateSubtotal() {
        self.totalsViewController.subtotal  = CartController.shared.subtotal
        self.totalsViewController.itemCount = CartController.shared.itemCount
    }
}

// ----------------------------------
//  MARK: - Actions -
//
extension CartViewController {
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// ----------------------------------
//  MARK: - CartCellDelegate -
//
extension CartViewController: CartCellDelegate {
    
    func cartCell(_ cell: CartCell, didUpdateQuantity quantity: Int) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            let cartItem  = CartController.shared.items[indexPath.row]
            
            if quantity != cartItem.quantity {
                cartItem.quantity = quantity
                
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
            }
            
            self.updateSubtotal()
        }
    }
}

// ----------------------------------
//  MARK: - UITableViewDataSource -
//
extension CartViewController: UITableViewDataSource {
    
    // ----------------------------------
    //  MARK: - Data -
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CartController.shared.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell     = tableView.dequeueReusableCell(withIdentifier: CartCell.className, for: indexPath) as! CartCell
        let cartItem = CartController.shared.items[indexPath.row]
        
        cell.delegate = self
        cell.configureFrom(cartItem.viewModel)
        
        return cell
    }
}

// ----------------------------------
//  MARK: - UITableViewDelegate -
//
extension CartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateParallax()
    }
}