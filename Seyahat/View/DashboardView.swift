//
//  DashboardView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var planManager = PlanManager()
    @State private var showingCitySelection = false
    @State private var showPlanDetails = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Merhaba! 👋")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Bugün nereyi keşfetmek istiyorsun?")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Planlarım")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if planManager.savedPlans.isEmpty {
                            emptyStateView
                        } else {
                            planGrid
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Seyahat Planlayıcı")
            .navigationBarItems(
                trailing: Button(action: { showingCitySelection = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            )
        }
        .sheet(isPresented: $showingCitySelection) {
            ProvinceListView()
        }
    }
    
    private var allPlansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Planlarım")
                .font(.headline)
                .fontWeight(.semibold)
            
            if planManager.savedPlans.isEmpty {
                emptyStateView
            } else {
                planGrid
            }
        }
    }
    
    private var planGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(planManager.savedPlans, id: \.id) { plan in
                PlanCard(plan: plan, planManager: planManager)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Henüz plan yok")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Sağ üstteki + tuşuna basarak ilk planını oluştur!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
