//
//  Functions.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 02/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

/// Concatenates two tuple elements where the tuple represents (head, tail) of 
/// a list of element type of head.
/// - Returns: a list of concatenated head with the tail
public func cons<T>(tuple: (T, [T])) -> [T] {
    let (head, tail) = tuple
    return [head] + tail
}