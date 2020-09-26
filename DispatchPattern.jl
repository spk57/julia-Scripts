#sbox5.jl
"""Implement a pattern for dispatching actions based on Truth table values"""

module DispatchPattern
using Match

struct Truth
  a::Bool
  b::Bool
end

actionAB()   =println("Do A and B")
actionA!B()  =println("Do A not B")
action!AB()  =println("Do B not A")
action!A!B() =println("Do nothing")

"Pattern for dispatching based on multiple truth cases"
dispatch!(item::Truth)=@match (item.a, item.b)  begin
  (true, true)          => actionAB()
  (true, false)         => actionA!B()
  (false, true)         => action!AB()
  (false, false)        => action!A!B()
  bad                   => println("Unknown dispatch: $bad")
end

truths=[Truth(true, true), 
        Truth(true, false),
        Truth(false, true),
        Truth(false, false)]

map(dispatch!, truths)

end