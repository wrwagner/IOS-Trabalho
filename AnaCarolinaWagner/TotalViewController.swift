//
//  TotalViewController.swift
//  AnaCarolinaWagner
//
//  Created by Wagner Rodrigues on 22/09/2018.
//  Copyright © 2018 ComprasUSA. All rights reserved.
//

import UIKit
import CoreData

class TotalViewController: UIViewController {
    
    @IBOutlet private weak var labelTotalDolar: UILabel!
    @IBOutlet private weak var labelTotalReal: UILabel!
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateValues()
    }
    
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateValues() {
        guard let products = fetchedResultController.fetchedObjects,
            let dolarQuotation = UserDefaults.standard.value(forKey: "dolar") as? Double,
            let iof = UserDefaults.standard.value(forKey: "iof") as? Double
        else {return}
        
        var totalDolar = 0.0
        var totalReal = 0.0
        
        for product in products {
            totalDolar += product.price + product.product_state!.tax
            
            if product.isCreditCar {
                totalReal += ((product.price + product.product_state!.tax) * dolarQuotation) * ((iof / 100) + 1)
            }
            else {
                totalReal += (product.price + product.product_state!.tax) * dolarQuotation
            }
        }
        
        labelTotalReal.text = String(format: "R$ %.2f", totalReal)
        labelTotalDolar.text = String(format: "U$ %.2f", totalDolar)
    }
}

extension TotalViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateValues()
    }
}
