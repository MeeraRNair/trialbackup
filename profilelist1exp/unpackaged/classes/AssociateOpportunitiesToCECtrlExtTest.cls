/*****************************************************************************************************************
* Name          : AssociateOpportunitiesToCECtrlExtTest
* Description   : Test Method for AssociateOpportunitiesToCECtrlExt.
* ---------------------------------------------------------
* Revision  Name            Date            Description
* 1.0       Manikandan      8.08.2011       CR 6345 - Defect ID : 71878.
* 2.0       Krishnamoorthi  26.06.2012      R 13.7 CR 6948 - Changes 
* 3.0       Venu K			06-12-2019		Implemented TDF for 0102 release
******************************************************************************************************************/

@isTest
private class AssociateOpportunitiesToCECtrlExtTest {
    static Attending_Accounts__c newAttendingAccounts = new Attending_Accounts__c();
    static Attending_Accounts__c newAttendingAccounts1 = new Attending_Accounts__c();
    static Customer_Engagement__c testCustEngObj;
    static list<user> listUser;
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccfromFactory[0].Account_Country_Code__c='US';
        insert listAccfromFactory;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Standard Opportunity');
        insert listOppTdf;
        list<User> listuserTDF = TestDataFactory.createNPortalUser(1);
        insert listuserTDF;
    }
    static testMethod void associateOpportunitiesToCECtrlExt() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc=[Select id from Account Limit 1];
        list<Opportunity> listOpp=[Select id from Opportunity Limit 2];
        listOpp[0].AccountId=listAcc[0].id;
        listOpp[1].AccountId=listAcc[0].id;
        update listOpp;
        system.assertEquals(listOpp[0].AccountId, listAcc[0].id);
        Contact primaryContact = new Contact(FirstName = 'ContactExcSafeWord1', LastName = 'ContactExcSafeWord1', 
                                             AccountId = listAcc[0].Id, Phone = '11111', 
                                             Decision_Making_Role__c = 'Influencer', Job_Function__c = 'IT',
                                             Purchaser_Influence_over_Merged__c = 'Client-Desktops' );
        
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Customer_Engagement__c' and 
                                 name = 'Executive Briefing Center'];
        listUser = [SELECT Id FROM USER  limit 1];
        testCustEngObj = new Customer_Engagement__c(Name = 'Mytest CE',
                                                    Requestor_Name__c = listUser[0].Id, 
                                                    Estimated_no_of_Customer_Attendees__c = 11,
                                                    Primary_Account__c = listAcc[0].Id,
                                                    Primary_Contact__c = primaryContact.Id,
                                                    NDA__c = 'Yes',
                                                    Event_Status__c = 'Pending',
                                                    Submitted_Date__c = System.today(),
                                                    RecordTypeId = recordType.Id);
        insert testCustEngObj;
        newAttendingAccounts.Account__c = listAcc[0].Id;
        newAttendingAccounts.Customer_Engagement__c = testCustEngObj.Id;
        newAttendingAccounts.NDA__c = 'Yes';
        newAttendingAccounts.Trade_Compliant__c = 'Yes';
        insert newAttendingAccounts;   
        TriggerExecutionController.setSkipAllTriggers(false);     
        List<AssociateOpportunitiesToCECtrlExt.OpportunityWrapper> listOppAssociate = new List<AssociateOpportunitiesToCECtrlExt.OpportunityWrapper>();
        AssociateOpportunitiesToCECtrlExt.OpportunityWrapper wrapperElt = new AssociateOpportunitiesToCECtrlExt.OpportunityWrapper(listOpp[0]);        
        wrapperElt.selected = true;
        listOppAssociate.add(wrapperElt); 
        PageReference pref = Page.AssociateOpportunitiesToCE;
        pref.getParameters().put('id',testCustEngObj.Id);
        Test.setCurrentPage(pref);
        AssociateOpportunitiesToCECtrlExt con = new AssociateOpportunitiesToCECtrlExt();
        con.getListStageNames();
        con.makequery();
        con.search();
        con.cancel();
        con.getPAGE_SIZE();
        con.associateOpportunity();
        con.setPAGE_SIZE(1);
        con.Next();
        con.Previous();
        con.ok();
    }
}