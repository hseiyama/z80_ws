;***********************************************************
;SAMPLE 6_2_4_text
;***********************************************************
;��4�F�����\��
;�L�[�u-�v�������āA�\�����������܂��B
;�L�[�u+�v�������ƁA"Hello"�Ƃ����������\������܂��B
;���j�^�[�v���O�����ł̃e�L�X�g��`���g�p����܂��B
;(�e�L�X�g��7�Z�O�����g�f�B�X�v���C�̃R�[�h�\�i�t�^�Q�Ɓj�ɏ]���č\������Ă��܂��j�B
;***********************************************************
;
DAK1	EQU	045AH
DAK2	EQU	0483H
DISP3	EQU	0583H
DISP4	EQU	0589H
;
	ORG	2000H
EX04:
	LD	IX,DISP3	;�e�L�X�g�uHALLO�v
DISPL1:
	CALL	DAK1
	CP	11H		;�L�[�u-�v
	JR	NZ,DISPL1
	LD	IX,DISP4	;��̃e�L�X�g
DISPL2:
	CALL	DAK1
	CP	10H		;�L�[�u+�v
	JR	NZ,DISPL2
	LD	IX,DISP4
	LD	C,6
INI1:
	LD	B,20H
INI2:
	CALL	DAK2
	DJNZ	INI2
	DEC	IX
	DEC	C
	JR	NZ,INI1
	JR	EX04
	END
