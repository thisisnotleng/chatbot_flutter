🌱 Agri_Chatbot

Agri_Chatbot is a Flutter-based AI chatbot designed to assist users with agricultural queries.
It leverages Google’s Gemini 1.5 model with custom context integration to provide accurate, context-aware responses related to farming, crops, soil, weather, and agricultural practices.

Lately, I’m focusing on learning and practicing Flutter & Dart development, and this project is part of that journey.

🚀 Features

🤖 AI-powered chatbot using Gemini 1.5 Model

🌾 Agriculture-focused responses with custom knowledge context

📱 Cross-platform app built with Flutter (Android, iOS, Web)

💬 Simple and intuitive chat-style UI

⚡ Real-time responses via API integration

🔒 Context-aware conversation for more relevant answers

🛠️ Tech Stack

Frontend: Flutter (Dart)

Backend / API: Python Flask 

AI Model: Gemini 1.5

State Management: setState() for local UI state + ValueNotifier/ValueListenableBuilder for theme switching

Database / Storage: MySQL


⚙️ Installation & Setup

Clone the repository

git clone https://github.com/thisisnotleng/chatbot_flutter.git
cd flutter_app


Install dependencies

flutter pub get


Run the app

flutter run

cd python/python_flask

Run the app

python app.py


Configure API Key

Add your Gemini API key and MySQL DB info in python_flask/.env.

📸 Screenshots
<img width="372" height="804" alt="image" src="https://github.com/user-attachments/assets/51ebaf3d-510e-4888-b6f8-a64d036f9052" />

<img width="372" height="810" alt="image" src="https://github.com/user-attachments/assets/d30232be-a8b0-4d2d-9a60-1fe3e916fd29" />

🎯 Roadmap

 Add user authentication (login/signup)

 Store chat history (MySQL)

## License
MIT License
