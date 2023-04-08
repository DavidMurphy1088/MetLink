import MapKit
import SwiftUI
import CoreData

struct ConfigurationView: View {
    @ObservedObject var vehiclePositions = VehiclePositions()

    var body: some View {
        VStack {
            Text("setup")
        }
    }

}
