public class UserDealAccess implements Queueable {
    
    public String Operation_type {get;set;}
    public contact cont {get;set;}
    public user us {get;set;}
    public list<String> selectedDealTypes {get;set;}
    public string opereation_type{get;set;}
    public string Accid{get ; set ;}
    
    public UserDealAccess(String Operation_type ,Contact cont,User us,list<String> selectedDealTypes,String opereation_type, string Accid ){
        this.Operation_type  = Operation_type;
        this.cont = cont;
        this.us = us;
        this.selectedDealTypes  = selectedDealTypes ;
        this.opereation_type = opereation_type;
        this.Accid = Accid;
        
        
    }
    public void execute(QueueableContext context) {
        System.debug('execute'+Operation_type);
        if(Operation_type  == 'show'){
            shareAccess(cont,us,selectedDealTypes,opereation_type,Accid );
        }
        else if(Operation_type == 'remove'){
            removeAccess(us,cont,Accid);
        }
    }
    public void updateContact(Contact cont){
        
        TriggerExecutionController.setSkipContactTriggers(true);
        update cont;
        TriggerExecutionController.setSkipContactTriggers(false);   
    }
    public pageReference removeAccess(user us,contact con,string selectedaccid){
        
        System.debug('removeAccess');
        List<Opportunity> AllOpportunities = [select id from Opportunity where PartnerAccountId =: selectedaccid];
        List<id> oppids = new List<id>();
        for(Opportunity op : AllOpportunities ){
            oppids.add(op.id);
        }
        System.debug('oppids'+oppids);
        list<OpportunityShare> oppShare = [SELECT Id 
                                           FROM OpportunityShare where OpportunityId IN:oppids AND 
                                           UserOrGroupId =:us.Id and RowCause !='Owner' and RowCause ='Manual'];
        List<ContactOpportunityStages__c> listConOppty = [select id,Opportunity_Stage__c,SalesmotionAccount__c 
                                                          from ContactOpportunityStages__c 
                                                          where contact__c =: con.id 
                                                          and SalesmotionAccount__c =:selectedaccid
                                                         ];
        List<ContactOpportunityStages__c> listConOpptyDel = new List<ContactOpportunityStages__c>(); 
        System.debug('oppShare'+oppShare.size()+'listConOppty'+listConOppty.size());
        if(oppShare.size()>0){
            Database.Delete(oppShare,false);
            for(ContactOpportunityStages__c conOppty : listConOppty){
                if(conOppty.SalesmotionAccount__c == selectedaccid){
                    listConOpptyDel.add(conOppty);
                }
                
            }
            if(listConOpptyDel.size() > 0){
                Database.Delete(listConOpptyDel,false);
                
            }
            List<ContactOpportunityStages__c> listConOppty2 = [select id,Opportunity_Stage__c,SalesmotionAccount__c 
                                                               from ContactOpportunityStages__c 
                                                               where contact__c =: con.id 
                                                              ];
            if(listConOppty2.size() == 0){
                con.View_All_deals_Access__c = false;
                con.DealAccess_jobId__c  = '';
                con.Have_Dealtype_Access__c ='';
                TriggerExecutionController.setSkipContactTriggers(true);
                updateContact(con);
                TriggerExecutionController.setSkipContactTriggers(false);   
                
                
            }
        }
        
        return null;
        
    }
    
    
    public pageReference shareAccess(contact con,User us,list<String> dealTypes,String opereation_type,string Accountid){
        System.debug('shareAccess'+dealTypes+'::'+con.Partner_User__c+'::'+userinfo.getUserId()+'::'+Accountid);
        map<Id,Opportunity> mapOppty = new  map<Id,Opportunity>([select id,OwnerId 
                                                                 from Opportunity 
                                                                 where PartnerAccountId =: Accountid 
                                                                 and StageName in :dealTypes 
                                                                 and OwnerID != :con.Partner_User__c ]);
        
        List<OpportunityShare> listOpptyShare = new list<OpportunityShare>();
        System.debug('AllOpportunities'+mapOppty.keySet());
        if(mapOppty.keySet().size() > 0){
        //if(mapOppty.values().size() > 0){
           for(String EachOppoty: mapOppty.keySet()){
          // for(Opportunity EachOppoty: mapOppty.values()){
                //System.debug('mapOppty'+mapOppty.get(EachOppoty).createdById);
               if(userinfo.getUserId() != con.Partner_User__r.id){
               // if(EachOppoty.ownerId!= con.Partner_User__r.id){
                    OpportunityShare opptyShare = new OpportunityShare();
                    opptyShare.OpportunityId = EachOppoty;
                    opptyShare.UserOrGroupId = us.Id;  
                    opptyShare.OpportunityAccessLevel = 'Read';
                    
                    listOpptyShare.add(opptyShare);
                }
                
            }
        }
        String  strStages = '';
        for(string strDeal: dealTypes){
            strStages += strDeal+';';
        }
        strStages = strStages.removeEnd(';');
        System.debug('stages>>'+strStages);
        system.debug('>>>>>>>>>>>>'+Accountid);
       
        System.debug('AllOpportunitiesShare::'+ listOpptyShare); 
        if(listOpptyShare.size() > 0){
            System.debug('>>>>> '+ database.insert(listOpptyShare,false));
            List<ContactOpportunityStages__c>  listConOpp = new List<ContactOpportunityStages__c>();
            listConOpp = [select id,Opportunity_Stage__c,SalesmotionAccount__c 
                          from ContactOpportunityStages__c 
                          where contact__c =: con.id 
                          and SalesmotionAccount__c =: Accountid];       
            if(listConOpp.size() == 0){
                ContactOpportunityStages__c conopp1= new ContactOpportunityStages__c();
                
                conopp1.contact__c = con.id;
                conopp1.Opportunity_Stage__c = strStages;
                conopp1.SalesmotionAccount__c = Accountid;
                listConOpp.add(conopp1);
            }
            else{
                strStages = strStages.removeEnd(';');
                listConOpp[0].contact__c = con.id;
                listConOpp[0].Opportunity_Stage__c = strStages;
                listConOpp[0].SalesmotionAccount__c = Accountid;
                //database.insert(conopp,false);
            }
            System.debug('listConOpp[0]'+listConOpp[0]);
            upsert listConOpp[0];
            con.View_All_deals_Access__c = true;
            con.DealAccess_jobId__c  = '';
            TriggerExecutionController.setSkipContactTriggers(true);
                updateContact(con);
            TriggerExecutionController.setSkipContactTriggers(false);
            
        }
        return null;
    }
}