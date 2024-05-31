import SwiftUI

let SAMPLE_DIODES: [Light.Diode] = [
    .init(wavelength: 395, count: 4, description: "Ultraviolet", intensity: 0.0, alpha: 0.3),
    .init(wavelength: 405, count: 2, description: "405nm", intensity: 0.0, alpha: 0.2),
    .init(wavelength: 415, count: 4, description: "415nm", intensity: 0.0, alpha: 0.3),
    .init(wavelength: 430, count: 12, description: "430nm", intensity: 0.0, alpha: 0.6),
    .init(wavelength: 450, count: 32, description: "Royal Blue", intensity: 0.0, alpha: 0.9),
    .init(wavelength: 465, count: 32, description: "Blue", intensity: 0.0, alpha: 0.8),
    .init(wavelength: 510, count: 2, description: "Green", intensity: 0.0, alpha: 0.3),
    .init(wavelength: 645, count: 2, description: "Red", intensity: 0.0, alpha: 0.2),
]

let SAMPLE_BREAKPOINTS: [Light.Breakpoint] = [
    .init(time: 4 * 60 * 60, diodes: SAMPLE_DIODES),
    .init(time: 2 * 60 * 60, diodes: SAMPLE_DIODES),
    .init(time: 1 * 60 * 60, diodes: SAMPLE_DIODES),
    .init(time: 1 * 60 * 60, diodes: SAMPLE_DIODES),
    .init(time: 1 * 60 * 60, diodes: SAMPLE_DIODES),
    .init(time: 1 * 60 * 60, diodes: SAMPLE_DIODES),
    .init(time: 2 * 60 * 60, diodes: SAMPLE_DIODES),
    .init(time: 4 * 60 * 60, diodes: SAMPLE_DIODES),
]

let SAMPLE_LIGHTS = [
    Light(name: "Radion G4", image: "..", location: "192.0.0.1", breakpoints: getRandomizedBreakpoints()),
    Light(name: "Radion G5", image: "..", location: "192.0.0.2", breakpoints: getRandomizedBreakpoints()),
    Light(name: "Radion G6", image: "..", location: "192.0.0.3", breakpoints: getRandomizedBreakpoints()),
]

func getRandomizedDiodes() -> [Light.Diode] {
    var diodes: [Light.Diode] = []
    for diode in SAMPLE_DIODES {
        diodes.append(Light.Diode(
            wavelength: diode.wavelength,
            count: diode.count,
            description: diode.description,
            intensity: diode.wavelength == 510 ? 0 : Double.random(in: 0.0...1.0),
            alpha: diode.alpha
        ))
    }
    return diodes
}

func getRandomizedTimes() -> [TimeInterval] {
    var breakpoints: Set<TimeInterval> = []
    let maxInterval: TimeInterval = 86400 // Maximum time in seconds (24 hours)
    let intervalStep: TimeInterval = 1800 // Interval of 1800 seconds (30 minutes)
        
    var currentTime: TimeInterval = 0
    while currentTime < maxInterval && breakpoints.count < 12 {
        let remainingTime = maxInterval - currentTime
        let maxRandomMultiple = Int(remainingTime / intervalStep)
        let randomMultiple = Double(Int.random(in: 1...maxRandomMultiple))
        let breakpoint = randomMultiple * intervalStep
        breakpoints.insert(breakpoint)
        currentTime += intervalStep
    }
    return breakpoints.sorted()
}

func getRandomizedBreakpoints() -> [Light.Breakpoint] {
    var breakpoints: [Light.Breakpoint] = []
    for breakpoint in getRandomizedTimes() {
        breakpoints.append(.init(time: breakpoint, diodes: getRandomizedDiodes()))
    }
    return breakpoints
}

func getFixedBreakpoints() -> [Light.Breakpoint] {
    return [
        .init(time: 6 * 60 * 60, diodes: SAMPLE_DIODES.map { $0.copy() }),
        .init(time: 8 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 9.5 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 11 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 11.5 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 12 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 12.5 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 13 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 14.5 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 17 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 19 * 60 * 60, diodes: getRandomizedDiodes()),
        .init(time: 21 * 60 * 60, diodes: SAMPLE_DIODES.map { $0.copy() }),
    ]
}


func getMockLight() -> Binding<Light> {
    return Binding.constant(Light(name: "Radion G6 XR30", image: "radion_g6_xr30", location: "192.0.0.1", breakpoints: getRandomizedBreakpoints()))
}
