# JOURNAL.md — Journal d’équipe, CEG 3536, laboratoire 2 (automne 2026)

**Équipe** : Ilies Allal, Salim Allal, Océane Randrianelson  
**Section** : A01, groupe 9  
**Dépôt Git : https://github.com/Ilii13/LabCEG3536_Groupe9.git

## Suivi du jalon J1

| Laboratoire | Échéancier prévu (J1) | Déroulement réel | Écart et cause | Ajustement pour les laboratoires 3 à 5 |
|---|---|---|---|---|
| 1 | Remise prévue le 9 octobre 2026. | Le programme et le rapport du laboratoire 1 ont été préparés. | Aucun écart signalé. | Garder les résultats des essais au même endroit. |
| 2 | Séances A01 les 16 et 23 octobre. Démonstration prévue à la deuxième séance et remise annoncée pour le 2 novembre. | Le programme et le rapport ont été préparés. Des captures ont été prises pour les essais du moteur. | Aucun écart d’échéancier signalé. Certaines mesures et preuves restent à ajouter. | Noter les valeurs pendant les essais et nommer les captures et les vidéos avec le numéro de l’essai. |

## Rôles et rotation

Ilies s’est occupé du codage, Salim des essais et Océane de la rédaction du rapport. Les trois ont participé à la vérification des résultats. La rotation des rôles par séance n’a pas été notée.

| Séance prévue | Réalise | Valide (essais, mesures, relecture) | Périphérique configuré ou mesuré par chacun |
|---|---|---|---|
| Séance 1 — 16 octobre | Ilies : codage. | Salim : essais. Océane : rédaction. Vérification des résultats en équipe. | Répartition par périphérique non notée. |
| Séance 2 — 23 octobre | Ilies : codage. | Salim : essais. Océane : rédaction. Vérification des résultats en équipe. | Répartition par périphérique non notée. |

## Calculs préalables (avant la séance 1)

| Grandeur | Formule | Valeur | Vérifiée par (essai) |
|---|---|---|---|
| `PWM_PSC`, `PWM_ARR` | f = 4 000 000 / [(PSC + 1) × (ARR + 1)] | PSC = 0, ARR = 199. Fréquence calculée : 20 kHz. | T3, à partir des registres |
| `CCR1` pour 25, 50, 75 et 100 % | CCR1 = consigne × (ARR + 1) / 100 | 50, 100, 150 et 200 | T3 |
| `SYSTICK_LOAD_1MS` | 4 000 000 × 0,001 − 1 | 3 999 | T10, mesure à compléter |
| Fronts par tour de l’arbre de sortie | 2 × 11 × 34 | 748 fronts par tour | T5, valeur théorique |
| Vitesse à partir de `vitesse_fronts` | Nombre de fronts en valeur absolue × 120 / 748, sur 500 ms | Environ 0,16 tr/min par front | T6 |
| Fronts attendus à 100 %, sur 500 ms | 350 × 748 / 120 | Environ 2 182 fronts par fenêtre, soit 4 363 fronts par seconde à la vitesse de référence | T5 et T6 |

## Journal des séances

Les dates ci-dessous sont celles prévues pour la section A01. Les captures ne permettent pas de dater chaque mesure.

### Séance 1 — 16 octobre 2026

- **Objectifs** : reprendre le code du laboratoire 1, ajouter la commande du moteur et préparer les premiers essais de PWM.
- **Fait** : le projet contient la PWM sur TIM1, la base de temps SysTick et les commandes de marche avant, de marche arrière et d’arrêt.
- **Décisions** : dans le code, la marche avant correspond à AI1 = 1 et AI2 = 0. Le buzzer est commandé sur PA0 et un bip est réglé à 100 ms. La constante `ENC_SENS_INVERSE` vaut 0 dans le projet. La correspondance avec le sens mesuré reste à vérifier sur le moteur.
- **Difficultés et solutions** : les réglages de la PWM peuvent être vérifiés avec les registres. Pour SysTick et le buzzer, il faut aussi relever la durée pour confirmer le résultat.
- **Mesures** : les quatre valeurs de CCR1 ont été relevées dans les captures T3. La période de SysTick et la durée des bips restent à mesurer.
- **Validations Git** : Ilies.

### Séance 2 — 23 octobre 2026

- **Objectifs** : terminer les essais du moteur et vérifier la rampe, l’encodeur et l’arrêt d’urgence.
- **Fait** : les captures du laboratoire montrent le cycle du bouton User, plusieurs points de la rampe et la coupure du moteur par E-Stop.
- **Décisions** : calculer la vitesse à partir du nombre de fronts sur 500 ms. Utiliser `sens_mesure` pour vérifier le sens de rotation.
- **Difficultés et solutions** : les captures ne montrent pas la descente de 100 % à 25 %. Il faut reprendre un relevé de `pwm_pct` et de `ticks_ms` au début et à la fin de cette descente.
- **Mesures** : la vitesse augmente avec la consigne dans les relevés en marche avant. Pour E-Stop, les captures montrent la coupure de la commande. Le délai reste à mesurer.
- **Validations Git** : Ilies.
## Tableau des mesures (composante L2-A)

| Mesure | Exigence | Valeur mesurée ou calculée | Incertitude / méthode | Écart | Cause | Preuve (fichier) |
|---|---|---|---|---|---|---|
| Fréquence PWM | 20 kHz , 5 % | 20 kHz calculés | PSC = 0, ARR = 199, horloge nominale de 4 MHz | 0 kHz sur le calcul | La fréquence réelle n’a pas été mesurée. | `T3_25.PNG`, `T3_50.PNG`, `T3_75.PNG`, `T3_100.PNG` |
| Rapports cycliques | 25, 50, 75 et 100 %, à , 2 points | 25, 50, 75 et 100 % calculés | CCR1 / (ARR + 1). Un compte de CCR1 vaut 0,5 point. | 0 point aux quatre paliers | Les valeurs de CCR1 correspondent aux consignes. | Captures T3 |
| Rampe montante | De 0 à 100 % en 1 s , 10 % | 999 ticks de 0 à 99 %, soit environ 999 ms | Différence entre 21 604 et 20 605, avec un tick nominal de 1 ms | Durée totale à confirmer | Il manque le relevé à 100 % pour cette montée en avant. | `T4_1.PNG`, `T4_Montee_Fin.PNG` |
| Rampe descendante | De 100 à 25 % en 750 ms , 10 % | Non relevée | Relever `pwm_pct` et `ticks_ms` au début et à la fin. | À déterminer | Aucun relevé de la descente dans les captures. | À joindre |
| Période de SysTick | 1 ms , 1 % | 1 ms calculée | LOAD = 3 999 avec l’horloge nominale de 4 MHz | À mesurer | Il manque le relevé de `ticks_ms` sur 10 s. | `systick.s` pour le réglage |
| Vitesse en marche avant | Croissante et stable à , 10 % | 540, 1 106, 1 669 et 2 248 fronts / 500 ms, soit 86,6, 177,4, 267,8 et 360,6 tr/min | Un relevé par palier. Un front vaut environ 0,16 tr/min. | À 100 %, +10,6 tr/min par rapport à 350 tr/min à vide | Les relevés montrent la hausse de vitesse. Il manque les séries de trois fenêtres pour vérifier la stabilité. | Captures T3 |
| Vitesse en marche arrière | Croissante et stable à , 10 % | Environ 182,7 tr/min à 50 %. Environ 372,7 tr/min affichés à la coupure à 100 %. | Relevés isolés de 1 139 et 2 323 fronts en valeur absolue. La deuxième valeur est indicative. | Série incomplète | Il manque les paliers de 25 % et de 75 %, ainsi que trois fenêtres par palier. | `T2_Arriere.PNG`, `T7_EStop_Arriere_100.PNG` |
| Déphasage E_A / E_B | Signaux en quadrature, ordre inversé selon le sens | Non relevé | Comparer le comptage dans les deux sens. | À déterminer | Il manque les relevés de `enc_count` sur 1 s dans chaque sens. | Vidéo T5 à joindre |
| Délai E-Stop → PWM nulle | Moins de 1 ms | CCR1 = 0 et STB = 0 après la coupure. Délai non mesuré. | Lecture après le passage dans le gestionnaire d’interruption | À déterminer | Les captures montrent le résultat après la coupure. | `T7_EStop_Avant_100.PNG`, `T7_EStop_Arriere_100.PNG` |
| Durée d’un bip | 100 ms , 10 % | 100 ms dans le code | Relever `ticks_ms` au début et à la fin du bip. | À mesurer | La durée réelle n’a pas été relevée. | `buzzer.s` et `registres_lab2.inc` pour le réglage. Vidéo T9 à joindre. |

## Tableau des essais (T1 à T10)

Les vidéos T5, T6, T8, T9 et T10 ont été signalées. Elles sont à joindre au dossier. Le tiret dans la colonne Date indique que la date de l’essai n’a pas été notée.

| Essai | Date | Résultat observé | Verdict | Preuve (fichier) |
|---|---|---|---|---|
| T1 Réinitialisation | 06/11 | `etat = 0`, `pwm_pct = 0`, CCR1 = 0 et STB = 0. Le délai, la DEL et le silence du buzzer restent à vérifier. | Partiel | `T1.PNG` |
| T2 Cycle User et sens | 06/11 | Les captures montrent avant, arrêt, arrière, arrêt à une consigne de 50 %. Les sorties de direction correspondent aux états. Il manque `sens_mesure` dans les deux sens. | Partiel | `T2_Avant.PNG`, `T2_Arret_Avant.PNG`, `T2_Arriere.PNG`, `T2_Arret_Arriere.PNG` |
| T3 PWM | 06/11 | Les quatre valeurs de CCR1 donnent les rapports cycliques demandés. La fréquence calculée est de 20 kHz. | Conforme sur les registres | `T3_25.PNG`, `T3_50.PNG`, `T3_75.PNG`, `T3_100.PNG` |
| T4 Rampe | 06/11 | En marche avant, les captures donnent 999 ticks entre 0 et 99 %. Le passage à 100 % en avant et la descente à 25 % restent à relever. | Partiel | `T4_1.PNG`, `T4_Montee_Fin.PNG`, `T4.PNG`, `T4_StepOver.PNG` |
| T5 Encodeur | 06/11 | Des valeurs de `enc_count` sont visibles. Il manque deux relevés à 1 s d’intervalle dans chaque sens pour calculer le nombre de fronts et vérifier le sens du comptage. L’absence de perte de fronts reste à vérifier. | Partiel | `T3_100.PNG`, captures T7 et vidéo T5 à joindre |
| T6 Vitesse | 06/11 | La vitesse augmente aux quatre paliers en avant. Il manque des relevés en arrière, trois fenêtres par palier dans chaque sens et la lecture de `sens_mesure`. | Partiel | Captures T3, `T2_Arriere.PNG`, `T7_EStop_Arriere_100.PNG` et vidéo T6 à joindre |
| T7 E-Stop | 06/11 | CCR1 = 0, STB = 0 et `estop_flag = 1` dans les deux captures. Le délai de coupure et l’essai en arrière pendant la rampe restent à vérifier. | Partiel | `T7_EStop_Avant_100.PNG`, `T7_EStop_Arriere_100.PNG` |
| T8 Urgence et acquittement | 06/11 | Il faut montrer que User est ignoré, que Touch En est refusé avec E-Stop maintenu et qu’il est accepté après le relâchement. Après l’acquittement, le moteur doit rester à l’arrêt. | À documenter | Vidéo T8 à joindre |
| T9 Buzzer | 06/11 | Il faut documenter le bip en avant, le double bip en arrière et le bip au changement de consigne. Il reste à relever la durée des bips. | À documenter | Vidéo T9 à joindre |
| T10 SysTick et robustesse | 06/11 | Le réglage correspond à 1 ms. Il manque le relevé sur 10 s et les résultats des appuis pendant la rampe et des appuis simultanés. | À documenter | `systick.s` pour le réglage. Vidéo T10 à joindre. |

## Routine conservée pour L3-A

- **Routine** : `motor_set_pwm`.
- **Interface** : le registre `r0` reçoit la consigne en pourcentage. La routine retourne dans `r0` la valeur écrite dans CCR1. Si l’arrêt d’urgence est actif, elle retourne 0 et ne modifie pas CCR1.
- **Cas d’essai et résultats** : à l’arrêt, CCR1 vaut 0 dans la capture T1. Aux consignes de 25, 50, 75 et 100 %, les captures T3 montrent CCR1 à 50, 100, 150 et 200. Le code limite une consigne supérieure à 100 % et bloque l’écriture si l’arrêt d’urgence est actif. Ces deux cas restent à vérifier par un appel direct de la routine.

## Déclaration des sources et de l’usage d’outils d’IA générative

- **Sources** : énoncé du laboratoire 2, version 1.3 du 13 octobre 2026, complément officiel du laboratoire 2, projet du groupe 9 du laboratoire 1 et captures STM32CubeIDE des essais du laboratoire 2.
- **IA** : nous avons utilisé ChatGPT (GPT-6 pour l’aide au code et GPT-6.1 pour l’aide à la rédaction) pour générer une partie du code, organiser le rapport et le journal, et comprendre les consignes du laboratoire.
