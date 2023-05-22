;***********************************************************
;SAMPLE 6_2_7_key_nmi
;***********************************************************
;モニタサブプログラムDAK1はDAK2を使用し、モニタでの用途に応じてキー値を決定します。
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
