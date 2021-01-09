/*
    Monthly Maintenance SP3
    CR No.  8548, Marketing profiles to update Project Tag field in Opportunity
*/

public without sharing class opptyProjectTagCtlr {
    
    public Opportunity oppRecord{get;set;}
    public String projectTag{get;set;}
    string oppId;
    Boolean Idfound{get;set;}
    public opptyProjectTagCtlr()
    {
        Idfound=false;
        if(ApexPages.currentPage().getParameters().containsKey('id'))
          {
          oppId=ApexPages.currentPage().getParameters().get('id');
            Idfound=true;
            oppRecord=[select id,Project_Tag__c,Deal_ID__c from Opportunity where id=: oppId];
            projectTag='';
             if(oppRecord.Project_Tag__c!=null) 
                 projectTag=oppRecord.Project_Tag__c;
        }
        else
        {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Pass opportunity Id to access page.'));
            return ;
        
        }
    }
    
    
       public PageReference doCancel()
       {
       
           return new PageReference ('/'+oppRecord.Id);
       }
       
       public PageReference doSave()
       {
       
           if(projectTag.length()>255)
           {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING, 'Project Tag: data value too large:(max length=255)' ));
               return null;
           }
          try{
           oppRecord.Project_Tag__c=projectTag;
           update oppRecord;
            return new PageReference ('/'+oppRecord.Id);
           }
           catch(DMLException e)
           {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING, e.getMessage()));
               return null;
           }
          
           
       }

}