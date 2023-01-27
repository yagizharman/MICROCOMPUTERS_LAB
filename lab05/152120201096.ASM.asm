	LIST 	P=16F877A
	INCLUDE	P16F877.INC
	radix	hex
	__CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

    ; Reset vector
    org 0
    val EQU 0x20
    dir EQU 0x21
    count EQU 0x22
    ledCount EQU 0x23
    l	        EQU  0x13
    k	        EQU  0x14
    j	        EQU  0x15
    ;Yağız Harman 152120201096
   
    main
    ;initialazition
    BSF STATUS, RP0
    CLRF TRISD
    CLRF TRISB
    BCF STATUS,RP0
    
    begin:
    MOVLW d'0'
    MOVWF PORTB
    
    MOVLW d'0'
    MOVWF dir
    
    MOVLW d'1'
    MOVWF val
    
    MOVLW d'0'
    MOVWF ledCount
    CLRF count
    
    loop:
    MOVF val,W
    MOVWF PORTD
    CALL Delay
    INCF count
    MOVLW d'15'
    SUBWF count,W
    BTFSC STATUS,Z
    GOTO ifa
    
    else2:
    MOVLW d'7'
    SUBWF ledCount,W
    BTFSC STATUS,C
    GOTO rotate_left
    GOTO rotate_right
    
    ifa:
    CLRF PORTD
    CALL Delay
    MOVLW 0xFF
    MOVWF PORTD
    CALL Delay
    
    CLRF PORTD
    CALL Delay
    MOVLW 0xFF
    MOVWF PORTD
    CALL Delay
    CLRF PORTD
    CALL Delay
    MOVLW d'1'
    MOVWF val
    CLRF count
    MOVLW d'0'
    MOVWF dir
    CLRF ledCount
    GOTO begin
    
   
    
    rotate_right:
    BTFSC STATUS,Z
    BCF	    STATUS, C
    RLF val, F
    INCF ledCount
    GOTO loop
    rotate_left:
    BCF	 STATUS, C
    RRF val,F
    INCF ledCount
    GOTO loop

Delay:
;    Delay500ms:
;a	EQU	    0x70
;fk	EQU	    0x71
;kj	EQU	    0x72
;	MOVLW	    d'2'
;	MOVWF	    a			    ; i = 2
;Delay500ms_Loop1_Begin
;	MOVLW	    d'250'
;	MOVWF	    fk			    ; j = 250
;Delay500ms_Loop2_Begin	
;	MOVLW	    d'250'
;	MOVWF	    kj			    ; k = 250
;Delay500ms_Loop3_Begin	
;	NOP				    ; Do nothing
;	DECFSZ	    kj, F		    ; k--
;	GOTO	    Delay500ms_Loop3_Begin
;
;	DECFSZ	    fk, F		    ; j--
;	GOTO	    Delay500ms_Loop2_Begin
;
;	DECFSZ	    a, F		    ; i?
;	GOTO	    Delay500ms_Loop1_Begin    
;	RETURN
;	END
    
    
   Delay_250ms:
    MOVLW	    d'250'		    ; 
    MOVWF	    l			    ; l = 250
    Delay250ms_OuterLoop
    MOVLW	    d'250'
    MOVWF	    k			    ; k = 250
    Delay250ms_InnerLoop	
    NOP
    DECFSZ	    k, F		    ; k--
    GOTO	    Delay250ms_InnerLoop
    DECFSZ	    l, F		    ; l??
    GOTO	    Delay250ms_OuterLoop  
    RETURN   
    END