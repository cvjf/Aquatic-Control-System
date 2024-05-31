import Foundation

class BeagleboneReader {
    static let url_get_data = URL(string: "http://beaglebone.local:5000/get_data")!
    static let url_get_reading = URL(string: "http://beaglebone.local:5000/get_reading")!
    
    private static func fetch(url: URL) -> Data? {
        let semaphore = DispatchSemaphore(value: 0)
        var fetchedData: Data?
        var fetchError: Error?
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() }
            
            if let error = error {
                fetchError = error
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                fetchError = NSError(domain: "Server Error", code: 0, userInfo: nil)
                return
            }
            
            guard let data = data else {
                fetchError = NSError(domain: "No Data", code: 0, userInfo: nil)
                return
            }
            
            fetchedData = data
        }.resume()
        
        // Wait for the request to complete
        _ = semaphore.wait(timeout: .distantFuture)
        
        if fetchError != nil {
            return nil
        }
        
        guard let data = fetchedData else {
            return nil
        }
        
        return data
    }
        
    private static func fetchRawData() -> Data? {
        if let data = fetch(url: url_get_data) {
            return data
        }
        return nil
    }
    
    static func decodeReading() -> String? {
        if let data = fetch(url: url_get_reading) {
            if let decoded = String(data: data, encoding: .utf8) {
                return decoded
            }
        }
        return nil
    }
    
    static func decodeDeviceState() -> Light? {
        let jsonData = BeagleboneReader.fetchRawData()
        let decoder = JSONDecoder()
                
        if let data = jsonData {
            do {
                return try decoder.decode(Light.self, from: data)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return nil
    }
    
    static func encodeDeviceState(light: Light) -> String? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(light)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print("Error encoding light: \(error)")
            return nil
        }
    }
}
