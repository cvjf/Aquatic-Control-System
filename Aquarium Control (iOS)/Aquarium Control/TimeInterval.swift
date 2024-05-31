import Foundation

extension TimeInterval {
    func timeStringHHMM() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        guard let timeString = formatter.string(from: self) else {
            return ""
        }
        return timeString
    }
    
    func timeStringUS() -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let time = startOfDay.addingTimeInterval(self)

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
//        formatter.timeStyle = .short
        
        return formatter.string(from: time)
    }

}
