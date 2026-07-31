# AI Outfit Stylist

AI Outfit Stylist is an intelligent, AI-powered mobile application built with Flutter that acts as your personal fashion assistant. By combining a sleek mobile frontend with a powerful AI backend, it seamlessly manages your digital wardrobe, curates stylish outfit recommendations, and provides feedback on your style!

## 📱 Features

* **Digital Wardrobe Management:** Easily snap photos and upload your clothing. The AI automatically groups and categorizes your clothes by color, pattern, season, and style.
* **AI Outfit Generator:** Never wonder what to wear again! Give the AI an occasion (e.g., Casual, Formal, Party), the current weather, and the season, and it will instantly build a complete, stylish outfit from the clothes you own.
* **Outfit Rater:** Upload a picture of your current outfit and let our AI analyze your style, giving you a rating and tips on how to improve your look.
* **Saved Outfits:** Keep a collection of your favorite AI-generated fits to recreate later. 

## 🏗️ Architecture

The project is split into two primary components that communicate seamlessly:

1. **Frontend (Flutter):** 
   * Cross-platform mobile development using Flutter and Dart.
   * Target Platforms: Android and iOS.
   * State Management: Cubit / BLoC.
   * Sleek, modern UI with dynamic, AI-generated components.
   
2. **Backend (FastAPI & AI Models):**
   * Processes image uploads and segments clothing items.
   * Powers the recommendation engine using computer vision properties (clothing type, color, hex, confidence, etc.).

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (Targeting Android and iOS)
* Dart SDK
* An active instance of the AI Backend running locally or on a server.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/ai-outfit-stylist.git
   cd ai-outfit-stylist
