//
//  UserInteraction.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 29.05.2025.
//


import Foundation

struct UserInteraction {
    let place: Place
    let wasLiked: Bool
    let dislikeReason: DislikeReason?
    let timestamp: Date = Date()
    let category: String
}