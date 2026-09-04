# Basic_GuardRails

A comprehensive AI application guardrails system demonstrating multiple layers of security and safety controls for LLM-powered applications. This project integrates **Google Gemini** with **LangChain** and implements input validation, PII detection, prompt injection prevention, and output filtering.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Running the Backend](#running-the-backend)
  - [API Endpoints](#api-endpoints)
- [Architecture](#architecture)
  - [Guardrails Pipeline](#guardrails-pipeline)
  - [Security Layers](#security-layers)
- [API Response Examples](#api-response-examples)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

**Basic_GuardRails** demonstrates best practices for securing AI applications by implementing a multi-layered guardrail system. The backend processes user requests through a series of safety checks before sending them to the Google Gemini model, ensuring that only safe, legitimate requests are processed.

This project serves as an educational resource for developers looking to implement safety controls in their AI-powered applications.

---

## ✨ Features

### Security & Safety Controls

- **Input Guard**: Validates request format and enforces maximum length constraints
- **PII (Personally Identifiable Information) Detection**: 
  - Email addresses
  - Phone numbers (Indian format support)
  - Payment card numbers (with Luhn validation)
- **Prompt Injection Prevention**: Detects and blocks attempts to manipulate system instructions
- **Output Guard**: Validates model output for safety and length constraints

### AI Integration

- Integration with **Google Gemini** API for intelligent responses
- LangChain framework for reliable LLM communication
- Configurable model selection and parameters
- Comprehensive error handling and logging

### Frontend

- iOS/SwiftUIUI application for client-side interaction
- Seamless communication with backend API

---

## 📁 Project Structure

```
Basic_GuardRails/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py              # FastAPI application & endpoints
│   │   ├── agent.py             # Gemini LLM integration
│   │   └── guardrails/
│   │       ├── __init__.py
│   │       └── guards.py        # Security guard implementations
│   ├── tests/                   # Unit tests
│   ├── requirements.txt         # Python dependencies
│   └── .env.example             # Environment configuration template
├── forntend/
│   └── Guardrails/
│       └── Guardrails/          # iOS SwiftUI application
├── README.md                    # Project documentation
└── .gitignore
```

---

## 🛠️ Tech Stack

### Backend

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Web Framework | FastAPI | High-performance Python web framework |
| Server | Uvicorn | ASGI server for FastAPI |
| LLM Integration | LangChain | Framework for building LLM applications |
| AI Model | Google Gemini | Large language model via Google API |
| Validation | Pydantic | Data validation and schema management |
| Environment | python-dotenv | Environment variable management |

### Frontend

| Component | Technology |
|-----------|-----------|
| Platform | iOS |
| Language | SwiftUI |

---

## 📦 Prerequisites

- **Python 3.8+**
- **Google API Key** (for Gemini access)
- **pip** (Python package manager)
- Xcode (for iOS development)

---

## 🚀 Installation

### Backend Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/VikashKumar1424/Basic_GuardRails.git
   cd Basic_GuardRails
   ```

2. **Navigate to backend directory**

   ```bash
   cd backend
   ```

3. **Create a virtual environment**

   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

4. **Install dependencies**

   ```bash
   pip install -r requirements.txt
   ```

---

## ⚙️ Configuration

### Environment Variables

1. **Create `.env` file** in the `backend/` directory

   ```bash
   cp .env.example .env  # If .env.example exists
   ```

2. **Add your configuration**

   ```env
   GOOGLE_API_KEY=your_google_api_key_here
   GEMINI_MODEL=gemini-3.5-flash
   ```

3. **Obtain Google API Key**
   - Visit [Google AI Studio](https://aistudio.google.com/apikey)
   - Create a new API key
   - Add it to your `.env` file

---

## 💻 Usage

### Running the Backend

1. **Activate virtual environment** (if not already active)

   ```bash
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Start the FastAPI server**

   ```bash
   cd backend
   python -m uvicorn app.main:app --reload
   ```

   The server will start at: `http://localhost:8000`

3. **Access API documentation**

   - **Swagger UI**: http://localhost:8000/docs
   - **ReDoc**: http://localhost:8000/redoc

### API Endpoints

#### Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "ok",
  "service": "langchain-guardrails-gemini"
}
```

#### Chat Endpoint

```http
POST /chat
Content-Type: application/json

{
  "message": "Your question here"
}
```

---

## 🏗️ Architecture

### Guardrails Pipeline

Every user message passes through the following sequential security checks:

```
User Request
    ↓
[1] INPUT GUARD (Format & Length Validation)
    ↓
[2] PII GUARD (PII Detection)
    ↓
[3] INJECTION GUARD (Prompt Injection Detection)
    ↓
[4] GEMINI MODEL (LLM Processing)
    ↓
[5] OUTPUT GUARD (Output Validation)
    ↓
Response to User
```

### Security Layers

#### 1. Input Guard
- Validates that request is not empty
- Enforces maximum length of 2000 characters

#### 2. PII Guard
- **Email Detection**: Uses regex pattern matching
- **Phone Detection**: Supports Indian phone numbers (10 digits starting with 6-9)
- **Card Detection**: Identifies payment cards and validates using Luhn algorithm

#### 3. Injection Guard
Prevents common prompt injection attacks:
- System prompt revelation attempts
- Instruction bypass attempts
- Guardrail disable commands
- Jailbreak attempts

#### 4. Output Guard
- Validates model output is not empty
- Enforces maximum output length of 4000 characters

---

## 📤 API Response Examples

### Successful Request

```json
{
  "allowed": true,
  "answer": "Your AI-generated response here...",
  "risk_score": 0,
  "model": "gemini-3.5-flash"
}
```

### Blocked by Input Guard

```json
{
  "allowed": false,
  "blocked_by": "input",
  "message": "Request too long. Maximum length is 2000 characters."
}
```

### Blocked by PII Guard

```json
{
  "allowed": false,
  "blocked_by": "pii",
  "pii_type": "email",
  "message": "Email address detected. Please remove personal information from your request."
}
```

### Blocked by Injection Guard

```json
{
  "allowed": false,
  "blocked_by": "injection",
  "message": "Prompt injection detected. The request was blocked."
}
```

### Model Error

```json
{
  "allowed": false,
  "blocked_by": "model",
  "message": "Gemini request failed. Check GOOGLE_API_KEY, model name, network access, and API quota.",
  "detail": "Error details here..."
}
```

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the MIT License. See the LICENSE file for details.

---

## 🔗 Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [LangChain Documentation](https://docs.langchain.com/)
- [Google Gemini API](https://ai.google.dev/)
- [Pydantic Documentation](https://docs.pydantic.dev/)

---

## 👤 Author

**Vikash Kumar** - [GitHub Profile](https://github.com/VikashKumar1424)

---

**Last Updated**: September 2026

If you have any questions or feedback, feel free to open an issue or contact the maintainer!
