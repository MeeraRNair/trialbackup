/*
 * Author   : Kishore Dupam
 * Purpose  : Engage Channel Button on Deal Registration page
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12728     16.10       05-04-2016      Devika          Updated the pageReference to redirect to opp detail page.            
            Defect 4454190           26-12-2017      Rajashekar      Defect 4454190:Displaying exception when clicked on Accept button in Partner portal for Engage Channel.
                                                                       Added Excetion handling (try - catch)          
 */

public class EngageChannelParnterRejection {
    
    Public Id channeloptyId;
    Public Opportunity channelOpp{get;set;}
    public String strdata{get;set;}
    Public boolean bshow{get;set;}
   
    public EngageChannelParnterRejection(ApexPages.StandardController controller) {
         bshow=false;      
        channeloptyId = ApexPages.currentpage().getParameters().get('Id');
        channelOpp = new Opportunity();

    }
        Public Pagereference saveOpp(){  // Added by Rajashekar kura  ::  Defect 4454190 
        If(strdata == null || strdata==''){
        bshow=false;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Required_Error));     
              return null; 
        }
        else{
       try{       
          
        if(channeloptyId != null){
           channelOpp = [SELECT id,RecordTypeId,Associated_Opportunity__r.Name,Associated_Opportunity__r.Engage_Channel_Rejection_Reason__c,Associated_Opportunity__r.Number_of_Engage_Channel_Rejections__c,Engage_Channel_Status__c,Associated_Opportunity__c,Deal_Registration_Status__c, Rejection_Reason_Code__c,Other_Rejection_Reason__c, StageName FROM Opportunity WHERE id=: channeloptyId];        
           system.debug('====Channel Opp deal'+channelOpp);
           }
           channelOpp.StageName = 'Lost, Cancelled - 0%';
            channelOpp.Engage_Channel_Status__c = 'Rejected';
            channelOpp.Reason_Won_Lost__c='Deal moved from direct to partner';
            channelOpp.Competitor_Lost_To__c='Unknown';
          
            System.debug('$$$channelOpp'+channelOpp);
            update channelOpp;
             Opportunity segmentOpp = new Opportunity(id = channelOpp.Associated_Opportunity__c);
            //segmentOpp.StageName='Plan - 1%';
         if(!Test.isRunningTest()){       OpportunityFieldHistory  ofh=[Select Id, CreatedById, CreatedDate,Field, NewValue, OldValue from OpportunityFieldHistory Where Field = 'StageName' and OpportunityId=:channelOpp.Associated_Opportunity__c order by CreatedDate desc limit 1];
            segmentOpp.StageName=String.valueof(ofh.OldValue); 
            }else{  
            segmentOpp.StageName='Plan - 1%';
            }
            segmentOpp.Engage_Channel_Status__c = 'Rejected';
             
         if(channelOpp.Associated_Opportunity__r.Engage_Channel_Rejection_Reason__c == ''|| channelOpp.Associated_Opportunity__r.Engage_Channel_Rejection_Reason__c== null){
               segmentOpp.Engage_Channel_Rejection_Reason__c=strdata +' '+'- Rejected by'+' '+UserInfo.getName()+' on '+DateTime.now();
              segmentOpp.Number_of_Engage_Channel_Rejections__c = 1;
           }
           else{
               segmentOpp.Number_of_Engage_Channel_Rejections__c = channelOpp.Associated_Opportunity__r.Number_of_Engage_Channel_Rejections__c+1;
               segmentOpp.Engage_Channel_Rejection_Reason__c=strdata+' '+'- Rejected by'+' '+UserInfo.getName()+' on '+DateTime.now()+','+channelOpp.Associated_Opportunity__r.Engage_Channel_Rejection_Reason__c;
           }
          List<String> listObjAPINames = new List<String>{'Opportunity'};
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        update segmentOpp;
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
       
            System.debug('$$$segmentOpp'+segmentOpp);
        //v1.0 return new PageReference('/006/o');
        return new PageReference('/'+channeloptyId);
        }
        Catch(Exception ex)
        {   bshow=true;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getdmlMessage(0)));     
              return null; 
        }
        return new PageReference('/'+channeloptyId);
       // return null;
    }
}
}