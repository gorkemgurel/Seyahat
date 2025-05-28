//
//  PlanManager.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import Foundation

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
        savedPlans.removeAll { $0.id == plan.id }
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedPlans) {
            userDefaults.set(encoded, forKey: plansKey)
        }
    }
    
    private func loadSavedPlans() {
        guard let data = userDefaults.data(forKey: plansKey),
              let plans = try? JSONDecoder().decode([PlanConfiguration].self, from: data) else {
            return
        }
        savedPlans = plans
    }
}
