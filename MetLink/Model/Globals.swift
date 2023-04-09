import SwiftUI

class Logger : ObservableObject {
    static var logger = Logger()
    var message:String=""
    
    func log(_ str:String, _ err:Error? = nil) {
        var msg = "Logger:"
        if let err = err {
            msg += "*** ERROR ***"
            msg += "\nlocalMsg:"+err.localizedDescription
            //str + "\nfullMsg:"+err.
        }
        msg += str
        print(msg)
        if let err = err {
            print(err)
        }
        DispatchQueue.main.async {
            self.message = msg
            if let error = err {
                self.message += error.localizedDescription
            }
        }
    }
}

class MetLink {
    static var metlink = MetLink()
    
    init() {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        Routes.routes.getRoutes()
//        { result in
//            dispatchGroup.leave()
//        }

        dispatchGroup.wait()

        dispatchGroup.enter()
        VehiclePositions.vehiclePositions.getPositions()
            // Handle the result of the second API call
            //dispatchGroup.leave()
        //}
    }
    
    func makeRequest(_ urlStr:String) -> URLRequest {
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("bqgukXkCrc8ASUt1KWb3GUEB1jQVziP4my82gdM0", forHTTPHeaderField: "x-api-key")
        return request
    }
    
    func callAPI(url:String, handler: @escaping (Data) -> Int) {
        let request = MetLink.metlink.makeRequest(url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                Logger.logger.log("no data error loading:", error)
                return
            }
            
            DispatchQueue.main.async {
                handler(data)
            }
        }
        task.resume()
    }

}
