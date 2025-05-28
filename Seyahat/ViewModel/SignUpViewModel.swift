//
//  SignUpViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 22.05.2025.
//

import Foundation
import FirebaseAuth

class SignUpViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
        }
    }
}
