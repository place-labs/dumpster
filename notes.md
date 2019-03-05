Top objects
 - by instance count
 - by size


Count by class
- name

Count by generation




Single pass across each line

Build address -> offset, len mapping for associated line and store in mem
Override hash function to use mem address directly as hash

Build generation count

Build top object count




Index object
Overrides hash method -> mem address
Contains address, start and len
Build other attributes lazily

---

Single pass across each line (streaming)

Ignore ROOT objects - use skip_while

Other entries extract { address, type, class } into lazy structure

Index based on address

Count based on type

Count based on class




List count on type
List count on class (top) - requires full parse of associated class entries


---

Separately - requires full parse

Count based on generation
Count based on file:line
Size based on class
Size based on generation


---

Output
===

Analysis of ./ruby-heap.dump
---

Total mem usage: 4748mb
Active objects:  3887095


Allocations by generation
Gen | Objects
*     23497
17    879
18    769
19    9876
20    67


Top objects by instance count
Foo::Bar    89098
Test::A     98099
