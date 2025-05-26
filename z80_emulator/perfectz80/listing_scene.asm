;***************************************************************
;	perfectz80_scene用 Z80アセンブラコード
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
	LD	C, PIOA
	IN	B, (C)
	LD	C, PIOB
	OUT	(C), B
	JR	LOOP

IOSET:
	LD	HL, PIOACD		;PIOAコマンドセットアップ
	LD	B, PAEND - PIOACD
	LD	C, PIOA + 1		;PIOAコマンドアドレス(1DH)
	OTIR
	LD	HL, PIOBCD		;PIOBコマンドセットアップ
	LD	B, PBEND - PIOBCD
	LD	C, PIOB + 1		;PIOBコマンドアドレス(1FH)
	OTIR
	LD	HL, CTC0CD		;CTC0コマンドセットアップ
	LD	B, C0END - CTC0CD
	LD	C, CTC0
	OTIR
;	LD	HL, CTC1CD		;CTC1コマンドセットアップ
;	LD	B, C1END - CTC1CD
;	LD	C, CTC1
;	OTIR
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
	DW	INTCT0		; 8: CTC0割り込み
	DW	0000H		;10: CTC1割り込み
	DW	0000H		;12: CTC2割り込み
	DW	0000H		;14: CTC3割り込み

;*******************************
;	ROM領域
;*******************************
PIOACD:	DB	0CFH		;PIOAモードワード			**001111 (モード3)
	DB	0FFH		;PIOAデータディレクションワード		(全ビット入力)
	DB	07H		;PIOAインタラプトコントロールワード	****0111 (割込み無効)
;	DB	00H		;PIOAインタラプトマスクワード
;	DB	ENTRY + 4	;PIOAインタラプトベクタ
PAEND	EQU	$
PIOBCD:	DB	0CFH		;PIOBモードワード			**001111 (モード3)
	DB	00H		;PIOBデータディレクションワード		(全ビット出力)
	DB	07H		;PIOBインタラプトコントロールワード	****0111 (割込み無効)
;	DB	00H		;PIOBインタラプトマスクワード
;	DB	ENTRY + 6	;PIOBインタラプトベクタ
PBEND	EQU	$

CTC0CD:
	DB	ENTRY + 8	;CTC0インタラプトベクタ			*****000 (全チャネル用)
	DB	87H		;CTC0チャンネルコントロールワード	*******1 (タイマモード)
	DB	08H		;CTC0タイムコンスタントレジスタ		(8)
C0END	EQU	$
;CTC1CD:
;	DB	05H		;CTC1チャンネルコントロールワード	*******1
;	DB	00H		;CTC1タイムコンスタントレジスタ
;C1END	EQU	$
;CTC2CD:
;	DB	05H		;CTC2チャンネルコントロールワード	*******1
;	DB	00H		;CTC2タイムコンスタントレジスタ
;C2END	EQU	$
;CTC3CD:
;	DB	05H		;CTC3チャンネルコントロールワード	*******1
;	DB	5		;CTC3タイムコンスタントレジスタ
;C3END	EQU	$

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
