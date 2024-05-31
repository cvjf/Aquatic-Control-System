import SwiftUI

struct DevicesView: View {
    
    @AppStorage("username") var username: String = "Guest"
    @AppStorage("devices")
    var devices = SAMPLE_LIGHTS
        
    @State var beaglebone = BeagleboneReader.decodeDeviceState()
    
    @State private var showBottomBar: Bool = false
    @State private var showAlert = false
    @State private var path = NavigationPath()
    
    @State private var reading = ""
    
    var body: some View {
        NavigationStack(path: $path) {
            NavigationLink {
                SpectrumEditingView(light: $devices[0])
                    .navigationTitle(devices[0].name).navigationBarTitleDisplayMode(.inline)
            } label: {
                Text(devices[0].name)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
//            if beaglebone != nil {
//                NavigationLink {
//                    SpectrumEditingView(light: $devices[1])
//                        .navigationTitle(devices[1].name).navigationBarTitleDisplayMode(.inline)
//                } label: {
//                    Text(devices[0].name)
//                        .fontWeight(.black)
//                }
//            }

                        
            Button(action: {
                if let light = BeagleboneReader.decodeDeviceState() {
                    print(light)
                    devices = [light]
                    print(devices)
                }
            }, label: {
                Text("Load from Beaglebone")
            })
            
            Button(action: {
                if let decoded = BeagleboneReader.decodeReading() {
                    reading = decoded
                    showAlert = true
                }
            }, label: {
                Text("Read Beaglebone photoresistor")
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Photoresistor reported \(reading) volts."))
            }
            
            Divider()
            
            Button(action: {
                print(devices[0])
            }, label: {
                Text("Debug: Print current device")
            })
            
            Button(action: {
                UserDefaults.standard.setValue(SAMPLE_LIGHTS.rawValue, forKey: "devices")
            }, label: {
                Text("Debug: Reset user defaults")
            })
        }
        
    }
}

#Preview {
    DevicesView()
}
