//
//  ProductViewController.swift
//  HelloWorld
//
//  Created by ABC on 14/12/2023.
//

import UIKit
class ProductViewController: UIViewController {
    var price: Int = 0

    @IBOutlet weak var chossePayView: UIView!
    @IBAction func payWithOM(_ sender: UIButton) {
        Task { @MainActor in
            print("choosed OM payment")
            let oc = OrangeMoneyViewController()
            // oc.getOrangeMoneyToken()
            print("RETRIEVED TOKEN IS ********************")
            await print( oc.getOrangeMoneyToken() )
        }
    }
    @IBAction func payWithWave(_ sender: Any) {
        print("choosed Wave payment")
                let endpoint = "https://api.wave.com/v1/checkout/sessions"
        Task { @MainActor in

                           let endpoint = "https://api.wave.com/v1/checkout/sessions"
                           guard let url = URL(string: endpoint) else {throw MyError.invalidURL}
                         var request = URLRequest(url: url)
                         request.httpMethod = "POST"
                         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                request.setValue("Bearer wave_sn_prod_KF7S-TZu5rF789Hj3pw_1M0xx28B32olssB-vJi88kBr_P2YA71hnQy6Ta7ZaxMJEy1JWR9WK3oXTewzVbqw8Ysmwr8wlG5QQA", forHTTPHeaderField: "Authorization")
                         let requestBody: CheckoutRequestBody = CheckoutRequestBody(amount: "\(price)")
                         do {
                                    let jsonData = try JSONEncoder().encode(requestBody)
                                    request.httpBody = jsonData
                                } catch {
                                    throw MyError.invalidData
                                }
                           let (data,response) = try await URLSession.shared.data(for: request)
                           print ("Request Response :\(response)")
                           guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                               throw MyError.invalidResponse
                           }
                           do{
                               let decoder = JSONDecoder()
                             //  decoder.keyDecodingStrategy = .convertFromSnakeCase //purhaps won't need it
                               print("RETRIEVED DATA is ")
                               print(String(data: data, encoding: .utf8))
                               let decodedData = try decoder.decode(WaveCheckoutResponse.self, from: data)
                               print("trying to print data response .... \n \(decodedData)")
                               if let waveLaunchURL = URL(string: decodedData.wave_launch_url) {
                                   await UIApplication.shared.open(waveLaunchURL)
                                           } else {
                                               print("Invalid wave_launch_url")
                                           }
                               return decodedData
                           } catch let error as DecodingError{
                               print("invalid data .....",error)
                               throw MyError.invalidData
                           }
                     
                       }
    }
    @IBAction func dismissPayPopup(_ sender: Any) {
        chossePayView.isHidden = true
    }
    struct CheckoutRequestBody: Codable{
             let amount : String
        var currency =  "XOF"
        var error_url =  "https://example.com/error"
        var success_url = "https://example.com/success"
         }
         struct WaveCheckoutResponse:Codable {
             let id: String
             let amount: String
             let checkout_status: String
             let client_reference : String?
             let currency : String
             let error_url : String
             let last_payment_error : String?
             let business_name : String
             let payment_status: String
             let success_url: String
             let wave_launch_url: String
             let when_completed: String?
             let when_created : String
             let when_expires: String
         }
    override func viewDidLoad() {

           super.viewDidLoad()
        chossePayView.isHidden = true
         //  print("productView ready")
       //   self.view.backgroundColor = .systemBlue
           // Do any additional setup after loading the view.
       }
    @IBAction func PerformPayment(_ sender: UIButton) {
        price = sender.tag
        print ("U've selected a product\nWith tag \(price)")

        chossePayView.isHidden = false
              }
              


enum MyError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
}
}
