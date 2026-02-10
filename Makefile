# LOG_FILE=$(shell nvim --headless -c 'lua print(require("keymap-stats").logfile)' -c "qall" 2>&1 | grep log)
LOG_FILE=$${HOME}/.local/share/${NVIM_APPNAME}/keymap-stats.nvim.log
tail-log:
	tail -F ${LOG_FILE}

truncate-log:
	truncate -s 0 ${LOG_FILE}

smoke-run:
	nvim --headless -c 'lua require("keymap-stats")' -c "qall"
lint:
	selene lua
test:
	nvim -l ./tests/busted.lua tests
test-debug:
	nvim -u ./tests/busted.lua tests/busted.lua

test-log:
	tail -f  .tests/data/astronvim/keymap-stats.nvim.log

test-minimal:
	nvim -u ./tests/minimal.lua tests/minimal.lua
