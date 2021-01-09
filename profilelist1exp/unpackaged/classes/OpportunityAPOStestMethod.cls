@isTest(SeeAllData=true)
private class OpportunityAPOStestMethod
{
static opportunity newoppty = new opportunity();

static testmethod void myTest()
    {
       Profile SSIprofile = [select id from profile where name like '%SSI Integration Connector API%' Limit 1];
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
        
        system.Test.startTest();
        Account testAcc = new Account(name='testaccount');
        insert testAcc;
        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('APOS','Opportunity',true);
        Opportunity opp=new Opportunity (name='test opp APOS', Accountid=testAcc.id, Type='Deal/Bid - Direct', Domain__c='APOS', CurrencyIsoCode='USD', CloseDate=System.Today(),
            Solution_Type__c='APOS',Solution_Name__c='Other', StageName='House Account', RecordTypeId = oppRecordTypeId, CreatedById='005A00000049FnM', Source_System__c = 'Renew');
        insert opp;
        
        Opportunity opp1=new Opportunity (name='test opp APOS', Accountid=testAcc.id, Type='Deal/Bid - Direct', Domain__c='APOS', CurrencyIsoCode='USD', CloseDate=System.Today(),
            Solution_Type__c='APOS',Solution_Name__c='Other', StageName='Consolidated', RecordTypeId = oppRecordTypeId, CreatedById='005A00000049FnM', Source_System__c = 'Renew');
        insert opp1;
        
        list<opportunity> opptylist = new list<opportunity>();
        opptylist.add(opp);
        opptylist.add(opp1);
        
        OpportunityFieldPopulator.updateRenewedAPOSOpportunities(opptylist);
        system.Test.stopTest();
        system.assertequals(opp.StageName,'Lost, Cancelled - 0%');
        system.assertequals(opp.Probability,0);
        system.assertequals(opp.Reason_Won_Lost__c, 'Service /Support/Delivery Capabilities');
        system.assertequals(opp.Service_Solution_Reason__c,'No feedback');
     }
    }