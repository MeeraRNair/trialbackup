/************************************************************************

Author        : Rahul Mishra
Description   : Controller class to save the record created from
Trip Report lightning component
Last Revised  : 30 Nov 2017


*************************************************************************/


public class TripReportController {
    
    // Method to save the trip report record with information entered from lightning component
    
    @AuraEnabled
    public static void  saveTripReport(CustomerInteraction__c trpRec) {
        CustomerInteraction__c objtrpRec = new CustomerInteraction__c(Goal_Objective__c = trpRec.Goal_Objective__c, Date__c = trpRec.Date__c, 
                                                                      Name = trpRec.Name,Customer_Attendee1__c = trpRec.Customer_Attendee1__c,
                                                                      Account__c = trpRec.Account__c, Type__c = trpRec.Type__c, Summary__c = trpRec.Summary__c, 
                                                                      Action_Items__c = trpRec.Action_Items__c, Send_Notification_Email__c = trpRec.Send_Notification_Email__c,
                                                                      Secondary_Dell_Attendee__c = trpRec.Secondary_Dell_Attendee__c, 
                                                                      Dell_Executive_Attendee_1__c = trpRec.Dell_Executive_Attendee_1__c,
                                                                      Primary_Dell_Attendee__c = trpRec.Primary_Dell_Attendee__c,
                                                                      Customer_Attendee2__c = trpRec.Customer_Attendee2__c);
        
        
        
        try {
            insert objtrpRec;
        }        
        catch (AuraHandledException ex) {
            system.debug(ex);
        }
    }
    
    // Method to fetch the list of options for Type picklist on lightning component
    
    @AuraEnabled
    public static List < String > getGoalOptions() { 
        
        List < String > listAllGoals = new list < String > (); 
        Schema.sObjectType objType = CustomerInteraction__c.getSObjectType();        
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > mapField = objDescribe.fields.getMap();
        
        list < Schema.PicklistEntry > listValues =
            mapField.get('Goal_Objective__c').getDescribe().getPickListValues();
        
        
        for (Schema.PicklistEntry a: listValues) {
            listAllGoals.add(a.getValue());
        }        
        listAllGoals.sort();
        return listAllGoals;
    }
    
    // Method to fetch the list of options for Goal picklist on lightning component
    
    @AuraEnabled 
    public static List < String > getTypeOptions() { 
        
        List < String > listAllTypes = new list < String > (); 
        Schema.sObjectType objType = CustomerInteraction__c.getSObjectType();        
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > mapField = objDescribe.fields.getMap();
        
        list < Schema.PicklistEntry > listValues =
            mapField.get('Type__c').getDescribe().getPickListValues();
        
        
        for (Schema.PicklistEntry a: listValues) {
            listAllTypes.add(a.getValue());
        }
        listAllTypes.sort();
        return listAllTypes;
    }
    
    // Method to fetch the account based on the search term mentioned
    
    @AuraEnabled
    public static List<Account> getAccountList(string searchstring){
        
        string strSearchkey = searchstring+'%';
        String strSearchQuery =  'select id, Name from Account where Name LIKE: strSearchkey limit 5';
        List <Account> listAccount = Database.query(strSearchQuery);
        return listAccount;        
    }   
}