#make_bin#
#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#
#CS=0000h#
#IP=0000h#
#DS=0000h#
#ES=0000h#
#SS=0000h#
#SP=0FFFEh#
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#


         jmp     st1 
         db     1021 dup(0)
;main program
          
st1:      cli 
; intialize ds, es,ss to start of RAM
          mov       ax,0200h
          mov       ds,ax
          mov       es,ax
          mov       ss,ax
          mov       sp,0FFFEH

PORTA EQU 0000H
PORTB EQU 0002H                                  

;DATA
JMP     START

PORTA EQU 00h
PORTB EQU 02h
PORTC EQU 04h
CREG1 EQU 06h

;AEDC EQU 08h 


START:

;initialize 8255A
;portA as intput,portB as output ,portC lower as output and portC upper as input

	MOV 	AL,10011000b
	OUT 	CREG1,AL

;loading count of chocolates
	
	MOV	 	AX,100
	MOV		[6F0h],AX
	MOV 	AX,100
	MOV 	[6F2h],AX
	MOV 	AX,1
	MOV		[6F4h],AX



;setting portb
	MOV		AL, 00000000B
	OUT		PORTB,AL
	MOV 	AL,08H
	OUT 	PORTC,AL


MAIN:
;check if key is pressed and figure out whether it is perk or 5star or dairy milk
	IN		AL,PORTC
	AND		AL,70h
	CMP		AL,01100000B
	JE		PERK
	CMP		AL,01010000B
	JE		FIVESTAR
	CMP		AL,00110000B
	JE		DAIRYMILK
	JMP		MAIN

;perk

PERK:
    MOV     CL, 5
    W1:     CALL DELAY_1S
            NOP
            LOOP W1
	MOV		DL,01
	LEA		SI,[6F0h]
	MOV		AL,[SI]
	CMP		AL,0000h
	JNE		ADCWAIT		        ;If perk is present jump to ADCWAIT
	MOV		AL,00000001B		;PC0 is set  so as to glow the led
	OUT		CREG1,AL
	CALL 	DELAY_1S		    ;DELAY
	MOV		AL,98H			    ;resetting 8255A
	OUT		CREG1,AL
	JMP 	MAIN

;checking for weight of perk. From ADCWAIT, we jump to P1 this if perk was the selected input.
	
P1: MOV     AL, 98H
    OUT     CREG1, AL
    MOV		AH,01011000B
	IN 		AL,PORTA
	CMP		AL,AH
	JNE		MONEYBACK
	DEC 	[SI]
   
    ;logic to rotate the motor so as to take the money in
	MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000100B
	OUT		PORTB,AL
	CALL	DELAY_1S
    MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000000B	;stop the motors
	OUT		PORTB,AL
	
	;logic to rotate the motor so as to dispense the cholocate out
	MOV		AL,00000001B
	OUT		PORTB,AL
	CALL	DELAY_1S
	MOV		AL,00000000B	;stopping the motors
	OUT		PORTB,AL
	JMP		CHOCOUT

;5star

FIVESTAR:	
	MOV		DL,02
	LEA		SI,[6F2h]
	MOV		AL,[SI]
	CMP		AL,00h
	JNE		ADCWAIT			;If 5star is present jump to ADCWAIT
	MOV		AL,0000011B		;PC1 is set
	OUT		CREG1,AL
	CALL 	DELAY_1S		;DELAY
	MOV		AL,98h			;resetting
	OUT		CREG1,AL
	JMP 	MAIN                                                                                    
	
;checking for weight of 5star. From ADCWAIT, we jump to P2 if 5star was the selected input.
P2:	
    MOV     AL, 98H
    OUT     CREG1, AL
    MOV		AH,11001100b
	IN 		AL,PORTA
	CMP		AL,AH
	JNE		MONEYBACK
	DEC 	[SI]
    
    ;logic to rotate the motor so as to take the money in
	MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000100B
	OUT		PORTB,AL
	CALL	DELAY_1S
    MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000000B	;stop the motors
	OUT		PORTB,AL
	
	;logic to rotate the motor so as to dispense the cholocate out
	MOV		AL,00000010B
	OUT		PORTB,AL
	CALL	DELAY_1S
	MOV		AL,00000000B	;stopping the motors
	OUT		PORTB,AL
	JMP		CHOCOUT

;dairymilk
DAIRYMILK:	
	MOV		DL,03
	LEA		SI,[6F4h]
	MOV		AL,[SI]
	CMP		AL,0000h
	JNE		ADCWAIT			;If dairy milk is present jump to ADCWAIT
	MOV		AL,00000101B		;PC2 is set
	OUT		CREG1,AL
	CALL 	DELAY_1S		;DELAY
	MOV		AL,98h			;resetting
	OUT		CREG1,AL
	JMP 	MAIN                                                                         
	
;checking for weight of dairy milk. From ADCWAIT, we jump to P3 if dairy was the selected input
P3:	
    MOV     AL, 98H
    OUT     CREG1, AL
    MOV		AH, 01100110b
	IN 		AL,PORTA
	CMP		AL,AH
	JNE		MONEYBACK
	DEC 	[SI]

	MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000100B
	OUT		PORTB,AL
	CALL	DELAY_1S
    MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000000B	;stop the motors
	OUT		PORTB,AL

	MOV		AL,00000011B
	OUT		PORTB,AL
	CALL	DELAY_1S
	MOV		AL,00000000B	;stopping the motors
	OUT		PORTB,AL
	JMP		CHOCOUT

;adcwait

ADCWAIT:
    ;; delay to give time for the user to set weight

    MOV CL,07
  T3:
    CALL DELAY_1S
    LOOP T3  
            
    ;setting adc on
    IN      AL,PORTC
    AND     AL,11110111B
	OUT		PORTC,AL
	

;loop till adc interrupt is raised .ie. eoc is 1
J1: IN		AL,PORTC
	AND		AL,80H
	CMP		AL,0
	JE		J1			
	

    
	IN		AL,PORTA
	JMP		EXITADC

;logic to decide whether to go perk, or 5star, or dairy milk
T1:	MOV		AH,1
	CMP		AH,DL
	JE		P1       
	
	
	MOV		AH,2
	CMP		AH,DL
	JE		P2
	
	MOV		AH,3
	CMP		AH,DL
	JE		P3

;exitadc
EXITADC:	
	;clear adcst and ale in PC3
    MOV     Al, 98h
    OUT     CREG1, AL
    ;IN      AL,PORTC
	MOV     AL, 00000111b
	OUT     CREG1, AL
	
	JMP		T1

;moneyback
MONEYBACK:
    MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000101B
	OUT		PORTB,AL
	CALL	DELAY_1S
	MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000000B	;stop the motors
	OUT		PORTB,AL	
	JMP		MAIN

;chocout
CHOCOUT:
    MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000101B
	OUT		PORTB,AL
	CALL	DELAY_1S
	MOV     AL,98h
    OUT     CREG1,AL
	MOV		AL,00000000B	;stop the motors
	OUT		PORTB,AL	
	JMP		MAIN



;delay_20ms
DELAY_20MS proc
	
	MOV		CH,5
	X1:	NOP
		NOP
		DEC 	CH
		JNZ 	X1
	RET
DELAY_20MS endp

;delay_1s
DELAY_1S proc
	
	MOV		BX,15000
	X2:	CALL	DELAY_20MS
		DEC		BX
		JNZ		X2
	RET
DELAY_1S endp		
	
