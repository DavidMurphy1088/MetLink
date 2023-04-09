import SwiftUI
import MapKit
import SwiftUI
import CoreData

struct AnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

//https://kristaps.me/blog/swiftui-map-annotations/

struct MapContentView: View {
    @ObservedObject var vehiclePositions = VehiclePositions.vehiclePositions
    let coordinate = CLLocationCoordinate2D(latitude: -41.289257, longitude: 174.7752991)

    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -41.289257, longitude: 174.77529916), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    @State private var selectedAnnotation: VehiclePositionAnnotation? = nil

    struct VehiclePositionAnnotation: Identifiable {
        let id = UUID()
        //let coordinate: CLLocationCoordinate2D
        //let title: String
        //let direction: Int
        //let readingAgeSeconds: Int
        let vehiclePosition:VehiclePosition
        
        func getCoordinates() -> CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: vehiclePosition.position.latitude, longitude: vehiclePosition.position.longitude)
        }
    }
    
    struct DetailView: View {
        @State var annot:VehiclePositionAnnotation
        var body : some View {
            Text("S")
        }
    }
    
    func makePoints() -> [VehiclePositionAnnotation] {
        var res:[VehiclePositionAnnotation] = []
        //var nums = Set<Int>()
        //var nums1 = Set<Int>()
        for pos in vehiclePositions.vehiclePositions {
            //nums.insert(pos.trip.route_id)
//            let a = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: pos.position.latitude, longitude: pos.position.longitude),
//                                     title: "\(pos.trip.route_id)", direction: pos.trip.direction_id, vehiclePosReading: pos)
            let a = VehiclePositionAnnotation(vehiclePosition: pos)
            res.append(a)
            //nums1.insert(pos.trip.route_id)
        }
        return res
    }
    
    struct VehicleAnnotationView: View {
        @State private var showTitle = true
        let vehiclePositionAnnotation: VehiclePositionAnnotation
        
        var body: some View {
            VStack(spacing: 0) {
                Text("Route:\(vehiclePositionAnnotation.vehiclePosition.trip.route_id) secs:\(vehiclePositionAnnotation.vehiclePosition.readingAgeSeconds())")
                    .font(.callout)
                    .padding(5)
                    .background(Color(.white))
                    .cornerRadius(10)
                    .opacity(showTitle ? 0 : 1)

                Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(vehiclePositionAnnotation.vehiclePosition.trip.direction_id == 0 ? .red : .blue)

                Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.red)
                .offset(x: 0, y: -5)
            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    showTitle.toggle()
                }
            }
        }
    }
    
    func formatTime() -> String {
        if let time = vehiclePositions.lastGetTime {
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            let timeString = formatter.string(from: time)
            return("\(timeString)")
        }
        else {
            return ""
        }
    }
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: self.makePoints()) { vehiclePositionAnnotation in
                MapAnnotation(coordinate: vehiclePositionAnnotation.getCoordinates()) {
                    VehicleAnnotationView(vehiclePositionAnnotation: vehiclePositionAnnotation)
                }
            }
            HStack {
                Button("Refresh") {
                    vehiclePositions.getPositions()
                }
                Text(self.formatTime())
                Text(vehiclePositions.status ?? "")
            }
        }
    }
}


