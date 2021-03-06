/*:
## Properties and Subscripts

There are two special kinds of methods that differ from regular methods:
computed properties and subscripts. A computed property looks like a regular
property, but it doesn't use any memory to store its value. Instead, the value
is computed on the fly every time the property is accessed. A computed property
is really just a method with unusual defining and calling conventions.

Let's look at the various ways to define properties. We'll start with a struct
that represents a GPS track. It stores all the recorded points in a stored
property called `record`:

*/

//#-hidden-code
import Foundation
import CoreLocation
//#-end-hidden-code

struct GPSTrack {
    var record: [(CLLocation, Date)] = []
}

/*:
We could also have defined `record` using `let` instead of `var`, in which case
it'd be a constant stored property and couldn't be mutated anymore.

*/
