
run:
	rebar compile
	erl -pa ./ebin -boot start_sasl -s elredis_app


.phony: run
