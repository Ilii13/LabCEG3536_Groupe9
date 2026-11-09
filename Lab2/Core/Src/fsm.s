/* CEG3536 Lab 2, Groupe 9 — FSM 1 pas / ms, sans attente bloquante.
 * L'ISR EXTI2 met immediatement le moteur en securite. Cette FSM enregistre
 * l'urgence, traite les boutons et pilote les rampes, DEL et bips.
 */
#include "registres.inc"
#include "registres_lab2.inc"
    .syntax unified
    .cpu cortex-m33
    .thumb

    .bss
    .align 2
    .global etat
etat:                   .space 4
    .global touch_enabled
touch_enabled:          .space 4   /* maintenu pour interface Lab1, inutilise */
    .global compteur_transitions
compteur_transitions:   .space 4
    .global consigne_pct
consigne_pct:           .space 4
    .global pwm_pct
pwm_pct:                .space 4
clignote_compteur:      .space 4
clignote_phase:         .space 4
prochain_sens:          .space 4
rampe_compteur:         .space 4
fenetre_compteur:       .space 4

    .section .rodata
etat_vers_del:
    .byte LED_ROUGE, LED_VERTE, LED_BLEUE, LED_ROUGE
    .text
    .align 2

    .global fsm_init
    .type fsm_init, %function
fsm_init:
    push    {r4, lr}
    movs    r1, #0
    ldr     r0, =etat
    str     r1, [r0]
    ldr     r0, =touch_enabled
    str     r1, [r0]
    ldr     r0, =compteur_transitions
    str     r1, [r0]
    ldr     r0, =pwm_pct
    str     r1, [r0]
    ldr     r0, =rampe_compteur
    str     r1, [r0]
    ldr     r0, =fenetre_compteur
    str     r1, [r0]
    ldr     r0, =clignote_compteur
    str     r1, [r0]
    ldr     r0, =clignote_phase
    str     r1, [r0]
    ldr     r0, =prochain_sens
    str     r1, [r0]
    ldr     r0, =consigne_pct
    movs    r1, #CONSIGNE_INITIALE
    str     r1, [r0]
    /* E1 : au reset, rouge mais aucun bip. */
    movs    r0, #LED_ROUGE
    bl      led_set
    pop     {r4, pc}
    .size fsm_init, .-fsm_init

    .global fsm_step
    .type fsm_step, %function
fsm_step:
    push    {r4, r5, r6, lr}
    /* A : consommer une urgence capturee par l'ISR. */
    ldr     r0, =estop_flag
    ldr     r1, [r0]
    cbz     r1, fsm_lire_boutons
    movs    r1, #0
    str     r1, [r0]
    bl      motor_stop_now
    ldr     r0, =pwm_pct
    movs    r1, #0
    str     r1, [r0]
    ldr     r0, =rampe_compteur
    str     r1, [r0]
    ldr     r0, =etat
    movs    r1, #ETAT_ARRET_URGENCE
    str     r1, [r0]
    ldr     r0, =clignote_compteur
    movs    r1, #0
    str     r1, [r0]
    ldr     r0, =clignote_phase
    movs    r1, #1
    str     r1, [r0]
    ldr     r0, =buzzer_continu
    str     r1, [r0]
fsm_lire_boutons:
    /* Lire les deux boutons chaque milliseconde, meme en urgence. */
    movs    r0, #BTN_USER
    bl      button_pressed
    mov     r4, r0
    movs    r0, #BTN_TOUCH
    bl      button_pressed
    mov     r5, r0
    ldr     r0, =etat
    ldr     r6, [r0]
    cmp     r6, #ETAT_ARRET_URGENCE
    beq     fsm_urgence

    /* B : Touch hors urgence fait tourner 25/50/75/100, jamais 0. */
    cbz     r5, fsm_traiter_user
    ldr     r0, =consigne_pct
    ldr     r1, [r0]
    adds    r1, r1, #CONSIGNE_PAS
    cmp     r1, #CONSIGNE_MAX
    bls     fsm_consigner
    movs    r1, #CONSIGNE_MIN
fsm_consigner:
    str     r1, [r0]
    movs    r0, #1
    bl      buzzer_bip
fsm_traiter_user:
    cbz     r4, fsm_sorties
    cmp     r6, #ETAT_ARRET
    bne     fsm_user_stop
    ldr     r0, =prochain_sens
    ldr     r1, [r0]
    cmp     r1, #0
    bne     fsm_user_arriere
    movs    r0, #ETAT_MARCHE_AVANT
    bl      fsm_entree_etat
    cbnz    r0, fsm_sorties
    ldr     r0, =prochain_sens
    movs    r1, #1
    str     r1, [r0]
    b       fsm_sorties
fsm_user_arriere:
    movs    r0, #ETAT_MARCHE_ARRIERE
    bl      fsm_entree_etat
    cbnz    r0, fsm_sorties
    ldr     r0, =prochain_sens
    movs    r1, #0
    str     r1, [r0]
    b       fsm_sorties
fsm_user_stop:
    movs    r0, #ETAT_ARRET
    bl      fsm_entree_etat
    b       fsm_sorties

fsm_urgence:
    /* User et changements de consigne ignores. */
    cbz     r5, fsm_sorties
    movs    r0, #BTN_ESTOP
    bl      button_raw
    cbnz    r0, fsm_sorties        /* maintien E-Stop : acquittement refuse */
    movs    r1, #0
    ldr     r0, =buzzer_continu
    str     r1, [r0]
    movs    r0, #0
    bl      buzzer_set            /* arrete le son continu tout de suite */
    movs    r0, #ETAT_ARRET
    bl      fsm_entree_etat       /* bip d'entree dans l'etat ARRET */
fsm_sorties:
    bl      fsm_maj_sorties
    pop     {r4, r5, r6, pc}
    .size fsm_step, .-fsm_step

/* Entree dans un des 3 etats normaux ; r0=etat.
 * motor_set_dir refuse un changement de sens lorsque CCR1 !=0.
 * Retour 0 si transition acceptee ; 1 sinon.
 */
    .type fsm_entree_etat, %function
fsm_entree_etat:
    push    {r4, lr}
    mov     r4, r0
    /* Les codes ETAT_{ARRET,AVANT,ARRIERE}=MOTOR_{ARRET,AVANT,ARRIERE}. */
    bl      motor_set_dir
    cbnz    r0, fsm_entree_refus
    ldr     r0, =etat
    str     r4, [r0]
    ldr     r0, =compteur_transitions
    ldr     r1, [r0]
    adds    r1, r1, #1
    str     r1, [r0]
    movs    r1, #0
    ldr     r0, =pwm_pct
    str     r1, [r0]
    ldr     r0, =rampe_compteur
    str     r1, [r0]
    cmp     r4, #ETAT_MARCHE_ARRIERE
    ite     eq
    moveq   r0, #2
    movne   r0, #1
    bl      buzzer_bip
    movs    r0, #0
    pop     {r4, pc}
fsm_entree_refus:
    movs    r0, #1
    pop     {r4, pc}
    .size fsm_entree_etat, .-fsm_entree_etat

/* E6 : fenetre encodeur 500ms ; E4 : rampe 10ms ; E8 : clignotement
 * 250ms ; E9 : bip non bloquant. Seul endroit qui appelle led_set et
 * motor_set_pwm, pilote les sorties par etat et compteurs.
 */
    .type fsm_maj_sorties, %function
fsm_maj_sorties:
    push    {r4, lr}
    /* Une mesure de vitesse toutes les 500 ms, dans tous les etats. */
    ldr     r0, =fenetre_compteur
    ldr     r1, [r0]
    adds    r1, r1, #1
    cmp     r1, #FENETRE_VITESSE_MS
    blo     fsm_fenetre_retenir
    movs    r1, #0
    str     r1, [r0]
    ldr     r0, =sens_mesure
    bl      encoder_read
    b       fsm_fenetre_fin
fsm_fenetre_retenir:
    str     r1, [r0]
fsm_fenetre_fin:
    ldr     r0, =etat
    ldr     r4, [r0]
    cmp     r4, #ETAT_ARRET_URGENCE
    beq     fsm_sorties_urgence
    /* En marche, atteindre la consigne par pas de 1 pourcent/10ms. */
    cmp     r4, #ETAT_ARRET
    beq     fsm_sorties_led_normal
    ldr     r0, =rampe_compteur
    ldr     r1, [r0]
    adds    r1, r1, #1
    cmp     r1, #RAMPE_PAS_MS
    blo     fsm_rampe_retenir
    movs    r1, #0
    str     r1, [r0]
    ldr     r0, =pwm_pct
    ldr     r1, [r0]
    ldr     r2, =consigne_pct
    ldr     r2, [r2]
    cmp     r1, r2
    beq     fsm_sorties_led_normal
    blo     fsm_rampe_monter
    subs    r1, r1, #1
    b       fsm_rampe_appliquer
fsm_rampe_monter:
    adds    r1, r1, #1
fsm_rampe_appliquer:
    str     r1, [r0]
    /* L'ISR E-Stop a toujours priorite sur cette rampe. */
    ldr     r0, =estop_flag
    ldr     r0, [r0]
    cbnz    r0, fsm_sorties_led_normal
    mov     r0, r1
    bl      motor_set_pwm
    b       fsm_sorties_led_normal
fsm_rampe_retenir:
    str     r1, [r0]
fsm_sorties_led_normal:
    ldr     r0, =etat_vers_del
    ldrb    r0, [r0, r4]
    bl      led_set
    b       fsm_sorties_buzzer
fsm_sorties_urgence:
    ldr     r0, =clignote_compteur
    ldr     r1, [r0]
    adds    r1, r1, #1
    cmp     r1, #CLIGNOTEMENT_DEMI_MS
    blo     fsm_clignote_retenir
    movs    r1, #0
    str     r1, [r0]
    ldr     r0, =clignote_phase
    ldr     r1, [r0]
    eor     r1, r1, #1
    str     r1, [r0]
    b       fsm_clignote_afficher
fsm_clignote_retenir:
    str     r1, [r0]
fsm_clignote_afficher:
    ldr     r0, =clignote_phase
    ldr     r0, [r0]
    cmp     r0, #0
    ite     eq
    moveq   r0, #LED_AUCUNE
    movne   r0, #LED_ROUGE
    bl      led_set
fsm_sorties_buzzer:
    bl      buzzer_step
    pop     {r4, pc}
    .size fsm_maj_sorties, .-fsm_maj_sorties
