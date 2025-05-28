//
//  SheetDismissalManager.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//


//
//  SheetDismissalManager.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import SwiftUI
import Combine

class SheetDismissalManager: ObservableObject {
    static let shared = SheetDismissalManager()
    
    @Published var shouldDismissAllSheets = false
    
    private init() {}
    
    func dismissAllSheets() {
        shouldDismissAllSheets = true
        // Reset after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shouldDismissAllSheets = false
        }
    }
}