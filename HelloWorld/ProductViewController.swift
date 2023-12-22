//
//  ProductViewController.swift
//  HelloWorld
//
//  Created by ABC on 14/12/2023.
//

import UIKit
class ProductViewController: UIViewController {
    
    // MARK: - Properties
    var price: Int = 0
    var orangeMoneyToken = ""
    var waveToken = ""
    
    // MARK: - Outlets
    // View for choosing the payment method
    @IBOutlet weak var chossePayView: UIView!
    
    // MARK: - Actions
    // Action when choosing Orange Money payment
    @IBAction func payWithOM(_ sender: UIButton) {
        Task { @MainActor in
            print("choosed OM payment")
            let orangeMoneyViewController = OrangeMoneyViewController()
            
            // Obtain Orange Money token asynchronously
            orangeMoneyToken =   try await orangeMoneyViewController.getOrangeMoneyToken()
            
            // Perform Orange Money payment using the obtained token
            await orangeMoneyViewController.getOrangeMoneyQrCode(token: orangeMoneyToken, price: price)
        }
    }
    
    // Action when choosing Wave payment
    @IBAction func payWithWave(_ sender: Any){
        print("choosed Wave payment")
        Task { @MainActor in
            let waveViewController = WaveViewController()
            
            // Obtain Wave token asynchronously
            waveToken = try await waveViewController.getWaveToken()
            
            // Perform Wave payment using the obtained token
            try await waveViewController.PerformWavePayment(token: waveToken, price:String(price))
        }
    }
    
    // Action to dismiss the payment method selection view
    @IBAction func dismissPayPopup(_ sender: Any) {
        chossePayView.isHidden = true
    }
    
    // Action when a product is selected for payment
    @IBAction func PerformPayment(_ sender: UIButton) {
        price = sender.tag
        print ("U've selected a product\nWith tag \(price)")
        chossePayView.isHidden = false
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
           super.viewDidLoad()
        chossePayView.isHidden = true
       }
}
