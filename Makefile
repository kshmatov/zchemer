.PHONY: all test test-engine test-gui run validate clean help

all: test validate

## test: run every engine/ and gui/ test (excludes gui/main.rkt, the runnable entry point)
test: test-engine test-gui

## test-engine: run engine/ rackunit tests
test-engine:
	raco test engine/

## test-gui: run gui/ rackunit tests without ever popping a visible window
test-gui:
	raco test -x gui/main.rkt gui/

## run: launch the native app (pass SAVE=path/to/progress.rktd to use a specific save file)
run:
	racket gui/main.rkt $(SAVE)

## validate: check every openspec capability spec is well-formed
validate:
	openspec validate --all --strict

## clean: remove raco's compiled-bytecode caches
clean:
	find . -type d -name compiled -not -path '*/openspec/*' -prune -exec rm -rf {} +

help:
	@grep -E '^## ' Makefile | sed 's/^## /  /'
