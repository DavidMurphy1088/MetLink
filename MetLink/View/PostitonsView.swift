import MapKit
import SwiftUI
import CoreData

struct PositionsView: View {
    @ObservedObject var vehiclePositions = VehiclePositions()

    var body: some View {
        List(vehiclePositions.vehiclePositions, id: \.self) { pos in
            VStack(alignment: .leading) {
                HStack {
                    //Text(pos.vehicle.id)
                    //Text("Pos " + String(pos.position.latitude))
                }

//                Text(pos)
//                    .font(.subheadline)
            }
        }
        .onAppear {
            //vehiclePositions.getPositions()
        }
    }

}
