import SwiftUI

class Logger : ObservableObject {
    static var logger = Logger()
    var message:String=""
    
    func log(service:String, _ str:String, _ err:Error? = nil) {
        var msg = "Logger-" + service + ":"
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
    
    func makeRequest(_ urlStr:String) -> URLRequest {
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("bqgukXkCrc8ASUt1KWb3GUEB1jQVziP4my82gdM0", forHTTPHeaderField: "x-api-key")
        return request
    }
    
    func callAPI(service:String, url:String, handler: @escaping (Data) -> Int, dispatchGroup:DispatchGroup? = nil ) {
        //print("->METLINK:", service, "starting", "\t", Thread.current.isMainThread, Thread.current)
        let request = MetLink.metlink.makeRequest(url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //print("->METLINK:", service, "received data", "\t", Thread.current.isMainThread, Thread.current)
            guard let data = data, error == nil else {
                Logger.logger.log(service: "METLINK", "no data error loading:", error)
                return
            }
            DispatchQueue.main.async {
                //print("   METLINK:", service, "starting handler", service, "\t", Thread.current.isMainThread, Thread.current)
                let result = handler(data)
                print("   METLINK:", service, "end handler", service, "Result", result)
                if let dispatchGroup = dispatchGroup {
                    dispatchGroup.leave()
                }
            }
        }
        task.resume()
    }

}
