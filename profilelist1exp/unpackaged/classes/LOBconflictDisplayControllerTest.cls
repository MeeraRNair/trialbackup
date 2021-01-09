/* 10 -12-2018         Haribabu.A     STORY 5907651 Removed reference for the field direct_account_name__c */
/*
REVISION HISTORY
================
Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           25-10-2019          Implimented TestDataFactory        
*/
@isTest(SeeAllData=false)
private class LOBconflictDisplayControllerTest{
    public static list<Account> listAcc;
    public static list<Opportunity> listOpp;
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);                                                 
        list<Account> listAccTDF=TestDataFactory.createNAccount(2,'End-User Account');
        listAccTDF[0].RecordtypeId=TestDataFactory.getRecordTypeIdbyName('Partner Account', 'Account');
        listAccTDF[0].Participating_in_LOB_Program__c=false;
        listAccTDF[0].Is_GTM_Partner__c=true;
        insert listAccTDF;
        list<Opportunity> listOppTDF=TestDataFactory.createNOpportunities(1, 'Deal Registration-Submitted');
        insert listOppTDF;
    }
    static testMethod void lOBConflictTestError(){
        test.starttest();
        listAcc=[select id from Account];
        List<LOB_Registration__c > listlobRecords = createLOBs(listAcc[1],listAcc[0]);
        test.stoptest();
        ApexPages.StandardController stdCon =new ApexPages.StandardController(listlobRecords[0]);     
        Test.setCurrentPageReference(new PageReference('Page.LOBconflictDisplay')); 
        LOBconflictDisplayController con =new LOBconflictDisplayController(stdCon);
        ApexPages.Message[] listpageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, listpageMessages.size());
    }
    static testMethod void lOBConflictTestNoAccount(){
        
        test.starttest();
        listAcc=[select id from Account];
        
        List<LOB_Registration__c > listlobRecords = createLOBs(listAcc[1],listAcc[0]);
        test.stoptest();
        System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;
        listOpp=[select id from Opportunity Limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        ApexPages.StandardController stdCon =new ApexPages.StandardController(listlobRecords[0]);     
        Test.setCurrentPageReference(new PageReference('Page.LOBconflictDisplay')); 
        System.currentPageReference().getParameters().put('oppId', listOpp[0].Id);
        LOBconflictDisplayController con =new LOBconflictDisplayController(stdCon);
    }
    static testMethod void lOBConflictTestProducts(){
        System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;
        Test.StartTest();
        listAcc=[select id from Account];
        
        List<LOB_Registration__c > listlobRecords = createLOBs(listAcc[1],listAcc[0]);
        Test.StopTest();
        listOpp=[select id from Opportunity limit 1];
        listOpp[0].AccountId=listAcc[1].id;
        TriggerExecutionController.setSkipAllTriggers(true); 
        update listOpp;
        List<OpportunityLineItem> listoli = TestDataFactory.createNOpportunityLineItem(1);
        listoli[0].OpportunityId=listOpp[0].id;
        insert listoli;
        
        system.debug('***$$$'+listoli); 
        system.debug('***$$$'+listlobRecords);  
        ApexPages.StandardController stdCon =new ApexPages.StandardController(listlobRecords[0]);     
        Test.setCurrentPageReference(new PageReference('Page.LOBconflictDisplay')); 
        System.currentPageReference().getParameters().put('oppId', listOpp[0].Id);
        LOBconflictDisplayController con =new LOBconflictDisplayController(stdCon);
        con.getConflictList();
        Integer intpageCheck = con.pageNumber;
        system.assertEquals(intpageCheck,1);
        Boolean bintNextCheck = con.hasNext;
        con.next();
        Boolean bPreviousCheck = con.hasPrevious;      
        con.previous();
        con.first();
        con.last();
        
    }
    
    private static List<LOB_Registration__c > createLOBs(Account eUacc,Account partnerAcc){
        
        List<LOB_Registration__c> listlobReg = new List<LOB_Registration__c>();
        List<String> listlobName = new List<String> {'Client','Server','Storage','Networking','Security – Network Security (SonicWall)'};
            
            for(Integer intj=0;intj < listlobName.size();intj++){
                LOB_Registration__c lobRegPartnerRecord = new LOB_Registration__c ();
                lobRegPartnerRecord.LOB_Name__c =listlobName[intj];             
                lobRegPartnerRecord.Registered_End_User__c= eUacc.Id;
                lobRegPartnerRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
                lobRegPartnerRecord.LOB_registration_status__c = 'Partner(approved)';
                lobRegPartnerRecord.LOB_Award_Type__c = 'Account';
                lobRegPartnerRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;        
                listlobReg.add(lobRegPartnerRecord);
                
                LOB_Registration__c lobRegPartnerRecord1 = new LOB_Registration__c ();
                lobRegPartnerRecord1.LOB_Name__c =listlobName[intj];             
                lobRegPartnerRecord1.Registered_End_User__c= eUacc.Id;
                lobRegPartnerRecord1.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
                lobRegPartnerRecord1.LOB_registration_status__c = 'Partner(approved)';
                lobRegPartnerRecord1.LOB_Award_Type__c = 'Account';
                lobRegPartnerRecord1.Preferred_GTM_Partner_Account__c = partnerAcc.Id;          
                listlobReg.add(lobRegPartnerRecord1);
                
                LOB_Registration__c lobRegDellRecord = new LOB_Registration__c ();
                lobRegDellRecord.LOB_Name__c =listlobName[intj];             
                lobRegDellRecord.Registered_End_User__c= eUacc.Id;
                lobRegDellRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
                lobRegDellRecord.LOB_registration_status__c = 'Dell(Approved)';
                lobRegDellRecord.LOB_Award_Type__c = 'Account';
                lobRegDellRecord.Preferred_GTM_Partner_Account__c  = partnerAcc.Id;          
                
                listlobReg.add(lobRegDellRecord);           
            }
        
        insert listlobReg;
        
        return listlobReg; 
    }
}