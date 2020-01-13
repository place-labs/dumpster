# Dumpster
An analysis tool for Ruby MRI heap dumps.

Provides automated analysis and identification of potential memory leaks within
a program.

## Usage

### Capturing Heap Dumps
Using [rbtrace](https://github.com/tmm1/rbtrace), enable allocation tracking on
the ruby process you'd like to inspect.
_Note:_ this will result in a perf impact while active. Use with care.
```
rbtrace -p <pid> -e 'Thread.new{require "objspace";ObjectSpace.trace_object_allocations_start}.join'
```

After the process has had time to rotate through a few GC generations, export
via:
```
rbtrace -p <pid> -e 'Thread.new{require "objspace";io=File.open("/tmp/ruby-heap.dump", "w");ObjectSpace.dump_all(output: io);io.close}.join'
```

To stop tracking and clear allocations from mem:
```
rbtrace -p <pid> -e 'Thread.new{GC.start;require "objspace";ObjectSpace.trace_object_allocations_stop;ObjectSpace.trace_object_allocations_clear}.join'
```

### Analysis
!! When using outside of a dev context, analysis should always take place on a
machine remote to that running the application under analysis.

```
./dumpster ruby-heap.dump
```

Depending on the size of heap dump being parsed, analysis may take some time.
Progress will be provided. When complete, a ordered list of 'locations of
interest' will be provided. These are lines responsible for an increasing number
of long-lived object allocations that may be indicative of a memory leak.

## Contributing

1. Fork it ( https://github.com/[your-github-name]/dumpster/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Kim Burgess](https://github.com/kimburgess) Kim Burgess - creator, maintainer
