    LIST 	P=16F877A ;LAB GROUP 46 YA?IZ HARMAN 152120201096
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

    ; Reset vector
    org 0x00
    ; ---------- Initialization ---------------------------------
    BSF     STATUS, RP0	 ; Select Bank1
    CLRF    TRISB	               ; Set all pins of PORTB as output
    CLRF    TRISD	               ; Set all pins of PORTD as output
    BCF     STATUS, RP0	 ; Select Bank0    
    CLRF    PORTB	               ; Turn off all LEDs connected to PORTB
    CLRF    PORTD	; Turn off all LEDs connected to PORTD
    
    ; ---------- Your code starts here --------------------------
    
    tmp1    EQU	    0x20	; A temporary variable
    tmp2    EQU	    0x21	; Another temporary variable
    x	    EQU	    0x22
    y	    EQU	    0x23
    z	    EQU	    0x24
    r1	    EQU	    0x25
    r2	    EQU	    0x26
    r3	    EQU	    0x27
    r4	    EQU	    0x28
    r5	    EQU	    0x29
    tmp3    EQU     0x30
    tmp4    EQU     0x31
    tmp5    EQU     0x32
    tmp6    EQU     0x33
    tmp7    EQU     0x34
    tmp8    EQU     0x35
    tmp9    EQU     0x36
    tmp10    EQU     0x37
    tmp11    EQU     0x38
    tmp12    EQU     0x39
    tmp13    EQU     0x40
    
    MOVLW   d'5'		
    MOVWF   x		
    MOVLW   d'6'		
    MOVWF   y		
    MOVLW   d'7'		
    MOVWF   z		
    
    ;--------R1-------
    MOVF x,W		
    ADDWF x,W		
    ADDWF x,W		
    ADDWF x,W		
    ADDWF x,W		
    MOVWF  tmp1
    MOVF y,W		
    ADDWF y,W	
    SUBWF tmp1,W
    ADDWF z,W
    MOVWF  tmp2
    MOVLW   3
    SUBWF tmp2, W
     MOVWF   r1
    ;--------R1 END-------
    
    ;--------R2-------
    MOVLW   5		
    ADDWF   x, W	
    MOVWF   tmp3	
    MOVF    tmp3, W	
    ADDWF   tmp3, W
    ADDWF   tmp3, W
    ADDWF   tmp3, W
    MOVWF   tmp3
    MOVF y,W
    ADDWF   y, W
    ADDWF   y, W
    SUBWF tmp3,W
    ADDWF   z,W
    MOVWF   r2	
    ;--------R2 END-------
    
     ;--------R3-------
     MOVF x,W
     MOVWF tmp4
     MOVF tmp4,W
     BCF STATUS,C
     RRF tmp4,F
     
     MOVF y,W
     MOVWF tmp5
     MOVF tmp5,W
     BCF STATUS,C
     RRF tmp5,F
     
     MOVF z,W
     MOVWF tmp6
     MOVF tmp6,W
     BCF STATUS,C
     RRF tmp6,F
      BCF STATUS,C
     RRF tmp6,F
    
     
     MOVFW tmp4
     ADDWF tmp5,W
     ADDWF tmp6,W
     MOVWF   r3	
    ;--------R3 END-------
    
     ;--------R4-------
    MOVF x,W		
    ADDWF x,W		
    ADDWF x,W		
    MOVWF  tmp7
    MOVF y,W
    SUBWF tmp7,W
    MOVWF tmp8
    MOVF z,W
    ADDWF z,W		
    ADDWF z,W
    SUBWF tmp8,W
    MOVWF tmp9
    MOVF tmp9,W
    ADDWF tmp9,W
    MOVWF tmp10
    MOVLW   d'30'
    SUBWF tmp10,W
    MOVWF   r4
     ;--------R4 END-------
     ;---------R-----------
      
      MOVF r1,W		
      ADDWF r1,W		
      ADDWF r1,W		
      ADDWF r2,W
      ADDWF r2,W
      MOVWF tmp11
      
        MOVF r3,W
	MOVWF tmp12
	MOVF tmp12,W
	BCF STATUS,C
	RRF tmp12,F
	MOVF tmp12,W
	SUBWF tmp11,W
	MOVWF tmp13
	
	 MOVF r4,W
	 SUBWF tmp13,W
	 
     
      ;---------R END-----------
     
    ; ---------- Your code ends here ----------------------------    
    MOVWF  PORTD    	; Send the result stored in WREG to PORTD to display it on the LEDs
    
LOOP    GOTO    $	; Infinite loop
     END                               ; End of the program



