//
//  DataController.swift
//  NoteApp
//
//  Created by Corentin Robert on 15/10/2024.
//

import Foundation
import CoreData
class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "CoNotebook")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
