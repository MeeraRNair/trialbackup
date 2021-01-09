public class PQR_Duplicatecheck_HelperCls{

        public static void pqrDupCheck(list<Partner_Quoting_Relationships__c>listPQR){ 
        
       
        
        
        if(PQRelationshipsTriggerHandler.bisFirstTime){
        PQRelationshipsTriggerHandler.bisFirstTime = false;
        map<string,string> mapPT1 = new map<string,string>();
        for(Partner_Quoting_Relationships__c pty : listPQR){
            mapPT1.put(pty.Partner_Track__c,pty.Relationship_Type__c);
        } 
        system.debug('=======mapPT1==='+mapPT1);
        list<Partner_Quoting_Relationships__c> listpt1 = [select id,Relationship_Type__c,Partner_Track__c 
                         from Partner_Quoting_Relationships__c where Partner_Track__c IN :mapPT1.keySet()];
       system.debug('===== soql query === listpt1 size==>'+listpt1.size());
       
        for(Partner_Quoting_Relationships__c pty : listPQR){
            system.debug('======= pty rec trigger.new =='+pty);
            for(Partner_Quoting_Relationships__c pp:listpt1){
                system.debug('==== pp rec from query ==='+pp);
        if(pty.Partner_Track__c == pp.Partner_Track__c && pty.Relationship_Type__c== pp.Relationship_Type__c){
                    pty.adderror('Record already exists with the same relationship. Please create a different record.');
                }
               // system.debug('========pty in duplicats check ======'+pty);
            }
            
        }
        }
    }
  /*  public static void ptaDupCheck(list<Partner_Quoting_Relationships__c>listPQR,map<Id, Partner_Quoting_Relationships__c> mapOldPQR){
            boolean Excutetrigger = false;
        if(PQRelationshipsTriggerHandler.bisFirstTime){
        PQRelationshipsTriggerHandler.bisFirstTime = false;
            for(Partner_Quoting_Relationships__c  newPQR : listPQR) {
            Partner_Quoting_Relationships__c oldPQR = mapOldPQR.get(newPQR.Id);
            if(newPQR.Relationship_Type__c!= oldPQR.Relationship_Type__c|| newPQR.Related_Account__c!= oldPQR.Related_Account__c){
           
                Excutetrigger = true;
            }
            }
         }  
         
          if(Excutetrigger){
         // PQRelationshipsTriggerHandler.bisFirstTime = false;
        map<string,string> mapPT1 = new map<string,string>();
        for(Partner_Quoting_Relationships__c pty : listPQR){
            mapPT1.put(pty.Partner_Track__c,pty.Relationship_Type__c);
        } 
        system.debug('=======mapPT1==='+mapPT1);
        list<Partner_Quoting_Relationships__c> listpt1 = [select id,Relationship_Type__c,Partner_Track__c 
                         from Partner_Quoting_Relationships__c where Partner_Track__c IN :mapPT1.keySet()];
       system.debug('===== soql query === listpt1 size==>'+listpt1.size());
       
        for(Partner_Quoting_Relationships__c pty : listPQR){
            system.debug('======= pty rec trigger.new =='+pty);
            for(Partner_Quoting_Relationships__c pp:listpt1){
                system.debug('==== pp rec from query ==='+pp);
        if(pty.Partner_Track__c == pp.Partner_Track__c && pty.Relationship_Type__c== pp.Relationship_Type__c){
                    pty.adderror('Record already exists with the same relationship. Please create a different record.');
                }
               // system.debug('========pty in duplicats check ======'+pty);
            }
            
        
        }
          }
    }*/
    
}