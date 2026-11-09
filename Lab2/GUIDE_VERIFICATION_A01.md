# CEG 3536 — Lab 2 Groupe 9 — guide de vérification (version de travail)

**Important** : code préparé avec le code Lab 1 et le complément officiel Lab 2. Compilation croisée de contrôle (Clang ARM + lld avec adaptation d'un script de validation) effectuée, **pas de test effectué sur STM32CubeIDE/ST-LINK/Leafy**. Ne pas écrire « T1–T10 réussi » sans mesures réelles. Le fichier STM32L552ZETXQ_FLASH.ld d'origine du projet a été conservé tel quel.

## Import STM32CubeIDE
1. Dézipper l'archive ; ouvrir File > Import > Existing Projects into Workspace, choisir CEG3536_Lab2_Groupe9.
2. Project > Clean puis Project > Build. Transmettre toute erreur de compilation au partenaire.
3. Alimenter la Nucleo via CN1 ST-LINK et vérifier la carte avant d'alimenter le moteur 12 V.
4. Debug > SFRs : TIM1 (CR1, CCMR1, CCER, PSC, ARR, CCR1, BDTR), SysTick (CTRL, LOAD, VAL), GPIOB et GPIOE (ODR).
5. Live Expressions : etat, consigne_pct, pwm_pct, ticks_ms, enc_count, vitesse_fronts, sens_mesure, estop_flag, buzzer_continu, compteur_transitions.

## Critères de passage / calculs théoriques
- Reset : etat=0, PWM CCR1=0, AI1 PB10=0, AI2 PB11=0, STB PE15=0, PA9 rouge=1, PA0 buzzer=0.
- TIM1 : PSC=0, ARR=199, CR1=0x81, CCMR1=0x68, CCER=1, BDTR bit 15=1 ; f_PWM=4MHz/200=20kHz.
- CCR1 après rampe : 25%=50, 50%=100, 75%=150, 100%=200.
- SysTick : LOAD=3999=0xF9F, CTRL=0x7 (+COUNTFLAG possible), SHPR3 priorité SysTick = 0x40.
- Rampes : 1 point / 10 ms = 0 vers 100 % en 1000 ms ; retour 100 vers 25 % en 750 ms.
- Encodeur : 748 fronts par tour de sortie (2 × 11 × 34); 500 ms : tr/min = fronts × 120/748. Il faut valider la polarité ENC_SENS_INVERSE sur le moteur réel.
- Buzzer : PA0=1 pendant 100 ms pour un bip et 100 ms de silence entre deux bips.
- E-Stop : EXT2 priorité 0 doit couper CCR1 et STB dans l'ISR; urgence rouge 2 Hz et son continu. Acquittement uniquement Touch En avec E-Stop relâché.
- Aucune écriture dans les cases « valeurs mesurées » du JOURNAL.md sans capture du débogueur.

## Ordre des tests réels (exigé par l'énoncé v1.3)
1. Avant alimentation moteur : E1 (reset), E10 (tick), confirmer E-Stop (ISR) et les états sûrs.
2. Alimentation moteur seulement lorsque le banc est sécurisé, arbre dégagé et arrêt d'urgence validé.
3. T2 : cycle User et GPIOB/E ODR ; T3 : 25/50/75/100 ; T4 : montée/descente par ticks_ms.
4. T5/T6 : encoder et comparaison des deux sens, aux quatre paliers.
5. T7 : E-Stop à 100 % et pendant rampe ; point d'arrêt juste après motor_stop_now, capturer CCR1 et GPIOE ODR.
6. T8/T9 : acquittement, buzzer, rouge 2Hz ; T10 : mesure sur 10 s et appuis simultanés.
7. Sauvegarder les captures dans preuves/ et compléter JOURNAL.md.

## Points matériels non encore confirmés
- Polarités BTN_ESTOP_ACTIF_HAUT et BTN_TOUCH_ACTIF_HAUT et rappels PUPDR.
- ENC_SENS_INVERSE (sens d'impulsions du moteur réel) et ENC_PUPDR.
- Mesures de fréquence, état des registres, E-Stop, bips, nombre d'impulsions.
- Rôle de `prochain_sens` en cas d'acquittement et commande sûre du moteur.

## Sources
Énoncé de Laboratoire 2 v1.3 (13 oct. 2026), complément officiel CEG3536_Lab2_Complement.zip ; projet équipe Lab1_Salim_Ilies.zip. Assistance ChatGPT GPT-6 pour intégrer les routines et proposer les vérifications : déclarer dans rapport conformément à la section 4.1/7.
