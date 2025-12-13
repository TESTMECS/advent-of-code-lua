alias cp := commit-push
commit-push MSG:
	git add . && git commit -m "{{MSG}}" && git push

runp year day part:
	lua ~/advent-of-code-lua/src/run.lua {{year}} {{day}} {{part}}

run year day:
	lua ~/advent-of-code-lua/src/run.lua {{year}} {{day}}
