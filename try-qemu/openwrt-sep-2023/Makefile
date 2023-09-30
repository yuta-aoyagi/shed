.POSIX:

all: help # TODO: replace later

help:
	@echo "usage: make [all|help|check]" >&2

check:
	bundle exec rubocop -S
	bundle exec rspec
