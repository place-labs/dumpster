http://tmm1.net/ruby21-objspace/
https://github.com/ruby/ruby/blob/trunk/include/ruby/ruby.h
https://github.com/ruby/ruby/blob/trunk/include/ruby/ruby.h#L485-L517

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


Provide ability to filter using BM (based on cmd line options)

For filtering by class - BM scan for class entry, then use address in BM scan
for lines referencing it.

When reading, use pos/file.size to update progress



---
$ dumpster
Usage: dumpster [OPTION]... FILE
Try 'dumpster --help' for more information.

---
$ dumpster --help
Usage: dumpster [OPTION]... FILE
Analyses the contents of a Ruby MRI heap dump in FILE.

 -q, --quick           provide a partial analysis (instance counts only)
 -g, --generation=NUM  only inspect objects allocated in generation NUM
 -f, --file=PATTERN    only inspect objects instantiated within files matching PATTERN
 -c, --class=NAME      only inspect objects of class NAME

---
$ dumpster ruby-heap.dump --quick
◢ Analysing (34%)

...
Found 37678936 heap objects
Built from 4787 classes

► Top objects by instance count
  89098     Foo::Bar
  9809      Test::A
  4377      A::B
  9309      C::Hkkljfs


---
$ dumpster ruby-heap.dump

Found 37678936 heap objects
Built from 4787 classes
Using 34995Mb of memory

► Allocations by generation
  Gen     | Objects   | Mem usage
  *         23497
  17        879
  18        769
  19        9876
  20        67

► Top objects by instance count
  1         Foo::Bar
  9809      Test::A
  4377      A::B
  9309      C::Hkkljfs

► Top objects by size


► Allocations by location
  1245      /foo/bar:6
