//
//  Models.swift
//  TagsLayout
//
//  Created by varunbhalla19 on 09/10/22.
//

import Foundation

enum Section {
    case one
}

struct Tag: Identifiable {
    let title: String
    let id: String = UUID.init().uuidString
    
    private static let tagStrings = [
        "UIViewController", "Lazy", "Tags", "Random", "Words", "Apple", "Vegetables", "Hey", "Banana", "Potato", "Facebook", "Instagram", "Twitter", "Reddit", "Music", "Technology", "iOS", "Android", "Swift", "Kotlin", "React", "Jetpack Compose", "UIKit", "SwiftUI", "Phones", "Tag Layout", "Functions", "Lists", "Map", "Reduce", "String", "Int", "Double", "Section", "Data Source", "Snapshot"
    ]
    
    private static let tags = Self.tagStrings.map(Tag.init(title:))
    
}
