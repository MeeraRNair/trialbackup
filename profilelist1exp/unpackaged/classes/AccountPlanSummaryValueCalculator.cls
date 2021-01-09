/*
**********************************************************
* Name          : AccountPlanSummaryValueCalculator 
* Description   : To hold a collection of certain value (currently annualValueofStrategy) of AccountPlan and calculate it for each AccountPlan
* ---------------------------------------------------------
* Revision      Name         Date           Release     Description
* 1.0           Jessie Tan   12-Sep-2015    16.10       Created for CR11943 to calculate the value of Annual Values of Strategie field of Accounnt Plan object
************************************************************/

public class AccountPlanSummaryValueCalculator implements TempDataHolderAndCalculator {

    private Map<Id, Double> annualStrategyValueMap = new Map<Id, Double>();
    private Map<Id, SFDC_Acct_Plan__c> accountPlanMap = null;
    private map<string,Double> currencyConvMap;
    
    public AccountPlanSummaryValueCalculator (){
    
        //retrieve the conversion rates into map
        currencyConvMap = CurrencyUtils.getCurrencyConversionMap();
        
    }
    
    //store the current Account Plan map (for some logic, it needs to refer to current account plan list value)
    public void setAccountPlanMap(Map<Id, SFDC_Acct_Plan__c> accountPlanMap){
        this.accountPlanMap = accountPlanMap;
    }    
    
    public void storeSourceData(Set<Id> accountPlanIdSet){
    
        try{
        
            if(accountPlanIdSet == null || accountPlanIdSet.isEmpty())
                return;             
            
            List<SFDC_Strategy__c> strategyList = [Select CurrencyIsoCode, SFDC_Acct_Plan__c, SFDC_Acct_Plan__r.Plan_Starting_Fiscal_Year__c, SFDC_Acct_Plan__r.CurrencyIsoCode, When_do_you_plan_to_realize_Strategy__c, Potential_Strategy_Value__c from SFDC_Strategy__c where SFDC_Acct_Plan__c IN :accountPlanIdSet ];
            
            for (SFDC_Strategy__c strategy: strategyList ){
                
                //case 1 : when account plan map is not null (this is the case when user updating 'Plan_Starting_Fiscal_Year__c' in Account Plan), 
                //'When_do_you_plan_to_realize_Strategy__c' has to validate against 'Plan_Starting_Fiscal_Year__c' of current value of Account Plan (not old value from database)
                //case 2 : when account plan map is null (this is the case when user updating 'When_do_you_plan_to_realize_Strategy__c' or 'Potential_Strategy_Value__c ' in Strategy), 
                //then the value are checkedagainst 'strategy.SFDC_Acct_Plan__r.Plan_Starting_Fiscal_Year__c' (database value)
                if((accountPlanMap!=null && strategy.When_do_you_plan_to_realize_Strategy__c != accountPlanMap.get(strategy.SFDC_Acct_Plan__c).Plan_Starting_Fiscal_Year__c)
                    ||
                    (accountPlanMap==null && strategy.When_do_you_plan_to_realize_Strategy__c != strategy.SFDC_Acct_Plan__r.Plan_Starting_Fiscal_Year__c)
                 ){
                    continue;
                }
                
                if(strategy.Potential_Strategy_Value__c == null)
                    continue;
                
                if(!annualStrategyValueMap.containsKey(strategy.SFDC_Acct_Plan__c)){
                    annualStrategyValueMap.put(
                        strategy.SFDC_Acct_Plan__c, 
                        getConvertedCurrency(strategy)
                    );
                    continue;
                }
                
                annualStrategyValueMap.put(
                    strategy.SFDC_Acct_Plan__c, 
                    annualStrategyValueMap.get(strategy.SFDC_Acct_Plan__c) 
                        + 
                    getConvertedCurrency(strategy)
                );
                
            }
        
        }catch(Exception e){
            
            System.debug('### Error Message at AccountPlanSummaryValueCalculator : ' + e.getMessage());
            System.debug('### Error at AccountPlanSummaryValueCalculator : ' + e);
            System.debug('### Error Stack Trace at AccountPlanSummaryValueCalculator : ' + e.getStackTraceString());
            
        }
        
    }
    
    //convert the Potential_Strategy_Value__c of each of the strategy to the currencyIsoCode of Account Plan
    private Double getConvertedCurrency (SFDC_Strategy__c strategy){
                
        return getConvertedCurrency(
                   strategy.CurrencyIsoCode, 
                   strategy.Potential_Strategy_Value__c.doubleValue(),
                   (
                       accountPlanMap==null
                           ?
                       strategy.SFDC_Acct_Plan__r.CurrencyIsoCode
                           :
                       accountPlanMap.get(strategy.SFDC_Acct_Plan__c).CurrencyIsoCode
                   )
                );
    
    }
    
    public Decimal calculateResult(Id id){
    
        return (annualStrategyValueMap.get(Id)==null)?0:Decimal.valueOf(annualStrategyValueMap.get(Id));    
    
    }
    
    //convert the currency to target currencyIsoCode given the source currencyIsoCode and source value
    private Double getConvertedCurrency (string sourceIsoCode, Double sourceCurrencyValue, string targetIsoCode){
        Double targetCurrencyValue = 0;
        
        if(currencyConvMap.containsKey(sourceIsoCode) && currencyConvMap.containsKey(targetIsoCode)){
            targetCurrencyValue = sourceCurrencyValue/currencyConvMap.get(sourceIsoCode) * currencyConvMap.get(targetIsoCode);
        }
        
        return targetCurrencyValue ;
    }
    
}