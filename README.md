# 🧬 Pepmax

> An offline-first iOS application for tracking, analyzing, and comparing peptides including Experimental ones.

![Swift](https://img.shields.io/badge/Swift-5.8-orange.svg)
![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Build](https://github.com/harshitsiwach/pepmaxxing/actions/workflows/ios.yml/badge.svg)

---

## 🌟 Key Features

* **📚 Comprehensive Encyclopedia**: An offline database of over 100+ peptides, offering deep dives into dosages, mechanisms, routes of administration, and clinical status.
* **🛡️ Smart Insights & Safety**: Generates real-time interaction warnings and personalized alerts (e.g., Low BMI or Gender-specific contraindications) based on your user profile.
* **📊 Cycle Analytics & Tracking**: Visual dashboard featuring a 30-day injection heatmap, lifetime usage statistics, and active cycle progress tracking.
* **⚖️ Side-by-Side Comparison**: Select 2 to 3 peptides to compare their dosing range, effects, and clinical status side-by-side.
* **⏰ Intelligent Local Reminders**: Set recurring daily or weekly injection reminders right on your device.
* **🔒 Biometric Security**: Secure your medical data using Face ID, Touch ID, or Passcode via our native App Lock.
* **📤 Data Portability**: Export your injection logs into a CSV file with a single tap to share with your healthcare provider or keep for personal backups.
* **🎨 Liquid Glass Aesthetic**: Stunning UI utilizing glassmorphism, dynamic gradients, and custom haptics for an incredibly premium user experience.

---

## 🛠️ Technology Stack

* **Frontend Framework**: SwiftUI (iOS 16+)
* **Architecture**: MVVM with custom `AppStore` environment object
* **Security**: `LocalAuthentication` Framework
* **Notifications**: `UserNotifications` Framework
* **Project Generation**: XcodeGen

---

## 🚀 Running Locally

Because Pepmax uses **XcodeGen** to manage its project files, there is no `.xcodeproj` tracked in the repository. You must generate it before opening the project.

### Prerequisites
* **macOS** with **Xcode 14+** installed.
* **Homebrew** installed.

### Setup Instructions

1. **Install XcodeGen**  
   Run the following command in your terminal:
   ```bash
   brew install xcodegen
   ```

2. **Clone the Repository**
   ```bash
   git clone https://github.com/harshitsiwach/pepmaxxing.git
   cd pepmaxxing
   ```

3. **Generate the Xcode Project**
   ```bash
   xcodegen generate
   ```

4. **Run the App**  
   Open the newly generated `Pepmax.xcodeproj` file in Xcode. Select your preferred iOS Simulator (e.g., iPhone 15 Pro) and hit **Run (⌘ + R)**.

---

## ⚠️ Disclaimer

**Pepmax is for educational and informational purposes only.** It does not constitute medical advice. Always consult a qualified healthcare professional before beginning any new medication, peptide, or wellness protocol.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. If you plan on making major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
