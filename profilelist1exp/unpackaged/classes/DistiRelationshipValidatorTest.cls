/* Revision  Name            Date                 CR         Release No              Description
* 1.0       Jatin         12.06.2018             16018       FY-19-DCS-0802          Commented NET exam logic statements as part of NET003 story
*/


@isTest
private class DistiRelationshipValidatorTest {
    
    @isTest static void testValidateDistiResellerAccounts() {

        Account distiAccount12 = new Account(Name='testOppDistiUser Test Account12', 
                                         Partner_Type__c = 'DISTRIBUTOR (GCC)',
                                          //        Partner_Type__c = 'OEM',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                      //      Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED KINGDOM' ) ;       
        insert distiAccount12;

       Partner_Request__c  request = new Partner_Request__c();
      
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
            'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Sponsoring_Distributor__c = 'testOppDistiUser Test Account12';
        insert request;
        
       Partner_Request__c  request1 = new Partner_Request__c();
      
        request1.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
            'Partner_Request__c', true);
        request1.email__c = 'test@dell.com';
        request1.Export_Compliance_Agreed__c = true;
        request1.Partner_Terms_Conditions__c = true;
        request1.Other_Customers__c = 'test2';
        request1.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request1.Feature_Request_Deal_Registration__c = true;
        request1.Sponsoring_Distributor__c = 'testOppDistiUser Test Account';
        insert request1;

        List<Account> accData = new List<Account>();

        Account resellerAccount = new Account(Name='testOppDistiUser Test Account', 
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Authorized,Storage',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Type__c = 'GLOBAL ALLIANCE',
                                            Status__c = 'Active',
                                            Partner_Registration__c= request.id,
                                            DMU__c = false );
        accData.add(resellerAccount); 

        Account resellerAccount1 = new Account(Name='testOppDistiUser Test Account', 
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Type__c = 'GLOBAL ALLIANCE',
                                            Status__c = 'Active',
                                            Partner_Registration__c= request1.id,
                                            DMU__c = false );
        accData.add(resellerAccount1);      

        Account distiAccount = new Account(Name='testOppDistiUser Test Account', 
                                         Partner_Type__c = 'DISTRIBUTOR (GCC)',
                                          //        Partner_Type__c = 'OEM',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Storage',
                                            Partner_Registration__c= request.id,
                                            Account_Country__c = 'UNITED KINGDOM' ) ;       
        accData.add(distiAccount);

        Account distiAccount1 = new Account(Name='testOppDistiUser Test Account', 
                                            Partner_Type__c = 'DISTRIBUTOR (GCC)',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Authorized',
                                            Partner_Registration__c= request.id,
                                            Account_Country__c = 'UNITED KINGDOM' ) ;    
        accData.add(distiAccount1);
        Database.SaveResult[] srList = Database.insert(accData, false);


//        database.insert accData;  

        List<Disti_Relationship__c> distiRelations = new List<Disti_Relationship__c>();

        Disti_Relationship__c distiObj1  = new Disti_Relationship__c();
        distiObj1.Disti_Account__c = distiAccount.Id;
        distiObj1.Reseller_Account__c = resellerAccount.Id;
        insert distiObj1; 

        Disti_Relationship__c distiObj2  = new Disti_Relationship__c();
        distiObj2.Disti_Account__c = distiAccount1.Id;
        distiObj2.Reseller_Account__c = resellerAccount1.Id;
        insert distiObj2;

        try {
            Disti_Relationship__c distiUpdate = [Select Id, Disti_Account__c, Reseller_Account__c from Disti_Relationship__c where Id =: distiObj1.Id];
            distiUpdate.Disti_Account__c = distiAccount1.Id;
            distiUpdate.Reseller_Account__c = resellerAccount1.Id;
            update distiUpdate;
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Disti Account is already exists') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }

        try {
            Disti_Relationship__c distiObj3  = new Disti_Relationship__c();
            distiObj3.Disti_Account__c = distiAccount1.Id;
            distiObj3.Reseller_Account__c = resellerAccount1.Id;
            insert distiObj3;
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Disti Account is already exists') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Disti_Relationship__c distiObj4  = new Disti_Relationship__c();
        distiObj4.Reseller_Account__c = resellerAccount.Id;
        insert distiObj4; 

        Disti_Relationship__c distiObj5  = new Disti_Relationship__c();
        distiObj5.Reseller_Account__c = resellerAccount1.Id;
        insert distiObj5; 

        Disti_Relationship__c distiObj6  = new Disti_Relationship__c();
        distiObj6.Reseller_Account__c = resellerAccount1.Id;
        insert distiObj6; 
    }
    
}