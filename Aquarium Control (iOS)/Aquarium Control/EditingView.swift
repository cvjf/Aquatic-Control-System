import SwiftUI

struct EditingView: View {

    @Binding var light: Light
    @Binding var selected: Int

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("Overall Intensity")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical)
                    SliderView(value: $light.intensity, colors: [.orange])
                        .padding(.leading, 23)
                    
                    Text("Daytime Colors")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical)
                    
                    ForEach(0 ..< light.breakpoints[selected].diodes.count, id: \.self) {
                        Text(light.breakpoints[selected].diodes[$0].description)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(2)
                        SliderView(
                            value: $light.breakpoints[selected].diodes[$0].intensity,
                            colors: [Color.from(wavelength: Double(light.breakpoints[selected].diodes[$0].wavelength))]
                        )
                        .padding(.leading, 23)
                    }
                }
                .padding(.bottom, 20)
                .frame(width: geometry.size.width)
            }
        }
    }
}

#Preview {
    EditingView(light: getMockLight(), selected: .constant(1))
        .padding()
}
