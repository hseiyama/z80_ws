;***********************************************************
;SAMPLE 6_2_7_key_nmi
;***********************************************************
;���j�^�T�u�v���O����DAK1��DAK2���g�p���A���j�^�ł̗p�r�ɉ����ăL�[�l�����肵�܂��B
;***********************************************************
;
DAK1	EQU	045AH
DAK2	EQU	0483H
DADP	EQU	04C3H
;
	ORG	2000H
EX07:
	CALL	DAK2
	LD	A,(KEY)
	CALL	DADP
	JR	EX07
;
	ORG	2100H
KEY:
	DEFB	0
;
	ORG	2340H
NMI:
	PUSH	AF
	LD	A,(KEY)
	INC	A
	LD	(KEY),A
	POP	AF
	RETN
	END
