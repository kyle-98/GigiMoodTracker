import SwiftUI

struct CalendarView: View {
    let calendar = Calendar.current
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let moodImages = ["bad", "neutral", "good"]

    @State private var moodSelections: [String: String] = [:]
    @State private var currentDate = Date()
    @State private var currentMonth: String = ""
    @State private var showYearPicker = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date()) // Store selected year
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Gigi Mood Tracker")
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    .font(.title2)
                    .fontWeight(.bold)
                
            
                HStack {
                    Button(action: {
                        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
                        loadSelectionsForMonth()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.body)
                            .padding(.leading)
                    }
                    
                    // Tapping on month/year opens the year picker
                    Text(getMonthYearString())
                        .font(.body)
                        .fontWeight(.bold)
                        .onTapGesture {
                            showYearPicker = true
                        }

                    Button(action: {
                        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
                        loadSelectionsForMonth()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.body)
                            .padding(.trailing)
                    }
                }
                .padding(.bottom, 5)
                

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

                    ForEach(0..<firstWeekday, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: columnWidth, height: rowHeight)
                    }

                    ForEach(daysInMonth(), id: \.self) { date in
                        ZStack {
                            VStack(spacing: 0) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.headline)
                                    .foregroundColor(getTextColor(for: date))

                                if let selectedMood = moodSelections[formattedDate(date)] {
                                    Image(selectedMood)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                }
                            }
                            .frame(width: columnWidth, height: rowHeight)
                            .background(getTileColor(for: date))
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1)
                                    .opacity(0.1)
                            )
                        }
                        .contextMenu {
                            if !calendar.isDateInFuture(date) {
                                ForEach(moodImages, id: \.self) { moodImage in
                                    Button(action: {
                                        moodSelections[formattedDate(date)] = moodImage
                                        saveMoodSelection(date: formattedDate(date), moodImage: moodImage)
                                    }) {
                                        Image(moodImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                        Text(moodImage.capitalized)
                                    }
                                }
                                
                                if moodSelections[formattedDate(date)] != nil {
                                    Button(role: .destructive) {
                                        moodSelections.removeValue(forKey: formattedDate(date))
                                        deleteMoodSelection(date: formattedDate(date))
                                    } label: {
                                        Label("Clear Selection", systemImage: "xmark.circle.fill")
                                            .foregroundColor(.red)
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
            DispatchQueue.main.async {
                loadSelectionsForMonth()
            }
        }
        .sheet(isPresented: $showYearPicker) {
            VStack {
                Text("Select Year")
                    .font(.headline)
                    .padding(.top)

                Picker("Year", selection: $selectedYear) {
                    ForEach(2000...2050, id: \.self) { year in
                        Text("\(String(year))")
                            .tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100) // Make the picker smaller
                
                Button("Done") {
                    updateYear(selectedYear)
                    showYearPicker = false
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 0)
            .presentationDetents([.height(250)])
        }
    }

    // Function to update the calendar to a new year while keeping the current month
    private func updateYear(_ year: Int) {
        var components = calendar.dateComponents([.month, .day], from: currentDate)
        components.year = year
        if let newDate = calendar.date(from: components) {
            currentDate = newDate
            selectedYear = year
            loadSelectionsForMonth()
        }
    }

    private func getMonthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    private func loadSelectionsForMonth() {
        let currentMonthKey = getFormattedMonthYearKey()
        currentMonth = currentMonthKey

        var moodSelectionsDict: [String: String] = [:]
        let moodSelections = CoreDataManager.shared.fetchSelections(forMonth: currentMonthKey)

        if !moodSelections.isEmpty {
            moodSelectionsDict = moodSelections.reduce(into: [:]) { result, selection in
                if let date = selection.date, let moodValue = selection.moodValue {
                    result[date] = moodValue
                }
            }
        }

        self.moodSelections = moodSelectionsDict
    }

    private func saveMoodSelection(date: String, moodImage: String) {
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
            return colorScheme == .dark ? Color.blue.opacity(0.4) : Color.blue.opacity(0.2)
        } else if date > Date() {
            return Color.gray.opacity(0.3)
        } else {
            return colorScheme == .dark ? Color.gray.opacity(0.2) : Color(UIColor.systemGray6)
        }
    }

    private func getTextColor(for date: Date) -> Color {
        return colorScheme == .dark ? Color.white : Color.black.opacity(0.8)
    }

    private func getFormattedMonthYearKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: currentDate)
    }

    private func deleteMoodSelection(date: String) {
        CoreDataManager.shared.deleteMoodSelection(dateString: date)
    }
}



// Allow the Calendar object to be able to check if a date is in the future
extension Calendar {
    func isDateInFuture(_ date: Date) -> Bool {
        return date > Date()
    }
}
