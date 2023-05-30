	org 8000
	ld hl, 83f8		// 表示位置
	ld (hl), 38		// 表示用セグメントデータ
	halt
