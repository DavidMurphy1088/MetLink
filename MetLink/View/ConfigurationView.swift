import MapKit
import SwiftUI
import CoreData

struct ConfigurationView: View {
    @ObservedObject var routes = Routes.routes
    
    func getRouteDesc(route: Route) -> String {
        return route.route_short_name + "->" +  route.route_desc
    }

    var body: some View {
        List(routes.routeList.sorted(), id: \.self) { route in
            Toggle(getRouteDesc(route: route), isOn: Binding(
                get: { routes.selectedRoutes.contains(route) },
                set: { isSelected in
                    if isSelected {
                        routes.selectedRoutes.insert(route)
                    } else {
                        routes.selectedRoutes.remove(route)
                    }
                    routes.saveDefaults()
                }
            ))
        }
    }
}
