import Foundation
import SwiftUI

class GlobalSettings: ObservableObject {
    static let shared = GlobalSettings()
    
    @Published var testingModeEnabled: Bool = false
}
