import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var showingNameEntryPopup = false
    @State private var playerName: String = ""
    @State private var showingStatusMessage = false
    @State private var statusMessage = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    if verticalSizeClass == .regular {
                        portraitLayout(geometry: geometry)
                    } else {
                        landscapeLayout(geometry: geometry)
                    }

                    if showingStatusMessage {
                        Text(statusMessage)
                            .font(.title)
                            .foregroundColor(viewModel.gameStatus == .won ? .green : .red)
                            .padding()
                            .transition(.scale)
                    }
                }
                
                if showingNameEntryPopup {
                    nameEntryPopup
                        .transition(.scale)
                }
            }
        }
        .onChange(of: viewModel.gameStatus) { newStatus in
            switch newStatus {
            case .won:
                statusMessage = "Congratulations! 🎉"
                showingStatusMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showingNameEntryPopup = true
                }
            case .lost:
                statusMessage = "Game Over! 💀"
                showingStatusMessage = true
            default:
                showingStatusMessage = false
            }
        }
    }


    // MARK: - UI Components
    
    // Layout for portrait orientation
    func portraitLayout(geometry: GeometryProxy) -> some View {
        VStack {
            restartButton
                .padding(.bottom, 5)
            
            gameBoard(geometry: geometry)
        }
        .padding(.top, geometry.safeAreaInsets.top)
    }
    
    // Layout for landscape orientation
    func landscapeLayout(geometry: GeometryProxy) -> some View {
        HStack {
            restartButton
                .padding(.horizontal, 5)
            
            gameBoard(geometry: geometry)
        }
        .padding(.leading, geometry.safeAreaInsets.leading) // Adjust for safe area
        .padding(.top, 20)
    }
    
    // Restart game button
    var restartButton: some View {
        Button(action: {
            triggerHapticFeedback(style: .light)
            viewModel.resetGame()
        }) {
            Text("Restart")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .font(.system(size: verticalSizeClass == .regular ? 20 : 14)) // Adjust font size
        }
    }

    // Game board layout
    func gameBoard(geometry: GeometryProxy) -> some View {
        let width = geometry.size.width - (verticalSizeClass == .regular ? 20 : 50) // Adjust based on orientation
        let height = geometry.size.height - (verticalSizeClass == .regular ? 100 : 20) // Provide more space in portrait
        
        let size = min(width, height)
        let columns = [GridItem](repeating: .init(.flexible()), count: viewModel.columns)
        
        return LazyVGrid(columns: columns, spacing: 5) {
            ForEach(0..<viewModel.rows * viewModel.columns, id: \.self) { index in
                let row = index / viewModel.columns
                let column = index % viewModel.columns
                Button(action: {
                    triggerHapticFeedback(style: .light)
                    viewModel.revealCell(atRow: row, andColumn: column)
                }) {
                    cellView(for: viewModel.grid[row][column])
                }
                .aspectRatio(1, contentMode: .fit)
                .buttonStyle(BorderlessButtonStyle())
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    triggerHapticFeedback(style: .medium)
                    viewModel.flagCell(atRow: row, andColumn: column)
                })
            }
        }
        .frame(width: size, height: size)
        .padding(.trailing, 20.0)
        .padding(.leading, 10.0)
    }

    // MARK: - Helper Functions
    
    // Function to create a view for each cell based on its state
    @ViewBuilder
    private func cellView(for cell: Cell) -> some View {
        let backgroundColor: Color = color(for: cell)
        Text(display(for: cell))
            .frame(minWidth: 20, maxWidth: .infinity, minHeight: 20, maxHeight: .infinity)
            .background(backgroundColor)
            .foregroundColor(.white)
            .font(.caption2)
            .border(Color.black, width: 0.5)
    }

    // Determine the display text for a cell
    private func display(for cell: Cell) -> String {
        switch cell.state {
        case .revealed where cell.hasMine:
            return "💣"
        case .revealed:
            return cell.neighboringMines > 0 ? "\(cell.neighboringMines)" : " "
        case .flagged:
            return "🚩"
        case .hidden where (cell.hasMine && GlobalSettings.shared.testingModeEnabled):
            return "🟥"
        case .hidden:
            return " "
        }
    }

    // Determine the background color for a cell
    private func color(for cell: Cell) -> Color {
        switch cell.state {
        case .revealed where cell.hasMine:
            return .red
        case .revealed:
            return .gray
        case .flagged, .hidden:
            return .blue
        }
    }
    
    // Trigger haptic feedback
    private func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // Popup for name entry
    private var nameEntryPopup: some View {
        VStack(spacing: 20) {
            Text("New High Score!")
                .font(.headline)
            
            TextField("Enter your name", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save") {
                viewModel.saveHighScore(name: playerName)
                playerName = "" // Reset for next time
                showingNameEntryPopup = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(maxWidth: 300)
        .zIndex(1) // Ensure popup is above other content
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HighScoreEntryView: View {
    @Binding var playerName: String
    var onSave: () -> Void // Ensure this matches the expectation

    var body: some View {
        NavigationView {
            Form {
                TextField("Enter your name", text: $playerName)
                Button("Save") {
                    onSave()
                }
            }
            .navigationBarTitle("High Score", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                playerName = "" // Reset playerName if canceled
            })
        }
    }
}
