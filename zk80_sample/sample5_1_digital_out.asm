	org 8000
start:
	ld b, 04
	ld c, 01
	call on_off:
	ld b, 04
	ld c, 00
	call on_off:
	jr start:
on_off:
	call 0300
	ld b, 25
delay:
	call 02ef
	djnz delay:
	ret
