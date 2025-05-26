;***************************************************************
;	perfectz80_trace用 Z80アセンブラコード
;***************************************************************

;*******************************
;	定数定義
;*******************************
ROM_B	EQU	0000H
ENTRY	EQU	0040h
RAM_B	EQU	ROM_B + 80H

;	パラレルポートI/Oアドレスセット
PIOA	EQU	1CH		;Ａポートデータ
PIOB	EQU	1EH		;Ｂポートデータ
;	カウンタタイマI/Oアドレスセット
CTC0	EQU	10H		;CTC0のアドレス
;CTC1	EQU	11H		;CTC1のアドレス
;CTC2	EQU	12H		;CTC2のアドレス
;CTC3	EQU	13H		;CTC3のアドレス

;***************************************************************
;	メインルーチン
;***************************************************************
	ORG	ROM_B

START:
	DI
	LD	SP, 0000H
	IM	2
	XOR	A
	LD	I, A
	CALL	IOSET
	XOR	A
	LD	(CT0CNT), A
	LD	(NMICNT), A
	EI
LOOP:
	IN	A, (PIOA)
	CP	0AAH
	JR	Z, BREAK
	RLCA
	LD	B, A
	LD	C, PIOB
	OUT	(C), B
	JR	LOOP
BREAK:
	NOP
	HALT
	LD	A, 55H
	OUT	(PIOA), A
	NOP
	JR	LOOP

IOSET:
	LD	HL, CTC0CD		;CTC0コマンドセットアップ
	LD	B, C0END - CTC0CD
	LD	C, CTC0
	OTIR
	RET

;*******************************
;	割り込みアドレス
;*******************************
	ORG	ENTRY + 04H

	DW	0000H		; 4: PIOA割り込み
	DW	0000H		; 6: PIOB割り込み
	DW	INTCT0		; 8: CTC0割り込み
	DW	0000H		;10: CTC1割り込み
	DW	0000H		;12: CTC2割り込み
	DW	0000H		;14: CTC3割り込み

;*******************************
;	ROM領域
;*******************************
CTC0CD:
	DB	ENTRY + 8	;CTC0インタラプトベクタ			*****000 (全チャネル用)
	DB	87H		;CTC0チャンネルコントロールワード	*******1 (タイマモード)
	DB	08H		;CTC0タイムコンスタントレジスタ		(8)
C0END	EQU	$

;*******************************
;	NMI処理
;*******************************
	ORG	0066H

NMI:
	EXX
	LD	HL, NMICNT
	INC	(HL)
	EXX
	RETN

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

;*******************************
;	RAM領域
;*******************************
	ORG	RAM_B

CT0CNT:	DS	1
NMICNT:	DS	1

	END
