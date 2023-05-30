	org 8000
adc:
	ld b, 01
	call 030f		// AD変換
	ld a, h
	ld (83f6), a		// データ表示部の上位2桁
	ld a, l
	ld (83f7), a		// データ表示部の下位2桁
	call 01c0		// 表示
	call delay:		// 約200ms
	jr adc:
delay:
	ld b, 2c		// 44回
loop:
	call 02dd		// 4.5ms
	djnz loop:
	ret
