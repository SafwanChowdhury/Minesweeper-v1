import SwiftUI

struct MainMenuView: View {
    @State private var showingHighScores = false
    @State private var highScores: [HighScore] = []
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
                VStack(spacing: 20.0) {
                    Text("Minesweeper")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    NavigationLink(destination: ContentView()) {
                        Text("Start Game")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 50)
                    }
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        Text("Settings")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 50)
                    }
                    .sheet(isPresented: $showingSettings) {
                        SettingsViewPopup(isPresented: $showingSettings)
                    }
                    
                    Button(action: {
                        self.highScores = HighScoresManager.shared.loadHighScores()
                        self.showingHighScores.toggle()
                    }) {
                        Text("High Scores")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 50)
                    }
                }
                .padding(.top, 100)
                .padding(.bottom, 100)
                if showingHighScores {
                    highScoresPopup
                }
            }
        }
    }

    private var highScoresPopup: some View {
        VStack(spacing: 20) {
            Text("High Scores")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(highScores) { highScore in
                        HStack {
                            Text(highScore.playerName)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(highScore.score)")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1)))
                    }
                }
            }
            .frame(maxHeight: 200)
            
            Button("Close") {
                showingHighScores = false
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .zIndex(1)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(maxWidth: 300)
        .zIndex(1) // Ensure popup is above other content
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
