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
        //self.getRoutes()
    }
    
    func getRoutesHandler(data:Data) -> Int {
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
            Logger.logger.log("JSON error:", error)
        }
        catch {
            Logger.logger.log("General error:", error)
        }
        return 0
    }
    
    func getRoutes() {
        MetLink.metlink.callAPI(url: "https://api.opendata.metlink.org.nz/v1/gtfs/routes", handler: getRoutesHandler)
    }

}
