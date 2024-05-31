import SwiftUI

// some common colors found in actinic spectrums
extension Color {
    public static var ultraviolet: Color {
//        return Color(red: 35.0/255.0, green: 1.0/255.0, blue: 101.0/255.0)
//        return Color(red: 199.0/255.0, green: 15.0/255.0, blue: 211.0/255.0) // color picker
        return Color(red: 97/255.0, green: 0.0/255.0, blue: 97/255.0) // converted from 380nm
    }
    public static var violet: Color {
        return Color(red: 118.0/255.0, green: 0.0/255.0, blue: 237.0/255.0)
    }
    public static var royal: Color {
        return Color(red: 0.0/255.0, green: 52.0/255.0, blue: 196.0/255.0)
    }
    public static var marine: Color {
        return Color(red: 22.0/255.0, green: 119.0/255.0, blue: 197.0/255.0)
    }
    public static var warm: Color {
        return Color(red: 228.0/255.0, green: 224.0/255.0, blue: 200.0/255.0)
    }
    public static var cold: Color {
        return Color(red: 228.0/255.0, green: 224.0/255.0, blue: 200.0/255.0)
    }
    public static var nm_395: Color {
        return Color(red: 128.0/255.0, green: 0.0/255.0, blue: 161.0/255.0)
    }
}

// converting between wavelengths and rgbs
extension Color {
    static func from(wavelength: Double) -> Color {
        let intensityMax = 255.0
        let gamma = 0.8
        var factor: Double
        var red, green, blue: Double
        
        if (wavelength >= 380) && (wavelength < 440) {
            red = -(wavelength - 440) / (440 - 380)
            green = 0.0
            blue = 1.0
        } else if (wavelength >= 440) && (wavelength < 490) {
            red = 0.0
            green = (wavelength - 440) / (490 - 440)
            blue = 1.0
        } else if (wavelength >= 490) && (wavelength < 510) {
            red = 0.0
            green = 1.0
            blue = -(wavelength - 510) / (510 - 490)
        } else if (wavelength >= 510) && (wavelength < 580) {
            red = (wavelength - 510) / (580 - 510)
            green = 1.0
            blue = 0.0
        } else if (wavelength >= 580) && (wavelength < 645) {
            red = 1.0
            green = -(wavelength - 645) / (645 - 580)
            blue = 0.0
        } else if (wavelength >= 645) && (wavelength < 781) {
            red = 1.0
            green = 0.0
            blue = 0.0
        } else {
            red = 0.0
            green = 0.0
            blue = 0.0
        }
        
        // Let the intensity fall off near vision limits
        if (wavelength >= 380) && (wavelength < 420) {
            factor = 0.3 + 0.7 * (wavelength - 380) / (420 - 380)
        } else if (wavelength >= 420) && (wavelength < 701) {
            factor = 1.0
        } else if (wavelength >= 701) && (wavelength < 781) {
            factor = 0.3 + 0.7 * (780 - wavelength) / (780 - 700)
        } else {
            factor = 0.0
        }
        
        // Don't want 0^x = 1 for x <> 0
        let r = red == 0.0 ? 0.0 : intensityMax * pow(red * factor, gamma) / 255.0
        let g = green == 0.0 ? 0.0 : intensityMax * pow(green * factor, gamma) / 255.0
        let b = blue == 0.0 ? 0.0 : intensityMax * pow(blue * factor, gamma) / 255.0
        
        return Color(red: r, green: g, blue: b)
    }

    static func from(wavelengths: [Wavelength]) -> Color {
        let colors = wavelengths.map { Color.from(wavelength: $0) }
        return combine(colors)
    }

    static private func combine(_ colors: [Color]) -> Color {
        guard !colors.isEmpty else {
            return .clear
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        for color in colors {
            let uiColor = UIColor(color)
            var currentRed: CGFloat = 0
            var currentGreen: CGFloat = 0
            var currentBlue: CGFloat = 0
            var currentAlpha: CGFloat = 0
            
            uiColor.getRed(&currentRed, green: &currentGreen, blue: &currentBlue, alpha: &currentAlpha)
            
            red += currentRed
            green += currentGreen
            blue += currentBlue
            alpha += currentAlpha
        }
        
        red /= CGFloat(colors.count)
        green /= CGFloat(colors.count)
        blue /= CGFloat(colors.count)
        alpha /= CGFloat(colors.count)
        
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
    
    static func combinedColor(from colorsWithIntensity: [(Color, Double)]) -> Color {
        guard !colorsWithIntensity.isEmpty else {
            return .clear
        }
        
        // Initialize color components
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var totalIntensity: CGFloat = 0
        
        // Calculate combined color components
        for (color, intensity) in colorsWithIntensity {
            let uiColor = UIColor(color)
            var currentRed: CGFloat = 0
            var currentGreen: CGFloat = 0
            var currentBlue: CGFloat = 0
            var currentAlpha: CGFloat = 0
            
            uiColor.getRed(&currentRed, green: &currentGreen, blue: &currentBlue, alpha: &currentAlpha)
            
            // Weight the color components by intensity
            red += currentRed * CGFloat(intensity)
            green += currentGreen * CGFloat(intensity)
            blue += currentBlue * CGFloat(intensity)
            totalIntensity += CGFloat(intensity)
        }
        
        // Normalize the color components
        red /= totalIntensity
        green /= totalIntensity
        blue /= totalIntensity
        
        if totalIntensity == 0 {
            return Color.black
        }
        
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: 1.0)
    }

}

extension Light.Diode  {
    public static func combinedColor(from diodes: [Light.Diode]) -> Color {
        let colorsWithIntensity = diodes.map({ diode in
            return (Color.from(wavelength: diode.wavelength), Double(diode.alpha) * diode.intensity)
        })
        return Color.combinedColor(from: colorsWithIntensity)
    }
}


//extension Color {
//    static let LEN_MIN = 350
//    static let LEN_MAX = 780
//    static let LEN_STEP = 5
//    
//    static let X: [Double] = [0.000160, 0.000662, 0.002362, 0.007242, 0.019110, 0.043400, 0.084736, 0.140638, 0.204492, 0.264737,
//                              0.314679, 0.357719, 0.383734, 0.386726, 0.370702, 0.342957, 0.302273, 0.254085, 0.195618, 0.132349,
//                              0.080507, 0.041072, 0.016172, 0.005132, 0.003816, 0.015444, 0.037465, 0.071358, 0.117749, 0.172953,
//                              0.236491, 0.304213, 0.376772, 0.451584, 0.529826, 0.616053, 0.705224, 0.793832, 0.878655, 0.951162,
//                              1.014160, 1.074300, 1.118520, 1.134300, 1.123990, 1.089100, 1.030480, 0.950740, 0.856297, 0.754930,
//                              0.647467, 0.535110, 0.431567, 0.343690, 0.268329, 0.204300, 0.152568, 0.112210, 0.081261, 0.057930,
//                              0.040851, 0.028623, 0.019941, 0.013842, 0.009577, 0.006605, 0.004553, 0.003145, 0.002175, 0.001506,
//                              0.001045, 0.000727, 0.000508, 0.000356, 0.000251, 0.000178, 0.000126, 0.000090, 0.000065, 0.000046,
//                              0.000033]
//    
//    static let Y: [Double] = [0.000017, 0.000072, 0.000253, 0.000769, 0.002004, 0.004509, 0.008756, 0.014456, 0.021391, 0.029497,
//                              0.038676, 0.049602, 0.062077, 0.074704, 0.089456, 0.106256, 0.128201, 0.152761, 0.185190, 0.219940,
//                              0.253589, 0.297665, 0.339133, 0.395379, 0.460777, 0.531360, 0.606741, 0.685660, 0.761757, 0.823330,
//                              0.875211, 0.923810, 0.961988, 0.982200, 0.991761, 0.999110, 0.997340, 0.982380, 0.955552, 0.915175,
//                              0.868934, 0.825623, 0.777405, 0.720353, 0.658341, 0.593878, 0.527963, 0.461834, 0.398057, 0.339554,
//                              0.283493, 0.228254, 0.179828, 0.140211, 0.107633, 0.081187, 0.060281, 0.044096, 0.031800, 0.022602,
//                              0.015905, 0.011130, 0.007749, 0.005375, 0.003718, 0.002565, 0.001768, 0.001222, 0.000846, 0.000586,
//                              0.000407, 0.000284, 0.000199, 0.000140, 0.000098, 0.000070, 0.000050, 0.000036, 0.000025, 0.000018,
//                              0.000013]
//    
//    static let Z: [Double] = [0.000705, 0.002928, 0.010482, 0.032344, 0.086011, 0.197120, 0.389366, 0.656760, 0.972542, 1.282500,
//                              1.553480, 1.798500, 1.967280, 2.027300, 1.994800, 1.900700, 1.745370, 1.554900, 1.317560, 1.030200,
//                              0.772125, 0.570060, 0.415254, 0.302356, 0.218502, 0.159249, 0.112044, 0.082248, 0.060709, 0.043050,
//                              0.030451, 0.020584, 0.013676, 0.007918, 0.003988, 0.001091, 0.000000, 0.000000, 0.000000, 0.000000,
//                              0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
//                              0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
//                              0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
//                              0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
//                              0.000000]
//    
//    static let MATRIX_SRGB_D65: [Double] = [3.2404542, -1.5371385, -0.4985314,
//                                            -0.9692660,  1.8760108,  0.0415560,
//                                            0.0556434, -0.2040259,  1.0572252]
//    
//    static func from(wavelength: Double) -> Color {
//        guard wavelength >= Double(LEN_MIN), wavelength <= Double(LEN_MAX) else {
//            return .white
//        }
//        
//        var len = wavelength
//        len -= Double(LEN_MIN)
//        let index = Int(floor(len / Double(LEN_STEP)))
//        let offset = len - Double(LEN_STEP) * Double(index)
//        
//        let x = interpolate(values: X, index: index, offset: offset)
//        let y = interpolate(values: Y, index: index, offset: offset)
//        let z = interpolate(values: Z, index: index, offset: offset)
//        
//        let m = MATRIX_SRGB_D65
//        
//        var r = m[0] * x + m[1] * y + m[2] * z
//        var g = m[3] * x + m[4] * y + m[5] * z
//        var b = m[6] * x + m[7] * y + m[8] * z
//        
//        r = clip(gammaCorrect_sRGB(c: r))
//        g = clip(gammaCorrect_sRGB(c: g))
//        b = clip(gammaCorrect_sRGB(c: b))
//        
//        return Color(red: r, green: g, blue: b)
//    }
//    
//    static func interpolate(values: [Double], index: Int, offset: Double) -> Double {
//        if offset == 0 {
//            return values[index]
//        }
//        
//        let x0 = Double(index * LEN_STEP)
//        let x1 = x0 + Double(LEN_STEP)
//        let y0 = values[index]
//        let y1 = values[1 + index]
//        
//        return y0 + offset * (y1 - y0) / (x1 - x0)
//    }
//    
//    static func gammaCorrect_sRGB(c: Double) -> Double {
//        if c <= 0.0031308 {
//            return 12.92 * c
//        }
//        
//        let a = 0.055
//        return (1 + a) * pow(c, 1 / 2.4) - a
//    }
//    
//    static func clip(_ c: Double) -> Double {
//        if c < 0 {
//            return 0
//        }
//        if c > 1 {
//            return 1
//        }
//        return c
//    }
//}
