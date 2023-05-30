	org 8000
keyin:
	call 0216
	cp ff
	jr z, keyin:		// ƒL[“ü—Í‚È‚µ
	ld hl, 83f7
	ld (hl), a
	call 01c0		// •\¦
	jr keyin:
