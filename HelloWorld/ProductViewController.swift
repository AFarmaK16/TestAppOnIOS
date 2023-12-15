//
//  ProductViewController.swift
//  HelloWorld
//
//  Created by ABC on 14/12/2023.
//

import UIKit
class ProductViewController: UIViewController {
    
    
    @IBAction func PerformPayment(_ sender: UIButton) {
        print ("U've selected a product")
        print ("With tag \(sender.tag)")
    }
    
    
    //    let wave_Auth_token = "A"
         
 //        struct CheckoutRequestBody{
 //            let amount : String
 //            let currency =  "XOF"
 //            let error_url =  "https://example.com/error"
 //          let success_url = "https://example.com/success"
 //        }
 //        struct WaveCheckoutResponse:Codable {
 //            let id: String
 //            let amount: String
 //            let checkout_status: String
 //            let client_reference : String
 //            let currency : String
 //            let error_url : String
 //            let last_payment_error : String
 //            let business_name : String
 //            let payment_status: String
 //            let success_url: String
 //            let wave_launch_url: String
 //            let when_completed: String
 //            let when_created : String
 //            let when_expires: String
 //        }
    override func viewDidLoad() {

           super.viewDidLoad()
         //  print("productView ready")
       //   self.view.backgroundColor = .systemBlue
           // Do any additional setup after loading the view.
       }

}
