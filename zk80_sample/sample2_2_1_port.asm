// PORT3(�^�N�g�X�C�b�`)�������ꂽ��APORT4(�����[�����LED)��ON�ɂ��܂��B

	org 8000
start:
	ld b, 03		// PORT3
	call 0305		// �f�W�^������
	or a			// �X�C�b�`��������Ă�����
	jr z, led_on:		// �����[(LED)��ON�ɂ���

// �����[(LED)��OFF�ɂ���
	ld b, 04		// PORT4
	ld c, 00
	call 0300		// �f�W�^���o��
	jr start:

// �����[(LED)��ON�ɂ���
led_on:
	ld b, 04		// PORT4
	ld c, 01
	call 0300		// �f�W�^���o��
	jr start:
