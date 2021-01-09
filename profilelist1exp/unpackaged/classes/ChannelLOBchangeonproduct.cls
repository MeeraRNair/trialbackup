public without sharing class ChannelLOBchangeonproduct{

 @InvocableMethod
public static void specialityQueue(List<id> productids){
       System.debug('---Helloo---'+productids);
      List<OpportunityLineItem> opplineitems = new List<OpportunityLineItem>();
      List<Product2> prods = [select id,Channel_Product_LOB__c from Product2 where id IN : productids];
       Id NewOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity', TRUE);
       Id ExistingECOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer','Opportunity', TRUE);
       Id SubmittedOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted','Opportunity', TRUE);
       
       
      opplineitems = [select id,OpportunityID,Opportunity.RecordTypeId from OpportunityLineItem where Product2Id IN : productids AND Opportunity.StageName != 'Lost, Cancelled - 0%' AND (Opportunity.RecordTypeId =: NewOppRecordTypeID OR Opportunity.RecordTypeId =: ExistingECOppRecordTypeID OR Opportunity.RecordTypeId =: SubmittedOppRecordTypeID )];  

       System.debug('---Helloo---'+prods );
       System.debug('---Helloo---'+opplineitems);
       System.debug('---Helloo---'+opplineitems.size());
                                                                        
                                                                         
      set<id> oppids = new set<id>();
      for(OpportunityLineItem  op : opplineitems) {
           oppids.add(op.OpportunityID );
      }

       System.debug('---Helloo---'+oppids);
       System.debug('---Helloo---'+oppids.size());
      
      List<opportunity> newopp  = new List<opportunity>();
      for( Opportunity opp : [select name, id,Specialty_Queue__c, (select id,Channel_Product_LOB__c from opportunitylineitems) from opportunity where id IN : oppids ])
      {
          
          integer i = 0;
          for( OpportunityLineItem oli : opp.opportunitylineitems )
          {
              if(oli.Channel_Product_LOB__c!= null && ((oli.Channel_Product_LOB__c).toLowerCase().contains('storage')|| (oli.Channel_Product_LOB__c).toLowerCase().contains('solution') ))
            {                
                 i++;
            }
          }
         //lobmap.put(opp.id,str); 
         if(i == 0){
             opp.Specialty_Queue__c = 'No';
         }else{
             opp.Specialty_Queue__c = 'Yes';
         }  
         newopp.add(opp);  
      }
      
      if(newopp != null && newopp.size() > 0)
      {
      TriggerExecutionController.setSkipAllTriggers(true);
       database.update(newopp,false);
      TriggerExecutionController.setSkipAllTriggers(false);
      }
  
  }




}