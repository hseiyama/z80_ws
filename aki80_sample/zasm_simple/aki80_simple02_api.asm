;***************************************************************
;	AKI-80ゴールドボード単体
;***************************************************************

;*******************************
;	定数定義
;*******************************
RAM_B	EQU	8000H
CR	EQU	0DH
LF	EQU	0AH
ESC	EQU	1BH
DEL	EQU	7FH

;***************************************************************
;	メインルーチン
;***************************************************************
	ORG	RAM_B

START:
	LD	C, 03H		; param1: STROUT
	LD	HL, MSG1	; param2: String address
	RST	30H		; [UniMon] STROUT
	XOR	A
	LD	(DATA1), A
LOOP:
	LD	A, (DATA1)
	INC	A
	LD	(DATA1), A
	LD	C, 05H		; param1: CONST
	RST	30H		; [UniMon] CONST
	JR	Z, LOOP
	LD	C, 04H		; param1: CONIN
	RST	30H		; [UniMon] CONIN
	CP	ESC
	JR	Z, DEBUG
	CP	DEL
	JR	Z, WSTAR
	CP	" "
	JR	Z, MSGOT
	LD	C, 02H		; param1: CONOUT
	RST	30H		; [UniMon] CONOUT
	JR	LOOP
DEBUG:
	NOP			; For DEBUG
	JR	LOOP
WSTAR:
	LD	C, 01H		; param1: WSTART
	RST	30H		; [UniMon] WSTART
MSGOT:
	LD	C, 03H		; param1: STROUT
	LD	HL, MSG2	; param2: String address
	RST	30H		; [UniMon] STROUT
	JR	LOOP

;*******************************
;	ROM領域
;*******************************
	ORG	RAM_B + 40H

MSG1:	DEFB	"Hello Assembler World !!", CR, LF, 00H
MSG2:	DEFM	"MessageString", CR, LF, 00H
ADDR1:	DEFW	$
ADDR2:	DEFW	. - 2

;*******************************
;	RAM領域
;*******************************
	ORG	RAM_B + 80H

DATA1:	DEFS	1

	END
