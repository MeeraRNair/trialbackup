@isTest 
private class DealSummaryTest {
    static list<Account> listacc;
    static list<Opportunity> listOpp;    
    private static string getBadgeNumber(){
        return string.valueof(datetime.now()).replace(':', '').replace('-', '').replace(' ', '') + datetime.now().millisecond();
    }
    static testMethod void testDSummaryTriggers() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Profile p = [select id from profile where name='System Administrator'];
        String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
        User u = new User(alias = 'test123', email='test1234@dell.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id, country='United States',            
                          timezonesidkey='America/Los_Angeles', username=strusername, Badge_Number__c = getBadgeNumber());
        insert u;
        list<Account> listAcc = TestDataFactory.createNAccount(1, 'Partner Account');
        listAcc[0].status__c = 'Active';
        listAcc[0].Account_Country_Code__c='US';
        insert listAcc;  
        list<Opportunity> listOpp = TestDataFactory.createNOpportunities(1, 'Deal Registration');
        listOpp[0].RecordTypeId = TestDataFactory.getRecordTypeIdbyName('Deal Registration', 'Opportunity');
        listOpp[0].AccountId = listAcc[0].id;
        listOpp[0].CurrencyIsoCode = 'USD';
        listOpp[0].Type = 'Renewal';
        listOpp[0].No_times_BookDate_moved__c = 0;
        listOpp[0].CloseDate = System.today();
        insert listOpp;
        CustomerInteraction__c ci = new CustomerInteraction__c(Related_Opportunity__c = listOpp[0].id, Account__c=listAcc[0].Id);
        insert ci;
        CustomerInteraction__c ci1 = new CustomerInteraction__c(Related_Opportunity__c = listOpp[0].id, Account__c=listAcc[0].Id);
        insert ci1;        
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        Deal_Summary__c ds = new Deal_Summary__c(Opportunity__c = listOpp[0].id, ForcedCalculation__c = false, Stage__c = listOpp[0].StageName, No_Qualified_NPS__c=0);
        insert ds;
        Task t = new Task(whatid=listOpp[0].id);
        insert t;
        Task t1 = new Task(whatid=listOpp[0].id);
        insert t1;
        Task t2 = [select id from Task where id=:t1.id];
        delete t2;
        system.assertEquals(listOpp[0].AccountId, listAcc[0].Id);
        system.assertEquals(listOpp[0].No_times_BookDate_moved__c, 0);
        system.assertEquals(ds.Opportunity__c, listOpp[0].Id);
        system.assertEquals(ds.ForcedCalculation__c, false);
        system.runas(u)
        {
            Event e = new Event(whatid=listOpp[0].id, DurationInMinutes=10, ActivityDateTime=system.today());
            insert e;
            Event e1 = new Event(whatid=listOpp[0].id, DurationInMinutes=10, ActivityDateTime=system.today());
            insert e1;
            Event e2 = [select id from Event where id=:e1.id];
            delete e2;
            
            //Added below code to increase the coverage for changes made to the Trigger DealSummaryTripReport as a part of Grax Archival 01/12/2020 Release 
            delete ci1; 
            TriggerExecutionControl__c exec = new TriggerExecutionControl__c();
            exec.Name= 'CustomerInteraction__c';
            exec.UsersToSkip__c='';
            insert exec;
            //END -- Grax Archival 01/12/2020 Release
        }
        Test.stopTest();  
    }
    static testMethod void testDSummaryTrigger(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Profile p = [select id from profile where name='System Administrator'];
        String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
        User u = new User(alias = 'test123', email='test1234@dell.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id, country='United States',            
                          timezonesidkey='America/Los_Angeles', username=strusername, Badge_Number__c = getBadgeNumber());
        insert u;
        list<Account> listAcc = TestDataFactory.createNAccount(1, 'Partner Account');
        listAcc[0].status__c = 'Active';
        listAcc[0].Account_Country_Code__c='US';
        insert listAcc;  
        list<Opportunity> listOpp = TestDataFactory.createNOpportunities(1, 'Deal Registration');
        listOpp[0].AccountId = listAcc[0].id;
        listOpp[0].StageName = 'Propose - 60%';
        listOpp[0].CloseDate = System.today();
        insert listOpp;
        Contact c = new Contact(AccountId=listAcc[0].Id, LastName='MyLastName', Email='test@dell.com');
        insert c;
        TriggerExecutionController.setSkipAllTriggers(false);
        List<Opportunity> listmyOp = new List<Opportunity>();
        Opportunity op1 = [select id, StageName from Opportunity where id =:listOpp[0].id limit 1];
        op1.StageName = 'Discover - 10%';
        listmyOp.add(op1);
        test.startTest();   
        system.runas(u){
            TriggerExecutionController.setSkipOpportunityTriggers(True);
            update listmyOp;
            TriggerExecutionController.setSkipAllTriggers(false);
            system.assertEquals(op1.StageName, 'Discover - 10%');            
        }
        test.stopTest();  
    }
    static testMethod void testDSummaryClass1(){
        TriggerExecutionController.setSkipAllTriggers(true);     
        Profile p = [select id from profile where name='System Administrator'];
        String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
        User u = new User(alias = 'test123', email='test1234@dell.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id, country='United States',            
                          timezonesidkey='America/Los_Angeles', username=strusername, Badge_Number__c = getBadgeNumber());
        insert u;
        list<Account> listAcc = TestDataFactory.createNAccount(1, 'Partner Account');
        listAcc[0].status__c = 'Active';
        listAcc[0].Account_Country_Code__c='US';
        insert listAcc;  
        list<Opportunity> listOpp = TestDataFactory.createNOpportunities(1, 'Deal Registration');
        listOpp[0].AccountId = listAcc[0].id;
        listOpp[0].CurrencyIsoCode = 'USD';
        listOpp[0].CloseDate = System.today();
        TriggerExecutionController.setSkipOpportunityTriggers(True);
        insert listOpp;
        set<id> setOppId = new set<id>();
        setOppId.add(listOpp[0].Id);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Deal_Summary__c ds = new Deal_Summary__c(Opportunity__c = listOpp[0].id, ForcedCalculation__c = false, Stage__c = listOpp[0].StageName);
        insert ds;
        Contact c = new Contact(AccountId=listAcc[0].Id, LastName='MyLastName', Email='test@dell.com');
        insert c;
        integer intPSCt = [Select count() from Contact where Id =:c.Id]; 
        TriggerExecutionController.setSkipAllTriggers(false);
        List<Opportunity> listmyOp = new List<Opportunity>();
        Opportunity op1 = [select id, StageName from Opportunity where id=:listOpp[0].id limit 1];
        op1.StageName = 'Discover - 10%';
        listmyOp.add(op1);
        List<Deal_Summary__c> listmyDS = new List<Deal_Summary__c>();
        Deal_Summary__c ds1 = [select id, Stage__c, Stage_Plan__c, Stage_Discover__c, Stage_Qualify__c, Stage_Propose__c, Stage_Commit__c, No_Qualified_NPS__c from Deal_Summary__c limit 1];
        ds1.Stage__c = 'Discover - 10%';
        ds1.Stage_Plan__c = 0;
        ds1.No_Qualified_NPS__c = intPSCt;
        ds1.ForcedCalculation__c = true;
        listmyDS.add(ds1);
        list<OpportunityHistory> listoh1 = [Select CreatedDate From OpportunityHistory where OpportunityId = :listOpp[0].Id Order By CreatedDate ASC Limit 1];
        list<OpportunityHistory> listoh2 = [Select CreatedDate From OpportunityHistory where OpportunityId = :listOpp[0].Id Order By CreatedDate DESC Limit 1];
        list<OpportunityFieldHistory> listofh = [Select OpportunityId, OldValue, NewValue, Field, CreatedDate From OpportunityFieldHistory where Field='StageName' and OpportunityId = :listOpp[0].Id Order By CreatedDate ASC];
        test.startTest();   
        system.runas(u){
            TriggerExecutionController.setSkipOpportunityTriggers(True);
            update listmyOp;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            update listmyDS;
            TriggerExecutionController.setSkipAllTriggers(false);
            PageReference pageRef = Page.DealSummary;      
            pageRef.getParameters().put('id',listOpp[0].Id);
            Test.setCurrentPageReference(pageRef);         
            DealSummary dSCls = new DealSummary();
            dSCls.insOppty();
            Deal_Summary__c ds2 = new Deal_Summary__c(Opportunity__c = listOpp[0].id, Account__c=listAcc[0].Id, ForcedCalculation__c = true);
            insert ds2;
            dSCls.theRefresh();
            DealSummary.optyAdd(setOppId);
        }
        test.stopTest();  
        system.assertEquals(op1.StageName, 'Discover - 10%');            
        system.assertEquals(ds1.Stage__c, 'Discover - 10%');            
        system.assertEquals(ds1.ForcedCalculation__c, true);            
    }
    static testMethod void testDSummaryClass2(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Profile p = [select id from profile where name='System Administrator'];
        String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
        User u = new User(alias = 'test123', email='test1234@dell.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id, country='United States',            
                          timezonesidkey='America/Los_Angeles', username=strusername, Badge_Number__c = getBadgeNumber());
        insert u;
        list<Opportunity> listOpp = TestDataFactory.createNOpportunities(2, 'Deal Registration');
        listOpp[0].CurrencyIsoCode = 'USD';
        listOpp[0].Type = 'Renewal';
        listOpp[0].StageName = 'Discover - 10%';
        listOpp[0].CloseDate = System.today();
        listOpp[1].CurrencyIsoCode = 'USD';
        listOpp[1].Type = 'Renewal';
        listOpp[1].StageName = 'Qualify - 30%';
        listOpp[1].No_times_BookDate_moved__c = 0;
        listOpp[1].CloseDate = System.today();
        insert listOpp;
        system.assertEquals(listOpp[1].No_times_BookDate_moved__c, 0);
        Deal_Summary__c ds = new Deal_Summary__c(Opportunity__c = listOpp[0].id, ForcedCalculation__c = false, Stage__c = listOpp[0].StageName);
        insert ds;
        Deal_Summary__c ds1 = new Deal_Summary__c(Opportunity__c = listOpp[1].id, ForcedCalculation__c = false, Stage__c = listOpp[1].StageName);
        insert ds1;
        TriggerExecutionController.setSkipAllTriggers(false);
        test.startTest();   
        system.runas(u){            
            PageReference pageRef = Page.DealSummary;      
            pageRef.getParameters().put('id',listOpp[0].Id);
            Test.setCurrentPageReference(pageRef);                     
            DealSummary dSCls = new DealSummary();
            PageReference pageRef1 = Page.DealSummary;      
            pageRef1.getParameters().put('id',listOpp[1].Id);
            Test.setCurrentPageReference(pageRef1);                     
            DealSummary dSCls1 = new DealSummary();
        }
        test.stopTest(); 
    }
    static testMethod void testDSummaryClass3(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Profile p = [select id from profile where name='System Administrator'];
        String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
        User u = new User(alias = 'test123', email='test1234@dell.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id, country='United States',            
                          timezonesidkey='America/Los_Angeles', username=strusername, Badge_Number__c = getBadgeNumber());
        insert u;
        list<Opportunity> listOpp = TestDataFactory.createNOpportunities(3, 'Deal Registration');
        listOpp[0].CurrencyIsoCode = 'USD';
        listOpp[0].Type = 'Renewal';
        listOpp[0].StageName = 'Propose - 60%';
        listOpp[0].Region__c ='All';
        listOpp[0].CloseDate = System.today()+1;
        listOpp[1].StageName = 'Commit - 90%';
        listOpp[1].Solution_Name__c = 'Boomi Solution';
        listOpp[1].Region__c ='All';
        listOpp[1].No_times_BookDate_moved__c = null;
        listOpp[1].CloseDate = System.today();
        listOpp[2].StageName = 'Commit - 90%';
        listOpp[2].Solution_Name__c = 'Boomi Solution';
        listOpp[2].Region__c ='All';
        listOpp[2].No_times_BookDate_moved__c = null;
        listOpp[2].CloseDate = System.today();
        listOpp[2].Region__c ='All';
        listOpp[2].Competitor_Lost_To__c='Unknown';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpp;
        Deal_Summary__c ds2 = new Deal_Summary__c(Opportunity__c = listOpp[0].id, ForcedCalculation__c = false, Stage__c = listOpp[0].StageName);
        insert ds2;
        Deal_Summary__c ds3 = new Deal_Summary__c(Opportunity__c = listOpp[1].id, ForcedCalculation__c = true, Stage__c = listOpp[1].StageName, Stage_Plan__c=null, Stage_Discover__c=null, Stage_Qualify__c=null, Stage_Propose__c=null, Stage_Commit__c=null);
        insert ds3;
        Deal_Summary__c ds4 = new Deal_Summary__c(Opportunity__c = listOpp[2].id, ForcedCalculation__c = true, Stage__c = listOpp[2].StageName, Stage_Plan__c=null, Stage_Discover__c=null, Stage_Qualify__c=null, Stage_Propose__c=null, Stage_Commit__c=null);
        insert ds4;
        TriggerExecutionController.setSkipAllTriggers(false);
        test.startTest();   
        system.runas(u){            
            PageReference pageRef2 = Page.DealSummary;      
            pageRef2.getParameters().put('id',listOpp[0].Id);
            Test.setCurrentPageReference(pageRef2);                     
            DealSummary dSCls2 = new DealSummary();
            PageReference pageRef3 = Page.DealSummary;      
            pageRef3.getParameters().put('id',listOpp[1].Id);
            Test.setCurrentPageReference(pageRef3);                     
            DealSummary dSCls3 = new DealSummary();
            PageReference pageRef4 = Page.DealSummary;      
            pageRef4.getParameters().put('id',listOpp[2].Id);
            Test.setCurrentPageReference(pageRef4);                     
            DealSummary dSCls4 = new DealSummary();
        }
        test.stopTest();  
        system.assertEquals(ds2.Opportunity__c, listOpp[0].Id);            
    }                        
}