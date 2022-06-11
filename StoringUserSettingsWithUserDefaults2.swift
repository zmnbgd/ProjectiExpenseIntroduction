//
//  StoringUserSettingsWithUserDefaults2.swift
//  ProjectiExpenseIntroduction
//
//  Created by Marko Zivanovic on 11.6.22..
//

import SwiftUI

struct StoringUserSettingsWithUserDefaults2: View {
    
    @AppStorage("Tap count") private var tapCount = 0
    
    var body: some View {
        Button("Tap count \(tapCount)") {
            tapCount += 1
        }
    }
}

struct StoringUserSettingsWithUserDefaults2_Previews: PreviewProvider {
    static var previews: some View {
        StoringUserSettingsWithUserDefaults2()
    }
}
