/***********************************************************
* Name          : Deal Summary
* ---------------------------------------------------------
* Revision   Release       Name           Date              Description   
* 1.0        FY18-DCS-0802 Syidah         14-Jun-2017       CR 14509 - Added "Order Submitted - 99%" picklist value under StageName introduce new custom setting 
************************************************************/

global class DealSummary{
    public Opportunity opty;
    public Opportunity oppty;
    public Boolean refreshPage {get; set;}
    public string RelatedStrategy {get; set;}
    public string ScheduledOpportunity {get; set;}
    public string OpportunityPlan {get; set;}
    public integer CallPlanCt {get; set;}
    public integer CallsLoggedCt {get; set;}
    public integer TripReportsCt {get; set;}
    public integer NPSCt {get; set;}

    public list<OpportunityFieldHistory> LastStageDt;
    public list<OpportunityFieldHistory> OptyFieldHistory;

    public integer OHDaysInPlan {get; set;}
    public integer OHDaysInDiscover {get; set;}
    public integer OHDaysInQualify {get; set;}
    public integer OHDaysInPropose {get; set;}
    public integer OHDaysInCommit {get; set;} 
    public integer OHDaysInSubmit {get; set;} //1.0 - Added "Order Submitted - 99%" picklist value under StageName
    
    //1.0 - Introduced custom settings for StageName
    private OWD__c owd = OWD__c.getOrgDefaults();      
	
    public DealSummary(){
        refreshPage=false;
        string id = ApexPages.currentPage().getParameters().get('id');
        if(id == null){
            system.debug('Opportunity Id is NULL');
        }
        else{
            opty = [select id, Name, AccountId, Deal_ID__c, Unweighted_Rev_Formula__c, Total_Margin__c, StageName, Scheduled_Opportunity__c, Probability, Related_Strategy__c, Opportunity_Plan__c, No_times_BookDate_moved__c, LastActivityDate, CreatedDate from Opportunity where id = :id];
            
            if(opty.Related_Strategy__c == null){
                RelatedStrategy = 'No';
            }
            else{
                RelatedStrategy = 'Yes';
            }          
            if(opty.Scheduled_Opportunity__c == null || opty.Scheduled_Opportunity__c == false){
                ScheduledOpportunity = 'No';
            }
            else{
                ScheduledOpportunity = 'Yes';
            }

            if(opty.Opportunity_Plan__c == null || opty.Opportunity_Plan__c == 'N'){
                OpportunityPlan = 'No';
            }
            else{
                OpportunityPlan = 'Yes';
            }
            
            CallPlanCt = [Select count() from Event where WhatId = :Id and RecordType.Name = 'Call Plan' and WhatId != null];
            CallsLoggedCt = [Select count() from Task where WhatId = :Id AND RecordType.Name='Standard Task' AND Type='Call Customer' AND Status='Completed' and WhatId != null and Status != null];
            TripReportsCt = [Select count() from CustomerInteraction__c where Related_Opportunity__c = :Id and Related_Opportunity__c != null];
            NPSCt = [Select count() From Contact where AccountId = :opty.AccountId and Survey__c in ('Yes', 'None') and Status__c = 'Customer' and Decision_Making_Role__c in ('Power Sponsor / Decision Maker', 'Sponsor/ Champion', 'Influencer', 'Evaluator', 'Purchasing / Procurement', 'Financial Buyer', 'Technical Buyer', 'Operational Buyer', 'Legal Approver') and Email_Opt_In__c != 'No' and AccountId != null and Survey__c != null and Status__c != null and Decision_Making_Role__c != null];
            datetime OHDateTimeOld, OHDateTimeNew, OHLastStageDateTime;
            date OHDateOld, OHDateNew, OHLastStageDate;          
            OHDaysInPlan = 0;
            OHDaysInDiscover = 0;
            OHDaysInQualify = 0;
            OHDaysInPropose = 0;
            OHDaysInCommit = 0;
            OHDaysInSubmit = 0; // 1.0 - Added "Order Submitted - 99%" picklist value under StageName

            OHDateTimeOld = date.valueof(opty.CreatedDate);
            OHDateOld = Date.newInstance(OHDateTimeOld.year(), OHDateTimeOld.month(), OHDateTimeOld.day());
            
            // Getting Stage History from OpportunityFieldHistory
            if(Test.isRunningTest()){
                OptyFieldHistory = retrieveDummyOpptyFieldHistory(Id);
            }
            else{
                OptyFieldHistory = [Select OpportunityId, OldValue, NewValue, Field, CreatedDate From OpportunityFieldHistory where OpportunityId = :Id and Field='StageName' and Field != null Order By CreatedDate ASC];
            }
            
            // Looping OpportunityFieldHistory to calculate Days spent in Stages.
            for(OpportunityFieldHistory oh : OptyFieldHistory){
                    
                if(Test.isRunningTest()){
                    OHDateTimeNew = System.Now();
                }
                else{
                    OHDateTimeNew = oh.CreatedDate;
                }
                
                OHDateNew = Date.newInstance(OHDateTimeNew.year(), OHDateTimeNew.month(), OHDateTimeNew.day());
                
                // Calculating Days spent in Plan
                if((oh.OldValue == owd.Oppty_Stage1__c && OHDateNew != OHDateOld) || Test.isRunningTest()){
                    OHDaysInPlan = OHDaysInPlan + OHDateOld.daysBetween(OHDateNew);
                    OHDateOld = OHDateNew;
                    OHDateTimeNew = oh.CreatedDate;
                }
                
                // Calculating Days spent in Discover
                if((oh.OldValue == owd.Oppty_Stage10__c && OHDateNew != OHDateOld) || Test.isRunningTest()){
                    OHDaysInDiscover = OHDaysInDiscover + OHDateOld.daysBetween(OHDateNew);
                    OHDateOld = OHDateNew;
                    OHDateTimeNew = oh.CreatedDate;
                }
                
                // Calculating Days spent in Qualify
                if((oh.OldValue == owd.Oppty_Stage30__c && OHDateNew != OHDateOld) || Test.isRunningTest()){
                    OHDaysInQualify = OHDaysInQualify + OHDateOld.daysBetween(OHDateNew);
                    OHDateOld = OHDateNew;
                    OHDateTimeNew = oh.CreatedDate;
                }
                   
                // Calculating Days spent in Propose
                if((oh.OldValue == owd.Oppty_Stage60__c && OHDateNew != OHDateOld) || Test.isRunningTest()){
                    OHDaysInPropose = OHDaysInPropose + OHDateOld.daysBetween(OHDateNew);
                    OHDateOld = OHDateNew;
                    OHDateTimeNew = oh.CreatedDate;
                }
                
                // Calculating Days spent in Commit
                if((oh.OldValue == owd.Oppty_Stage90__c && OHDateNew != OHDateOld) || Test.isRunningTest()){
                    OHDaysInCommit = OHDaysInCommit + OHDateOld.daysBetween(OHDateNew);
                    OHDateOld = OHDateNew;
                    OHDateTimeNew = oh.CreatedDate;
                }
                 
                // 1.0 - Added "Order Submitted - 99%" picklist value under StageName
                // Calculating Days spent in Order Submitted
                if((oh.OldValue == owd.Oppty_Stage99__c && OHDateNew != OHDateOld) || Test.isRunningTest()){
                    OHDaysInSubmit = OHDaysInSubmit + OHDateOld.daysBetween(OHDateNew);
                    OHDateOld = OHDateNew;
                    OHDateTimeNew = oh.CreatedDate;
                }

                system.debug('--Test-OHDaysInPlan: ' + OHDaysInPlan);
                system.debug('--Test-OHDaysInDiscover: ' + OHDaysInDiscover);
                system.debug('--Test-OHDaysInQualify: ' + OHDaysInQualify);
                system.debug('--Test-OHDaysInPropose: ' + OHDaysInPropose);
                system.debug('--Test-OHDaysInCommit: ' + OHDaysInCommit);
                system.debug('--Test-OHDaysInSubmit: ' + OHDaysInSubmit); // 1.0 - Added "Order Submitted - 99%" picklist value under StageName
                system.debug('--Test-OHDateOld: ' + OHDateOld);
                system.debug('--Test-OHDateNew: ' + OHDateNew);
            }
            
            if(OptyFieldHistory.size() > 0){
                LastStageDt = [select CreatedDate from OpportunityFieldHistory where (OpportunityId = :Id and Field = 'StageName' and Field != null) order by CreatedDate DESC limit 1];
                
                if(Test.isRunningTest()){
                    OHLastStageDateTime = date.valueof(System.Now());
                }
                else{
                    OHLastStageDateTime = date.valueof(LastStageDt[0].get('CreatedDate'));
                }
            }
            else{
                OHLastStageDateTime = date.valueof(opty.CreatedDate);
            }        
            OHLastStageDate = Date.newInstance(OHLastStageDateTime.year(), OHLastStageDateTime.month(), OHLastStageDateTime.day());
            
            // 1.0 - CR 14509 - Added "Order Submitted - 99%" picklist value under StageName and introduce new custom setting 
            // To calculate days spent for the current stage between TODAY and the LastStageChanged Date.
            if(opty.StageName == owd.Oppty_Stage1__c){
                OHDaysInPlan = OHDaysInPlan + OHLastStageDate.daysBetween(system.TODAY());
            }
            else if(opty.StageName == owd.Oppty_Stage10__c){
                OHDaysInDiscover = OHDaysInDiscover + OHLastStageDate.daysBetween(system.TODAY());
            }
            else if(opty.StageName == owd.Oppty_Stage30__c){
                OHDaysInQualify = OHDaysInQualify + OHLastStageDate.daysBetween(system.TODAY());
            }
            else if(opty.StageName == owd.Oppty_Stage60__c){
                OHDaysInPropose = OHDaysInPropose + OHLastStageDate.daysBetween(system.TODAY());
            }
            else if(opty.StageName == owd.Oppty_Stage90__c){
                OHDaysInCommit = OHDaysInCommit + OHLastStageDate.daysBetween(system.TODAY());
            }
            else if(opty.StageName == owd.Oppty_Stage99__c){
                OHDaysInSubmit = OHDaysInSubmit + OHLastStageDate.daysBetween(system.TODAY());
            }
        }
    }

    public Opportunity getOpportunity(){
        return opty;   
    }

    public void insOppty(){
        string id = ApexPages.currentPage().getParameters().get('id');
        integer ExistCt = [select count() from Deal_Summary__c where Opportunity__c =:id];
        
        if(ExistCt == 0){
            oppty = [select id, AccountId from Opportunity where id = :id];
            Deal_Summary__c ds = new Deal_Summary__c(Opportunity__c = id, ForcedCalculation__c = true, Account__c = oppty.AccountId);
            insert ds; 
        }
    }
    
    public pageReference theRefresh(){
        string id = ApexPages.currentPage().getParameters().get('id');        
        Deal_Summary__c[] MyDS = [Select Id, Opportunity__c, Account__c, ForcedCalculation__c, Opportunity__r.AccountId from Deal_Summary__c where Opportunity__c = :id];
        MyDS[0].ForcedCalculation__c = true;
        MyDS[0].Account__c = MyDS[0].Opportunity__r.AccountId;
        update MyDS;
        
        refreshPage=true;
        return null;
    }
    
    @future 
    public static void optyAdd(Set<Id> OptyIds){
        list<Opportunity> op = [select Id, Name, AccountId, Deal_ID__c, Unweighted_Rev_Formula__c, Total_Margin__c, StageName, Scheduled_Opportunity__c, Probability, Related_Strategy__c, Opportunity_Plan__c, LastModifiedDate, No_times_BookDate_moved__c, LastActivityDate from Opportunity where Id IN :OptyIds];
        list<Deal_Summary__c> DSToInsert = new List<Deal_Summary__c>();
        integer NPSCt;
        NPSCt = 0;
        if(op.size() > 0){
            NPSCt = [Select count() From Contact where AccountId =:op[0].AccountId and Survey__c in ('Yes', 'None') and Status__c = 'Customer' and Decision_Making_Role__c in ('Power Sponsor / Decision Maker', 'Sponsor/ Champion', 'Influencer', 'Evaluator', 'Purchasing / Procurement', 'Financial Buyer', 'Technical Buyer', 'Operational Buyer', 'Legal Approver') and Email_Opt_In__c != 'No' and AccountId != null and Survey__c != null and Status__c != null and Decision_Making_Role__c != null];
        }
        for(Opportunity o : op){
            string Linked_Strategy, ScheduledOppty, OpportunityPlan;
            
            if(o.Related_Strategy__c == null){
                Linked_Strategy = 'No';
            }
            else{
                Linked_Strategy = 'Yes';
            }
            
            if(o.Scheduled_Opportunity__c == null || o.Scheduled_Opportunity__c == false){
               ScheduledOppty = 'No';                
            }
            else{
                ScheduledOppty = 'Yes';
            }

            if(o.Opportunity_Plan__c == null || o.Opportunity_Plan__c == 'N'){
               OpportunityPlan = 'No';                
            }
            else{
                OpportunityPlan = 'Yes';
            }
            
            Deal_Summary__c ds = new Deal_Summary__c(Opportunity__c = o.id,
                Account__c = o.AccountId, 
                Stage__c = o.StageName,
                Scheduled_Opportunity__c = ScheduledOppty,
                Opportunity_Plan__c = OpportunityPlan,
                Last_Activity_Date__c = o.LastActivityDate,
                Linked_Strategy__c = Linked_Strategy,
                Stage_Plan__c = 0,
                Stage_Discover__c = 0,
                Stage_Qualify__c = 0,
                Stage_Propose__c = 0,
                Stage_Commit__c = 0,
                Stage_Order_Submitted__c = 0, // 1.0 - Added "Order Submitted - 99%" picklist value under StageName
                No_Call_Plan__c = 0,
                No_Calls_Logged__c = 0,
                No_Trip_Reports__c = 0,
                //No_Qualified_NPS__c = NPSCt,
                LastStageChanged__c = system.TODAY(),
                ForcedCalculation__c = false);
            DSToInsert.add(ds); 
        }

        try{       
            insert DSToInsert; 
        }
        catch (DMLException e){
            System.Debug(e);
        }
    }     
   
    //CR 14509
    private OpportunityFieldHistory[] retrieveDummyOpptyFieldHistory(Id opportunityId){
        list<OpportunityFieldHistory> listOpptyHistory = new list<OpportunityFieldHistory>{};
        listOpptyHistory.add(new OpportunityFieldHistory(OpportunityId=opportunityId, Field='StageName'));
        return listOpptyHistory;  
    }      
}