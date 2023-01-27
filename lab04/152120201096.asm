LIST	P=16F877A
    INCLUDE	p16f877.inc
    __CONFIG	_CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
    org		0x00
    
X		EQU	0x60
Y		EQU	0x61
i		EQU	0x12
K		EQU	0x13
J		EQU	0x14
MULT_SUM	EQU	0X62	
TEMP_SUM	EQU	0x63
DIVS_COUNT	EQU	0X64		
SUM		EQU	0x65    
MULT_COUNT	EQU	0x66
R_H		EQU	0x70
R_L		EQU	0x71
ADD_COUNT	EQU	0x72
GN_COUNT	EQU	0x73
N		EQU	0x74	
A		EQU	0X20
; -------------------------- 152120201096 YA?IZ HARMAN --------------------------
		
    CLRF    DIVS_COUNT
    MOVLW	d'112'
    MOVWF	X
    MOVLW	d'100'
    MOVWF	Y  
    MOVLW	d'125'
    MOVWF	N
    CALL	GENERATE_NUMBERS
    CALL	ADD_NUMBERS
    CALL	DISPLAY_NUMBERS
GENERATE_NUMBERS:
    CLRF	GN_COUNT    
GN_LOOP_BEGIN:
    MOVLW	A		    ; WREG <- A (Starting address of the array)
    MOVWF	FSR		    ; FSR <- WREG (Load the starting address of the array in FSR register)
    CLRF	TEMP_SUM
GN_LOOP_BODY:
    MOVF	N,W		    ; WREG = N
    SUBWF	X,W		    ; WREG = X-N
    BTFSC	STATUS, C	    ; No carry means X < N. Carry means X >= N or N <= X
    GOTO	GN_LOOP_OR	    ; End Loop if X > N
    GOTO	GN_INCHECK
    GN_LOOP_OR:
    MOVF	N,W		    ; WREG = N
    SUBWF	Y,W		    ; WREG = Y-N
    BTFSC	STATUS, C	    ; No carry means Y < N. Carry means Y >= N or Y <= X
    GOTO	GN_LOOP_END	    ; End Loop if Y > N
    
   GN_INCHECK:
    MOVF	X,W		    ; WREG = X
    ADDWF	Y,W		    ; WREG = Y + WREG = Y + X
    MOVWF	TEMP_SUM	    ; WREG = TEMP_SUM
    BTFSC	TEMP_SUM,0
    GOTO	GN_LOOP_IF
    GOTO	GN_LOOP_ELSE    
GN_LOOP_IF:
    MOVF	TEMP_SUM,W	    ; WREG = TEMP_SUM
    CALL	MULTIPLY
    MOVWF	INDF
    INCF	FSR,F
    INCF	GN_COUNT,F
    INCF	X,F
    INCF	ADD_COUNT    
    GOTO	GN_LOOP_BODY    
GN_LOOP_ELSE:
    MOVF	TEMP_SUM,W
    CALL	DIVISION
    MOVWF	INDF 
    INCF	FSR,F
    INCF	GN_COUNT,F
    INCF	Y,F
    INCF	Y,F
    INCF	Y,F
    INCF	ADD_COUNT    
    GOTO	GN_LOOP_BODY    
GN_LOOP_END:
    MOVF	GN_COUNT,W
    MOVWF	ADD_COUNT    
    RETURN
MULTIPLY: 
    CLRF	MULT_SUM	    ; MULT_SUM = 0	   
    CLRF	MULT_COUNT	    ; MULT_COUNT = 0
    BSF		MULT_COUNT, 3	    ; MULT_COUNT = 8  
    CLRF	R_H		    ; R_H = 0
    CLRF	R_L		    ; R_L = 0
    MOVFW	Y		    ; WREG = Y (Multiplier)
    MOVWF	R_L		    ; R_L = WREG
    MOVFW	X		    ; WREG = X (Multiplicant)
    RRF		R_L,F		    ; R_L = R_L >> 1
MULTIPLY_LOOP:
    BTFSC	STATUS, C	    ; Is the least significant bit of Y equal to 1?
    ADDWF	R_H,F		    ; R_H = R_H + WREG 
    RRF		R_H,F		    ; R_H = R_H >> 1
    RRF		R_L,F		    ; R_L = R_L >> 1 
    DECFSZ	MULT_COUNT	    ; MULT_COUNT = MULT_COUNT-1 
    GOTO	MULTIPLY_LOOP 
    MOVF R_L,W
    ADDWF R_L,W
    ADDWF R_H,W
    MOVWF MULT_SUM
    RETURN
DISPLAY_NUMBERS:
   	   
    BANKSEL	TRISD 
    CLRF	TRISD 
    MOVLW 0xFF
    MOVWF TRISB
    BANKSEL	PORTD 
    MOVF	SUM,W	
    MOVWF	PORTD 
    CALL	BUTTON_EVENT
    MOVWF       PORTD
    MOVLW	d'5'
    MOVWF	i
    MOVLW	A
    MOVWF	FSR
LOOP:
    MOVF	INDF,W
    MOVWF	PORTD
    CALL	DELAY250ms
    CALL	BUTTON_EVENT
    INCF	FSR,F
    DECFSZ	i,F
    GOTO	LOOP
    GOTO	END_CODE
DIVISION:
    CLRF	DIVS_COUNT
DIV_BODY:
    MOVLW	d'3'
    SUBWF	TEMP_SUM,W
    BTFSS	STATUS,	C
    GOTO	DIV_END
    MOVWF	TEMP_SUM
    INCF	DIVS_COUNT,F
    GOTO	DIV_BODY    
DIV_END:
    MOVF	DIVS_COUNT,W     
    RETURN 
ADD_NUMBERS:
    CLRF	SUM
    MOVLW	A
    MOVWF	FSR   
ADD_NUMBERS_LOOP_BEGIN:  
    MOVF	INDF,W
    ADDWF	SUM,F
    INCF	FSR,F    
    DECFSZ	ADD_COUNT,F
    GOTO	ADD_NUMBERS_LOOP_BEGIN    
    MOVF	SUM,W    
    RETURN
;------------------------------------------------------------------------------
; Waste 250ms in a loop
;------------------------------------------------------------------------------
DELAY250ms:	
    MOVLW	d'250'
    MOVWF	K    
DELAY250ms_OuterLoop:    
    MOVLW	d'250'
    MOVWF	J    
DELAY250ms_InnerLoop:
    NOP
    DECFSZ	J,F
    GOTO	DELAY250ms_InnerLoop	
    DECFSZ	K,F
    GOTO	DELAY250ms_OuterLoop     
    RETURN    
BUTTON_EVENT:    
    BTFSC	PORTB, 3
    GOTO	BUTTON_EVENT
    RETURN     
END_CODE:
    MOVF	0X24,W
    BANKSEL	TRISD 
    CLRF	TRISD		    ; TRISD = 0 [Essentially we are setting all pins of D to be output]
    BANKSEL	PORTD 
    MOVWF	PORTD		    ; PORTD = WREG: Display the result on the LEDs connected to PortD
    GOTO	$;
    END


