/*
REVISION HISTORY
================
Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           6-dec-2019          Implimented TestDataFactory        
*/
@isTest
private class AutoPopulateAccountNameTest{
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    @testSetup static void setup() {
        // Create common test Account Data
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Account> listAccTdf=TestDataFactory.createNAccount(3, 'Partner Account');
        insert listAccTdf;
        // Create common test Opportunity Data
        List<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Deal Registration');
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    public static testMethod void testPopulateAccountName(){
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        listAcc=[SELECT id FROM ACCOUNT Limit 2];
        listAcc[0].RecordTypeID=getRecordTypeIdbyName('End-User Account','Account');
        listAcc[0].Unassigned_End_User_Account__c = false;
        
        update listAcc;
        Contact con = new Contact(Lastname = 'Test', Accountid = listAcc[0].id, Email = 'test@dell.com', Phone = '123123123');
        insert con;
        
        End_Customer__c endCustomer = new End_Customer__c(
            Partner_Account__c = listAcc[1].Id,
            Name = 'Test Company',
            Mailing_city__c = 'Test City' ,
            Mailing_country__c = 'Test Country',
            Mailing_State__c = 'Test State',
            Mailing_street__c = 'Test Street',
            Status__c ='Active',
            Website__c = 'www.salesforce.com',
            Zip_Code__c = '664455',
            Account_Industry__c = 'Agriculture'
        );
        insert endCustomer ;
        endCustomer.End_User_Account__c = listAcc[0].Id;
        update endCustomer ;
        listOpp=[SELECT id From Opportunity LIMIT 1];
        listOpp[0].End_Customer__c = endCustomer.Id;
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        update listOpp;
        map<Id, Opportunity> mapOld = new map<Id, Opportunity>();
        mapOld.put(listOpp[0].Id, listOpp[0]);
        System.debug('***Old Status: '+ listOpp[0].Deal_Registration_Status__c);
        
        list<Opportunity> listnewOpp = [select id, End_Customer__c, Deal_Registration_Status__c from Opportunity where id =: listOpp[0].id];
        listnewOpp[0].Deal_Registration_Status__c= 'Submitted' ;   
        update listnewOpp;
        
        Case caseObj = new Case(ContactId = con.id, AccountId = listAcc[0].id, Opportunity_Title__c = listOpp[0].id, Status = 'Open', Priority = 'High', Subject = 'Sandbox: APPROVAL REQUEST: DealID# End User', Description = 'test' );
        insert caseObj;
        AutoPopulateAccountNameFromEndCustomer.populateAccountName(listnewOpp, mapOld); 
        test.stopTest();
        system.assertEquals('New', listOpp[0].Deal_Registration_Status__c);
    }
    
    public static testMethod void caseCreationTest(){
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        listAcc=[select id from Account ];
        for(Account acc : listAcc){
            acc.Partner_Relationship__c = 'Authorized';
            acc.Account_Country__c = 'UNITED STATES';
            acc.Status__c = 'Active';
            acc.DMU__c = false;
        }
        listAcc[0].Account_Country__c = 'UNITED STATES';
        listAcc[0]. Type = 'Partner';
        listAcc[1]. Partner_Type__c = 'Disti (GCC)';
        listAcc[1].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        listAcc[1].Account_Country__c = 'UNITED KINGDOM';
        listAcc[1].Partner_Tier__c = 'Tier 1';
        Update listAcc;
        
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].id;
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Enterprise_Sales_Approval_Requested__c = true;
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Distributor_ID__c = 'Test Disti User' ;
        listOpp[0].Deal_Registration_Recommendation__c = 'test';
        update listOpp;
        system.assertNotEquals(listOpp[0].id, null);
        map<Id, Opportunity> mapOld = new map<Id, Opportunity>();
        mapOld.put(listOpp[0].Id, listOpp[0]);
        
        List<Opportunity> listnewOpp1 = new List<Opportunity>();
        Opportunity listnewOpp = [Select Id, Deal_Registration_Status__c, Enterprise_Sales_Approval_Requested__c from Opportunity where Id =: listOpp[0].Id];
        
        listnewOpp.Deal_Registration_Status__c= 'Submitted' ;
        listnewOpp.Enterprise_Sales_Approval_Requested__c = true;
        listnewOpp.AccountId=listAcc[2].Id;
        listnewOpp1.add(listnewOpp);
        
        AutoPopulateAccountNameFromEndCustomer.caseCreation(listnewOpp1, mapOld); 
        test.stopTest();
    }
    
    public static testMethod void caseCreationTest1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        listAcc=[select id from account];
        list<id> listaccids=new list<id>(); 
        for(Account acc : listAcc){
            acc.Partner_Relationship__c = 'Authorized';
            acc.Account_Country__c = 'UNITED STATES';
            acc.Status__c = 'Active';
            acc.DMU__c = false;
            listaccids.add(acc.id);
        }
        listAcc[0].Account_Country__c = 'UNITED STATES';
        listAcc[0]. Type = 'Partner';
        listAcc[1]. Partner_Type__c = 'Disti (GCC)';
        listAcc[1].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        listAcc[1].Account_Country__c = 'UNITED KINGDOM';
        listAcc[1].Partner_Tier__c = 'Tier 1';
        Update listAcc;
        
        list<User> listUser=TestDataFactory.createNPortalUser(1);
        listUser[0].isActive = true;
        listUser[0].Enable_Partner_Admin__c = true;
        listUser[0].Enable_Partner_Deal_Registration__c = true;
        insert listUser;
        List<AccountTeamMember> listaccountTeam = new List<AccountTeamMember>();
        AccountTeamMember acctTM1 = new AccountTeamMember(AccountId = listAcc[1].Id, userId = listUser[0].id, TeamMemberRole = 'Sales Rep');
        listaccountTeam.add(acctTM1);
        AccountTeamMember acctTM2 = new AccountTeamMember(AccountId = listAcc[2].Id, userId = listUser[0].id, TeamMemberRole = 'Sales Rep');
        listaccountTeam.add(acctTM2);
        insert listaccountTeam;
        listOpp=[select id from Opportunity limit 1];
        listOpp[0].AccountId=listAcc[1].id;
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Enterprise_Sales_Approval_Requested__c = false;
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Distributor_ID__c = 'Test Disti User' ;
        listOpp[0].Deal_Registration_Recommendation__c='test';
        update listOpp;
        
        map<Id, Opportunity> mapOld = new map<Id, Opportunity>();
        mapOld.put(listOpp[0].Id, listOpp[0]);
        
        List<Opportunity> listnewOpp = [Select Id, Deal_Registration_Status__c, Enterprise_Sales_Approval_Requested__c from Opportunity where Id =: listOpp[0].Id];
        listnewOpp[0].AccountId=listAcc[2].Id; 
        listnewOpp[0].Deal_Registration_Status__c= 'Submitted' ;
        listnewOpp[0].Enterprise_Sales_Approval_Requested__c = true;
        Update listnewOpp;
        
        system.assertnotequals(listOpp[0].AccountId, listnewOpp[0].AccountId);
        system.assertnotequals(listnewOpp[0].AccountId,null);
        
        Contact con = new Contact(Lastname = 'Test', Accountid = listAcc[2].id, Email = 'test@dell.com', Phone = '123123123');
        insert con;
        
        Id caseDelRegistratnRT = StaticFactory.getRecordTypeIdByName('Case', 'EMC DR');
        Case caseObj = new Case(ContactId = con.id, Ownerid = listUser[0].id, AccountId = listAcc[2].id, Opportunity_Title__c = listOpp[0].id, Status = 'Open', Priority = 'High', Subject = 'Sandbox: APPROVAL REQUEST: DealID# End User', Description = 'test', RecordTypeId = caseDelRegistratnRT);
        insert caseObj;
        CaseTeamRole ctrole = [SELECT Id, Name FROM CaseTeamRole Limit 1];
        
        CaseTeamMember teammemberad=new CaseTeamMember(ParentId = caseObj.id, MemberId = listUser[0].id, TeamRoleId = ctrole.id);
        insert teammemberad;
        
        AutoPopulateAccountNameFromEndCustomer.caseCreation(listnewOpp, mapOld); 
        test.stopTest();
    }
    public static Id getRecordTypeIdbyName(String strRecordTypeName,String strobjectName){
        return  Schema.getGlobalDescribe().get(strobjectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
}