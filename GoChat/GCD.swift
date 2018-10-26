//
//  GCD.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/11/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation

/**
 Async wait helper. GCD abstraction.
 */
func wait(seconds: Double, then closure: @escaping () -> Void)
{
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        closure()
    }
}
