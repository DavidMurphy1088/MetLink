import SwiftUI

struct Route: Codable, Hashable {
    let id: Int
    let route_id: String
    let route_short_name: String
    let route_desc: String
//    "id": 28,
//        "route_id": "10",
//        "agency_id": "TZM",
//        "route_short_name": "1",
//        "route_long_name": "Johnsonville West/Churton Park/Grenada Village - Island Bay",
//        "route_desc": "Island Bay - Johnsonville West/Churton Park/Grenada Village",
//        "route_type": 3,
//        "route_color": "e31837",
//        "route_text_color": "ffffff",
//        "route_url": ""
}

class Routes: ObservableObject {
    @Published var selectedRoutes: Set<Route> = []
    static let routes = Routes()
    let logger = Logger.logger
    var routes: [Route] = []
    
    init() {
        self.getRoutes()
    }
    
    func getRoutesHandler(data:Data) -> Int {
        let decoder = JSONDecoder()
        do {
            let jsonRoutes = try decoder.decode([Route].self, from: data)
            //print(jsonData)
            var i = 0
            for route in jsonRoutes {
                //print(route)
                routes.append(route)
                if i > 10 {
                    break
                }
                i += 1
            }
        }
        catch let error as DecodingError {
            Logger.logger.log("JSON error:", error)
            //print("checkData:", self.checkData(data))
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
