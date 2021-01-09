/* 
* Test Class logic related to LinkedPartnerTracksControllerTest
* Revision CR Number   Release No        Date            Modified By               Description
* -------- ---------   ----------     -----------       ------------               -----------
*                      0102            26-Sep-2018      Venugopalachary k         Implement Test Data Factory                                   
*/
@isTest
private class DistributorResellerInsertTest{
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    @testSetup static void setup() {
        OWD__c oWDsetting  = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert oWDsetting;
        // Create common test Account Data
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Account> listAccTdf=TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTdf;
        // Create common test Opportunity Data
        List<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration');
        insert listOppTdf;
        List<Profile> listpartnerProfiles = [select Id, Name from Profile where name like '%Portal%' limit 1];
        Contact newCont = new Contact(FirstName = 'MyTestContact9', 
                                      LastName = 'MyTestContact9', 
                                      AccountId =listAccTdf[1].Id, 
                                      Status__c  =  'Marketing Suspect', 
                                      Email = 'MyTestContactEmail_9@ust-global.com', 
                                      Fax = '1234567', 
                                      MobilePhone = '0987654', 
                                      Last_Operation_Performed__c = 'testing',
                                      Phone = '1234500');
        insert newCont;
        list<user> listUserTdf=TestDataFactory.createNPortalUser(1);
        listUserTdf[0].isActive=True;
        listUserTdf[0].ProfileId=listpartnerProfiles[0].id;
        listUserTdf[0].ContactId = newCont.Id;
        insert listUserTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void distributorResellerAssign(){
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[select id from Account];
        list<user> listUser=[Select id from User Limit 1];
        user partnerUser = [select id, contactid, accountid from user where id =: listUser[0].id];
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[0].id;
        listOpp[0].Deal_Registration_Status__c= 'New';
        update listOpp;
        system.assertNotEquals(listOpp[0].id, null);
        User us12 = [select id, ContactId, AccountId from User where UserRole.Name like '%Partner user' limit 1];
        
        Opportunity opp =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,Distributor_Reseller_Name__c, StageName,Primary_Product_Delivery_Address_Region__c,Deal_Reg_Oppty__c  from Opportunity where Id =:listOpp[0].Id];
        opp.Distributor_Reseller_Name__c = listAcc[1].id;
        update opp;          
        Map<id,string> mapDist=new map<id,String>();
        mapDist.put(Opp.id,Opp.Distributor_Reseller_Name__c);
        List<Opportunity> listOpp = new List<Opportunity>();
        listOpp.add(opp);
        DistributorResellerInsert.DistributorResellerInserts(listOpp,null);    
        
        Opportunity opp123 =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,Distributor_Reseller_Name__c, StageName,Primary_Product_Delivery_Address_Region__c,Deal_Reg_Oppty__c  from Opportunity where Id =:listOpp[0].Id];
        opp123.Distributor_Reseller_Name__c = us12.AccountId;
        update opp123;
        Map<Id,Opportunity> mapOppold = new Map<Id,Opportunity>(); 
        mapOppold.put(opp123.Id, opp123);                
        DistributorResellerInsert.DistributorResellerInserts(listOpp,mapOppold);    
    }
}