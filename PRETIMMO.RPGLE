**free                                                                                              
// *********************************************************************************** //           
// *** INDICATEURS                                                                                  
// *********************************************************************************** //           
//____|_*ON___________________________________|_*OFF____________________________________            
// 03 | Touche F3 (Quitter)                   |                                                     
// 12 | Touche F12 (Retour)                   |                                                     
// 41 | Affichage enreg du SF résultats       |                                                     
// 42 | Effacement du SF résultats            |                                                     
// 90 | Saut de page pour le PRTF             |                                                     
// *********************************************************************************** //           
ctl-opt dftactgrp(*no) actgrp(*caller) bnddir('PRETIMMO');                                          
                                                                                                    
// *** Déclaration des fichiers ***                                                                 
dcl-f EPRETIMMO workstn sfile(SFLRESULT : ligne);                                                   
dcl-f PRETIMMO printer oflind(*IN90);                                                               
                                                                                                    
// *** Déclaration des variables ***                                                                
dcl-s ligne zoned(4:0);                                                                             
                                                                                                    
// *** Déclaration des constantes ***                                                               
dcl-s ANNUITES_CONSTANTES int(10) inz(1);                                                           
dcl-s AMORTISSEMENT_CONSTANT int(10) inz(2);                                                        
                                                                                                    
// *** Déclaration des prototypes des modules ***                                                   
/copy EDDAM/QCOPYSRC,PRETIMMO                                                                       
                                                                                                    
Dcl-Pr QCMDEXC EXTPGM('QCMDEXC');                                                                   
    commandString CHAR(32702) CONST OPTIONS(*VARSIZE);                                              
    commandLength PACKED(15:5) CONST;                                                               
End-Pr;                                                                                             
                                                                                                    
// Boucle d'affichage de l'écran principal (saisie des paramètres)                                  
dow not *IN03;                                                                                      
    write FOOTMAIN;                                                                                 
    exfmt MAIN;                                                                                     
    select;                                                                                         
        when (*IN03);                                                                               
            leave;                                                                                  
        when (*IN11);                                                                               
            QCMDEXC('WRKSPLF' : 7);                                                                 
    endsl;                                                                                          
                                                                                                    
    if DUREE = 0; // Pour éviter les erreurs de division par 0 plus tard                            
        exfmt WDURERR;                                                                              
        iter;                                                                                       
    endif;                                                                                          
                                                                                                    
    // Remplir le sous fichier des résultats                                                        
    if TYPEPRET <> 0;                                                                               
        RemplirSfResultats();                                                                       
        AfficherSfResultats();                                                                      
    endif;                                                                                          
enddo;                                                                                              
                                                                                                    
*INLR = *ON;                                                                                        
return;                                                                                             
                                                                                                    
dcl-proc RemplirSfResultats;                                                                        
    dcl-s moisMax packed(3:0);                                                                      
                                                                                                    
    // Vider le sous fichier                                                                        
    *IN42 = *ON;                                                                                    
    write CTLRESULT;                                                                                
    *IN42 = *OFF;                                                                                   
    ligne = 0; // Initialisation numéro de ligne                                                    
                                                                                                    
    // Initialisation des champs dans l'entête du SF                                                
    INTERETTOT = 0;                                                                                 
    INTPAYES = 0;                                                                                   
                                                                                                    
    // Initialisation des champs dans le SF                                                         
    CAPRESTDU = MONTANT;                                                                            
    select;                                                                                         
        when (TYPEPRET = ANNUITES_CONSTANTES);                                                      
            MENSUALITE = GetMensualites(MONTANT : TAUX : %int(DUREE));                              
        when (TYPEPRET = AMORTISSEMENT_CONSTANT);                                                   
            CAPREMB = GetRemboursementCapital(MONTANT : %int(DUREE));                               
    endsl;                                                                                          
                                                                                                    
    moisMax = AnneesToMois(%int(DUREE));                                                            
                                                                                                    
    for MOIS = 1 to moisMax;                                                                        
        INTERETS = GetInterets(CAPRESTDU : TAUX);                                                   
        INTERETTOT += INTERETS;                                                                     
                                                                                                    
        select;                                                                                     
            when (TYPEPRET = ANNUITES_CONSTANTES);                                                  
                // Recalcul de la mensualité pour le dernier mois                                   
                if MOIS = moisMax;                                                                  
                    MENSUALITE = GetLastMensualite(CAPRESTDU : INTERETS);                           
                endif;                                                                              
                CAPREMB = MENSUALITE - INTERETS;                                                    
            when (TYPEPRET = AMORTISSEMENT_CONSTANT);                                               
                // Recalcul du capital remboursé pour le dernier mois                               
                if MOIS = moisMax;                                                                  
                    CAPREMB = GetLastRemboursementCapital(CAPRESTDU : INTERETS);                    
                endif;                                                                              
                MENSUALITE = CAPREMB + INTERETS;                                                    
        endsl;                                                                                      
                                                                                                    
        // Écriture de la ligne dans le SF seulement si le mois >= filtre                           
        if MOIS >= FLTMOIS;                                                                         
            ligne += 1;                                                                             
            write SFLRESULT;                                                                        
        else; // Si en dessous du filtre, incrémenter les intérêts déjà payés                       
            INTPAYES += INTERETS;                                                                   
        endif;                                                                                      
                                                                                                    
        CAPRESTDU -= CAPREMB; // Calcul du PROCHAIN capital restant dû                              
    endfor;                                                                                         
                                                                                                    
    MONTANTTOT = MONTANT + INTERETTOT; // Calcul du montant total dans l'entête                     
    INTMONT = INTERETTOT / MONTANTTOT * 100; // Pourcentage d'intérêts par rapport au montant total 
    if INTERETTOT = 0; // Éviter la division par 0                                                  
        PRCPAYES = 0;                                                                               
    else;                                                                                           
        PRCPAYES = INTPAYES / INTERETTOT * 100; // Pourcentage d'intérêts payés avant le filtre     
    endif;                                                                                          
                                                                                                    
    // Activer les enreg du SF s'il y a au moins une ligne                                          
    if ligne > 0;                                                                                   
        *IN41 = *ON;                                                                                
    else;                                                                                           
        *IN41 = *OFF;                                                                               
    endif;                                                                                          
end-proc;                                                                                           
                                                                                                    
dcl-proc AfficherSfResultats;                                                                       
    dow not *IN03;                                                                                  
        write FOOTRESULT;                                                                           
        exfmt CTLRESULT;                                                                            
                                                                                                    
        select;                                                                                     
            when (*IN03 or *IN12);                                                                  
                leave;                                                                              
            when (*IN11);                                                                           
                QCMDEXC('WRKSPLF' : 7);                                                             
            when (*IN20); // Touche F20                                                             
                ImprimerResultats();                                                                
            other; // Touche entrée                                                                 
                RemplirSfResultats();                                                               
        endsl;                                                                                      
    enddo;                                                                                          
end-proc;                                                                                           
                                                                                                    
dcl-proc ImprimerResultats;                                                                         
    ligne = 0;                                                                                      
    write HEADER;                                                                                   
    write COLONNES;                                                                                 
    dow 1 = 1;                                                                                      
        ligne += 1;                                                                                 
        chain ligne SFLRESULT;                                                                      
        if not %found();                                                                            
            leave;                                                                                  
        endif;                                                                                      
                                                                                                    
        write DETAIL;                                                                               
        if *IN90; // En cas de fin de page, passer à la suivante                                    
            write EJECT;                                                                            
            write COLONNES;                                                                         
            *IN90 = *OFF;                                                                           
        endif;                                                                                      
    enddo;                                                                                          
                                                                                                    
    write FOOTER;                                                                                   
    exfmt WIMPRESSOK;                                                                               
end-proc;                                                                                           
                                                                                                    
