import SwiftUI

struct SettingsViewPopup: View {
    @Binding var isPresented: Bool
    @State private var showingClearConfirmation = false
    
    @ObservedObject var globalSettings = GlobalSettings.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue) // Use consistent accent color
                
                Button("Clear High Scores") {
                    showingClearConfirmation = true
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .alert(isPresented: $showingClearConfirmation) {
                    Alert(
                        title: Text("Confirm"),
                        message: Text("Are you sure you want to clear all high scores?"),
                        primaryButton: .destructive(Text("Clear")) {
                            HighScoresManager.shared.clearHighScores()
                        },
                        secondaryButton: .cancel()
                    )
                }

                Button(action: {
                    globalSettings.testingModeEnabled.toggle()
                }) {
                    Text(globalSettings.testingModeEnabled ? "Disable Testing Mode" : "Enable Testing Mode")
                        .padding()
                        .background(globalSettings.testingModeEnabled ? Color.blue : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button("Close") {
                    isPresented = false
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .navigationBarHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure full screen coverage
        .background(Color.white)
        .edgesIgnoringSafeArea(.all) // Ignore safe area to cover entire screen
        .cornerRadius(20)
    }
}


struct SettingsViewPopup_Previews: PreviewProvider {
    static var previews: some View {
        SettingsViewPopup(isPresented: .constant(true))
    }
}
