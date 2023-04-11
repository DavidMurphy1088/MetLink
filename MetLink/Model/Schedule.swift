import SwiftUI

class Schedule {
    static let schedule = Schedule()
    
    func getTripsForDate(route: Int, date: String) {
        print(CalendarDates.calendarDates.calendarDatesDict.keys)
        let calendarDates = CalendarDates.calendarDates.calendarDatesDict[date]
        
        guard let calendarDates = calendarDates else {
            return
        }
        var servicesForDate:[String] = []
        for calDate in calendarDates {
            servicesForDate.append(calDate.service_id)
        }
        var n = 0
        var ss:[String] = []
        for trip in Trips.trips.tripsList {
            if trip.route_id != route {
                continue
            }
            if !(servicesForDate.contains(trip.service_id)) {
                continue
            }
            //print(n, "Trip:", trip.trip_id, "service", trip.service_id, "route", trip.route_id, "Dir", trip.direction_id)
            n+=1
            if n > 2500 {
                break
            }
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            StopTimes.stopTimes.getStopTimes(dispatchGroup: dispatchGroup, tripId: trip.trip_id)
            dispatchGroup.wait()
            var m = 0
            
            for stime in StopTimes.stopTimes.stopTimes {
                if stime.stop_id == "5000" {
                    ss.append(stime.arrival_time)
                    print("  Courtenay", m, "Direction:", trip.direction_id, "seq:", stime.stop_sequence, stime.arrival_time)
                    m+=1
                }
            }
        }
        print(ss.sorted())
    }
}
