//
//  File.swift
//  HelloWorld
//
//  Created by ABC on 20/12/2023.
//

import UIKit
class OrangeMoneyViewController: UIViewController{
    var token = ""
    var baseUrl = "https://api.sandbox.orange-sonatel.com/"
    
    struct OrangeMoneyTokenRequestBody: Codable{
        var  grant_type = "client_credentials"
        var client_secret = "1e639e99-6d0e-432e-9757-9473065e6802"
        var client_id = "8ed1efda-1bcb-428e-9df2-352312efe5ad"
    }
    
    struct OrangeMoneyCheckoutResponse: Codable{
        var access_token: String
    }
    
    func getOrangeMoneyToken() async -> String{
        var access_token = ""
        let endpoint = "oauth/token"
      await   Task { @MainActor in
            guard let url = URL(string: baseUrl + endpoint) else {throw TypeError.invalidURL}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name:"grant_type", value: "client_credentials"),
                URLQueryItem(name:"client_secret", value: "1e639e99-6d0e-432e-9757-9473065e6802"),
                URLQueryItem(name:"client_id", value: "8ed1efda-1bcb-428e-9df2-352312efe5ad")
            ]
          //  request.setValue("No Auth", forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let (data,response) = try await URLSession.shared.data(for: request)
//            print(requestBodyComponents)
//            print(String(data: data, encoding: .utf8))
//            print ("Request Response :\(response)")
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                print("Invalid response body")
                throw TypeError.invalidResponse
            }
            do{
                let decoder = JSONDecoder()
                //  decoder.keyDecodingStrategy = .convertFromSnakeCase //purhaps won't need it
//                print("********************RETRIEVED token is ")
//                print(String(data: data, encoding: .utf8) ?? "None")
                let decodedData = try decoder.decode(OrangeMoneyCheckoutResponse.self, from: data)
//                print("trying to print gettoken response .... \n \(decodedData)")
    //         print(decodedData)
              access_token =  decodedData.access_token
            //    print(access_token)
                return access_token
            } catch let error as DecodingError{
                print("invalid data .....",error)
                throw TypeError.invalidData
            }
        }
        return  access_token
    }
    
    enum TypeError: Error{
        case invalidURL
        case invalidResponse
        case invalidData
    }
}

