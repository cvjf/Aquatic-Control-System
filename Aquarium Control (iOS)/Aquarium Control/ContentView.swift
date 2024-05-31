import SwiftUI

struct ContentView: View {

    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: isAnimating ? 200 : 100, height: isAnimating ? 200 : 100)
                .animation(.interpolatingSpring)
            
            Button("Toggle Animation") {
                withAnimation {
                    self.isAnimating.toggle()
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
