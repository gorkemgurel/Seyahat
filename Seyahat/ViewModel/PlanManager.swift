//
//  PlanManager.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import Foundation
import SwiftUI

class PlanManager: ObservableObject {
    @Published var savedPlans: [PlanConfiguration] = []
    
    private let userDefaults = UserDefaults.standard
    private let plansKey = "SavedTravelPlans"
    
    init() {
        loadSavedPlans()
    }
    
    func savePlan(_ plan: PlanConfiguration) {
        if let index = savedPlans.firstIndex(where: { $0.id == plan.id }) {
            savedPlans[index] = plan
        } else {
            savedPlans.append(plan)
        }
        saveToUserDefaults()
    }
    
    func deletePlan(_ plan: PlanConfiguration) {
        withAnimation {
            savedPlans.removeAll { $0.id == plan.id }
        }
        saveToUserDefaults()
    }
    
    func savePlans() {
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        do {
            let encoded = try JSONEncoder().encode(savedPlans)
            userDefaults.set(encoded, forKey: plansKey)
            userDefaults.synchronize()
            print("Plans saved successfully. Total plans: \(savedPlans.count)")
        } catch {
            print("Failed to save plans: \(error)")
        }
    }
    
    private func loadSavedPlans() {
        guard let data = userDefaults.data(forKey: plansKey) else {
            print("No saved plans found")
            return
        }
        
        do {
            let plans = try JSONDecoder().decode([PlanConfiguration].self, from: data)
            self.savedPlans = plans
            print("Loaded \(plans.count) plans")
        } catch {
            print("Failed to load plans: \(error)")
        }
    }
}
