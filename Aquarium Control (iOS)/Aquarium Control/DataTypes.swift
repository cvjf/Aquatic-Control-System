import Foundation


extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

typealias Wavelength = Double

struct Light {
    var id = UUID()

    var name: String
    var image: String
    let location: String

    var intensity: Double = 0.0
    var breakpoints: [Breakpoint]
    
    struct Breakpoint: Hashable, Codable {
        var time: TimeInterval
        var diodes: [Diode]
    }
    
    struct Diode: Hashable, Codable, Identifiable {
        var id = UUID()
        
        let wavelength: Wavelength // in nm
        let count: Int
        let description: String
        var intensity: Double = 0.0 // 0...1
        var alpha: Double = 1 // used in drawing the spectrum graph. determined by manufacturer
    }
}

extension Light: Hashable, Codable, Identifiable {
    static func == (lhs: Light, rhs: Light) -> Bool {
        return lhs.id == rhs.id
    }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(UUID.self, forKey: .id)
        
        name = try values.decode(String.self, forKey: .name)
        image = try values.decode(String.self, forKey: .image)
        location = try values.decode(String.self, forKey: .location)
        
        intensity = try values.decode(Double.self, forKey: .intensity)
        breakpoints = try values.decode([Breakpoint].self, forKey: .breakpoints)
    }
}

extension Light.Diode {
    public func copy() -> Light.Diode {
        return Light.Diode(wavelength: wavelength, count: count, description: description, intensity: intensity, alpha: alpha)
    }
}

extension Light.Breakpoint {
    public func copy() -> Light.Breakpoint {
        return .init(time: self.time, diodes: self.diodes.map { $0.copy() })
    }
}
