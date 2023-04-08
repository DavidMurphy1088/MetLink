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

    var body : some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    let persistenceController = PersistenceController.shared

    var body: some View {
        TabView {
            MapContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            .tabItem {
                Label("First", systemImage: "1.circle")
            }
//            MapContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
//            .tabItem {
//                Label("Second", systemImage: "2.circle")
//            }
        }
    }
}
