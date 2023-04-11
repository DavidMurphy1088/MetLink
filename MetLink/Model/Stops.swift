import SwiftUI

struct Stop: Codable, Hashable {
    let id: Int
    let stop_id: String
    let stop_code: String
    let stop_name: String
    let stop_desc: String
    //"zone_id": "3",
    let stop_lat: Double //-41.33689713,
    let stop_lon: Double //174.7827608,
    //"location_type": 0,
    let selected: Bool?
}

class Stops: ObservableObject {
    static let stops = Stops()
    static let GTFS_NAME = "STOPS"
    let logger = Logger.logger
    //@Published
    var stops: [Stop] = []
    @Published var stopsSelected: [Stop] = []
    
    init() {
        if let savedStops = UserDefaults.standard.object(forKey: "selectedStops") as? Data {
            let decoder = JSONDecoder()
            if let loadedStops = try? decoder.decode([Stop].self, from: savedStops) {
                for stop in loadedStops {
                    self.stopsSelected.append(stop)
                }
                //print(loadedStrings) // Prints the list of strings
            }
        }
    }
    
    func saveDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(stopsSelected) {
            let s = String(data: encoded, encoding: .utf8)
            //print(s)
            UserDefaults.standard.set(encoded, forKey: "selectedStops")
        }
    }
    
    func searchStops(searchTerm: String) -> [Stop] {
        var result:[Stop] = []
        var i = 0
        for stop in stops {
            if stop.stop_name.contains(searchTerm) {
                result.append(stop)
                i += 1
                if i > 20 {
                    break
                }
            }
        }
        return result
    }
    
    func handler(data:Data) -> Int {
        stops = []
        let decoder = JSONDecoder()
        //var n = 0
        do {
            let json = try decoder.decode([Stop].self, from: data)
            for stop in json {
                stops.append(stop)
//                if n < 3 {
//                    DispatchQueue.main.async {
//                        self.stopsSelected.append(stop)
//                    }
//                }
//                n += 1
                //print(stop)
            }
        }
        catch let error as DecodingError {
            Logger.logger.log(service: CalendarDates.GTFS_NAME, "JSON error:", error)
        }
        catch {
            Logger.logger.log(service: CalendarDates.GTFS_NAME, "General error:", error)
        }
        return stops.count
    }
    
    func getStops(dispatchGroup: DispatchGroup) {
        MetLink.metlink.callAPI(service: Stops.GTFS_NAME, url: "https://api.opendata.metlink.org.nz/v1/gtfs/stops",
                                handler: handler, dispatchGroup: dispatchGroup)
    }

}
