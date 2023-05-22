;***********************************************************
;SAMPLE sample6_2_5_game
;***********************************************************
;��5�F�z�Q�[��
;�\���ʒu�̃Z�O�����g�����X�ɐ��䂷��B
;�L�[�u+�v�ŏz���~���A���̃L�[�i���Z�b�g�L�[�Ɗ��荞�݃L�[�������j�ŏz���p������B
;�\�ł́A���ꂪ�ŏ��Ɏ�����܂��B
;�o�C�g�͕\���ʒu (OOXX=�E�A05XX=��) ��\���A���̃o�C�g�̓Z�O�����g�̊��蓖�Ă�\���܂�
;�i�r�b�g0�Z�O�����gB�ȂǁA�L�q�ɏ]���j�B
;
;�y���l�z�A�Z���u���G���[�������BMEM�̃T�C�Y��6�iSEG�̌��j�B
;***********************************************************
;
DAK2	EQU	0483H
;
	ORG	2000H
EX05:
	LD	HL,TABLE
	LD	IX,MEM
LOOP:
	CALL	CLRDISP
	LD	E,(HL)		;�\���ʒu
	INC	E
	JR	Z,EX05
	DEC	E
	LD	D,0
	ADD	IX,DE
	INC	HL
	LD	A,(HL)		;�\���f�[�^
	LD	(IX),A
	LD	IX,MEM
	LD	B,3
LIGHT:
	CALL	DAK2
	JR	C,LIGHT1
	LD	C,A		;�L�[�l���L��
LIGHT1:
	DJNZ	LIGHT
	LD	A,C		;�L�[�l�𕜋A
	CP	0AH		;�L�[�u+�v�Ɣ�r
	JR	Z,STOP
	INC	HL
	INC	HL
STOP:
	DEC	HL
	JR	LOOP
CLRDISP:
	LD	B,6		;SEG�̌����w��
CLR:
	LD	(IX+0),00H
	INC	IX
	DJNZ	CLR
	LD	DE,0FFFAH
	ADD	IX,DE
	RET
TABLE:
	DEFW	0400H
	DEFW	0100H
	DEFW	2000H
	DEFW	8000H
	DEFW	4000H
	DEFW	0200H
	DEFB	0FFH
;
	ORG	2100H
MEM:
	DEFS	6
	END
