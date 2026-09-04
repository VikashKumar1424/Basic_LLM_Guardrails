
from fastapi import FastAPI
from pydantic import BaseModel

from .agent import MODEL, ask_gemini
from .guardrails.guards import (
    input_guard,
    pii_guard,
    injection_guard,
    output_guard,
)


# ---------------------------------------------------------
# FastAPI
# ---------------------------------------------------------

app = FastAPI(
    title="LangChain Guardrails + Gemini",
    version="1.0.0",
)


# ---------------------------------------------------------
# Request Model
# ---------------------------------------------------------

class ChatRequest(BaseModel):
    message: str


# ---------------------------------------------------------
# Health Check
# ---------------------------------------------------------

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "langchain-guardrails-gemini",
    }


# ---------------------------------------------------------
# Chat
# ---------------------------------------------------------

@app.post("/chat")
def chat(req: ChatRequest):

    # =====================================================
    # STEP 1 — INPUT GUARD
    # =====================================================

    allowed, reason = input_guard(req.message)

    if not allowed:
        return {
            "allowed": False,
            "blocked_by": "input",
            "message": reason,
        }


    # =====================================================
    # STEP 2 — PII GUARD
    # =====================================================

    pii_allowed, pii_reason, pii_type = pii_guard(req.message)

    if not pii_allowed:
        return {
            "allowed": False,
            "blocked_by": "pii",
            "pii_type": pii_type,
            "message": pii_reason,
        }


    # =====================================================
    # STEP 3 — PROMPT INJECTION GUARD
    # =====================================================

    injection_allowed, injection_reason = injection_guard(
        req.message
    )

    if not injection_allowed:
        return {
            "allowed": False,
            "blocked_by": "injection",
            "message": injection_reason,
        }


    # =====================================================
    # STEP 4 — SEND TO GEMINI
    # =====================================================

    try:
        answer = ask_gemini(req.message)

    except Exception as exc:
        return {
            "allowed": False,
            "blocked_by": "model",
            "message": (
                "Gemini request failed. "
                "Check GOOGLE_API_KEY, model name, "
                "network access, and API quota."
            ),
            "detail": str(exc),
        }


    # =====================================================
    # STEP 5 — OUTPUT GUARD
    # =====================================================

    output_allowed, output_reason = output_guard(answer)

    if not output_allowed:
        return {
            "allowed": False,
            "blocked_by": "output",
            "message": output_reason,
        }


    # =====================================================
    # STEP 6 — SUCCESS
    # =====================================================

    return {
        "allowed": True,
        "answer": answer,
        "risk_score": 0,
        "model": MODEL,
    }
