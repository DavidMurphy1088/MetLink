import SwiftUI

struct CalendarDate: Codable, Hashable {
    let id: Int
    let service_id: String
    let date: String
    let exception_type: Int
}

class CalendarDates {
    static let calendarDates = CalendarDates()
    static let GTFS_NAME = "Calendar_Dates"
    let logger = Logger.logger
    var calendarDatesDict: [String: [CalendarDate]] = [:]
    //var calendarDates: [CalendarDate] = []
    
    func handler(data:Data) -> Int {
        calendarDatesDict = [:]
        let decoder = JSONDecoder()
        do {
            let jsonRoutes = try decoder.decode([CalendarDate].self, from: data)
            for calDate in jsonRoutes {
                //calendarDates.append(calDate)
                if calendarDatesDict[calDate.date] == nil {
                    calendarDatesDict[calDate.date] = []
                }
                calendarDatesDict[calDate.date]?.append(calDate)
            }
            print("cal dates size", calendarDatesDict.count, calendarDatesDict.keys)
        }
        catch let error as DecodingError {
            Logger.logger.log(service: CalendarDates.GTFS_NAME, "JSON error:", error)
        }
        catch {
            Logger.logger.log(service: CalendarDates.GTFS_NAME, "General error:", error)
        }
        return 0
    }
    
    func getRoutes(dispatchGroup: DispatchGroup) {
        MetLink.metlink.callAPI(service: CalendarDates.GTFS_NAME, url: "https://api.opendata.metlink.org.nz/v1/gtfs/calendar_dates",
                                handler: handler, dispatchGroup: dispatchGroup)
    }

}
