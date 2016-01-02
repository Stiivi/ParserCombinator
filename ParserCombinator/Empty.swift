//
//  Empty.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 01/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

/// Objects that implement `isEmpty` property.
/// It is recommended for tokens to conform to this protocol. For example a
/// Token enum might have a case `.Empty` that would be it's `emptyValue`.
/// Empty values are used to check end of the input stream.
public protocol EmptyCheckable {
    static var EmptyValue: Self { get }
    var isEmpty: Bool { get }
}

/// Makes optional to respond to `isEmpty`.
extension Optional: EmptyCheckable {
    public static var EmptyValue: Optional {
        return nil
    }
    /// - Returns: `true` when the receiver is nil. No unwrapping is done
    public var isEmpty: Bool {
        return self == nil
    }
}

/// Makes optional to respond to `isEmpty`.
extension Character: EmptyCheckable {
    public static var EmptyValue: Character {
        return "\0"
    }
    /// - Returns: `true` when the receiver is "\0".
    public var isEmpty: Bool {
        return self == "\0"
    }
}

/// Claims `String` to have `isEmpty`. Primarily for `succeed(String)`
extension String: EmptyCheckable {
    public static var EmptyValue: String {
        return ""
    }
}