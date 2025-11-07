//
//  ContentView.swift
//  ExampleAppCodum
//
//  Created by Lov on 08/10/25.
//

import SwiftUI
import concordium_id_swift_sdk
import ConcordiumWalletCrypto

struct ContentView: View {
    @State private var output: String = ""
    @State private var popupType: PopupType? = nil
    @State private var shouldCreate: Bool = false
    @State private var shouldRecover: Bool = false
    @State private var walletConnectSessionTopic: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    enum PopupType: Identifiable {
        case qrCode
        case createRecover
        case createOnly
        case recoverOnly
        
        var id: Int { hashValue }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("IDAppSDKiOS Demo")
                .font(.title)
                .fontWeight(.bold)
            // MARK: - Simplified Controls
            Button("OpenDeepLink Popup") {
                popupType = .qrCode
            }
            .buttonStyle(ActionButtonStyle())

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Create account", isOn: $shouldCreate)
                Toggle("Recover account", isOn: $shouldRecover)
            }
            .padding(.horizontal, 4)

            // Session topic field (required for Create and Both)
            VStack(alignment: .leading, spacing: 6) {
                Text("WalletConnect session topic (required for Create/Both)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextField("Enter session topic", text: $walletConnectSessionTopic)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal, 4)

            Button("OpenActionPopup") {
                // Validation: at least one option must be selected
                guard shouldCreate || shouldRecover else {
                    errorMessage = "Please select at least one option (Create or Recover)."
                    showErrorAlert = true
                    return
                }

                // If Create or Both selected, session topic must be provided
                if shouldCreate {
                    let topicTrimmed = walletConnectSessionTopic.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !topicTrimmed.isEmpty else {
                        errorMessage = "WalletConnect session topic is required for Create account."
                        showErrorAlert = true
                        return
                    }
                }

                if shouldCreate && shouldRecover {
                    popupType = .createRecover
                } else if shouldCreate {
                    popupType = .createOnly
                } else if shouldRecover {
                    popupType = .recoverOnly
                }
            }
            .buttonStyle(ActionButtonStyle())

            Divider().padding(.vertical, 12)

            // MARK: - Output Area

            ScrollView {
                Text(output)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(white: 0.95))
                    .cornerRadius(8)
            }
            .frame(height: 220)
        }
        .padding()
        .sheet(item: $popupType) { type in
            VStack {
                switch type {
                case .qrCode:
                    ConcordiumIDAppPopup.invokeIdAppDeepLinkPopup(
                        walletConnectUri: "wc:1234567890abcdef@2?relay-protocol=irn&symKey=abcdef1234567890"
                    )
                case .createRecover:
                    ConcordiumIDAppPopup.invokeIdAppActionsPopup(
                        onCreateAccount: {
                            print("Create account tapped")
                        },
                        onRecoverAccount: {
                            print("Recover account tapped")
                        },
                        walletConnectSessionTopic: walletConnectSessionTopic
                    )
                case .createOnly:
                    ConcordiumIDAppPopup.invokeIdAppActionsPopup(
                        onCreateAccount: {
                            print("Create account tapped")
                        },
                        walletConnectSessionTopic: walletConnectSessionTopic
                    )
                case .recoverOnly:
                    ConcordiumIDAppPopup.invokeIdAppActionsPopup(
                        onRecoverAccount: {
                            print("Recover account tapped")
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .presentationDetents(
                type == .qrCode
                    ? [.fraction(0.97)]
                    : (type == .recoverOnly ? [.height(320)] : [.height(520)])
            )

            .presentationCompactAdaptation(.sheet)
            .presentationContentInteraction(.scrolls)
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.white)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ConcordiumIDAppPopupClose"))) { _ in
            // Dismiss the sheet when SDK requests close
            popupType = nil
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Custom Button Style
struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color(#colorLiteral(red: 0.066, green: 0.262, blue: 0.655, alpha: 1)))
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}
/*
 Task {
     do {
         let hash = try await ConcordiumIDAppSDK.signAndSubmit(accountIndex: 0, seedPhrase: "guide birth situate smooth sheriff toe daring february rely sign answer rebel message sock brush foam trigger apology hammer relax gallery great goat enforce", expiry: 1762501117, unsignedCdiStr: "", network: .testnet)

         let keys = try await ConcordiumIDAppSDK.generateAccountWithSeedPhrase(from: "guide birth situate smooth sheriff toe daring february rely sign answer rebel message sock brush foam trigger apology hammer relax gallery great goat enforce", network: .testnet, accountIndex: 0)
     } catch {
         print(error.localizedDescription)
     }
 }
 */
