	org 8000
	ld hl, 83f8
	sub a
on_off:
	ld (hl), a		// 7�Z�O�����gLED�X�V
	call delay:		// ��1�b
	xor 80			// �ŏ�ʃr�b�g�𔽓]
	jr on_off:
delay:
	ld b, 25
loop:
	call 02ef
	djnz loop:
	ret
