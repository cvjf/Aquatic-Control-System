import Foundation

struct CubicSplineInterpolator {
    private var x: [Double]
    private var y: [Double]
    private var a: [Double]
    private var b: [Double]
    private var c: [Double]
    private var d: [Double]
    
    init(x: [Double], y: [Double]) {
        self.x = x
        self.y = y
        let n = x.count
        
        // Calculate coefficients
        var h = [Double]()
        var alpha = [Double]()
        var l = [Double](repeating: 0.0, count: n)
        var mu = [Double](repeating: 0.0, count: n)
        var z = [Double](repeating: 0.0, count: n)
        
        for i in 0..<n-1 {
            h.append(x[i+1] - x[i])
        }
        
        for i in 1..<n-1 {
            alpha.append(3 * ((y[i+1] - y[i]) / h[i]) - 3 * ((y[i] - y[i-1]) / h[i-1]))
        }
        
        l[0] = 1
        mu[0] = 0
        z[0] = 0
        
        for i in 1..<n-1 {
            l[i] = 2 * (x[i+1] - x[i-1]) - h[i-1] * mu[i-1]
            mu[i] = h[i] / l[i]
            z[i] = (alpha[i-1] - h[i-1] * z[i-1]) / l[i]
        }
        
        l[n-1] = 1
        z[n-1] = 0
        c = [Double](repeating: 0.0, count: n)
        b = [Double](repeating: 0.0, count: n)
        d = [Double](repeating: 0.0, count: n)
        a = [Double](repeating: 0.0, count: n)
        
        for j in (0..<n-1).reversed() {
            c[j] = z[j] - mu[j] * c[j+1]
            b[j] = (y[j+1] - y[j]) / h[j] - h[j] * (c[j+1] + 2 * c[j]) / 3
            d[j] = (c[j+1] - c[j]) / (3 * h[j])
            a = y
        }
    }
    
    func interpolate(_ xValue: Double) -> Double {
        let n = x.count
        var j = 0
        
        // Find the segment containing xValue
        while j < n && xValue > x[j] {
            j += 1
        }
        
        // Interpolate
        if j == 0 {
            j = 1
        } else if j >= n {
            j = n - 1
        }
        
        let h = x[j] - x[j - 1]
        let t = (xValue - x[j - 1]) / h
        
        let result = a[j - 1] + b[j - 1] * t + c[j - 1] * t * t + d[j - 1] * t * t * t
        return result < 0 ? 0 : result
    }
}
