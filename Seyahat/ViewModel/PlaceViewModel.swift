//
//  PlaceViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import Foundation

class PlaceViewModel: ObservableObject {
    let place: Place
    var availablePlacesForSelection: [Place] = []
    var excludedPlaceNames: Set<String> = []
    
    init(place: Place) {
        self.place = place
    }
    
    func setAvailablePlaces(_ places: [Place], excludedNames: Set<String>) {
        self.availablePlacesForSelection = places
        self.excludedPlaceNames = excludedNames
    }
    
    func createPlaceSelectionViewModel() -> PlaceSelectionViewModel {
        return PlaceSelectionViewModel(
            availablePlaces: availablePlacesForSelection,
            excludedPlaceNames: excludedPlaceNames
        )
    }
}
