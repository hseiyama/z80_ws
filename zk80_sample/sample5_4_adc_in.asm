	org 8000
adc:
	ld b, 01
	call 030f		// AD�ϊ�
	ld a, h
	ld (83f6), a		// �f�[�^�\�����̏��2��
	ld a, l
	ld (83f7), a		// �f�[�^�\�����̉���2��
	call 01c0		// �\��
	call delay:		// ��200ms
	jr adc:
delay:
	ld b, 2c		// 44��
loop:
	call 02dd		// 4.5ms
	djnz loop:
	ret
