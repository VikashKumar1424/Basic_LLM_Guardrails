import SwiftUI


struct ContentView: View {

    @StateObject private var state = ChatState()

    // FocusState belongs to the View
    @FocusState private var isInputFocused: Bool


    var body: some View {

        NavigationStack {

            VStack(spacing: 20) {

                // ====================================================
                // HEADER
                // ====================================================

                VStack(spacing: 8) {

                    Image(
                        systemName: "shield.checkered"
                    )
                    .font(
                        .system(size: 44)
                    )

                    Text("Safe AI Assistant")
                        .font(.title.bold())

                    Text(
                        "LangChain + Gemini + Guardrails"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }


                // ====================================================
                // RESPONSE AREA
                // ====================================================

                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 12
                    ) {

                        if !state.status.isEmpty {
                            HStack(spacing: 8) {
                                Image(
                                    systemName: state.isBlocked
                                        ? "xmark.circle.fill"
                                        : "checkmark.circle.fill"
                                )
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(
                                    state.isBlocked ? .red : .green
                                )

                                Text(state.status)
                                    .font(.headline)
                            }
                        }


                        if !state.output.isEmpty {

                            Text(state.output)
                                .font(.body)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .padding()
                                .background(
                                    state.isBlocked
                                    ? Color.red.opacity(0.08)
                                    : Color.blue.opacity(0.08)
                                )
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 16
                                    )
                                )
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }


                Spacer()


                // ====================================================
                // INPUT
                // ====================================================

                HStack(
                    alignment: .bottom,
                    spacing: 10
                ) {

                    TextField(
                        "Ask something...",
                        text: $state.input,
                        axis: .vertical
                    )
                    .lineLimit(1...5)
                    .textFieldStyle(.roundedBorder)

                    // Correct FocusState usage
                    .focused(
                        $isInputFocused
                    )

                    .submitLabel(.send)

                    .onSubmit {

                        guard state.canSend else {
                            return
                        }

                        Task {
                            await state.sendMessage()
                        }
                    }


                    // =================================================
                    // SEND BUTTON
                    // =================================================

                    Button {

                        // Hide keyboard
                        isInputFocused = false

                        Task {
                            await state.sendMessage()
                        }

                    } label: {

                        Image(
                            systemName:
                                "arrow.up.circle.fill"
                        )
                        .font(
                            .system(size: 34)
                        )
                    }
                    .disabled(
                        !state.canSend
                    )
                }


                // ====================================================
                // CLEAR BUTTON
                // ====================================================

                Button("Clear") {

                    state.clearChat()

                    // Put focus back into TextField
                    isInputFocused = true
                }
                .disabled(
                    !state.canClear
                )
            }
            .padding()
            .navigationTitle(
                "Guardrails Demo"
            )
        }
    }
}


#Preview {

    ContentView()
}
