import MapKit
import SwiftUI
import CoreData

struct ConfigurationView: View {
    @ObservedObject var routes = Routes.routes
    
    var body: some View {
        List(routes.routes, id: \.self) { route in
            Toggle(route.route_desc, isOn: Binding(
                get: { routes.selectedRoutes.contains(route) },
                set: { isSelected in
                    if isSelected {
                        routes.selectedRoutes.insert(route)
                    } else {
                        routes.selectedRoutes.remove(route)
                    }
                }
            ))
        }
//        .onAppear() {
//            print(self.services.selectedServices)
//        }
    }

}
