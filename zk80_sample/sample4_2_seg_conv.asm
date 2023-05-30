	org 8000
	ld hl, 83f4
	ld (hl), 12
	inc hl
	ld (hl), 34
	inc hl
	ld (hl), ab
	inc hl
	ld (hl), cd
	call 01c0
	halt
