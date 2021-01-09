public class Dealreg_AcceptExtension{
    public id OptyID{get;set;} 
    public Boolean bvalidApprover {get;set;}
    Public Opportunity channelOpp{get;set;}
public Dealreg_AcceptExtension(ApexPages.StandardController controller) {
            
    OptyID = ApexPages.currentpage().getParameters().get('Id');
    channelOpp = new Opportunity();
}
Public Pagereference saveOpp(){
    List<String> listObjAPINames = new List<String>{'Opportunity'};
    TriggerExecutionController.setSkipAllTriggers(true);
    SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);

    pagereference pgref = new pagereference('/'+OptyID);
    pgref.setRedirect(true);
    bvalidApprover =isValidApprover();
    if(OptyID != null && (bvalidApprover || UserInfo.getProfileId() == System.Label.System_Administrator_Profile_Id ))  
    {    
    channelOpp = [SELECT id,RecordTypeId,StageName,Deal_Registration_Reviewer__c,Reviewer_Accepted_Date_Time__c FROM Opportunity WHERE id=: OptyID];        
    system.debug('====Channel Opp deal'+channelOpp);
    channelOpp.Deal_Registration_Reviewer__c = userInfo.getUserId();
    channelOpp.Reviewer_Accepted_Date_Time__c = system.now();
    update channelOpp;
    ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
    TriggerExecutionController.setSkipAllTriggers(false);

    return pgref;
    }else
    {ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You are not a valid approver for this deal.');
    ApexPages.addMessage(myMsg);
    return null;
    }
        
}
     
public Boolean isValidApprover(){
    list<ProcessInstance> listPI = [SELECT Id, Status,(SELECT Id, ActorId, OriginalActorId FROM StepsAndWorkItems)
                                      FROM ProcessInstance WHERE Status = 'pending' AND TargetObjectId = :OptyID LIMIT 1];  
    list<ProcessInstanceHistory > listPIH = new list<ProcessInstanceHistory>();  
    if(listPI!=null && listPI.size() > 0) {                   
        for(ProcessInstance p : listPI){            
        listPIH.addall(p.StepsAndWorkItems);          
        }
    }
      
    Set<string> setactorid = new Set<string>();
    if(listPIH!=null && listPIH.size() > 0) {
        for(ProcessInstanceHistory pih: listPIH){
            setactorid.add(pih.actorId);
            setactorid.add(pih.OriginalActorId);
        }
    }

    system.debug('actoridset'+setactorid);
    Boolean bisValidApprver ;
    If( setactorid.contains(Userinfo.getUserId()) ){
        bisValidApprver = true;
    }else{
    bisValidApprver = false;
    }
    return bisValidApprver;
}
}