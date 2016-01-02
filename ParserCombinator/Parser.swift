//
//  Parser.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 01/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

//===----------------------------------------------------------------------===//
//
// Result
//
//===----------------------------------------------------------------------===//

/// Parsing error with error message
public enum ParserError: ErrorType, CustomStringConvertible {
    case Error(String)

    public var description: String {
        switch self {
        case Error(let s): return s
        }
    }
}

/// Parsing result
public enum Result<V>: CustomStringConvertible {
    public typealias Value = V
    case Failure(ErrorType)
    case Success(Value)

    public var description: String {
        switch self {
        case .Failure(let error): return "Error: \(error)"
        case .Success(let value): return String(value)
        }
    }
    public func flatMap<T>(transform: Value -> Result<T>) -> Result<T> {
        switch self {
        case .Failure(let error): return Result<T>.Failure(error)
        case .Success(let value): return transform(value)
        }
    }
}

/// Unwrapping
public func ??<T>(left: Result<T>, right: Result<T>) -> Result<T> {
    switch left {
    case .Success: return left
    case .Failure: return right
    }
}

//===----------------------------------------------------------------------===//
//
// Parser
//
//===----------------------------------------------------------------------===//

/// The Parser definition
public struct Parser<T: EmptyCheckable, O> {
    public typealias Token = T
    public typealias Function = Stream<T> -> Result<(O,Stream<T>)>

    public var parse: Function

    public init(_ parse: Function) {
        self.parse = parse
    }
}

