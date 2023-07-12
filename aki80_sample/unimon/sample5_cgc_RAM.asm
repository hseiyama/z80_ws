;******************************
;�y�W�S�b�O�P�T��p�Z�b�g�A�b�v
;******************************
;AKI80�X�^�[�g�A�b�v�A�Z���u��

DBUG	EQU	8000H		;Z VISION REMOTE���g�p����Ƃ���8000H
				;ROM�ɏĂ��Ƃ���0000H

;	�p�������|�[�gI/O�A�h���X�Z�b�g
PIOA	EQU	1CH		;�`�|�[�g�f�[�^
PIOB	EQU	1EH		;�a�|�[�g�f�[�^

;	�r�h�n�|�[�gI/O�A�h���X�Z�b�g
SIOA	EQU	18H		;chA���M/��M�o�b�t�@
SIOB	EQU	1AH		;chB���M/��M�o�b�t�@

;	�J�E���^�^�C�}I/O�A�h���X�Z�b�g
CTC0	EQU	10H		;CTC0�̃A�h���X
CTC1	EQU	11H		;CTC1�̃A�h���X
CTC2	EQU	12H		;CTC2�̃A�h���X
CTC3	EQU	13H		;CTC3�̃A�h���X

;	�y�W�S�b�O�P�T��pI/O�A�h���X�Z�b�g
WDM	EQU	0F0H	;WDTER,WDTPR,HALTMR
WDC	EQU	0F1H	;�N���A�[(4EH) �f�B�Z�[�u��(B1H)
DGC	EQU	0F4H	;�f�C�W�[�`�F�[���ݒ�(bit0-bit2)
WDCL	EQU	4EH	;�E�H�b�`�h�b�O�N���A�R�}���h�f�[�^
HMCR	EQU	0DBH	;�z���g���[�h�R���g���[���R�}���h�f�[�^


;********************************
;	�h�^�n�Z�b�g�f�[�^
;********************************
;�K�X�ύX�̂���

	ORG	DBUG
	JP	START
PIOACD:
	DB	0CFH	;PIOA���[�h���[�h			**001111 (���[�h3)
	DB	0FFH	;PIOA�f�[�^�f�B���N�V�������[�h		(�S�r�b�g����)
	DB	97H	;PIOA�C���^���v�g�R���g���[�����[�h	****0111 (�����ݗL��)
	DB	0FEH	;PIOA�C���^���v�g�}�X�N���[�h
	DB	0E4H	;PIOA�C���^���v�g�x�N�^
PAEND	EQU	$
PIOBCD:
	DB	0CFH	;PIOB���[�h���[�h			**001111 (���[�h3)
	DB	00H	;PIOB�f�[�^�f�B���N�V�������[�h		(�S�r�b�g�o��)
	DB	07H	;PIOB�C���^���v�g�R���g���[�����[�h	****0111 (�����ݖ���)
;	DB	00H	;PIOB�C���^���v�g�}�X�N���[�h		(���g�p)
;	DB	0E6H	;PIOB�C���^���v�g�x�N�^			(���g�p)
PBEND	EQU	$

;SIOACD:
;	DB	18H	;SIOA WR0 �`�����l�����Z�b�g
;	DB	04H	;SIOA WR0 �|�C���^�S
;	DB	44H	;SIOA WR4 �ۯ� �ݸӰ�� �į�� �ޯ� ���è �Ȱ���
;	DB	01H	;SIOA WR0 �|�C���^�P
;	DB	10H	;SIOA WR1 ���荞�ݐ���E�F�C�g�^���f�B		(��M��׸����荞�݉�)
;	DB	03H	;SIOA WR0 �|�C���^�R
;	DB	0C1H	;SIOA WR3 ��M�o�b�t�@������
;	DB	05H	;SIOA WR0 �|�C���^�T
;	DB	68H	;SIOA WR5 ���M�o�b�t�@������
;SAEND	EQU	$
;SIOBCD:
;	DB	18H	;SIOB WR0 �`�����l�����Z�b�g
;	DB	04H	;SIOB WR0 �|�C���^�S
;	DB	44H	;SIOB WR4 �ۯ� �ݸӰ�� �į�� �ޯ� ���è �Ȱ���
;	DB	01H	;SIOB WR0 �|�C���^�P
;	DB	04H	;SIOB WR1 ���荞�ݐ���E�F�C�g�^���f�B		(�ð�� �̪�� �޸��)
;	DB	02H	;SIOB WR0 �|�C���^�Q
;	DB	0F0H	;SIOB WR2 �C���^���v�g�x�N�^			(���荞���޸��)
;	DB	03H	;SIOB WR0 �|�C���^�R
;	DB	0C1H	;SIOB WR3 ��M�o�b�t�@������
;	DB	05H	;SIOB WR0 �|�C���^�T
;	DB	68H	;SIOB WR5 ���M�o�b�t�@������
;SBEND	EQU	$

CTC0CD:
	DB	25H	;CTC0 �`�����l���R���g���[�����[�h	*******1 (�^�C�}���[�h)
	DB	240	;CTC0 �^�C���R���X�^���g���W�X�^	(200Hz: 5ms����)
	DB	0E8H	;CTC0 �C���^���v�g�x�N�^		*****000 (�S�`���l���p)
C0END	EQU	$
CTC1CD:
	DB	0C5H	;CTC1 �`�����l���R���g���[�����[�h	*******1 (�J�E���^���[�h)
	DB	200	;CTC1 �^�C���R���X�^���g���W�X�^	(1Hz: 1s����)
C1END	EQU	$
CTC2CD:
	DB	05H	;CTC2 �`�����l���R���g���[�����[�h	*******1
	DB	00H	;CTC2 �^�C���R���X�^���g���W�X�^
C2END	EQU	$
CTC3CD:
	DB	05H	;CTC3 �`�����l���R���g���[�����[�h	*******1 (�^�C�}���[�h)
	DB	5	;CTC3 �^�C���R���X�^���g���W�X�^	(153.6kHz)
C3END	EQU	$

WDMCD:
;	DB	0F3H	;�E�H�b�`�h�b�O�C�z���g���[�h�ݒ�	*****011 (STOP���[�h)
;	DB	0E3H	;�E�H�b�`�h�b�O�C�z���g���[�h�ݒ�	*****011 (IDLE1���[�h)
;	DB	0EBH	;�E�H�b�`�h�b�O�C�z���g���[�h�ݒ�	*****011 (IDLE2���[�h)
	DB	0FBH	;�E�H�b�`�h�b�O�C�z���g���[�h�ݒ�	*****011 (RUN���[�h)
DGCCD:
	DB	00H	;�f�C�W�[�`�F�[�����ʐݒ�		00000*** (CTC > SIO > PIO)


;*****************************
;	�h�m�s����(IM1)
;*****************************

	ORG	DBUG + 0038H
	EI
	RETI


;***********************
;	�m�l�h����
;***********************

	ORG	DBUG + 0066H
	PUSH	AF
	LD	A, 55H
	OUT	(PIOB), A		;�|�[�gB�ɏo��
	LD	A, '2'
;	CALL	SEND			;���M�v�� (A���W�X�^)
	LD	C, 02H
	RST	30H			;CONOUT
	POP	AF
;	HALT
	RETN			;�m�l�h�֎~


;*******************************
;	�h�^�n�Z�b�g�A�b�v
;*******************************

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
	LD	HL, CTC1CD		;CTC1�R�}���h�Z�b�g�A�b�v
	LD	B, C1END - CTC1CD
	LD	C, CTC1
	OTIR
	LD	HL, CTC2CD		;CTC2�R�}���h�Z�b�g�A�b�v
	LD	B, C2END - CTC2CD
	LD	C, CTC2
	OTIR
	LD	HL, CTC3CD		;CTC3�R�}���h�Z�b�g�A�b�v
	LD	B, C3END - CTC3CD
	LD	C, CTC3
	OTIR
;	LD	HL, SIOACD		;SIOA�R�}���h�Z�b�g�A�b�v
;	LD	B, SAEND - SIOACD
;	LD	C, SIOA + 1		;SIOA�R�}���h�A�h���X(19H)
;	OTIR
;	LD	HL, SIOBCD		;SIOB�R�}���h�Z�b�g�A�b�v
;	LD	B, SBEND - SIOBCD
;	LD	C, SIOB + 1		;SIOB�R�}���h�A�h���X(1BH)
;	OTIR
	LD	A, HMCR			;�z���g���[�h�R���g���[��
	OUT	(WDC), A
	LD	A, (WDMCD)		;�E�H�b�`�h�b�O�C�z���g���[�h�Z�b�g
	OUT	(WDM), A
	LD	A, (DGCCD)		;���荞�ݗD�揇�ʃZ�b�g
	OUT	(DGC), A
WDOG:	LD	A, WDCL			;�E�H�b�`�h�b�O�N���A
	OUT	(WDC), A
	RET


;**************************************
;	���荞�݃A�h���X�CDWL�ݒ�
;	�A�h���X�l�����̂܂܋L��
;**************************************

	ORG	DBUG + 00E4H
	DW	INTPA			;PIOA���荞��
	DW	0000H			;PIOB���荞��
	DW	0000H			;CTC0���荞��
	DW	INTCT1			;CTC1���荞��
	DW	0000H			;CTC2���荞��
	DW	0000H			;CTC3���荞��
	DW	0000H			;SIOB�g�����X�~�b�^�o�b�t�@�G���v�e�B
	DW	0000H			;SIOB�O���^�X�e�[�^�X���荞��
	DW	0000H			;SIOB���V�[�o�L�����N�^�A�x�C���u��
	DW	0000H			;SIOB�����M���
	DW	0000H			;SIOA�g�����X�~�b�^�o�b�t�@�G���v�e�B
	DW	0000H			;SIOA�O���^�X�e�[�^�X���荞��
	DW	0000H			;SIOA���V�[�o�L�����N�^�A�x�C���u��
	DW	0000H			;SIOA�����M���


;************************************************************************
;	���C�����[�`���X�^�[�g
;************************************************************************

	ORG	DBUG + 0100H

START:	DI				;�Z�b�g�A�b�v���A���荞�ݕs��
	IM	2			;���荞�݃��[�h�Q
	LD	A, DBUG / 100H		;���荞�ݏ�ʃx�N�^���[�h
	LD	I, A
	LD	SP, 0000H		;�X�^�b�N�|�C���^ FFFFH����

;	LD	HL, 8000H		;�O��I/O�g�p����RESET�҂�
;WAIT:	DEC	HL
;	LD	A, H
;	OR	L
;	JR	NZ, WAIT

	CALL	IOSET
	EI

	;��������v���O����������
	XOR	A			;A=0
	LD	(FLAG), A		;FLAG��������
	IN	A, (PIOA)		;�|�[�gA�����
	LD	(VALUE), A		;VALUE��������
	LD	A, '0'
;	CALL	SEND			;���M�v�� (A���W�X�^)
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
	ADD	A, 10H			;VALUE���X�V
	LD	(VALUE), A
LOOP1:
	CALL	SLEEP			;�ȓd�̓��[�h�ڍs����
	CALL	WDOG			;�E�H�b�`�h�b�O�N���A
	JR	LOOP

;CTC0���荞�� (5ms����)
;INTCT0:
;	PUSH	AF
;	LD	A, (VALUE)
;	OUT	(PIOB), A		;�|�[�gB�ɏo��
;	POP	AF
;	EI
;	RETI

;CTC1���荞�� (1s����)
INTCT1:
	PUSH	AF
	LD	A, (VALUE)
	INC	A			;VALUE���X�V
	LD	(VALUE), A
	POP	AF
	CALL	POUT			;�|�[�g�o��
	EI
	RETI

;SIOA�g�����X�~�b�^�o�b�t�@�G���v�e�B
;INTSA0:
;	PUSH	AF
;	CALL	DISATX			;���M���荞�݋֎~
;	LD	A, (VALUE)
;	ADD	A, 10H			;VALUE���X�V
;	LD	(VALUE), A
;	POP	AF
;	EI
;	RETI

;SIOA���V�[�o�L�����N�^�A�x�C���u��
;INTSA2:
;	PUSH	AF
;	CALL	EISATX			;���M���荞�݋���
;	IN	A, (SIOA)		;��M
;	INC	A
;	CALL	SEND			;���M�v�� (A���W�X�^)
;	POP	AF
;	EI
;	RETI

;SIOA�����M���
;INTSA3:
;	PUSH	AF
;	LD	A, 0AAH
;	OUT	(PIOB), A		;�|�[�gB�ɏo��
;	POP	AF
;	EI
;	HALT				;HALT (���荞�݋���)
;					;�y���Ӂz�����ݏ�������HALT�͕��A�ł��Ȃ��B
;					;�@���^�C�}�����݁ANMI�ł͋@�\���� (RESET�͗L��)
;	RETI

;PIOA���荞��
INTPA:
	PUSH	AF
;	IN	A, (PIOA)		;�|�[�gA�����
;	LD	(VALUE), A		;VALUE���Đݒ�
	LD	A, 0CCH			;
	LD	(FLAG), A		;FLAG=0xCC
	POP	AF
	EI
	RETI

;�|�[�g�o��
POUT:
	PUSH	AF
	LD	A, (VALUE)
	OUT	(PIOB), A		;�|�[�gB�ɏo��
	POP	AF
	RET

;���M�v�� (A���W�X�^)
;SEND:
;	PUSH	AF
;SEND1:
;	IN	A, (SIOA + 1)		;RR0��ǂݍ���
;	BIT	2, A			;���M�o�b�t�@�E�G���v�e�B���m�F
;	JR	Z, SEND1
;	POP	AF
;	OUT	(SIOA), A		;���M
;	RET

;���M���荞�݋���
;EISATX:
;	PUSH	AF
;	LD	A, 01H			;SIOA WR0 (���W�X�^1)
;	OUT	(SIOA + 1), A
;	LD	A, 12H			;SIOA WR1 (���M���荞�݉�)
;	OUT	(SIOA + 1), A
;	POP	AF
;	RET

;���M���荞�݋֎~
;DISATX:
;	PUSH	AF
;	LD	A, 01H			;SIOA WR0 (���W�X�^1)
;	OUT	(SIOA + 1), A
;	LD	A, 10H			;SIOA WR1 (���M���荞�ݕs��)
;	OUT	(SIOA + 1), A
;	POP	AF
;	RET

;�ȓd�̓��[�h�ڍs����
SLEEP:
	PUSH	AF
	LD	A, (FLAG)
	CP	A, 0CCH			;FLAG==0xCC
	JR	NZ, SLEEP1
	XOR	A			;A=0
	LD	(FLAG), A		;FLAG��������
	LD	A, 0DBH
	OUT	(PIOB), A		;�|�[�gB�ɏo��
	HALT
	LD	A, '1'
;	CALL	SEND			;���M�v�� (A���W�X�^)
	LD	C, 02H
	RST	30H			;CONOUT
SLEEP1:
	POP	AF
	RET


;**************************************
;	�q�`�l�z�u
;**************************************

	ORG	DBUG + 1000H

VALUE:	DEFB	00H
FLAG:	DEFB	00H

	END
