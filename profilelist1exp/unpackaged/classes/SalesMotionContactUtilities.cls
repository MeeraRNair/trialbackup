/**
* @File Name          : SalesMotionContactUtilities.cls
* @Description        : Utility class for Sales Motion Contact record's insertion and updation logic
* @Author             : Sushanth Dasari
* @Last Modified By   : Sushanth Dasari
* @Last Modified On   : 11/11/2019, 10:06:38 AM
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    11/5/2019       Sushanth Dasari          Initial Version
**/
public class SalesMotionContactUtilities {

    /**
    * @description 
    * @author Sushanth Dasari |  11/5/2019 
    * @param map<Id Contact> mapOldContacts 
    * @param map<Id Contact> mapNewContacts 
    * @return void 
    **/
    public static void publishContactsForSMContacts(map<Id, Contact> mapOldContacts, map<Id, Contact> mapNewContacts){
        List<Sales_Motion_Contact_Event__e> listPublishEvents = new List<Sales_Motion_Contact_Event__e>();
        try{
            for(Contact contactRecord: mapNewContacts.values()){
                if(String.isNotBlank(contactRecord.EligibleTracks__c)){
                    Sales_Motion_Contact_Event__e salesMotionContactEvent = new Sales_Motion_Contact_Event__e();
                    salesMotionContactEvent.ContactId__c = contactRecord.Id;
                    salesMotionContactEvent.new_partnertrackIds__c = contactRecord.EligibleTracks__c;
                    if(mapOldContacts!= null && mapOldContacts.containsKey(contactRecord.Id)){
                        salesMotionContactEvent.old_partnertrackIds__c = mapOldContacts.get(contactRecord.Id).EligibleTracks__c;
                    }
                    listPublishEvents.add(salesMotionContactEvent);
                }
            }
            System.debug('listPublishEvents: '+listPublishEvents);
            if(!listPublishEvents.isEmpty()){
                List<Database.SaveResult> listResults = EventBus.publish(listPublishEvents);
                for(Database.SaveResult sr : listResults) {
                    if(sr.isSuccess()){
                        System.debug('Successfully published event.');
                    } else {
                        for(Database.Error objErr : sr.getErrors()) {
                            System.debug('The following error has occurred.');  
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                        }
                    }
                }    
            }
        }catch(Exception e) {
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'Publish platform event-SalesMotionContactUtilities';
            exceptionRecord.Object_type__c = 'publishContactsForSMContacts';
            exceptionRecord.Error_Messages__c = e.getMessage();
            System.debug('Error: '+e.getMessage());
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
        }
    }
    
    /**
    * @description Method for inserting new Sales Motion Contact records
    * @author Sushanth Dasari | 11/5/2019 
    * @param List<Sales_Motion_Contact_Event__e> listSMContact 
    * @return void 
    **/
    public static void insertSalesMotionContacts(List<Sales_Motion_Contact_Event__e> listSMContact){
        try{
            List<Sales_Motion_Contact__c> listAllSMContacts = new List<Sales_Motion_Contact__c>();
            List<Sales_Motion_Contact__c> listInsertSMContacts = new List<Sales_Motion_Contact__c>();
            List<String> listPartnerTrackId = new List<String>();
            Map<String, String> mapPTIdSMAccountId = new Map<String, String>();
            Set<Id> setSMId = new Set<Id>();
            Set<Id> setContactId = new Set<Id>();
            Set<String> setSMIdContactId = new Set<String>();
            
            for(Sales_Motion_Contact_Event__e sMContactRecord: listSMContact){
                if(String.isNotBlank(sMContactRecord.new_partnertrackIds__c)){
                    if(sMContactRecord.new_partnertrackIds__c.contains(';')){
                        listPartnerTrackId = sMContactRecord.new_partnertrackIds__c.split(';');
                    }else{
                        listPartnerTrackId.add(sMContactRecord.new_partnertrackIds__c);  
                    }
                }
            }
            
            for(Account salesMotionRecord : [SELECT Id, Partner_Track__c
                                             FROM Account
                                             WHERE recordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId()
                                             AND Partner_Track__c IN :listPartnerTrackId]){
                                                 mapPTIdSMAccountId.put(salesMotionRecord.Partner_Track__c, salesMotionRecord.Id);
                                             }
            
            for(Sales_Motion_Contact_Event__e sMContactRecord: listSMContact){
                for(String strPartnerTrackId : listPartnerTrackId){
                    if(String.isNotBlank(sMContactRecord.new_partnertrackIds__c) && sMContactRecord.new_partnertrackIds__c.contains(strPartnerTrackId)
                       && mapPTIdSMAccountId.containsKey(strPartnerTrackId)){
                           Sales_Motion_Contact__c salesMotionContact = new Sales_Motion_Contact__c();
                           salesMotionContact.Sales_Motion__c = mapPTIdSMAccountId.get(strPartnerTrackId);
                           salesMotionContact.Contact__c = sMContactRecord.contactId__c;
                           listAllSMContacts.add(salesMotionContact);
                           setSMId.add(mapPTIdSMAccountId.get(strPartnerTrackId));
                           setContactId.add(sMContactRecord.contactId__c);
                       }
                }
            }
            
            for(Sales_Motion_Contact__c salesMotionContactRecord : [SELECT Id, Sales_Motion__c, Contact__c
                                                                    FROM Sales_Motion_Contact__c
                                                                    WHERE Sales_Motion__c =: setSMId
                                                                    AND Contact__c =: setContactId]){
                                                                        setSMIdContactId.add(salesMotionContactRecord.Sales_Motion__c+''+salesMotionContactRecord.Contact__c);
                                                                    }
            if(!listAllSMContacts.isEmpty()){
                for(Sales_Motion_Contact__c salesMotionContactRecord : listAllSMContacts){
                    if(!setSMIdContactId.contains(salesMotionContactRecord.Sales_Motion__c+''+salesMotionContactRecord.Contact__c)){
                        listInsertSMContacts.add(salesMotionContactRecord);
                    } 
                }
            }
            
            if(!listInsertSMContacts.isEmpty()){
                Database.SaveResult[] listSR = Database.insert(listInsertSMContacts,false);
                for(Database.SaveResult sr : listSR) {
                    if(sr.isSuccess()){
                        System.debug('Insert Successfully');
                    } else {
                        for(Database.Error objErr : sr.getErrors()) {
                            System.debug('The following error has occurred.');  
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                        }
                    }
                }    
            }
        }catch(Exception e) {
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'Insert Sales Motion Contacts';
            exceptionRecord.Object_type__c = 'SalesMotionContactUtilities';
            exceptionRecord.Error_Messages__c = e.getMessage();
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
        }
    }
    
    /**
    * @description 
    * @author Sushanth Dasari | 11/5/2019 
    * @param List<Sales_Motion_Contact_Event__e> listSMContacts 
    * @return void 
    **/
    public static void updateSalesMotionContacts(List<Sales_Motion_Contact_Event__e> listSMContacts){
        try{
            List<String> listNewPTIdContactId = new List<String>();
            List<String> listOldPTIdContactId = new List<String>();
            List<String> listDeletePTIdContactId = new List<String>();
            Set<String> setPartnerTrackId = new Set<String>();
            Map<String, String> mapPTIdSMAccountId = new Map<String, String>();
            List<Sales_Motion_Contact__c> listDeleteSMContacts = new List<Sales_Motion_Contact__c>();
            List<Sales_Motion_Contact__c> listAllSMContacts = new List<Sales_Motion_Contact__c>();
            List<String> listSMId = new List<String>();
            List<String> listContactId = new List<String>();
            Map<String, String> mapSMIdConIdvsSMCId= new Map<String, String>();
            List<Sales_Motion_Contact_Event__e> listInsertSMContacts = new List<Sales_Motion_Contact_Event__e>();

            for(Sales_Motion_Contact_Event__e sMContactRecord: listSMContacts){
                if(String.isNotBlank(sMContactRecord.new_partnertrackIds__c)
                   && sMContactRecord.new_partnertrackIds__c != sMContactRecord.old_partnertrackIds__c){
                       listInsertSMContacts.add(sMContactRecord);
                       if(sMContactRecord.new_partnertrackIds__c.contains(';')){
                           for(String strPartnerTrackId : sMContactRecord.new_partnertrackIds__c.split(';')){
                               listNewPTIdContactId.add(strPartnerTrackId+'-'+sMContactRecord.ContactId__c);
                           }
                       }else{
                           listNewPTIdContactId.add(sMContactRecord.new_partnertrackIds__c+'-'+sMContactRecord.ContactId__c);
                       }
                       if(sMContactRecord.old_partnertrackIds__c.contains(';')){
                           for(String strPartnerTrackId : sMContactRecord.old_partnertrackIds__c.split(';')){
                               listOldPTIdContactId.add(strPartnerTrackId+'-'+sMContactRecord.ContactId__c);
                           }
                       }else{
                           listOldPTIdContactId.add(sMContactRecord.old_partnertrackIds__c+'-'+sMContactRecord.ContactId__c);
                       }
                }
            }
            
            if(!listInsertSMContacts.isEmpty()){
                insertSalesMotionContacts(listInsertSMContacts);
            }
            
            for(String strOldPTIdContactId : listOldPTIdContactId){
                if(!listNewPTIdContactId.contains(strOldPTIdContactId)){
                    listDeletePTIdContactId.add(strOldPTIdContactId);
                    setPartnerTrackId.add(strOldPTIdContactId.replaceAll('-.*', ''));
                }
            }
            
            if(!setPartnerTrackId.isEmpty()){
                for(Account salesMotionRecord : [SELECT Id, Partner_Track__c
                                                 FROM Account
                                                 WHERE recordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId()
                                                 AND Partner_Track__c IN :setPartnerTrackId]){
                                                     mapPTIdSMAccountId.put(salesMotionRecord.Partner_Track__c, salesMotionRecord.Id);
                                                 }
                
                for(String strPTIdContactId: listDeletePTIdContactId){
                    List<String> listSplit = new List<String>();
                    listSplit = strPTIdContactId.split('-');
                    if(mapPTIdSMAccountId.containsKey(listSplit[0])){
                        listSMId.add(mapPTIdSMAccountId.get(listSplit[0]));
                        listContactId.add(listSplit[1]);
                        Sales_Motion_Contact__c salesMotionContact = new Sales_Motion_Contact__c();
                        salesMotionContact.Sales_Motion__c = mapPTIdSMAccountId.get(listSplit[0]);
                        salesMotionContact.Contact__c = listSplit[1];
                        listAllSMContacts.add(salesMotionContact);
                    }
                }
            }
            
            if(!listAllSMContacts.isEmpty() && !listSMId.isEmpty() && !listContactId.isEmpty()){
                for(Sales_Motion_Contact__c salesMotionContact : [SELECT Id, Sales_Motion__c, Contact__c
                                                                  FROM Sales_Motion_Contact__c
                                                                  WHERE Sales_Motion__c =: listSMId
                                                                  AND Contact__c =: listContactId]){
                                                                      mapSMIdConIdvsSMCId.put(salesMotionContact.Sales_Motion__c+''+salesMotionContact.Contact__c, salesMotionContact.Id);
                                                                  }
                for(Sales_Motion_Contact__c salesMotionContactRecord : listAllSMContacts){
                    if(mapSMIdConIdvsSMCId.containsKey(salesMotionContactRecord.Sales_Motion__c+''+salesMotionContactRecord.Contact__c)){
                        Sales_Motion_Contact__c salesMotionCont = new Sales_Motion_Contact__c();
                        salesMotionCont.Id = mapSMIdConIdvsSMCId.get(salesMotionContactRecord.Sales_Motion__c+''+salesMotionContactRecord.Contact__c);
                        listDeleteSMContacts.add(salesMotionCont);
                    }
                }
            }
            
            if(!listDeleteSMContacts.isEmpty()){
                Database.DeleteResult[] listDR = Database.delete(listDeleteSMContacts,false);
                for(Database.DeleteResult sr : listDR) {
                    if(sr.isSuccess()){
                        System.debug('Delete Successfully');
                    } else {
                        for(Database.Error objErr : sr.getErrors()) {
                            System.debug('The following error has occurred.');  
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                        }
                    }
                }
            }
        }catch(Exception e) {
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'Insert/Delete Sales Motion Contacts';
            exceptionRecord.Object_type__c = 'SalesMotionContactUtilities';
            exceptionRecord.Error_Messages__c = e.getMessage();
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
        }
    }
}