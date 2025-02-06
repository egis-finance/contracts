# Makefile

.PHONY: fmt build build-f test test-v anvil chisel lint

# Load variables from .env file
ifneq (,$(wildcard ./.env))
	include .env
	export
endif

# Commands
fmt:
	forge fmt

# Build the project using Forge
build:
	forge build

# Build the project using Forge with force
build-f:
	forge clean && forge build --force

# Run tests with low verbosity
test:
	forge test

# Run tests with high verbosity
test-v:
	forge test -vvvvv

# Foundry local anvil (do in a separate pane or tab)
anvil:
	anvil

# repl
chisel:
	chisel

lint:
	solhint src/*.sol test/*.sol script/*.sol --fix --noPrompt
