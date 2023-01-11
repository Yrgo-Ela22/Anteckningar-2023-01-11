;/********************************************************************************
;* demo.asm: Demonstration av ett grundläggande assemblerprogram för mikrodator 
;*           ATmega328P, där en lysdiod ansluten till pin 8 (PORTB0) tänds vid
;*           nedtryckning av en tryckknapp ansluten till pin 13 (PORTB5).
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
;*              LDI (Load Immediate)      : Läser in konstant i ett CPU-register.
;*              OUT (Write to I/O)        : Skriver till ett I/O-register.
;*              IN (Read from I/O)        : Läser från ett I/O-register.
;*              ANDI (And Immediate)      : Bitvis multiplikation med en konstant.
;*              ORI (Or Immediate)        : Bitvis addition med en konstant.
;*              BRNE (Branch If Not Equal): Om resultatet av föregående beräkning
;*                                          inte blev noll sker programhopp till
;*                                          till angiven adress.        
;********************************************************************************/

; Makrodefinitioner:
.EQU LED1    = PORTB0 ; Lysdiod 1 ansluten till pin 8 (PORTB0).              
.EQU BUTTON1 = PORTB5 ; Tryckknapp 1 ansluten till pin 13 (PORTB5). 

;/********************************************************************************
;* .CSEG: Här lagras programkoden.
;********************************************************************************/
.CSEG
.ORG 0x00    ; Startadress 0x00 i programminnet.
   RJMP main ; Vi hoppar till subrutinen main för att starta programmet.

;/********************************************************************************
;* main: Initierar systemet vid start.
;********************************************************************************/
main:
   LDI R16, (1 << LED1)    ; Skriver värdet 0000 0001 till CPU-register R16.
   OUT DDRB, R16           ; Sätter lysdioden till utport.
   LDI R16, (1 << BUTTON1) ; Skriver värdet 0010 0000 till CPU-register R16.
   OUT PORTB, R16          ; Aktiverar den interna pullup-resistorn på knappens pin.

;/********************************************************************************
;* main_loop: Kontinuerlig loop, motsvarar en while-sats i main.
;********************************************************************************/
main_loop:                  ; Kontinuerlig loop.
   IN R16, PINB             ; Läser in insignalerna från PINB till CPU-register R16.
   ANDI R16, (1 << BUTTON1) ; Nollställer alla bitar förutom tryckknappens.
   BRNE led1_on             ; Om resultatet ej är lika med noll tänds lysdioden.
   RJMP led1_off            ; Annars släcks lysdioden.

;/********************************************************************************
;* led1_on: Tänder lysdioden och återstartar loopen i subrutinen main.
;********************************************************************************/
led1_on:
   IN R16, PORTB        ; Läser in nuvarande signaler från dataregister PORTB.
   ORI R16, (1 << LED1) ; Ettställer lysdiodens bit.
   OUT PORTB, R16       ; Skriver tillbaka värdet till dataregister PORTB.
   RJMP main_loop       ; Återstartar loopen i main.

;/********************************************************************************
;* led1_off: Släcker lysdioden och återstartar loopen i subrutinen main.
;********************************************************************************/
led1_off:
   IN R16, PORTB          ; Läser in nuvarande signaler från dataregister PORTB.
   ANDI R16, ~(1 << LED1) ; Nollställer lysdiodens bit.
   OUT PORTB, R16         ; Skriver tillbaka värdet till dataregister PORTB.
   RJMP main_loop         ; Återstartar loopen i main.