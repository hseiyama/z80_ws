;***********************************************************
;SAMPLE 6_2_2_DAK2
;***********************************************************
;��2�F�uHELPUS�v�f�B�X�v���C�̓_��
;�v���O����DAK2�́A��10ms�̊ԁA�f�B�X�v���C�𐧌䂵�܂��B
;�e�L�X�g'HELPUS'��0.5�b���Ƃ�0.5�b�_�ł�����B
;
;�\�����Ԃ�ύX����ɂ́A���������P�[�V����200BH�̒l��ύX����K�v������A
;���̒l��DAK2���Ăяo�����߂̃��[�v�����w�肷�邽�߁A���Ԃ����肳���B
;�\���e�L�X�g�́A���������P�[�V����2026H�`202BH�ŕύX���邱�Ƃ��ł��܂��B
;***********************************************************
;
DAK1	EQU	045AH
DAK2	EQU	0483H
;
	ORG	2000H
EX2:
	LD	HL,BLANK	;�u�X�y�[�X�L�����N�^�[�v
	PUSH	HL
	LD	IX,HELP		; �e�L�X�g�u�w���v�v
LOOP:
	EX	(SP),IX		; �e�L�X�g����������
	LD	B,32H		; �\������
LOOP1:
	CALL	DAK2		; �\��
	DJNZ	LOOP1
	JR	LOOP
;
	ORG	2020H
HELP:
	DEFB	0AEH		;"S"
	DEFB	0E3H		;"U"
	DEFB	4FH		;"P"
	DEFB	0C2H		;"L"
	DEFB	0CEH		;"E"
	DEFB	6BH		;"H"
BLANK: 
	DEFB	0
	DEFB	0
	DEFB	0
	DEFB	0
	DEFB	0
	DEFB	0
	END
