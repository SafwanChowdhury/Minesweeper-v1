import Foundation

enum CellState {
    case hidden, revealed, flagged
}

struct Cell {
    var state: CellState = .hidden
    var hasMine: Bool = false
    var neighboringMines: Int = 0
}

class GameViewModel: ObservableObject {
    @Published var grid: [[Cell]] = []
    let rows: Int = 10
    let columns: Int = 10
    var totalMines: Int = 15
    var firstMove: Bool = true // Add a flag to check if it's the first move
    
    @Published var gameStatus: String? = nil
    
    init() {
        resetGame()
    }
    
    func resetGame() {
        grid = Array(repeating: Array(repeating: Cell(), count: columns), count: rows)
        firstMove = true // Reset first move flag
        gameStatus = nil
    }
    
    // Modified placeMines function
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
        
        // If it's the first move, place mines excluding the selected cell and its neighbors
        if firstMove {
            placeMines(excludingRow: row, andColumn: column)
            firstMove = false
        }
        
        let cell = grid[row][column]
        if cell.state == .hidden {
            grid[row][column].state = .revealed
            
            if cell.hasMine {
                endGame()
                gameStatus = "Game Over! You hit a mine."
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
            gameStatus = "Congratulations! You cleared all mines."
        }
    }
    
    func endGame() {
        for row in 0..<rows {
            for column in 0..<columns {
                // Reveal all cells, but don't change flagged cells to keep player's flags visible
                if grid[row][column].state != .flagged {
                    grid[row][column].state = .revealed
                }
            }
        }
        // Optionally, set a game over message
        gameStatus = "Game Over! You hit a mine."
    }
    
    func flagCell(atRow row: Int, andColumn column: Int) {
        guard row >= 0, row < rows, column >= 0, column < columns else { return }
        
        // Toggle flag state for the cell
        if grid[row][column].state == .hidden {
            grid[row][column].state = .flagged
        } else if grid[row][column].state == .flagged {
            grid[row][column].state = .hidden
        }
    }
    
    private func checkWinCondition() -> Bool {
        for row in grid {
            for cell in row {
                // If any cell that does not have a mine is still hidden, the game is not won yet
                if cell.state == .hidden && !cell.hasMine {
                    return false
                }
            }
        }
        if gameStatus == "Game Over! You hit a mine." {
            return false
        }
        return true
    }
}
