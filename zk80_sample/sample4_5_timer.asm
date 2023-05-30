	org 8000
	ld hl, 83f8
	sub a
on_off:
	ld (hl), a		// 7セグメントLED更新
	call delay:		// 約1秒
	xor 80			// 最上位ビットを反転
	jr on_off:
delay:
	ld b, 25
loop:
	call 02ef
	djnz loop:
	ret
