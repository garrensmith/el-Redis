clean:
	rebar clean

test: clean eunit

eunit:
	rebar eunit skip_deps=true

run:
	rebar compile
	erl -pa ./ebin -pa deps/*/ebin -s elredis_app


.phony: run, eunit, test
