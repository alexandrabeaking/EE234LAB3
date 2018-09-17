.text
.global main @ start with main function

.set MYLED_BASEADDR, 0x4BB00000

initialize_PWM_clk:
    MOVw r1, #0x000 	@ Let r1 = 0x000
    STR r1, [r0] 	@ store r1 in r0  (disable all LEDs and disable PWM mode)
    MOVw r1, #0x00C 	@ Let r1 = 0x00C
    STR r1, [r0, #0x08] @ store r1 in r0+0x08 (set PWM counter clock division value to 12 == 4.16666Mhz)
    bx lr 		@ return to the calling function
enable_LED:
    MOVw r1, #0x1F 	@ Let r1 = 0x1F
    STR r1, [r0] 	@ store r1 in r0 (enable all LEDs, nable PWM mode)
    bx lr 		@ return to the calling function
initialize_PWM_PRD:
/*LED1*/
    MOVw r1, #10000 	@ Let r1 = 10000
    STR r1, [r0, #0x1C] @ store r1 in r0+0x1C (define PWM period value as 1000 for LED 1)
    STR r1, [r0, #0x20]
    STR r1, [r0, #0x24]
    STR r1, [r0, #0x28]
    bx lr 		@ return to the calling function
initialize_PWM_DC:
/*LED1*/
    MOVw r1, #0 	@ Let r1 = 0
    STR r1, [r0, #0x0C] @ store r1 in r0+0x0C (initialize PWM Duty Cycle as 0 for LED1)
    bx lr 		@ return to the calling function
set_PWM_DC:
    STR r1, [r0, #0x0C]	@ store r1 in r0+0x0C
    STR r1, [r0, #0x10]
    STR r1, [r0, #0x14]
    STR r1, [r0, #0x18]
    bx lr 		@ return to the calling function
set_delay:
    SUBS r4, r4, #1	@ decrement r4 until r4 ==0
    BNE set_delay
	bx lr

main:

   /*Iniitialize IP blocks and needed variables */

    LDR r0, =MYLED_BASEADDR 	@ Load MYLED baseaddress into r0
    bl initialize_PWM_clk 	@ call function enable_PWM_clk
    bl enable_LED 		@ call function enable_LEDS
    bl initialize_PWM_PRD 	@ call function initialize_PWM_PRD
    bl initialize_PWM_DC 	@ call function initialize_PWM_DC

    MOV r2, #1000 		@ r2 holds max pulse width
    MOV r1, #0			@ r1 holds current pulse width
    MOVw r3, #0xFFFF		@ r3 holds loop delay count
    MOVt r3, #0x000F

   /*Create an always loop to ramp up LED1*/

led_loop:
    bl set_PWM_DC		@ Pass r1 to set pulse width
    MOV r4, r3
    bl set_delay		@ Pass r4 to delay loop
    ADDS r1, r1, #1	 	@ inc r1
    CMP r1, r2
    BNE led_loop 		@ restart loop when r1==r2
    MOV r1, #0			@ reset r1 to 0 and restart loop
    b led_loop
.end





