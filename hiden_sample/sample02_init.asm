	ORG	0000H

	PUSH	AF
	PUSH	AF
	XOR	A			;���Z���ʂ���Ƀ[���ɂȂ�
					;�uLD A,0�v�̑�p�i�t���O�ω��Ȃ��j
	POP	AF
	OR	A			;�L�����[�t���O�̃��Z�b�g�p
					;�uCP 0�v�̑�p
	POP	AF
	AND	A			;�uOR A�v�Ɠ����ړI�Ŏg�p
	HALT

	END
