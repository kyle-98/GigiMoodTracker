import SwiftUI

struct CalendarView: View {
    let calendar = Calendar.current
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let moodImages = ["bad", "neutral", "good"] // Map names of images to keys

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
                let rowHeight: CGFloat = 90 // Set a fixed height for each row (this will be the height of all the day squares

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(columnWidth), spacing: 0), count: 7), spacing: 0) {
                    let firstDayOfMonth = getFirstDayOfMonth()
                    let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1 // Adjust for sunday to be at the very left and saturday to be at the very right

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
                                    .foregroundColor(getTextColor(for: date))

                                if let selectedMood = moodSelections[formattedDate(date)] {
                                    Image(selectedMood) // Show selected image based on the selected mood key
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40) // Adjust size of the image inside the day square
                                }
                            }
                            .frame(width: columnWidth, height: rowHeight)
                            .background(getTileColor(for: date)) // Set background color for each square
                            // Using overlay instead of border bc border overlaps in the grid making the lines thicker
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1)
                                    .opacity(0.1)
                            )
                        }
                        .contextMenu {
                            // Only allow mood selection if the date is not in the future
                            if !calendar.isDateInFuture(date) {
                                ForEach(moodImages, id: \.self) { moodImage in
                                    Button(action: {
                                        moodSelections[formattedDate(date)] = moodImage
                                        saveMoodSelection(date: formattedDate(date), moodImage: moodImage) // Save selected mood to core data
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
            // Refresh main view on application start to properly fetch all items from core data
            DispatchQueue.main.async {
                loadSelectionsForMonth() // Load selections when the view appears
            }
        }
    }

    // Function to get the month and year string (e.g. March 2025)
    private func getMonthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    private func loadSelectionsForMonth() {
        // Get the current month in "YYYY-MM" format
        let currentMonthKey = getFormattedMonthYearKey()
        currentMonth = currentMonthKey

        var moodSelectionsDict: [String: String] = [:]  // Store date as string, this maps to the entity object in the core data

        // Fetch all the moods for the current month (by day)
        let moodSelections = CoreDataManager.shared.fetchSelections(forMonth: currentMonthKey)

        // Check if there are any mood selections
        if !moodSelections.isEmpty {
            // Map fetched selections into a dictionary with string as key and moodValue as value
            moodSelectionsDict = moodSelections.reduce(into: [:]) { result, selection in
                if let date = selection.date, let moodValue = selection.moodValue {
                    result[date] = moodValue  // Store the date string as key and the selected mood as the value
                }
            }
        }

        // Update the moodSelections dictionary for the UI display
        self.moodSelections = moodSelectionsDict
    }

    // Save the mood selection to core data
    private func saveMoodSelection(date: String, moodImage: String) {
        CoreDataManager.shared.updateMoodSelection(dateString: date, moodValue: moodImage)
    }

    // Get the first day of the current/selected month
    private func getFirstDayOfMonth() -> Date {
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        return calendar.date(from: components)!
    }
    
    // Get the number of days in the current/selected month
    private func daysInMonth() -> [Date] {
        let firstDay = getFirstDayOfMonth()
        let range = calendar.range(of: .day, in: .month, for: firstDay)!
        return range.map { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
        }
    }

    // Format a date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // Get the color of a day square, if days in past or current, these will be available for the user to select moods for
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

    // Get the text color of the day numbers depending on the device theme
    private func getTextColor(for date: Date) -> Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black.opacity(0.8)
        }
    }

    // Get the format of the current/selected month so it can be used to find all data for that month in core data
    private func getFormattedMonthYearKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: currentDate)
    }
}

// Allow the Calendar object to be able to check if a date is in the future
extension Calendar {
    func isDateInFuture(_ date: Date) -> Bool {
        return date > Date()
    }
}
