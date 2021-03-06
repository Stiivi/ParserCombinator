//
//  Operators.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 02/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

precedencegroup ReturnPrecedence {
	associativity: right
	higherThan: LogicalDisjunctionPrecedence
	lowerThan: AdditionPrecedence
}

precedencegroup BindPrecedence {
	associativity: right
	higherThan: ReturnPrecedence
	lowerThan: AdditionPrecedence
}


infix operator >>-: BindPrecedence

public func >>-<A,B,T>(parser: Parser<T,A>, f: @escaping (A)->Parser<T,B>) -> Parser<T,B> {
    return into(parser, f)
}


// Traditional
infix operator <|>: LogicalDisjunctionPrecedence

public func <|><T,O>(left: Parser<T,O>, right: Parser<T,O>) -> Parser<T,O> {
    return alternate(left, right)
}

// Convenient
public func ||<T,O>(left: Parser<T,O>, right: Parser<T,O>) -> Parser<T,O> {
    return alternate(left, right)
}


infix operator =>: ReturnPrecedence

public func => <T,A,B> (parser: Parser<T,A>, transform: @escaping (A)->B) -> Parser<T,B> {
    return using(parser, transform)
}

/*

Skip
====

*/

infix operator *> : BindPrecedence
public func *><T, A, B>(p: Parser<T,A>, q:Parser<T,B>) -> Parser<T,B> {
    return xthen(p, nofail(q))
}

infix operator <* : BindPrecedence
public func <*<T, A, B>(p: Parser<T,A>, q:Parser<T,B>) -> Parser<T,A> {
    return thenx(p, q)
}

// infix operator + { associativity left precedence 130 }
public func +<T,A,B> (p: Parser<T,A>, q: Parser<T,B>) -> Parser<T,(A,B)> {
    return then(p, q)
}

infix operator … : BindPrecedence
public func …<T,A,B> (p: Parser<T,A>, q: Parser<T,B>) -> Parser<T,(A,B)> {
    return then(p, q)
}

// String comparable
prefix operator §
public prefix func §<T: Equatable>(value: T) -> Parser<T, T>{
    return expect(value)
}

// String comparable
prefix operator %
public prefix func %<T>(expectation: String) -> Parser<T, T> {
    return item(expectation)
}


//===----------------------------------------------------------------------===//
//
// Swift syntax conveniences
//
//===----------------------------------------------------------------------===//

// TODO: Add this later
//
//extension ParserType
//        where   Self: StringLiteralConvertible,
//                Input: CustomStringConvertible,
//                Output: CustomStringConvertible,
//                Input == Output
//{
//    typealias ExtendedGraphemeClusterLiteralType = String
//    typealias UnicodeScalarLiteralType = String
//
//    init(stringLiteral value: StringLiteralType){
//        self = expectText(String(value))
//    }
//
//    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType){
//        self = expectText(String(value))
//    }
//
//    init(unicodeScalarLiteral value: UnicodeScalarLiteralType){
//        self = expectText(String(value))
//    }
//}
//

