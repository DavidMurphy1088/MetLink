import SwiftUI

struct Route: Codable, Hashable, Comparable {
    static func < (lhs: Route, rhs: Route) -> Bool {
        let lhs = Int(lhs.route_short_name)
        let rhs = Int(rhs.route_short_name)
        if lhs == nil || rhs == nil {
            return false
        }
        return lhs! < rhs!
    }
    
    let id: Int
    let route_id: String
    let route_short_name: String
    let route_desc: String
}

class Routes: ObservableObject {
    @Published var selectedRoutes: Set<Route> = []
    static let routes = Routes()
    let logger = Logger.logger
    var routeList: [Route] = []
    
    init() {
        if let savedRoutes = UserDefaults.standard.object(forKey: "selectedRoutes") as? Data {
            let decoder = JSONDecoder()
            if let loadedRoutes = try? decoder.decode([Route].self, from: savedRoutes) {
                for route in loadedRoutes {
                    self.selectedRoutes.insert(route)
                }
                //print(loadedStrings) // Prints the list of strings
            }
        }
    }
    
    func getRoutesHandler(data:Data) -> Int {
        routeList = []
        let decoder = JSONDecoder()
        do {
            let jsonRoutes = try decoder.decode([Route].self, from: data)
            var i = 0
            for route in jsonRoutes {
                if Int(route.route_short_name) != nil {
                    routeList.append(route)
                    i += 1
                }
            }            
        }
        catch let error as DecodingError {
            Logger.logger.log(service: "ROUTES", "JSON error:", error)
        }
        catch {
            Logger.logger.log(service: "ROUTES", "General error:", error)
        }
        return 0
    }
    
    func getRoutes() {
        MetLink.metlink.callAPI(service: "Routes", url: "https://api.opendata.metlink.org.nz/v1/gtfs/routes", handler: getRoutesHandler)
    }
    
    func saveDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(selectedRoutes) {
            let s = String(data: encoded, encoding: .utf8)
            //print(s)
            UserDefaults.standard.set(encoded, forKey: "selectedRoutes")
        }
    }
}
