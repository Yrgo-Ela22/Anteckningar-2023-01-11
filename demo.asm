;/********************************************************************************
;* demo.asm: Demonstration av ett grundl�ggande assemblerprogram f�r mikrodator 
;*           ATmega328P, d�r en lysdiod ansluten till pin 8 (PORTB0) t�nds vid
;*           nedtryckning av en tryckknapp ansluten till pin 13 (PORTB5).
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
;*              LDI (Load Immediate)      : L�ser in konstant i ett CPU-register.
;*              OUT (Write to I/O)        : Skriver till ett I/O-register.
;*              IN (Read from I/O)        : L�ser fr�n ett I/O-register.
;*              ANDI (And Immediate)      : Bitvis multiplikation med en konstant.
;*              ORI (Or Immediate)        : Bitvis addition med en konstant.
;*              BRNE (Branch If Not Equal): Om resultatet av f�reg�ende ber�kning
;*                                          inte blev noll sker programhopp till
;*                                          till angiven adress.        
;********************************************************************************/

; Makrodefinitioner:
.EQU LED1    = PORTB0 ; Lysdiod 1 ansluten till pin 8 (PORTB0).              
.EQU BUTTON1 = PORTB5 ; Tryckknapp 1 ansluten till pin 13 (PORTB5). 

;/********************************************************************************
;* .CSEG: H�r lagras programkoden.
;********************************************************************************/
.CSEG
.ORG 0x00    ; Startadress 0x00 i programminnet.
   RJMP main ; Vi hoppar till subrutinen main f�r att starta programmet.

;/********************************************************************************
;* main: Initierar systemet vid start.
;********************************************************************************/
main:
   LDI R16, (1 << LED1)    ; Skriver v�rdet 0000 0001 till CPU-register R16.
   OUT DDRB, R16           ; S�tter lysdioden till utport.
   LDI R16, (1 << BUTTON1) ; Skriver v�rdet 0010 0000 till CPU-register R16.
   OUT PORTB, R16          ; Aktiverar den interna pullup-resistorn p� knappens pin.

;/********************************************************************************
;* main_loop: Kontinuerlig loop, motsvarar en while-sats i main.
;********************************************************************************/
main_loop:                  ; Kontinuerlig loop.
   IN R16, PINB             ; L�ser in insignalerna fr�n PINB till CPU-register R16.
   ANDI R16, (1 << BUTTON1) ; Nollst�ller alla bitar f�rutom tryckknappens.
   BRNE led1_on             ; Om resultatet ej �r lika med noll t�nds lysdioden.
   RJMP led1_off            ; Annars sl�cks lysdioden.

;/********************************************************************************
;* led1_on: T�nder lysdioden och �terstartar loopen i subrutinen main.
;********************************************************************************/
led1_on:
   IN R16, PORTB        ; L�ser in nuvarande signaler fr�n dataregister PORTB.
   ORI R16, (1 << LED1) ; Ettst�ller lysdiodens bit.
   OUT PORTB, R16       ; Skriver tillbaka v�rdet till dataregister PORTB.
   RJMP main_loop       ; �terstartar loopen i main.

;/********************************************************************************
;* led1_off: Sl�cker lysdioden och �terstartar loopen i subrutinen main.
;********************************************************************************/
led1_off:
   IN R16, PORTB          ; L�ser in nuvarande signaler fr�n dataregister PORTB.
   ANDI R16, ~(1 << LED1) ; Nollst�ller lysdiodens bit.
   OUT PORTB, R16         ; Skriver tillbaka v�rdet till dataregister PORTB.
   RJMP main_loop         ; �terstartar loopen i main.