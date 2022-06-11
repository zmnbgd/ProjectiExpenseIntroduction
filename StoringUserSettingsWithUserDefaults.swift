//
//  StoringUserSettingsWithUserDefaults.swift
//  ProjectiExpenseIntroduction
//
//  Created by Marko Zivanovic on 11.6.22..
//

import SwiftUI

struct StoringUserSettingsWithUserDefaults: View {
    
    @State private var tapCount = UserDefaults.standard.integer(forKey: "Tap")
    
    var body: some View {
        Button("Tap count \(tapCount)") {
            tapCount += 1
            UserDefaults.standard.set(tapCount, forKey: "Tap")
        }
    }
}

struct StoringUserSettingsWithUserDefaults_Previews: PreviewProvider {
    static var previews: some View {
        StoringUserSettingsWithUserDefaults()
    }
}
