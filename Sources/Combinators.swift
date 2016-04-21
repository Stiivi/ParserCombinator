//
//  Combinators.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 01/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

//===----------------------------------------------------------------------===//
//
// Combinators
//
//===----------------------------------------------------------------------===//

/// Represents alternation. If the first parser is not successful, then the
/// result of the right one is returned.
///
public func alternate<T,O>(_ left: Parser<T,O>, _ right: Parser<T,O>) -> Parser<T,O> {
    return Parser {
        input in
        let result = left.parse(input)
        switch result {
        case .OK: return result
        case .Error: return result
        default: return right.parse(input)
        }
    }
}


/// Parser that returns value from the wrapped parser if it succeeds or returns
/// `nil`.
///
public func option<T,O>(_ parser: Parser<T,O>) -> Parser<T, O?> {
    return alternate(using(parser, {r in Optional.some(r)}),
                     succeed(Optional.none))
}

/// Parser that returns `true` if the wrapped parser succeeds or `false` if the
/// wrapped parser fails.
///
public func optionFlag<T,O>(_ parser: Parser<T,O>) -> Parser<T, Bool> {
    return alternate(using(parser, {_ in true}),
                     succeed(false))
}

/// Parser that passes output of the wrapped parser, transforms it through a
/// function `f` which should return a parser. The returned parser might
/// be of another type as the wrapped parser.
///
/// Also known as `bind`.
///
///     into :: parser * ** -> (** -> parser * ***) -> parser * ***
///     (p $into f) inp = g (p inp)
///                       where
///                           g (OK (v,inp’)) = f v inp’
///                           g other         = other
///
public func into<A,B,T>(_ parser: Parser<T,A>, _ f: (A->Parser<T,B>)) -> Parser<T,B> {
    return Parser{
        input in
        let result = parser.parse(input)

        switch result {
        case .OK(let value, let input2):
            return f(value).parse(input2)
        case .Fail(let error, let token):
            return Result.Fail(error, token)
        case .Error(let error, let token):
            return Result.Error(error, token)
        }
    }
}
/// Parser that transforms value from the wrapped parser with a function
/// `transform`
///
///     using :: parser * ** -> (** -> ***) -> parser * ***
///     p $using f = p $into \v. succeed (f v)
///
public func using<T,A,B> (_ parser: Parser<T,A>, _ transform: A->B) -> Parser<T,B> {
    return into(parser) {
        value in
        return succeed(transform(value))
    }
}

/// Parser that puts result of two wrapped parsers into a tuple
///
///     then :: parser * ** -> parser * *** -> parser * (**,***)
///     p $then q = p $into \v. q $using \w.(v,w)
///
public func then<T,A,B> (_ p: Parser<T,A>, _ q: Parser<T,B>) -> Parser<T,(A,B)> {
    return into(p) {
        v in
        return using(q) {
            w in (v, w)
        }
    }
}

//===----------------------------------------------------------------------===//
//
// Repeats
//
//===----------------------------------------------------------------------===//


/// Parser that parses zero or more occurences of the wrapped parser
///
///     many :: parser * ** -> parser * [**]
///     many p = ((p $then many p) $using cons) $alt (succeed [])
////
public func many<T, O>(_ p:Parser<T,O>) -> Parser<T,[O]>{
    let inner_many = Parser {
        many(p).parse($0)
    }

    let some = using(then(p, inner_many), cons)

    return alternate(some, succeed([O]()))
}


/// Parser that parses one or more occurences of the wrapped parser
///
///     some :: parser * ** -> parser * [**]
///     some p = (p $then many p) $using cons
///
public func some<T, O>(_ p:Parser<T,O>) -> Parser<T,[O]>{
    return using(then(p, many(p)), cons)
}

/// Parser that parses one or more occurences of wrapped parser `p` separated
/// by separator parser `sep`. For example the parser:
///
///     let parser = separated(item("item"), expect(","))
///
/// Matches a stream of input `["a", ",", "b", ",", "c"]`
///
public func separated<T, A, B>(_ p: Parser<T,A>, _ sep:Parser<T,B>) -> Parser<T,[A]> {
    return using(then(p, many(xthen(sep, p))), cons)
}


//===----------------------------------------------------------------------===//
//
// Others
//
//===----------------------------------------------------------------------===//
/// Parser that reads input from both parsers but returns just the result from
/// the later one.
///
///     xthen :: parser * ** -> parser * *** -> parser * ***
///     p1 $xthen p2 = (p1 $then p2) $using snd
///
public func xthen<T, A, B>(_ p: Parser<T,A>, _ q:Parser<T,B>) -> Parser<T,B> {
    return using(then(p, q)) { (_, second) in second }
}

/// Parser that reads input from both parsers but returns just the result from
/// the first one.
///
///     thenx :: parser * ** -> parser * *** -> parser * **
///     p1 $thenx p2 = (p1 $then p2) $using fst
///
public func thenx<T, A, B>(_ p: Parser<T,A>, _ q:Parser<T,B>) -> Parser<T,A> {
    return using(then(p, q)) { (first, _) in first }
}

/// Parser that discards the output from the wrapped parser and returns a
/// `value` instead.
///     return :: parser * ** -> *** -> parser * ***
///     p $return v = p $using (const v)
///                   where const x y = x
///
public func `return`<T, A, B>(_ p: Parser<T,A>, value: B) -> Parser<T,B> {
    return succeed(value)
}
