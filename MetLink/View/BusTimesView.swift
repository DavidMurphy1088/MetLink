import MapKit
import SwiftUI
import CoreData

struct BusTimesView: View {

    func stopTapped(stop: Stop) {
        print("get time", stop.stop_name)
    }
    
    
    var body: some View {
        VStack {
            UserSelectedStopsView()
        }
   }
}
