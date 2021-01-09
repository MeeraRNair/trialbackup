public without sharing class  OpportunityShareAccessForContacts{
    
    public Contact con {get;set;}
    public User user{get;set;}
    public boolean showAction{get;set;}
    public map<String,Integer> stageAndCount;
    public Integer OpptyShareCount {get;set;}
    public list<String> dealTypes {get;set;}
    public Boolean Deal_access_feature {get;set;}
    public Boolean previousActionUnderProcesss {get;set;}
    public String dealAccessRequest {get;set;}
    public boolean showChart {get;set;}
    
    /* ******************RAM Variables******************************* */
    public list<Partner_Track__c> ptlist{get;set;}
    public list<account> acclist{get;set;}
    public Id partnertrackId{get;set;}
    public set<string> eligibleTracksIdList;
    public string selectedtrack {get ; set ;}
    public SelectOption[] alleligibletracks{get;set;}
    public SelectOption[] alleligibleAccounts{get;set;}
    public string selectedAccount {get ; set ;}
    public boolean Removebtn {get ; set ;}
    public boolean removeaccessbool {get ; set ;}
    public ContactOpportunityStages__c conopplist {get ; set ;}
    //getting stages from ContactOpportunityStages for the selected track and account
    public List<ContactOpportunityStages__c> conopplist1{get ; set ;}
    public boolean showaccounts {get ; set ;}
    public String accessType {get ;set;}
    public OpportunityShareAccessForContacts(ApexPages.StandardController controller) {
        previousActionUnderProcesss  = false;
        conopplist = new ContactOpportunityStages__c();
        alleligibletracks= new SelectOption[]{};
        alleligibleAccounts = new SelectOption[]{};
        selectedtrack = '';
        showChart  = false;
        accessType = ApexPages.Currentpage().getParameters().get('access');
        System.debug('accessType'+accessType);
        Deal_access_feature  =   System.Label.DealAccess_option == 'True' ?true:false;
        dealTypes  = new list<String>();
        stageAndCount = new map<String,Integer>();
        OpptyShareCount  = 0;
        if(accessType  == 'remove')
        {
           //showAction = true;    showChart  = false;    dealAccessRequest  = 'Remove Deal View Access';
            removeaccessbool = true;
            
        }else{
            //Deal_access_feature  =  false;
            dealAccessRequest  = 'Add Deal View Access';
            showChart  = false;
            showAction = false;
        }
        System.debug('dealAccessRequest'+dealAccessRequest);
        con  = (Contact)controller.getRecord();
        con = [SELECT Id,name,AccountId,Preferred_Track__c,EligibleTracks__c,View_All_deals_Access__c,
               Have_Dealtype_Access__c,DealAccess_jobId__c,Partner_User__r.id   
               FROM Contact 
               WHERE Id=:con.Id];
        try{
            user = [SELECT id
                    FROM User 
                    WHERE ContactId=:con.id];
        }catch(Exception ex){}
        System.debug('>>>>>>> '+con.AccountId);
        if(con.DealAccess_jobId__c  !='' && con.DealAccess_jobId__c   !=null){
            previousActionUnderProcesss  = true;
        }

        eligibleTracksIdList = new set<string>() ;
        if(con !=null){
            if(con.EligibleTracks__c != null){
                if(con.EligibleTracks__c.contains(';')){
                    eligibleTracksIdList.addAll(con.EligibleTracks__c.split(';'));
                 }
                else{
                    eligibleTracksIdList.add(con.EligibleTracks__c.trim());
                }
                System.debug('eligibleTracksIdList'+eligibleTracksIdList);
                alleligibletracks.add(new SelectOption('--None--', '--None--' ));
                for(Partner_Track__c record: [SELECT Id,Name,Master_Group_Id__c,Track_Id__c,Track_Name__c,Partner_Track_Name__c FROM Partner_Track__c WHERE Id IN: eligibleTracksIdList]) {
                    if(String.isNotBlank(record.Track_Name__c)){
                        alleligibletracks.add(new SelectOption(record.Id, record.Track_Name__c));
                       
                        
                    }
                }
                system.debug('.............'+alleligibletracks );
            }       
        }
       
    }
    
    public void getAccounts(){
        System.debug('getAccounts'+selectedtrack);
        System.debug('showchart::'+showchart);
        alleligibleAccounts = new SelectOption[]{};
        conopplist = new ContactOpportunityStages__c();
        //alleligibleAccounts.add(new SelectOption('--None--', '--None--' ));
        if(selectedtrack != '--None--' && String.isNotBlank(selectedtrack)){
            showchart=false;SelectedAccount='';showaccounts = true;showAction = false;OpptyShareCount  = 0;Removebtn=false;
            for(Account acc : [Select id,Name from Account Where Partner_Track__c =: selectedtrack]){
                alleligibleAccounts.add(new SelectOption(acc.id,acc.name));
            } 
           
        }
        
          //conoppstages();
    }
    public void conoppstages(){
        System.debug('conoppstages');
        OpptyShareCount  = 0;getPieData();
        System.debug('showchart'+showchart+'SelectedAccount'+SelectedAccount);
        conopplist1 = new List<ContactOpportunityStages__c>();
        if(string.isNotBlank(SelectedAccount) && SelectedAccount !='--None--'){
            showchart = true;
            conopplist1 = [SELECT id,Opportunity_Stage__c 
                           FROM ContactOpportunityStages__c 
                           WHERE contact__c =: con.id 
                           AND SalesmotionAccount__c =: SelectedAccount];
            system.debug('conopplist::'+conopplist);
            if(conopplist1.size() > 0 ){
                conopplist = conopplist1[0];
                getChangeData();
                if(accessType == 'remove'){
                    removebtn=true;showAction = false;
                }
            }
            else{
                conopplist = new ContactOpportunityStages__c();
                removebtn=false;showAction = false;
            }
        }
        else{
             showchart = false;conopplist = new ContactOpportunityStages__c();
             removebtn=false;showAction = false;
        }
        
        
    }
    public UserDealAccess us;
    
    public void processRequest(){
        System.debug('processRequest');
        System.debug('accessType'+accessType);
        System.debug('dealTypes'+dealTypes);
        if(accessType  != ''){
            us = new UserDealAccess(accessType,con,user,dealTypes,'ASYNC',selectedAccount);
            //if(accessType  == 'show'){     
            if(OpptyShareCount > = Integer.valueOf(System.label.OpportunityShare_threshould)){
                 System.debug('OpptyShareCount'+OpptyShareCount);
                //if selected deals type count is greater than threshould run Quable Job
                ID jobID = System.enqueueJob(us);     
                con.DealAccess_jobId__c = jobID+'__access' ;   
                us.updateContact(con);
                // goBack();
            }
            else{
                System.debug('SYNC');
                //if selected deals type count is less than threshould run process Sync.
                us.shareAccess(con,user,dealTypes,'SYNC',selectedAccount );
                //   goBack();
                showAction  = false;
                //selectedaccount = '--None--';selectedtrack ='--None--';
                removebool = false;addbool = false;
                //showchart = false;
                //conopplist = new ContactOpportunityStages__c();
            }
            
            
        }
        else{
            goBack();
        }
        
    }
    //Method to show remove alert
    public void removealrt(){
        removebool = true;addbool = false;
        showAction = true;  dealAccessRequest  = 'Remove Deal View Access';removebtn = false;
    }
    
    //Method to remove Access
    public void removeAccess(){
        
        integer sharedDealsCount = [SELECT count()  FROM OpportunityShare where UserOrGroupId =:user.Id and RowCause !='Owner' and RowCause ='Manual'];
        us = new UserDealAccess(accessType,con,user,dealTypes,'ASYNC',selectedAccount);   
        if(sharedDealsCount > = Integer.valueOf(System.label.OpportunityShare_threshould)){
            //if selected deals type count is greater than threshould run Quable Job
            ID jobID = System.enqueueJob(us);   con.DealAccess_jobId__c = jobID+'__remove';  us.updateContact(con);
            //  goBack();
        }else{
            //if selected deals type count is less than threshould run process Sync.
            us.removeAccess(user,con,selectedaccount);
            removebool = false;addbool = false;
            
            //   goBack();
        }  
        
        List<ContactOpportunityStages__c> conopprmv = [select id,Opportunity_Stage__c,SalesmotionAccount__c 
                                                       from ContactOpportunityStages__c 
                                                       where contact__c =: con.id and SalesmotionAccount__c =: selectedAccount];       
        if(conopprmv.size() == 0){             
            //delete conopprmv;
            OpptyShareCount  = 0;
            Removebtn = false;showAction = false;
            //selectedaccount = '--None--';selectedtrack ='--None--';
            //showchart=false; 
            conopplist = new ContactOpportunityStages__c();
        }
        
        
    }
    public PageReference goBack(){
        System.debug('>>>>>>> in go back '+'/'+con.id);
        return new PageReference ('/'+con.id) ;
    }
    @InvocableMethod(label='Give access to deals' )
    public static Void getAccountNames(list<String>  ids) {
        try{
            System.debug('>>>>>> '+ids);
            map<String,String> OpportunityIdAndAccountsId = new map<String,String>();
            map<String,list<String>> AccountIdandOppotys = new map<String,list<String>>();
            list<String> AccountIds = new list<String>();
            
            list<Opportunity> AllOpps= [select id,name,PartnerAccountId,StageName 
                                        from Opportunity where id in:ids ];
            list<String> optyStages = new list<String>();
            
            for(Opportunity opp:AllOpps ){
                optyStages.add(opp.stageName);
                OpportunityIdAndAccountsId.put(opp.id,opp.PartnerAccountId);
                AccountIds.add(opp.PartnerAccountId);
                
                if(!AccountIdandOppotys.Keyset().contains(opp.PartnerAccountId)){
                    list<String> oppsare = new list<String>();
                    oppsare.add(opp.id);
                    AccountIdandOppotys.put(opp.PartnerAccountId,oppsare);
                    
                }else{
                    list<String> existingOpts = new list<String>();
                    
                    existingOpts = AccountIdandOppotys.get(opp.PartnerAccountId);
                    existingOpts.add(opp.id);
                    AccountIdandOppotys.put(opp.PartnerAccountId,existingOpts);
                }
            }
            List<OpportunityShare> AllOpportunitiesShare = new list<OpportunityShare>();
            
            for(Contact con:[select id,Partner_User__r.id,
                             AccountId,Have_Dealtype_Access__c  from Contact where AccountId in : AccountIds and  View_All_deals_Access__c = true and Partner_User_Deal_Registration__c = true  and Have_Dealtype_Access__c  INCLUDES (:optyStages[0])]){
                                 
                                 for(String Oppty :AccountIdandOppotys.get(con.AccountId)){
                                     if(userinfo.getUserId() != con.Partner_User__r.id){     
                                         OpportunityShare OS = new OpportunityShare();   OS.OpportunityId = Oppty;   OS.UserOrGroupId = con.Partner_User__r.id;  OS.OpportunityAccessLevel = 'Read';   AllOpportunitiesShare.add(OS);
                                         
                                     }
                                 }
                                 
                             }
            System.debug('AllOpportunitiesShare '+AllOpportunitiesShare);
            
            
            if(AllOpportunitiesShare.size()>0){
                
                try{  database.insert(AllOpportunitiesShare,false);
                    
                    
                   }catch(Exception ex){
                       System.debug('>>>>> deal share exception '+ex);
                   }
            }
            
        }catch(Exception ex){}
        
    }
    
    public List<PieWedgeData> getPieData() {
        System.debug('getPieData');
        List<PieWedgeData> data = new List<PieWedgeData>();  
        try{ 
            if(String.isNotBlank(selectedaccount)){
                System.debug('selectedAccount:'+selectedaccount);
                List<AggregateResult> ag = [SELECT StageName, COUNT(Name) 
                                            FROM Opportunity 
                                            WHERE PartnerAccountid=:selectedaccount
                                            GROUP BY StageName];
                for(AggregateResult eachag:ag){
                    data.add(new PieWedgeData(String.valueOf(eachag.get('StageName')), (Integer)eachag.get('expr0')));
                    stageAndCount.put(String.valueOf(eachag.get('StageName')), (Integer)eachag.get('expr0'));
                    
                }
                
                
            }
            
        }
        catch(exception ex){}
        return data;
    }
    //Get Partner Track records as PickList Values.
    public List<SelectOption> getPartnerTrackList() {
        system.debug('===========');
        List<SelectOption> PartnerTracks = new List<SelectOption>();
        PartnerTracks.add(new SelectOption('', '--None--'));
        
        for (Partner_Track__c pt:ptlist) {
            PartnerTracks.add(new SelectOption(pt.Id, pt.Track_Name__c));
        }
        
        return PartnerTracks;
    }
    // Wrapper class
    public class PieWedgeData {
        
        public String name { get; set; } 
        public Integer data { get; set; }
        public PieWedgeData(String name, Integer data) { 
            this.name = name; 
            this.data = data;
        }
    }
    public List<ContactOpportunityStages__c>  conopp {get ; set ;}
    public boolean addbool {get ; set ;}
    public boolean removebool {get ; set ;}
    public void getChangeData(){
        dealTypes   = new list<String>();
        System.debug(' conopplist.Opportunity_Stage__c '+conopplist.Opportunity_Stage__c);
        OpptyShareCount  = 0;
        
        //List<Opportunity> lstOppty = new List<Opportunity>();
        Integer intOpptyCount = [SELECT count()
                  				 FROM Opportunity 
                    			 WHERE PartnerAccountid=:selectedaccount];
        System.debug('intOpptyCount::'+intOpptyCount);
        if(intOpptyCount > 0){
                    
        //con.Have_Dealtype_Access__c
        if(null != conopplist.Opportunity_Stage__c && !Test.isRunningTest()){
           for(String eachStage : conopplist.Opportunity_Stage__c.split(';')){
                dealTypes.add(eachStage);
                if(stageAndCount.keyset().contains(eachStage))
                    OpptyShareCount  += stageAndCount.get(eachStage);
            }
        }
        System.debug('dealTypes::'+dealTypes);
        System.debug('OpptyShareCount::'+OpptyShareCount);
        System.debug('selectedAccount::'+selectedAccount+'con.id'+con.id);
        List<ContactOpportunityStages__c> conopprmv = [select id,Opportunity_Stage__c,SalesmotionAccount__c 
                                                       from ContactOpportunityStages__c 
                                                       where contact__c =: con.id 
                                                       and SalesmotionAccount__c =: selectedAccount];       
        if(conopprmv.size() > 0){ 
            dealAccessRequest  = 'Remove Deal View Access';            
            removebool = true;addbool = false;
            showAction  = false;removebtn = true;
            
        } 
        else{
            dealAccessRequest  = 'Add Deal View Access';
            addbool = true;removebool = false;
            showAction  = true;removebtn = false;
        } 
        
        
            
        }

    }
    
    
}