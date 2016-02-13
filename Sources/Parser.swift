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

public protocol ResultType {
    associatedtype Value
}

/// Parsing result wrapper.
public enum Result<V,T>: CustomStringConvertible, ResultType {
    public typealias Value = V

    /// Holds the parser result value if the parser succeeded
    case OK(Value)
    /// Parser failed to match an expected input. Other parsers might continue
    /// parsing if their predecessors failed.
    case Fail(String, T)
    /// Unrecoverable error
    case Error(String, T)

    public var description: String {
        switch self {
        case .OK(let value): return String(value)
        case .Fail(let error): return "Fail: \(error)"
        case .Error(let error): return "Error: \(error)"
        }
    }
}

//===----------------------------------------------------------------------===//
//
// Parser
//
//===----------------------------------------------------------------------===//

protocol ParserType {
    associatedtype Input
    associatedtype Output
}

/// The Parser – structure wrapping a function that reads a symbol from the input
/// stream and produces a parser result `Result` with output value and next
/// stream state
public struct Parser<I: EmptyCheckable, O>: ParserType {
    public typealias Input = I
    public typealias Output = O

    var fun: Stream<Input> -> Result<(Output,Stream<Input>),Input>

    /// Initializes the parser with a fuction `parse` which takes an input stream
    /// and produces a parser result wit the output value and advanced stream
    /// state.
    public init(_ parse: Stream<Input> -> Result<(Output,Stream<Input>),Input>) {
        self.fun = parse
    }

    public func parse(stream: Stream<Input>) -> Result<(Output, Stream<Input>),Input> {
        return self.fun(stream)
    }
}
