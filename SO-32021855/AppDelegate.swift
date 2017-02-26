//
//  AppDelegate.swift
//  SO-32021855
//
//  Copyright © 2017 Xavier Schott
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
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MixpanelDelegate, SKPaymentTransactionObserver {

    var window: UIWindow?

    //MARK: MixpanelDelegate
    func mixpanelWillFlush(_ mixpanel: Mixpanel) -> Bool {
        let isOnWiFi = true // Use reachability to make an educated guess
        return isOnWiFi
    }

    //MARK: Process and report
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transation in transactions {
            switch transation.transactionState {

            case .purchased:
                queue.finishTransaction(transation)
                // Track here...

                Mixpanel.sharedInstance().track("Purchased",
                                                properties: ["productIdentifier":transation.payment.productIdentifier])
            case .purchasing: break
            case .restored: break
            case .deferred: break
            case .failed: break
            }
        }
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let mixpanel = Mixpanel.sharedInstance(withToken: "apiToken")
        mixpanel.delegate = self
        return true
    }

    func track(transaction: SKPaymentTransaction) {
        if let url = URL(string: "https://<yoursite>/php/purchase.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = "{\"itemName\":\"\(transaction.payment.productIdentifier)\"}"
                .data(using: .utf8)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let task = URLSession.shared.dataTask(with: request as URLRequest,
                                                  completionHandler: {_,_,_ in })
            task.resume()
        }
    }}

