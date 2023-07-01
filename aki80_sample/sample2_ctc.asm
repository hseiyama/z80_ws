;******************************
;�y�W�S�b�O�P�T��p�Z�b�g�A�b�v
;******************************
;AKI80�X�^�[�g�A�b�v�A�Z���u��

DBUG	EQU	0000H		;Z VISION REMOTE���g�p����Ƃ���8000H
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


;********************************
;	�h�^�n�Z�b�g�f�[�^
;********************************
;�K�X�ύX�̂���

	ORG	DBUG
	JP	START
PIOACD:
;	DB	0E4H	;PIOA�C���^���v�g�x�N�^			(���g�p)
	DB	0CFH	;PIOA���[�h���[�h			**001111 (���[�h3)
	DB	0FFH	;PIOA�f�[�^�f�B���N�V�������[�h		(�S�r�b�g����)
	DB	07H	;PIOA�C���^���v�g�R���g���[�����[�h	****0111 (�����ݖ���)
;	DB	00H	;PIOA�C���^���v�g�}�X�N���[�h		(���g�p)
PAEND	EQU	$
PIOBCD:
;	DB	0E6H	;PIOB�C���^���v�g�x�N�^			(���g�p)
	DB	0CFH	;PIOB���[�h���[�h			**001111 (���[�h3)
	DB	00H	;PIOB�f�[�^�f�B���N�V�������[�h		(�S�r�b�g�o��)
	DB	07H	;PIOB�C���^���v�g�R���g���[�����[�h	****0111 (�����ݖ���)
;	DB	00H	;PIOB�C���^���v�g�}�X�N���[�h		(���g�p)
PBEND	EQU	$

SIOACD:	DB	18H	;SIOA WR0 �`�����l�����Z�b�g
	DB	04H	;SIOA WR0 �|�C���^�S
	DB	44H	;SIOA WR4 �ۯ� �ݸӰ�� �į�� �ޯ� ���è �Ȱ���
	DB	01H	;SIOA WR0 �|�C���^�P
	DB	00H	;SIOA WR1 ���荞�ݐ���E�F�C�g�^���f�B
	DB	03H	;SIOA WR0 �|�C���^�R
	DB	0E1H	;SIOA WR3 ��M�o�b�t�@������
	DB	05H	;SIOA WR0 �|�C���^�T
	DB	68H	;SIOA WR5 ���M�o�b�t�@������
SAEND	EQU	$
SIOBCD:	DB	18H	;SIOB WR0 �`�����l�����Z�b�g
	DB	04H	;SIOB WR0 �|�C���^�S
	DB	44H	;SIOB WR4 �ۯ� �ݸӰ�� �į�� �ޯ� ���è �Ȱ���
	DB	01H	;SIOB WR0 �|�C���^�P
	DB	00H	;SIOB WR1 ���荞�ݐ���E�F�C�g�^���f�B
	DB	02H	;SIOB WR0 �|�C���^�Q
	DB	0F0H	;SIOB WR2 �C���^���v�g�x�N�^
	DB	03H	;SIOB WR0 �|�C���^�R
	DB	0E1H	;SIOB WR3 ��M�o�b�t�@������
	DB	05H	;SIOB WR0 �|�C���^�T
	DB	68H	;SIOB WR5 ���M�o�b�t�@������
SBEND	EQU	$

CTC0CD:
;	DB	0E8H	;CTC0 �C���^���v�g�x�N�^		*****000 (�`���l��0�p)
	DB	0EAH	;CTC1 �C���^���v�g�x�N�^		*****010 (�`���l��1�p)
;	DB	0ECH	;CTC2 �C���^���v�g�x�N�^		*****100 (�`���l��2�p)
;	DB	0EEH	;CTC3 �C���^���v�g�x�N�^		*****110 (�`���l��3�p)
	DB	25H	;CTC0 �`�����l���R���g���[�����[�h	*******1 (�^�C�}���[�h)
	DB	244	;CTC0 �^�C���R���X�^���g���W�X�^	(192.1Hz)
C0END	EQU	$
CTC1CD:
	DB	0C5H	;CTC1 �`�����l���R���g���[�����[�h	*******1 (�J�E���^���[�h)
	DB	192	;CTC1 �^�C���R���X�^���g���W�X�^	(0.999s)
C1END	EQU	$
CTC2CD:
	DB	05H	;CTC2 �`�����l���R���g���[�����[�h	*******1
	DB	00H	;CTC2 �^�C���R���X�^���g���W�X�^
C2END	EQU	$
CTC3CD:
	DB	05H	;CTC3 �`�����l���R���g���[�����[�h	*******1
	DB	00H	;CTC3 �^�C���R���X�^���g���W�X�^
C3END	EQU	$

WDMCD:	DB	0FBH	;�E�H�b�`�h�b�O�C�z���g���[�h�ݒ�	*****011
DGCCD:	DB	00H	;�f�C�W�[�`�F�[�����ʐݒ�		00000***


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
	HALT
	RETN			;�m�l�h�֎~


;*******************************
;	�h�^�n�Z�b�g�A�b�v
;*******************************

IOSET:	LD	HL, PIOACD		;PIOA�R�}���h�Z�b�g�A�b�v
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
	LD	HL, SIOACD		;SIOA�R�}���h�Z�b�g�A�b�v
	LD	B, SAEND - SIOACD
	LD	C, SIOA + 1		;SIOA�R�}���h�A�h���X(19H)
	OTIR
	LD	HL, SIOBCD		;SIOB�R�}���h�Z�b�g�A�b�v
	LD	B, SBEND - SIOBCD
	LD	C, SIOB + 1		;SIOB�R�}���h�A�h���X(1BH)
	OTIR
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
	DW	0000H			;PIOA���荞��
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
	IN	A, (PIOA)
	LD	(VALUE), A
LOOP:
	LD	A, (VALUE)
	OUT	(PIOB), A
	JR	LOOP

INTCT1:
	PUSH	AF
	LD	A, (VALUE)
	INC	A
	LD	(VALUE), A
	POP	AF
	EI
	RETI

;**************************************
;	�q�`�l�z�u
;**************************************

	ORG	8000H

VALUE:	DEFB	00H

	END
