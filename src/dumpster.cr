require "./dumpster/cli"

# FIXME: find a less hacky method for doing this
RUNNING_SPECS = PROGRAM_NAME.ends_with? "crystal-run-spec.tmp"

Crystal.main &->Dumpster::Cli.run unless RUNNING_SPECS
