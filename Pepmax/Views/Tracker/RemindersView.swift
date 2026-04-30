import SwiftUI

struct RemindersView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @StateObject private var notifications = NotificationManager.shared
    @State private var showAddReminder = false
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(Color(hex: "FFB800"))
                    Text("Reminders")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(theme.text)
                }
                Spacer()
                Button {
                    showAddReminder = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(theme.primary)
                }
                .buttonStyle(.plain)
            }
            
            if !notifications.isAuthorized {
                // Permission prompt
                GlassCard {
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(theme.textMuted)
                        Text("Enable Notifications")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(theme.text)
                        Text("Get reminded when it's time for your next dose")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(theme.textMuted)
                            .multilineTextAlignment(.center)
                        GlowButton(title: "Enable", icon: "bell.fill", isSmall: true) {
                            notifications.requestPermission()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            } else if notifications.pendingReminders.isEmpty {
                // Empty state
                GlassCard {
                    VStack(spacing: 10) {
                        Image(systemName: "bell")
                            .font(.system(size: 24))
                            .foregroundStyle(theme.textMuted)
                        Text("No reminders set")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                        Text("Tap + to add your first injection reminder")
                            .font(.system(size: 12))
                            .foregroundStyle(theme.textMuted.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            } else {
                // Reminders list
                ForEach(notifications.pendingReminders) { reminder in
                    reminderCard(reminder)
                }
            }
        }
        .sheet(isPresented: $showAddReminder) {
            AddReminderSheet()
                .environmentObject(store)
        }
    }
    
    private func reminderCard(_ reminder: ReminderSchedule) -> some View {
        GlassCard(padding: 14) {
            HStack(spacing: 14) {
                // Time display
                VStack(spacing: 2) {
                    Text(reminder.timeString)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(reminder.isEnabled ? theme.primary : theme.textMuted)
                    Text(reminder.daysString)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                }
                .frame(width: 80)
                
                // Peptide info
                VStack(alignment: .leading, spacing: 3) {
                    Text(reminder.peptideName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(theme.text)
                        .lineLimit(1)
                    Text(reminder.dosage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                }
                
                Spacer()
                
                // Toggle
                Toggle("", isOn: Binding(
                    get: { reminder.isEnabled },
                    set: { _ in notifications.toggleReminder(reminder) }
                ))
                .tint(theme.primary)
                .labelsHidden()
                
                // Delete
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        notifications.removeReminder(reminder)
                        Haptics.impact(.light)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(theme.error.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Add Reminder Sheet

struct AddReminderSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notifications = NotificationManager.shared
    
    @State private var selectedPeptide = ""
    @State private var dosage = ""
    @State private var selectedTime = Date()
    @State private var selectedDays: Set<Int> = []
    @State private var isDaily = true
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    private let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Peptide picker
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "pills.fill")
                                    .foregroundStyle(theme.primary)
                                Text("Peptide")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(theme.text)
                            }
                            
                            Picker("Select Peptide", selection: $selectedPeptide) {
                                Text("Select...").tag("")
                                ForEach(store.peptides, id: \.name) { p in
                                    Text(p.name).tag(p.name)
                                }
                            }
                            .tint(theme.primary)
                        }
                    }
                    
                    // Dosage
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "scalemass.fill")
                                    .foregroundStyle(Color(hex: "00B894"))
                                Text("Dosage")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(theme.text)
                            }
                            TextField("e.g. 250 mcg", text: $dosage)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(theme.text)
                                .tint(theme.primary)
                        }
                    }
                    
                    // Time picker
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .foregroundStyle(Color(hex: "6C5CE7"))
                                Text("Time")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(theme.text)
                            }
                            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                                .tint(theme.primary)
                        }
                    }
                    
                    // Frequency
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .foregroundStyle(Color(hex: "E056A0"))
                                Text("Frequency")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(theme.text)
                            }
                            
                            // Daily toggle
                            HStack {
                                Text("Every day")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                Toggle("", isOn: $isDaily)
                                    .tint(theme.primary)
                                    .labelsHidden()
                                    .onChange(of: isDaily) { _ in
                                        if isDaily { selectedDays.removeAll() }
                                    }
                            }
                            
                            if !isDaily {
                                // Day selector
                                HStack(spacing: 6) {
                                    ForEach(1...7, id: \.self) { day in
                                        let idx = day == 1 ? 0 : day - 1
                                        Button {
                                            withAnimation(.spring(response: 0.3)) {
                                                if selectedDays.contains(day) {
                                                    selectedDays.remove(day)
                                                } else {
                                                    selectedDays.insert(day)
                                                }
                                                Haptics.selection()
                                            }
                                        } label: {
                                            Text(dayNames[idx])
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(selectedDays.contains(day) ? .white : theme.textMuted)
                                                .frame(width: 38, height: 38)
                                                .background {
                                                    Circle()
                                                        .fill(selectedDays.contains(day) ? theme.primary : Color.white.opacity(isDarkMode ? 0.06 : 0.3))
                                                        .overlay {
                                                            Circle().stroke(selectedDays.contains(day) ? theme.primary.opacity(0.5) : theme.glassBorder, lineWidth: 1)
                                                        }
                                                }
                                                .shadow(color: selectedDays.contains(day) ? theme.primary.opacity(0.3) : .clear, radius: 6)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Save button
                    GlowButton(title: "Set Reminder", icon: "bell.badge.fill") {
                        saveReminder()
                    }
                    .opacity(canSave ? 1 : 0.5)
                    .disabled(!canSave)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.textMuted)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private var canSave: Bool {
        !selectedPeptide.isEmpty && !dosage.isEmpty
    }
    
    private func saveReminder() {
        guard canSave else { return }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime)
        let minute = calendar.component(.minute, from: selectedTime)
        
        let reminder = ReminderSchedule(
            peptideName: selectedPeptide,
            dosage: dosage,
            hour: hour,
            minute: minute,
            days: isDaily ? [] : Array(selectedDays).sorted()
        )
        
        notifications.scheduleReminder(reminder)
        dismiss()
    }
}
