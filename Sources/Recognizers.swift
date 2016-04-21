//
//  Recognizers.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 01/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

//===----------------------------------------------------------------------===//
//
// Recognizers
//
//===----------------------------------------------------------------------===//

/// Parser that always succeeds with value `value`
///
/// - Returns: Parser of the same type as the `value`
public func succeed<T,O>(_ value: O) -> Parser<T, O> {
    return Parser { Result.OK(value, $0) }
}


/// Parser that always fails with an error `error`.
///
/// - Returns: Parser of the same type as the input parser
public func fail<T,O>(_ error: String) -> Parser<T, O> {
    return Parser {
        input in
        Result.Fail(error, input.head)
    }
}


/// Converts a failure to an error
///
/// - Returns: Parser of the same type as the input parser
public func nofail<T,O>(_ parser: Parser<T,O>) -> Parser<T,O> {
    return Parser {
        input in

        let result = parser.parse(input)

        switch result {
        case .Fail(let error, let token):
            return Result.Error(error, token)
        default:
            return result
        }
    }
}


/// Recognise single symbol that matches the predicate `condition`. If the symbol
/// does not match, then an error `expected` is returned.
///
/// - Returns: Parser of the same type as the input stream
///
public func satisfy<T: EmptyCheckable>(_ expected: String, _ condition: (T) -> Bool) -> Parser<T,T> {
    return Parser {
        input in
        let (head, tail) = (input.head, input.tail)
        let message = "Expected \(expected), got \(head)."
        if head.isEmpty {
            return fail("Unexpected end of input. \(message)").parse(tail)
        }
        else {
            if condition(head) {
                return succeed(head).parse(tail)
            }
            else {
                return fail(message).parse(tail)
            }
        }
    }
}


/// Recognizes a token that is equal to value
///
/// - Returns: Parser of the same type as the input stream
///
public func expect<T: Equatable>(_ value: T) -> Parser<T, T>{
    return satisfy("expected \(value)") {
        $0 == value
    }
}


/// Recognizes symbol convertible to a string with given value that is also
/// converted to a string: `String(input) == String(value)`.
///
/// - Returns: Parser of the same type as the input stream
///
public func expectText<T: CustomStringConvertible>(_ value: T) -> Parser<T, T>{
    return satisfy("expected \(value)") {
        String($0) == String(value)
    }
}

/// Parser that takes any non-empty token from the input. If the token is not
/// present, for example because of end of the input stream, then
/// `expected` error is returned.
///
/// - Returns: Parser of the same type as the source tokens
public func item<T>(_ expected: String) -> Parser<T, T> {
    return satisfy(expected) { _ in true }
}


/**
 Wraps a function in a closure that just passes result of the wrapped parser.
 This function can be used when constructing recursive grammar:
 
        // Declaration of expr that will be defined later
        let expr: Parser<String, Int>

        // Recursive reference to expr:
        let term =
                (§"(" *> wrap { expr } <* §")")
                || number

        // Actual definition of the parser
        let expr   =
                (term + (§"+" *> term))      => op(+)
                || (term + (§"-" *> term))   => op(-)
                || term

 - Returns: wrapped parser of the same type
 
 */
public func wrap<T,O>(_ parser: () -> Parser<T,O>) -> Parser<T,O> {
    return Parser {
        input in return parser().parse(input)
    }
}
