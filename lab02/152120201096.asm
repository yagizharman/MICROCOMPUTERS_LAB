	LIST 	P=16F877
	INCLUDE	P16F877.INC
	__CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 
	radix	dec
	;152120201096 YAGIZ HARMAN
; Static global variables
DATSEC1	udata
x	res	1		; 1 byte value
y	res	1		; 1 byte value
box	res	1		; 1 byte value	
temp    res     1	
; Code section
TEXT	CODE	
ORG 0
	
	
;if (x < 0 || x > 11 || y < 0 || y > 10) box = -1;   // We do not fall inside a valid box
;else if (x <= 3){
 ;   if (y <= 1)        box = 3;
  ; else if (y <= 4) box = 2;
   ;else                   box = 1;

;} else if (x <= 7){
 ;   if (y <= 5) box=5;
  ;  else           box=4;

;} else {
 ;   if (y<=2)         box=9;
  ;  else if (y<=6) box=8;
   ; else if (y<=8) box=7;
    ;else                 box=6;
;} //end-else

    
	
	;------------
	MOVLW	d'5'		    ; 
	MOVWF	x		    ; x = WREG
	MOVLW   d'6'
	MOVWF   y
	MOVLW d'3'
	MOVWF temp
	BTFSS	x, 7	    ; Is x negative?
	GOTO	CHECK_IF_GT_10_LABEL
	;if x is negative you got here
	IF_LABEL:
	MOVLW	-1 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
        
	CHECK_IF_GT_10_LABEL:
	; Check if x > 11    
	    MOVF	x, W
	    SUBLW	d'11'	    ; WREG = 10 - x
	    BTFSS	STATUS, C   
	    GOTO	IF_LABEL
	
	CHECK_IF_Y_NEGATIVE:
	    BTFSS	y, 7	    ; Is y negative?
	    GOTO	CHECK_IF_Y_10_LABEL
	    GOTO	IF_LABEL
	CHECK_IF_Y_10_LABEL:
	    ; Check if y > 10    
	    MOVF	y, W
	    SUBLW	d'10'	    ; WREG = 10 - x
	    BTFSS	STATUS, C   
	    GOTO	IF_LABEL
	
	NEXT_STATEMENT:
	MOVLW d'3'
	MOVWF temp
	MOVF x,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO NEXT_STATEMENT2
	MOVLW d'1'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO less_than2
	MOVLW	d'3' 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
	
	
	less_than2:
	MOVLW d'4'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO less_than3
	MOVLW	d'2' 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
	
	less_than3:
	MOVLW	d'1' 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
	
	NEXT_STATEMENT2:
	MOVLW d'7'
	MOVWF temp
	MOVF x,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO NEXT_STATEMENT3
	MOVLW d'5'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO less_2
	MOVLW	d'5' 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
	
	less_2:
	MOVLW	d'4' 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
	
	NEXT_STATEMENT3:
	MOVLW d'2'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO less_12
	MOVLW	d'9' 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
	
	less_12:
	MOVLW d'6'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO less_13
	MOVLW	d'8' 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
	
	less_13:
	MOVLW d'8'
	MOVWF temp
	MOVF y,W
	SUBWF temp,W
	BTFSS STATUS,C
	GOTO less_14
	MOVLW	d'7' 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
	
	less_14:
	MOVLW	d'6' 
	MOVWF	box	    ; box = -1
	GOTO	END_STATAMENT
    
	END_STATAMENT:
	BSF	STATUS, RP0	    ; Select Bank1
	CLRF	TRISD		    ; Make all pins on PORTD as output
	
	BCF	STATUS, RP0	    ; Select Bank0
	MOVF	box, W		    ; WREG = z
	MOVWF	PORTD		    ; PORTD = WREG
	    GOTO    $
	    END 
    
   
 
    END ; End of the program
	