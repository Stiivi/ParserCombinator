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
public func alternate<T,O>(left: Parser<T,O>, _ right: Parser<T,O>) -> Parser<T,O> {
    return Parser {
        input in
        let result = left.parse(input)
        debugPrint("--- parsed: \(result)")
        if case .OK = result {
            return result
        }
        else {
            return right.parse(input)
        }
    }
}

infix operator <|> { associativity left precedence 130 }
public func <|><T,O>(left: Parser<T,O>, right: Parser<T,O>) -> Parser<T,O> {
    return alternate(left, right)
}

/**
    Also known as `bind`.

    into :: parser * ** -> (** -> parser * ***) -> parser * ***
    (p $into f) inp = g (p inp)
                      where
                        g (OK (v,inp’)) = f v inp’
                        g other         = other
*/

public func into<A,B,T>(parser: Parser<T,A>, _ f: (A->Parser<T,B>)) -> Parser<T,B> {
    return Parser{
        input in
        let result = parser.parse(input)

        switch result {
        case .OK(let value, let input2):
            return f(value).parse(input2)
        case .Fail(let error):
            return Result.Fail(error)
        case .Error(let error):
            return Result.Error(error)
        }
    }
}

infix operator >>- { associativity left precedence 130 }
public func >>-<A,B,T>(parser: Parser<T,A>, f: (A->Parser<T,B>)) -> Parser<T,B> {
    return into(parser, f)
}

/**
    using :: parser * ** -> (** -> ***) -> parser * ***
    p $using f = p $into \v. succeed (f v)
*/
public func using<T,A,B> (parser: Parser<T,A>, _ transform: A->B) -> Parser<T,B> {
    return into(parser) {
        value in
        return succeed(transform(value))
    }
}

/**
    then :: parser * ** -> parser * *** -> parser * (**,***)
    p $then q = p $into \v. q $using \w.(v,w)
*/

public func then<T,A,B> (p: Parser<T,A>, _ q: Parser<T,B>) -> Parser<T,(A,B)> {
    return into(p) {
        v in
        return using(q) {
            w in (v, w)
        }
    }
}


/*
 
 (Parser cs1) <*> (Parser cs2) =
 Parser (\s -> [(f a, s2) | (f, s1) <- cs1 s, (a, s2) <- cs2 s1]
*/

/*
 many :: f a -> f [a]
 many v = many_v
         where
            many_v = some_v <|> pure []
            some_v = (:) <$> v <*> many_v

 */
/**

    many :: parser * ** -> parser * [**]
    many p = ((p $then many p) $using cons) $alt (succeed [])

*/

public func many<T, O>(p:Parser<T,O>) -> Parser<T,[O]>{
    let inner_many = Parser {
        many(p).parse($0)
    }

    let some = using(then(p, inner_many), cons)

    return alternate(some, succeed([O]()))
}

/**
 
 some :: parser * ** -> parser * [**]
 some p = (p $then many p) $using cons

*/
public func some<T, O>(p:Parser<T,O>) -> Parser<T,[O]>{
    return using(then(p, many(p)), cons)
}

func cons<T>(tuple: (T, [T])) -> [T] {
    let (head, tail) = tuple
    return [head] + tail
}
