;***********************************************************
;SAMPLE 4_3_shift
;***********************************************************
;4.3 ���V�t�g 
;�^�X�N�F�������ʒu 2040H �̓��e�͍��� 1�r�b�g�V�t�g����A
;���ʂ̓������ʒu 2041H �Ɋi�[����܂��B
;
;���̌��ʁAODEH �̓������ʒu 2041H �Ɋi�[����܂��B
;(�r�b�g��11011110B) 
;***********************************************************
;
	ORG	2000H		;�A�h���X�J�n�v���O����
BSP3:
	LD	A,(2040H)	;���[�h�I�y�����h
	SLA	A		;1��ړ�����
	LD	(2041H),A	;�t�@�C������
	HALT
;
	ORG	2040H		;�Z���f�[�^
	DEFB	6FH		;�r�b�g�� 01101111b
	END