/*:
### Index Sets and Character Sets

`Set` is the only type in the standard library that conforms to `SetAlgebra`,
but the protocol is also adopted by two interesting types in Foundation:
`IndexSet` and `CharacterSet`. Both of these date back to a time long before
Swift was a thing. The way these and other Objective-C classes are now bridged
into Swift as fully featured value types — adopting common standard library
protocols in the process — is great because they'll instantly feel familiar to
Swift developers.

`IndexSet` represents a set of positive integer values. You can, of course, do
this with a `Set<Int>`, but `IndexSet` is way more storage efficient because it
uses a list of ranges internally. Say you have a table view with 1,000 elements
and you want to use a set to manage the indices of the rows the user has
selected. A `Set<Int>` needs to store up to 1,000 elements, depending on how
many rows are selected. An `IndexSet`, on the other hand, stores continuous
ranges, so a selection of the first 500 rows in the table only takes two
integers to store (the selection's lower and upper bounds).

However, as a user of an `IndexSet`, you don't have to worry about the internal
structure, as it's completely hidden behind the familiar `SetAlgebra` and
`Collection` interfaces. (Unless you want to work on the ranges directly, that
is. `IndexSet` exposes a view to them via its `rangeView` property, which itself
is a collection.) For example, you can add a few ranges to an index set and then
map over the indices as if they were individual members:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
var indices = IndexSet()
indices.insert(integersIn: 1..<5)
indices.insert(integersIn: 11..<15)
let evenIndices = indices.filter { $0 % 2 == 0 }
//#-end-editable-code


/*:
`CharacterSet` is an equally efficient way to store a set of Unicode characters.
It's often used to check if a particular string only contains characters from a
specific character subset, such as `alphanumerics` or `decimalDigits`. Unlike
`IndexSet`, `CharacterSet` isn't a collection, though. We'll talk a bit more
about `CharacterSet` in the chapter on strings.

*/
