**free                                                                                              
ctl-opt nomain;                                                                                     
                                                                                                    
dcl-proc AnneesToMois export;                                                                       
    dcl-pi *n int(10);                                                                              
        annees int(10);                                                                             
    end-pi;                                                                                         
                                                                                                    
    return annees * 12;                                                                             
end-proc;                                                                                           
                                                                                                    
dcl-proc GetInterets export;                                                                        
    dcl-pi *n packed(10:2);                                                                         
        capital packed(11:2);                                                                       
        taux packed(3:2);                                                                           
    end-pi;                                                                                         
                                                                                                    
    return capital * taux / 100 / 12;                                                               
end-proc;                                                                                           
                                                                                                    
dcl-proc GetMensualites export;                                                                     
    dcl-pi *n packed(10:2);                                                                         
        capital packed(11:2);                                                                       
        taux packed(3:2);                                                                           
        annees int(10);                                                                             
    end-pi;                                                                                         
    dcl-s tm packed(7:6);                                                                           
                                                                                                    
    tm = taux / 100 / 12; // tm = taux au mois                                                      
                                                                                                    
    if tm = 0; // Pour éviter la division par 0                                                     
        return 0;                                                                                   
    endif;                                                                                          
                                                                                                    
    return capital * tm / (1 - (1 + tm) ** (-12 * annees));                                         
end-proc;                                                                                           
                                                                                                    
dcl-proc GetLastMensualite export;                                                                  
    dcl-pi *n packed(10:2);                                                                         
        capitalRestant packed(11:2);                                                                
        interets packed(10:2);                                                                      
    end-pi;                                                                                         
                                                                                                    
    return capitalRestant + interets;                                                               
end-proc;                                                                                           
                                                                                                    
dcl-proc GetRemboursementCapital export;                                                            
    dcl-pi *n packed(10:2);                                                                         
        capital packed(11:2);                                                                       
        annees int(10);                                                                             
    end-pi;                                                                                         
                                                                                                    
    return capital / annees / 12;                                                                   
end-proc;                                                                                           
                                                                                                    
dcl-proc GetLastRemboursementCapital export;                                                        
    dcl-pi *n packed(10:2);                                                                         
        capitalRestant packed(11:2);                                                                
        interets packed(10:2);                                                                      
    end-pi;                                                                                         
                                                                                                    
    return capitalRestant - interets;                                                               
end-proc;                                                                                           
                                                                                                    
