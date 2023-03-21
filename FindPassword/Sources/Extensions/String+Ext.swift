//
//  File.swift
//  FindPassword
//
//  Created by Виталик Молоков on 15.03.2023.
//

import Foundation

extension String {
    var lowercase:   String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase:   String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var letters:     String { return lowercase + uppercase }
    
    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}
