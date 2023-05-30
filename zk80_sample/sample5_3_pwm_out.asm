	org 8000
	ld hl, 020b		// (C��) 523Hz
	call sound:
	ld hl, 024b		// (D��) 587Hz
	call sound:
	ld hl, 0293		// (E��) 659Hz
	call sound:
	ld hl, 02ba		// (F��) 698Hz
	call sound:
	ld hl, 0310		// (G��) 784Hz
	call sound:
	ld hl, 0370		// (A��) 880Hz
	call sound:
	ld hl, 03dc		// (B��) 988Hz
	call sound:
	ld hl, 0417		// (C��) 1047Hz
	call sound:
	ld hl, 0000		// ��~
	call sound:
	halt
sound:
	ld b, 02
	ld de, 01f4		// �f���[�e�B�� 50%
	call 030a		// PWM�M���o��
	ld b, 2c		// 44��
loop:
	call 02dd		// 4.5ms
	djnz loop:
	ret
