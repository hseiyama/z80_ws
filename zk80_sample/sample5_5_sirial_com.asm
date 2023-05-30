	org 8000
	ld c, 00		// 115200bps
	call 031e		// ボーレート設定
start:
	call 0319		// 受信バッファーから1文字取得
	cp ff
	jr z, start:		// 受信なし

	ld c, a			// 受信した文字をそのまま送信
	call 0314		// 1文字送信
	jr start:
