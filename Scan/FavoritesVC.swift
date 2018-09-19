//
//  FavoritesVC.swift
//  Scan
//
//  Created by Neil Sood on 9/18/18.
//  Copyright © 2018 Neil Sood. All rights reserved.
//

import UIKit
import CoreData

class FavoritesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableData: [Product] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchAllItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAllItems()
//        tableView.reloadData()
    }
    

    func fetchAllItems() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
//        request.predicate = NSPredicate(format: "type = %@", "isFavorited")
        do {
            let products = try context.fetch(request)
            tableData = products as [Product]
            
        } catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }

}

extension FavoritesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        for product in tableData {
            if product.isFavorited {
                count += 1
            }
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavItem", for: indexPath)
        if tableData[indexPath.row].isFavorited {
            cell.textLabel?.text = tableData[indexPath.row].name
            let num = Int(tableData[indexPath.row].price * 100)
            var str = String(num)
            var index = str.index(str.endIndex, offsetBy: -2)
            str.insert(".", at: index)
            cell.detailTextLabel?.text = "$" + str
            cell.accessoryType = .detailButton
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .normal, title: "remove") { action, index in
            self.tableData[indexPath.row].isFavorited = false
            
            do {
                try self.context.save()
            } catch {
                print("\(error)")
            }
            
            self.tableData.remove(at: indexPath.row)
            tableView.reloadData()
        }
        remove.backgroundColor = .red
        
        return [remove]
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ToDisplaySegue", sender: indexPath)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ToDisplaySegue", sender: indexPath)
    }
}