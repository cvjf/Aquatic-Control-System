import SwiftUI

struct BreakpointView: View {
    @State var isHighlighted: Bool = false
    
    let height: CGFloat = 3
    
    var body: some View {
        Rectangle()
            .frame(maxHeight: height)
            .foregroundStyle(.background)
            .contentShape(Rectangle())
    }
}

struct GradientRectangle: View {
    var height: CGFloat
    let colors: [Color]
        
    var body: some View {
        Rectangle()
            .fill(Gradient(colors: colors))
            .frame(height: height)
            .cornerRadius(5)
    }
}

struct TimelineViewAlt: View {
    @State private var selection: Int?
    
    @Binding var light: Light
    
    var body: some View {
        HStack {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<light.breakpoints.count, id: \.self) { i in
                        let maxHeight = geometry.size.height - CGFloat(light.breakpoints.count * 2) // maxHeight - (2pt per breakpoint)
                        let nonfinalRectHeight = intervalToHeight(interval: light.breakpoints[i].time, maxHeight: maxHeight)
                        let nonfinalRectOffset = calcOffset(breakpointIndex: i, maxHeight: maxHeight)
                        let breakpointOffset = calcOffset(breakpointIndex: i, maxHeight: maxHeight, isBreakpoint: true)

                        if (i == 0) {
                            GradientRectangle(height: nonfinalRectHeight, colors: [
                                Light.Diode.combinedColor(from: light.breakpoints.last!.diodes),
                                Light.Diode.combinedColor(from: light.breakpoints[i].diodes)
                            ])
                            .offset(y: nonfinalRectOffset)
//                            .onAppear(perform: {
//                                print(nonfinalRectHeight)
//                            })
                        } else {
                            GradientRectangle(height: nonfinalRectHeight, colors: [
                                Light.Diode.combinedColor(from: light.breakpoints[i-1].diodes),
                                Light.Diode.combinedColor(from: light.breakpoints[i].diodes)
                            ])
                            .offset(y: nonfinalRectOffset)
                            .onAppear(perform: {
                                print("\(nonfinalRectHeight) + \(calcOffset(breakpointIndex: i, maxHeight: maxHeight)) ")
                            })
                        }
                        ZStack {
                            BreakpointView()
                                .offset(y: breakpointOffset)
//                                .onAppear(perform: {
//                                    print("\(i): \(calcOffset(breakpointIndex: i, maxHeight: maxHeight, isBreakpoint: true)) / \(geometry.size.height) ")
//                                })
                                .gesture(DragGesture(minimumDistance: 0)
                                    .onChanged({ gesture in
                                        print("dragged \(gesture.translation.height)")
                                    }))
                        }
                        
                        if (i == light.breakpoints.endIndex - 1) {
                            let offset = calcOffset(breakpointIndex: i, maxHeight: maxHeight, isLastRectangle: true)
                            GradientRectangle(height: geometry.size.height - offset, colors: [
                                Light.Diode.combinedColor(from: light.breakpoints[i].diodes),
                            ])
                            .offset(y: offset)
                        }
                    }
                }
            }
        }
    }
    
    func calcOffset(breakpointIndex: Int, maxHeight: CGFloat, isBreakpoint: Bool = false, isLastRectangle: Bool = false) -> CGFloat {
        var totalInterval: TimeInterval = 0
        
        let endIndex = isBreakpoint || isLastRectangle ? breakpointIndex + 1 : breakpointIndex

        for i in 0 ..< endIndex {
            totalInterval += light.breakpoints[i].time
        }
        
        var offset = intervalToHeight(interval: totalInterval, maxHeight: maxHeight) + CGFloat(breakpointIndex) * 2
        if isLastRectangle {
            offset += 2
        }

//        print("breakpoint: \(breakpointIndex), interval: \(totalInterval), offset: \(offset) / \(maxHeight), breakpoint? \(isBreakpoint), lastRect? \(isLastRectangle)")
        return offset
    }
    
    func intervalToHeight(interval: TimeInterval, maxHeight: CGFloat) -> CGFloat {
        return maxHeight * interval / 86400.0
    }
    
    func heightToInterval(height: CGFloat, maxHeight: CGFloat) -> TimeInterval {
        return (height / maxHeight) * 86400.0
    }
}

struct TimelineView: View {
    
    @Binding var light: Light
    @Binding var selected: Int?
    
    private let maxTimestamp = 86400.0

    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(spacing: 0) {
                    if light.breakpoints.isEmpty {
                        GradientRectangle(height: .infinity, colors: [.black])
                    } else {
                        ForEach(0..<light.breakpoints.count, id: \.self) { i in
                            let maxHeightWithoutBreakpoints = geometry.size.height - CGFloat(light.breakpoints.count) * 3
                            let rectangleHeight = rectangleHeight(at: i, maxHeight: maxHeightWithoutBreakpoints)
                            
                            if (i == 0) {
                                GradientRectangle(height: rectangleHeight, colors: [
                                    Light.Diode.combinedColor(from: light.breakpoints.last!.diodes),
                                    Light.Diode.combinedColor(from: light.breakpoints[i].diodes)
                                ])
                            } else {
                                GradientRectangle(height: rectangleHeight, colors: [
                                    Light.Diode.combinedColor(from: light.breakpoints[i-1].diodes),
                                    Light.Diode.combinedColor(from: light.breakpoints[i].diodes)
                                ])
                            }
                            ZStack {
                                if i == selected {
                                    BreakpointView()
                                        .overlay(content: {
                                            Text("\(light.breakpoints[i].time.timeStringUS())")
                                                .font(Font.system(size: 12, design: .default))
                                                .tracking(0.12)
                                                .foregroundStyle(Color.black)
                                                .frame(width: 50, height: 25)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.white.opacity(0.9))
                                                        .shadow(color: .black, radius: 15)
                                                )
                                                .onTapGesture {
                                                    print("try to change time")
                                                }
                                        })
                                } else {
                                    BreakpointView()
                                        .onTapGesture {
                                            withAnimation {
                                                selected = i
                                            }
                                        }
                                }
                            }
                            .zIndex(1)
                            if (i == light.breakpoints.endIndex - 1) {
                                GradientRectangle(height: .infinity, colors: [
                                    Light.Diode.combinedColor(from: light.breakpoints[i].diodes),
                                ])
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func rectangleHeight(at index: Int, maxHeight: CGFloat) -> CGFloat {
        let lastTimestamp = index <= 0 ? 0.0 : light.breakpoints[index-1].time
        let timeDifference = light.breakpoints[index].time - lastTimestamp
        return maxHeight * timeDifference / maxTimestamp
    }
}

#Preview {
    HStack {
        TimelineView(light: getMockLight(), selected: .constant(1))
            .frame(width: 40)
    }
}
