;***********************************************************
;SAMPLE 2
;***********************************************************
;
PIOAD	EQU	00h
PIOAC	EQU	01h
PIOBD	EQU	02h
PIOBC	EQU	03h
;
	ORG	0000h
START:
	LD	SP,0100h	;スタックポインタの設定
;
	LD	A,4Fh		;PORTAの設定
	OUT	(PIOAC),A	;- モード設定(入力モード)
	LD	A,83h
	OUT	(PIOAC),A	;- 割り込み制御語(割込み有効)
;
	LD	A,0Fh		;PORTBの設定
	OUT	(PIOBC),A	;- モード設定(出力モード)
	LD	A,03h
	OUT	(PIOBC),A	;- 割り込み制御語(割込み無効)
;
	IM	1		;割込みモードの設定(モード1)
	EI			;割込み許可
LOOP:
	NOP
	JP	LOOP
;
	ORG	0038h
INT:
	IN	A,(PIOAD)	;PORTAから入力
	OUT	(PIOBD),A	;PORTBに出力
	EI			;割込み許可
	RETI
;
	ORG	0066h
NMI:
	HALT			;動作の停止
	END
;
;***********************************************************
;■動作メモ
; 1.<RESET>SW押下->離した後に、<ARDY>LEDが点灯。
; 2.<ASTB>SW押下->離した後に、PORTAの入力値がPORTBの出力に反映。
;   その際、<BRDY>LEDが消灯していれば消灯->点灯。
; 3.<BSTB>SW押下->離した後に、<BRDY>LEDが点灯->消灯。
; 4.<WAIT>SW押下時に、<ASTB>SW押下すると<ARDY>LEDが点灯->消灯。
;   その後、<WAIT>SW離すと、<ARDY>LEDと<BRDY>LEDが点灯。
; 5.<WAIT>SW押下時に、<BSTB>SW押下すると<BRDY>LEDが点灯->消灯。
;   その後、<WAIT>SW離しても変化なし。
;■結論(PIOの動作)
; 1.リセット後、PORTAの設定で<ARDY>LEDが点灯し割込み可能となる。
; 2.<ASTB>SW押下->離した後に、入力値を更新し割込みが発生する。
;***********************************************************
