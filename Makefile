.PHONY: lint check_dupes install

sources :=$(wildcard ./exercises/**.json)
general_sources :=$(wildcard ./general_exercises/*.json)

lint:
	check-jsonschema --schemafile ./schema.json $(sources)

lint-general:
	check-jsonschema --schemafile ./general_exercises/schema_general.json $(general_sources)
check_dupes:
		# check for duplicate id's, if there's ID's listed here
		# we've got duplicate id's that need to be resolved
		jq -s ".[]" $(sources) | jq '.id' | sort | uniq -d
install:
	pip install check-jsonschema

dist/general_exercises.json: $(general_sources)
		# requires jq
		jq -s '.' $^ > $@
build-general: dist/general_exercises.json
		node scripts/build_exercises.js
dist/exercises.json: $(sources)
		# requires jq
		# brew install jq (for macos)
		jq -s '.' $^ > $@
dist/exercises.nd.json: $(sources)
		# output to new line delimited JSON
		# for use to import into PostgreSQL via the COPY command
		#
	  # https://konbert.com/blog/import-json-into-postgres-using-copy
		# https://www.postgresql.org/docs/current/sql-copy.html
		jq -s '.[]' $^ > $@
dist/exercises.csv: dist/exercises.json
		# output to csv format
		# requires in2csv which is part of
		# https://csvkit.readthedocs.io/
		in2csv ./dist/exercises.json > $@
