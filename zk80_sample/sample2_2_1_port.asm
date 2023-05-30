// PORT3(タクトスイッチ)が押されたら、PORT4(リレーおよびLED)をONにします。

	org 8000
start:
	ld b, 03		// PORT3
	call 0305		// デジタル入力
	or a			// スイッチが押されていたら
	jr z, led_on:		// リレー(LED)をONにする

// リレー(LED)をOFFにする
	ld b, 04		// PORT4
	ld c, 00
	call 0300		// デジタル出力
	jr start:

// リレー(LED)をONにする
led_on:
	ld b, 04		// PORT4
	ld c, 01
	call 0300		// デジタル出力
	jr start:
