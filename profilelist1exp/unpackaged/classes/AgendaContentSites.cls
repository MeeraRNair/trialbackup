public Class AgendaContentSites{

    public static void updateSitesMultiPickList(List<event_Location__c> eventList,String siteNames){
        String oldValue;
        List<Agenda_Content__c> updateList=[select id,name,Sites__c from 
        Agenda_Content__c];        
        for(Agenda_Content__c agendaContent:updateList){
            oldValue=agendaContent.Sites__c;
            if(oldValue==null){
                oldValue=siteNames;
            }
            if(oldValue!=null){
                oldValue=oldValue+';'+siteNames;
            }                                
            agendaContent.Sites__c=oldValue;           
        } 
       
        if(updateList.size()>0){
            update updateList;
        }
                          
    } 
      
}