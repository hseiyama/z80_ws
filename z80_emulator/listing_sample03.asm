;***************************************************************
;	z80_sample03�p Z80�A�Z���u���R�[�h
;***************************************************************

;*******************************
;	�萔��`
;*******************************
ROM_B	EQU	0000H
RAM_B	EQU	ROM_B + 40H

;	�p�������|�[�gI/O�A�h���X�Z�b�g
PIOA	EQU	1CH		;�`�|�[�g�f�[�^
PIOB	EQU	1EH		;�a�|�[�g�f�[�^

;***************************************************************
;	���C�����[�`��
;***************************************************************
	ORG	ROM_B

START:
	DI
	LD	SP, 0000H
	CALL	IOSET
LOOP:
	IN	A, (PIOA)
	OUT	(PIOB), A
	LD	(PIO_WS), A
	JR	LOOP

IOSET:
	LD	HL, PIOACD		;PIOA�R�}���h�Z�b�g�A�b�v
	LD	B, PAEND - PIOACD
	LD	C, PIOA + 1		;PIOA�R�}���h�A�h���X(1DH)
	OTIR
	LD	HL, PIOBCD		;PIOB�R�}���h�Z�b�g�A�b�v
	LD	B, PBEND - PIOBCD
	LD	C, PIOB + 1		;PIOB�R�}���h�A�h���X(1FH)
	OTIR
	RET

;*******************************
;	ROM�̈�
;*******************************
	ORG	ROM_B + 30H

PIOACD:	DB	0CFH		;PIOA���[�h���[�h			**001111 (���[�h3)
	DB	0FFH		;PIOA�f�[�^�f�B���N�V�������[�h		(�S�r�b�g����)
	DB	07H		;PIOA�C���^���v�g�R���g���[�����[�h	****0111 (�����ݖ���)
;	DB	00H		;PIOA�C���^���v�g�}�X�N���[�h
;	DB	ENTRY+16	;PIOA�C���^���v�g�x�N�^
PAEND	EQU	$
PIOBCD:	DB	0CFH		;PIOB���[�h���[�h			**001111 (���[�h3)
	DB	00H		;PIOB�f�[�^�f�B���N�V�������[�h		(�S�r�b�g�o��)
	DB	07H		;PIOB�C���^���v�g�R���g���[�����[�h	****0111 (�����ݖ���)
;	DB	00H		;PIOB�C���^���v�g�}�X�N���[�h
;	DB	ENTRY+18	;PIOB�C���^���v�g�x�N�^
PBEND	EQU	$

;*******************************
;	RAM�̈�
;*******************************
	ORG	RAM_B

PIO_WS:	DEFS	1

	END
