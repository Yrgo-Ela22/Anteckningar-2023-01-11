;********************************************************************************
;* main.asm: Demonstration av enkelt assemblerprogram för mikrodator ATmega328P. 
;*           En lysdiod ansluts till pin 8 (PORTB0) och en tryckknapp ansluts 
;*           till pin 13 (PORTB). Vid nedtryckning av tryckknappen blinkar
;*           lysdioden var 100:e millisekund, annars hålls den släckt.
;*
;*           Noteringar: 
;*              Subrutin är samma som som en funktion.
;*              All data måste lagras i ett CPU-register vid användning.    
;*
;*           Assemblerdirektiv:
;*              .EQU (Equal)        : Allmäna makrodefinitioner.
;*              .DEF (Define)       : Makrodefinitioner för CPU-register.
;*              .CSEG (Code Segment): Programminnet, här lagras programkoden.
;*              .DSEG (Data Segment): Dataminnet, här lagras statiska variabler.
;*              .ORG (Origin)       : Används för att specificera en adress.
;*
;*           Assemblerinstruktioner:
;*              RJMP (Relative Jump)      : Hoppar till angiven adress.
;*              CALL (Call Subroutine)    : Anropar subrutin (tänk funktionsanrop).
;*              RET (Return)              : Genomför återhopp från subrutin.
;*              LDI (Load Immediate)      : Läser in konstant i CPU-register.
;*              OUT (Write to I/O)        : Skriver till I/O-register.
;*              IN (Read From I/O)        : Läser innehåll från I/O-register.
;*              ANDI (And Immediate)      : Bitvis multiplikation med en konstant.
;*              ORI (Or Immediate)        : Bitvis addition med en konstant.
;*              CALL (Call Subroutine)    : Anropar subrutin och sparar
;*                                          återhoppsadressen på stacken.
;*              RET (Return)              : Genomför återhopp från subrutin
;*                                          till adress sparad på stacken. 
;*              CPI (Compare Immediate)   : Jämför innehållet i ett CPU-register
;*                                          med en konstant via subtraktion.
;*              BRNE (Branch If Not Equal): Hoppar till angiven adress om
;*                                          operanderna i föregående jämförelse
;*                                          inte matchade.
;*              BRLO (Branch If Lower)    : Hoppar till angiven adress om
;*                                          resultatet från föregående
;*                                          jämförelse blev negativt.
;*              INC (Increment)           : Inkrementerar innehållet i ett
;*                                          CPU-register.
;*              PUSH (Push To Stack)      : Lagrar innehåll på stacken.
;*              POP (Pop From Stack)      : Hämtar innehåll från stacken.
;********************************************************************************

; Makrodefinitioner:
.EQU LED1    = PORTB0 ; Lysdiod 1 ansluten till pin 8 (PORTB0).
.EQU BUTTON1 = PORTB5 ; Tryckknapp 1 ansluten till pin 13 (PORTB5).

;********************************************************************************
;* .CSEG: Kodsegmentet (programminnet). Här lagras programkoden.
;*        Programmet börjar alltid på adress 0x00 i programminnet. I detta
;*        fall hoppar vi till subrutinen main för att starta programmet.
;********************************************************************************
.CSEG
.ORG 0x00    ; Startadress 0x00 - Här börjar programmet.
   RJMP main ; Hoppar till subrutinen main.

;********************************************************************************
;* main: Initierar I/O-portarna vid start. Programmet hålls sedan igång
;*       kontinuerligt så länge matningsspänning tillförs. Vid nedtryckning
;*       av tryckknappen tänds lysdioden, annars hålls den släckt.
;********************************************************************************
main:

;********************************************************************************
;* setup: Initierar mikrodatorns I/O-portar.
;********************************************************************************
setup:
   LDI R16, (1 << LED1)    ; Läser in (1 << LED1) = 0000 0001 i CPU-register R16.
   OUT DDRB, R16           ; Skriver innehållet till datariktningsregister DDRB.
   LDI R16, (1 << BUTTON1) ; Läser in (1 << BUTTON1) = 0010 0000 i CPU-register R16.
   OUT PORTB, R16          ; Skriver innehållet till dataregister PORTB.

;********************************************************************************
;* main_loop: Håller igång programmet så länge matningsspänning tillförs.
;********************************************************************************
main_loop:                
   IN R16, PINB             ; Läser insignaler från PINB till CPU-register R16.
   ANDI R16, (1 << BUTTON1) ; Nollställer alla bitar förutom tryckknappens.
   BRNE call_led1_blink     ; Om tryckknappen är nedtryckt blinkas lysdioden.
   CALL led1_off            ; Annars hålls lysdioden släckt.
   RJMP main_loop_end       ; Återstartar loopen i main.
call_led1_blink:            
   CALL led1_blink          ; Blinkar lysdioden med en blinkhastighet på 100 ms.
main_loop_end:              
   RJMP main_loop           ; Återstartar loopen i main.

;********************************************************************************
;* led1_on: Tänder lysdioden. 
;********************************************************************************
led1_on:
   IN R16, PORTB        ; Läser in data från PORTB.
   ORI R16, (1 << LED1) ; Ettställer lysdiodens bit, övriga bitar opåverkade.
   OUT PORTB, R16       ; Skriver tillbaka det uppdaterade innehållet.
   RET                  ; Avslutar subrutinen, hoppar till återhoppsadressen.

;********************************************************************************
;* led1_off: Släcker lysdioden.
;********************************************************************************
led1_off:
   IN R16, PORTB          ; Läser in data från PORTB.
   ANDI R16, ~(1 << LED1) ; Nollställer lysdiodens bit, övriga bitar opåverkade.
   OUT PORTB, R16         ; Skriver tillbaka det uppdaterade innehållet.
   RET                    ; Avslutar subrutinen, hoppar till återhoppsadressen.

;********************************************************************************
;* led1_blink: Blinkar lysdioden med 100 millisekunds blinkhastighet.
;********************************************************************************
led1_blink:
   CALL led1_on     ; Tänder lysdioderna.
   CALL delay_100ms ; Genererar 100 millisekunders fördröjning.
   CALL led1_off    ; Släcker lysdioderna.
   CALL delay_100ms ; Genererar 100 millisekunders fördröjning.
   RET              ; Avslutar subrutinen, genomför återhopp.

;********************************************************************************
;* delay_100ms: Genererar 100 millisekunders fördröjning via uppräkning med
;*              CPU-register R16 - R18. Innan uppräkningen startar sparas
;*              tidigare innehåll undan på stacken.
;********************************************************************************
delay_100ms:
   PUSH R16              ; Sparar undan innehållet från CPU-register R16 på stacken.
   PUSH R17              ; Sparar undan innehållet från CPU-register R17 på stacken.
   PUSH R18              ; Sparar undan innehållet från CPU-register R18 på stacken.
   LDI R16, 0x00         ; Nollställer R16 inför uppräkning i for-satsen.
   LDI R17, 0x00         ; Nollställer R16 inför uppräkning i for-satsen.
   LDI R18, 0x00         ; Nollställer R16 inför uppräkning i for-satsen.
delay_100ms_loop:        ; Loop som räknar från 0 till 255 x 255 x 5.
   INC R16               ; Räknar upp från 0 - 255.
   CPI R16, 255          ; Jämför R16 mot värdet 255.
   BRLO delay_100ms_loop ; Så länge R16 är mindre än 255 upprepas loopen.
   LDI R16, 0x00         ; Nollställer R16 inför nästa uppräkning.
   INC R17               ; Räknar upp R17 efter att R16 har räknat upp till 255.
   CPI R17, 255          ; Jämför R17 mot värdet 255.
   BRLO delay_100ms_loop ; Så länge R17 är mindre än 255 upprepas loopen från början.
   LDI R17, 0x00         ; Nollställer R17 inför nästa uppräkning.
   INC R18               ; Räknar upp R18 efter att R16 - R17 har räknat upp till 255 x 255.
   CPI R18, 5            ; Jämför R18 mot värdet 5.
   BRLO delay_100ms_loop ; Så länge R17 är mindre än 5 upprepas loopen från början.
delay_100ms_end:         ; Återställer CPU-register innan återhopp.
   POP R18               ; Lägger tillbaka innehållet lagrat på stacken i CPU-register R18.
   POP R17               ; Lägger tillbaka innehållet lagrat på stacken i CPU-register R17.
   POP R16               ; Lägger tillbaka innehållet lagrat på stacken i CPU-register R16.
   RET                   ; Avslutar subrutin, genomför återhopp till lagrad återhoppsadress.

