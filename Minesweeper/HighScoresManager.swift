import Foundation

class HighScoresManager {
    static let shared = HighScoresManager()
    private let highScoresKey = "highScores"
    
    func saveHighScore(_ highScore: HighScore) {
        var highScores = loadHighScores()
        highScores.append(highScore)
        // Optionally, sort or limit the number of saved high scores here
        highScores.sort { $0.score < $1.score }
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: highScoresKey)
        }
    }
    
    func loadHighScores() -> [HighScore] {
        guard let savedScores = UserDefaults.standard.data(forKey: highScoresKey),
              let decodedScores = try? JSONDecoder().decode([HighScore].self, from: savedScores) else {
            return []
        }
        return decodedScores
    }
}

extension HighScoresManager {
    func clearHighScores() {
        UserDefaults.standard.removeObject(forKey: highScoresKey)
    }
}
