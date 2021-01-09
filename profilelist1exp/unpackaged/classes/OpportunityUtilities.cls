/*
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities which are related to Opportunity object. 
*          Please create separate classes and use it for complex logics.
*        
*
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR10496     15.10       10-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
*-------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
* Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
* 2.0      CR14931     DCS-FY18-1101   20-Sep-2017     Naga            Code cleanup for savo functionality, removed all refferences of Product_Group_Hidden__c and Product_Brand_Hidden__c fields from code.
  3.0      CR15586     DCS-FY19-0502   30-Mar-2018     Gan             To call integrateMyDeal only when it is not calling from batch or future call    
  4.0      CR15930     DCS-FY19-0703   07-Jun-2018     Akshita         Consolidated if condition,commented lines and, system.debug statements as part of Opportunity code reduce story     
  5.0      CR17639     FY20-DCS-0702   15-July-2019    Rajiv           Visit Bundles sync issue, corrected for reflecting the correct data from the opportunity/account data linked to them
  5.0     CR17750     DCE-FY20-0802   19-Jul-2019     Kiran        Modified fields with VisitOps package name as part of Version 2.54
*/
public class OpportunityUtilities {
    
        /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0         CR10496     15.10       15-Sep-2014     Ragu            This logic is separated from OpportunityTGRREUD trigger and rewritten as part of trigger redesign.
*/
    public static void createEndCustomerAndPopulateDetailsInOpps(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities) {
        set<String> setRecordTypeNames = new set<String>{'Deal Registration', 'Deal Registration for Existing End Customer', 'Deal Registration-Submitted'}; 
            map<Id, String> mapRecordType = StaticFactory.getRecordTypeIdNameMapByNames('Opportunity', setRecordTypeNames);
        
        set<Id> setOwnerIds = new set<Id>();
        list<Opportunity> lstOppsToCreateEC = new list<Opportunity>();
        
        set<Id> setSubmittedCustomerIds = new set<Id>();
        list<Opportunity> lstSubmittedOppsToUpdate = new list<Opportunity>();
        
        set<Id> setCustomerIds = new set<Id>();
        set<Id> setContactIds = new set<Id>();
        list<Opportunity> lstEndCustomerOpps = new list<Opportunity>();
        
        for(Opportunity newOpportunity : lstNewOpportunities) {
            Opportunity oldOpportunity;
            if(mapOldOpportunities != null) {
                oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            }
            
            String strRecordTypeName = mapRecordType.get(newOpportunity.RecordTypeId);
            if(!String.isBlank(strRecordTypeName)) {
                if(oldOpportunity != null && newOpportunity.Deal_Registration_Status__c == 'Submitted' && newOpportunity.End_Customer__c != null) {
                    setSubmittedCustomerIds.add(newOpportunity.End_Customer__c);
                    lstSubmittedOppsToUpdate.add(newOpportunity);
                }
                if(strRecordTypeName == 'Deal Registration for Existing End Customer' 
                   && ((oldOpportunity == null && newOpportunity.End_Customer__c != null && newOpportunity.End_Customer_Contact__c != null)
                       || (oldOpportunity != null && oldOpportunity.End_Customer__c != null && oldOpportunity.End_Customer_Contact__c != null 
                           && newOpportunity.End_Customer__c != oldOpportunity.End_Customer__c && newOpportunity.End_Customer_Contact__c != oldOpportunity.End_Customer_Contact__c))) {
                               lstEndCustomerOpps.add(newOpportunity);
                               setCustomerIds.add(newOpportunity.End_Customer__c);
                               setContactIds.add(newOpportunity.End_Customer_Contact__c);
                           }
            }
        }
        if(!lstEndCustomerOpps.isEmpty()) {
            PartnerEndUserDataCaptureUtils.UpdateExistingEndCustomerDetails(lstEndCustomerOpps, setCustomerIds, setContactIds);
        }
        
        if(!lstSubmittedOppsToUpdate.isEmpty()) {
            PartnerEndUserDataCaptureUtils.updateDealAssignmentInstruction(lstSubmittedOppsToUpdate, setSubmittedCustomerIds);
        }
    }
   /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0                                 09-Apr-2010     Hanan           Added code to insert Solution Certification recod - For Perot2. Solution Certificate records needed only for Standard Opportunities
2.0         CR10496     15.10       22-Sep-2014     Ragu            This logic is separated from opportunityTrigger trigger and rewritten as part of trigger redesign.
3.0                                 21-Aug-2017     Ramesh          CR 14815 Code is commented , which is related to services
*/
    public static void createSolutionCertificate(set<Id> setOpportunityIds, map<Id, Opportunity> mapOpportunities) {
        /* v 3.0 - start-ramesh
        if(setOpportunityIds != null && !setOpportunityIds.isEmpty()) {
            GlobalVariables.SKIP_SOLUTION_CERT_FUNCTIONALITY = true;
            map<Id, Id> mapOppIdSolCertId = new map<Id, Id>();
            for(Solution_Certification__c solCertificationIterator : [select Id, Opportunity__c from Solution_Certification__c where Opportunity__c in :setOpportunityIds]) {
                mapOppIdSolCertId.put(solCertificationIterator.Opportunity__c, solCertificationIterator.Id);
            }
            SolutionCertificationUtils.processOpportunityListFromTrigger(mapOpportunities, setOpportunityIds, mapOppIdSolCertId);
        } */ //3.0 - End
    }
  
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0         CR10496     15.10       17-Sep-2014     Ragu            This logic is separated from OSCafterinsert trigger and rewritten as part of trigger redesign.
3.0         CR10483     15.10       14-Sep-2014     Annie           To replace partner specific parameter
3.0         CR10483     15.10       15-Nov-2014     Annie           Added Custom Setting and partner check
4.0         114(94-96)  16.07-S03   27-May-2015     Anamika         Pass deal reg status,deal exp date,stage and deal type to OSC when a new deal is associated to a solution.
*/ 
    public static void createSolutions(list<Opportunity> lstOpportunities, map<Id, Account> mapRelatedAccounts) {
        
        List<id> oppIdList = new List<id>();
        String OSCActionIdentifier = 'Association';
        if(lstOpportunities != null) {
            list<Solution__c> lstSolutions = new list<Solution__c>();
            for(Opportunity newOpportunity : lstOpportunities) {                   
                if(newOpportunity.OSC_Solution_ID__c != null) {
                    oppIdList.add(newOpportunity.id);
                    // Create new solution record and associate it to the newly created deal
                    Solution__c solutionObj = new Solution__c();
                    // Populate the OSC_Regional_ID__c field with the OSC_Solution_ID__c which has come from the OSC
                    solutionobj.OSC_Regional_ID__c = newOpportunity.OSC_Solution_ID__c;
                    solutionobj.Opportunity__c = newOpportunity.Id;                
                    lstSolutions.add(solutionobj);
                }
            }
            if(!lstSolutions.isEmpty()) {
                insert lstSolutions;                             
                OSCWebServiceCallout.sendNotification(oppIdList,OSCActionIdentifier);
                
            }
        }
    }
    
    /*  Revision  CR Number             Release No      Date            Modified By       Description
--------     ---------             ----------     -----------     ------------      -----------
1.0     CR11567,11568,11569,11570   16.07         11-June-2015    Samridh Manucha  To do realtime update on OSC when Deal Type, Deal Expiration Date, Stage and Deal Registration status in opportunity changes

*/ 
    public static void RealtimeSolutionsupdate(List<Opportunity> opplst, Map<Id, Opportunity> oldMap){
        
        List<id> Addopp = new List<id>();
        String OSCActionIdentifier = 'DealSync';
        
        for(Opportunity opp:opplst){
            if(oldMap.get(opp.Id).Deal_Type__c != opp.Deal_Type__c || oldMap.get(opp.Id).Deal_Expiration_Date__c != opp.Deal_Expiration_Date__c || oldMap.get(opp.Id).stagename != opp.stagename|| oldMap.get(opp.Id).Deal_Registration_Status__c != opp.Deal_Registration_Status__c || oldMap.get(opp.Id).Opportunity_Customer_Number__c != opp.Opportunity_Customer_Number__c || oldMap.get(opp.Id).AccountID != opp.AccountID || oldMap.get(opp.Id).Unassigned_End_User__c != opp.Unassigned_End_User__c ){       //Anamika- sending opportunity customer number and end user affinity ID to OSC
                   Addopp.add(opp.id);             
               }
        }
        if(Addopp.size() > 0){
           List<solution__c> solutions = [select id, Opportunity__c, OSC_Regional_Id__c from solution__c where Opportunity__c IN : Addopp];
            if(solutions.size()>0){
                
                set<id> oppidfrmsol = new set<id>();
                List<id> Listoppid = new List<id>();
                
                for(solution__c sl: solutions){
                    oppidfrmsol.add(sl.Opportunity__c); 
                }
                
                Listoppid.addAll(oppidfrmsol);
                OSCWebServiceCallout.sendNotification(Listoppid,OSCActionIdentifier);// sending DealSync because we dont have to generate solutionId list and Product list in JSON
            }
        }
    }
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR6525                  25-Aug-2011     Raymond Yip
2.0         CR10496     15.10       18-Sep-2014     Ragu            This logic is separated from OpportunityAccntPlanAfterInsertUpdate trigger and rewritten as part of trigger redesign.
3.0         CR10058     15.10       03-Nov-2014     Jessie Tan      Modified for CRQ1072 of CR10058 (fixes to eliminate unnecessary email of CR10058) 
4.0         CR10590     15.10       11-Nov-2014     Jessie Tan      Modified for CR10590 (fixes to calculate Strategy Opportunity Rollup Data correctly)
*/
    public static void recalculateStrategyValues(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities, TriggerHandler.TriggerEvent trigEvent) {
        set<Id> setStrategyIdsToUpdate = new set<Id>();
        for(Opportunity newOpportunity : lstNewOpportunities) {
            Opportunity oldOpportunity;
            if(mapOldOpportunities != null) {
                oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            }
            
            if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT && newOpportunity.Related_Strategy__c != null && newOpportunity.Amount != null) {
                setStrategyIdsToUpdate.add(newOpportunity.Related_Strategy__c);
            }
            else if(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                if(newOpportunity.Related_Strategy__c != oldOpportunity.Related_Strategy__c || newOpportunity.Amount != oldOpportunity.Amount || newOpportunity.StageName != oldOpportunity.StageName || newOpportunity.CloseDate != oldOpportunity.CloseDate) {
                       setStrategyIdsToUpdate.add(newOpportunity.Related_Strategy__c);                       
                       if(oldOpportunity.Related_Strategy__c != null) {
                           setStrategyIdsToUpdate.add(oldOpportunity.Related_Strategy__c);
                       }
                   }
            }
        }
        if(!setStrategyIdsToUpdate.isEmpty()) {
            // Change to Dell fiscal year here
            Integer currentYear = System.today().Year();
            Date FirstHalfStartDate = OpportunityUtils.getFYStartAndEndDate('StartDate', System.today());
            //v4.0 - start
            Date FirstHalfEndDate = OpportunityUtils.getCurrentFiscalYearDate('2' + 'EndDate');
            Date SecondHalfStartDate = OpportunityUtils.getCurrentFiscalYearDate('3' + 'StartDate');
            //v4.0 - end
            Date SecondHalfEndDate = OpportunityUtils.getFYStartAndEndDate('EndDate', System.today()); 
            
            map<String, Double> mapCurrencyConversionRate = CurrencyUtils.getCurrencyConversionMap();
            map<Id, SFDC_Strategy__c> mapStrategies = new map<Id, SFDC_Strategy__c>();
            for(Opportunity oppIterator : [select Id, Name, Probability, Related_Strategy__c, CloseDate, Amount, CurrencyIsoCode from Opportunity where Related_Strategy__c in :setStrategyIdsToUpdate and Related_Strategy__c != null]) {
                Double dAmount = oppIterator.Amount == null ? 0 : oppIterator.Amount;
                String strIsoCode = oppIterator.CurrencyIsoCode;
                if(mapCurrencyConversionRate.containsKey(strIsoCode)) {
                    dAmount = dAmount / mapCurrencyConversionRate.get(strIsoCode);
                }
                
                SFDC_Strategy__c targetStrategy = mapStrategies.get(oppIterator.Related_Strategy__c);
                if(targetStrategy == null) {
                    targetStrategy = new SFDC_Strategy__c(Id = oppIterator.Related_Strategy__c, Open_Opportunity_Value_1st_Half__c = 0, Open_Opportunity_Value_2nd_Half__c = 0, Open_Opportunity_Value_Next_FY__c = 0, Closed_Opportunity_Value_1st_Half__c = 0, Closed_Opportunity_Value_2nd_Half__c = 0, Closed_Opportunity_Value_Next_Year__c = 0);
                    mapStrategies.put(targetStrategy.Id, targetStrategy);
                }
                //v4.0 - start
                if(oppIterator.CloseDate >= FirstHalfStartDate && oppIterator.CloseDate <= FirstHalfEndDate) {            
                    if(oppIterator.Probability != 100 && oppIterator.Probability != 0) {             
                        targetStrategy.Open_Opportunity_Value_1st_Half__c += dAmount;
                    }  else if(oppIterator.Probability == 100) {
                        targetStrategy.Closed_Opportunity_Value_1st_Half__c += dAmount;
                    } 
                } 
                
                else if(oppIterator.CloseDate >= SecondHalfStartDate && oppIterator.CloseDate <= SecondHalfEndDate) {
                    if(oppIterator.Probability != 100 && oppIterator.Probability != 0) {
                        targetStrategy.Open_Opportunity_Value_2nd_Half__c += dAmount;
                    }
                    else if(oppIterator.Probability == 100) {  
                        targetStrategy.Closed_Opportunity_Value_2nd_Half__c += dAmount;
                    }
                }
                else if(oppIterator.CloseDate > SecondHalfEndDate) {
                    if(oppIterator.Probability != 100 && oppIterator.Probability != 0) {
                        targetStrategy.Open_Opportunity_Value_Next_FY__c += dAmount;
                    }
                    else if(oppIterator.Probability == 100) {
                        targetStrategy.Closed_Opportunity_Value_Next_Year__c += dAmount;
                    } 
                }
                //v4.0 - end
            }
            //v4.0 - start
            //add strategy that do not have any opportunities linked to it
            if(setStrategyIdsToUpdate.size() > mapStrategies.keySet().size()){
                
                setStrategyIdsToUpdate.removeAll(mapStrategies.keySet());
                
                for(Id strategyId: setStrategyIdsToUpdate){
                    
                    if(strategyId==null)
                        continue;
                    
                    mapStrategies.put(strategyId, new SFDC_Strategy__c(Id = strategyId, Open_Opportunity_Value_1st_Half__c = 0, Open_Opportunity_Value_2nd_Half__c = 0, Open_Opportunity_Value_Next_FY__c = 0, Closed_Opportunity_Value_1st_Half__c = 0, Closed_Opportunity_Value_2nd_Half__c = 0, Closed_Opportunity_Value_Next_Year__c = 0)
                                     );
                }
            }
            //v4.0 - end
            
            if(!mapStrategies.isEmpty()) {
                //v3.0 - start
                Map<Id, SFDC_Strategy__c> existingStrategyMap = new Map<Id, SFDC_Strategy__c> ([SELECT Id, Closed_Opportunity_Value_1st_Half__c,Closed_Opportunity_Value_2nd_Half__c,Closed_Opportunity_Value_Next_Year__c,Open_Opportunity_Value_1st_Half__c,
                                                                                                Open_Opportunity_Value_2nd_Half__c,Open_Opportunity_Value_Next_FY__c from SFDC_Strategy__c WHERE Id IN :mapStrategies.keySet()]);
                for (SFDC_Strategy__c strategyToUpdate: mapStrategies.values()){
                    
                    SFDC_Strategy__c existingStrategy = existingStrategyMap.get(strategyToUpdate.Id);
                    
                    if(existingStrategy!=null && existingStrategy.Closed_Opportunity_Value_1st_Half__c==strategyToUpdate.Closed_Opportunity_Value_1st_Half__c && 
                       existingStrategy.Closed_Opportunity_Value_2nd_Half__c==strategyToUpdate.Closed_Opportunity_Value_2nd_Half__c && existingStrategy.Closed_Opportunity_Value_Next_Year__c==strategyToUpdate.Closed_Opportunity_Value_Next_Year__c && 
                       existingStrategy.Open_Opportunity_Value_1st_Half__c==strategyToUpdate.Open_Opportunity_Value_1st_Half__c && existingStrategy.Open_Opportunity_Value_2nd_Half__c==strategyToUpdate.Open_Opportunity_Value_2nd_Half__c && 
                       existingStrategy.Open_Opportunity_Value_Next_FY__c==strategyToUpdate.Open_Opportunity_Value_Next_FY__c){
                          mapStrategies.remove(strategyToUpdate.Id);
                      }
                }
                //v3.0 - end 
                update mapStrategies.values();
            }
        }
    }
    
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR7788                  18-Dec-2012     Sang Chian
2.0         CR10496     15.10       18-Sep-2014     Ragu            This logic is separated from OpportunityAccntPlanAfterInsertUpdate trigger and rewritten as part of trigger redesign.
*/
    public static void updateRSSSupportRequest(set<Id> setOpportunityIds) {
        if(setOpportunityIds != null && !setOpportunityIds.isEmpty()) {
            Id RSSRecordTypeId = Schema.SObjectType.Support_Request__c.getRecordTypeInfosByName().get('Request Specialist Support').getRecordTypeId();
            list<Support_Request__c> lstSupportRequests = new list<Support_Request__c>();
            for(Support_Request__c supportRequest : [select Id, Status__c from Support_Request__c where RecordTypeId = :RSSRecordTypeId and Status__c != 'Engagement complete' and Opportunity__c in :setOpportunityIds]) {
                supportRequest.Status__c = 'Engagement complete';
                lstSupportRequests.add(supportRequest);
            }
            if(!lstSupportRequests.isEmpty()) {
                update lstSupportRequests;
            }
        }
    }
    
    /*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
2.0         CR10496     15.10           19-Sep-2014     Ragu            This logic is separated from DealSummaryOppty trigger and rewritten as part of trigger redesign.
3.0         CR14534     FY18-DCS-0802   21-Jun-2017     Emily           Include new stage value - Order Submitted - 99%
*/
public static void updateDealSummary(map<Id, Opportunity> mapNewOpportunities, map<Id, Opportunity> mapOldOpportunities) {
        set<Id> setOpportunityIds = new set<Id>();
        
        for(Opportunity newOpportunity : mapNewOpportunities.values()) {
            Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            
            if(oldOpportunity.StageName != newOpportunity.StageName || oldOpportunity.CloseDate != newOpportunity.CloseDate || oldOpportunity.Opportunity_Plan__c != newOpportunity.Opportunity_Plan__c 
               || oldOpportunity.Related_Strategy__c != newOpportunity.Related_Strategy__c || oldOpportunity.Scheduled_Opportunity__c != newOpportunity.Scheduled_Opportunity__c) {
                   setOpportunityIds.add(newOpportunity.Id);
               }
        }
        if(!setOpportunityIds.isEmpty()) {
			list<Deal_Summary_Event__e> listDealSummaryRecords = new list<Deal_Summary_Event__e>();
			for(Deal_Summary__c dealSummary : [select Id, Opportunity__c, LastStageChanged__c, Stage_Plan__c, Stage_Discover__c, Stage_Qualify__c, Stage_Propose__c,Stage_Commit__c, 
                                               Opportunity__r.Id, Opportunity__r.AccountId, Opportunity__r.StageName, Opportunity__r.LastActivityDate, 
                                               Stage_Order_Submitted__c,Opportunity__r.Scheduled_Opportunity__c, 
                                               Opportunity__r.Related_Strategy__c, Opportunity__r.Opportunity_Plan__c from Deal_Summary__c where Opportunity__c in :setOpportunityIds]){
												   
                            Opportunity oldOpportunity = mapOldOpportunities.get(dealSummary.Opportunity__c);		
                            Deal_Summary_Event__e dealSummaryRec = new Deal_Summary_Event__e();
							
							dealSummaryRec.Deal_Summary_Id__c = dealSummary.id;
							dealSummaryRec.Account__c = dealSummary.Opportunity__r.AccountId;
							dealSummaryRec.Last_Activity_Date__c = dealSummary.Opportunity__r.LastActivityDate;				   
							dealSummaryRec.Last_Stage_Changed__c = dealSummary.LastStageChanged__c;
							dealSummaryRec.Old_Stage_Name__c = oldOpportunity.StageName;
							dealSummaryRec.Opportunity__c = dealSummary.Opportunity__c;
							dealSummaryRec.Opportunity_Plan__c = dealSummary.Opportunity__r.Opportunity_Plan__c;
							dealSummaryRec.Related_Strategy__c = dealSummary.Opportunity__r.Related_Strategy__c;
							dealSummaryRec.Scheduled_Opportunity__c = dealSummary.Opportunity__r.Scheduled_Opportunity__c;
							dealSummaryRec.Stage_Commit__c = dealSummary.Stage_Commit__c;
							dealSummaryRec.Stage_Discover__c = dealSummary.Stage_Discover__c;
							dealSummaryRec.Stage_Name__c = dealSummary.Opportunity__r.StageName;
							dealSummaryRec.Stage_Plan__c = dealSummary.Stage_Plan__c;
							dealSummaryRec.Stage_Propose__c =  dealSummary.Stage_Propose__c;
							dealSummaryRec.Stage_Qualify__c	= dealSummary.Stage_Qualify__c;
							
							listDealSummaryRecords.add(dealSummaryRec);
			}
			
            List<Database.SaveResult> results = EventBus.publish(listDealSummaryRecords);
					
			for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                }
             }  			
	      }			
       }
    }
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR8130                  23-Apr-2013                     Code to insert record in opportunity description history object while updating standard opportunity
2.0         CR8417                  26-May-2014     Sree Prakash    Extend the opportunity description history to Mass Update custom button
3.0         CR8577                  16-Aug-2013                     New record type 'Channel Opportunity' should have same functionality as Standard Opportunity
4.0         CR10496     15.10       22-Sep-2014     Ragu            This logic is separated from opportunityTrigger trigger and rewritten as part of trigger redesign.
5.0         7123894     FY20-0804   22-Aug-2019     Mahesh           Changed method to Future as part of TTI
*/
    @Future
    public static void createOpportunityDescriptionHistory(String stroldJson) {
         List<opportunity> listOpportunities = (List<opportunity>)System.JSON.deserialize(stroldJson, List<opportunity>.class);
        if(!GlobalVariables.override_first_run){               
            if(listOpportunities != null && !listOpportunities.isEmpty()) {
                list<Oppt_Description_History__c> listOppDescHistory = new list<Oppt_Description_History__c>();
                for(opportunity oppIterator : listOpportunities) {
                    Oppt_Description_History__c oppDescHistory = new Oppt_Description_History__c();
                    oppDescHistory.Modified_By__c = oppIterator.Description_Last_Modified_By__c;
                    oppDescHistory.Modified_Date__c = oppIterator.Description_Last_Modified_Date__c;
                    oppDescHistory.Description__c = oppIterator.Description;
                    oppDescHistory.Opportunity__c = oppIterator.Id;
                    listOppDescHistory.add(oppDescHistory); 
                }
                insert listOppDescHistory;
            }
            GlobalVariables.override_first_run = true;
        }
    }  
    
/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         CR8948                      08-Aug-2013                     Creation of Boomi Log Records
2.0         CR10496     15.10           22-Sep-2014     Ragu            This logic is separated from opportunityTrigger trigger and rewritten as part of trigger redesign.
3.0         CR12116     16.10           19-Oct-2015     Krishnamoorthi  Added logic to populate Opportunity Stage in Boomi Log object for Story 198906:[Proj Mgmt] Update Changepoint when Opportunity is Lost
4.0         CR14534     FY18-DCS-0802   21-Jun-2017     Emily           Include new stage value - Order Submitted - 99%
*/
    //V3.0 - Boolean variable to prevent multiple insert of Boomi log record when Opportunity is Lost, Cancelled - 0% caused by Workflow R12.10 CR6613 Updating Win/Loss Date in Opportunity 
    public static Boolean SOM_BOOMI_ISINSERT = true;
    public static void createSOMBoomiLogs(list<Opportunity> lstOpportunities, map<Id, Opportunity> mapOldOpportunities, map<Id, Opportunity> mapRelatedOpportunities) {
        list<SOM_Boomi_Log__c> lstSOMBoomiLogs = new list<SOM_Boomi_Log__c>();
        //CR14534
        OWD__c owd = OWD__c.getOrgDefaults();
        
        for(Opportunity newOpportunity : lstOpportunities) {
            Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            Opportunity relatedOpportunity = mapRelatedOpportunities.get(newOpportunity.Id);
            
            //V3.0 -- Added Opportunity Stage check
            //CR14534 replace hardcoded stage value with OWD custom setting
            if(newOpportunity.Services_Project_Count__c > 0 && (newOpportunity.OwnerId != oldOpportunity.OwnerId || newOpportunity.Services_Sales_Owner__c != oldOpportunity.Services_Sales_Owner__c || (newOpportunity.StageName != oldOpportunity.StageName && newOpportunity.StageName == owd.Oppty_Stage0__c))) {
                SOM_Boomi_Log__c somBoomiLog = new SOM_Boomi_Log__c();
                somBoomiLog.Opportunity_Owner__c = newOpportunity.OwnerId;
                somBoomiLog.Services_Sales_Owner__c = newOpportunity.Services_Sales_Owner__c;       
                somBoomiLog.Affinity_Account_ID__c = relatedOpportunity.Account.Account_Id__c;
                somBoomiLog.Primary_CE_Name__c = newOpportunity.Primary_CE_Name__c;
                somBoomiLog.Primary_CE_Email__c = newOpportunity.Primary_CE_Email__c;
                somBoomiLog.Deal_ID__c = newOpportunity.Deal_ID__c;
                somBoomiLog.Status__c = 'Pending';
                
                // To fill the source field.
                somBoomiLog.Source__c = newOpportunity.Id + ';';
                if(newOpportunity.OwnerId != oldOpportunity.OwnerId) {
                    somBoomiLog.Source__c = somBoomiLog.Source__c + 'Opportunity Owner' + ';';
                }
                if(newOpportunity.Services_Sales_Owner__c != oldOpportunity.Services_Sales_Owner__c) {
                    somBoomiLog.Source__c = somBoomiLog.Source__c + 'Services Sales Owner' + ';';
                }                       
                
                //V3.0 -- Update the Opportunity Stage and Source field if Opportunity Stage is modified
                //CR14534 replace hardcoded stage value with OWD custom setting                
                if(newOpportunity.StageName != oldOpportunity.StageName && newOpportunity.StageName == owd.Oppty_Stage0__c) {
                    somBoomiLog.Opportunity_Stage__c = newOpportunity.StageName;
                    somBoomiLog.Source__c = somBoomiLog.Source__c + 'Opportunity Stage' + ';';
                }
                lstSOMBoomiLogs.add(somBoomiLog);
            }
        }
        if(!lstSOMBoomiLogs.isEmpty() && SOM_BOOMI_ISINSERT == true) {
            insert lstSOMBoomiLogs;
            SOM_BOOMI_ISINSERT = false;
        }
    }

    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR7923                  25-Jan-2013     Mohammad        Updated Quest Software Unweighted Rev and Quest Software Unweighted Margin Rev Fields with sum of Amount and Unweighted Margin Rev from the associated Opportunity.
2.0         CR10496     15.10       22-Sep-2014     Ragu            This logic is separated from opportunityTrigger trigger and rewritten as part of trigger redesign.
3.0         5936162     DCE-0402    04-Mar-2019     Emily           Comment field - Quest_Software_Unweighted_Rev__c 
*/
    public static void recalculateQuestRevenues(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities, TriggerHandler.TriggerEvent trigEvent) {
        set<Id> setRelatedParentOppIds = new set<Id>();
        for(Opportunity newOpportunity : lstNewOpportunities) {
            Opportunity oldOpportunity;
            if(mapOldOpportunities != null) {
                oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            }
            
            if(newOpportunity.Related_Parent_Opportunity__c != null) {
                if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT || (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && (newOpportunity.Amount != oldOpportunity.Amount || newOpportunity.Related_Parent_Opportunity__c != oldOpportunity.Related_Parent_Opportunity__c  || newOpportunity.Unweighted_Margin_Rev__c != oldOpportunity.Unweighted_Margin_Rev__c))) {
                          setRelatedParentOppIds.add(newOpportunity.Related_Parent_Opportunity__c);
                }
            }
        }
        if(!setRelatedParentOppIds.isEmpty()) {
            list<Opportunity> lstOppsToUpdate = new list<Opportunity>();
            for(AggregateResult aggResultIterator : [select Related_Parent_Opportunity__c, sum(Unweighted_Margin_Rev__c) RevSum, sum(Amount) AmountSum
                                                     from Opportunity where Related_Parent_Opportunity__c in :setRelatedParentOppIds group by Related_Parent_Opportunity__c]) {
                                                         Opportunity oppInstance = new Opportunity();
                                                         oppInstance.Id = (Id)aggResultIterator.get('Related_Parent_Opportunity__c');
                                                         //3.0 oppInstance.Quest_Software_Unweighted_Rev__c = (Double)aggResultIterator.get('AmountSum');
                                                         lstOppsToUpdate.add(oppInstance);
                                                     }
            if(!lstOppsToUpdate.isEmpty()) {
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                update lstOppsToUpdate;
                TriggerExecutionController.setSkipOpportunityTriggers(false);
            }
        }
    }
    
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR7406                  18-Sep-2012     Deepthi         Auto populate Partner Sales Rep Name, Emai and Phone when owner is changed.
2.0         CR10496     15.10       23-Sep-2014     Ragu            This logic is separated from opptyBeforeInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
*/
    public static void updatePartnerSalesRepDetails(list<Opportunity> lstOpportunities, map<Id, Opportunity> mapOldOpportunities, map<Id, Opportunity> mapRelatedOpportunities) {
        for(Opportunity newOpportunity : lstOpportunities) {
            Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            Opportunity relatedOpportunity = mapRelatedOpportunities.get(newOpportunity.Id);
            
            if(newOpportunity.OwnerId != oldOpportunity.OwnerId) {
                if(relatedOpportunity.Owner.Contact.AccountId != null && relatedOpportunity.Owner.Contact.AccountId == newOpportunity.AccountId) {
                    newOpportunity.Partner_Sales_Rep_Name__c = relatedOpportunity.Owner.FirstName + ' ' + relatedOpportunity.Owner.LastName;
                    newOpportunity.Partner_Sales_Rep_Email__c = relatedOpportunity.Owner.Contact.Email;
                    if(relatedOpportunity.Owner.Contact.Phone != '') {
                        newOpportunity.Partner_Sales_Rep_Phone__c = relatedOpportunity.Owner.Contact.Phone;
                    }
                    else {
                        newOpportunity.Partner_Sales_Rep_Phone__c = ' ';
                    }
                }
            }
        }
    }
    
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR6445                  23-May-2012     Deepthi         Link the Account Play - Query for the Account Play ID and update SourceID
2.0         CR10496     15.10       23-Sep-2014     Ragu            This logic is separated from opptyBeforeInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
*/
    public static void linkToAccountPlay(list<Opportunity> lstOpportunities, set<String> setLatticePreLeadIds) {
        if(setLatticePreLeadIds != null && !setLatticePreLeadIds.isEmpty()) {
            map<String, Id> mapLatticeAPId = new map<String, Id>();
            for(Account_Play__c accountPlay : [select Id, Lattice_Pre_Lead_External_ID__c from Account_Play__c where Lattice_Pre_Lead_External_ID__c in :setLatticePreLeadIds]) {
                mapLatticeAPId.put(accountPlay.Lattice_Pre_Lead_External_ID__c, accountPlay.Id);
            }
            
            for(Opportunity oppIterator : lstOpportunities) {
                Id accountPlayId = mapLatticeAPId.get(oppIterator.Lattice_PreLead_External_Id__c);
                if(accountPlayId != null) {
                    oppIterator.Lattice_Source_Id__c = accountPlayId;
                }
            }
        }
    }
    
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR9828      15.10       26-Aug-2014     Nurul           To enable data synchronization with Partner Hub, when an Opportunity record is deleted in SFDC.
*/
    public static void storeDeletedOpportunityDetailInPartnerHub(list<Opportunity> lstDeletedOpportunities) {
        list<Partner_Hub_Record_Deleted__c> lstPartnerHubRecords = new list<Partner_Hub_Record_Deleted__c>();
        
        for(Opportunity oppIterator : lstDeletedOpportunities) {
            Partner_Hub_Record_Deleted__c partnerHubRecord = new Partner_Hub_Record_Deleted__c();
            partnerHubRecord.Key_Identifier__c = oppIterator.Deal_Id__c;
            partnerHubRecord.Record_GUID__c = oppIterator.Id;
            partnerHubRecord.Type__c = 'Opportunity';
            lstPartnerHubRecords.add(partnerHubRecord);
        }
        
        if(!lstPartnerHubRecords.isEmpty()) {
            insert lstPartnerHubRecords;
        }
    }
    
    /*
Revision    CR Number   Release No        Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0          11565        16.07         02-June-2015     Prateek         Update supportability indicator on Account
2.0          13449      FY17-DCS-1002   29-Aug-2016       Afiq            Place rollup precedence__c of status in the following order: Not Supportable, Expired, Risk, Under Review, Supportable
*/
    public static void updateSupportabilityIndicator(TriggerHandler.TriggerEvent trigEvent, list<Opportunity> lstOpportunities, map<Id, sObject> mapOldOpportunities)
    {
        set<Id> setAccId = new Set<Id>();
        
        if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT)
        {
            for(Opportunity oppIterator : lstOpportunities)
            {
                setAccId.add(oppIterator.AccountId);
            }
        }
        else if(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE)
        {
            for(Opportunity oppIterator : lstOpportunities)
            {
                if(oppIterator.Supportability_Status__c != ((Map<Id, Opportunity>)mapOldOpportunities).get(oppIterator.Id).Supportability_Status__c)
                {
                    setAccId.add(oppIterator.AccountId);
                }
            }
        }
        System.Debug('Account Ids -'+setAccId);
        
        if(!setAccId.isEmpty())
        {
            Map<String, Supportability_Status_Mapping__c> mapSupportabilityStatusToPrecedence = new Map<String, Supportability_Status_Mapping__c>();
            if(!Test.isrunningTest())
            {
                mapSupportabilityStatusToPrecedence = Supportability_Status_Mapping__c.getAll();
            }
            else
            {
                Map<String, Supportability_Status_Mapping__c> mapSupportabilityStatusToPrecedence_test = new Map<String, Supportability_Status_Mapping__c>{
                            //2.0 Starts here
                            'Not Supportable'=>new Supportability_Status_Mapping__c(Name='Not Supportable', Precedence__c=0.0),
                            'Expired'=>new Supportability_Status_Mapping__c(Name='Expired', Precedence__c=1.0),
                            'Risk'=>new Supportability_Status_Mapping__c(Name='Risk', Precedence__c=2.0),
                            'Under Review'=>new Supportability_Status_Mapping__c(Name='Under Review', Precedence__c=3.0),
                            'Supportable'=>new Supportability_Status_Mapping__c(Name='Supportable', Precedence__c=4.0)                                                                                                                            
                            //2.0 Ends Here
                        };
                            mapSupportabilityStatusToPrecedence = mapSupportabilityStatusToPrecedence_test;
            }  
            System.Debug('Supportability Status -'+mapSupportabilityStatusToPrecedence);            
            
            Map<Integer, String> mapPrecedenceToSupportabilityStatus = new Map<Integer, String>();
            
            for(Supportability_Status_Mapping__c objSSM : mapSupportabilityStatusToPrecedence.values())
            {
                mapPrecedenceToSupportabilityStatus.put(Integer.valueOf(objSSM.Precedence__c), objSSM.Name);
            }
            Map<Id, Account> mapAccIdToAcc = new Map<Id, Account>([SELECT Id, Supportability_Status__c, (SELECT Id, Supportability_Status__c FROM Opportunities WHERE Supportability_Status__c != null) FROM Account WHERE Id IN : setAccId]);
            
            Map<Id, Integer> mapAccIdToPrecedence = new Map<Id, Integer>();
            List<Account> lstAcc = new List<Account>();
            
            for(Account objAcc : mapAccIdToAcc.values())
            {    
                if(objAcc.Opportunities.size() > 0){     
                    for(Opportunity objOpp : objAcc.Opportunities)
                    {
                        //4.0 consolidated two if conditions in one 
                        if((!mapAccIdToPrecedence.containsKey(objAcc.Id)) || (mapAccIdToPrecedence.containsKey(objAcc.Id) && mapAccIdToPrecedence.get(objAcc.Id) > mapSupportabilityStatusToPrecedence.get(objOpp.Supportability_Status__c).Precedence__c))
                        {
                            mapAccIdToPrecedence.put(objAcc.Id, Integer.valueOf(mapSupportabilityStatusToPrecedence.get(objOpp.Supportability_Status__c).Precedence__c));
                        }
                    }
                }
                else
                {
                    lstAcc.add(new Account(Id = objAcc.Id, Supportability_Status__c = ''));
                }
            }
            if(!mapAccIdToPrecedence.isEmpty())
            {             
                for(Id AccId : mapAccIdToPrecedence.keySet())
                {
                    if(mapAccIdToAcc.get(AccId).Supportability_Status__c != mapPrecedenceToSupportabilityStatus.get(mapAccIdToPrecedence.get(AccId)))
                    {
                        lstAcc.add(new Account(Id = AccId, Supportability_Status__c = mapPrecedenceToSupportabilityStatus.get(mapAccIdToPrecedence.get(AccId))));
                    }                   
                }
            }
            if(!lstAcc.isEmpty())
            {
                TriggerExecutionController.setSkipAccountTriggers(true);
                Database.SaveResult[] results = Database.Update(lstAcc, false);
                //update lstAcc;
                TriggerExecutionController.setSkipAccountTriggers(false);
            }
        }
    }
    
/* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR11721     16.07       13-Jul-2015     Jiji            To remove the deal reg analyst with Sales Support role upon opportunity Approve/reject.
*/
    public static void removeSalesSupportRolefromOppTeam(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities) {
        set<String> setRecordTypeNames = new set<String>{'Deal Registration-Submitted'}; 
        map<Id, String> mapRecordType = StaticFactory.getRecordTypeIdNameMapByNames('Opportunity', setRecordTypeNames);
        Set<Id> oppId = new  Set<Id>();
        List<OpportunityTeamMember> oppteamMemberList = new List<OpportunityTeamMember>();
       //try{
        for(Opportunity newOpportunity : lstNewOpportunities) {
            Opportunity oldOpportunity;
            if(mapOldOpportunities != null) {
                oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            }
            if(mapRecordType.get(oldOpportunity.RecordTypeId) != NULL &&
               newOpportunity.Deal_Registration_Status__c != oldOpportunity.Deal_Registration_Status__c &&
               (newOpportunity.Deal_Registration_Status__c == 'Approved' || newOpportunity.Deal_Registration_Status__c == 'Rejected') 
              ){
                  oppId.add(newOpportunity.Id);
              }
        }
        if(oppId != NULL){
            oppteamMemberList = [Select id, OpportunityId, TeamMemberRole from OpportunityTeamMember Where TeamMemberRole = 'Sales Support' AND OpportunityId IN :oppId];
        }
        if(oppteamMemberList != NULL){
            Delete oppteamMemberList;    
        }
    }
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR12076     CSM1102     20-Oct-2015     Fenny           Redesign the SFDC - MyDeal integration via Boomi to make it real time
2.0         CR15166     FY18-0203   26-Nov-2017     Krishnakumar    Display Forecasted Units and Quote Numbers in myDeal

*/
    public static void pushCustomServiceSupportRequestToMyDeal(Map<Id, Opportunity> oppOldMap, Map<Id, Opportunity> oppNewMap){
        //** CODE COVERAGE FOR THIS METHOD WILL BE HANDLED BY afterInsertUpdateSupportRequestTest.integrateMyDealTest **//
        
        // Only need to push associated SR to MyDeal if any opportunity field store in below custom label is updated
        List<string> oppFields = System.Label.Opportunity_Fields_Ref_by_Support_Request.split(','); 
        Set<Id> oppIdSet = null;
        for(Id i : oppOldMap.keySet()){
            for(String field : oppFields){
                if(oppOldMap.get(i).get(field) != oppNewMap.get(i).get(field)){
                    if(oppIdSet == null) { oppIdSet = new Set<Id>(); }
                    oppIdSet.add(i);
                    break;
                }
            }
        }
        //2.0 - start
        if((oppIdSet != null) && (oppIdSet.size() > 0)){
            integrateMyDealCheck(oppIdSet);
        }
        //2.0 End
    }
    
    public static void updateCTICallLog(TriggerHandler.TriggerEvent trigEvent, list<Opportunity> lstOpportunities, map<Id, sObject> mapOldOpportunities)
    {
        set<Id> setCTIId = new Set<Id>();
        Map<id, Opportunity> mapCTIIdToOpp = new Map<Id, Opportunity>();
        if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT)
        {
            for(Opportunity oppIterator : lstOpportunities)
            {
                if(oppIterator.CTI_Call_Log_Id__c != null)
                {
                    setCTIId.add(oppIterator.CTI_Call_Log_Id__c);
                    mapCTIIdToOpp.put(oppIterator.CTI_Call_Log_Id__c, oppIterator);
                }
            }
        }        
        if(!setCTIId.isEmpty())
        {
            Map<Id, CTI_Call_Log__c> mapCTIIdToCTI = new Map<Id, CTI_Call_Log__c>([SELECT Id, Account__c, Opportunity__c FROM CTI_Call_Log__c WHERE Id IN : setCTIId]);
            List<CTI_Call_Log__c> lstCTICallLog = new List<CTI_Call_Log__c>();
            for(Id objCTIId : mapCTIIdToCTI.keySet())
            {               
                if(mapCTIIdToOpp.containsKey(objCTIId))
                {
                    mapCTIIdToCTI.get(objCTIId).Opportunity__c = mapCTIIdToOpp.get(objCTIId).Id;
                    mapCTIIdToCTI.get(objCTIId).Account__c = mapCTIIdToOpp.get(objCTIId).AccountId;
                    lstCTICallLog.add(mapCTIIdToCTI.get(objCTIId));
                }
            }
            if(!lstCTICallLog.isEmpty())
            {
                update lstCTICallLog;
            }
        }
    }
    
    /*  Revision  CR Number       Release No      Date            Modified By       Description
--------     ---------      ----------     -----------     ------------      -----------
1.0           12348          16.12         16-Nov-2015      Dipin Raju       Populate Customer Requested Date based on Book Date
2.0			  18328						   11-Jan-2020		Aditi Singh      Populate Customer Requested Date after editing the Book Date	
*/ 
      public static void updateCustomerReqDate(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities, TriggerHandler.TriggerEvent trigEvent) {
        Set<Id> OppIds = new Set<id>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        
        for(Opportunity c: lstNewOpportunities){
            Opportunity oldOpp = mapOldOpportunities.get(c.Id);
            if(oldOpp.CloseDate!=c.CloseDate) {
                OppIds.add(c.Id); 
                opportunityMap.Put(c.Id, c); 
            }
        }
        if(!OppIds.isEmpty()) {  
            List<OpportunityLineItem> UpdatedProductList = new List<OpportunityLineItem>();
             
            for(OpportunityLineItem lds: [SELECT Id, Customer_Requested_Date__c, Request_Type__c, OpportunityId, Skip_OLI__c,Skip_OLI_Quest__c  FROM OpportunityLineItem WHERE OpportunityId IN :OppIds])
            {
                Boolean dateUpdated = false;
                if(lds.Request_Type__c=='Ship')  {
                    lds.Customer_Requested_Date__c=opportunityMap.get(lds.OpportunityId).CloseDate + 14;
                    dateUpdated = true;
                    lds.Skip_OLI__c = true;
                    lds.Skip_OLI_Quest__c = true;
                  }
                
                if(lds.Request_Type__c=='Delivery')  {
                    lds.Customer_Requested_Date__c=opportunityMap.get(lds.OpportunityId).CloseDate + 21;
                    dateUpdated = true;
                    lds.Skip_OLI__c = true;
                    lds.Skip_OLI_Quest__c= true;
                     }
                if(lds.Request_Type__c=='MABD')  {
                    lds.Customer_Requested_Date__c=opportunityMap.get(lds.OpportunityId).CloseDate;
                    dateUpdated = true;
                    lds.Skip_OLI__c = true;
                    lds.Skip_OLI_Quest__c= true;
                     }
                if(dateUpdated)
                {
                    UpdatedProductList.add(lds);
                 }
                
            }
            if(!UpdatedProductList.isEmpty())
            {
                Update UpdatedProductList;
                
            }   
        }
        system.debug('out updateCustomerReqDate');
    } 

/*  Revision  CR Number       Release No      Date            Modified By       Description
--------     ---------      ----------     -----------     ------------      -----------
1.0           15166          FY18-DCS-0203  26-Nov-2017      Krishnakumar    Display Forecasted Units and Quote Numbers in myDeal

*/     
    @InvocableMethod(label='MyDeal Integration for Oppt Forecasted Units and Quote Numbers' 
                     description='This method will push Forecasted_Units_and_Quote_Numbers2 to MyDeal via Boomi if field updated  ')
    public static void pushOpptQuoteToMyDeal(List<Id> opptIdList){
        Set<Id> opptIDSet = new Set<Id>();  
        If ((!opptIdList.isEmpty()) && (OpptIdList != NULL)){
            opptIDSet.add(opptIdList.get(0));
            integrateMyDealCheck(opptIDSet);
        }
    }
 /*  Revision  CR Number       Release No      Date            Modified By       Description
--------     ---------      ----------     -----------     ------------      -----------
1.0           15166          FY18-DCS-0203  26-Nov-2017      Krishnakumar    Display Forecasted Units and Quote Numbers in myDeal

*/     
    private static void integrateMyDealCheck(Set<Id> oppIdSet){
    
            String CSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);
            Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Custom_Service_Support_Request_Count__c > 0 AND Id IN :oppIdSet]);
            if((opportunities != null) && (opportunities.size() > 0)){
                Map<Id, Support_Request__c> suppReqMap = new Map<Id, Support_Request__c>([SELECT Id FROM Support_Request__c 
                                                                                          WHERE RecordTypeId = :CSS_RECORDTYPEID AND Solution_Architect__c = 'Yes' AND Opportunity__c IN :opportunities.keySet()]);
                if((suppReqMap != null) && (suppReqMap.size() > 0) && SuppReqMyDealIntegration.REQUIRE_CALLOUT && !system.isBatch() && !system.isFuture()){
                    SuppReqMyDealIntegration.integrateMyDeal(suppReqMap.keySet());
                    SuppReqMyDealIntegration.REQUIRE_CALLOUT = false;
                }
            }
    }
    
    /*  
Revision    CR Number         Release No         Date            Modified By       Description
--------    ---------          ----------      -----------     ------------      -----------
1.0         Defect 5078728    FY19-DCS-0602   15-May-2019      Krishnakumar    Merging the VOOpportunity Trigger.    
2.0         Defect 5592142    FY19-DCS-1002   14-Sept-2019     Azwanti         Update Account Region/District field in Visit Bundle when Sales Channel Region Name get updated                 
3.0      Story  6452281    FY20-0702      17-June-2019     Rajiv       Updated all the missing sync logic for Visit Bundle updates, Syncs the missing opportunities too
*/         

    public static void updateVisitOpsDetails(Map<id,Opportunity> mapOpptyNew,Map<id,Opportunity> mapOpptyOld,map<Id, Account> mapRelatedAccounts, map<Id, Opportunity> mapRelatedRecords){
        set<id> oppIds = new set<id>();
        List<VisitOps__VisitBundle__c> vbList = new List<VisitOps__VisitBundle__c>();
        OWD__c owd = OWD__c.getOrgDefaults();
        Map<String, Id> mapOppNumbers = new Map<String, Id>();
        //system.debug('***********Visit Bundle Called---');
        for(Opportunity objOpp:mapOpptyNew.values()){
            if (mapOpptyOld == null || ((mapOpptyOld.get(objOpp.id).StageName != objOpp.StageName && (objOpp.StageName == owd.Oppty_Stage100__c  || objOpp.StageName == owd.Oppty_Stage0__c)) || (mapOpptyOld.get(objOpp.id).Name != objOpp.Name) || (mapOpptyOld.get(objOpp.id).Amount != objOpp.Amount) || (mapOpptyOld.get(objOpp.id).StageName != objOpp.StageName)|| (mapOpptyOld.get(objOpp.id).CloseDate != objOpp.CloseDate)  || (mapOpptyOld.get(objOpp.id).Primary_Competitor__c != objOpp.Primary_Competitor__c)||  (mapOpptyOld.get(objOpp.id).Deal_ID__c != objOpp.Deal_ID__c)||  (mapOpptyOld.get(objOpp.id).OwnerId  != objOpp.OwnerId )||  (mapOpptyOld.get(objOpp.id).Type != objOpp.Type)||  (mapOpptyOld.get(objOpp.id).Account != objOpp.Account)||  (mapOpptyOld.get(objOpp.id).Affinity_ID__c != objOpp.Affinity_ID__c)||  (mapOpptyOld.get(objOpp.id).Reason_Won_Lost__c != objOpp.Reason_Won_Lost__c)||  (mapOpptyOld.get(objOpp.id).Probability != objOpp.Probability) || (mapOpptyOld.get(objOpp.id).EMC_Opportunity_ID__c != objOpp.EMC_Opportunity_ID__c) ||  (mapOpptyOld.get(objOpp.id).Duplicate_Opportunity_ID__c != objOpp.Duplicate_Opportunity_ID__c) || (mapOpptyOld.get(objOpp.id).EMC_Opportunity_Number__c != objOpp.EMC_Opportunity_Number__c))) {
                    oppIds.add(objOpp.id);
                    vbList.addAll(mapRelatedRecords.get(objOpp.id).VisitOps__VisitBundles__r);
      }
      //Check if Opportunities are linked or not, if not linked then collect the visit bundle items to pupulate the Opportunity field
            if(objOpp.EMC_Opportunity_Number__c != null && (mapOpptyOld == null || (mapOpptyOld.get(objOpp.id).Deal_ID__c != objOpp.Deal_ID__c) || (mapOpptyOld.get(objOpp.id).EMC_Opportunity_Number__c != objOpp.EMC_Opportunity_Number__c)))
            {
                mapOppNumbers.put(objOpp.EMC_Opportunity_Number__c, objOpp.Id);
            }
        }
        //Get the Visit Bundles for which we need to link the Opportunities, and add them to vbList to be updated for the related opportunities 
        if(!mapOppNumbers.isEmpty())
        {
            for(VisitOps__VisitBundle__c vblVar : [select id,Corresponding_Opportunity_ID__c, VisitOps__Opportunity__c,VisitOps__visit__r.Owner.Email,VisitOps__Opportunity__r.StageName
                                                   From VisitOps__VisitBundle__c Where Corresponding_Opportunity_ID__c IN :mapOppNumbers.keySet()])
            {
                if(mapOppNumbers.containsKey(vblVar.Corresponding_Opportunity_ID__c))
                {
                    
                    vblVar.VisitOps__Opportunity__c = mapOppNumbers.get(vblVar.Corresponding_Opportunity_ID__c);
                    vbList.add(vblVar);
                }
            }
        }
        //system.debug('***********Visit Bundle Called---'+mapOppNumbers);
        if(!oppIds.isEmpty() || !mapOppNumbers.isEmpty()){
            system.debug('***********Visit Bundle Called---'+mapOppNumbers);
            List<VisitOps__VisitBundle__c> list2Update = new List<VisitOps__VisitBundle__c>();
            VisitOps__VisitBundle__c objVistOps;
            for (VisitOps__VisitBundle__c vBundle : vbList) {
                objVistOps = new VisitOps__VisitBundle__c();
                objVistOps.id=vBundle.id;

                //Check if the stage name is changed and and the changed stage name is either 'Closed Won' or 'Closed Lost'
                if ((mapOpptyOld == null || mapOpptyOld.get(vBundle.VisitOps__Opportunity__c).StageName!=vBundle.VisitOps__Opportunity__r.StageName)
                && (vBundle.VisitOps__Opportunity__r.StageName== owd.Oppty_Stage100__c 
                    || vBundle.VisitOps__Opportunity__r.StageName==  owd.Oppty_Stage0__c)) {
                        objVistOps.VisitOps__Send_Notification_to_Visit_Team_Owner__c = true;
                        objVistOps.VisitOps__Visit_Team_Owner_Email__c = vBundle.VisitOps__visit__r.Owner.Email;
                }

                //Update the Opportunity details in the Visit Bundle
                objVistOps.VisitOps__VB_OppName__c = mapOpptyNew.get(vBundle.VisitOps__Opportunity__c).Name;
                objVistOps.VisitOpsP__Opp_Name__c = mapOpptyNew.get(vBundle.VisitOps__Opportunity__c).Name;
                if (mapRelatedAccounts!=null && !mapRelatedAccounts.isEmpty()) {
                    account acc=mapRelatedAccounts.get(mapOpptyNew.get(vBundle.VisitOps__Opportunity__c).AccountId);
                    objVistOps.VisitOps__VB_CompanyName__c = acc.Name;
                    if(acc.Billing_Address_CN__c!=null){
                    	objVistOps.VO_Account_Address__c = acc.Billing_Address_CN__c.replace('<br>',' ');
                    }
                    objVistOps.VO_Account_Classification__c = acc.Account_Classification__c;
                    objVistOps.VO_Account_Country__c = acc.Account_Country__c;
                    objVistOps.VO_Account_Segment_Name__c = acc.Segment_Name__c;
                    objVistOps.VO_Account_Segment_Desc__c = acc.Segment_Desc__c;
                    objVistOps.VO_Account_Segment_Business_Unit__c = acc.Segment_Business_Unit_Name__c;
                }
                Opportunity opp = mapOpptyNew.get(vBundle.VisitOps__Opportunity__c);
                objVistOps.VisitOps__VB_OppSalesStage__c = opp.StageName;   
                objVistOps.VisitOps__VB_OppCloseDate__c = opp.CloseDate;
                objVistOps.VisitOps__VB_OppMainCompetitors__c = opp.Primary_Competitor__c;
                objVistOps.VO_Opportunity_Deal_ID_Number__c = String.isNotBlank(opp.Deal_ID__c) ? opp.Deal_ID__c : opp.EMC_Opportunity_Number__c;
                
                objVistOps.VO_Opportunity_Owner__c = mapRelatedRecords.get(opp.id).Owner.Name;
                objVistOps.VO_Opportunity_Type__c = opp.Type;
                objVistOps.VO_Account_Region_District__c = opp.Sales_Channel_Region_Name__c; // CR16455 opp.Sales_Channel_Region__c;
                objVistOps.VO_Account_SFDC_ID__c = opp.AccountId;
                objVistOps.VO_Account_Affinity_ID__c = opp.Affinity_ID__c;
                objVistOps.VO_Opportunity_Reason_Won_Lost__c = opp.Reason_Won_Lost__c;
                objVistOps.VO_Probability__c = string.valueof(opp.Probability);
                objVistOps.Opp_Amount__c=opp.Unweighted_Rev_USD__c;
                objVistOps.VisitOps__VB_OppAmount__c =opp.Unweighted_Rev_USD__c;
                objVistOps.CurrencyIsoCode='USD';
                objVistOps.Corresponding_Opportunity_ID__c = String.isNotBlank(opp.Deal_ID__c) ? opp.EMC_Opportunity_Number__c : opp.Deal_ID__c;
                
                objVistOps.VO_Duplicate_Opportunity_ID__c = opp.Duplicate_Opportunity_ID__c;
                objVistOps.VisitOps__Opportunity__c = vBundle.VisitOps__Opportunity__c;
                list2Update.add(objVistOps);
            }   
            if(!list2Update.isEmpty()){
                update list2Update;
            } 
        }         

    }
    
    /**
    * Use this Queable class to perform visit bundle update when there is change in related Opportunity.
    * This helps us overcome the 101 issue from Opportunity related triggers
    */
    public class VisitBundleAsyncExecution implements Queueable {
		public Map<id,Opportunity> mapOpptyNew;
        public Map<id,Opportunity> mapOpptyOld;
        public map<Id, Account> mapRelatedAccounts;
        public map<Id, Opportunity> mapRelatedRecords;
        
        public VisitBundleAsyncExecution(Map<id,Opportunity> mapOpptyNew,Map<id,Opportunity> mapOpptyOld,map<Id, Account> mapRelatedAccounts, map<Id, Opportunity> mapRelatedRecords)
        {
            this.mapOpptyNew = mapOpptyNew;
            this.mapOpptyOld = mapOpptyOld;
            this.mapRelatedAccounts = mapRelatedAccounts;
            this.mapRelatedRecords = mapRelatedRecords;
            
        }
        public void execute(QueueableContext context) {
            updateVisitOpsDetails(mapOpptyNew, mapOpptyOld, mapRelatedAccounts, mapRelatedRecords);      
        }
	}
}