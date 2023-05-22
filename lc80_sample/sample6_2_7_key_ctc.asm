;***********************************************************
;SAMPLE 6_2_7_key_ctc
;***********************************************************
;モニタサブプログラムDAK1はDAK2を使用し、モニタでの用途に応じてキー値を決定します。
;***********************************************************
;
CTC0	EQU	0ECH
;
DAK1	EQU	045AH
DAK2	EQU	0483H
DADP	EQU	04C3H
;
	ORG	2000H
INIT:
	IM	2
	LD	A,22H		;INT.TAB H-BYTE
	LD	I,A
	XOR	A		;INT.VEC L-BYTE
	OUT	(CTC0),A
	LD	A,0A5H		;INT.TIMER X 256
	OUT	(CTC0),A
	LD	A,0E9H		;TIME CONSTANT
	OUT	(CTC0),A
	EI
EX07:
	CALL	DAK2
	LD	A,(KEY)
	CALL	DADP
	JR	EX07
;
	ORG	2030H
KEY:
	DEFB	0
;
	ORG	2040H
INT:
	PUSH	AF
	LD	A,(KEY)
	INC	A
	LD	(KEY),A
	POP	AF
	EI
	RETI
;
	ORG	2200H		;INT.VEC
	DEFW	2040H		;INT.VEC ADDRESS
	END
