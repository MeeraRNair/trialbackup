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
public class EngageChannelParnterApproval {
    
    Public Opportunity channelOpp{get;set;}
    Public Id channeloptyId{get; set;}
     Public boolean bdisplayPopup1 {get; set;}
     public boolean bdisplayPopup {get; set;} 
     public boolean bdisplayPopup2 {get; set;} 
     // public boolean displayPop {get;set;}
    public EngageChannelParnterApproval(ApexPages.StandardController controller) {
        
        channeloptyId = ApexPages.currentpage().getParameters().get('Id');
        channelOpp = new Opportunity();
        
        
    }
    
    Public Pagereference saveOpp(){
           if(channeloptyId != null){
         channelOpp = [SELECT RecordTypeId ,Name,Associated_Opportunity__r.Name,Number_of_Line_Items__c,Associated_Opportunity__c,Deal_Registration_Status__c, Rejection_Reason_Code__c,Other_Rejection_Reason__c, StageName FROM Opportunity WHERE id=: channeloptyId];        
             if(channelOpp.Number_of_Line_Items__c != 0){
         
            channelOpp.Engage_Channel_Status__c = 'Approved';
            try{          // Added by Rajashekar kura  ::  Defect 4454190  
              update channelOpp;               
              System.debug('###channelOpp'+channelOpp);
              return new PageReference('/apex/AVSSuggestionforOpportunity?source=Accept&id='+channeloptyId);
             // return new PageReference('/'+channeloptyId);
            }Catch(Exception ex){    bdisplayPopup1 = true;   bdisplayPopup=false; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getdmlMessage(0)));            }
            }
        else{
         bdisplayPopup1 = true;
         bdisplayPopup=false;
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.Label.Add_Product_To_Opportunity));
        } 
        }
       // return new PageReference('/'+channeloptyId);
        return null;
    }
    Public PageReference cancelOppAction(){  
        bdisplayPopup =false;      
        return new PageReference('/'+channeloptyId);
    }
     Public PageReference addDealAccess(){        
        return new PageReference('/apex/DistributorResellerSelectionPage?id='+channeloptyId);
    }
        
      public PageReference showPopup() { 
            if(channeloptyId != null){  
        channelOpp = [SELECT RecordTypeId ,Name,Associated_Opportunity__r.Name,Associated_Opportunity__c,Distributor_Reseller_Name__r.Name,
                      Deal_Registration_Status__c, Rejection_Reason_Code__c,Other_Rejection_Reason__c, StageName, 
                      Distributor_Name__c  FROM Opportunity WHERE id=: channeloptyId];
        if(channelOpp.Distributor_Name__c.contains('Distribution')){
            bdisplayPopup = true;
            bdisplayPopup2 =true;
            return null;
        }else{
        bdisplayPopup = true;
            return null;
           // channelOpp.Engage_Channel_Status__c = 'Approved';
         //   try{          // Added by Rajashekar kura  ::  Defect 4454190  
            //  update channelOpp;               
           //   System.debug('###channelOpp'+channelOpp);
           //   return new PageReference('/apex/AVSSuggestionforOpportunity?source=Accept&id='+channeloptyId);
             // return new PageReference('/'+channeloptyId);
          //  }Catch(Exception ex){  
          //  bdisplayPopup1 = true;
          //  bdisplayPopup=false; 
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getdmlMessage(0)));            }
        }
        
        }
        return null;
    }
}