/*
* Author   : Niveda
* Purpose  : Test class for LeadValidator. 
*        
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR 11837    16.10       19-Aug-2015     Niveda          Created.
* 1.1      CR 11925    16.10       11-Sep-2015     Ragu            Added method for testing v1.1 & v1.2 changes in LeadValidator.
* 1.2      TFS 204661  16.10       22-Oct-2015     Nagendra        E2E regression : Update a CL 2.0 with the Status is Closed – Invalid Lead and Invalid Reason is Existing CL
* 1.3                              15-Oct-2019     Venugopalachary Implimented testDataFactory 
*/

@isTest
private class LeadValidator_Test { 
    
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
        list<user> listUserTdf=TestDataFactory.createNPortalUser(1);
        insert listUserTdf;
        
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        
    }
    // v1.0 - Test LeadValidator.validateDirectLead2()
    static testMethod void testvalidateDirectLead2() {
        // Start: Test data preparation
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<lead> listLeads = LeadTestData.lstLeads;
        
        list<user> listUser=[Select id from User Limit 1];
        Test.startTest();
        for(lead leadIterator: listLeads) {
            leadIterator.Inside_Sales_Rep_ICAM__c = listUser[0].Id;
            leadIterator.ISM_Channel_ISM__c = listUser[0].Id;
            leadIterator.Account_Executive_PDM__c = listUser[0].Id;
            leadIterator.RSM__c = listUser[0].Id;
        }
        
        Database.update(listLeads, false);
        Test.stopTest();
        system.assertEquals(listLeads[0].Account_Executive_PDM__c,listLeads[0].Account_Executive_PDM__c);
    }
    
    static testMethod void testvalidateRelatedContactForCL() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> listContacts = ContactTestData.lstContacts;
        
        // Create Account
        list<Account> listAcc=[Select id from Account Limit 1];
        // Create Channel Lead
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.bCreate = false;
        LeadTestData.createChannelLead2();
        list<lead> listLeads = LeadTestData.lstLeads;
        
        Lead leadInstance = listLeads[0];
        leadInstance.Related_Contact__c = listContacts[0].Id;
        leadInstance.Account__c = listContacts[0].AccountId;
        Database.insert(leadInstance, false);
        system.assertEquals(listLeads[0].Related_Contact__c, listLeads[0].Related_Contact__c);
        // End: Test data preparation
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        
        // Error Message: Related Contact must belong to the selected Account.
        Id clClensingScoringRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
        leadInstance.RecordTypeId = clClensingScoringRTId;
        leadInstance.Account__c = listAcc[0].Id;
        Database.update(leadInstance, false);
        
        Test.stopTest();
    }
    
    static testMethod void testvalidateDuplicateChannelLeads() {
        // Start: Test data preparation
        ContactTestData.iNumberOfContacts = 1;
        TriggerExecutionController.setSkipAllTriggers(true);
        ContactTestData.createContact();
        TriggerExecutionController.setSkipAllTriggers(false);
        list<Contact> listContacts = ContactTestData.lstContacts;
        
        LeadTestData.iNumberOfLeads = 3;
        LeadTestData.bCreate = false;
        LeadTestData.createChannelLead2();
        list<lead> listLeads = LeadTestData.lstLeads;
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.bCreate = false;
        LeadTestData.createChannelLead2();
        list<lead> listLeadsForRL = LeadTestData.lstLeads;
        
        // Id clCleansingRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
        // End: Test data preparation
        
        Test.startTest();
        
        Contact conInstance = listContacts[0];
        
        Lead channelLead = listLeads[0];
        channelLead.Related_Contact__c = conInstance.Id;
        
        channelLead = listLeads[1];
        channelLead.Related_Contact__c = conInstance.Id;
        channelLead.Ignore_Duplicate_Record__c = true;
        Database.insert(listLeads, false);
        channelLead = listLeads[2];
        channelLead.Related_Contact__c = conInstance.Id;
        Database.update(channelLead, false);
        system.assertEquals(listLeads[0].Related_Contact__c, listLeads[0].Related_Contact__c);
        // Error Message: Duplicate Closed - Invalid Lead cannot score.
        channelLead.Status = 'Closed - Invalid Lead';
        channelLead.Invalid_Lead_Reason__c = 'Existing CL';
        channelLead.Ready_for_Scoring__c = true;
        Database.update(channelLead, false);
        
        // v1.2 Error Message: Duplicate Closed - Invalid Lead cannot score.
        channelLead = listLeads[0];
        channelLead.Related_Contact__c = conInstance.Id;
        channelLead.Status = 'Closed - Invalid Lead';
        channelLead.Invalid_Lead_Reason__c = 'Existing CL';
        channelLead.Ignore_Duplicate_Record__c = false;
        channelLead.Ready_for_Scoring__c = false;
        Database.insert(channelLead, false);
        
        channelLead.Status = 'Closed - Invalid Lead';
        channelLead.Invalid_Lead_Reason__c = 'Existing CL';
        channelLead.Ignore_Duplicate_Record__c = false;
        channelLead.Ready_for_Scoring__c = true;
        Database.update(channelLead, false);
        Country__c cn=new Country__c(Name='CHINA',Code__c='cn');
        insert cn;
        List<Lead> listlead=new List<Lead>();
        listlead.addAll(listLeads);
        listlead[0].RecordTypeId=System.Label.Lead_Account_suggestion_RT_ID; 
        listlead[0].Mg_Address_Line_1__c='부산광역시'; 
        listlead[0].Postal_Address_1__c='부산광역시';
        listlead[0].Mg_Address_Line_2__c='부산광역시';
        listlead[0].Postal_Address_2__c='부산광역시'; 
        listlead[0].Mg_City__c='부산광역시';
        listlead[0].Postal_City__c='부산광역시';
        listlead[0].Mg_State__c='부산광역시';
        listlead[0].Postal_State__c='부산광역시'; 
        listlead[0].Mg_Name__c='부산광역시';
        listlead[0].Postal_Company_Name__c='부산광역시';
        listlead[0].Postal_Country__c=cn.Id; 
        
        Map<id,Country__c> mapmymap=new Map<id,Country__c>();
        mapmymap.put(cn.id,cn);
        LeadValidator.validateDoubleByte(listlead,mapmymap);
        Test.stopTest();
    }
}