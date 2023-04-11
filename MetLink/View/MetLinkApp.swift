import SwiftUI

@main
struct MetLinkApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        DispatchQueue.global(qos: .background).async {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            //Routes.routes.getRoutes()
            Stops.stops.getStops(dispatchGroup: dispatchGroup)
            //CalendarDates.calendarDates.getRoutes(dispatchGroup: dispatchGroup)
            print("============Waiting..")
            
            //dispatchGroup.enter()
            //Trips.trips.getTrips(dispatchGroup: dispatchGroup)
            //dispatchGroup.wait()
        
            //dispatchGroup.wait()
            //Schedule.schedule.getTripsForDate(route: 20, date: "20230411")
        }
    }
    
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
            BusTimesView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            .tabItem {
                Label("Times", systemImage: "2.circle")
            }
            ConfigSelectStopsView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            .tabItem {
                Label("Stops", systemImage: "2.circle")
            }
            VehiclePositionsView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            .tabItem {
                Label("Positions", systemImage: "1.circle")
            }

            ConfigurationView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            .tabItem {
                Label("Routes", systemImage: "3.circle")
            }

//            MapContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
//            .tabItem {
//                Label("Second", systemImage: "2.circle")
//            }
        }
    }
}
