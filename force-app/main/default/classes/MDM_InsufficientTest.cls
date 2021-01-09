@isTest(SeeAllData=true)
private class MDM_InsufficientTest
{
static testmethod void myTest()
    {
       Profile SSIprofile = [select id from profile where name like '%GBL Sales Rep - Non SSO%' Limit 1];
       User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = SSIprofile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        
        insert testUser;
        string output;
        string oAddress1;
        string dunsnumber;
        string affiid;
        string accid;
       // List<dunsDataWrapper> allDunsData = new list<dunsDataWrapper>();
        
        
        Account testAcc = new Account(name='testaccount',D_U_N_S__c='1234',Global_D_U_N_S__c='1234',account_id__c='1234');
        insert testAcc;
        PageReference p = Page.MDM_DBAccountDetailsPage;
        Test.setcurrentpage(p);
        apexpages.currentpage().getparameters().put('dunsnumber',testAcc.D_U_N_S__c);
        dunsnumber = apexpages.currentpage().getparameters().get('dunsnumber');
        apexpages.currentpage().getparameters().put('affinityid',testAcc.account_id__c);
        affiid = apexpages.currentpage().getparameters().get('affinityid');
        apexpages.currentpage().getparameters().put('id',testAcc.id);
        accid = apexpages.currentpage().getparameters().get('id');
        apexpages.currentpage().getparameters().put('owner',testAcc.owner.name);
        string accowner = apexpages.currentpage().getparameters().get('owner');
        apexpages.currentpage().getparameters().put('owneremail',testAcc.owner.email);
        string owneremail = apexpages.currentpage().getparameters().get('owneremail');
        
        system.Test.startTest();
        mdm_insufficientaccesscntrlr inst = new mdm_insufficientaccesscntrlr();
        
        system.Test.stopTest();
     }
    }