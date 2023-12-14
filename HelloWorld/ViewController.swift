//
//  ViewController.swift
//  HelloWorld
//
//  Created by ABC on 07/12/2023.
//

import UIKit
import Firebase
class ViewController: UIViewController {

  

  
    override func viewDidLoad() {
//        var ref: DatabaseReference!
//        ref = Database.database().reference()
//        var dataDic: [String: Any] = [:]
//        dataDic["First Name"] = "ABK"
//        dataDic["Last Name"] = "Asym"
//        ref.setValue(dataDic)
       super.viewDidLoad()

        print("\n\tHello guys\n")
        // Do any additional setup after loading the view.
    }
    @IBAction func showProductView(_ sender: Any) {
        let pc = ProductViewController()
        self.present(pc, animated: true,completion: nil)
        //print("button pressed")
    }

}

