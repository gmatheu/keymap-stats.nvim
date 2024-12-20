LOG_FILE=$(shell nvim --headless -c 'lua print(require("keymap-stats").logfile)' -c "qall" 2>&1 | grep log)
tail-log:
	tail -F ${LOG_FILE}

truncate-log:
	truncate -s 0 ${LOG_FILE}

test:
	nvim -l ./tests/busted.lua tests
test-debug:
	nvim -u ./tests/busted.lua tests/busted.lua

test-log:
	tail -f  .tests/data/astronvim/keymap-stats.nvim.log

test-minimal:
	nvim -u ./tests/minimal.lua tests/busted.lua
