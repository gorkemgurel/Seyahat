//
//  CategoryListView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: CategoryListViewModel

    var body: some View {
        List(viewModel.categoryList, id: \.name) { category in
            NavigationLink(destination: PlaceListView(viewModel: PlaceListViewModel(category: category))) {
                Text(category.name)
            }
        }
        .navigationTitle("Kategoriler")
    }
}
