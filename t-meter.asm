; for MSP430F2101

.include "msp430x2xx.inc"

.entry_point start

BAUD_RATE equ 9600

CALDCO_1MHZ equ 10FEh
CALBC1_1MHZ equ 10FFh
RAM_START equ 200h
RAM_SIZE equ 128
CACTL1 equ 59h
CACTL2 equ 5Ah
CAPD equ 5Bh

.org 0F800h
start:
    mov.w #WDTPW|WDTHOLD, &WDTCTL
    mov.w #(RAM_START + RAM_SIZE), SP
    mov.b &CALBC1_1MHZ, &BCSCTL1
    mov.b &CALDCO_1MHZ, &DCOCTL
    mov.b #2, &P1OUT
    mov.b #2, &P1DIR
    mov.b #10h, &P2DIR

    mov.b #68h, &CACTL1
    mov.b #04h, &CACTL2
    mov.b #01h, &CAPD
repeat:
    mov.b #10h, &P2OUT
    mov.w #1000, r8
    call #DELAY
    mov.b #00h, &P2OUT
    mov.w #2E0h, &TACTL
    wait_cap:
    bit.b #1, &CACTL2
    jnz wait_cap
    mov.w #0, &TACTL
    mov.w &TAR, r8
    call #UART_SEND_H4
    mov.b #13, r8
    call #UART_SEND
    mov.b #10, r8
    call #UART_SEND
    jmp repeat

;=======================
; sends hex char from r8
UART_SEND_H1:
    push r8
    bic.b #0F0h, r8
    add.b #'0', r8
    cmp.b #('9' + 1), r8
    jn uart_send_h_dec
    add.b #('A'-'0'-10), r8
    uart_send_h_dec:
    call #UART_SEND
    pop r8
    ret

;=======================
; sends hex byte from r8
UART_SEND_H2:
    push r8
    rra r8
    rra r8
    rra r8
    rra r8
    call #UART_SEND_H1
    pop r8
    call #UART_SEND_H1
    ret

;=======================
; sends hex byte from r8
UART_SEND_H4:
    swpb r8
    call #UART_SEND_H2
    swpb r8
    call #UART_SEND_H2
    ret

;========================
; sends character from r8
UART_SEND:
    push r8
    push r10
    mov.w #(1000000 / BAUD_RATE - 1), &TACCR0
    mov.w #210h, &TACTL
    bic.w #0FE00h, r8
    bis.w #100h, r8
    rla.w r8
    
    uart_send_rep:
    and.b #1, &TACCTL0
    jz uart_send_rep
    mov.b #0, &TACCTL0
    
    mov.b r8, r10
    and.b 1, r10
    add.b r10, r10
    mov.b r10, &P1OUT
    
    rra.w r8
    jnz uart_send_rep
    
    mov.w #0, &TACTL
    pop r10
    pop r8
    ret

;============================
; delay for (R8) milliseconds
DELAY:
    push r8
    push r9
    delay_rep0:
    mov.w #358, r9
    delay_rep:
    dec.w r9
    jnz delay_rep
    dec.w r8
    jnz delay_rep0
    pop r9
    pop r8
    ret    

.org 0FFFEh
  dw start
