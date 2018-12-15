//
//  ViewController+CoreDate.swift
//  AnaCarolinaWagner
//
//  Created by Wagner Rodrigues on 02/09/2018.
//  Copyright © 2018 ComprasUSA. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}

