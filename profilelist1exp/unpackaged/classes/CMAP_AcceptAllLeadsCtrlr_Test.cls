/*
REVISION HISTORY
======================================================================================================================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0        Afiq        01/10/2015        16.10       12014   Creating a test class for CMAP_AcceptAllLeadsCtrlr class

*/

@isTest(SeeAllData=true)
private class CMAP_AcceptAllLeadsCtrlr_Test{
    static testMethod void MassAcceptAllLeads() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        testData.getAccount(true);
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getCampaign(true);
        CMAP_Helper.skipinsert = true;
        
        Lead leadObj1 = new Lead(lastName = 'Test Lead Mass Assign',
                email ='testcmap1@cmaptest.com',
                status = 'Assigned to Channel Partner',
                Phone='88967544',
                RecordTypeId = leadRTId,
                Budget__c = 'Yes',
                Budget_Range__c =1000,
                Purchase_Timeframe__c ='Immediately',
                Decision_Making_Role__c='Influencer',
                Solution_Type__c='Campus',
                Solution_Scope__c='Hardware and Support Only',
                Product_Focus__c='Servers',
                Focus_LOB__c='EMC',
                Country = 'US',
                Partner_Account__c =testdata.accountObj.Id,
                Campaign__c  = testdata.campObj.Id,
                Company = 'Test Company',
                Partner_User__c =testData.PartnerUser.Id,
                //Partner_Admin__c =testData.pUser2.Id,
                Ready_For_Scoring__C = TRUE,
                Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)'
                );
            
       
        
        insert leadObj1;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.startTest();
        
        List <Lead> pcm = new List<Lead>();
        CMAP_AcceptAllLeadsCtrlr cmap = new CMAP_AcceptAllLeadsCtrlr(new ApexPages.StandardSetController(pcm));        
        cmap.AcceptAllLead();
               
        Test.stopTest();
    }
}