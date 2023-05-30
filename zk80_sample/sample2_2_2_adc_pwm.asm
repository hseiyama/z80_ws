// PORT1(半固定抵抗)からAD変換した値を読んで、
// PORT2(圧電スピーカー)へパルス幅変調を設定します。

	org 8000
start:
	ld b, 01		// PORT1
	call 030F		// AD変換
	call delay:		// 約200ms
	ld b, 02		// PORT2
	ld de, 01f4		// デューティ比 50%
	call 030a		// 取得した値(HL = 0～1023)で周波数設定
	jr start:
delay:
	ld b, 2c		// 44回
loop:
	call 02dd		// 4.5ms
	djnz loop:
	ret
