import SwiftUI

struct SliderView: View {
    @Binding var value: Double
    @State var colors: [Color]
        
    var body: some View {
        HStack(alignment: .center) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
                        .frame(width: geometry.size.width, height: 5)
                        .cornerRadius(6)
                    ZStack {
                        Circle()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .frame(width: 30, height: 30)
                        Circle()
                            .stroke(.white.opacity(0.5), lineWidth: 1)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .frame(width: 30, height: 30)
                        Circle()
                            .fill(colors.last ?? .black)
                            .frame(width: 8, height: 8)
                    }
                    .offset(x: CGFloat(value) * geometry.size.width - 15)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged({ gesture in
                            updateValue(with: gesture, in: geometry)
                        }))
                }
            }
            Spacer(minLength: 25)
            TextField("", value: $value, format: .percent.precision(.fractionLength(0)).rounded(rule: .down))
                .frame(width: 40)
                .padding(8)
                .font(Font.system(size: 12, design: .default))
                .background(.gray.opacity(0.3))
                .cornerRadius(6)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .onChange(of: value, { _, newValue in
                    value = newValue > 1.0 ? 1.0 : newValue
                })
        }
        .frame(width: .infinity, height: 30)
    }
    
    func updateValue(with gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let newValue = gesture.location.x / geometry.size.width
        value = min(max(Double(newValue), 0), 1)
    }
}

#Preview {
    SliderView(value: .constant(0.0), colors: [.black, .red, .yellow, .green, .blue, .royal, .ultraviolet].reversed())
        .padding(.horizontal, 40)
}
