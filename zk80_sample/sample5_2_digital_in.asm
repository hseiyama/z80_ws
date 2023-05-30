	org 8000
	ld hl, 83f8
	ld b, 03
in:
	call 0305
	or a
	jr nz, set_high:
	ld (hl), 38
	jr in:
set_high:
	ld (hl), 76
	jr in:
