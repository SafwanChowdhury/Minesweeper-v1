import Foundation

enum CellState {
    case hidden, revealed, flagged
}

enum GameStatus {
    case ongoing
    case won
    case lost
}

struct Cell {
    var state: CellState = .hidden
    var hasMine: Bool = false
    var neighboringMines: Int = 0
}

struct HighScore: Codable, Identifiable {
    var id = UUID()
    let playerName: String
    let score: Int // Time in seconds
    let date: Date
}

class GameViewModel: ObservableObject {
    @Published var grid: [[Cell]] = []
    @Published var timerIsActive = false
    @Published var secondsElapsed = 0
    private var timer: Timer?
    @Published var highScores: [HighScore] = []
    let rows: Int = 10
    let columns: Int = 10
    var totalMines: Int = 15
    var firstMove: Bool = true
    @Published var gameStatus: GameStatus = .ongoing
    init() {
        resetGame()
        loadHighScores()
    }
    
    func resetGame() {
        grid = Array(repeating: Array(repeating: Cell(), count: columns), count: rows)
        firstMove = true
        gameStatus = .ongoing
        stopTimer()
        secondsElapsed = 0
    }
    
    func startTimer() {
        timerIsActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.secondsElapsed += 1
        }
    }
    
    func stopTimer() {
        timerIsActive = false
        timer?.invalidate()
        timer = nil
    }
    
    func saveHighScore(name: String) {
        let newScore = HighScore(playerName: name, score: secondsElapsed, date: Date())
        highScores.append(newScore)
        saveHighScores()
    }
    
    private func saveHighScores() {
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: "highScores")
        }
    }
    
    private func loadHighScores() {
        if let savedScores = UserDefaults.standard.data(forKey: "highScores"),
           let decodedScores = try? JSONDecoder().decode([HighScore].self, from: savedScores) {
            highScores = decodedScores
        }
    }
    
    func placeMines(excludingRow row: Int, andColumn column: Int) {
        var minesPlaced = 0
        while minesPlaced < totalMines {
            let randomRow = Int.random(in: 0..<rows)
            let randomColumn = Int.random(in: 0..<columns)
            if !(randomRow == row && randomColumn == column) && !grid[randomRow][randomColumn].hasMine {
                grid[randomRow][randomColumn].hasMine = true
                minesPlaced += 1
                updateNeighboringMines(forRow: randomRow, andColumn: randomColumn)
            }
        }
    }
    
    func updateNeighboringMines(forRow row: Int, andColumn column: Int) {
        for i in max(row-1, 0)...min(row+1, rows-1) {
            for j in max(column-1, 0)...min(column+1, columns-1) {
                if !(i == row && j == column) {
                    grid[i][j].neighboringMines += 1
                }
            }
        }
    }
    
    func revealCell(atRow row: Int, andColumn column: Int) {
        guard row >= 0, row < rows, column >= 0, column < columns else { return }
        
        if firstMove {
            firstMove = false
            placeMines(excludingRow: row, andColumn: column)
            startTimer()
        }
        
        let cell = grid[row][column]
        if cell.state == .hidden {
            grid[row][column].state = .revealed
            
            if cell.hasMine {
                endGame(win: false)
            } else {
                if cell.neighboringMines == 0 {
                    for i in max(row-1, 0)...min(row+1, rows-1) {
                        for j in max(column-1, 0)...min(column+1, columns-1) {
                            if !(i == row && j == column) {
                                revealCell(atRow: i, andColumn: j)
                            }
                        }
                    }
                }
            }
        }
        
        if checkWinCondition() {
            endGame(win: true)
        }
    }
    
    func endGame(win: Bool) {
        stopTimer()
        for row in 0..<rows {
            for column in 0..<columns {
                if grid[row][column].state != .flagged {
                    grid[row][column].state = .revealed
                }
            }
        }
        gameStatus = win ? .won : .lost
    }
    
    func flagCell(atRow row: Int, andColumn column: Int) {
        guard row >= 0, row < rows, column >= 0, column < columns else { return }
        
        if grid[row][column].state == .hidden {
            grid[row][column].state = .flagged
        } else if grid[row][column].state == .flagged {
            grid[row][column].state = .hidden
        }
    }
    
    private func checkWinCondition() -> Bool {
        var nonMineCellsRevealed = true
        var mineCellsHandledCorrectly = true
        
        for row in grid {
            for cell in row {
                if !cell.hasMine && cell.state != .revealed {
                    nonMineCellsRevealed = false
                }
                if cell.hasMine && (cell.state == .revealed && cell.state != .flagged) {
                    mineCellsHandledCorrectly = false
                }
            }
        }
        
        return nonMineCellsRevealed && mineCellsHandledCorrectly
    }
}
