	org 8000
keyin:
	call 0216
	cp ff
	jr z, keyin:		// �L�[���͂Ȃ�
	ld hl, 83f7
	ld (hl), a
	call 01c0		// �\��
	jr keyin:
