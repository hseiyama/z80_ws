;***********************************************************
;SAMPLE 6_2_7_key
;***********************************************************
;���j�^�T�u�v���O����DAK1��DAK2���g�p���A���j�^�ł̗p�r�ɉ����ăL�[�l�����肵�܂��B
;***********************************************************
;
DAK1	EQU	045AH
DADP	EQU	04C3H
;
	ORG	2000H
EX07:
	CALL	DAK1
	CALL	DADP
	JR	EX07
	END