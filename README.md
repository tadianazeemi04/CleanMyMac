# 🧘‍♂️ ZenClean Pro: The Premium macOS Utility

**ZenClean Pro** is a state-of-the-art macOS cleaning utility designed with a focus on **Liquid Glass** aesthetics, data safety, and high-performance system analysis. Built for developers and power users who value both their disk space and their desktop's visual harmony.

![ZenClean Dashboard Placeholder](https://img.shields.io/badge/Design-Liquid%20Glass-FF512F?style=for-the-badge&logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-00f2fe?style=for-the-badge&logo=swift)

---

## ✨ Features

### 💎 Next-Gen Aesthetics
*   **Liquid Glass Interface**: Deep background refraction and semi-transparent layers that feel part of macOS.
*   **Mesh Gradients**: Dynamic, slow-moving backgrounds that provide a calm, "Zen" atmosphere.
*   **Concentric Geometry**: High-end visualizations of disk health and junk distribution.

### 🧹 Powerful Cleaning Engine
*   **Smart Junk Scanner**: Targets System Caches, User Logs, Mail Downloads, and massive **Xcode DerivedData** (often 20GB+).
*   **Large Files Finder**: Scout your home directory for files larger than **200 MB** to reclaim massive amounts of space.
*   **Selective Cleaning**: Precision control via checkboxes—delete everything or just specific folders.

### 🛡️ Safety & Privacy First
*   **Trash-Safe Deletion**: ZenClean never permanently deletes your data. It uses the `trashItem` API to safely move junk to the Trash, allowing for easy recovery.
*   **Transparency**: Guided walkthrough for **Full Disk Access** permissions, ensuring you remain in control of your system's security.
*   **Zero Telemetry**: All analysis happens locally on your Mac. No data ever leaves your device.

---

## 🛠 Project Architecture

ZenClean Pro is built with a clean, modular Swift architecture:
- `Models/`: Type-safe data structures for junk categorization.
- `Engine/`: The high-performance scanning unit utilizing `FileManager` and `async/await`.
- `UI/`: A collection of SwiftUI views optimized for macOS performance.
- `Core/`: Design system tokens, premium styling modifiers, and App entry.

---

## 🚀 Getting Started

1.  **Clone & Open**: Open the `.xcodeproj` file in Xcode (Version 14.0+ recommended).
2.  **Permissions**:
    - For full functionality, enable **Full Disk Access** in *System Settings > Privacy & Security*.
    - The app will guide you through this process on its first launch.
3.  **Build & Run**: Hit `Cmd + R` to experience ZenClean Pro.

---

## 📜 Dev Rationale (The "Vibe")
ZenClean Pro was developed using **"Vibe Coding"** principles—blending high-end design aesthetics with robust, modern Swift code. Every animation and shadow is tuned to feel "premium" and native to the Apple ecosystem.

---

### ⚠️ Disclaimer
*ZenClean Pro is a system utility. While highly safe, always ensure your important work is saved before performing major system purges.*

**Crafted with ❤️ for the macOS Community.**
