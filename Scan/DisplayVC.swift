//
//  DisplayVC.swift
//  Scan
//
//  Created by Isabell Frischmann on 9/18/18.
//  Copyright © 2018 Isabell Frischmann. All rights reserved.
//

import UIKit

protocol DisplayVCDelegate: class {
    func backBtnPressed()
}

class DisplayVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var clearanceLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var delegate: DisplayVCDelegate?
    var indexPath: IndexPath?
    var data = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = data["name"]
        brandLabel.text = data["brand"]
        clearanceLabel.text = data["clearance"]
        stockLabel.text = data["stock"]
        
        let imageString = data["imageURL"]
        print(imageString)
        let imageURL = URL(string: imageString!)

        if let data = try? Data(contentsOf: imageURL!)
        {
            let image: UIImage = UIImage(data: data)!
            imageView.image = image
        }
        
        
        guard let desc = data["desc"] else { return }
        print(desc)
        
        let convertedDesc = convertSpecialCharacters(string: desc)
//        print(utfDesc)

//        let utfDesc = desc.data(using: .utf8)
        
        descLabel.text = convertedDesc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        guard let doub = data["price"] else { return }
        
        let num = Int(Double(doub)! * 100)
        var str = String(num)
        var index = str.index(str.endIndex, offsetBy: -2)
        str.insert(".", at: index)
        priceLabel.text = "$" + str
    }
    
    func convertSpecialCharacters(string: String) -> String {
        var newString = string
        let char_dictionary = [
            "&amp;" : "&",
            "&lt;" : "<",
            "&gt;" : ">",
            "&quot;" : "\"",
            "&apos;" : "'"
        ];
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.replacingOccurrences(of: escaped_char, with: unescaped_char, options: NSString.CompareOptions.literal, range: nil)
        }
        return newString
    }
    
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        delegate?.backBtnPressed()
    }
    

}

