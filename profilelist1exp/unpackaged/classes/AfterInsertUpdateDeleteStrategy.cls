/*
**********************************************************
* Name          : afterInserUpdatetDeleteStrategy
* Description   : after insert after update after delete for Strategy
* ---------------------------------------------------------
* Revision      Name         Date           Release     Description
* 1.0           Naga|Kenny   27-Sep-2019    FY20 1101   Calculate the no. of Strategies by current and next fiscal years
************************************************************/
public class  AfterInsertUpdateDeleteStrategy{

    public static void noOfStrategies(List<SFDC_Strategy__c> listNewStrategy, List<SFDC_Strategy__c> listOldStrategy){
        String strCurrentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
         
        Integer intNextFiscalYear = Integer.valueOf(strCurrentFiscalYear) + 1;
        String strNextFY = String.valueOf(intNextFiscalYear);
        System.debug(strNextFY);
        String strCurrentFiscalYr = 'FY' + strCurrentFiscalYear.right(2);
        String strNextFisicalYr ='FY' + strNextFY.right(2);
    
        Set<id> setStrategyId = new Set<id>();
        //List<String> lstWhatBu = new List<String>();   
        //string[] listofFY = new string[]{'+currentNextFiscalYear+'};
        
        if(listNewStrategy != null){
            for (SFDC_Strategy__c strategy: listNewStrategy){
                setStrategyId.add(strategy.SFDC_Acct_Plan__c); 
                system.debug('setStrategyIdnew:'+setStrategyId);  
            }    
        }    
        
        if(listOldStrategy != null){
            for (SFDC_Strategy__c strategy: listOldStrategy){
                setStrategyId.add(strategy.SFDC_Acct_Plan__c);    
                system.debug('setStrategyIddel:'+setStrategyId);      
            }
        }          
        
        Integer intstrategy = 0;
        Integer intClient = 0;
        Integer intCompute = 0;
        Integer intEI = 0;
        Integer intNetworking = 0;
        Integer intPivotal = 0;
        Integer intServices = 0;
        Integer intStorage = 0;
        Integer intVirtustream = 0;
        Integer intVMware = 0;
        Integer intBoomi = 0;
        Integer intCs = 0;
        Integer intClientSp = 0;
        Integer intEsg = 0;
        Integer intSecureWork = 0;
        Integer intRsa = 0;
        Integer intDps = 0;
        Integer intUds = 0;
        Integer intUw = 0;
             
        Map<ID, SFDC_Acct_Plan__c> mapAccPlan= new map<ID, SFDC_Acct_Plan__c>([select id, No_of_Strategies_by_Current_Next_FY__c from SFDC_Acct_Plan__c where id IN :setStrategyId]);
        for(SFDC_Acct_Plan__c accPlan : [select id,Virtustream__c,VMware__c,Storage_Strategy__c,Services__c,Pivotal__c,Networking_Strategy__c,Enterprise_Infrastructure__c,
                    SecureWorks__c,RSA__c,ESG__c,CS__c,Client_S_P__c,Boomi__c,DPS__c,UDS__c,Unified_Workspace__c,Compute_Servers__c,Client_Strategy__c, No_of_Strategies_by_Current_Next_FY__c from SFDC_Acct_Plan__c where id IN :setStrategyId]){
            mapAccPlan.get(accplan.id).No_of_Strategies_by_Current_Next_FY__c = string.valueOf(intstrategy);
            mapAccPlan.get(accplan.id).Virtustream__c = 'N';
            mapAccPlan.get(accplan.id).VMware__c = 'N';
            mapAccPlan.get(accplan.id).Storage_Strategy__c = 'N';
            mapAccPlan.get(accplan.id).Services__c = 'N';
            mapAccPlan.get(accplan.id).Pivotal__c = 'N';
            mapAccPlan.get(accplan.id).Networking_Strategy__c = 'N';
            mapAccPlan.get(accplan.id).Enterprise_Infrastructure__c = 'N';
            mapAccPlan.get(accplan.id).Compute_Servers__c = 'N';
            mapAccPlan.get(accplan.id).Client_Strategy__c = 'N';
            mapAccPlan.get(accplan.id).Boomi__c = 'N';
            mapAccPlan.get(accplan.id).Client_S_P__c = 'N';
            mapAccPlan.get(accplan.id).CS__c = 'N';
            mapAccPlan.get(accplan.id).ESG__c = 'N';
            mapAccPlan.get(accplan.id).RSA__c = 'N';
            mapAccPlan.get(accplan.id).SecureWorks__c = 'N';
            mapAccPlan.get(accplan.id).DPS__c = 'N';
            mapAccPlan.get(accplan.id).UDS__c = 'N';
            mapAccPlan.get(accplan.id).Unified_Workspace__c = 'N';        
        }
        for(SFDC_Strategy__c strategies : [Select When_do_you_plan_to_realize_Strategy__c, SFDC_Acct_Plan__c from SFDC_Strategy__c where (When_do_you_plan_to_realize_Strategy__c LIKE :('%'+strCurrentFiscalYr+'%') OR When_do_you_plan_to_realize_Strategy__c LIKE :('%'+strNextFisicalYr+'%')) and SFDC_Acct_Plan__c IN :mapAccPlan.keyset()]){
            intstrategy++;
            mapAccPlan.get(strategies.SFDC_Acct_Plan__c).No_of_Strategies_by_Current_Next_FY__c = string.valueOf(intstrategy);
            system.debug('intstrategy='+1);
        }
        for(SFDC_Strategy__c strategies : [Select What_BU_s_are_involved__c, Which_LOB_will_you_offer__c, SFDC_Acct_Plan__c from SFDC_Strategy__c where SFDC_Acct_Plan__c IN :mapAccPlan.keyset()]){
            String[] listWhatBuInv;
            String[] listWhatBuOffer;
            Set<string> setStr = new Set<string>();
            if(strategies.What_BU_s_are_involved__c != null){
                listWhatBuInv = strategies.What_BU_s_are_involved__c.split(';');
                setStr.addAll(listWhatBuInv);
            }
            //String listWhatBuInv = strategies.What_BU_s_are_involved__c;
            if(strategies.Which_LOB_will_you_offer__c != null){
                listWhatBuOffer = strategies.Which_LOB_will_you_offer__c.split(';');
                setStr.addAll(listWhatBuOffer);
            }             
            if(setStr.contains('Client')){
                intClient++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Client_Strategy__c = string.valueOf(intClient)+'Y';
            }
            if(setStr.contains('Compute (Servers)')){
                intCompute++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Compute_Servers__c = string.valueOf(intCompute)+'Y';
            }            
            if(setStr.contains('Enterprise Infrastructure')){
                intEI++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Enterprise_Infrastructure__c = string.valueOf(intEI)+'Y';
            }            
            if(setStr.contains('Networking')){
                intNetworking++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Networking_Strategy__c = string.valueOf(intNetworking)+'Y';
            }            
            if(setStr.contains('Pivotal')){
                intPivotal++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Pivotal__c = string.valueOf(intPivotal)+'Y';
            }            
            if(setStr.contains('Services')){
                intServices++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Services__c = string.valueOf(intServices)+'Y';
            }            
            if(setStr.contains('Storage')){
                intStorage++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Storage_Strategy__c = string.valueOf(intStorage)+'Y';
            }
            
            if(setStr.contains('Virtustream')){
                intVirtustream++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Virtustream__c = string.valueOf(intVirtustream)+'Y';
            }            
            if(setStr.contains('VMware')){
                intVMware++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).VMware__c = string.valueOf(intVMware)+'Y';
            }
            if(setStr.contains('Boomi')){
                intBoomi++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Boomi__c = string.valueOf(intBoomi)+'Y';
            }
            if(setStr.contains('Client S&P')){
                intClientSp++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Client_S_P__c = string.valueOf(intClientSp)+'Y';
            }
            if(setStr.contains('CS')){
                intCs++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).CS__c = string.valueOf(intCs)+'Y';
            }
            if(setStr.contains('ESG')){
                intEsg++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).ESG__c = string.valueOf(intEsg)+'Y';
            }
            if(setStr.contains('RSA')){
                intRsa++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).RSA__c = string.valueOf(intRsa)+'Y';
            }
            if(setStr.contains('SecureWorks')){
                intSecureWork++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).SecureWorks__c = string.valueOf(intSecureWork)+'Y';
            }
            if(setStr.contains('UDS')){
                intUds++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).UDS__c = string.valueOf(intUds)+'Y';
            }
            if(setStr.contains('DPS')){
                intDps++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).DPS__c = string.valueOf(intDps)+'Y';
            }
            if(setStr.contains('Unified Workspace')){
                intUw++;
                mapAccPlan.get(strategies.SFDC_Acct_Plan__c).Unified_Workspace__c = string.valueOf(intUw)+'Y';
            }
            
        }
    
    update mapAccPlan.values();
    }
}