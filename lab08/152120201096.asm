; This program counts up to 16 and displays the corresponding hexadecimal number
; on one of the seven segment displays. By default this program uses the first
; segment display, but that can easily be changed.
;    
    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    radix	dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; Static global variables
DATSEC1	udata
LUT	res	16		; 16 byte look up value	    
;Yağız Harman 152120201096    
; Here is the number variable    
counter	    EQU	    0x50
act EQU 0x54
org 0x00    
	    
	    
	    
INIT:
BSF	    STATUS, RP0		; Select Bank1
CLRF    TRISA		; PortA --> Output
CLRF    TRISD
MOVLW 0xFF
MOVWF TRISB
BCF	    STATUS, RP0		; Select Bank0
CLRF W
; Clear PORTD & Select DIS4
CLRF    PORTD		; PORTD = 0
CLRF    PORTA		; Deselect all SSDs
BSF	    PORTA, 5		;
CLRF counter
CALL Init_LUT
MOVF counter,W
CALL GetCodeFromLUT
MOVWF  PORTD     
GOTO while1

DISPLAY:  
CALL  Delay100ms
MOVF counter,W
CALL GetCodeFromLUT
MOVWF PORTD 
CALL  Delay100ms  
    
while1:
CLRF act

check_if_pressed:
BTFSC PORTB,3
INCF act
BTFSC PORTB,4
INCF act
BTFSC PORTB,5
INCF act

MOVLW d'1'
SUBWF act,W
BTFSC STATUS,Z
GOTO while1

BTFSS   PORTB,3
GOTO    button3_pressed

BTFSS   PORTB,4
GOTO    button4_pressed

BTFSS   PORTB,5
GOTO    button5_pressed

GOTO    while1

button3_pressed:
MOVLW d'9'
SUBWF counter,W
INCF counter
BTFSS STATUS,C
GOTO DISPLAY
CLRF counter
GOTO DISPLAY





    
   
button4_pressed:
MOVLW d'0'
SUBWF counter,W
BTFSC STATUS,Z
GOTO not_zero
DECF counter
GOTO DISPLAY   
not_zero:
MOVLW d'9'
MOVWF counter
GOTO DISPLAY    
    
button5_pressed:
CLRF counter
GOTO DISPLAY
	    
	     
	    
	    
  
GOTO while1
	    
	    
;------------------------------------------------------------------------------
; Init_LUT
;------------------------------------------------------------------------------
Init_LUT
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
; Get the code from the LUT
;------------------------------------------------------------------------------
GetCodeFromLUT
    MOVWF   FSR		; FSR = number
    MOVLW   LUT		; WREG = &LUT
    ADDWF   FSR, F	; FSR += &LUT
    MOVF    INDF, W	; WREG = LUT[number]
    RETURN
    
    
;------------------------------------------------------------------------------
; Waste 100ms in a loop
;------------------------------------------------------------------------------
Delay100ms:
i	EQU	    0x75		    ; Use memory slot 0x70
j	EQU	    0x76		    ; Use memory slot 0x71
	MOVLW	    d'100'		    ; 
	MOVWF	    i			    ; i = 100
Delay100ms_OuterLoop
	MOVLW	    d'250'
	MOVWF	    j			    ; j = 250
Delay100ms_InnerLoop	
	NOP
	DECFSZ	    j, F		    ; j--
	GOTO	    Delay100ms_InnerLoop

	DECFSZ	    i, F		    ; i?
	GOTO	    Delay100ms_OuterLoop    
	RETURN
	
	END