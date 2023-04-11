import SwiftUI

struct PositionsResponse: Codable {
    let header: Header?
    let entity: [Entity]?
}

struct Header: Codable {
    let gtfsRealtimeVersion: String
    let incrementality: Int
    let timestamp: Int
}

struct Entity: Codable {
    let id: String
    let vehicle: VehiclePosition?
}

struct VehiclePosition: Codable, Hashable {
    static func == (lhs: VehiclePosition, rhs: VehiclePosition) -> Bool {
        return (lhs.timestamp == rhs.timestamp)
    }

    func hash(into hasher: inout Hasher) {
        //hasher.combine(position)
        hasher.combine(timestamp)
    }
    
    let trip: VehicleTrip
    let position: Position
    let vehicle: InnerVehicle
    let timestamp: Int
    
    func readingAgeSeconds() -> Int {
        let d = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return Int(Date().timeIntervalSince(d))
    }
}

struct VehicleTrip: Codable {
    //let start_time: String
    let trip_id: String
    let direction_id: Int
    let route_id: Int
    
    //let schedule_relationship: String
    //let start_date: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let intVal = try? values.decode(Int.self, forKey: .route_id), let routeId:Int? = intVal {
            self.route_id = intVal
        }
        else {
            //print("route", values.allKeys)
            self.route_id = -1
        }
        
        if let intVal = try? values.decode(Int.self, forKey: .direction_id), let directionId:Int? = intVal {
            self.direction_id = intVal
        }
        else {
            self.direction_id = -1
        }
        
        if let strValue = try? values.decode(String.self, forKey: .trip_id), let tripIdDecoded:String? = strValue {
            self.trip_id = tripIdDecoded!
        } else {
            self.trip_id=""
        }
    }
}

struct Position: Codable, Hashable {
    //let bearing: Int
    let latitude: Double
    let longitude: Double
}

struct InnerVehicle: Codable {
    let id: String
}

class VehiclePositions: ObservableObject {
    static let vehiclePositions = VehiclePositions()
    
    @Published var lastGetTime:Date?
    @Published var status:String?
    @Published var vehiclePositions:[VehiclePosition] = []
    var logger = Logger.logger

    func checkData(_ data: Data) -> Bool {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("\n\n", jsonString, "\n")
            return true
        }
        return false
    }
    
    
    func getPositionsHandler(data:Data) -> Int {
        vehiclePositions = []
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(PositionsResponse.self, from: data)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            if let entity = response.entity {
                self.lastGetTime = Date()
                self.vehiclePositions = []
                var routeIdSet: Set<Int> = []
                for ent in entity {
                    if let vehicle = ent.vehicle {
                        routeIdSet.insert(vehicle.trip.route_id)
                        if vehicle.trip.route_id == 20 {
                            self.vehiclePositions.append(vehicle)
//                            if self.vehiclePositions.count % 1 == 0 {
//                                print("\tAge", vehicle.readingAgeSeconds(), "secs \tRoute", vehicle.trip.route_id, "\tDirection", vehicle.trip.direction_id, "\tTrip", vehicle.trip.trip_id)
//                            }
                        }
                    }
                }
                //print("All routes", routeIdSet.sorted())
                //self.logger.log("Loaded \(self.vehiclePositions.count) trips")
            }
        }
        catch let error as DecodingError {
            Logger.logger.log(service: "POSITIONS", "JSON error:", error)
            //print("checkData:", self.checkData(data))
        }
        catch {
            Logger.logger.log(service: "POSITIONS", "General error:", error)
        }
        
        return 0
    }
    
    func getPositions() {
        MetLink.metlink.callAPI(service: "Positions", url: "https://api.opendata.metlink.org.nz/v1/gtfs-rt/vehiclepositions", handler: getPositionsHandler)
    }
}
