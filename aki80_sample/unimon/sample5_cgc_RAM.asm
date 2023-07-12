;******************************
;Ｚ８４Ｃ０１５専用セットアップ
;******************************
;AKI80スタートアップアセンブラ

DBUG	EQU	8000H		;Z VISION REMOTEを使用するときは8000H
				;ROMに焼くときは0000H

;	パラレルポートI/Oアドレスセット
PIOA	EQU	1CH		;Ａポートデータ
PIOB	EQU	1EH		;Ｂポートデータ

;	ＳＩＯポートI/Oアドレスセット
SIOA	EQU	18H		;chA送信/受信バッファ
SIOB	EQU	1AH		;chB送信/受信バッファ

;	カウンタタイマI/Oアドレスセット
CTC0	EQU	10H		;CTC0のアドレス
CTC1	EQU	11H		;CTC1のアドレス
CTC2	EQU	12H		;CTC2のアドレス
CTC3	EQU	13H		;CTC3のアドレス

;	Ｚ８４Ｃ０１５専用I/Oアドレスセット
WDM	EQU	0F0H	;WDTER,WDTPR,HALTMR
WDC	EQU	0F1H	;クリアー(4EH) ディセーブル(B1H)
DGC	EQU	0F4H	;デイジーチェーン設定(bit0-bit2)
WDCL	EQU	4EH	;ウォッチドッグクリアコマンドデータ
HMCR	EQU	0DBH	;ホルトモードコントロールコマンドデータ


;********************************
;	Ｉ／Ｏセットデータ
;********************************
;適宜変更のこと

	ORG	DBUG
	JP	START
PIOACD:
	DB	0CFH	;PIOAモードワード			**001111 (モード3)
	DB	0FFH	;PIOAデータディレクションワード		(全ビット入力)
	DB	97H	;PIOAインタラプトコントロールワード	****0111 (割込み有効)
	DB	0FEH	;PIOAインタラプトマスクワード
	DB	0E4H	;PIOAインタラプトベクタ
PAEND	EQU	$
PIOBCD:
	DB	0CFH	;PIOBモードワード			**001111 (モード3)
	DB	00H	;PIOBデータディレクションワード		(全ビット出力)
	DB	07H	;PIOBインタラプトコントロールワード	****0111 (割込み無効)
;	DB	00H	;PIOBインタラプトマスクワード		(未使用)
;	DB	0E6H	;PIOBインタラプトベクタ			(未使用)
PBEND	EQU	$

;SIOACD:
;	DB	18H	;SIOA WR0 チャンネルリセット
;	DB	04H	;SIOA WR0 ポインタ４
;	DB	44H	;SIOA WR4 ｸﾛｯｸ ｼﾝｸﾓｰﾄﾞ ｽﾄｯﾌﾟ ﾋﾞｯﾄ ﾊﾟﾘﾃｨ ｲﾈｰﾌﾞﾙ
;	DB	01H	;SIOA WR0 ポインタ１
;	DB	10H	;SIOA WR1 割り込み制御ウェイト／レディ		(受信ｷｬﾗｸﾀ割り込み可)
;	DB	03H	;SIOA WR0 ポインタ３
;	DB	0C1H	;SIOA WR3 受信バッファ制御情報
;	DB	05H	;SIOA WR0 ポインタ５
;	DB	68H	;SIOA WR5 送信バッファ制御情報
;SAEND	EQU	$
;SIOBCD:
;	DB	18H	;SIOB WR0 チャンネルリセット
;	DB	04H	;SIOB WR0 ポインタ４
;	DB	44H	;SIOB WR4 ｸﾛｯｸ ｼﾝｸﾓｰﾄﾞ ｽﾄｯﾌﾟ ﾋﾞｯﾄ ﾊﾟﾘﾃｨ ｲﾈｰﾌﾞﾙ
;	DB	01H	;SIOB WR0 ポインタ１
;	DB	04H	;SIOB WR1 割り込み制御ウェイト／レディ		(ｽﾃｰﾀｽ ｱﾌｪｸﾂ ﾍﾞｸﾄﾙ)
;	DB	02H	;SIOB WR0 ポインタ２
;	DB	0F0H	;SIOB WR2 インタラプトベクタ			(割り込みﾍﾞｸﾄﾙ)
;	DB	03H	;SIOB WR0 ポインタ３
;	DB	0C1H	;SIOB WR3 受信バッファ制御情報
;	DB	05H	;SIOB WR0 ポインタ５
;	DB	68H	;SIOB WR5 送信バッファ制御情報
;SBEND	EQU	$

CTC0CD:
	DB	25H	;CTC0 チャンネルコントロールワード	*******1 (タイマモード)
	DB	240	;CTC0 タイムコンスタントレジスタ	(200Hz: 5ms周期)
	DB	0E8H	;CTC0 インタラプトベクタ		*****000 (全チャネル用)
C0END	EQU	$
CTC1CD:
	DB	0C5H	;CTC1 チャンネルコントロールワード	*******1 (カウンタモード)
	DB	200	;CTC1 タイムコンスタントレジスタ	(1Hz: 1s周期)
C1END	EQU	$
CTC2CD:
	DB	05H	;CTC2 チャンネルコントロールワード	*******1
	DB	00H	;CTC2 タイムコンスタントレジスタ
C2END	EQU	$
CTC3CD:
	DB	05H	;CTC3 チャンネルコントロールワード	*******1 (タイマモード)
	DB	5	;CTC3 タイムコンスタントレジスタ	(153.6kHz)
C3END	EQU	$

WDMCD:
;	DB	0F3H	;ウォッチドッグ，ホルトモード設定	*****011 (STOPモード)
;	DB	0E3H	;ウォッチドッグ，ホルトモード設定	*****011 (IDLE1モード)
;	DB	0EBH	;ウォッチドッグ，ホルトモード設定	*****011 (IDLE2モード)
	DB	0FBH	;ウォッチドッグ，ホルトモード設定	*****011 (RUNモード)
DGCCD:
	DB	00H	;デイジーチェーン順位設定		00000*** (CTC > SIO > PIO)


;*****************************
;	ＩＮＴ処理(IM1)
;*****************************

	ORG	DBUG + 0038H
	EI
	RETI


;***********************
;	ＮＭＩ処理
;***********************

	ORG	DBUG + 0066H
	PUSH	AF
	LD	A, 55H
	OUT	(PIOB), A		;ポートBに出力
	LD	A, '2'
;	CALL	SEND			;送信要求 (Aレジスタ)
	LD	C, 02H
	RST	30H			;CONOUT
	POP	AF
;	HALT
	RETN			;ＮＭＩ禁止


;*******************************
;	Ｉ／Ｏセットアップ
;*******************************

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
	LD	HL, CTC1CD		;CTC1コマンドセットアップ
	LD	B, C1END - CTC1CD
	LD	C, CTC1
	OTIR
	LD	HL, CTC2CD		;CTC2コマンドセットアップ
	LD	B, C2END - CTC2CD
	LD	C, CTC2
	OTIR
	LD	HL, CTC3CD		;CTC3コマンドセットアップ
	LD	B, C3END - CTC3CD
	LD	C, CTC3
	OTIR
;	LD	HL, SIOACD		;SIOAコマンドセットアップ
;	LD	B, SAEND - SIOACD
;	LD	C, SIOA + 1		;SIOAコマンドアドレス(19H)
;	OTIR
;	LD	HL, SIOBCD		;SIOBコマンドセットアップ
;	LD	B, SBEND - SIOBCD
;	LD	C, SIOB + 1		;SIOBコマンドアドレス(1BH)
;	OTIR
	LD	A, HMCR			;ホルトモードコントロール
	OUT	(WDC), A
	LD	A, (WDMCD)		;ウォッチドッグ，ホルトモードセット
	OUT	(WDM), A
	LD	A, (DGCCD)		;割り込み優先順位セット
	OUT	(DGC), A
WDOG:	LD	A, WDCL			;ウォッチドッグクリア
	OUT	(WDC), A
	RET


;**************************************
;	割り込みアドレス，DWL設定
;	アドレス値をそのまま記入
;**************************************

	ORG	DBUG + 00E4H
	DW	INTPA			;PIOA割り込み
	DW	0000H			;PIOB割り込み
	DW	0000H			;CTC0割り込み
	DW	INTCT1			;CTC1割り込み
	DW	0000H			;CTC2割り込み
	DW	0000H			;CTC3割り込み
	DW	0000H			;SIOBトランスミッタバッファエンプティ
	DW	0000H			;SIOB外部／ステータス割り込み
	DW	0000H			;SIOBレシーバキャラクタアベイラブル
	DW	0000H			;SIOB特殊受信状態
	DW	0000H			;SIOAトランスミッタバッファエンプティ
	DW	0000H			;SIOA外部／ステータス割り込み
	DW	0000H			;SIOAレシーバキャラクタアベイラブル
	DW	0000H			;SIOA特殊受信状態


;************************************************************************
;	メインルーチンスタート
;************************************************************************

	ORG	DBUG + 0100H

START:	DI				;セットアップ中、割り込み不可
	IM	2			;割り込みモード２
	LD	A, DBUG / 100H		;割り込み上位ベクタロード
	LD	I, A
	LD	SP, 0000H		;スタックポインタ FFFFHから

;	LD	HL, 8000H		;外部I/O使用時のRESET待ち
;WAIT:	DEC	HL
;	LD	A, H
;	OR	L
;	JR	NZ, WAIT

	CALL	IOSET
	EI

	;ここからプログラムを書く
	XOR	A			;A=0
	LD	(FLAG), A		;FLAGを初期化
	IN	A, (PIOA)		;ポートAを入力
	LD	(VALUE), A		;VALUEを初期化
	LD	A, '0'
;	CALL	SEND			;送信要求 (Aレジスタ)
	LD	C, 02H
	RST	30H			;CONOUT
LOOP:
	LD	C, 05H
	RST	30H			;CONST
	JR	Z, LOOP1
	LD	C, 04H
	RST	30H			;CONIN
	LD	C, 02H
	RST	30H			;CONOUT
	LD	A, (VALUE)
	ADD	A, 10H			;VALUEを更新
	LD	(VALUE), A
LOOP1:
	CALL	SLEEP			;省電力モード移行判定
	CALL	WDOG			;ウォッチドッグクリア
	JR	LOOP

;CTC0割り込み (5ms周期)
;INTCT0:
;	PUSH	AF
;	LD	A, (VALUE)
;	OUT	(PIOB), A		;ポートBに出力
;	POP	AF
;	EI
;	RETI

;CTC1割り込み (1s周期)
INTCT1:
	PUSH	AF
	LD	A, (VALUE)
	INC	A			;VALUEを更新
	LD	(VALUE), A
	POP	AF
	CALL	POUT			;ポート出力
	EI
	RETI

;SIOAトランスミッタバッファエンプティ
;INTSA0:
;	PUSH	AF
;	CALL	DISATX			;送信割り込み禁止
;	LD	A, (VALUE)
;	ADD	A, 10H			;VALUEを更新
;	LD	(VALUE), A
;	POP	AF
;	EI
;	RETI

;SIOAレシーバキャラクタアベイラブル
;INTSA2:
;	PUSH	AF
;	CALL	EISATX			;送信割り込み許可
;	IN	A, (SIOA)		;受信
;	INC	A
;	CALL	SEND			;送信要求 (Aレジスタ)
;	POP	AF
;	EI
;	RETI

;SIOA特殊受信状態
;INTSA3:
;	PUSH	AF
;	LD	A, 0AAH
;	OUT	(PIOB), A		;ポートBに出力
;	POP	AF
;	EI
;	HALT				;HALT (割り込み許可)
;					;【注意】割込み処理中のHALTは復帰できない。
;					;　※タイマ割込み、NMIでは機能せず (RESETは有効)
;	RETI

;PIOA割り込み
INTPA:
	PUSH	AF
;	IN	A, (PIOA)		;ポートAを入力
;	LD	(VALUE), A		;VALUEを再設定
	LD	A, 0CCH			;
	LD	(FLAG), A		;FLAG=0xCC
	POP	AF
	EI
	RETI

;ポート出力
POUT:
	PUSH	AF
	LD	A, (VALUE)
	OUT	(PIOB), A		;ポートBに出力
	POP	AF
	RET

;送信要求 (Aレジスタ)
;SEND:
;	PUSH	AF
;SEND1:
;	IN	A, (SIOA + 1)		;RR0を読み込む
;	BIT	2, A			;送信バッファ・エンプティを確認
;	JR	Z, SEND1
;	POP	AF
;	OUT	(SIOA), A		;送信
;	RET

;送信割り込み許可
;EISATX:
;	PUSH	AF
;	LD	A, 01H			;SIOA WR0 (レジスタ1)
;	OUT	(SIOA + 1), A
;	LD	A, 12H			;SIOA WR1 (送信割り込み可)
;	OUT	(SIOA + 1), A
;	POP	AF
;	RET

;送信割り込み禁止
;DISATX:
;	PUSH	AF
;	LD	A, 01H			;SIOA WR0 (レジスタ1)
;	OUT	(SIOA + 1), A
;	LD	A, 10H			;SIOA WR1 (送信割り込み不可)
;	OUT	(SIOA + 1), A
;	POP	AF
;	RET

;省電力モード移行判定
SLEEP:
	PUSH	AF
	LD	A, (FLAG)
	CP	A, 0CCH			;FLAG==0xCC
	JR	NZ, SLEEP1
	XOR	A			;A=0
	LD	(FLAG), A		;FLAGを初期化
	LD	A, 0DBH
	OUT	(PIOB), A		;ポートBに出力
	HALT
	LD	A, '1'
;	CALL	SEND			;送信要求 (Aレジスタ)
	LD	C, 02H
	RST	30H			;CONOUT
SLEEP1:
	POP	AF
	RET


;**************************************
;	ＲＡＭ配置
;**************************************

	ORG	DBUG + 1000H

VALUE:	DEFB	00H
FLAG:	DEFB	00H

	END
