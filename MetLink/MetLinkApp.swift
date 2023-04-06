//
//  MetLinkApp.swift
//  MetLink
//
//  Created by David Murphy on 4/6/23.
//

import SwiftUI

@main
struct MetLinkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
