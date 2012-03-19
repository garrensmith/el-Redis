clean:
	rebar clean

test: clean eunit

eunit:
	rebar eunit skip_deps=true

run:
	rebar compile
	erl -pa ./ebin -boot start_sasl -s elredis_app


.phony: run, eunit, test
