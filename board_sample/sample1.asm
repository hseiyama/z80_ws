;***********************************************************
;SAMPLE 1
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
	LD	A,03h
	OUT	(PIOAC),A	;- 割り込み制御語(割込み無効)
;
	LD	A,0Fh		;PORTBの設定
	OUT	(PIOBC),A	;- モード設定(出力モード)
	LD	A,03h
	OUT	(PIOBC),A	;- 割り込み制御語(割込み無効)
LOOP:
	IN	A,(PIOAD)	;PORTAから入力
	OUT	(PIOBD),A	;PORTBに出力
	JP	LOOP
	END
;
;***********************************************************
;■動作メモ
; 1.<ASTB>SW押下後に、PORTAの入力値がPORTBの出力に反映。
; 2.<ASTB>SW押下時は、常にPORTAの入力値がPORTBの出力に反映。
; 3.<WAIT>SW押下時に、<ASTB>SW押下すると<ARDY>LEDが点灯->消灯。
;   <WAIT>SW押下時に、<BSTB>SW押下すると<BRDY>LEDが点灯->消灯。
;   その後、<WAIT>SW離すと、<ARDY>LEDと<BRDY>LEDが点灯。
;■結論(PIOの動作)
; 1.<IN>命令により、<ARDY>LEDが点灯し、<ASTB>SW押下されるまで
;   入力値は前回値を維持する。
;   <ASTB>SW押下されると、そのタイミングで入力値を更新する。
;***********************************************************
