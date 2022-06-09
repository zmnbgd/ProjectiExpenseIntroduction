//
//  ShowingAndHidingViews.swift
//  ProjectiExpenseIntroduction
//
//  Created by Marko Zivanovic on 9.6.22..
//

import SwiftUI

struct SecondView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let name: String
    
    var body: some View {
        Button("Done") {
            dismiss()
        }
    }
}

struct ShowingAndHidingViews: View {
    
    @State private var showingSheet = false
    
    var body: some View {
        Button("Show sheet") {
            // show the sheet
            
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
            SecondView(name: "Minja")
        }
    }
}

struct ShowingAndHidingViews_Previews: PreviewProvider {
    static var previews: some View {
        ShowingAndHidingViews()
    }
}

