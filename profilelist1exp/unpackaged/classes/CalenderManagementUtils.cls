public class CalenderManagementUtils {
    public static void updateChildDates (map<Id, Integer> cmIDtoOffSetDaysMap){
        List<Calendar_Management__c> calManListToUpdate = new List<Calendar_Management__c>();
        List<Calendar_Management__c> primaryCalListToUpdate = new List<Calendar_Management__c>();
        List<Agenda_Topic__c> agendaTopicListToUpdate = new List<Agenda_Topic__c>();
        List<Transportation__c> transportListToUpdate = new List<Transportation__c>();      
        Integer offsetDays=0; 
        Id secCalManRecType  = IdLookupUtils.getRecordTypeId('Secondary Calendar RT','Calendar_Management__c',true);
        try{
            /*  handling secondary calenders.  */
            for(Calendar_Management__c secCalManagement : [SELECT Date__c, Calendar_Management_Record_ID__c
                                                            FROM Calendar_Management__c 
                                                            WHERE Calendar_Management_Record_ID__c IN :cmIDtoOffSetDaysMap.keySet()]){
                offsetDays =  cmIDtoOffSetDaysMap.get(secCalManagement.Calendar_Management_Record_ID__c);
                secCalManagement.Date__c += offsetDays;
                calManListToUpdate.add(secCalManagement);
            }
            /* handling primary calenders */
             for(Calendar_Management__c primaryCalManagement : [SELECT Date__c, Id
                                                            FROM Calendar_Management__c 
                                                            WHERE Id IN :cmIDtoOffSetDaysMap.keySet()]){
                offsetDays =  cmIDtoOffSetDaysMap.get(primaryCalManagement.Id);
                primaryCalManagement.Date__c += offsetDays;
                primaryCalListToUpdate.add(primaryCalManagement);
            }
            /*  handling Agenda Topics.  */
            for(Agenda_Topic__c  agendaTopic : [SELECT Start_Date__c,Customer_Engagement__r.Calendar_Management__c 
                                                 FROM Agenda_Topic__c 
                                                 WHERE Customer_Engagement__r.Calendar_Management__c IN :cmIDtoOffSetDaysMap.keySet()]){    
                if(agendaTopic.Start_Date__c!=null){
                    offsetDays =  cmIDtoOffSetDaysMap.get(agendaTopic.Customer_Engagement__r.Calendar_Management__c);
                    agendaTopic.Start_Date__c =agendaTopic.Start_Date__c+ offsetDays;
                    agendaTopicListToUpdate.add(agendaTopic);
                }
             }
            
            /*  handling Travel */
            for(Transportation__c  transportation : [SELECT Start_Date__c,Customer_Engagement__r.Calendar_Management__c 
                                                      FROM Transportation__c 
                                                      WHERE Customer_Engagement__r.Calendar_Management__c IN :cmIDtoOffSetDaysMap.keySet()]){
                if(transportation.Start_Date__c!=null){
                    offsetDays =  cmIDtoOffSetDaysMap.get(transportation.Customer_Engagement__r.Calendar_Management__c);
                    transportation.Start_Date__c += offsetDays;
                    transportListToUpdate.add(transportation);
                }
            }
            
            //Updating the secondary calender,topics and travel records
            if(calManListToUpdate.size()> 0){ 
                database.update(calManListToUpdate,false);
            }
            if(primaryCalListToUpdate.size()> 0){ 
                database.update(primaryCalListToUpdate,false);
            }
        
            if(agendaTopicListToUpdate.size()> 0){ 
                database.update(agendaTopicListToUpdate,false);
            }
            
            if(transportListToUpdate.size()> 0){
                database.update(transportListToUpdate,false);
            }
        }
        catch(Exception e){
            System.debug('Exception Occured during update:'+e);
        } 
    }
}