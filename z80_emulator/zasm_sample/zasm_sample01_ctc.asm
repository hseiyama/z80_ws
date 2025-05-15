;***************************************************************
;	zasm_sample01_ctc Z80アセンブラコード
;***************************************************************

;*******************************
;	定数定義
;*******************************
ROM_B	EQU	8000H
ENTRY	EQU	ROM_B + 40H
ENTRYL	EQU	ENTRY & 00FFH
RAM_B	EQU	ROM_B + 80H

;	パラレルポートI/Oアドレスセット
PIOA	EQU	1CH		;Ａポートデータ
PIOB	EQU	1EH		;Ｂポートデータ
;	カウンタタイマI/Oアドレスセット
CTC0	EQU	10H		;CTC0のアドレス
CTC1	EQU	11H		;CTC1のアドレス
;CTC2	EQU	12H		;CTC2のアドレス
;CTC3	EQU	13H		;CTC3のアドレス

;***************************************************************
;	メインルーチン
;***************************************************************
	ORG	ROM_B

START:
	DI
;	LD	SP, 0000H
;	IM	2
	LD	HL,ENTRY
	LD	A,H
	LD	I,A

	CALL	IOSET
	XOR	A
	LD	(CT0CNT), A
	EI
LOOP:
	IN	A, (PIOA)
	CP	0AAH
	JR	NZ, POUT
	LD	A, (CT0CNT)
POUT:
	OUT	(PIOB), A
	JR	LOOP

IOSET:
	LD	HL, CTC0CD		;CTC0コマンドセットアップ
	LD	B, C0END - CTC0CD
	LD	C, CTC0
	OTIR
	LD	HL, CTC1CD		;CTC1コマンドセットアップ
	LD	B, C1END - CTC1CD
	LD	C, CTC1
	OTIR
;	LD	HL, CTC2CD		;CTC2コマンドセットアップ
;	LD	B, C2END - CTC2CD
;	LD	C, CTC2
;	OTIR
;	LD	HL, CTC3CD		;CTC3コマンドセットアップ
;	LD	B, C3END - CTC3CD
;	LD	C, CTC3
;	OTIR
	RET

;*******************************
;	割り込みアドレス
;*******************************
	ORG	ENTRY + 04H

	DW	0000H		; 4: PIOA割り込み
	DW	0000H		; 6: PIOB割り込み
	DW	0000H		; 8: CTC0割り込み
	DW	INTCT1		;10: CTC1割り込み
	DW	0000H		;12: CTC2割り込み
	DW	0000H		;14: CTC3割り込み

;*******************************
;	ROM領域
;*******************************
CTC0CD:
	DB	ENTRYL + 8	;CTC0インタラプトベクタ			*****000 (全チャネル用)
	DB	27H		;CTC0チャンネルコントロールワード	*******1 (タイマモード)
	DB	122		;CTC0タイムコンスタントレジスタ		(128.0Hz CLK=4MHz前提)
C0END	EQU	$
CTC1CD:
	DB	0C7H		;CTC1チャンネルコントロールワード	*******1 (カウンタモード)
	DB	128		;CTC1タイムコンスタントレジスタ		(1s)
C1END	EQU	$
;CTC2CD:
;	DB	05H		;CTC2チャンネルコントロールワード	*******1
;	DB	00H		;CTC2タイムコンスタントレジスタ
;C2END	EQU	$
;CTC3CD:
;	DB	05H		;CTC3チャンネルコントロールワード	*******1
;	DB	5		;CTC3タイムコンスタントレジスタ
;C3END	EQU	$

;*******************************
;	割り込み処理
;*******************************
INTCT1:
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

	END
