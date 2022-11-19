.PHONY: clean test dev release
CLEAN_COV=if [ -e luacov.report.out ]; then rm luacov.report.out; fi; if [ -e luacov.stats.out ]; then rm luacov.stats.out; fi
PWD=$(shell pwd)

LUA_PATH := ./src/?.lua
LUA_PATH := $(LUA_PATH);$(PWD)/external/du-unit-testing/src/?.lua
LUA_PATH := $(LUA_PATH);$(PWD)/external/du-unit-testing/src/mocks/?.lua
LUA_PATH := $(LUA_PATH);$(PWD)/external/du-unit-testing/external/du-luac/lua/?.lua
LUA_PATH := $(LUA_PATH);$(PWD)/external/du-unit-testing/external/du-lua-examples/?.lua
LUA_PATH := $(LUA_PATH);$(PWD)/external/du-unit-testing/external/du-lua-examples/api-mockup/?.lua
LUA_PATH := $(LUA_PATH);$(PWD)/external/du-unit-testing/external/du-lua-examples/api-mockup/utils/?.lua

all: release

lua_path:
	@echo "$(LUA_PATH)"

clean_cov:
	@$(CLEAN_COV)

clean_report:
	@if [ -d ./luacov-html ]; then rm -rf ./luacov-html; fi

clean: clean_cov clean_report
	@rm -rf out

test: clean
	@LUA_PATH="$(LUA_PATH)" busted .
	@luacov
	@$(CLEAN_COV)

dev: test
	@LUA_PATH="$(LUA_PATH)" du-lua build --copy=development/main
	@# Modify file inline. Actual regex is '/^\s*---.*$/d' but $ must be doubled in make file
	@sed -i '/^\s*---.*$$/d' "./out/development/example/stream/screen.lua"

release: test
	@LUA_PATH="$(LUA_PATH)" du-lua build --copy=release/main