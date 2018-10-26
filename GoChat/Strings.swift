//
//  Strings.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/2/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation

extension String
{
    func trimmed() -> String
    {
        let spaces = CharacterSet.whitespacesAndNewlines
        let trimmed =  self.trimmingCharacters(in: spaces)
        return trimmed
    }
}
