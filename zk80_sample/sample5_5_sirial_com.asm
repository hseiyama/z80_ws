	org 8000
	ld c, 00		// 115200bps
	call 031e		// �{�[���[�g�ݒ�
start:
	call 0319		// ��M�o�b�t�@�[����1�����擾
	cp ff
	jr z, start:		// ��M�Ȃ�

	ld c, a			// ��M�������������̂܂ܑ��M
	call 0314		// 1�������M
	jr start:
