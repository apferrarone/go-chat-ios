//
//  Dictionaries.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/5/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation

// reader of dictionaries

protocol OptionalType
{
    associatedtype Wrapped
    var asOptional : Wrapped? { get }
}

extension Optional : OptionalType
{
    var asOptional : Wrapped? {
        return self
    }
}

extension Dictionary where Key : ExpressibleByStringLiteral, Value : OptionalType
{
    func safeFromNil() -> [String : AnyObject]
    {
        var safe = [String : AnyObject]()
        
        for (key, value) in self where key is String
        {
            if let key = key as? String {
                let unwrappedValue = value.asOptional as AnyObject
                safe[key] = unwrappedValue
            }
        }
        
        return safe
    }
}
