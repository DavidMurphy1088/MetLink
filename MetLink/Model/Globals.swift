import SwiftUI

class Logger : ObservableObject {
    static var logger = Logger()
    var message:String=""
    
    func log(_ str:String, _ err:Error? = nil) {
        print("Logger:", err == nil ? "" : "*** ERROR ***", str + (err == nil ? "" : err!.localizedDescription))
        DispatchQueue.main.async {
            self.message = str
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
