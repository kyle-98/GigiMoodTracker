import SwiftUI

struct CalendarView: View {
    let calendar = Calendar.current
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    let moodImages = ["bad", "neutral", "good"]

    @State private var moodSelections: [String: String] = [:]
    @State private var currentDate = Date()

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Month and Year at the top
                Text(getMonthYearString())
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .padding(.bottom, 10)

                // Day of the week headers
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 5)

                // Calendar grid
                let columnWidth = (geometry.size.width - 40) / 7
                let rowHeight: CGFloat = 90

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(columnWidth), spacing: 0), count: 7), spacing: 0) {
                    let firstDayOfMonth = getFirstDayOfMonth()
                    let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1

                    // Empty spaces before the first day of the month
                    ForEach(0..<firstWeekday, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: columnWidth, height: rowHeight)
                    }

                    // Display the actual days of the month
                    ForEach(daysInMonth(), id: \.self) { date in
                        ZStack {
                            VStack(spacing: 0) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.headline)
                                    .foregroundColor(.black)

                                if let selectedMood = moodSelections[formattedDate(date)] {
                                    Image(selectedMood)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                }
                            }
                            .frame(width: columnWidth, height: rowHeight)
                            .background(Color.white)
                            .overlay( // Apply border only to the outer edges of the calendar grid
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        .onLongPressGesture {
                            showContextMenu(for: date)
                        }
                        .contextMenu {
                            ForEach(moodImages, id: \.self) { moodImage in
                                Button(action: {
                                    moodSelections[formattedDate(date)] = moodImage
                                    saveSelections() // Save the new selection
                                }) {
                                    HStack {
                                        Image(moodImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                        Text(moodImage.capitalized) // Add text next to the image
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .border(Color.black, width: 1)
            }
        }
        .onAppear {
            loadSelections() // Load saved selections when the view appears
        }
    }

    // Save the moodSelections to UserDefaults
    private func saveSelections() {
        if let encoded = try? JSONEncoder().encode(moodSelections) {
            UserDefaults.standard.set(encoded, forKey: "moodSelections")
        }
    }

    // Load the moodSelections from UserDefaults
    private func loadSelections() {
        if let savedData = UserDefaults.standard.data(forKey: "moodSelections"),
           let decodedSelections = try? JSONDecoder().decode([String: String].self, from: savedData) {
            moodSelections = decodedSelections
        }
    }

    private func getMonthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    private func getFirstDayOfMonth() -> Date {
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        return calendar.date(from: components)!
    }

    private func daysInMonth() -> [Date] {
        let firstDay = getFirstDayOfMonth()
        let range = calendar.range(of: .day, in: .month, for: firstDay)!
        return range.map { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
