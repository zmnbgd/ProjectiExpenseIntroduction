//
//  DeletingItemsUsingonDelete.swift
//  ProjectiExpenseIntroduction
//
//  Created by Marko Zivanovic on 10.6.22..
//

import SwiftUI

struct DeletingItemsUsingonDelete: View {
    
    @State private var numbers = [Int]()
    @State private var currentNumber = 1
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // onDelete modifier only exists on ForEach
                    ForEach(numbers, id: \.self) {
                        Text("Row \($0)")
                    }
                    .onDelete(perform: removeRows)
                }
                Button("Ad number") {
                    numbers.append(currentNumber)
                    currentNumber += 1
                }
            }
            .navigationTitle("On Delete")
            .toolbar {
                EditButton()
            }
        }
    }
    
    func removeRows(at offsets: IndexSet) {
        numbers.remove(atOffsets: offsets)
    }
    
}

struct DeletingItemsUsingonDelete_Previews: PreviewProvider {
    static var previews: some View {
        DeletingItemsUsingonDelete()
    }
}
