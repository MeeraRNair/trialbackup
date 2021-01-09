/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13171       FY17-DCS-0701   27-May-2016     Fenny           Unit test code to cover ProcessFlowTriggerController
                                                                        This version only cover for Account, Opportunity, OpportunityLineItem trigger
2.0         13542       FY17-DCS-1101   28-Sep-2016     Gan             Skip Lead triggers by process flow

3.0         14104       FY18-DCS-0403   16-Mar-2017     SriRamaKrishna  Skip User Triggers by process flow
4.0         14068       FY18-DCS-0502   14-Mar-2017     SuiYee          Skip GDM triggers by Process flow
5.0         15781       FY19-DCE-0703   30-May-2018     Fenny           Skip Case triggers by Process flow
6.0         7569003     FY200DCS-1101   22-Oct-2019     Monisha         Skip S&P Vendor triggers by Process flow
*/    

@isTest(SeeAllData=false)
public class ProcessFlowTriggerControllerTest{
    private static testMethod void testSkipTriggers(){
        system.assert(!TriggerExecutionController.skipAccountTriggers()); // 1.0
        system.assert(!TriggerExecutionController.skipOpportunityTriggers()); // 1.0
        system.assert(!TriggerExecutionController.skipOpportunityLineItemTriggers()); // 1.0
        system.assert(!TriggerExecutionController.skipLeadTriggers()); //2.0
        system.assert(!TriggerExecutionController.skipUserTriggers()); //3.0
        system.assert(!TriggerExecutionController.skipGDMRequestTriggers()); //4.0
        system.assert(!TriggerExecutionController.skipCaseTriggers()); //5.0
        system.assert(!TriggerExecutionController.skipSnPVendorTriggers());//6.0

        List<string> listObjectAPINames = new List<string>();
        listObjectAPINames.add('Account,Lead'); // 2.0
        listObjectAPINames.add('Opportunity'); // 1.0
        listObjectAPINames.add('OpportunityLineItem'); // 1.0
        listObjectAPINames.add('User');//3.0
        listObjectAPINames.add('GDM Request');//4.0
        listObjectAPINames.add('Case');//5.0
        listObjectAPINames.add('S&P Vendors');//6.0
        ProcessFlowTriggerController.isTest = true;
        ProcessFlowTriggerController.skipTriggers(listObjectAPINames);
        
        system.assert(TriggerExecutionController.skipAccountTriggers()); // 1.0
        system.assert(TriggerExecutionController.skipLeadTriggers()); // 2.0
        system.assert(TriggerExecutionController.skipOpportunityTriggers()); // 1.0
        system.assert(TriggerExecutionController.skipOpportunityLineItemTriggers()); // 1.0
        system.assert(TriggerExecutionController.skipUserTriggers());//3.0
        system.assert(TriggerExecutionController.skipGDMRequestTriggers());//4.0
        system.assert(TriggerExecutionController.skipCaseTriggers()); //5.0
        system.assert(TriggerExecutionController.skipSnPVendorTriggers());//6.0
    }
}