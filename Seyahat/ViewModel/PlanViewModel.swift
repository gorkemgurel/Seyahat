//
//  PlanViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import Foundation
import CoreLocation

class PlanViewModel: ObservableObject {
    var district: District
    
    private var filteredPlacesByCategory: [PlanCategory: [Place]] = [:]
    
    @Published var selectedSortOption: PlaceSortOption = .reviewCountDescending
    @Published var currentPlanConfiguration: PlanConfiguration = .defaultPlan
    @Published var planAdvices: [UUID: [Place]] = [:]
    
    private var sessionDislikedAndActivePlaceNames: Set<String> = []
    private let turkishLocale = Locale(identifier: "tr_TR")

    init(district: District, planConfiguration: PlanConfiguration = .defaultPlan) {
        self.district = district
        self.currentPlanConfiguration = planConfiguration
        setupFilteredPlaces()
        generateInitialAdvices()
    }
    
    func updatePlanConfiguration(_ newConfiguration: PlanConfiguration) {
        currentPlanConfiguration = newConfiguration
        setupFilteredPlaces()
        generateInitialAdvices()
    }
    
    func addPlanItem(_ item: PlanItem) {
        currentPlanConfiguration.items.append(item)
        setupFilteredPlaces()
        generateAdviceForItem(item)
    }
    
    func removePlanItem(at index: Int) {
        guard index < currentPlanConfiguration.items.count else { return }
        let item = currentPlanConfiguration.items[index]
        planAdvices.removeValue(forKey: item.id)
        currentPlanConfiguration.items.remove(at: index)
    }
    
    // Mesafe hesaplama fonksiyonları
    func calculateDistance(from source: Place, to destination: Place) -> CLLocationDistance {
        let sourceLocation = CLLocation(
            latitude: source.location.latitude,
            longitude: source.location.longitude
        )
        let destinationLocation = CLLocation(
            latitude: destination.location.latitude,
            longitude: destination.location.longitude
        )
        
        return sourceLocation.distance(from: destinationLocation)
    }
    
    func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    func estimateWalkingTime(_ distance: CLLocationDistance) -> String {
        let walkingSpeedKmH = 5.0
        let walkingSpeedMs = walkingSpeedKmH * 1000 / 3600
        let timeInSeconds = distance / walkingSpeedMs
        
        if timeInSeconds < 60 {
            return "< 1 dk"
        } else if timeInSeconds < 3600 {
            let minutes = Int(timeInSeconds / 60)
            return "\(minutes) dk"
        } else {
            let hours = Int(timeInSeconds / 3600)
            let minutes = Int((timeInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)s \(minutes)dk"
        }
    }
    
    func estimateDrivingTime(_ distance: CLLocationDistance) -> String {
        let drivingSpeedKmH = 30.0
        let drivingSpeedMs = drivingSpeedKmH * 1000 / 3600
        let timeInSeconds = distance / drivingSpeedMs
        
        if timeInSeconds < 60 {
            return "< 1 dk"
        } else if timeInSeconds < 3600 {
            let minutes = Int(timeInSeconds / 60)
            return "\(minutes) dk"
        } else {
            let hours = Int(timeInSeconds / 3600)
            let minutes = Int((timeInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)s \(minutes)dk"
        }
    }
    
    private func setupFilteredPlaces() {
        filteredPlacesByCategory.removeAll()
        
        let usedCategories = Set(currentPlanConfiguration.items.map { $0.category })
        
        for category in usedCategories {
            let places = district.categories[category.districtCategoryIndex].places
            filteredPlacesByCategory[category] = filterPlaces(
                places,
                excludeNamesContaining: category.excludedWords,
                locale: turkishLocale
            )
        }
    }
    
    func filterPlaces(_ places: [Place], excludeNamesContaining forbiddenWords: [String], locale: Locale) -> [Place] {
        return places.filter { place in
            guard place.formattedAddress.lowercased(with: locale).contains(district.name.lowercased(with: locale)) else {
                return false
            }
            
            let displayNameLowercased = place.displayName.lowercased(with: locale)
            let hasForbiddenWord = forbiddenWords.contains { word in
                let wordLowercased = word.lowercased(with: locale)
                return displayNameLowercased.contains(wordLowercased)
            }
            return !hasForbiddenWord
        }
    }
    
    func generateInitialAdvices() {
        sessionDislikedAndActivePlaceNames.removeAll()
        planAdvices.removeAll()
        
        for item in currentPlanConfiguration.items {
            generateAdviceForItem(item)
        }
    }
    
    private func generateAdviceForItem(_ item: PlanItem) {
        guard let filteredPlaces = filteredPlacesByCategory[item.category] else { return }
        
        let sortedPlaces = sortPlaces(filteredPlaces, by: selectedSortOption)
        let selectedPlaces = selectNewUniquePlaces(
            from: sortedPlaces,
            count: item.maxCount,
            excludingSet: &sessionDislikedAndActivePlaceNames
        )
        
        planAdvices[item.id] = selectedPlaces
    }
    
    func sortPlaces(_ places: [Place], by option: PlaceSortOption) -> [Place] {
        switch option {
        case .reviewCountDescending:
            return places.sorted { ($0.userRatingCount ?? 0) > ($1.userRatingCount ?? 0) }
        case .ratingDescending:
            return places.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .nameAscending:
            return places.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        }
    }
    
    private func selectNewUniquePlaces(from sortedList: [Place], count: Int, excludingSet: inout Set<String>) -> [Place] {
        var results: [Place] = []
        
        for place in sortedList {
            if !excludingSet.contains(place.name) {
                results.append(place)
                excludingSet.insert(place.name)
            }
            if results.count == count {
                break
            }
        }
        
        return results
    }

    private func sortPlacesByReason(places: [Place], reason: DislikeReason, defaultSortOption: PlaceSortOption) -> [Place] {
        var sortedPotentialPlaces = places
        
        switch reason {
        case .badRating:
            sortedPotentialPlaces.sort {
                if ($0.rating ?? 0.0) != ($1.rating ?? 0.0) {
                    return ($0.rating ?? 0.0) > ($1.rating ?? 0.0)
                }
                return ($0.userRatingCount ?? 0) > ($1.userRatingCount ?? 0)
            }
        case .tooExpensive:
            sortedPotentialPlaces.sort {
                let price0 = $0.priceLevel ?? Int.max
                let price1 = $1.priceLevel ?? Int.max
                if price0 != price1 {
                    return price0 < price1
                }
                return ($0.rating ?? 0.0) > ($1.rating ?? 0.0)
            }
        case .tooFar:
            sortedPotentialPlaces = sortPlaces(sortedPotentialPlaces, by: defaultSortOption)
        case .general:
            sortedPotentialPlaces = sortPlaces(places, by: defaultSortOption)
        }
        
        return sortedPotentialPlaces
    }

    func suggestAlternativeForPlanItem(_ planItem: PlanItem, dislikedPlace: Place, reason: DislikeReason) {
        guard let currentAdvices = planAdvices[planItem.id],
              let filteredPlaces = filteredPlacesByCategory[planItem.category] else { return }
        
        sessionDislikedAndActivePlaceNames.remove(dislikedPlace.name)
        sessionDislikedAndActivePlaceNames.insert(dislikedPlace.name)
        
        var newAdvices: [Place] = []
        
        for advice in currentAdvices {
            if advice.name != dislikedPlace.name {
                newAdvices.append(advice)
                sessionDislikedAndActivePlaceNames.insert(advice.name)
            }
        }
        
        let neededCount = planItem.maxCount - newAdvices.count
        
        if neededCount > 0 {
            let potentialCandidates = filteredPlaces.filter { place in
                return !sessionDislikedAndActivePlaceNames.contains(place.name)
            }
            
            let sortedCandidates = sortPlacesByReason(
                places: potentialCandidates,
                reason: reason,
                defaultSortOption: selectedSortOption
            )
            
            let newlyFoundPlaces = selectNewUniquePlaces(
                from: sortedCandidates,
                count: neededCount,
                excludingSet: &sessionDislikedAndActivePlaceNames
            )
            
            newAdvices.append(contentsOf: newlyFoundPlaces)
        }
        
        planAdvices[planItem.id] = Array(newAdvices.prefix(planItem.maxCount))
    }
    
    func suggestAlternative(for planItemId: UUID, dislikedPlace: Place, reason: DislikeReason) {
        guard let planItem = currentPlanConfiguration.items.first(where: { $0.id == planItemId }) else { return }
        suggestAlternativeForPlanItem(planItem, dislikedPlace: dislikedPlace, reason: reason)
    }
}
