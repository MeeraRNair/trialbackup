/* 
Author: Che Saidi, Shahiruni Wahida <Shahiruni_Saidi@dell.com>

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     25-MAY-2015     Che Saidi, Shahiruni Wahida      Created for CR11515, CR11516, CR11517, CR11518 to show relevant summary data of Account Plan
2.0     08-JUNE-2015    Che Saidi, Shahiruni Wahida      Modified for CR11595, CR11596 to do refresh logic and Right Bottom Box data
3.0     09-JUNE-2015    Chiong, Emily                    Modified for CR11594 to do calculation for Opportunity Fulfillment 
4.0     10-JUNE-2015    Jessie Tan                       Modified for CR11597 to do calculation for No Of Unlinked Opportunity and Linked Opportunities
5.0     23-JUNE-2015    Jessie Tan                       Modified for CR11636 to do calculation for No of Activity
6.0     29-AUG-2015     Jessie Tan                       Modified for CR11896 to rectify the calculation for No of Linked Opportunity
7.0     29-Jun-2017     Sriram                           CR 14544 - Added "Order Submitted - 99%" picklist value under StageName and introduced custom settings for StageName picklist values
*/
public class VFC_AccountPlanSummary {
    
    public SFDC_Acct_Plan__c accPlan {get;set;}
    public String accPlanId {get;set;}
    public String statusDateStr {get;set;}
    public String createdDateStr {get;set;}    
    public Integer APLCount {get;set;}
    
    public Integer opptyFulfilment {get;set;}
    public Integer NoOfLinkedOpp {get;set;}
    public Integer NoOfUnLinkedOpp {get;set;}
    public String buOfferedStr {get;set;}       
    public Integer NoOfActivity {get;set;}     
    public String errorMessage {get;set;}  
    
    private Double opptyRollUpTotal; 
    private Map<String, Double> currencyConvMap;
    private Set<Id> strategyIdSet;
    private Set<Id> currentAPStrategyIdSet;
    public owd__c owd {set;get;}// CR -14544
    
    public VFC_AccountPlanSummary() {
    
    owd = owd__c.getOrgDefaults();//CR -14544
        try{
           
            initialize();
            getAccPlans(); 
              
        }catch (Exception e){
    
            handleError(e);
    
        } 
        
    }
    
    private void handleError(Exception e){                
      
        //String errMsg;                
        
        System.debug('### error Stack Trace: ' + e.getStackTraceString());
        System.debug('### error Message: ' + e.getMessage());
        System.debug('### error: ' + e);
        
        errorMessage = 'There is unexpected problem happened. Please kindly click on <b>Refresh</b> button again. If the problem keeps happening, please contact your administrator.';
          
    }    
    
    private void resetSettings(){
    
        errorMessage = null;
        
    }
    
    private void initialize(){        
        currencyConvMap = CurrencyUtils.getCurrencyConversionMap();
    }
    
    public void getAccPlans(){
        
        accPlanId = ApexPages.currentPage().getParameters().get('id'); 
        
        if(accPlanId != null){
            accPlan = [SELECT Account__c, Account__r.Name, Name, Account_Plan_ID__c, Plan_Starting_Fiscal_Year__c, Account_Plan_Owner__c,  Account_Plan_Owner__r.name, Status__c, CreatedDate, 
                            Date_Approved_by_Sales_Management__c, Date_Rejected__c, Last_4Q_Revenue__c, No_of_Strategies__c, X4Q_Revenue_Plan__c, Annual_Value_of_Strategies__c, CurrencyIsoCode,
                            Last_4Q_Margin__c, Go_To_Market_Approach__c, Previous_NPS_Results__c, Current_NPS_Results__c, Anticipated_IT_Spend_with_Dell__c, 
                            Share_of_Wallet_with_Dell__c, Plan_Status__c, Account_Annual_IT_Spend__c    
                        FROM SFDC_Acct_Plan__c 
                        WHERE Id = :accPlanId];    
                        
            if(accPlan != null){
            
                getDates();
                
                getNoOfAccountPlanningContacts(accPlan.Account__c);
                
                getStrategy(accPlanId);
                
                //v4.0 - start
                getNoOfLinkedAndUnlinkedOpp();
                //v4.0 - end 
                
                //v5.0 - start              
                getNoOfActivity();
                //v5.0 - end
                
            }
            
        }
    }
    
    //get No of Account Planning Contacts 
    public void getNoOfAccountPlanningContacts(Id accId){
    
        APLCount = [SELECT COUNT() 
                    FROM Contact 
                    WHERE AccountId = :accId 
                    AND Main_Contact__c = true];
                    
    }
    
    //get formatted Approved/Rejected Date value and Created Date
    public void getDates(){
        
        DateTime statusDate;
        
        if(accPlan.Plan_Status__c == 'Pending' || accPlan.Plan_Status__c == 'Waiting for Strategies' || accPlan.Plan_Status__c == 'Submitted for Approval'){
            statusDate = null;
        }else if(accPlan.Plan_Status__c == 'Reviewed and Approved'){
            statusDate = accPlan.Date_Approved_by_Sales_Management__c;
        }else if(accPlan.Plan_Status__c == 'Rejected'){
            statusDate = accPlan.Date_Rejected__c;
        }
        
        if(statusDate != null){
            statusDateStr = statusDate.format('dd/MM/yyyy');    
        }
        
        if(accPlan.createdDate  != null){
            createdDateStr = accPlan.createdDate.format('dd/MM/yyyy');    
        }
    }
    
    //v4.0 - start
    //get No of Linked and Unlinked Oppty
    public void getNoOfLinkedAndUnlinkedOpp(){
   // CR 14544 - Start
        List<string> listOptyStages=  new List<string>{owd.Oppty_Stage1__c, owd.Oppty_Stage10__c, owd.Oppty_Stage30__c, owd.Oppty_Stage60__c, owd.Oppty_Stage90__c, owd.Oppty_Stage99__c};
        NoOfUnLinkedOpp = [Select count() from Opportunity where AccountId = :accPlan.Account__c and StageName IN :listOptyStages and CloseDate >=today and Related_Strategy__c = null ];
    // CR 14544 - End
        //v6.0 - start
        //NoOfLinkedOpp = [Select count() from Opportunity where AccountId = :accPlan.Account__c and Related_Strategy__c != null ];
        NoOfLinkedOpp = [Select count() from Opportunity where Related_Strategy__c IN :currentAPStrategyIdSet];
        //v6.0 - end 
        
    }
    //v4.0 - end 
    
    //v5.0 - start
    //get No of Activity
    public void getNoOfActivity(){
     
        Integer tripReportCount = [Select count() from CustomerInteraction__c where Account__c = :accPlan.Account__c and (Date__c >= LAST_N_DAYS:135 and Date__c <= NEXT_N_DAYS:135)];
        
        Integer eventCount = [Select count() from Event where (AccountId = :accPlan.Account__c or WhatId IN :strategyIdSet) and (StartDateTime >= LAST_N_DAYS:135 and StartDateTime <= NEXT_N_DAYS:135)];
        
        Integer taskCount = [Select count() from Task where (AccountId = :accPlan.Account__c or WhatId IN :strategyIdSet) and (ActivityDate >= LAST_N_DAYS:135 and ActivityDate <= NEXT_N_DAYS:135)];
        
        NoOfActivity = tripReportCount + eventCount + taskCount ;
        
        System.debug('### No Of Activity : ' + NoOfActivity );
        
    }
    //v5.0 - end 
    
    //v5.0 - start
    //get Opportunity roll up total & Opportunity Fulfillment %
    public void getStrategy(Id accPlanId){
        //Double opptyRollUpTotalThisFY = 0;
        opptyRollUpTotal = 0;
        opptyFulfilment = 0;
        buOfferedStr = '';
                
        Double annualValueOfStrategyInUSD = 0;
        Set<String> buOfferedSet = new Set<String>();
        strategyIdSet = new Set<Id>();
        
        //v6.0 - start
        currentAPStrategyIdSet = new Set<Id>();
        //v6.0 - end 
        
    /*
        strategyList = [Select Open_Opportunity_Value_1st_Half__c, Open_Opportunity_Value_2nd_Half__c, Open_Opportunity_Value_Next_FY__c,
                           Closed_Opportunity_Value_1st_Half__c, Closed_Opportunity_Value_2nd_Half__c, 
                           Which_LOB_will_you_offer__c 
                        From SFDC_Strategy__c  
                        Where SFDC_Acct_Plan__c = :accPlanId];
      */
        
        List<SFDC_Strategy__c> strategyList = [Select Id, SFDC_Acct_Plan__c, Open_Opportunity_Value_1st_Half__c, Open_Opportunity_Value_2nd_Half__c, Open_Opportunity_Value_Next_FY__c,
                           Closed_Opportunity_Value_1st_Half__c, Closed_Opportunity_Value_2nd_Half__c, 
                           Which_LOB_will_you_offer__c 
                        From SFDC_Strategy__c  
                        Where SFDC_Acct_Plan__r.Account__c = :accPlan.Account__c];
          
        if (strategyList != null && strategyList.size() > 0){
            
            for(integer i=0; i<strategyList.size(); i++){
            
                strategyIdSet.add(strategyList[i].Id);
                
                if(strategyList[i].SFDC_Acct_Plan__c==accPlanId){
                
                    //v6.0 - start
                    currentAPStrategyIdSet.add(strategyList[i].Id);
                    //v6.0 - end
                    
                    if (strategyList[i].Open_Opportunity_Value_1st_Half__c == null)
                        strategyList[i].Open_Opportunity_Value_1st_Half__c = 0;
                    
                    if (strategyList[i].Open_Opportunity_Value_2nd_Half__c == null)
                        strategyList[i].Open_Opportunity_Value_2nd_Half__c = 0;
                    
                    //if (strategyList[i].Open_Opportunity_Value_Next_FY__c == null)
                        //strategyList[i].Open_Opportunity_Value_Next_FY__c = 0;
                    
                    if (strategyList[i].Closed_Opportunity_Value_1st_Half__c == null)
                        strategyList[i].Closed_Opportunity_Value_1st_Half__c = 0;
                    
                    if (strategyList[i].Closed_Opportunity_Value_2nd_Half__c == null)
                        strategyList[i].Closed_Opportunity_Value_2nd_Half__c = 0;
                    
                    /*   
                    opptyRollUpTotal += strategyList[i].Open_Opportunity_Value_1st_Half__c.intValue() +    
                                        strategyList[i].Open_Opportunity_Value_2nd_Half__c.intValue() +
                                        strategyList[i].Open_Opportunity_Value_Next_FY__c.intValue() +
                                        strategyList[i].Closed_Opportunity_Value_1st_Half__c.intValue() +
                                        strategyList[i].Closed_Opportunity_Value_2nd_Half__c.intValue();
                    */
                    
                    opptyRollUpTotal += strategyList[i].Open_Opportunity_Value_1st_Half__c+    
                                                strategyList[i].Open_Opportunity_Value_2nd_Half__c +
                                                strategyList[i].Closed_Opportunity_Value_1st_Half__c +
                                                strategyList[i].Closed_Opportunity_Value_2nd_Half__c;
                    
                    //opptyRollUpTotal = opptyRollUpTotalThisFY + strategyList[i].Open_Opportunity_Value_Next_FY__c;
                                                
                    if(strategyList[i].Which_LOB_will_you_offer__c != null){
                        String buo = strategyList[i].Which_LOB_will_you_offer__c;
                        string[] part;
                        part = buo.split('\\;');
                        
                        for(integer p=0; p<part.size(); p++){
                            buOfferedSet.add(part[p]);
                        }
                    }
                
                }
                
            }
            
            if (accPlan.Annual_Value_of_Strategies__c > 0){
                annualValueOfStrategyInUSD = getConvertedCurrencyInUSD(accPlan.CurrencyIsoCode, accPlan.Annual_Value_of_Strategies__c.doubleValue());
                opptyFulfilment = (opptyRollUpTotal / annualValueOfStrategyInUSD * 100).intValue();
            }
            
            if(buOfferedSet.size() > 0){
                getBUOffered(buOfferedSet);
            }
        } 
    }
    //v5.0 - end 
    
    //get BU Offered value
    public void getBUOffered(Set<String> BUOset){
        for(String s:BUOset) {
            buOfferedStr += (buOfferedStr == ''?'':'; ')+s;
        }
    }
    
    public String getOpptyRollUpTotalInInt(){
        list<String> args = new String[]{'0','number','###,###,##0'};
        String s = String.format(opptyRollUpTotal.intValue().format(), args);
    
        return s;
    }
        
    public pageReference theRefresh(){
        
        try{
        
            resetSettings();
            getAccPlans();
            
        }catch (Exception e){
    
            handleError(e);
    
        } 
        
        return null;
        
    }
    
    public Double getConvertedCurrencyInUSD(string isoCode, Double value){
        Double valueInUSD = 0;
        //map<string,Double> currencyConvMap = getCurrencyConversionMap();
        if(currencyConvMap.containsKey(isoCode)){
            valueInUSD = value/currencyConvMap.get(isoCode);
        }        
        return valueInUSD;
    }
}