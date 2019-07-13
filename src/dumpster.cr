require "./dumpster/cli"

running_specs = PROGRAM_NAME.ends_with? "crystal-run-spec.tmp"

Dumpster::Cli.run unless running_specs
