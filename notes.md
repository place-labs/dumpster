http://tmm1.net/ruby21-objspace/
https://github.com/ruby/ruby/blob/trunk/include/ruby/ruby.h
https://github.com/ruby/ruby/blob/trunk/include/ruby/ruby.h#L485-L517

https://eaton.party/blog/configuring-docker-for-crystal-development


https://anomaly.io/understand-auto-cross-correlation-normalized-shift/index.html
https://anomaly.io/detect-correlation-time-series/

Single pass across each line

---

crystal build --verbose src/dumpster.cr --link-flags "-L /nix/store/zbw5w43lhbp7lrn7j5hcj36j1whdff92-liblapack-3.8.0/lib"

---

docker exec engine rbtrace -p 1 -e 'Thread.new{GC.start;require "objspace";ObjectSpace.trace_object_allocations_start}.join'

docker exec engine rbtrace -p 1 -e 'Thread.new{GC.start;require "objspace";io=File.open("/tmp/ruby-heap.dump", "w"); ObjectSpace.dump_all(output: io); io.close}.join'



---

Provide ability to filter using BM (based on cmd line options)

For filtering by class - BM scan for class entry, then use address in BM scan
for lines referencing it.

When reading, use pos/file.size to update progress

Keep hash of class address -> name
Count min sketch for grouping


****************
1. BM search for ' "type":"'
2. Case on first char to detect type and define jump
3. For fast search extract address, for full use `gets` prepend '{' and extract as JSON

extract char_at - check for 'O' or 'C'


Sub-problems
+ line segmentation / iteration
+ entry discard / pre-parse
+ entry parsing
+ space-bounded counting


+++++

---
$ dumpster
Usage: dumpster [OPTION]... FILE
Try 'dumpster --help' for more information.

---
$ dumpster --help
Usage: dumpster [OPTION]... FILE
Analyses the contents of a Ruby MRI heap dump in FILE.

 -q, --quick           provide a partial analysis (instance counts only)
 -n, --num=COUNT       show top COUNT objects in metrics (default: 20)
 -g, --generation=NUM  only inspect objects allocated in generation NUM
 -f, --file=PATTERN    only inspect objects instantiated within files matching PATTERN
 -c, --class=NAME      only inspect objects of class NAME

---
$ dumpster ruby-heap.dump --quick
◢ Analysing (34%)

...
Found 37678936 heap objects

► Top objects by instance count
  89098     Foo::Bar
  9809      Test::A
  4377      A::B
  9309      C::Hkkljfs


---
$ dumpster ruby-heap.dump

Found 37678936 objects
Built from 4787 classes
Using 34995MiB of memory

► Top allocations by location
  1245      /foo/bar:6

► Top instances by count
  1         Foo::Bar
  9809      Test::A
  4377      A::B
  9309      C::Hkkljfs

► Top instances by memory usage

► Top allocations by generation
  Gen     | Objects   | Mem usage
  *         23497
  17        879
  18        769
  19        9876
  20        67

---
$ dumpster --help
Usage: dumpster [OPTION]... FILE
Analyses the contents of a Ruby MRI heap dump in FILE to detect potential memory leaks.

 -n, --num=COUNT        show top COUNT objects in metrics (default: 20)
 -f, --file=PATTERN     only inspect objects instantiated within files matching PATTERN
 -c, --class=PATTERN    only inspect objects where the base class matches PATTERN
 -l, --locations-only   provide locations of interest only
 -t, --types-only       provide instance types only
 -m, --machine-readable output CSV data only to STDOUT for piping to other processes

$ dumpster ruby-heap.dump

Parsed 37678936 active objects
Across 583 generations

► Locations of interest
  Growth      | Instances   | Type        | Location
  0.26          12345         STRING        /foo/bar:6

► Types of interest
  Growth      | Instances   | Class
  0.26          12345         Foo::Bar::Example


---
$ dumpster ruby-heap.dump

Parsed 37678936 active objects
Across 4 generations

warning: only a small number of GC generations parsed, accuracy of the below analysis may be questionable...

► Locations of interest
  Growth      | Instances   | Type        | Location
  0.26          12345         STRING        /foo/bar:6

► Types of interest
  Growth      | Instances   | Class
  0.26          12345         Foo::Bar::Example


---
$ dumpster ruby-heap.dump

Parsed 37678936 active objects
Across 1 generations

error: not enough GC generations included within the dump file
