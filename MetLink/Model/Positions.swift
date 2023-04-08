import SwiftUI

struct Response: Codable {
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
    
    init() {
        self.getPositions()
    }
    
    func setStatus(_ str:String, _ err:Error? = nil) {
        print("Model:", str + (err == nil ? "" : err!.localizedDescription))
        DispatchQueue.main.async {
            self.status = str
            if let error = err {
                self.status! += error.localizedDescription
            }
        }
    }
    
    func getPositions() {
            let url = URL(string: "https://api.opendata.metlink.org.nz/v1/gtfs-rt/vehiclepositions")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("bqgukXkCrc8ASUt1KWb3GUEB1jQVziP4my82gdM0", forHTTPHeaderField: "x-api-key")
            setStatus("Starting loading...")
        
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("no data error loading:", error as Any)
                    return
                }
                print("checkData0:", self.checkData(data))
//                var i = 0
//                for byte in data {
//                    //if byte < 0x00 || byte > 0x7F {
//                    if byte < 0x30 || byte > 0x7A {
//                        print("***", i, byte)
//                    }
//                    i += 1
//                }
                
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
                
                var routeIdSet: Set<Int> = []
                var busIdSet: Set<String> = []

                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(Response.self, from: data)
                    let hdr = response.header
                    if let entity = response.entity {
                        DispatchQueue.main.async {
                            self.lastGetTime = Date()
                            self.vehiclePositions = []
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
                            self.setStatus("Loaded \(self.vehiclePositions.count) trips")
                        }
                    }
                }
                catch let error as DecodingError {
                    self.setStatus("JSON error:", error)
                    print("checkData:", self.checkData(data))
                    return
                }
                catch {
                    self.setStatus("General error:", error)
                          //"\n---Response", response.debugDescription,
                          //"\n---Data", data.count)
                }
            }
            task.resume()
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
}

