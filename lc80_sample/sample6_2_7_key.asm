;***********************************************************
;SAMPLE 6_2_7_key
;***********************************************************
;モニタサブプログラムDAK1はDAK2を使用し、モニタでの用途に応じてキー値を決定します。
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
