	org 8000
	ld hl, 1234
	ld de, abcd
	ld (83ee), hl		// �A�h���X���W�X�^�[
	ex de, hl
	ld (83ec), hl		// �f�[�^���W�X�^�[
	call 01a1
	halt
