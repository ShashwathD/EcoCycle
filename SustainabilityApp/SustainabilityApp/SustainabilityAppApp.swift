//
//  SustainabilityAppApp.swift
//  SustainabilityApp
//
//  Created by Shashwath Dinesh on 4/12/25.
//

import SwiftUI

@main
struct SustainabilityAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
