public without sharing class ChannelProgramFieldDisplay{
public boolean hasContractedReseller{get;set;}
public list <Qualified_Program__c > Cqp {get; set;}
public string  opptyname {get; set;}

    public  ChannelProgramFieldDisplay(ApexPages.StandardController controller){
    Cqp = new list<Qualified_Program__c>();    
    hasContractedReseller = true;
    opportunity opp = [select Name from opportunity where id =: ApexPages.currentPage().getParameters().get('cid')];
    opptyname = opp.name;
    Set<String> LastSet = new Set<String>();
    for(Qualified_Program__c qlfprd: [select Deal_Program__c,Channel_Program_Name__c,opportunity__r.name,Program_Description_From_Channel_Program__c   from Qualified_Program__c where Opportunity__c  =: ApexPages.currentPage().getParameters().get('cid') order by Deal_Program__r.Deal_Program_Name__c asc ]) 
    {
       if(LastSet.add(qlfprd.Channel_Program_Name__c))
         Cqp.add(qlfprd);
    }
    
    if(Cqp == null ||  Cqp.size() == 0){
    hasContractedReseller = false;
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, Label.Qualifeid_Program_Error_Msg));
    
    }        
  }
}