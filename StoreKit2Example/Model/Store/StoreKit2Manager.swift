//
//  StoreKit2Manager.swift
//  StoreKit2Example
//
//  Created by Leo Ho on 2023/3/2.
//

import Foundation
import StoreKit // StoreKit 2

@MainActor class StoreKit2Manager: NSObject {
    
    /// 產品 ID
    private let productID: [String] = ["test.com.storekit2example.auto.renew.subscription.yearly"]
    
    /// 產品陣列
    private var products: [Product] = []
    
    /// 已購買的產品 ID
    private var purchasedProductID: Set<String> = []
    
    /// 是否已經撈取完所有產品
    private var isLoadProducts: Bool = false
    
    private var updates: Task<Void, Never>? = nil
    
    override init() {
        super.init()
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
}

extension StoreKit2Manager {
    
    /// 撈取產品
    func fetchProducts() async throws -> [Product] {
        guard !isLoadProducts else {
            return []
        }
        let products = try await Product.products(for: productID)
        await MainActor.run {
            self.products = products
        }
        print(self.products)
        self.isLoadProducts = true
        return products
    }
    
    /// 購買產品
    func purchaseProducts() async throws {
        guard let product = self.products.first else {
            return
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verificationResult):
            switch verificationResult {
            case .unverified(let signedType, let verificationResult):
                break
            case .verified(let transaction):
                await transaction.finish()
                await updatePurchasedProducts()
                print("購買成功！")
            }
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            fatalError()
        }
    }
    
    /// 回復購買
    func restorePurchaseProducts() async throws {
        try await AppStore.sync()
    }
    
    /// 更新已購買的產品
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            if transaction.revocationDate == nil {
                purchasedProductID.insert(transaction.productID)
            } else {
                purchasedProductID.remove(transaction.productID)
            }
        }
    }
    
    /// 監聽交易更新狀態
    private func observeTransactionUpdates() -> Task<Void, Never> {
        return Task.detached {
            for await verificationResult in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                switch verificationResult {
                case .unverified(_, _):
                    <#code#>
                case .verified(_):
                    <#code#>
                }
                await self.updatePurchasedProducts()
            }
        }
    }
}
