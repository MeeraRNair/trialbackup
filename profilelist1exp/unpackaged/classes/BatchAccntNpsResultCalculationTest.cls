/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@isTest
private class BatchAccntNpsResultCalculationTest
{
    public static String strCRONEXP = '0 0 0 15 3 ? 2022';
    static list<Account> listAcc;
    static list<Contact> listCon;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-User Account');
        insert listAccTDF;
        list<Contact> listConTDF = TestDataFactory.CreateNContacts(2);
        insert listConTDF;
    }
    
    public static void createdata(){
/*        Account ac = new Account();
        ac.name = 'TestAccount';
        ac.Focus_Account__c = 'Direct Account Plan';
        insert ac; */
        listAcc = [select id from Account limit 1];
        listAcc[0].Focus_Account__c = 'Direct Account Plan';
        update listAcc;
        listCon = [select id, AccountID,Email from Contact limit 2];
        listCon[0].AccountId = listacc[0].Id;
        listCon[0].Email = 'test@gmail.com';
        listCon[1].AccountId = listacc[0].Id;
        listCon[1].Email = 'test1@gmail.com';
        update listCon;
/*        
        contact c = new contact();
        c.FirstName = 'Firstcontact';
        c.LastName = 'Lastcontact';
        c.AccountId = ac.Id;
        c.Email = 'test@gmail.com';
        insert c;
        
        contact c1 = new contact();
        c1.FirstName = 'Firstcontact1';
        c1.LastName = 'Lastcontact2';
        c1.AccountId = ac.Id;
        c1.Email = 'test1@gmail.com';
        insert c1;
        */
        NPS_Data__c nps = new NPS_Data__c();
        nps.name = 'Test NPS';
        nps.Contact__c = listCon[0].Id;
        nps.Survey_Date__c = system.today();
        nps.NPS_Score__c = 10;
        nps.Account__c = listAcc[0].id;
        insert nps;
        
        list<Date_Range__c> listDR = new list<Date_Range__c>();
        Date_Range__c drp = new Date_Range__c();
        drp.name = 'Previous_NPS_Data_Date_Range';
        drp.End_Date__c = Date.newInstance(2015, 7, 31);
        drp.Start_Date__c = Date.newInstance(2015, 2, 3);
        listDR.add(drp);
        
        Date_Range__c drc = new Date_Range__c();
        drc.name = 'Current_NPS_Data_Date_Range';
        drc.End_Date__c = Date.newInstance(2016, 1, 30);
        drc.Start_Date__c = Date.newInstance(2015, 8, 1);
        listDR.add(drc);
        
        insert listDR;
        
    }
    
    static testMethod void accNPStest()
    { 
        //skip all triggers on creation of account and opportunity
        TriggerExecutionController.setSkipAllTriggers(true);
        createdata();
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ]; 
        
        System.runAs (thisUser)
        {
            test.starttest();      
            
            String strjobId = System.schedule('ScheduleApexClassTest',strCRONEXP, new BatchAccntNpsResultCalculationScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :strjobId];
            System.assertEquals(strCRONEXP, ct.CronExpression);
            
            test.stoptest();
            
        }
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
}