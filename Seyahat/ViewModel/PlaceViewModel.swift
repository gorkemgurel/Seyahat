//
//  PlaceViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import Foundation

class PlaceViewModel: ObservableObject {
    var place: Place
    
    init(place: Place) {
        self.place = place
    }
}
