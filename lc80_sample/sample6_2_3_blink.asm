;***********************************************************
;SAMPLE 6_2_3_blink
;***********************************************************
;��3�F�_�Ń��C�g�̐���
;OUT LED��HIGH�܂���LOW�M���Ő��䂵�āA����LED���_�ł���悤�ɂ��邱�Ƃł��B
;***********************************************************
;
DIGITAP	EQU	0F5H		;B2...B7=DIGITANST. AND �L�[�}�g���b�N�X
				;B0=�e�[�v�C��, B1=�e�[�v�A�E�g
;
	ORG	2000H
EX03:
	LD	A,0FFH
	OUT	(DIGITAP),A
	LD	B,50H
LOOP1:
	CALL	DELAY
	DJNZ	LOOP1
	LD	A,0FDH
	OUT	(DIGITAP),A
	LD	B,50H
LOOP2:
	CALL	DELAY
	DJNZ	LOOP2
	JR	EX03
DELAY:
	LD	C,0FFH
LOOP3:
	DEC	C
	JR	NZ,LOOP3
	RET
	END
