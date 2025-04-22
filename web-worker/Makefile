.PHONY: lint format format-check check fix all

## Lint with flake8 (does not modify code)
lint:
	flake8 .

## Format with autopep8 (auto-fix issues)
format:
	autopep8 . --in-place --recursive --aggressive --aggressive

## Check what autopep8 would change (no actual fixing)
format-check:
	autopep8 . --recursive --diff

## Run both lint and format check (non-destructive)
check: lint format-check

## Auto-fix and then lint again to confirm
fix:
	autopep8 . --in-place --recursive --aggressive --aggressive
	flake8 .

## Run everything: auto-fix, then lint
all: fix
