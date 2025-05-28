//
//  PlanConfiguration.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import Foundation

struct PlanConfiguration: Codable {
    var items: [PlanItem]
    var name: String
    var id: UUID
    var createdDate: Date?
    var lastUsedDate: Date?
    var district: District?
    
    init(items: [PlanItem], name: String = "Özel Plan", district: District) {
        self.items = items
        self.name = name
        self.id = UUID()
        self.createdDate = Date()
        self.lastUsedDate = Date()
        self.district = district
    }
    
    private init(items: [PlanItem], name: String, isDefault: Bool) {
        self.items = items
        self.name = name
        self.id = UUID()
        if isDefault {
            self.createdDate = nil
            self.lastUsedDate = nil
        } else {
            self.createdDate = Date()
            self.lastUsedDate = Date()
        }
    }
    
    static let defaultPlan = PlanConfiguration(items: [
        PlanItem(category: .breakfast),
        PlanItem(category: .attraction, title: "Gezilecek Yer 1"),
        PlanItem(category: .cafe),
        PlanItem(category: .attraction, title: "Gezilecek Yer 2"),
        PlanItem(category: .dinner),
        PlanItem(category: .dessert)
    ], name: "Varsayılan Plan", isDefault: true)
    
    mutating func updateLastUsedDate() {
        lastUsedDate = Date()
    }
}
