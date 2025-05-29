//
//  PlanView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import SwiftUI

struct PlanView: View {
    @ObservedObject var viewModel: PlanViewModel
    let onSavePlan: ((PlanConfiguration) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @State private var hasUnsavedChanges = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(viewModel.currentPlanConfiguration.items.enumerated()), id: \.offset) { itemIndex, planItem in
                    if let places = viewModel.planAdvices[planItem.id], !places.isEmpty {
                        SectionHeaderView(title: planItem.title)
                        
                        ForEach(Array(places.enumerated()), id: \.offset) { placeIndex, place in
                            PlaceView(
                                viewModel: createPlaceViewModel(for: place, planItem: planItem),
                                onFilterSelected: { reasonString in
                                    handleDislike(
                                        forPlace: place,
                                        planItemId: planItem.id,
                                        reasonString: reasonString
                                    )
                                },
                                onManualPlaceSelected: { selectedPlace in
                                    handleManualPlaceSelection(
                                        originalPlace: place,
                                        selectedPlace: selectedPlace,
                                        planItemId: planItem.id
                                    )
                                }
                            )
                            
                            if let nextPlace = getNextPlace(currentItemIndex: itemIndex, currentPlaceIndex: placeIndex) {
                                LocationInfoView(
                                    fromPlace: place,
                                    toPlace: nextPlace,
                                    viewModel: viewModel
                                )
                            } else if placeIndex < places.count - 1 || itemIndex < viewModel.currentPlanConfiguration.items.count - 1 {
                                Divider()
                                    .padding(.vertical, 10)
                            }
                        }
                    } else {
                        EmptyCategoryView(categoryName: planItem.title)
                        if itemIndex < viewModel.currentPlanConfiguration.items.count - 1 {
                            Divider()
                                .padding(.vertical, 10)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("\(viewModel.district.name) Planı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Kaydet") {
                    savePlan()
                }
                .foregroundColor(hasUnsavedChanges ? .blue : .gray)
                .disabled(!hasUnsavedChanges)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissAllViews)) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func createPlaceViewModel(for place: Place, planItem: PlanItem) -> PlaceViewModel {
        let placeViewModel = PlaceViewModel(place: place)
        
        // Bu kategori için mevcut tüm mekanları ve hariç tutulacak isimleri ayarla
        if let availablePlaces = viewModel.filteredPlacesByCategory[planItem.category] {
            placeViewModel.setAvailablePlaces(
                availablePlaces,
                excludedNames: viewModel.sessionDislikedAndActivePlaceNames
            )
        }
        
        return placeViewModel
    }
    
    private func handleManualPlaceSelection(originalPlace: Place, selectedPlace: Place, planItemId: UUID) {
        viewModel.replacePlace(originalPlace: originalPlace, newPlace: selectedPlace, planItemId: planItemId)
        hasUnsavedChanges = true
    }
    
    private func savePlan() {
        viewModel.syncPlanAdvicesToConfiguration()
        
        if let onSavePlan = onSavePlan {
            onSavePlan(viewModel.currentPlanConfiguration)
        }
        
        hasUnsavedChanges = false
        GlobalDismissManager.shared.dismissAll()
    }
    
    private func getNextPlace(currentItemIndex: Int, currentPlaceIndex: Int) -> Place? {
        let items = viewModel.currentPlanConfiguration.items
        let currentItem = items[currentItemIndex]
        
        guard let currentPlaces = viewModel.planAdvices[currentItem.id] else { return nil }
        
        if currentPlaceIndex < currentPlaces.count - 1 {
            return currentPlaces[currentPlaceIndex + 1]
        }
        
        for nextItemIndex in (currentItemIndex + 1)..<items.count {
            let nextItem = items[nextItemIndex]
            if let nextPlaces = viewModel.planAdvices[nextItem.id], !nextPlaces.isEmpty {
                return nextPlaces.first
            }
        }
        
        return nil
    }

    private func handleDislike(forPlace place: Place, planItemId: UUID, reasonString: String) {
        let reason: DislikeReason
        
        switch reasonString {
        case "Uzak":
            reason = .tooFar
        case "Pahalı":
            reason = .tooExpensive
        case "Rastgele":
            reason = .general
        default:
            return
        }

        viewModel.suggestAlternative(for: planItemId, dislikedPlace: place, reason: reason)
        hasUnsavedChanges = true
    }
}

// Diğer view'lar aynı kalıyor...
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.bottom, 2)
    }
}

struct EmptyCategoryView: View {
    let categoryName: String
    
    var body: some View {
        VStack {
            Text("\(categoryName) için şu anda bir öneri bulunamadı.")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}
