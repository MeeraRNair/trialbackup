public class PTA_Duplicatecheck_HelperCls {

   
    /* **************************** For Duplicats ****************************************/
    
 
    
    
    public static void ptaDupCheck(list<Partner_Type_Attribute__c>listPTA,map<Id, Partner_Type_Attribute__c> mapOldPTA){
       boolean bExcutetrigger = false;
        if(PTAttributesTriggerHandler.bisFirstTime){
        PTAttributesTriggerHandler.bisFirstTime = false;
            for(Partner_Type_Attribute__c newPTA : listPTA) {
            Partner_Type_Attribute__c oldPTA = mapOldPTA.get(newPTA.Id);
            if(newPTA.Distribution_Channel__c != oldPTA.Distribution_Channel__c || newPTA.Partner_Price_List_Type__c != oldPTA.Partner_Price_List_Type__c){
                bExcutetrigger = true;
            }
            }
         }   
                
    if(bExcutetrigger){
        //PTAttributesTriggerHandler.bisFirstTime = false;
        map<string,string> mappt1 = new map<string,string>();
        for(Partner_Type_Attribute__c pty : listPTA){
            mappt1.put(pty.Partner_Track__c,pty.Partner_Price_List_Type__c);
        } 
        system.debug('=======mappt1==='+mappt1);
        list<Partner_Type_Attribute__c> listpt1 = [select id,Distribution_Channel__c,Partner_Price_List_Type__c,Partner_Track__c 
                         from Partner_Type_Attribute__c where Partner_Track__c IN :mappt1.keySet()];
       system.debug('===== soql query === listpt1 size==>'+listpt1.size());
       
        for(Partner_Type_Attribute__c pty : listPTA){
            system.debug('======= pty rec trigger.new =='+pty);
            for(Partner_Type_Attribute__c pp:listpt1){
                system.debug('==== pp rec from query ==='+pp);
        if(pty.Partner_Track__c == pp.Partner_Track__c && pty.Distribution_Channel__c == pp.Distribution_Channel__c){
                    pty.adderror('Record already exists with the same Distribution Channel. Please create a different record');
                }
               // system.debug('========pty in duplicats check ======'+pty);
            }
            
        }
        }
    }
    
    public static void ptaDupCheck(list<Partner_Type_Attribute__c>listPTA){
    if(PTAttributesTriggerHandler.bisFirstTime){
        PTAttributesTriggerHandler.bisFirstTime = false;
        map<string,string> mappt1 = new map<string,string>();
        for(Partner_Type_Attribute__c pty : listPTA){
            mappt1.put(pty.Partner_Track__c,pty.Partner_Price_List_Type__c);
        } 
        system.debug('=======mappt1==='+mappt1);
        list<Partner_Type_Attribute__c> listpt1 = [select id,Distribution_Channel__c,Partner_Price_List_Type__c,Partner_Track__c 
                         from Partner_Type_Attribute__c where Partner_Track__c IN :mappt1.keySet()];
       system.debug('===== soql query === listpt1 size==>'+listpt1.size());
       
        for(Partner_Type_Attribute__c pty : listPTA){
            system.debug('======= pty rec trigger.new =='+pty);
            for(Partner_Type_Attribute__c pp:listpt1){
                system.debug('==== pp rec from query ==='+pp);
        if(pty.Partner_Track__c == pp.Partner_Track__c && pty.Distribution_Channel__c == pp.Distribution_Channel__c){
                    pty.adderror('Record already exists with the same Distribution Channel. Please create a different record');
                }
               // system.debug('========pty in duplicats check ======'+pty);
            }
            
        }
        }
    }
    
}