; This program shows how loops are implemented in assembly
;
	LIST 	P=16F877
	INCLUDE	P16F877.INC
	__CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 
	radix	dec
	
; Static global variables
DATSEC1	udata
; Assumes that the sum fits into a single 8-byte unsigned byte
i	    res	1		; 1 byte value
N	    res	1		; 1 byte value
i2		res 1		; delay
j		res	1		; delay	    
zib0	    res	1		; first number
zib1	    res	1		; second number
zib	    res	1		; 2 byte value to hold the resul
temp1	    res 1
temp2	    res 1
	    	    
; Value to be displayed on the LEDs connected to PORTD	    
dispValue   res 1		; 1 byte value to display on the LEDs
   
; Code section
TEXT	CODE		

; Reset Vector	
	ORG 0
;YA?IZ HARMAN 152120201096
	
	BANKSEL TRISB 
	MOVLW 0xFF
	MOVWF TRISB   
	MOVLW 0x00
	MOVWF TRISD   
	BANKSEL PORTD 
	CLRF PORTD		    ; Turn off all LEDs 
	MOVLW	d'12'		   
	MOVWF	N
	MOVLW	d'1'
	MOVWF   zib0
	MOVLW	d'2'
	MOVWF	zib1		   
	MOVLW   d'2'
	MOVWF	i		    
loop_begin	
	MOVF	i, W		    ; WREG = i
	SUBWF	N, W		    ; WREG = N - i
	BTFSS	STATUS, C	    
	GOTO	loop_end	    
loop_body
	MOVF zib1,W
	ANDLW 0x3F
	MOVWF temp1
	MOVF zib0,W
	IORLW 0x05
	MOVWF temp2
	MOVF temp1,W
	ADDWF temp2,W
	MOVWF zib
	MOVF	zib1,W		    ;WREG = zib1
	MOVWF	zib0		    ;zib0 = WREG
	MOVF	zib,W		    ;WREG = zib
	MOVWF	zib1		    ;zib1 = WREG
	MOVF	zib, W		    ;WREG = zib
	MOVWF	dispValue	    ;dispValue = WREG
	MOVF	dispValue, W	    ;WREG = dispValue
	MOVWF	PORTD		    ;PORTD = WREG
	INCF	i, F		    ;i++
;Delay+Button check
check    
	MOVLW	    d'250'		     
	MOVWF	    i2			    
Delay250ms_OuterLoop
	MOVLW	    d'250'
	MOVWF	    j			    
Delay250ms_InnerLoop	
	NOP
	DECFSZ	    j, F		    
	GOTO	    Delay250ms_InnerLoop

	DECFSZ	    i2, F		    
	GOTO	    Delay250ms_OuterLoop

	BTFSC PORTB ,3
	GOTO check
	GOTO	loop_begin
loop_end		
	GOTO $
END

