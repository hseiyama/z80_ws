	org 8000
	ld hl, 020b		// (C音) 523Hz
	call sound:
	ld hl, 024b		// (D音) 587Hz
	call sound:
	ld hl, 0293		// (E音) 659Hz
	call sound:
	ld hl, 02ba		// (F音) 698Hz
	call sound:
	ld hl, 0310		// (G音) 784Hz
	call sound:
	ld hl, 0370		// (A音) 880Hz
	call sound:
	ld hl, 03dc		// (B音) 988Hz
	call sound:
	ld hl, 0417		// (C音) 1047Hz
	call sound:
	ld hl, 0000		// 停止
	call sound:
	halt
sound:
	ld b, 02
	ld de, 01f4		// デューティ比 50%
	call 030a		// PWM信号出力
	ld b, 2c		// 44回
loop:
	call 02dd		// 4.5ms
	djnz loop:
	ret
