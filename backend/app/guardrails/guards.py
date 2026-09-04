import re
from typing import Tuple


# ============================================================
# INPUT GUARD
# ============================================================

def input_guard(text: str) -> Tuple[bool, str]:

    if not text or not text.strip():
        return False, "Empty request"

    if len(text) > 2000:
        return (
            False,
            "Request too long. Maximum length is 2000 characters.",
        )

    return True, ""


# ============================================================
# PII PATTERNS
# ============================================================

PII_PATTERNS = {
    "email": (
        r"\b[A-Za-z0-9._%+-]+"
        r"@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b"
    ),

    "phone": (
        r"(?<!\d)"
        r"(?:\+91[-\s]?)?"
        r"[6-9]\d{9}"
        r"(?!\d)"
    ),

    # Common payment-card formats:
    #
    # 4111111111111111
    # 4111 1111 1111 1111
    # 4111-1111-1111-1111
    #
    "card": (
        r"(?<!\d)"
        r"(?:\d[ -]?){13,19}"
        r"(?!\d)"
    ),
}


# ============================================================
# LUHN VALIDATION
# ============================================================

def luhn_check(card_number: str) -> bool:
    """
    Validate a payment-card number using the Luhn algorithm.
    """

    digits = re.sub(r"\D", "", card_number)

    if not 13 <= len(digits) <= 19:
        return False

    total = 0
    reverse_digits = digits[::-1]

    for index, digit in enumerate(reverse_digits):
        value = int(digit)

        if index % 2 == 1:
            value *= 2

            if value > 9:
                value -= 9

        total += value

    return total % 10 == 0


# ============================================================
# PII GUARD
# ============================================================

def pii_guard(text: str) -> Tuple[bool, str, str]:

    # --------------------------------------------------------
    # Email
    # --------------------------------------------------------

    if re.search(
        PII_PATTERNS["email"],
        text,
        re.IGNORECASE,
    ):
        return (
            False,
            "Email address detected. Please remove personal information from your request.",
            "email",
        )

    # --------------------------------------------------------
    # Phone
    # --------------------------------------------------------

    if re.search(
        PII_PATTERNS["phone"],
        text,
    ):
        return (
            False,
            "Phone number detected. Please remove personal information from your request.",
            "phone",
        )

    # --------------------------------------------------------
    # Payment Card
    # --------------------------------------------------------

    card_matches = re.findall(
        PII_PATTERNS["card"],
        text,
    )

    for card_match in card_matches:

        if luhn_check(card_match):
            return (
                False,
                "Payment card information detected. For your security, please remove card details from your request.",
                "payment_card",
            )

    return True, "", ""


# ============================================================
# PROMPT INJECTION GUARD
# ============================================================

INJECTION_PATTERNS = [
    r"ignore\s+(all\s+)?previous\s+instructions",
    r"ignore\s+(all\s+)?prior\s+instructions",
    r"disregard\s+(all\s+)?previous\s+instructions",
    r"disregard\s+(all\s+)?prior\s+instructions",
    r"reveal\s+(the\s+)?system\s+prompt",
    r"show\s+(me\s+)?(the\s+)?system\s+prompt",
    r"print\s+(the\s+)?system\s+prompt",
    r"reveal\s+(your\s+)?hidden\s+instructions",
    r"show\s+(your\s+)?hidden\s+instructions",
    r"reveal\s+(your\s+)?instructions",
    r"bypass\s+(the\s+)?guardrails",
    r"bypass\s+(all\s+)?safety",
    r"disable\s+(the\s+)?guardrails",
    r"jailbreak",
]


def injection_guard(text: str) -> Tuple[bool, str]:

    for pattern in INJECTION_PATTERNS:

        if re.search(
            pattern,
            text,
            re.IGNORECASE,
        ):
            return (
                False,
                "Prompt injection detected. The request was blocked.",
            )

    return True, ""


# ============================================================
# OUTPUT GUARD
# ============================================================

def output_guard(text: str) -> Tuple[bool, str]:

    if not text or not text.strip():
        return False, "Empty model output"

    if len(text) > 4000:
        return False, "Model output too long"

    return True, ""