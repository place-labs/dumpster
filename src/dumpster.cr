require "./dumpster/cli"

RUNNING_SPECS = PROGRAM_NAME.ends_with? "crystal-run-spec.tmp"

Dumpster::Cli.run unless RUNNING_SPECS
