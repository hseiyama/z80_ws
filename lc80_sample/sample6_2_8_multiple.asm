;***********************************************************
;SAMPLE 6_2_8_multiple
;***********************************************************
;��7�F��Z
;2��8�r�b�g16�i���̏�Z
;�����̓������ʒu2100H��2101H�ɂ���A
;���ʂ̓������Z��2102H�i���ʃo�C�g�j��2103H�i��ʃo�C�g�j�Ɋi�[����܂��B
;***********************************************************
;
	ORG	2000H
EX08:
	LD	HL,2100H
	LD	C,(HL)
	INC	HL
	LD	D,(HL)
	CALL	MULT
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
	HALT
				;8�r�b�g��Z�� 16�r�b�g�̌��� C x D = BC
MULT:
	SUB	A		;���W�X�^A�폜
	LD	B,8		;8�r�b�g
MULT1:
	RR	C		;��Z��̃V�t�g
	JR	NC,MULT2	;CY = 0 �Ȃ���Z�Ȃ�
	ADD	A,D		;���Z�ɂ�錋��
MULT2:
	RR	A		;CY �̏�ʃr�b�g�Ɖ��ʌ��ʃr�b�g���L���b�`
	DJNZ	MULT1
	RR	C		;REG.C �̍Ō�̌��ʃr�b�g
	LD	B,A		;REG.B �̍��l�o�C�g
	RET
;
	ORG	2100H
	DEFW	1F20H		;����
	DEFW	0000H		;����
	END
