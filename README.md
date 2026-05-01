# 🧬 Pepmax Health Optimization

> A powerful, offline-first iOS application for tracking, analyzing, and optimizing Peptide, Hormone Replacement Therapy (HRT), and Steroid protocols. Built with a privacy-first approach featuring local AI integration.

![Swift](https://img.shields.io/badge/Swift-5.8-orange.svg)
![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Build](https://github.com/harshitsiwach/pepmaxxing/actions/workflows/ios.yml/badge.svg)

---

## 🌟 The Ultimate Tracking Suite

* **🤖 Local AI Assistant**: Privacy-first, offline LLM integration (powered by llama.cpp/GGUF) built directly into the app to answer questions regarding compound half-lives, stacking protocols, and health advice without sending your data to the cloud.
* **🗺️ 2D Interactive Rotation Map**: A stunning visual body heatmap tracking your injection sites. Avoid scar tissue buildup by visualizing exactly when and where your last injection was placed (color-coded by tissue recovery time).
* **🩸 Bloodwork & Biomarker Module**: Log and visualize your lab results natively using interactive line charts. Track Free Testosterone, E2, Liver Enzymes (AST/ALT), Lipids (HDL/LDL), and IGF-1 to monitor health markers safely alongside your cycles.
* **🛡️ PCT Wizard (Post Cycle Therapy)**: A dedicated recovery protocol planner that recommends and tracks medication schedules (e.g., Nolvadex, Clomid) post-cycle to help restore natural hormone production.
* **📸 Progress Photo Vault**: Securely store your physique updates locally within the app’s document directory. Track muscle growth and fat loss with date-stamped photo grids and a full-screen pinch-to-zoom viewer.
* **📚 Comprehensive Encyclopedia**: An offline database of over 100+ peptides and steroids, offering deep dives into dosages, half-lives, mechanisms, routes of administration, and clinical status.
* **📊 Cycle Analytics & Dashboard**: Visual dashboard featuring a 30-day injection heatmap, lifetime usage statistics, and active cycle tracking.
* **⚖️ Side-by-Side Comparison**: Select 2 to 3 compounds to compare their dosing ranges, effects, and clinical statuses side-by-side.
* **🔒 Biometric Security**: Secure your medical and cycle data using Face ID, Touch ID, or Passcode via our native App Lock.
* **🎨 Liquid Glass Aesthetic**: Stunning UI utilizing glassmorphism, dynamic gradients, and custom haptics for an incredibly premium user experience.

---

## 🛠️ Technology Stack

* **Frontend Framework**: SwiftUI (iOS 16+)
* **Architecture**: MVVM with custom `AppStore` environment object
* **Charts Framework**: Native Apple `Charts`
* **Local Inference Engine**: GGUF / Llama.cpp backend for offline AI chat
* **Security**: `LocalAuthentication` Framework
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

**Pepmax is for educational and informational purposes only.** It does not constitute medical advice. Always consult a qualified healthcare professional before beginning any new medication, peptide, hormone, or wellness protocol.

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
