import SwiftUI

struct StopTime: Codable, Hashable {
    let id: Int
    let arrival_time: String
    let stop_id: String
    let stop_sequence: Int
}

class StopTimes {
    static let stopTimes = StopTimes()
    static let GTFS_NAME = "STOP_TIMES"
    let logger = Logger.logger
    var stopTimes: [StopTime] = []
    
    func handler(data:Data) -> Int {
        stopTimes = []
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode([StopTime].self, from: data)
            for stopTime in json {
                stopTimes.append(stopTime)
            }
        }
        catch let error as DecodingError {
            Logger.logger.log(service: CalendarDates.GTFS_NAME, "JSON error:", error)
        }
        catch {
            Logger.logger.log(service: CalendarDates.GTFS_NAME, "General error:", error)
        }
        return 0
    }
    
    func getStopTimes(dispatchGroup: DispatchGroup, tripId: String) {
        MetLink.metlink.callAPI(service: CalendarDates.GTFS_NAME, url: "https://api.opendata.metlink.org.nz/v1/gtfs/stop_times?trip_id=" + tripId,
                                handler: handler, dispatchGroup: dispatchGroup)
    }

}
