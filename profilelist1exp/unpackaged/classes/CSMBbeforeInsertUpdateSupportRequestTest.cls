@isTest
private class CSMBbeforeInsertUpdateSupportRequestTest{   
    public static Account account;
    public static Opportunity opportunity;
    public static Contact cont;
    public static Support_Request__c supportReq;
    public static RecordType recTyp;
    public static Contract_Manager_Email__c conEmail;
    public static User user1,user2;
    public static Id expectedSupportOwner;
    public static String expectedEmail;
    
    public static voId createData() {
         Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
         account = new Account(name='TEST',recordtypeId=acRecTypeId);
         insert account;
         
         opportunity = new Opportunity(accountId = account.Id,
                                        Name = 'TestOpp',
                                        Type = 'Run Rate',
                                        Solution_Type__c = 'Business Processing',
                                        StageName = 'Plan - 1%',
                                        //CloseDate = date.parse('12/10/2011')); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValIdation
                                        CloseDate = System.Date.TODAY()); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValIdation
         insert opportunity;
         
         cont = new Contact(FirstName = 'TestContact1',
                             LastName = 'TestContactlast1',
                             accountId = account.Id,
                             Email = 'test@ust-global.com',
                             fax = '01987645',
                             MobilePhone = '0000019',
                             Phone = '0000000');
         insert cont;
         
         Profile cmProfile = new profile();
         for(Profile userProfile : [select Id from Profile where name like '%Contract Manager' Limit 1]){
             cmProfile=userprofile;
         }
         user1 = new User(Alias = 'CM101',
                          LastName = 'testCM101',
                          Email = 'x.y@ust-global.com',
                          Username = 'x.y@q.com',
                          CommunityNickname = 'testCM101',
                          EmailEncodingKey = 'ISO-8859-1',
                          TimeZoneSIdKey = 'America/Panama',
                          LocaleSIdKey = 'en_US',
                          LanguageLocaleKey = 'en_US',
                          ProfileId = cmProfile.Id,
                          Badge_number__c='CM101');
        insert user1;
        
        Profile smProfile = new profile();
        for(Profile userProfile:[select Id from Profile where name like '%Contract Senior Manager' Limit 1]){
             smProfile=userprofile;
        }
        user2 = new User(Alias = 'SM101',
              LastName = 'testCM101',
              Email = 'x.y@ust-global.com',
              Username = 'x1.1y@z1.com',
              CommunityNickname = 'testSM101',
              EmailEncodingKey = 'ISO-8859-1',
              TimeZoneSIdKey = 'America/Panama',
              LocaleSIdKey = 'en_US',
              LanguageLocaleKey = 'en_US',
              ProfileId = smProfile.Id,
              Badge_number__c = 'SM101');
        insert user2;
         
        Integer countConEmail= [select count() from Contract_Manager_Email__c where Business_unit1__c='Consumer Retail' AND Region__c='EMEA' AND Sub_Region1__c='Western Europe'];
         
        if(countConEmail > 0) {
            conEmail = [select Senior_Manager__c, Senior_Manager__r.Email from Contract_Manager_Email__c where Business_unit1__c='Consumer Retail' AND Region__c='EMEA' AND Sub_Region1__c='Western Europe' limit 1];
            expectedSupportOwner = conEmail.Senior_Manager__c;
            expectedEmail = conEmail.Senior_Manager__r.Email;      
        }
        else {
            conEmail = new Contract_Manager_Email__c(Business_unit1__c='Consumer Retail',
            Region__c = 'EMEA',
            Sub_Region1__c = 'Western Europe',
            Senior_Manager__c = user2.Id);
             
            insert conEmail;
            expectedSupportOwner = user2.Id;
            expectedEmail = user2.email;
        }
    }
    
    static testMethod voId myUnitTestForBeforeInsertUpdate() {
        createData();
        
        Test.startTest();
        //Id srRecordTypeId = IdLookupUtils.getRecordTypeId('Request CSMB Contract Support', 'Support_Request__c', true);
        Id srRecordTypeId = IdLookupUtils.getRecordTypeId('Request Contracts Support', 'Support_Request__c', true);
        supportReq = new Support_Request__c(Opportunity__c = opportunity.Id,
                            CSMB_Contract_Request_Type__c = 'New Contract',
                            Region__c = 'EMEA',
                            Sub_Region__c = 'Western Europe',
                            Business_unit1__c = 'Consumer Retail',
                            Contact_Name__c = cont.Id,
                            Support_Status__c = 'Pending',
                            RecordTypeId = srRecordTypeId,
                            Status__c = 'New',  // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValIdation
                            Segment_Business_Unit__c = 'PLE');
        insert supportReq;

        Support_Request__c suppReqAftrInsrt = [select Name, Support_Owner__c, WF_Email_for_CSMB__c from Support_Request__c where Id = :supportReq.Id];
        System.assertEquals(suppReqAftrInsrt.Support_Owner__c, expectedSupportOwner);
        System.assertEquals(suppReqAftrInsrt.WF_Email_for_CSMB__c, expectedEmail);
        Test.stoptest();
    }
    
}