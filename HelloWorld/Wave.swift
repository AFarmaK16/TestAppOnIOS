//
//  Wave.swift
//  HelloWorld
//
//  Created by ABC on 20/12/2023.
//

import UIKit
class WaveViewController: UIViewController {
    // Declare the base url for performing the request
    var payementGateWayUrl = "https://api.wave.com/v1/checkout/sessions"
    let tokenGateWayUrl = "https://api-service.work/api/payment-gateway-list"
    // MARK: - Structs
    
    // Structure for the request body when performing a Wave payment
    struct WaveCheckoutRequestBody: Codable {
        let amount: String
        var currency =  "XOF"
        var error_url =  "https://example.com/error"
        var success_url = "https://example.com/success"
    }
    
    struct PaymentGatewayInfo: Codable {
        let version: String
        let result: String
        let message: String
        let data: [PaymentGatewayData]
    }

    struct PaymentGatewayData: Codable {
        let paymentGatewayProvider: String?
        let data: GatewayData
    }

    struct GatewayData: Codable {
        let apiSecretKey: String?
        let apiPublicKey: String?
        let authToken: String
        let tokenizationUrl: String
        let paymentRedirectUrl: String
        let callbackUrl: String
        let gatewayCondition: Int
        let paymentStep: Int
        let additionalData: String
    }

    // Structure for the response when performing a Wave payment
    struct WaveCheckoutResponse: Codable {
        let id: String
        let amount: String
        let checkout_status: String
        let client_reference: String?
        let currency: String
        let error_url: String
        let last_payment_error: String?
        let business_name: String
        let payment_status: String
        let success_url: String
        let wave_launch_url: String
        let when_completed: String?
        let when_created: String
        let when_expires: String
    }
    
    // MARK: - Functions
    
    func getWaveToken() async throws -> String {
        var access_token = ""
        guard let url = URL(string: tokenGateWayUrl) else { throw ErrorType.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Prepare the request body for token retrieval
 
     //   request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("CRGxQinAKFOv5mu3HPoLrT6BjE1tws", forHTTPHeaderField: "publicKey")
      request.setValue("tRA3T64GSYPCir8ZQnw7p9jvuWlVI5", forHTTPHeaderField: "secretKey")
      request.setValue("en", forHTTPHeaderField: "locale")
 
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print(request)
        
        // Check the response status
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Invalid response body")
            throw ErrorType.invalidResponse
        }
        
        do {
            // Decode the response data to obtain the access token
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(PaymentGatewayInfo.self, from: data)
            access_token = decodedData.data.first?.data.authToken ?? ""
            return access_token
        } catch let error as DecodingError {
            print("Invalid data...", error)
            throw ErrorType.invalidData
        }
    }
    
    // Function to perform a Wave payment asynchronously
    func PerformWavePayment(token: String, price: String) async throws{
        
        // Create the URL for the Wave payment endpoint
        guard let url = URL(string: payementGateWayUrl) else { throw ErrorType.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers for the request
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        // Create the request body with the specified price
        let requestBody: WaveCheckoutRequestBody = WaveCheckoutRequestBody(amount: "\(price)")
        
        do {
            // Encode the request body and set it to the request
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            throw ErrorType.invalidData
        }
        
        // Send the request and retrieve the response
        let (data, response) = try await URLSession.shared.data(for: request)
        print("Request Response :\(response)")
        
        // Check the response status
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ErrorType.invalidResponse
        }
        
        do {
            // Decode the response data to obtain the Wave launch URL
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(WaveCheckoutResponse.self, from: data)
            
            // Open the Wave launch URL
            if let waveLaunchURL = URL(string: decodedData.wave_launch_url) {
                await UIApplication.shared.open(waveLaunchURL)
            } else {
                print("Invalid wave_launch_url")
            }
        } catch let error as DecodingError {
            print("Invalid data ...", error)
            throw ErrorType.invalidData
        }
    }
    
    // MARK: - Error Enum
    
    // Enum for representing different error types
    enum ErrorType: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
}
