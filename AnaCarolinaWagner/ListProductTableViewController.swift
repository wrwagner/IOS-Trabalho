//
//  ListProductTableViewController.swift
//  AnaCarolinaWagner
//
//  Created by Wagner Rodrigues on 02/09/2018.
//  Copyright © 2018 ComprasUSA. All rights reserved.
//

import UIKit
import CoreData

class ListProductTableViewController: UITableViewController {
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    var labelEmpity = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelEmpity.text = "Sua lista está vazia!"
        labelEmpity.textAlignment = .center
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProducts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newProductSegue" {
            _ = segue.destination as! AddProductViewController
            
        } else {
            let vc = segue.destination as! AddProductViewController
            if let product = fetchedResultController.fetchedObjects {
                vc.product = product[tableView.indexPathForSelectedRow!.row]
            }
        }
    }

    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescritor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescritor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            debugPrint(error.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = fetchedResultController.fetchedObjects?.count ?? 0
        
        tableView.backgroundView = count == 0 ? labelEmpity : nil
        
        if count == 0 {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellProductTableViewCell
        
        guard let product = fetchedResultController.fetchedObjects?[indexPath.row] else {
            return cell
        }
        
        cell.prepare(with: product)
        
        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductRegister") as! AddProductViewController
        
        vc.product = fetchedResultController.object(at: indexPath)
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let product = fetchedResultController.fetchedObjects?[indexPath.row] else {return}
            do {
                context.delete(product)
                try context.save()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }

}

extension ListProductTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        default:
            tableView.reloadData()
        }
    }
}
