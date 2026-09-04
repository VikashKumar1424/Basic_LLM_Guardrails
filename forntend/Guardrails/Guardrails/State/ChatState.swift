import Foundation
import SwiftUI
import Combine


@MainActor
final class ChatState: ObservableObject {

    // ========================================================
    // INPUT
    // ========================================================

    @Published var input = ""


    // ========================================================
    // OUTPUT
    // ========================================================

    @Published var output = ""


    // ========================================================
    // STATUS
    // ========================================================

    @Published var status = ""


    // ========================================================
    // LOADING
    // ========================================================

    @Published var isLoading = false


    // ========================================================
    // BLOCKED
    // ========================================================

    @Published var isBlocked = false


    // ========================================================
    // KEYBOARD
    // ========================================================

    @Published var isInputFocused = false


    private let service = APIService()

    // ========================================================
    // SEND BUTTON STATE
    // ========================================================

    var canSend: Bool {

        !isLoading &&
        !input
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
    }


    // ========================================================
    // CLEAR BUTTON STATE
    // ========================================================

    var canClear: Bool {

        !isLoading &&
        (
            !input.isEmpty ||
            !output.isEmpty ||
            !status.isEmpty
        )
    }


    // ========================================================
    // SEND MESSAGE
    // ========================================================

    func sendMessage() async {

        let text = input
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )


        guard !text.isEmpty else {
            return
        }


        isLoading = true

        status = ""

        output = ""

        isBlocked = false

        isInputFocused = false


        defer {
            isLoading = false
        }


        do {

            let result = try await service.chat(
                message: text
            )


            if result.allowed {

                handleAllowedResponse(
                    result
                )

            } else {

                handleBlockedResponse(
                    result
                )
            }


        } catch {

            handleConnectionError(
                error
            )
        }
    }


    // ========================================================
    // SUCCESS RESPONSE
    // ========================================================

    private func handleAllowedResponse(
        _ result: ChatResponse
    ) {
        isBlocked = false
        status = "Allowed • \(result.model ?? "Gemini")"

        // IMPORTANT:
        // Display only the answer field.
        output = result.answer ?? "No response received."
    }


    // ========================================================
    // BLOCKED RESPONSE
    // ========================================================

    private func handleBlockedResponse(
        _ result: ChatResponse
    ) {

        isBlocked = true


        let message =
            friendlyErrorMessage(
                blockedBy: result.blockedBy,
                backendMessage: result.message
            )


        status = message.title

        output = message.description
    }


    // ========================================================
    // CONNECTION ERROR
    // ========================================================

    private func handleConnectionError(
        _ error: Error
    ) {

        isBlocked = true

        status = "Connection Error"


        output = """
        The AI service could not be reached.

        Please make sure the FastAPI backend is running on:

        http://127.0.0.1:8000

        Technical details:

        \(error.localizedDescription)
        """
    }


    // ========================================================
    // CLEAR
    // ========================================================

    func clearChat() {

        input = ""

        output = ""

        status = ""

        isBlocked = false

        isInputFocused = true
    }


    // ========================================================
    // FRIENDLY GUARDRAIL MESSAGES
    // ========================================================

    private func friendlyErrorMessage(
        blockedBy: String?,
        backendMessage: String?
    ) -> (
        title: String,
        description: String
    ) {

        switch blockedBy {


        // ----------------------------------------------------
        // INPUT
        // ----------------------------------------------------

        case "input":

            return (

                "Invalid Request",

                """
                Please enter a valid question.

                Your message may be empty or longer than
                the allowed limit.
                """
            )


        // ----------------------------------------------------
        // PII
        // ----------------------------------------------------

        case "pii":

            if backendMessage?.lowercased()
                .contains("payment card") == true {

                return (

                    "Payment Card Detected",

                    """
                    Your message contains payment card information.

                    For your security, please remove:

                    • Credit card numbers
                    • Debit card numbers
                    • Payment card details

                    We do not process payment card information.
                    """
                )
            }


            return (

                "Personal Information Detected",

                """
                Your message contains personal information.

                For your privacy, please remove details such as:

                • Email addresses
                • Phone numbers
                • Payment card information

                Then try again.
                """
            )


        // ----------------------------------------------------
        // PROMPT INJECTION
        // ----------------------------------------------------

        case "injection":

            return (

                "Safety Check Blocked This Request",

                """
                This request appears to be trying to bypass
                the AI's safety rules or access hidden instructions.

                Please ask a normal question without requesting:

                • System prompts
                • Hidden instructions
                • Guardrail bypasses
                """
            )


        // ----------------------------------------------------
        // OUTPUT
        // ----------------------------------------------------

        case "output":

            return (

                "Response Blocked",

                """
                The AI generated a response that did not
                pass our safety checks.

                Please try asking the question in a
                different way.
                """
            )


        // ----------------------------------------------------
        // MODEL
        // ----------------------------------------------------

        case "model":

            return (

                "AI Service Error",

                """
                The request could not be processed by Gemini.

                Please check that the backend is running and
                that the Gemini API configuration is correct.
                """
            )


        // ----------------------------------------------------
        // UNKNOWN
        // ----------------------------------------------------

        default:

            return (

                "Request Blocked",

                """
                Your request could not be processed by the
                AI safety system.

                Please try asking a different question.
                """
            )
        }
    }
}
