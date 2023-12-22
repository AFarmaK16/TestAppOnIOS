//
//  File.swift
//  HelloWorld
//
//  Created by ABC on 20/12/2023.
//

import UIKit
class OrangeMoneyViewController: UIViewController {
    
    // Declare the base url for performing api request
    var baseUrl = "https://api.sandbox.orange-sonatel.com/"
    
    // MARK: - Structs
    
    // Structure for the request body to obtain Orange Money token
    struct OrangeMoneyTokenRequestBody: Codable {
        var  grant_type = "client_credentials"
        var client_secret = "1e639e99-6d0e-432e-9757-9473065e6802"
        var client_id = "8ed1efda-1bcb-428e-9df2-352312efe5ad"
    }
    
    // Structure for the response when obtaining the Orange Money token
    struct OrangeMoneyCheckoutResponse: Codable {
        var access_token: String
    }
    
    // Structure for the request body when generating Orange Money QR code
    struct OrangeMoneyQRCodeRequestBody: Codable {
        struct Amount: Codable {
            let unit: String
            let value: Int
        }
        
        let amount: Amount
        let callbackCancelUrl: String
        let callbackSuccessUrl: String
        let code: Int
        let metadata: [String: String]?
        let name: String
        let validity: Int
    }
    
    // Structure for the response when generating Orange Money QR code
    struct OrangeMoneyQRCodeRequestResponse: Codable {
        let deepLink: String
        let deepLinks: [String: String]
        let qrCode: String
        let validity: Int
        let metadata: [String: String]?
        let shortLink: String
        let qrId: String
    }
    
    // MARK: - Functions
    
    // Function to get the Orange Money token asynchronously
    func getOrangeMoneyToken() async throws -> String {
        var access_token = ""
        let endpoint = "oauth/token"
        guard let url = URL(string: baseUrl + endpoint) else { throw TypeError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Prepare the request body for token retrieval
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "client_credentials"),
            URLQueryItem(name: "client_secret", value: "e2a2a182-bbbf-4f48-87ad-c9fcb7b1a370"),
            URLQueryItem(name: "client_id", value: "4e0d8e4f-3f4a-4347-9b70-87f479b08def")
        ]
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check the response status
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Invalid response body")
            throw TypeError.invalidResponse
        }
        
        do {
            // Decode the response data to obtain the access token
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(OrangeMoneyCheckoutResponse.self, from: data)
            access_token = decodedData.access_token
            return access_token
        } catch let error as DecodingError {
            print("Invalid data...", error)
            throw TypeError.invalidData
        }
    }
    
    // Function to get the Orange Money QR code asynchronously
    func getOrangeMoneyQrCode(token: String, price: Int) async {
        let urlString = baseUrl + "api/eWallet/v4/qrcode"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // Prepare the request for generating the QR code
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        let requestAmountBody = OrangeMoneyQRCodeRequestBody.Amount(unit: "XOF", value: price)
        let requestBody: OrangeMoneyQRCodeRequestBody = OrangeMoneyQRCodeRequestBody(
            amount: requestAmountBody,
            callbackCancelUrl: "https://my-cancel-url.com",
            callbackSuccessUrl: "https://ciao.sn/",
            code: 497157,
            metadata: nil,
            name: "KWINGO SARL API",
            validity: 30
        )
        
        do {
            // Encode the request body and send the request
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check the response status
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw TypeError.invalidResponse
            }
            
            do {
                // Decode the response data to obtain the QR code information
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(OrangeMoneyQRCodeRequestResponse.self, from: data)
                
                // Open the Orange Money deep link
                if let orangeMoneyLaunchURL = URL(string: decodedData.deepLink) {
                    await UIApplication.shared.open(orangeMoneyLaunchURL)
                } else {
                    print("Invalid OrangeMoney_launch_url")
                }
            } catch let error as DecodingError {
                print("Invalid data...", error)
                throw TypeError.invalidData
            }
        } catch {
            print("Error encoding request body: \(error)")
            return
        }
    }
    
    // MARK: - Error Enum
    
    // Enum for representing different error types
    enum TypeError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
}

