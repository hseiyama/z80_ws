// PORT1(���Œ��R)����AD�ϊ������l��ǂ�ŁA
// PORT2(���d�X�s�[�J�[)�փp���X���ϒ���ݒ肵�܂��B

	org 8000
start:
	ld b, 01		// PORT1
	call 030F		// AD�ϊ�
	call delay:		// ��200ms
	ld b, 02		// PORT2
	ld de, 01f4		// �f���[�e�B�� 50%
	call 030a		// �擾�����l(HL = 0�`1023)�Ŏ��g���ݒ�
	jr start:
delay:
	ld b, 2c		// 44��
loop:
	call 02dd		// 4.5ms
	djnz loop:
	ret
