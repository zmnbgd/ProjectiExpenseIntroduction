//
//  ArchivingSwiftObjectsWithCodable.swift
//  ProjectiExpenseIntroduction
//
//  Created by Marko Zivanovic on 12.6.22..
//

import SwiftUI

struct user: Codable {
    
    let firstName: String
    let lastName: String
    
}

struct ArchivingSwiftObjectsWithCodable: View {
    
    @State private var userName = user(firstName: "Minja", lastName: "Zivanovic")
    
    var body: some View {
        Button("Save user") {
            let encoder = JSONEncoder()
            
            if let data = try? encoder.encode(userName) {
                UserDefaults.standard.set(data, forKey: "UserData")
            }
        }
    }
}

struct ArchivingSwiftObjectsWithCodable_Previews: PreviewProvider {
    static var previews: some View {
        ArchivingSwiftObjectsWithCodable()
    }
}
