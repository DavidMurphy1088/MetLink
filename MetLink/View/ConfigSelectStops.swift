import MapKit
import SwiftUI
import CoreData

struct UserSelectedStopsView: View {
    @ObservedObject var stops = Stops.stops
    @State var stopTappedAction: ((Stop) -> Void)? // = { }
    
    func deleteItem(at offsets: IndexSet) {
        stops.stopsSelected.remove(atOffsets: offsets)
    }
    
    var body: some View {
        VStack {
            Text("Selected Stops").font(.title2)
            List {
                ForEach(stops.stopsSelected, id: \.self) { stop in
                    HStack {
                        Text(stop.stop_id)
                        Text(stop.stop_name)//.font(.caption2)
                        //                            Spacer()
                        //                            Image(systemName: selectedStop == stop.id ? "checkmark.square" : "square")
                        //                            .onTapGesture {
                        //                                selectedStop = stop.id
                        //                            }
                    }
                    .onTapGesture {
                        if let stopTappedAction = stopTappedAction {
                            stopTappedAction(stop)
                        }
                    }
                }
                
                .onDelete(perform: deleteItem)
            }
            //.frame(height: 400)
        }
    }
}

struct ConfigSelectStopsView: View {
    @ObservedObject var stops = Stops.stops
    @State private var searchText = ""
    @State private var searchResults:[Stop] = []
    @State var keyboardPresented = false
    
    var searchView: some View {
        VStack {
            Text("Search Stops").font(.title2)
            HStack {
                Spacer()
                TextField("Search", text: $searchText)
                .onChange(of: searchText, perform: { searchTerm in
                    if searchTerm.count > 2 {
                        searchResults = stops.searchStops(searchTerm: searchText)
                        //searchResults.append(Stops.stops.stops[0])
                    }
                    else {
                        searchResults = []
                    }
                })

                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                Spacer()
            }
            List {
                ForEach(searchResults, id: \.self) { stop in
                    Text(stop.stop_name)
                    .onTapGesture {
                        self.searchResults = []
                        self.searchText = ""
                        stops.stopsSelected.append(stop)
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                        stops.saveDefaults()
                    }
                }
                //.onDelete(perform: deleteItem)
            }

        }
    }

    var body: some View {
        VStack {
            if !keyboardPresented {
                UserSelectedStopsView(stopTappedAction: nil)
            }
            searchView
            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            self.keyboardPresented = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            self.keyboardPresented = false
        }
   }
}
