//
//  ProductsViewController.swift
//  StoreKit2Example
//
//  Created by Leo Ho on 2023/3/2.
//

import UIKit
import StoreKit

class ProductsViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tvProducts: UITableView!
    
    // MARK: - Variables
    
    var storeManager = StoreKit2Manager()
    
    private var products: [Product] = []
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        setupTableView()
        setupNavigationBarButtonItems()
    }
    
    private func setupTableView() {
        tvProducts.delegate = self
        tvProducts.dataSource = self
        tvProducts.register(UINib(nibName: "ProductsTableViewCell", bundle: nil),
                            forCellReuseIdentifier: ProductsTableViewCell.identifier)
    }
    
    private func setupNavigationBarButtonItems() {
        let optionMenu = createSubscriptionMenu()
        let optionItem = UIBarButtonItem(title: "訂閱選項", menu: optionMenu)
        self.navigationItem.leftBarButtonItems = [optionItem]
        
        let restorePurchaseItem = UIBarButtonItem(title: "恢復購買",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(restorePurchase))
        self.navigationItem.rightBarButtonItems = [restorePurchaseItem]
    }
    
    // MARK: - Function
    
    private func fetchProducts() {
        Task {
            do {
                self.products = try await storeManager.fetchProducts()
                await MainActor.run {
                    self.tvProducts.reloadData()
                }
            } catch {
                print("Fetch Products Failed，Error：",error)
            }
        }
    }
    
    @objc func restorePurchase() {
        Task {
            do {
                try await storeManager.restorePurchaseProducts()
            } catch {
                print("Restore Products Failed，Error：",error)
            }
        }
    }
    
    private func createSubscriptionMenu() -> UIMenu {
        return UIMenu(children: [
            UIAction(title: "查看 App Store 訂閱狀態") { _ in
                if let window = UIApplication.shared.connectedScenes.first {
                    Task {
                        do {
                            try await AppStore.showManageSubscriptions(in: window as! UIWindowScene)
                            print("deviceVerificationID：", String(describing: AppStore.deviceVerificationID))
                            if #available(iOS 16.0, *) {
                                try? await print("jwsRepresentation：", AppTransaction.shared.jwsRepresentation)
                            }
                        } catch {
                            print("查看 App Store 訂閱狀態 Failed，Error：",error)
                        }
                    }
                }
            },
        ])
    }
    
    // MARK: - IBAction
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ProductsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductsTableViewCell.identifier,
                                                       for: indexPath) as? ProductsTableViewCell else {
            fatalError("ProductsTableViewCell Load Failed！")
        }
        cell.setInit(productName: products[indexPath.row].displayName,
                     productPrice: products[indexPath.row].displayPrice,
                     delegate: self)
        return cell
    }
    
    // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - ProductTableViewCellDelegate

extension ProductsViewController: ProductTableViewCellDelegate {
    
    func btnPurchaseClicked() {
        Task {
            do {
                try await storeManager.purchaseProducts()
            } catch {
                print("Purchase Product Failed，Error：",error)
            }
        }
    }
}

// MARK: - Protocol


