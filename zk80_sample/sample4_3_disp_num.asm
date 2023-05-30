	org 8000
	ld hl, 1234
	ld de, abcd
	ld (83ee), hl		// アドレスレジスター
	ex de, hl
	ld (83ec), hl		// データレジスター
	call 01a1
	halt
