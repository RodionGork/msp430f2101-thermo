# msp430f2101-t-meter

We use 1 kOhm sensor (KTY81/120) - it is attached between P1.0 and CA0.

Standard 1 kOhm resistor is attached between P1.2 and CA0 - and from CA0 to
GND we have 10 uF capacitor.

Resistance is measured with analog comparator and timer. Printed to UART.