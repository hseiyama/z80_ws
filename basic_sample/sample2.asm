;***********************************************************
;SAMPLE2
;***********************************************************
;
	ORG	0000h
START:
	XOR	A		;A <- 0
	LD	B,10		;B <- 10
	LD	H,1		;H <- 1
LOOP1:
	ADD	A,H		;A <- A+H
	INC	H		;H <- H+1
	DJNZ	LOOP1		;B <- B-1
	HALT
	END
