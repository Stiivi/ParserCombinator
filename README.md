ParserCombinator
================

Simple ParserCombinator framework for Swift

Operators:

* `a || b`: `alternate(a,b)` - if left side fails, then consider right side
  (also known as `<|>`
* `a + b`: `then(a,b)` - make a tuple from the left side and the right side
* `_ *> b`: `xthen(_,b)` – skip the left side (for example a required keyword) and return the right side
* `a <* _`: `thenx(a,_)` – skip the left side and return the right side
* `a => f`: apply function to a result
* unary `§x`: `expect(value)` – take a symbol matching value
* unary `%x`: `item(expeted)` – take any symbol, if does not match then retursn
  an error `expected`


Example
=======

Here is a simple arithmetic expression parser example. We are using a stream
that is already processed. Writing a lexer is left as an exercise to the reader.

```swift
import ParserCombinator


// Basic token parser – converts a symbol from input stream into an integer
let number: Parser<String, Int> = %"number" => { num in Int(num)! }

// Declaration for the recursive reference
let expr: Parser<String, Int>

// Here we reference future value of expn
let factor =
        (§"(" *> wrap { expr } <* §")")
        || number

let term   =
        (factor + (§"*" *> factor))      => (*)
        || (factor + (§"/" *> factor))   => (/)
        || factor

// Definition of the
expr   =
        (term + (§"+" *> term))      => (+)
        || (term + (§"-" *> term))   => (-)
        || term

let parser = expr

let source = ["1", "+", "2", "*", "(", "3", "+","4", ")"].stream()

let result = parser.parse(source)
```

Reading
=======

[Higher-Order Functions for Parsing, Graham Hutton]
(http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.63.3555&rep=rep1&type=pdf)

[Write You a Haskell, Stephen Diehl](http://dev.stephendiehl.com/fun/002_parsers.html)

Author
======

Stefan Urbanek <stefan.urbanek@gmail.com>
Twitter: [@Stiivi](https://twitter.com/stiivi)

License
=======

MIT. See the LICENSE file.
