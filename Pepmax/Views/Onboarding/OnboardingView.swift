import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var currentStep = 0
    @State private var selectedGender: UserProfile.Gender = .male
    @State private var weightText = "75"
    @State private var heightText = "175"
    @State private var ageText = "30"
    @State private var selectedActivity: UserProfile.ActivityLevel = .moderate
    @State private var selectedCountry = "United States"
    @State private var selectedUnit: UserProfile.UnitSystem = .metric
    @State private var animateIn = false
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    private let totalSteps = 4
    
    let countries = ["United States", "United Kingdom", "Canada", "Australia", "Germany", "India", "Japan", "Brazil", "France", "Netherlands", "Other"]
    
    // Computed BMI
    private var bmi: Double {
        let w = Double(weightText) ?? 0
        let h = Double(heightText) ?? 0
        guard h > 0 else { return 0 }
        let hm = (selectedUnit == .metric ? h : h * 2.54) / 100.0
        let wkg = selectedUnit == .metric ? w : w / 2.20462
        return wkg / (hm * hm)
    }
    
    private var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        case 30...: return "Obese"
        default: return "—"
        }
    }
    
    private var bmiColor: Color {
        switch bmi {
        case ..<18.5: return Color(hex: "FFB800")
        case 18.5..<25: return Color(hex: "00FF87")
        case 25..<30: return Color(hex: "FFB800")
        case 30...: return Color(hex: "FF2D55")
        default: return Color(hex: "A29BFE")
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            theme.background.ignoresSafeArea()
            
            // Animated gradient orbs
            backgroundOrbs
            
            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Content
                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    bodyStep.tag(1)
                    activityStep.tag(2)
                    summaryStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5), value: currentStep)
                
                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateIn = true
            }
        }
    }
    
    // MARK: - Background Orbs
    
    private var backgroundOrbs: some View {
        ZStack {
            Circle()
                .fill(theme.primary.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color(hex: "6C5CE7").opacity(0.06))
                .frame(width: 250, height: 250)
                .blur(radius: 60)
                .offset(x: 150, y: 100)
            
            Circle()
                .fill(theme.primary.opacity(0.05))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -50, y: 300)
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 3)
                    .fill(step <= currentStep ? theme.primary : Color.white.opacity(0.12))
                    .frame(height: 4)
                    .animation(.spring(response: 0.4), value: currentStep)
            }
        }
    }
    
    // MARK: - Step 1: Welcome
    
    private var welcomeStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 40)
                
                // Logo / Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [theme.primary.opacity(0.3), theme.primary.opacity(0.0)],
                                center: .center, startRadius: 0, endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(theme.primary.opacity(0.12))
                        .frame(width: 100, height: 100)
                        .overlay {
                            Circle().stroke(theme.primary.opacity(0.3), lineWidth: 1)
                        }
                    
                    Image(systemName: "pills.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(theme.primary)
                }
                .opacity(animateIn ? 1 : 0)
                .scaleEffect(animateIn ? 1 : 0.5)
                
                VStack(spacing: 12) {
                    Text("Welcome to")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                    
                    Text("Pepmax")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.clear)
                        .overlay {
                            LinearGradient(
                                colors: [theme.primary, theme.primarySoft],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .mask(
                                Text("Pepmax")
                                    .font(.system(size: 40, weight: .bold))
                            )
                        }
                    
                    Text("Your personal peptide encyclopedia,\ntracker, and dosage calculator")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(theme.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
                
                // Gender selection
                VStack(spacing: 14) {
                    Text("I am")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.textMuted)
                    
                    HStack(spacing: 16) {
                        ForEach(UserProfile.Gender.allCases, id: \.self) { gender in
                            genderCard(gender)
                        }
                    }
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 30)
                
                // Unit system
                VStack(spacing: 10) {
                    Text("Measurement System")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.textMuted)
                    
                    HStack(spacing: 10) {
                        ForEach(UserProfile.UnitSystem.allCases, id: \.self) { unit in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedUnit = unit
                                }
                            } label: {
                                Text(unit.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(selectedUnit == unit ? .white : theme.textMuted)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background {
                                        Capsule()
                                            .fill(selectedUnit == unit ? theme.primary : Color.white.opacity(0.06))
                                            .overlay {
                                                Capsule().stroke(selectedUnit == unit ? theme.primary.opacity(0.5) : theme.glassBorder, lineWidth: 1)
                                            }
                                    }
                                    .shadow(color: selectedUnit == unit ? theme.primary.opacity(0.3) : .clear, radius: 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func genderCard(_ gender: UserProfile.Gender) -> some View {
        Button {
            withAnimation(.spring(response: 0.35)) {
                selectedGender = gender
            }
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(selectedGender == gender ? theme.primary.opacity(0.15) : Color.white.opacity(0.04))
                        .frame(width: 70, height: 70)
                    Image(systemName: gender.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(selectedGender == gender ? theme.primary : theme.textMuted)
                }
                Text(gender.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedGender == gender ? theme.text : theme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isDarkMode ? .ultraThinMaterial : .regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(selectedGender == gender ? theme.primary.opacity(0.5) : theme.glassBorder, lineWidth: selectedGender == gender ? 2 : 1)
                    }
            }
            .shadow(color: selectedGender == gender ? theme.primary.opacity(0.2) : .clear, radius: 12)
            .scaleEffect(selectedGender == gender ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Step 2: Body Metrics
    
    private var bodyStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)
                
                VStack(spacing: 8) {
                    Text("Your Body")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(theme.text)
                    Text("Help us personalize your dosage calculations")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textMuted)
                }
                
                // Age
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundStyle(Color(hex: "6C5CE7"))
                            Text("Age")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(theme.text)
                        }
                        HStack {
                            TextField("30", text: $ageText)
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundStyle(theme.text)
                                .keyboardType(.numberPad)
                                .tint(theme.primary)
                            Text("years")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                        }
                    }
                }
                
                // Height
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "ruler.fill")
                                .foregroundStyle(Color(hex: "00B894"))
                            Text("Height")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(theme.text)
                        }
                        HStack {
                            TextField(selectedUnit == .metric ? "175" : "69", text: $heightText)
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundStyle(theme.text)
                                .keyboardType(.decimalPad)
                                .tint(theme.primary)
                            Text(selectedUnit == .metric ? "cm" : "inches")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                        }
                    }
                }
                
                // Weight
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "scalemass.fill")
                                .foregroundStyle(theme.primary)
                            Text("Weight")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(theme.text)
                        }
                        HStack {
                            TextField(selectedUnit == .metric ? "75" : "165", text: $weightText)
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundStyle(theme.text)
                                .keyboardType(.decimalPad)
                                .tint(theme.primary)
                            Text(selectedUnit == .metric ? "kg" : "lbs")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                        }
                    }
                }
                
                // BMI Preview
                if bmi > 0 {
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your BMI")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(theme.textMuted)
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(String(format: "%.1f", bmi))
                                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                                        .foregroundStyle(bmiColor)
                                    Text(bmiCategory)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(bmiColor)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background { Capsule().fill(bmiColor.opacity(0.12)) }
                                }
                            }
                            Spacer()
                            GlowRing(color: bmiColor, progress: min(bmi / 40.0, 1.0), lineWidth: 6)
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                
                // Country
                GlassCard {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                                .foregroundStyle(Color(hex: "E056A0"))
                            Text("Country")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(theme.text)
                        }
                        Spacer()
                        Picker("", selection: $selectedCountry) {
                            ForEach(countries, id: \.self) { c in
                                Text(c).tag(c)
                            }
                        }
                        .tint(theme.primary)
                    }
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Step 3: Activity Level
    
    private var activityStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)
                
                VStack(spacing: 8) {
                    Text("Activity Level")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(theme.text)
                    Text("This helps fine-tune dosage recommendations")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textMuted)
                }
                
                ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { level in
                    activityCard(level)
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func activityCard(_ level: UserProfile.ActivityLevel) -> some View {
        Button {
            withAnimation(.spring(response: 0.35)) {
                selectedActivity = level
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(selectedActivity == level ? theme.primary.opacity(0.15) : Color.white.opacity(0.04))
                        .frame(width: 52, height: 52)
                    Image(systemName: level.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(selectedActivity == level ? theme.primary : theme.textMuted)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(level.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(selectedActivity == level ? theme.text : theme.textMuted)
                    Text(activityDescription(level))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(theme.textMuted.opacity(0.7))
                }
                
                Spacer()
                
                if selectedActivity == level {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(theme.primary)
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isDarkMode ? .ultraThinMaterial : .regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(selectedActivity == level ? theme.primary.opacity(0.5) : theme.glassBorder, lineWidth: selectedActivity == level ? 2 : 1)
                    }
            }
            .shadow(color: selectedActivity == level ? theme.primary.opacity(0.15) : .clear, radius: 12)
        }
        .buttonStyle(.plain)
    }
    
    private func activityDescription(_ level: UserProfile.ActivityLevel) -> String {
        switch level {
        case .sedentary: return "Little or no exercise, desk job"
        case .light: return "Light exercise 1–3 days/week"
        case .moderate: return "Moderate exercise 3–5 days/week"
        case .active: return "Hard exercise 6–7 days/week"
        case .extreme: return "Very hard exercise, physical job"
        }
    }
    
    // MARK: - Step 4: Summary
    
    private var summaryStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)
                
                VStack(spacing: 8) {
                    Text("All Set!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(theme.text)
                    Text("Here's your profile summary")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textMuted)
                }
                
                // Profile Summary Card
                GlassCard(padding: 20) {
                    VStack(spacing: 20) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [theme.primary, theme.primarySoft],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)
                            Image(systemName: selectedGender.icon)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        
                        // Stats grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            summaryItem(title: "Gender", value: selectedGender.rawValue, icon: "person.fill")
                            summaryItem(title: "Age", value: "\(ageText) yrs", icon: "calendar")
                            summaryItem(title: "Height", value: "\(heightText) \(selectedUnit == .metric ? "cm" : "in")", icon: "ruler.fill")
                            summaryItem(title: "Weight", value: "\(weightText) \(selectedUnit == .metric ? "kg" : "lbs")", icon: "scalemass.fill")
                        }
                        
                        // BMI
                        if bmi > 0 {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("BMI")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(theme.textMuted)
                                    HStack(spacing: 6) {
                                        Text(String(format: "%.1f", bmi))
                                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                                            .foregroundStyle(bmiColor)
                                        Text(bmiCategory)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(bmiColor)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background { Capsule().fill(bmiColor.opacity(0.12)) }
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("Activity")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(theme.textMuted)
                                    Text(selectedActivity.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(theme.primary)
                                }
                            }
                            .padding(14)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(isDarkMode ? 0.04 : 0.3))
                            }
                        }
                        
                        // Country
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                                .foregroundStyle(Color(hex: "E056A0"))
                            Text(selectedCountry)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(theme.text)
                            Spacer()
                            Text(selectedUnit.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(theme.textMuted)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background { Capsule().fill(Color.white.opacity(0.06)) }
                        }
                    }
                }
                
                // Peptide count teaser
                GlassCard {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(theme.primary.opacity(0.12))
                                .frame(width: 48, height: 48)
                            Image(systemName: "book.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(theme.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("134 Peptides Ready")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(theme.text)
                            Text("Encyclopedia • Tracker • Calculator")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                        }
                        Spacer()
                    }
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func summaryItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.primary)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(theme.text)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isDarkMode ? 0.04 : 0.3))
        }
    }
    
    // MARK: - Navigation
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(theme.textMuted)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background {
                        Capsule()
                            .fill(Color.white.opacity(isDarkMode ? 0.06 : 0.5))
                            .overlay { Capsule().stroke(theme.glassBorder, lineWidth: 1) }
                    }
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            GlowButton(
                title: currentStep == totalSteps - 1 ? "Get Started" : "Continue",
                icon: currentStep == totalSteps - 1 ? "arrow.right" : "chevron.right"
            ) {
                if currentStep < totalSteps - 1 {
                    withAnimation(.spring(response: 0.4)) {
                        currentStep += 1
                    }
                } else {
                    completeOnboarding()
                }
            }
        }
    }
    
    // MARK: - Complete Onboarding
    
    private func completeOnboarding() {
        let weightKg: Double
        let heightCm: Double
        
        if selectedUnit == .metric {
            weightKg = Double(weightText) ?? 75
            heightCm = Double(heightText) ?? 175
        } else {
            weightKg = (Double(weightText) ?? 165) / 2.20462
            heightCm = (Double(heightText) ?? 69) * 2.54
        }
        
        store.profile = UserProfile(
            gender: selectedGender,
            weight: weightKg,
            height: heightCm,
            age: Int(ageText) ?? 30,
            activityLevel: selectedActivity,
            country: selectedCountry,
            isDarkMode: true,
            unitSystem: selectedUnit,
            hasCompletedOnboarding: true
        )
    }
}
