;********************************************************************************
;* main.asm: Demonstration av enkelt assemblerprogram f�r mikrodator ATmega328P. 
;*           En lysdiod ansluts till pin 8 (PORTB0) och en tryckknapp ansluts 
;*           till pin 13 (PORTB). Vid nedtryckning av tryckknappen blinkar
;*           lysdioden var 100:e millisekund, annars h�lls den sl�ckt.
;*
;*           Noteringar: 
;*              Subrutin �r samma som som en funktion.
;*              All data m�ste lagras i ett CPU-register vid anv�ndning.    
;*
;*           Assemblerdirektiv:
;*              .EQU (Equal)        : Allm�na makrodefinitioner.
;*              .DEF (Define)       : Makrodefinitioner f�r CPU-register.
;*              .CSEG (Code Segment): Programminnet, h�r lagras programkoden.
;*              .DSEG (Data Segment): Dataminnet, h�r lagras statiska variabler.
;*              .ORG (Origin)       : Anv�nds f�r att specificera en adress.
;*
;*           Assemblerinstruktioner:
;*              RJMP (Relative Jump)      : Hoppar till angiven adress.
;*              CALL (Call Subroutine)    : Anropar subrutin (t�nk funktionsanrop).
;*              RET (Return)              : Genomf�r �terhopp fr�n subrutin.
;*              LDI (Load Immediate)      : L�ser in konstant i CPU-register.
;*              OUT (Write to I/O)        : Skriver till I/O-register.
;*              IN (Read From I/O)        : L�ser inneh�ll fr�n I/O-register.
;*              ANDI (And Immediate)      : Bitvis multiplikation med en konstant.
;*              ORI (Or Immediate)        : Bitvis addition med en konstant.
;*              CALL (Call Subroutine)    : Anropar subrutin och sparar
;*                                          �terhoppsadressen p� stacken.
;*              RET (Return)              : Genomf�r �terhopp fr�n subrutin
;*                                          till adress sparad p� stacken. 
;*              CPI (Compare Immediate)   : J�mf�r inneh�llet i ett CPU-register
;*                                          med en konstant via subtraktion.
;*              BRNE (Branch If Not Equal): Hoppar till angiven adress om
;*                                          operanderna i f�reg�ende j�mf�relse
;*                                          inte matchade.
;*              BRLO (Branch If Lower)    : Hoppar till angiven adress om
;*                                          resultatet fr�n f�reg�ende
;*                                          j�mf�relse blev negativt.
;*              INC (Increment)           : Inkrementerar inneh�llet i ett
;*                                          CPU-register.
;*              PUSH (Push To Stack)      : Lagrar inneh�ll p� stacken.
;*              POP (Pop From Stack)      : H�mtar inneh�ll fr�n stacken.
;********************************************************************************

; Makrodefinitioner:
.EQU LED1    = PORTB0 ; Lysdiod 1 ansluten till pin 8 (PORTB0).
.EQU BUTTON1 = PORTB5 ; Tryckknapp 1 ansluten till pin 13 (PORTB5).

;********************************************************************************
;* .CSEG: Kodsegmentet (programminnet). H�r lagras programkoden.
;*        Programmet b�rjar alltid p� adress 0x00 i programminnet. I detta
;*        fall hoppar vi till subrutinen main f�r att starta programmet.
;********************************************************************************
.CSEG
.ORG 0x00    ; Startadress 0x00 - H�r b�rjar programmet.
   RJMP main ; Hoppar till subrutinen main.

;********************************************************************************
;* main: Initierar I/O-portarna vid start. Programmet h�lls sedan ig�ng
;*       kontinuerligt s� l�nge matningssp�nning tillf�rs. Vid nedtryckning
;*       av tryckknappen t�nds lysdioden, annars h�lls den sl�ckt.
;********************************************************************************
main:

;********************************************************************************
;* setup: Initierar mikrodatorns I/O-portar.
;********************************************************************************
setup:
   LDI R16, (1 << LED1)    ; L�ser in (1 << LED1) = 0000 0001 i CPU-register R16.
   OUT DDRB, R16           ; Skriver inneh�llet till datariktningsregister DDRB.
   LDI R16, (1 << BUTTON1) ; L�ser in (1 << BUTTON1) = 0010 0000 i CPU-register R16.
   OUT PORTB, R16          ; Skriver inneh�llet till dataregister PORTB.

;********************************************************************************
;* main_loop: H�ller ig�ng programmet s� l�nge matningssp�nning tillf�rs.
;********************************************************************************
main_loop:                
   IN R16, PINB             ; L�ser insignaler fr�n PINB till CPU-register R16.
   ANDI R16, (1 << BUTTON1) ; Nollst�ller alla bitar f�rutom tryckknappens.
   BRNE call_led1_blink     ; Om tryckknappen �r nedtryckt blinkas lysdioden.
   CALL led1_off            ; Annars h�lls lysdioden sl�ckt.
   RJMP main_loop_end       ; �terstartar loopen i main.
call_led1_blink:            
   CALL led1_blink          ; Blinkar lysdioden med en blinkhastighet p� 100 ms.
main_loop_end:              
   RJMP main_loop           ; �terstartar loopen i main.

;********************************************************************************
;* led1_on: T�nder lysdioden. 
;********************************************************************************
led1_on:
   IN R16, PORTB        ; L�ser in data fr�n PORTB.
   ORI R16, (1 << LED1) ; Ettst�ller lysdiodens bit, �vriga bitar op�verkade.
   OUT PORTB, R16       ; Skriver tillbaka det uppdaterade inneh�llet.
   RET                  ; Avslutar subrutinen, hoppar till �terhoppsadressen.

;********************************************************************************
;* led1_off: Sl�cker lysdioden.
;********************************************************************************
led1_off:
   IN R16, PORTB          ; L�ser in data fr�n PORTB.
   ANDI R16, ~(1 << LED1) ; Nollst�ller lysdiodens bit, �vriga bitar op�verkade.
   OUT PORTB, R16         ; Skriver tillbaka det uppdaterade inneh�llet.
   RET                    ; Avslutar subrutinen, hoppar till �terhoppsadressen.

;********************************************************************************
;* led1_blink: Blinkar lysdioden med 100 millisekunds blinkhastighet.
;********************************************************************************
led1_blink:
   CALL led1_on     ; T�nder lysdioderna.
   CALL delay_100ms ; Genererar 100 millisekunders f�rdr�jning.
   CALL led1_off    ; Sl�cker lysdioderna.
   CALL delay_100ms ; Genererar 100 millisekunders f�rdr�jning.
   RET              ; Avslutar subrutinen, genomf�r �terhopp.

;********************************************************************************
;* delay_100ms: Genererar 100 millisekunders f�rdr�jning via uppr�kning med
;*              CPU-register R16 - R18. Innan uppr�kningen startar sparas
;*              tidigare inneh�ll undan p� stacken.
;********************************************************************************
delay_100ms:
   PUSH R16              ; Sparar undan inneh�llet fr�n CPU-register R16 p� stacken.
   PUSH R17              ; Sparar undan inneh�llet fr�n CPU-register R17 p� stacken.
   PUSH R18              ; Sparar undan inneh�llet fr�n CPU-register R18 p� stacken.
   LDI R16, 0x00         ; Nollst�ller R16 inf�r uppr�kning i for-satsen.
   LDI R17, 0x00         ; Nollst�ller R16 inf�r uppr�kning i for-satsen.
   LDI R18, 0x00         ; Nollst�ller R16 inf�r uppr�kning i for-satsen.
delay_100ms_loop:        ; Loop som r�knar fr�n 0 till 255 x 255 x 5.
   INC R16               ; R�knar upp fr�n 0 - 255.
   CPI R16, 255          ; J�mf�r R16 mot v�rdet 255.
   BRLO delay_100ms_loop ; S� l�nge R16 �r mindre �n 255 upprepas loopen.
   LDI R16, 0x00         ; Nollst�ller R16 inf�r n�sta uppr�kning.
   INC R17               ; R�knar upp R17 efter att R16 har r�knat upp till 255.
   CPI R17, 255          ; J�mf�r R17 mot v�rdet 255.
   BRLO delay_100ms_loop ; S� l�nge R17 �r mindre �n 255 upprepas loopen fr�n b�rjan.
   LDI R17, 0x00         ; Nollst�ller R17 inf�r n�sta uppr�kning.
   INC R18               ; R�knar upp R18 efter att R16 - R17 har r�knat upp till 255 x 255.
   CPI R18, 5            ; J�mf�r R18 mot v�rdet 5.
   BRLO delay_100ms_loop ; S� l�nge R17 �r mindre �n 5 upprepas loopen fr�n b�rjan.
delay_100ms_end:         ; �terst�ller CPU-register innan �terhopp.
   POP R18               ; L�gger tillbaka inneh�llet lagrat p� stacken i CPU-register R18.
   POP R17               ; L�gger tillbaka inneh�llet lagrat p� stacken i CPU-register R17.
   POP R16               ; L�gger tillbaka inneh�llet lagrat p� stacken i CPU-register R16.
   RET                   ; Avslutar subrutin, genomf�r �terhopp till lagrad �terhoppsadress.

