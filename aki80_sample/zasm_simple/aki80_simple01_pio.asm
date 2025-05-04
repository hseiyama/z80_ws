;***************************************************************
;	AKI-80ゴールドボード
;	+ブレッドボード(SW+LED)
;***************************************************************

;*******************************
;	定数定義
;*******************************
RAM_B	EQU	8000H
CR	EQU	0DH
LF	EQU	0AH

;***************************************************************
;	メインルーチン
;***************************************************************
	ORG	RAM_B

START:
	XOR	A		; A = 0
	LD	(CNT_DT), A
LOOP:
	IN	A, (1CH)	; A <- IO only
	CP	0AAH		; A only
	JR	NZ, IO_OUT
	HALT
	NOP			; for Debug
	CALL	MSG_OT
IO_OUT:
	OUT	(1EH), A	; IO <- A only
	LD	A, (CNT_DT)	; A <- MEM only
	INC	A
	LD	(CNT_DT), A	; MEM <- A only
	JR	LOOP

MSG_OT:
	PUSH	AF
	LD	HL, MSG_ST
	LD	C, 03H
	RST	30H		; [UniMon] STROUT
	POP	AF
	RET

;*******************************
;	ROM領域
;*******************************
	ORG	RAM_B + 40H

MSG_ST:	DEFB	"Halt executed!!", CR, LF, 00H

;*******************************
;	RAM領域
;*******************************
	ORG	RAM_B + 80H

CNT_DT:	DEFS	1

	END
