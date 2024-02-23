import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()

    var body: some View {
        ScrollView {
            VStack {
                
                Button(action: viewModel.resetGame) {
                    Text("Restart Game")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.bottom, 5)

                let columns = [GridItem](repeating: .init(.flexible()), count: viewModel.columns)
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(0..<viewModel.rows * viewModel.columns, id: \.self) { index in
                        let row = index / viewModel.columns
                        let column = index % viewModel.columns
                        Button(action: {
                            viewModel.revealCell(atRow: row, andColumn: column)
                        }) {
                            cellView(for: viewModel.grid[row][column])
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .buttonStyle(BorderlessButtonStyle())
                        .simultaneousGesture(LongPressGesture().onEnded { _ in
                            viewModel.flagCell(atRow: row, andColumn: column)
                        })
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)

                if let gameStatus = viewModel.gameStatus {
                    Text(gameStatus)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding(.horizontal, 5.0)
        }
        .padding(.top, 50.0)
    }

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

    private func display(for cell: Cell) -> String {
        switch cell.state {
        case .revealed where cell.hasMine:
            return "💣"
        case .revealed:
            return cell.neighboringMines > 0 ? "\(cell.neighboringMines)" : " "
        case .flagged:
            return "🚩"
        case .hidden:
            return " "
        }
    }

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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
