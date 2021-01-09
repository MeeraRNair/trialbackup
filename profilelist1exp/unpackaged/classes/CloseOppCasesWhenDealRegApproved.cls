public class CloseOppCasesWhenDealRegApproved{
      //Added by Rajdeep for closing cases when opportunity deal registration status is approved
      public static void closeOppCases(map<Id,Opportunity> mapNewOpportunities,map<Id, Opportunity> mapOldOpportunities){
          set<Id> setOppIds = new set<Id>();
          list<Case> listCasesToUpdate = new list<Case>();
          for(Opportunity opp: mapNewOpportunities.values()){
              if((opp.Deal_Registration_Status__c =='Approved' || opp.Deal_Registration_Status__c =='Rejected') && opp.Deal_Registration_Status__c != mapOldOpportunities.get(opp.Id).Deal_Registration_Status__c){                 setOppIds.add(opp.Id);   }
          }
          for(Case c : [SELECT Id,Status,Opportunity_Title__c FROM Case WHERE Opportunity_Title__c IN :setOppIds  AND Status IN('Open')]){
              if(mapNewOpportunities.containskey(c.Opportunity_Title__c)){ c.Status = 'Closed(No Response)';             listCasesToUpdate.add(c);    }
          }
         // try{
              TriggerExecutionController.setSkipAllTriggers(true);
              Update listCasesToUpdate;
              TriggerExecutionController.setSkipAllTriggers(false);
         // }
        //  catch(DmlException dmlex){
         //     system.debug('Exception occur In closeCasesWhenOppDealRegApproved class --> closeCases method Exception line '+dmlex.getLineNumber()+'Exception '+dmlex);
        //  }
      }
}