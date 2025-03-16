import SwiftUI

struct CalendarView: View {
    let calendar = Calendar.current
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // Add custom image names to the array
    let moodImages = ["bad", "neutral", "good"]

    @State private var moodSelections: [String: String] = [:]
    @State private var currentDate = Date()
    @Environment(\.colorScheme) var colorScheme
    @State private var currentMonth: String = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Month and Year at the top with previous and next buttons
                HStack {
                    Button(action: {
                        // Go to previous month
                        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
                        loadSelectionsForMonth()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .padding(.leading)
                    }

                    Text(getMonthYearString())
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                        .padding(.bottom, 10)

                    Button(action: {
                        // Go to next month
                        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
                        loadSelectionsForMonth()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title)
                            .padding(.trailing)
                    }
                }
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
                let columnWidth = (geometry.size.width - 40) / 7 // Adjust column width based on screen size
                let rowHeight: CGFloat = 90 // Set a fixed height for each row

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(columnWidth), spacing: 0), count: 7), spacing: 0) {
                    let firstDayOfMonth = getFirstDayOfMonth()
                    let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1 // Adjust for Sunday start

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
                                    .foregroundColor(getTextColor(for: date)) // Adjust text color based on theme

                                if let selectedMood = moodSelections[formattedDate(date)] {
                                    Image(selectedMood) // Show selected image based on the mood key
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40) // Adjust size of the image
                                }
                            }
                            .frame(width: columnWidth, height: rowHeight)
                            .background(getTileColor(for: date)) // Set background color for each square
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1)
                                    .opacity(0.1) // Lighten the border for a softer look
                            )
                        }
                        .contextMenu {
                            // Only allow mood selection if the date is not in the future
                            if !calendar.isDateInFuture(date) {
                                ForEach(moodImages, id: \.self) { moodImage in
                                    Button(action: {
                                        moodSelections[formattedDate(date)] = moodImage
                                        saveMoodSelection(date: formattedDate(date), moodImage: moodImage) // Save to Core Data
                                    }) {
                                        Image(moodImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                        Text(moodImage.capitalized)
                                    }
                                }
                            } else {
                                Text("No mood selection for future days")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .border(Color.black, width: 1)
            }
        }
        .onAppear {
            loadSelectionsForMonth() // Load selections when the view appears
        }
    }

    // Function to get the month and year string (e.g., "March 2025")
    private func getMonthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    private func loadSelectionsForMonth() {
        // Get the current month in "YYYY-MM" format
        let currentMonthKey = getFormattedMonthYearKey()
        currentMonth = currentMonthKey

        var moodSelectionsDict: [String: String] = [:]  // Store date as String as per your Core Data model

        // Fetch all the moods for the current month (by date)
        let moodSelections = CoreDataManager.shared.fetchSelections(forMonth: currentMonthKey)

        // Check if there are any mood selections
        if !moodSelections.isEmpty {
            // Map fetched selections into a dictionary with string as key and moodValue as value
            moodSelectionsDict = moodSelections.reduce(into: [:]) { result, selection in
                if let date = selection.date, let moodValue = selection.moodValue {
                    result[date] = moodValue  // Store the date string as key
                }
            }
        }

        // Update the moodSelections dictionary for the UI display
        self.moodSelections = moodSelectionsDict
    }

    // Save the mood selection to Core Data
    private func saveMoodSelection(date: String, moodImage: String) {
        // Check if this date already exists
        CoreDataManager.shared.updateMoodSelection(dateString: date, moodValue: moodImage)
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

    private func getTileColor(for date: Date) -> Color {
        if calendar.isDateInToday(date) {
            return Color.blue.opacity(0.2)
        } else if date > Date() {
            return Color.gray.opacity(0.3)
        } else {
            if colorScheme == .dark {
                return Color.gray.opacity(0.2)
            } else {
                return Color(UIColor.systemGray6)
            }
        }
    }

    private func getTextColor(for date: Date) -> Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black.opacity(0.8)
        }
    }

    private func getFormattedMonthYearKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: currentDate)
    }
}

extension Calendar {
    func isDateInFuture(_ date: Date) -> Bool {
        return date > Date() // Check if the date is in the future
    }
}
