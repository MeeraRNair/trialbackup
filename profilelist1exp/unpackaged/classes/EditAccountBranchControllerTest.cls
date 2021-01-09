/*
* Author : 
*
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
*          CR                      10-Dec-2018     Haribabu.A      STORY 5907651 Removed reference for the fields lob_registration_id__c and direct_account_name__c
*
*/
@isTest(SeeAllData=false)
public class EditAccountBranchControllerTest{
    
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'End-User Account');
        insert listAccTdf;
        list<Account> listAccTdf1=TestDataFactory.createNAccount(1,'Partner Account');
        listAccTdf1[0].Is_GTM_Partner__c = true;
        insert listAccTdf1;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2,'Deal Registration-Submitted');
        for(Opportunity opp : listOppTdf){
            opp.AccountId=listAccTdf[0].id;
        }
        insert listOppTdf;
    }   
    
    private static testMethod void testeditAccountBranchController(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;
        
        test.startTest();
        list<Account> listAcc=[Select id from Account where Recordtype.Name='End-User Account' Limit 1];
        Contact euCon = new Contact();
        euCon.FirstName = 'testFirstName';
        euCon.LastName = 'testLastName';
        euCon.Email = 'test@test.com';
        euCon.Phone = '1234';
        euCon.AccountId = listAcc[0].Id;
        
        list<Account> listAcc1=[Select id from Account where Recordtype.Name='Partner Account' Limit 1];
        Account_Branch__c ab = new Account_Branch__c();
        ab.Account__c = listAcc[0].id;
        ab.Name = 'Test Branch';
        insert ab;
        
        List<LOB_Registration__c> listLobRegList = new List<LOB_Registration__c>();
        
        LOB_Registration__c lobRegClientRecord = new LOB_Registration__c ();
        lobRegClientRecord.LOB_Name__c ='Client';             
        lobRegClientRecord.Registered_End_User__c= listAcc[0].Id;
        lobRegClientRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
        lobRegClientRecord.LOB_registration_status__c = 'Partner(approved)';
        lobRegClientRecord.Preferred_GTM_Partner_Account__c = listAcc1[0].Id;              
        lobRegClientRecord.City__c = 'testCity';
        lobRegClientRecord.Location__c = ab.id;
        lobRegClientRecord.State_Province_Region__c = 'testState';      
        listLobRegList.add(lobRegClientRecord);
        
        LOB_Registration__c lobRegServerRecord = new LOB_Registration__c ();
        lobRegServerRecord.LOB_Name__c ='Server';             
        lobRegServerRecord.Registered_End_User__c= listAcc[0].Id;
        lobRegServerRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
        lobRegServerRecord.LOB_registration_status__c = 'Partner(submit for approval)';
        lobRegServerRecord.Preferred_GTM_Partner_Account__c = listAcc1[0].Id;              
        lobRegServerRecord.City__c = 'testCity';
        lobRegServerRecord.State_Province_Region__c = 'testState';      
        listLobRegList.add(lobRegServerRecord);
        
        LOB_Registration__c lobRegNetworkingRecord = new LOB_Registration__c ();
        lobRegNetworkingRecord.LOB_Name__c ='Networking';             
        lobRegNetworkingRecord.Registered_End_User__c= listAcc[0].Id;
        lobRegNetworkingRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
        lobRegNetworkingRecord.LOB_registration_status__c = 'Partner(submit for approval)';
        lobRegNetworkingRecord.Preferred_GTM_Partner_Account__c = listAcc1[0].Id;              
        lobRegNetworkingRecord.City__c = 'testCity';
        lobRegNetworkingRecord.State_Province_Region__c = 'testState';
        listLobRegList.add(lobRegNetworkingRecord);
        
        LOB_Registration__c lobRegStorageRecord = new LOB_Registration__c ();
        lobRegStorageRecord.LOB_Name__c ='Storage';             
        lobRegStorageRecord.Registered_End_User__c= listAcc[0].Id;
        lobRegStorageRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
        lobRegStorageRecord.LOB_registration_status__c = 'Open';
        lobRegStorageRecord.City__c = 'testCity';
        lobRegStorageRecord.State_Province_Region__c = 'testState';           
        listLobRegList.add(lobRegStorageRecord);
        
        insert listLobRegList;
        
        LOB_Administration__c loa = new LOB_Administration__c();
        loa.Active__c = true;
        loa.LOB_Administration_Name_Unique__c = 'Test Value';
        insert loa;
        system.assertEquals(lobRegStorageRecord.Registered_End_User__c, listAcc[0].Id);
        list<Opportunity> listOpp=[Select id from Opportunity Limit 2];
        TriggerExecutionController.setSkipAllTriggers(false);
        
        ApexPages.StandardController sc = new ApexPages.standardController(ab);        
        editAccountBranchController eab = new editAccountBranchController(sc);
        Test.StopTest(); 
        editAccountBranchController.existingLobsWrapper elWrap = new editAccountBranchController.existingLobsWrapper();
        editAccountBranchController.lobWrapper lobWrap = new editAccountBranchController.lobWrapper(loa);
        eab.processLobList();
        eab.test();
        eab.valueGet();
        eab.save();
        eab.getStrStatus();
        eab.setStrStatus('testStr');
        eab.getstatusExitingLob();
        eab.setstatusExitingLob('TestLob');
        eab.getItems();
        
    }
}