;***************************************************************
;	zasm_sample02_min Z80アセンブラコード
;***************************************************************

;*******************************
;	定数定義
;*******************************
ROM_B	EQU	0000H
ENTRY	EQU	ROM_B + 40H
ENTRYL	EQU	ENTRY & 00FFH
NMI_B	EQU	ROM_B + 66H
RAM_B	EQU	ROM_B + 80H

;	パラレルポートI/Oアドレスセット
PIOA	EQU	1CH		;Ａポートデータ
PIOB	EQU	1EH		;Ｂポートデータ

;***************************************************************
;	メインルーチン
;***************************************************************
	ORG	ROM_B

START:
	DI
	LD	SP, 0000H
	IM	2
	LD	HL,ENTRY
	LD	A,H
	LD	I,A

	XOR	A
	LD	(CT0CNT), A
	LD	(CT1CNT), A
	EI
LOOP:
	IN	A, (PIOA)
	INC	A
	OUT	(PIOA), A
	JR	LOOP

;*******************************
;	割り込み処理
;*******************************
INTCT0:
	PUSH	AF
	LD	A, (CT0CNT)
	INC	A
	LD	(CT0CNT), A
	POP	AF
	EI
	RETI

INTCT1:
	PUSH	AF
	LD	A, (CT1CNT)
	INC	A
	LD	(CT1CNT), A
	POP	AF
	EI
	RETI

;*******************************
;	割り込みアドレス
;*******************************
	ORG	ENTRY + 04H

	DW	0000H		; 4: PIOA割り込み
	DW	0000H		; 6: PIOB割り込み
	DW	INTCT0		; 8: CTC0割り込み
	DW	INTCT1		;10: CTC1割り込み
	DW	0000H		;12: CTC2割り込み
	DW	0000H		;14: CTC3割り込み

;*******************************
;	NMI処理
;*******************************
	ORG	NMI_B
NMI:
	PUSH	AF
	IN	A, (PIOA)
	CPL
	OUT	(PIOB), A
	POP	AF
	RETN

;*******************************
;	RAM領域
;*******************************
	ORG	RAM_B

CT0CNT:	DS	1
CT1CNT:	DS	1

	END
