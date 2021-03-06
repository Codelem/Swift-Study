/*:
## `CustomStringConvertible` and `CustomDebugStringConvertible`

Functions like `print`, `String(describing:)`, and string interpolation are
written to take any type, no matter what. Even without any customization, the
results you get back might be acceptable because structs print their properties
by default:

*/

//#-hidden-code
/// A simple regular expression type, supporting ^ and $ anchors,
/// and matching with . and *
public struct Regex {
    fileprivate let regexp: String
    
    /// Construct from a regular expression String
    public init(_ regexp: String) {
        self.regexp = regexp
    }
}
//#-end-hidden-code

//#-hidden-code
extension Regex {
    /// Returns true if the string argument matches the expression.
    public func match(_ text: String) -> Bool {

        // If the regex starts with ^, then it can only match the
        // start of the input
        if regexp.characters.first == "^" {
            return Regex.matchHere(regexp: regexp.characters.dropFirst(),
                text: text.characters)
        }

        // Otherwise, search for a match at every point in the input
        // until one is found
        var idx = text.startIndex
        while true {
            if Regex.matchHere(regexp: regexp.characters,
                text: text.characters.suffix(from: idx))
            {
                return true
            }
            guard idx != text.endIndex else { break }
            text.characters.formIndex(after: &idx)
        }

        return false
    }
}
//#-end-hidden-code

//#-hidden-code
extension Regex {
    /// Match a regular expression string at the beginning of text.
    fileprivate static func matchHere(
        regexp: String.CharacterView, text: String.CharacterView) -> Bool
    {
        // Empty regexprs match everything
        if regexp.isEmpty {
            return true
        }

        // Any character followed by * requires a call to matchStar
        if let c = regexp.first, regexp.dropFirst().first == "*" {
            return matchStar(character: c, regexp: regexp.dropFirst(2), text: text)
        }

        // If this is the last regex character and it's $, then it's a match iff the
        // remaining text is also empty
        if regexp.first == "$" && regexp.dropFirst().isEmpty {
            return text.isEmpty
        }

        // If one character matches, drop one from the input and the regex
        // and keep matching
        if let tc = text.first, let rc = regexp.first, rc == "." || tc == rc {
            return matchHere(regexp: regexp.dropFirst(), text: text.dropFirst())
        }

        // If none of the above, no match
        return false
    }

    /// Search for zero or more `c`'s at beginning of text, followed by the
    /// remainder of the regular expression.
    fileprivate static func matchStar
        (character c: Character, regexp: String.CharacterView,
            text: String.CharacterView)
        -> Bool
    {
        var idx = text.startIndex
        while true {   // a * matches zero or more instances
            if matchHere(regexp: regexp, text: text.suffix(from: idx)) {
                return true
            }
            if idx == text.endIndex || (text[idx] != c && c != ".") {
                return false
            }
            text.formIndex(after: &idx)
        }
    }
}
//#-end-hidden-code

//#-hidden-code
extension Regex: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        regexp = value
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self = Regex(stringLiteral: value)
    }
    public init(unicodeScalarLiteral value: String) {
        self = Regex(stringLiteral: value)
    }
}
//#-end-hidden-code

/*:
``` swift-example
print(Regex("colou?r"))
// prints out Regex(regexp: "colou?r")
```

Then again, you might want something a little prettier, especially if your type
contains private variables you don't want displayed. But never fear\! It only
takes a minute to give your custom class a nicely formatted output when it's
passed to `print`:

*/

//#-editable-code
extension Regex: CustomStringConvertible {
    public var description: String {
        return "/\(regexp)/"
    }
}
//#-end-editable-code

/*:
Now, if someone converts your custom type to a string through various means —
using it with a streaming function like `print`, passing it to
`String(describing:)`, or using it in some string interpolation — it'll print
out as `/expression/`:

*/

//#-editable-code
let regex = Regex("colou?r")
print(regex)
//#-end-editable-code

/*:
There's also `CustomDebugStringConvertible`, which you can implement when
someone calls `String(reflecting:)`, in order to provide more debugging output
than the pretty-printed version:

*/

//#-editable-code
extension Regex: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{expression: \(regexp)}"
    }
}
//#-end-editable-code

/*:
`String(reflecting:)` falls back to using `CustomStringConvertible` if
`CustomDebugStringConvertible` isn't implemented, and vice versa. So often,
`CustomDebugStringConvertible` isn't worth implementing if your type is simple.
However, if your custom type is a container, it's probably polite to conform to
`CustomDebugStringConvertible` in order to print the debug versions of the
elements the type contains. So we can extend the `FIFOQueue` example from the
collection protocols chapter:

*/

//#-hidden-code
/// A type that can `enqueue` and `dequeue` elements.
protocol Queue {
    /// The type of elements held in `self`.
    associatedtype Element
    /// Enqueue `element` to `self`.
    mutating func enqueue(_ newElement: Element)
    /// Dequeue an element from `self`.
    mutating func dequeue() -> Element?
}
//#-end-hidden-code

//#-hidden-code
/// An efficient variable-size FIFO queue of elements of type `Element`
struct FIFOQueue<Element>: Queue {
    fileprivate var left: [Element] = []
    fileprivate var right: [Element] = []

    /// Add an element to the back of the queue.
    /// - Complexity: O(1).
    mutating func enqueue(_ newElement: Element) {
        right.append(newElement)
    }

    /// Removes front of the queue.
    /// Returns `nil` in case of an empty queue.
    /// - Complexity: Amortized O(1).
    mutating func dequeue() -> Element? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
}
//#-end-hidden-code

//#-hidden-code
extension FIFOQueue: Collection {
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return left.count + right.count }
    
    public func index(after i: Int) -> Int {
        precondition(i < endIndex)
        return i + 1
    }
    
    public subscript(_ idx: Int) -> Element {
        precondition((0..<endIndex).contains(idx), "Index out of bounds")
        if idx < left.endIndex {
            return left[left.count - idx.advanced(by: 1)]
        } else {
            return right[idx - left.count]
        }
    }
}
//#-end-hidden-code

//#-hidden-code
extension FIFOQueue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(left: elements.reversed(), right: [])
    }
}
//#-end-hidden-code

//#-editable-code
extension FIFOQueue: CustomStringConvertible, 
    CustomDebugStringConvertible 
{
    public var description: String {
        // Print contained elements using String(describing:), which favors
        // CustomStringConvertible
        let elements = map { String(describing: $0) }.joined(separator: ", ")
        return "[\(elements)]"
    }
    
    public var debugDescription: String {
        // Print contained elements using String(reflecting:), which favors
        // CustomDebugStringConvertible
        let elements = map { String(reflecting: $0) }.joined(separator: ", ")
        return "FIFOQueue: [\(elements)]"
    }
}
//#-end-editable-code

/*:
Note the word "favors" there — `String(describing:)` falls back to
`CustomDebugStringConvertible` if `CustomStringConvertible` isn't available — so
if you do anything out of the ordinary when printing for debug, be sure to
implement `CustomStringConvertible` as well. But if your implementations for
`description` and `debugDescription` are identical, you can pick either one and
omit the other.

By the way, `Array` always prints out the debug description of its elements,
even when invoked via `String(describing:)`. The [reason given on the swift-dev
mailing
list](https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20151207/000272.html)
was that an array's description should never be presented to the user, so
debugging is the only use case. And an array of empty strings would look wrong
without the enclosing quotes, which `String.description` omits.

Given that conforming to `CustomStringConvertible` implies that a type has a
pretty `print` output, you may be tempted to write something like the following
generic function:

``` swift-example
func doSomethingAttractive<T: CustomStringConvertible>(with value: T) {
    // Print out something incorporating value, safe in the knowledge
    // it will print out sensibly.
}
```

But you're not supposed to use `CustomStringConvertible` in this manner. Instead
of poking at types to establish whether or not they have a `description`
property, you should use `String(describing:)` regardless and live with the ugly
output if a type doesn't conform to the protocol. This will never fail for any
type. And it's a good reason to implement `CustomStringConvertible` whenever you
write more than a very simple type. It only takes a handful of lines.

*/

