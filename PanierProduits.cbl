       IDENTIFICATION DIVISION.
       PROGRAM-ID. YOUR-PROGRAM-NAME.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
      *    Fichier  des paniers :
           SELECT PANIER ASSIGN TO
               "C:/Users/HP/Downloads/PANIER.txt"
                ORGANIZATION       IS LINE SEQUENTIAL
                FILE STATUS        IS L-Fst-In1
                .
      *    Fichier des paniers avec les produits :
           SELECT PANPRD ASSIGN TO
               "C:/Users/HP/Downloads/PANPRD.txt"
                ORGANIZATION       IS LINE SEQUENTIAL
                FILE STATUS        IS L-Fst-In2
                .
      *    Fichier de sortie :
           SELECT Sor-Panier ASSIGN TO
               "C:/Users/HP/Downloads/SortiePanier.txt"
                ORGANIZATION       IS LINE SEQUENTIAL
                FILE STATUS        IS L-Fst-Out
           .

      *    Fichier de sortie :
           SELECT Erreur-Paniers ASSIGN TO
               "C:/Users/HP/Downloads/SortieErreur.txt"
                ORGANIZATION       IS LINE SEQUENTIAL
                FILE STATUS        IS L-Fst-Err
           .

       DATA DIVISION.
       FILE SECTION.

       FD PANIER.
       01 ENR-PANIER                                      PIC X(15).


       FD PANPRD.
       01 ENR-PANPRD.
           05 ENR-PANPRD-CLE-PAN                          PIC X(15).
           05 ENR-PANPRD-PRD                              PIC X(07).
           05 ENR-PANPRD-PRIX                             PIC 9(05).

       FD Sor-Panier.
       01 ENR-Sor-Panier.
           05 ENR-Sor-Panier-CLE-PAN                      PIC X(15).
           05 ENR-Sor-Panier-NBR-PRD                      PIC 9(02).
           05 ENR-Sor-Panier-TOT                          PIC 9(06).
           05 ENR-Sor-Panier-LIV                          PIC X(1).

       FD Erreur-Paniers.
       01 ENR-ERREUR                                      PIC X(27).

       WORKING-STORAGE SECTION.

      * Variables File status

       01 L-Fst-In1                                        PIC 9.
       01 L-Fst-In2                                        PIC 9.
       01 L-Fst-Out                                        PIC 9.
       01 L-Fst-Err                                        PIC 9.

      * Structures fichiers en entrée
       01 WS-ENR-PANIER.
           05 WS-ENR-PANIER-CLE-PAN                        PIC X(15).

       01 WS-ENR-PANPRD.
           05 WS-ENR-PANPRD-CLE-PAN                        PIC X(15).
           05 WS-ENR-PANPRD-PRD                            PIC X(07).
           05 WS-ENR-PANPRD-PRIX                           PIC 9(05).

      * Booléens pour tester la fin de lecture :

       01 Lec-Fic-PANIER-Fin                               PIC 9.
           88 Lec-Fic-PANIER-Fin-Oui                       VALUE 1.
           88 Lec-Fic-PANIER-Fin-Non                       VALUE 0.

       01 Lec-Fic-PANPRD-Fin                               PIC 9.
           88 Lec-Fic-PANPRD-Fin-Oui                       VALUE 1.
           88 Lec-Fic-PANPRD-Fin-Non                       VALUE 0.

      * Compteurs

       01 CPT-PANIER                                       PIC 9(10).
       01 CPT-PANPRD                                       PIC 9(10).
       01 CPT-SORT                                         PIC 9(10).
       01 CPT-ERR                                          PIC 9(10).

      * Variables pour le traitement :

       01 Total                                            PIC 9(5)V99.
       01 NBR-PRD                                          PIC 9(3).


       PROCEDURE DIVISION.

      ****************
       MAIN-PROCEDURE.
      ****************

           PERFORM INITIALISATION             THRU FIN-INITIALISATION

           PERFORM Traitement                 THRU FIN-Traitement

           PERFORM FIN                        THRU FIN-FIN

           GOBACK
           .

      *-----------------------------------------------------------------
      *****************
       INITIALISATION.
      *****************
           DISPLAY '***************************************************'
           DISPLAY '***          PANIERS ET  PRODUITS               ***'
           DISPLAY '***************************************************'

      * Initialisation des dfférentes variables et des différents
      * booléens

           INITIALISE Total
                      NBR-PRD
                      CPT-PANIER
                      CPT-PANPRD
                      CPT-SORT
                      CPT-ERR
                      WS-ENR-PANIER
                      WS-ENR-PANPRD
                      L-Fst-In1
                      L-Fst-In2
                      L-Fst-Out
                      L-Fst-Err


           SET Lec-Fic-PANIER-Fin-Non    TO TRUE
           SET Lec-Fic-PANPRD-Fin-Non    TO TRUE


      * Ouverture des fichiers

           OPEN INPUT   PANIER
           OPEN INPUT   PANPRD
           OPEN OUTPUT  Sor-Panier
           OPEN OUTPUT  Erreur-Paniers

      * Première lecture des deux fichiers

           PERFORM LECTURE-FICHIER-1    THRU FIN-LECTURE-FICHIER-1
           MOVE ENR-PANIER              TO WS-ENR-PANIER

           PERFORM LECTURE-FICHIER-2    THRU FIN-LECTURE-FICHIER-2
           MOVE ENR-PANPRD              TO WS-ENR-PANPRD

           .

      ********************
       FIN-INITIALISATION. EXIT.
      ********************
      *-----------------------------------------------------------------
      ************
       Traitement.
      ************
           PERFORM UNTIL Lec-Fic-PANIER-Fin-Oui AND
                                                  Lec-Fic-PANPRD-Fin-Oui
                   PERFORM Comparaison THRU FIN-Comparaison
           END-PERFORM
           .
      ****************
       FIN-Traitement. EXIT.
      ****************

      *----------------------------------------------------------------*
      *************
       Comparaison.
      *************

           EVALUATE TRUE
               WHEN WS-ENR-PANIER-CLE-PAN = WS-ENR-PANPRD-CLE-PAN
                   PERFORM Traitement-produits THRU
                                               FIN-Traitement-produits

               WHEN WS-ENR-PANIER-CLE-PAN < WS-ENR-PANPRD-CLE-PAN
      *        C-A-D on a finit notre panier !!!!
                   PERFORM Traitement-panier THRU FIN-Traitement-panier

               WHEN WS-ENR-PANIER-CLE-PAN > WS-ENR-PANPRD-CLE-PAN
      *        Produit qui n'a pas de panier !!!! Erreur
                   PERFORM Traitement-Erreur THRU FIN-Traitement-Erreur
           END-EVALUATE
           .
      ****************
       FIN-Comparaison. EXIT.
      ****************

      *******************
       LECTURE-FICHIER-1.
      *******************

           READ PANIER
           AT END
               SET Lec-Fic-PANIER-Fin-Oui  TO TRUE

           NOT AT END
               IF L-Fst-In1 NOT = ZERO
                   DISPLAY 'Erreur lecture fichier 1 =' L-Fst-In1
               END-IF
               ADD 1 TO CPT-PANIER
      *>          DISPLAY "Fichier Paniers : Enregistrement numéro "
      *>                                                        CPT-PANIER
           END-READ
           .
      ***********************
       FIN-LECTURE-FICHIER-1. EXIT.
      ***********************
      *-----------------------------------------------------------------
      *******************
       LECTURE-FICHIER-2.
      *******************

           READ PANPRD
           AT END
               SET Lec-Fic-PANPRD-Fin-Oui  TO TRUE
           NOT AT END
               IF L-Fst-In2 NOT = ZERO
                   DISPLAY 'Erreur lecture fichier 1 =' L-Fst-In2
               END-IF
               ADD 1 TO CPT-PANPRD
      *>          DISPLAY "Fichier Paniers et produits :"
      *>                              "Enregistrement numéro " CPT-PANPRD
           END-READ
           .
      ***********************
       FIN-LECTURE-FICHIER-2. EXIT.
      ***********************

      *********************
       Traitement-produits.
      *********************
           ADD WS-ENR-PANPRD-PRIX    TO Total
           ADD 1                     TO NBR-PRD
           PERFORM LECTURE-FICHIER-2 THRU FIN-LECTURE-FICHIER-2
           MOVE ENR-PANPRD           TO WS-ENR-PANPRD
           IF Lec-Fic-PANPRD-Fin-Oui
               PERFORM Traitement-panier THRU FIN-Traitement-panier

           END-IF
           .
      *************************
       FIN-Traitement-produits. EXIT.
      *************************

      *******************
       Traitement-panier.
      *******************
           DISPLAY WS-ENR-PANIER-CLE-PAN " , " WS-ENR-PANPRD-CLE-PAN
           EVALUATE TRUE
               WHEN Total >= 100
                   MOVE 'G'           TO ENR-Sor-Panier-LIV
               WHEN Total =           ZERO
                   MOVE 'A'           TO ENR-Sor-Panier-LIV
               WHEN Total >           ZERO AND Total < 100
                   MOVE 'P'           TO ENR-Sor-Panier-LIV
                   ADD 14.55          TO Total

           END-EVALUATE

           MOVE Total                 TO ENR-Sor-Panier-TOT
           MOVE WS-ENR-PANIER-CLE-PAN TO ENR-Sor-Panier-CLE-PAN
           IF Lec-Fic-PANIER-Fin-Non
               WRITE ENR-Sor-Panier
               IF L-Fst-Out NOT ZERO
                   DISPLAY "Erreur ecriture fichier erreur = " L-Fst-Out
               END-IF
               ADD 1 TO CPT-SORT
           END-IF

           INITIALISE Total
                       NBR-PRD



           IF Lec-Fic-PANIER-Fin-Oui
               PERFORM ECR-FICHIER-ERR   THRU FIN-ECR-FICHIER-ERR
               PERFORM LECTURE-FICHIER-2 THRU FIN-LECTURE-FICHIER-2
               MOVE ENR-PANPRD           TO WS-ENR-PANPRD
           ELSE
               PERFORM LECTURE-FICHIER-1 THRU FIN-LECTURE-FICHIER-1
               MOVE ENR-PANIER           TO WS-ENR-PANIER
           END-IF



           .
      ***********************
       FIN-Traitement-panier. EXIT.
      ***********************

      *******************
       Traitement-Erreur.
      *******************
           IF Lec-Fic-PANPRD-Fin-Non
               PERFORM ECR-FICHIER-ERR THRU FIN-ECR-FICHIER-ERR
           END-IF
           PERFORM LECTURE-FICHIER-2 THRU FIN-LECTURE-FICHIER-2
           MOVE ENR-PANPRD TO WS-ENR-PANPRD
           IF Lec-Fic-PANPRD-Fin-Oui
               PERFORM Traitement-panier THRU FIN-Traitement-panier
           END-IF
           .
      ***********************
       FIN-Traitement-Erreur. EXIT.
      ***********************

      *****************
       ECR-FICHIER-ERR.
      *****************
           MOVE WS-ENR-PANPRD TO ENR-ERREUR
           WRITE ENR-ERREUR
           IF L-Fst-Err NOT ZERO
               DISPLAY "Erreur ecriture fichier erreur = " L-Fst-Err
           END-IF
           ADD 1              TO CPT-ERR
           .
      *********************
       FIN-ECR-FICHIER-ERR. EXIT.
      *********************
      *-----------------------------------------------------------------
      ******
       FIN.
      ******

      * Fermeture de tous les fichiers

           CLOSE PANIER
           CLOSE PANPRD
           CLOSE Sor-Panier
           CLOSE Erreur-Paniers

      * Display des compteurs et du nombre d'erreurs s'il y en a

           DISPLAY "Nombre d'enregistrements lus en 1 : " CPT-PANIER
           DISPLAY "Nombre d'enregistrements lus en 2 : " CPT-PANPRD
           DISPLAY "Nombre d'enregistrements ecrits dans fichier de "
                                                   "sorie : " CPT-SORT
           IF CPT-ERR NOT = ZERO
               DISPLAY '***********************************************'
               DISPLAY '***********************************************'
               DISPLAY '**************IL Y A DES ERREURS***************'
               DISPLAY '***********************************************'
               DISPLAY '***********************************************'
               DISPLAY "Nombre d'erreurs : "           CPT-ERR
           END-IF

           DISPLAY 'Fin de traitement'
           .

      **********
       FIN-FIN.  EXIT.
      **********
       END PROGRAM YOUR-PROGRAM-NAME.
      *-----------------------------------------------------------------
