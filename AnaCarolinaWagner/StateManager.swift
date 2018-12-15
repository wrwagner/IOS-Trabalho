//
//  StateManager.swift
//  AnaCarolinaWagner
//
//  Created by Wagner Rodrigues on 03/09/2018.
//  Copyright © 2018 ComprasUSA. All rights reserved.
//

import CoreData

class StateManager {
    
    static let shared = StateManager()
    var states : [State] = []
    
    func loadStates(with context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            states = try context.fetch(fetchRequest)
        } catch  {
            debugPrint(error.localizedDescription)
        }
    }
    
    func deleteState(index: Int, context: NSManagedObjectContext){
        let state = states[index]
        context.delete(state)
        do {
            try context.save()
            states.remove(at: index)
        } catch  {
            debugPrint(error.localizedDescription)
        }
    }
    
    private init() {
        
    }
}
