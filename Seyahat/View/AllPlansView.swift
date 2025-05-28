//
//  AllPlansView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import SwiftUI

struct AllPlansView: View {
    @ObservedObject var planManager: PlanManager
    @State private var showingCreatePlan = false
    
    var body: some View {
        List {
            ForEach(planManager.savedPlans, id: \.id) { plan in
                PlanListRow(plan: plan, planManager: planManager)
            }
            .onDelete(perform: deletePlans)
        }
        .navigationTitle("Tüm Planlar")
        .navigationBarItems(
            trailing: Button(action: { showingCreatePlan = true }) {
                Image(systemName: "plus")
            }
        )
        .sheet(isPresented: $showingCreatePlan) {
            // Plan oluşturma için şehir seçimi gerekecek
            Text("Plan oluşturma - şehir seçimi eklenecek")
        }
    }
    
    private func deletePlans(offsets: IndexSet) {
        for index in offsets {
            planManager.deletePlan(planManager.savedPlans[index])
        }
    }
}
