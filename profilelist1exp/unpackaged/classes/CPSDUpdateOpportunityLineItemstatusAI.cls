public class CPSDUpdateOpportunityLineItemstatusAI {
    // Added by Ershad - CPSD integration status Flag to Waiting Sync on Account,Opportunity and Opportunity Product
 public static void cpsdopportunityFlagUpdate(list<OpportunityLineItem> listLineItems){
	Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE);
	   Set<id> setoppidset = new Set<id>();
       Set<Id> setoppset = new Set<Id>();
	   Set<id> setaccset=new Set<Id>();
	   List<Opportunity> listopp1=new List<Opportunity>();
	   List<OpportunityLineItem> listolit=new List<OpportunityLineItem>();
	   List<Account> listacc=new List<Account>();
       //List<Opportunity> listoppList = new List<Opportunity>();
       Map<id,Opportunity> mapOpp;
       for(OpportunityLineItem  oli : listLineItems){
           if(oli.Sales_Configurator_Identifier__c=='ACT'){
            setoppidset.add(oli.OpportunityId);
           }  
        }
     mapOpp = new Map<id,Opportunity>([Select id,AccountId,RecordTypeId,CPSD_Integration_Status__c,Bill_To_Ship_To_Comments__c from Opportunity where RecordTypeId=:newOppRecordTypeID and id IN:setoppidset]);
     system.debug('CPSD-INTEGRA>>>>>>>>>'+mapOpp.size());
		 if(Recursion_check.bisFirstTime)
             {
           Recursion_check.bisFirstTime = false;
		   for (OpportunityLineItem  oli : listLineItems){
		     if(oli.Sales_Configurator_Identifier__c=='ACT' && (mapOpp.size()>0 && mapOpp.get(oli.OpportunityId).AccountId !=Null) && mapOpp.get(oli.OpportunityId).RecordTypeId ==newOppRecordTypeID){
			     Id oppid = mapOpp.get(oli.OpportunityId).id;
                 setoppset.add(oppid);
                 system.debug('--->>'+setoppset);
                 OpportunityLineItem ool=new OpportunityLineItem();
				 ool.id=oli.id;
				 ool.CPSD_Integration_Status__c='Waiting Sync';
				 listolit.add(ool);
                 system.debug('---hello'+listolit);
			   }
			 }
			 if(listolit.size()>0 && listolit.size()!=Null){
                  TriggerExecutionController.setSkipAllTriggers(true);
                  system.debug('inside OLI size>>>'+listolit);
                  Database.update(listolit,False); 
                  TriggerExecutionController.setSkipAllTriggers(false);
             }
            
            if(setoppset.size()>0 && setoppset.size()!=Null){
                system.debug('inside Opty'+setoppset);
			  for(Opportunity opds:[select id,CPSD_Integration_Status__c,Bill_To_Ship_To_Comments__c,AccountId from Opportunity where Id in:setoppset])
                {
			    Id accid=opds.AccountId;
				setaccset.add(accid);
				Opportunity opty=new Opportunity();
                opty.id=opds.id;
                opty.CPSD_Integration_Status__c='Waiting Sync';
                listopp1.add(opty);	
                system.debug('inside Opty1'+listopp1);    
			   }
			   
			}
			
			if(listopp1.size()>0){
              TriggerExecutionController.setSkipAllTriggers(true);
               system.debug('inside Opty3'+listopp1);    
			  Database.update(listopp1,False);
              TriggerExecutionController.setSkipAllTriggers(false);			
             }
			 
			 
            if(setaccset.size()>0){
                 
			 for(Account accd:[ select id,CPSD_Integration_Status__c,CPSD_Account_ID__c from Account where Id in :setaccset])
             {
			 if(accd.CPSD_Account_ID__c==Null ||accd.CPSD_Account_ID__c==''){
			  Account abc=New Account();
			  abc.id=accd.id;
			  abc.CPSD_Integration_Status__c='Waiting Sync';
			  listacc.add(abc);
                 
			     }
			 }
                
             if(listacc.size()>0){
			  TriggerExecutionController.setSkipAllTriggers(true);  
              Database.update(listacc,False); 
              TriggerExecutionController.setSkipAllTriggers(false);
			 } 
        
           }
        }
    }
}