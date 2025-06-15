//
//  Item.swift
//  MySandBox
//
//  Created by 青木振一郎 on 2025/06/15.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
