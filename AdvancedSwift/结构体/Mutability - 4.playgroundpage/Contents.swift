/*:
Inside a class, we can control mutable and immutable properties with `var` and
`let`. For example, we could create our own variant of Foundation's `Scanner`,
but for binary data. The `Scanner` class allows you to scan values from a
string, advancing through the string with each successful scanned value. A
`Scanner` does this by storing a string and its current position in the string.
Similarly, our class, `BinaryScanner`, contains the position (which is mutable),
and the original data (which will never change). This is all we need to store in
order to replicate the behavior of `Scanner`:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
class BinaryScanner {
    var position: Int
    let data: Data
    init(data: Data) {
        self.position = 0
        self.data = data
    }
}
//#-end-editable-code

/*:
We can also add a method that scans a byte. Note that this method is mutating:
it changes the `position` (unless we've reached the end of the data):

*/

//#-editable-code
extension BinaryScanner {
    func scanByte() -> UInt8? {
        guard position < data.endIndex else {
            return nil
        }
        position += 1
        return data[position-1]
    }
}
//#-end-editable-code

/*:
To test it out, we can write a method that scans all the remaining bytes:

*/

//#-editable-code
func scanRemainingBytes(scanner: BinaryScanner) {
    while let byte = scanner.scanByte() {
        print(byte)
    }
}
let scanner = BinaryScanner(data: "hi".data(using: .utf8)!)
scanRemainingBytes(scanner: scanner)
//#-end-editable-code

/*:
Everything works as expected. However, it's easy to construct an example with a
race condition. If we use Grand Central Dispatch to call `scanRemainingBytes`
from two different threads, it'll eventually run into a race condition. In the
code below, the condition `position < data.endIndex` can be true on one thread,
but then GCD switches to another thread and scans the last byte. Now, if it
switches back, the `position` will be incremented and the subscript will access
a value that's out of bounds:

``` swift-example
for _ in 0..<Int.max {
    let newScanner = BinaryScanner(data: "hi".data(using: .utf8)!)
    DispatchQueue.global().async {
        scanRemainingBytes(scanner: newScanner)
    }
    scanRemainingBytes(scanner: newScanner)
}
```

The race condition doesn't occur too often (hence the `Int.max`), and is
therefore difficult to find during testing. If we change `BinaryScanner` to a
struct, this problem doesn't occur at all. In the next section, we'll look at
why.

*/
