;***************************************************************
;	perfectz80_scene�p Z80�A�Z���u���R�[�h
;***************************************************************

;*******************************
;	�萔��`
;*******************************
ROM_B	EQU	0000H
ENTRY	EQU	0040h
RAM_B	EQU	ROM_B + 80H

;	�p�������|�[�gI/O�A�h���X�Z�b�g
PIOA	EQU	1CH		;�`�|�[�g�f�[�^
PIOB	EQU	1EH		;�a�|�[�g�f�[�^
;	�J�E���^�^�C�}I/O�A�h���X�Z�b�g
CTC0	EQU	10H		;CTC0�̃A�h���X
;CTC1	EQU	11H		;CTC1�̃A�h���X
;CTC2	EQU	12H		;CTC2�̃A�h���X
;CTC3	EQU	13H		;CTC3�̃A�h���X

;***************************************************************
;	���C�����[�`��
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
	LD	HL, PIOACD		;PIOA�R�}���h�Z�b�g�A�b�v
	LD	B, PAEND - PIOACD
	LD	C, PIOA + 1		;PIOA�R�}���h�A�h���X(1DH)
	OTIR
	LD	HL, PIOBCD		;PIOB�R�}���h�Z�b�g�A�b�v
	LD	B, PBEND - PIOBCD
	LD	C, PIOB + 1		;PIOB�R�}���h�A�h���X(1FH)
	OTIR
	LD	HL, CTC0CD		;CTC0�R�}���h�Z�b�g�A�b�v
	LD	B, C0END - CTC0CD
	LD	C, CTC0
	OTIR
;	LD	HL, CTC1CD		;CTC1�R�}���h�Z�b�g�A�b�v
;	LD	B, C1END - CTC1CD
;	LD	C, CTC1
;	OTIR
;	LD	HL, CTC2CD		;CTC2�R�}���h�Z�b�g�A�b�v
;	LD	B, C2END - CTC2CD
;	LD	C, CTC2
;	OTIR
;	LD	HL, CTC3CD		;CTC3�R�}���h�Z�b�g�A�b�v
;	LD	B, C3END - CTC3CD
;	LD	C, CTC3
;	OTIR
	RET

;*******************************
;	���荞�݃A�h���X
;*******************************
	ORG	ENTRY + 04H

	DW	0000H		; 4: PIOA���荞��
	DW	0000H		; 6: PIOB���荞��
	DW	INTCT0		; 8: CTC0���荞��
	DW	0000H		;10: CTC1���荞��
	DW	0000H		;12: CTC2���荞��
	DW	0000H		;14: CTC3���荞��

;*******************************
;	ROM�̈�
;*******************************
PIOACD:	DB	0CFH		;PIOA���[�h���[�h			**001111 (���[�h3)
	DB	0FFH		;PIOA�f�[�^�f�B���N�V�������[�h		(�S�r�b�g����)
	DB	07H		;PIOA�C���^���v�g�R���g���[�����[�h	****0111 (�����ݖ���)
;	DB	00H		;PIOA�C���^���v�g�}�X�N���[�h
;	DB	ENTRY + 4	;PIOA�C���^���v�g�x�N�^
PAEND	EQU	$
PIOBCD:	DB	0CFH		;PIOB���[�h���[�h			**001111 (���[�h3)
	DB	00H		;PIOB�f�[�^�f�B���N�V�������[�h		(�S�r�b�g�o��)
	DB	07H		;PIOB�C���^���v�g�R���g���[�����[�h	****0111 (�����ݖ���)
;	DB	00H		;PIOB�C���^���v�g�}�X�N���[�h
;	DB	ENTRY + 6	;PIOB�C���^���v�g�x�N�^
PBEND	EQU	$

CTC0CD:
	DB	ENTRY + 8	;CTC0�C���^���v�g�x�N�^			*****000 (�S�`���l���p)
	DB	87H		;CTC0�`�����l���R���g���[�����[�h	*******1 (�^�C�}���[�h)
	DB	08H		;CTC0�^�C���R���X�^���g���W�X�^		(8)
C0END	EQU	$
;CTC1CD:
;	DB	05H		;CTC1�`�����l���R���g���[�����[�h	*******1
;	DB	00H		;CTC1�^�C���R���X�^���g���W�X�^
;C1END	EQU	$
;CTC2CD:
;	DB	05H		;CTC2�`�����l���R���g���[�����[�h	*******1
;	DB	00H		;CTC2�^�C���R���X�^���g���W�X�^
;C2END	EQU	$
;CTC3CD:
;	DB	05H		;CTC3�`�����l���R���g���[�����[�h	*******1
;	DB	5		;CTC3�^�C���R���X�^���g���W�X�^
;C3END	EQU	$

;*******************************
;	NMI����
;*******************************
	ORG	0066H

NMI:
	EXX
	LD	HL, NMICNT
	INC	(HL)
	EXX
	RETN

;*******************************
;	���荞�ݏ���
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
;	RAM�̈�
;*******************************
	ORG	RAM_B

CT0CNT:	DS	1
NMICNT:	DS	1

	END
