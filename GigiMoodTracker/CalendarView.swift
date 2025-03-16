import SwiftUI

struct CalendarView: View {
    let calendar = Calendar.current
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // Add custom image names to the array
    let moodImages = ["bad", "neutral", "good"] // These are the image names you added to the asset catalog

    @State private var moodSelections: [String: String] = [:]
    @State private var currentDate = Date()

    @Environment(\.colorScheme) var colorScheme // Access the current color scheme (light/dark)

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
                                    .foregroundColor(colorScheme == .dark ? .white : .black) // Adjust text color for dark mode

                                if let selectedMood = moodSelections[formattedDate(date)] {
                                    Image(selectedMood) // Show selected image based on the mood key
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40) // Adjust size of the image
                                }
                            }
                            .frame(width: columnWidth, height: rowHeight) // Ensure each day has equal width and height
                            .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white) // Adapt to light/dark theme
                            .overlay( // Apply border only to the outer edges of the calendar grid
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        .onLongPressGesture {
                            // Show the context menu for the selected date on long press
                        }
                        .contextMenu {
                            // Add custom images to the context menu
                            ForEach(moodImages, id: \.self) { moodImage in
                                Button(action: {
                                    // Save the selected image for the specific date
                                    moodSelections[formattedDate(date)] = moodImage
                                }) {
                                    HStack {
                                        Image(moodImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40) // Set the size for each image in the menu
                                        Text(moodImage.capitalized) // Display text next to the image
                                            .font(.body)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 10) // Apply slight padding to the entire grid for left and right margins
                .border(Color.black, width: 1) // Add border around the entire calendar grid
            }
        }
    }

    // Function to get the month and year string (e.g., "March 2025")
    private func getMonthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    // Function to get first day of the current month
    private func getFirstDayOfMonth() -> Date {
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        return calendar.date(from: components)!
    }

    // Function to get all days in the current month
    private func daysInMonth() -> [Date] {
        let firstDay = getFirstDayOfMonth()
        let range = calendar.range(of: .day, in: .month, for: firstDay)!
        return range.map { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
        }
    }

    // Function to format date as a string
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
