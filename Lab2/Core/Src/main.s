/* CEG 3536 Laboratoire 2 — Groupe 9 : boucle SysTick non bloquante. */
#include "registres.inc"
#include "registres_lab2.inc"
    .syntax unified
    .cpu cortex-m33
    .thumb
    .text
    .align 2
    .global SystemInit
    .type SystemInit, %function
SystemInit:
    bx lr                       /* MSI 4 MHz, horloge de reset. */
    .size SystemInit, .-SystemInit
    .global main
    .type main, %function
main:
    bl gpio_init
    bl buzzer_init
    bl motor_init              /* toujours CCR1 = 0 et STB = 0 initialement */
    bl encoder_init
    bl estop_init
    ldr r0, =SYSTICK_PERIODE_US
    bl systick_init
    bl fsm_init
boucle_principale:
    ldr r0, =tick_1ms
    ldr r1, [r0]
    cmp r1, #0
    beq boucle_principale
    movs r1, #0
    str r1, [r0]
    bl fsm_step
    b boucle_principale
    .size main, .-main
s
