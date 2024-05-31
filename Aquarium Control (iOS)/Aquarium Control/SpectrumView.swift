import SwiftUI
import Charts

struct SpectrumData: Identifiable {
    let id = UUID()
    let wavelength: Double
    var intensity: Double
    
    static func template() -> [SpectrumData] {
        var data: [SpectrumData] = []
        for λ in stride(from: 380, through: 750, by: 5.0) {
            data.append(.init(wavelength: λ, intensity: 0))
        }
        return data
    }
    
    static func mock() -> [SpectrumData] {
        return [
            .init(wavelength: 380, intensity: 0),
            .init(wavelength: 395, intensity: 0.2),
            .init(wavelength: 400, intensity: 0.17), //
            .init(wavelength: 405, intensity: 1.0),
            .init(wavelength: 415, intensity: 1.0),
            .init(wavelength: 422.5, intensity: 0.6), //
            .init(wavelength: 430, intensity: 0.8),
            .init(wavelength: 440, intensity: 0.6), //
            .init(wavelength: 450, intensity: 1.0),
            .init(wavelength: 465, intensity: 1.0),
            .init(wavelength: 490, intensity: 0.1), //
//            .init(wavelength: 510, intensity: 0),
            .init(wavelength: 577.5, intensity: 0.1), //
            .init(wavelength: 645, intensity: 0.2),
            .init(wavelength: 700, intensity: 0),
        ]
    }
    
}

struct SpectrumGradient: View {
    func wavelengthToLocation(_ wavelength: Int) -> Double {
        return (Double(wavelength) - 380.0) / (700 - 380.0)
    }

    var body: some View {
        LinearGradient(stops: [
            .init(color: Color.from(wavelength: 380), location: wavelengthToLocation(380)),
            .init(color: Color.from(wavelength: 395), location: wavelengthToLocation(395)),
            .init(color: Color.from(wavelength: 405), location: wavelengthToLocation(405)),
            .init(color: Color.from(wavelength: 415), location: wavelengthToLocation(415)),
            .init(color: Color.from(wavelength: 430), location: wavelengthToLocation(430)),
            .init(color: Color.from(wavelength: 450), location: wavelengthToLocation(450)),
            .init(color: Color.from(wavelength: 465), location: wavelengthToLocation(465)),
            .init(color: Color.from(wavelength: 530), location: wavelengthToLocation(530)), // green
            .init(color: Color.from(wavelength: 575), location: wavelengthToLocation(575)), // yellow
            .init(color: Color.from(wavelength: 600), location: wavelengthToLocation(600)), // orange
            .init(color: Color.from(wavelength: 665), location: wavelengthToLocation(665)), // red
            .init(color: Color.from(wavelength: 700), location: wavelengthToLocation(700)), // red
        ], startPoint: .leading, endPoint: .trailing)
    }
}

struct SpectrumView: View {
    @Binding var light: Light
    @Binding var selected: Int
    
    private let template = SpectrumData.template()

    private func cubicSplineInterpolate() -> [SpectrumData] {
//        let x = light.breakpoints[selected].diodes
//            .filter { $0.intensity != 0 }
//            .map { $0.wavelength }
//        let y = light.breakpoints[selected].diodes
//            .filter { $0.intensity != 0 }
//            .map { $0.intensity * $0.alpha }
//        let interpolator = CubicSplineInterpolator(x: x, y: y)
                
        var data: [SpectrumData] = []
        
        data.append(.init(wavelength: 380, intensity: 0))
        for λ in stride(from: 380, through: 750, by: 5.0) {
            if let match = light.breakpoints[selected].diodes.first(where: { $0.wavelength == λ }) {
                //                if match.intensity == 0 {
                //                    data.append(.init(wavelength: λ, intensity: interpolator.interpolate(λ)))
                //                    print("Interpolated at " + String(λ) + ": " + String(interpolator.interpolate(λ)))
                //                } else {
                data.append(.init(wavelength: λ, intensity: match.alpha * match.intensity + 0.05))
                //                }
            }
        }
        data.append(.init(wavelength: 700, intensity: 0))
        
        return data
    }
        
    private var data: [SpectrumData] {
        var data: [SpectrumData] = []
        for diode in light.breakpoints[selected].diodes {
            data.append(.init(wavelength: diode.wavelength, intensity: diode.intensity))
        }
        return data
    }
    
    private var spectrumGradient: LinearGradient {
        return LinearGradient(stops: [
            .init(color: Color.from(wavelength: 380), location: wavelengthToLocation(380)),
            .init(color: Color.from(wavelength: 395), location: wavelengthToLocation(395)),
            .init(color: Color.from(wavelength: 405), location: wavelengthToLocation(405)),
            .init(color: Color.from(wavelength: 415), location: wavelengthToLocation(415)),
            .init(color: Color.from(wavelength: 430), location: wavelengthToLocation(430)),
            .init(color: Color.from(wavelength: 450), location: wavelengthToLocation(450)),
            .init(color: Color.from(wavelength: 465), location: wavelengthToLocation(465)),
            .init(color: Color.from(wavelength: 530), location: wavelengthToLocation(530)), // green
            .init(color: Color.from(wavelength: 575), location: wavelengthToLocation(575)), // yellow
            .init(color: Color.from(wavelength: 600), location: wavelengthToLocation(600)), // orange
            .init(color: Color.from(wavelength: 665), location: wavelengthToLocation(665)), // red
            .init(color: Color.from(wavelength: 700), location: wavelengthToLocation(700)), // red
        ], startPoint: .leading, endPoint: .trailing)
    }
    
    func wavelengthToLocation(_ wavelength: Int) -> Double {
        return (Double(wavelength) - 380.0) / (700 - 380.0)
    }

    var body: some View {
        VStack(spacing: 0) {
            //        Chart(SpectrumData.mock()) {
            Chart(self.cubicSplineInterpolate()) {
                AreaMark(
                    x: .value("Wavelength", $0.wavelength),
                    y: .value("Intensity", $0.intensity)
                )
                .interpolationMethod(.cardinal)
                .foregroundStyle(spectrumGradient)
            }
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartXScale(domain: 380...700)
            .frame(width: 650, height: 250)
            Rectangle()
                .frame(width: 650, height: 5)
                .background(.white)
                .foregroundStyle(.background)
            SpectrumGradient()
                .frame(width: 650, height: 8)
        }
        .rotationEffect(.degrees(+90))
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}

#Preview {
    SpectrumView(light: getMockLight(), selected: .constant(1))
}
