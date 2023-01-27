      LIST 	P=16F877A
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
    radix	dec
; Static global variables
DATSEC1	udata
LUT   res	16	; 16 byte look up value
NO_ITERATIONS		EQU	0x70
digit0			EQU	0x71
digit1			EQU	0x72
i				EQU	0x73
check			EQU	0x74
    ;Ya??z Harman 152120201096
    ; Reset vector 
    org 0x00
    GOTO MAIN

    #include <Delay.inc>	; Delay library (Copy the contents here)
    #include <LcdLib.inc>	; LcdLib.inc (LCD) utility routines
MAIN   
	BSF     STATUS, RP0	; Select Bank1
	CLRF    TRISA		; PortA --> Output
	CLRF    TRISD		; PortD --> Output
	BCF	STATUS, RP0	; Select Bank0
	
	CLRF    PORTD		; PORTD = 0
	CLRF	PORTA		; Deselect All SSDs
	BSF     STATUS, RP0
	
	MOVLW	0x0
	MOVWF	TRISD
	MOVWF	TRISE
	; This is only necessary because our programming board connects E0, E1 and E2 pins of the MCU
	; to LCD's control pins RS, RW, EN respectively. Because PORTE shares the same pins as the analog pins of PORTA of the MCU,
	; not only we must we set PORTE pins as output, but also set the analog pins of PORTA as digital output.
	; If we don't do this, PORTE's pins are not set up properly, and the LCD does not work	
	MOVLW	0x03		; Choose RA0 analog input and RA3 reference input
	MOVWF	ADCON1		; Register to configure PORTA's pins as analog/digital <11> means, all but one are analog
	
	BCF	STATUS, RP0	; Select Bank0
	CALL	LCD_Initialize	; Initialize the LCD

	MOVLW   d'0'
	MOVFW   digit0
	MOVLW   d'0'
	MOVLW   digit1
	MOVLW	d'0'
	MOVFW	check
	MOVLW   d'90'
	MOVWF   NO_ITERATIONS
	CALL    Init_LUT

while_1_loop:
    CLRF    i		; i = 0
    CALL DisplayCounter
for_loop:    
    ;Increment I until i>=NO_ITERATIONS
    MOVF    NO_ITERATIONS,W	; WREG=NO_ITERATIONS
    SUBWF   i,W			; WREG = NO_ITERATIONS - i
    BTFSC   STATUS,C		; Check if i<NO_ITERATIONS if not continue
    GOTO    first_if		; if i>=NO_ITERATIONS then end loop
for_loop_body:
    BSF	    PORTA, 5		; Select DIS4
    BCF	    PORTA, 4		; Do not select DIS3 so it can be set to 0
    MOVF    digit0, W		; WREG = digit0
    CALL    GetCodeFromLUT	; Get the 7-segment code for the number    
    MOVWF   PORTD		; PORTD becomes the digit0
    CALL    Delay5ms		; 5 ms delay
    BCF	    PORTA, 5		; Do not select DIS4 so it can stay as the ones
    BSF	    PORTA, 4		; Select DIS3 so it can be incremented as the tens
    MOVF    digit1, W		; WREG = digit1
    CALL    GetCodeFromLUT	; Get the 7-segment code for the number    
    MOVWF   PORTD		; PORTD becomes the digit1
    CALL    Delay5ms		; 5 ms delay
    INCF    i, F		; i++
    GOTO    for_loop
first_if:
    INCF    digit0, F		; digit0++
    MOVLW   d'10'		; WREG = 10
    SUBWF   digit0, W		; WREG = digit0 - WREG(10)
    BTFSS   STATUS, Z		; Check if the digit0 becomes tens then it must be resetted to ones
    GOTO    second_if
    CLRF    digit0		; digit0 = 0
    INCF    digit1, F		; increment digit1 to tens
second_if:
    MOVLW   d'2'		; WREG = 2
    SUBWF   digit1,W		; WREG = digit1 - W
    BTFSS   STATUS,Z		; check if digit1 is 2, if its reset the counter
    GOTO    end_ifs
    MOVLW   d'1'		; WREG = 1
    SUBWF   digit0,W		; WREG = digit0 - WREG
    BTFSS   STATUS,Z		; check if digit1 is 0, if its reset the counter
    GOTO    end_ifs
    CLRF    digit0
    CLRF    digit1
    MOVLW d'1'
    MOVWF check
end_ifs:
    GOTO    while_1_loop

    DisplayCounter:
    call LCD_Clear
    movlw 'C'
    call LCD_Send_Char
    movlw 'o'
    call LCD_Send_Char
    movlw 'u'
    call LCD_Send_Char
    movlw 'n'
    call LCD_Send_Char
    movlw 't'
    call LCD_Send_Char
    movlw 'e'
    call LCD_Send_Char
    movlw 'r'
    call LCD_Send_Char
    movlw ' '
    call LCD_Send_Char
    movlw 'V'
    call LCD_Send_Char
    movlw 'a'
    call LCD_Send_Char
    movlw 'l'
    call LCD_Send_Char
    movlw ':'
    call LCD_Send_Char
	; Print digit1: digits[1]
	MOVF	digit1, W ; WREG <- digit
	ADDLW	'0'	    ; Add '0' to the digit 
	CALL	LCD_Send_Char	

	; Print digit0: LSB
	MOVF	digit0, W   ; WREG <- digit
	ADDLW	'0'	    ; Add '0' to the digit 
	CALL	LCD_Send_Char
	CALL	LCD_MoveCursor2SecondLine
	MOVLW	d'0'
	SUBWF	check,W
	BTFSS	STATUS,Z
	GOTO	Display_Rolled_To_Zero
	CALL	Display_Counting_Val
	GOTO	for_loop_body
	RETURN

Display_Counting_Val:
    movlw 'C'
    call LCD_Send_Char
    movlw 'o'
    call LCD_Send_Char
    movlw 'u'
    call LCD_Send_Char
    movlw 'n'
    call LCD_Send_Char
    movlw 't'
    call LCD_Send_Char
    movlw 'i'
    call LCD_Send_Char
    movlw 'n'
    call LCD_Send_Char
    movlw 'g'
    call LCD_Send_Char
    movlw ' '
    call LCD_Send_Char
    movlw 'u'
    call LCD_Send_Char
    movlw 'p'
    call LCD_Send_Char
    movlw '.'
    call LCD_Send_Char
    movlw '.'
    call LCD_Send_Char
    movlw '.'
    call LCD_Send_Char    
    RETURN
Display_Rolled_To_Zero:
    movlw 'R'
    call LCD_Send_Char
    movlw 'o'
    call LCD_Send_Char
    movlw 'l'
    call LCD_Send_Char
    movlw 'l'
    call LCD_Send_Char
    movlw 'e'
    call LCD_Send_Char
    movlw 'd'
    call LCD_Send_Char
    movlw ' '
    call LCD_Send_Char
    movlw 'o'
    call LCD_Send_Char
    movlw 'v'
    call LCD_Send_Char
    movlw 'e'
    call LCD_Send_Char
    movlw 'r'
    call LCD_Send_Char
    movlw ' '
    call LCD_Send_Char
    movlw 't'
    call LCD_Send_Char
    movlw 'o'
    call LCD_Send_Char
    movlw ' '
    call LCD_Send_Char
    movlw '0'
    call LCD_Send_Char 
    RETURN

;------------------------------------------------------------------------------
; Get the code from the LUT
;------------------------------------------------------------------------------
GetCodeFromLUT:
    MOVWF   FSR		; FSR = number
    MOVLW   LUT		; WREG = &LUT
    ADDWF   FSR, F	; FSR += &LUT
    MOVF    INDF, W	; WREG = LUT[number]
    RETURN    
 
;------------------------------------------------------------------------------
; Init_LUT
;------------------------------------------------------------------------------
Init_LUT:
    MOVLW   B'00111111'		; 0
    MOVWF   LUT			; LUT[0] = WREG    
    MOVLW   B'00000110'		; 1
    MOVWF   LUT+1		; LUT[0] = WREG    
    MOVLW   B'01011011'		; 2
    MOVWF   LUT+2		; LUT[0] = WREG    
    MOVLW   B'01001111'		; 3
    MOVWF   LUT+3		; LUT[0] = WREG    
    MOVLW   B'01100110'		; 4
    MOVWF   LUT+4		; LUT[0] = WREG    
    MOVLW   B'01101101'		; 5
    MOVWF   LUT+5		; LUT[0] = WREG    
    MOVLW   B'01111101'		; 6
    MOVWF   LUT+6		; LUT[0] = WREG    
    MOVLW   B'00000111'		; 7
    MOVWF   LUT+7		; LUT[0] = WREG    
    MOVLW   B'01111111'		; 8
    MOVWF   LUT+8		; LUT[0] = WREG    
    MOVLW   B'01101111'		; 9
    MOVWF   LUT+9		; LUT[0] = WREG
   
    RETURN
    
;------------------------------------------------------------------------------
; Waste 5ms in a loop
;------------------------------------------------------------------------------    
Delay5ms:
k	EQU	0x74
l	EQU	0x75

    MOVLW   d'5'
    MOVWF   k		; k = noIterations1
Delay5ms_OuterLoop:
    MOVLW   d'250'
    MOVWF   l		; l = noIterations2
Delay5ms_InnerLoop:	
    NOP			; No operation	
    DECFSZ  l, F	; l--
    GOTO    Delay5ms_InnerLoop
    DECFSZ  k, F	; k--
    GOTO    Delay5ms_OuterLoop
    RETURN
    
    END