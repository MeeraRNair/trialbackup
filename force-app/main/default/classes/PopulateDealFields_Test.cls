/*
History:
  Revision CR Number   Release No       Date            Modified By     Description     
--------------------------------------------------------------------------------------
* 1.0      CR 14307    FY18-DCS0602     24-May-2017     Sajith          Lead Opportunity Product Map trigger test
* 2.0      CR 14735    FY18-DCS-1001    07-Aug-2017     Ashok           Object API Name Change
*/
@isTest
public class PopulateDealFields_Test{
    static Opportunity testOpportunity;
    static Account testAccountObj;
    
    static testMethod void testLeadOpportunityInsert() {
        // TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;
        testAccountObj =new Account(name='Renewal Test Account', Account_Country_Code__c = 'JC', Account_Country__c = 'Jedi Country');
        insert testAccountObj;
        testOpportunity= new Opportunity(Name='Test Oppty',AccountId= testAccountObj.Id,Distributor_Reseller_Name__c=testAccountObj.Id, StageName='10%', CloseDate = System.Today() + 30 ); 
        insert testOpportunity;
        opportunity opp = [select id,deal_id__c from opportunity where id=:testOpportunity.id];
        system.debug('@@@@Deal ID From Opportunity' + testOpportunity.id);
        Lead_Opportunity__c objtestM= New Lead_Opportunity__c();
        objtestM.Account__c=testAccountObj.Id;
        objtestM.Opportunity_Id__c=opp.deal_id__c;//testOpportunity.Deal_ID__c;
        system.debug('@@@@Deal ID From Lead Opportunity' + testOpportunity.id);
        insert objtestM;
        }
}