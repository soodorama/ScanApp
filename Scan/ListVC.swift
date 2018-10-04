//
//  ListVC.swift
//  Scan
//
//  Created by Isabell Frischmann on 9/18/18.
//  Copyright © 2018 Isabell Frischmann. All rights reserved.
//

import UIKit
import CoreData

class ListVC: UIViewController {

    var tableData: [Product] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchAllItems()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        fetchAllItems()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    get all Items from the Database
    func fetchAllItems() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        do {
            let products = try context.fetch(request)
            tableData = products as [Product]
        } catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        let controller = nav.topViewController as! DisplayVC
        controller.delegate = self
        
        let indexPath = sender as! IndexPath
        let data = tableData[indexPath.row]
        controller.data["imageURL"] = data.imageURL
        controller.data["price"] = String(data.price)
        controller.data["brand"] = data.brand
        controller.data["stock"] = data.isInStock ? "In Stock" : "Not in Stock"
        controller.data["clearance"] = data.isOnClearance ? "Clearance" : "Regular Sale"
        controller.data["desc"] = data.desc
        controller.data["name"] = data.name
        
    }
}

extension ListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductItem", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row].name
        let num = Int(tableData[indexPath.row].price * 100)
        var str = String(num)
        var index = str.index(str.endIndex, offsetBy: -2)
        str.insert(".", at: index)
        cell.detailTextLabel?.text = "$" + str
        cell.accessoryType = .detailButton
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let add = UITableViewRowAction(style: .normal, title: "Add") { action, index in
            self.tableData[indexPath.row].isFavorited = true
            
            self.tabBarController?.selectedIndex = 2
        }
        add.backgroundColor = .gray
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let product = self.tableData[indexPath.row]
            self.context.delete(product)
            
            do {
                try self.context.save()
            } catch {
                print("\(error)")
            }
            
            self.tableData.remove(at: indexPath.row)
            tableView.reloadData()
        }
        delete.backgroundColor = .red
        
        return [delete, add]
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ToDisplaySegue", sender: indexPath)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ToDisplaySegue", sender: indexPath)
    }
}

extension ListVC: DisplayVCDelegate {
    func backBtnPressed() {
        dismiss(animated: true, completion: nil)
    }
}
