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
    
    let trip: Trip
    let position: Position
    let vehicle: InnerVehicle
    let timestamp: Int
}

struct Trip: Codable {
    let start_time: String
    let trip_id: String
    let direction_id: Int
    let route_id: Int
    let schedule_relationship: Int
    let start_date: String
}

struct Position: Codable, Hashable {
    let bearing: Int
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
    
    init() {
        self.getPositions()
    }
    
    func checkData(_ data: Data) -> Bool {
//        if let jsonString = String(data: data, encoding: .utf8) {
//            return true
//        }
        var i = 0
        var bad = 0
        for byte in data {
            if (byte >= 65 && byte <= 90) {
                continue
            }
            if (byte >= 0 && byte <= 127) {
                continue
            }
            bad += 1
            let myScalar = UnicodeScalar(byte)
            let myCharacter = Character(myScalar)
            print ("non ascii", i, "byte:", byte, "character:", myScalar)
            //}
            i += 1
            if bad > 10 {
                break
            }
        }
        return bad == 0
    }
    
    func getPositionsHandler(data:Data) -> Int {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(PositionsResponse.self, from: data)
            if let positionResponse = response as? PositionsResponse {
                if let entity = positionResponse.entity {
                    self.lastGetTime = Date()
                    self.vehiclePositions = []
                    var routeIdSet: Set<Int> = []
                    
                    for ent in entity {
                        if let vehicle = ent.vehicle {
                            if vehicle.trip.route_id == 20 {
                                routeIdSet.insert(vehicle.trip.route_id)
                                //busIdSet.insert(ent.vehicle.trip.)
                                
                                self.vehiclePositions.append(vehicle)
                                if self.vehiclePositions.count % 1 == 0 {
                                    print("\nRoute", vehicle.trip.route_id, "Direction", vehicle.trip.direction_id, "Date", vehicle.trip.start_date, "time", vehicle.trip.start_time)
                                    print("Route IDs -------> loaded count:", self.vehiclePositions.count, routeIdSet)
                                }
                            }
                            if self.vehiclePositions.count > 10000 {
                                break
                            }
                        }
                    }
                    self.logger.log("Loaded \(self.vehiclePositions.count) trips")
                }
            }
        }
        catch let error as DecodingError {
            Logger.logger.log("JSON error:", error)
            print("checkData:", self.checkData(data))
        }
        catch {
            Logger.logger.log("General error:", error)
        }
        
        return 0
    }
    
    func getPositions() {
        MetLink.metlink.callAPI(url: "https://api.opendata.metlink.org.nz/v1/gtfs-rt/vehiclepositions", handler: getPositionsHandler)
    }
}

//                do {
//                    if JSONSerialization.isValidJSONObject(data) {
//                        _ = try JSONSerialization.data(withJSONObject: data)
//                        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//                        if let jsonString = String(data: jsonData, encoding: .utf8) {
//                            print(jsonString)
//                        }
//
//                    } else {
//                        // not valid - do something appropriate
//                    }
//                }
//                catch {
//                    print("Some vague internal error: \(error)")
//                }
