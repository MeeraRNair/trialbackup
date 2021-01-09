/***********************************************************
* Revision       Release                   Name           Date                  Description   
* 1.0			 0202					   Vikas KH		  08-Dec-2019			Impelemented TDF
***************************************************************/
@isTest
private class VFCntrlr_Certification_TrackerTest{
    static list<Account> listAcc;
    @testsetup static void setup() { 
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccTDF;
    }     
    public static testmethod void testTracking(){
       /* Country__c country1 = new Country__c();
        country1.Region__c = 'US';
        country1.Code__c = 'US';  
        country1.name = 'United States'; 
        insert(country1);
        */
        Certification_Process_Setup__c certProcess1 = new Certification_Process_Setup__c();
        certProcess1.Allow_Automation_Level__c = 'Registered to Preferred';
        certProcess1.Certification_Admin_mailbox__c = 'xyz@ust-global.com';
        certProcess1.Automate_Certification__c = true;
        certProcess1.Region__c = 'US';
        insert certProcess1;
    /*         
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';
        acc.Partner_Relationship__c='Registered';      
        insert acc; */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].status__c = 'Active';
        listAcc[0].Partner_Relationship__c='Registered';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        Certification_Tracker__c certTracker = new Certification_Tracker__c();  
        certTracker.Demo_Unit_Criteria_Met__c = true;
        certTracker.Training_Criteria_Met__c = true;
        certTracker.Last_Evaluation_date__c = System.today();
        certTracker.Account_name__c = listAcc[0].id;
        insert certTracker;
        PageReference pageRef = Page.Certification_Tracker;
        pageRef.getParameters().put('acid',listAcc[0].id);
        Test.setCurrentPageReference(pageRef);  
        ApexPages.StandardController sc = new ApexPages.StandardController(certTracker);
        VFCntrlr_Certification_Tracker vfcertTracker = new VFCntrlr_Certification_Tracker(sc);   
        vfcertTracker.getCTracker();
        vfcertTracker.getHasPreviousAndNext();
        vfcertTracker.next();
        vfcertTracker.previous();
        vfcertTracker.saveTracker();
        vfcertTracker.cancel();
        pageRef.getParameters().put('acid',null);
        pageRef.getParameters().put('Region','US');
        Test.setCurrentPageReference(pageRef);  
        ApexPages.StandardController sc4 = new ApexPages.StandardController(certTracker);
        VFCntrlr_Certification_Tracker vfcertTracker4 = new VFCntrlr_Certification_Tracker(sc4);   
        vfcertTracker4.getCTracker();
        vfcertTracker4.cancel(); 
    }
     public static testmethod void testTracking2(){
       /* Country__c country2 = new Country__c();        
        country2.Region__c = 'Canada';
        country2.Code__c = 'CA';  
        country2.name = 'Canada';      
        insert country2;
        */
        Certification_Process_Setup__c certProcess2 = new Certification_Process_Setup__c();
        certProcess2.Allow_Automation_Level__c = 'Registered to Preferred;Registered To Premier';
        certProcess2.Certification_Admin_mailbox__c = 'xyz@ust-global.com';
        certProcess2.Automate_Certification__c = true;
        certProcess2.Region__c = 'Canada';
        insert certProcess2;
    /*    Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='CA';
        acc.Partner_Relationship__c='Registered';      
        insert acc; */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='CA';
        listAcc[0].status__c = 'Active';
        listAcc[0].Partner_Relationship__c='Registered';
        update listAcc;
         system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        Certification_Tracker__c certTracker = new Certification_Tracker__c();  
        certTracker.Demo_Unit_Criteria_Met__c = true;
        certTracker.Training_Criteria_Met__c = true;
        certTracker.Last_Evaluation_date__c = System.today();
        certTracker.Account_name__c = listAcc[0].id;       
        insert certTracker;
        PageReference pageRef = Page.Certification_Tracker;        
        pageRef.getParameters().put('acid',listAcc[0].id);
        Test.setCurrentPageReference(pageRef);  
        ApexPages.StandardController sc3 = new ApexPages.StandardController(certTracker);
        VFCntrlr_Certification_Tracker vfcertTracker3 = new VFCntrlr_Certification_Tracker(sc3);  
        vfcertTracker3.cancel();    
        pageRef.getParameters().put('acid',null);
        pageRef.getParameters().put('Region','Canada');
        Test.setCurrentPageReference(pageRef);  
        ApexPages.StandardController sc4 = new ApexPages.StandardController(certTracker);
        VFCntrlr_Certification_Tracker vfcertTracker4 = new VFCntrlr_Certification_Tracker(sc4);          
        vfcertTracker4.getCTracker();
        vfcertTracker4.cancel(); 
    }
    public static testmethod void testTracking1(){
        Country__c country3 = new Country__c();    
        country3.Region__c = 'APJ';
        country3.Code__c = 'IN';  
        country3.name = 'India';  
        country3.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        insert(country3);
        Certification_Process_Setup__c certProcess3 = new Certification_Process_Setup__c();
        certProcess3.Allow_Automation_Level__c = 'Registered to Preferred;Registered To Premier;Preferred To Premier';
        certProcess3.Certification_Admin_mailbox__c = 'xyz@ust-global.com';
        certProcess3.Automate_Certification__c = true;
        certProcess3.Region__c = 'APJ';      
        insert certProcess3;
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='IN';
        listAcc[0].status__c = 'Active';
        listAcc[0].Partner_Relationship__c='Registered';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
     /*   Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='IN';
        acc.Partner_Relationship__c='Registered';      
        insert acc; */
        Certification_Tracker__c certTracker = new Certification_Tracker__c();  
        certTracker.Demo_Unit_Criteria_Met__c = true;
        certTracker.Training_Criteria_Met__c = true;
        certTracker.Last_Evaluation_date__c = System.today();
        certTracker.Account_name__c = listAcc[0].id;
        insert certTracker;
        List<Certification_Tracker__c> listcertTracker = new List<Certification_Tracker__c>();             
        for(integer inti=0; inti<26; inti++)
        {
            Certification_Tracker__c ct = new Certification_Tracker__c();
            ct.Demo_Unit_Criteria_Met__c = true;
            ct.Training_Criteria_Met__c = true;
            ct.Last_Evaluation_date__c = System.today();
            ct.Account_name__c = listAcc[0].id;
            listcertTracker.add(ct);            
        }
        insert listcertTracker;   
        PageReference pageRef = Page.Certification_Tracker;        
        pageRef.getParameters().put('acid',listAcc[0].id);
        Test.setCurrentPageReference(pageRef);  
        ApexPages.StandardController sc3 = new ApexPages.StandardController(certTracker);
        VFCntrlr_Certification_Tracker vfcertTracker3 = new VFCntrlr_Certification_Tracker(sc3);  
        vfcertTracker3.cancel();    
        pageRef.getParameters().put('acid',null);
        pageRef.getParameters().put('Region','APJ');
        Test.setCurrentPageReference(pageRef);  
        ApexPages.StandardController sc4 = new ApexPages.StandardController(certTracker);
        VFCntrlr_Certification_Tracker vfcertTracker = new VFCntrlr_Certification_Tracker(sc4);   
        vfcertTracker.getCTracker();
        vfcertTracker.getHasPreviousAndNext();
        vfcertTracker.next();
        vfcertTracker.previous();
        vfcertTracker.saveTracker();
        vfcertTracker.cancel(); 
    }
}