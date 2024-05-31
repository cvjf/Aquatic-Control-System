import SwiftUI

struct SpectrumEditingView: View {
    
    @State var selectedIndex1 = 0
    @State var selectedIndex2 = 0
    @State var selectedIndex3 = 0
    
    let options1: [SegmentControlItem] = [
        SegmentControlItem(name: "Car"),
        SegmentControlItem(name: "Bike")
    ]
    
    let options2: [SegmentControlItem] = [
        SegmentControlItem(name: "Car", iconString: "car.fill"),
        SegmentControlItem(name: "Bike", iconString: "bicycle"),
        SegmentControlItem(name: "Bus", iconString: "bus"),
    ]
    
    let details: [SegmentControlItem] = [
        SegmentControlItem(iconString: "sun.horizon"),
        SegmentControlItem(iconString: "lightspectrum.horizontal"),
    ]

    @State var selected: Int?
    @Binding var light: Light
    
    private let timelineViewWidth: CGFloat = 40
    
    func forwardSelected() {
        
    }
    
    func backwardSelected() {
    
    }
    
    func addBreakpoint(time: TimeInterval) -> Bool {
        var newTime = time
        var index = 0
        let times = light.breakpoints.map { $0.time }
        for i in 0..<times.count {
            if newTime == times[i] {
                newTime += 30 * 60
            } else if newTime > times[i] && newTime != times[i+1] {
                index = i
                break
            }
        }
        
        var newBreakpoint = light.breakpoints[index-1].copy()
        newBreakpoint.time = newTime
        light.breakpoints.append(newBreakpoint)
        light.breakpoints = light.breakpoints.sorted { $0.time < $1.time }
        return true
    }

    
    func addBreakpoint() {
        guard let selectedIndex = selected else { return }
        let index = min(selectedIndex, light.breakpoints.endIndex - 1)
        var breakpointCopy = light.breakpoints[index].copy()
        breakpointCopy.time += 10 * 60
        light.breakpoints.insert(breakpointCopy, at: index + 1)
        selected = index + 1
    }
    
    func removeBreakpoint() {
        guard let selectedIndex = selected else { return }
        let index = min(selectedIndex, light.breakpoints.endIndex - 1)
        light.breakpoints.remove(at: index)
        selected = nil // Reset selected index
    }


    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                HStack() {
                    TimelineView(light: $light, selected: $selected)
                        .frame(width: timelineViewWidth)
                    if selected != nil {
                        VStack {
                            SegmentControl(
                                selectedIndex: $selectedIndex3,
                                options: details
                            )
                            Spacer()
                            TabView(selection: $selectedIndex3) {
                                EditingView(light: $light, selected: Binding($selected)!)
                                    .tabItem {
                                        Label("Received", systemImage: "tray.and.arrow.down.fill")
                                    }
                                    .tag(0)
                                SpectrumView(light: $light, selected: Binding($selected)!)
                                    .tabItem {
                                        Label("Account", systemImage: "person.crop.circle.fill")
                                    }
                                    .tag(1)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
                        .padding(.leading, 12)
                    } else {
                        
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if selected != nil {
                            Button {
                                selected = nil
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            withAnimation {
                                let index = selected ?? light.breakpoints.endIndex - 1
                                // TODO: check for bounds
                                var breakpointCopy = light.breakpoints[index].copy()
                                breakpointCopy.time += 10 * 60
                                light.breakpoints.insert(breakpointCopy, at: index + 1)
                                selected = index + 1
//                                addBreakpoint()
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        Spacer()
                        Group {
                            Button {
                                withAnimation {
                                    if selected == nil || selected == 0 {
                                        selected = light.breakpoints.endIndex - 1
                                    } else {
                                        selected! -= 1
                                    }
                                }
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                            Button {
                                withAnimation {
                                    if selected == nil || selected == light.breakpoints.endIndex - 1 {
                                        selected = 0
                                    } else {
                                        selected! += 1
                                    }
                                }
                            } label: {
                                Image(systemName: "arrowshape.forward.fill")
                            }
                        }
                        Spacer()
                        Button {
                            withAnimation {
                                _ = light.breakpoints.remove(at: selected!)
                                if light.breakpoints.isEmpty {
                                    selected = nil
                                } else {
                                    selected = selected! <= 0 ? 0 : selected! - 1
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                        }
                        .disabled(selected == nil)

                    }
                }
            }
        }
    }
}

#Preview {
    SpectrumEditingView(light: getMockLight())
}
