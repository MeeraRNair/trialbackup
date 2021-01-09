public class CateringBreakWrapper {

    public boolean isChecked {get; set;}
    //Name,Break_Type__c,Description__c,Price__c,Engagement_Type__c
    public Agenda_Content__c agendaContent {get; set;}
    
    public CateringBreakWrapper (Agenda_Content__c c) {
            agendaContent = c;
            isChecked = false;
    }
    
    



}