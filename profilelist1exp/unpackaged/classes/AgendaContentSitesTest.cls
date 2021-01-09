@isTest
private class AgendaContentSitesTest{
    static Agenda_Content__c agendaContectObj=new Agenda_Content__c();
    static Event_Location__c eventLocation=new Event_Location__c();
    
    public static  testMethod void updateSitesMultiPickListTest(){
    
        RecordType ELRT=[Select Name, Id From RecordType where sObjectType='Event_Location__c'    
        and name='Sites' limit 1];
    
        agendaContectObj.name='Test agendacontent';
        agendaContectObj.Engagement_Type__c='EBC';
        agendaContectObj.Sites__c='Site1';
        
        insert agendaContectObj;
        
        eventLocation.Name='Test event location';
        eventLocation.region__c='APJ';
        eventLocation.recordTypeId=ELRT.Id;
        
        insert eventLocation;  
        
    }    
}