import SwiftUI

struct Trip: Codable, Hashable {
    let route_id: Int
    let service_id : String
    let trip_id: String
    //"trip_headsign": ""
    let direction_id: Int
}

class Trips: ObservableObject {
    static let trips = Trips()
    static let GTFS_NAME = "Trips"
    var tripsList: [Trip] = []
    let logger = Logger.logger

    func getTripsHandler(data:Data) -> Int {
        tripsList = []
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode([Trip].self, from: data)
            for trip in json {
                Trips.trips.tripsList.append(trip)
            }
        }
        catch let error as DecodingError {
            Logger.logger.log(service: Trips.GTFS_NAME, "JSON error:", error)
        }
        catch {
            Logger.logger.log(service: Trips.GTFS_NAME, "General error:", error)
        }
        return 0
    }
    
    func getTrips(dispatchGroup: DispatchGroup) {
        MetLink.metlink.callAPI(service: "Trips", url: "https://api.opendata.metlink.org.nz/v1/gtfs/trips?route_id=20", handler: getTripsHandler, dispatchGroup: dispatchGroup)
    }
    

}
