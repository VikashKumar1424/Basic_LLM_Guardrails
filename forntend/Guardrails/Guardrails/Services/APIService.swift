import Foundation


final class APIService {

    private let baseURL = URL(
        string: "http://127.0.0.1:8000"
    )!


    // ========================================================
    // CHAT
    // ========================================================

    func chat(
        message: String
    ) async throws -> ChatResponse {

        let url = baseURL
            .appendingPathComponent("chat")


        var request = URLRequest(
            url: url
        )

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )


        let body = ChatRequest(
            message: message
        )


        request.httpBody = try JSONEncoder()
            .encode(body)


        let (
            data,
            response
        ) = try await URLSession.shared.data(
            for: request
        )


        guard let httpResponse =
                response as? HTTPURLResponse
        else {

            throw URLError(
                .badServerResponse
            )
        }


        guard 200..<300 ~= httpResponse.statusCode
        else {

            throw URLError(
                .badServerResponse
            )
        }


        do {

            return try JSONDecoder()
                .decode(
                    ChatResponse.self,
                    from: data
                )

        } catch {

            print(
                "Decoding error:",
                error
            )

            print(
                "Raw response:",
                String(
                    data: data,
                    encoding: .utf8
                ) ?? "Unable to read response"
            )

            throw error
        }
    }
}
