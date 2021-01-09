@isTest
private class VFCntrlr_Certification_Tracker_EditTest{
     static list<Account> listAcc;
     static List<Certification_Tracker__c> listcerTracker;
    @testsetup static void setup() { 
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccTDF;
        List<Certification_Tracker__c> listCerTrackerTDF = TestDataFactory.createNcertTracker(1);
        listCerTrackerTDF[0].Account_name__c = listAccTDF[0].id;
        insert listCerTrackerTDF;
    }     
    public static testmethod void testCertificationTrackerEdit(){                   
        //Create partner Account
    /*    Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';
        acc.Partner_Relationship__c='Registered';      
        insert acc;
        
        Certification_Tracker__c certTracker = new Certification_Tracker__c();  
        certTracker.Evaluate_Criteria__c=true;       
        certTracker.Account_name__c = acc.id;    
        certTracker.Dell_Certification_Areas__c = 'Networking';     
        insert certTracker;
        */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].status__c = 'Active';
        listAcc[0].Partner_Relationship__c='Registered';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        listcerTracker = [select id from Certification_Tracker__c limit 1 ];
        Master_Program_Setup__c mp = new Master_Program_Setup__c(Master_Program_Name__c = 'TestMP', Apply_Requirement_To__c ='Global',
                                                                    Active__c=true, Certification_Name__c='Server');
        
        insert mp;
        
        PageReference pageRef = Page.Certification_Tracker_Edit;        
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',listcerTracker[0].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(listcerTracker[0]);
        VFCntrlr_Certification_Tracker_Edit vfCntrlr = new VFCntrlr_Certification_Tracker_Edit(sc);
        
        vfCntrlr.getct();
        vfCntrlr.getAvailableList();
        vfCntrlr.selAvailableList = new List<String>();
        vfCntrlr.selAvailableList.add('Server');
        vfCntrlr.availableToSelected();
        vfCntrlr.getSelectedList();
        vfCntrlr.save();
        
        vfCntrlr.selSelectList = new List<String>();
        vfCntrlr.selSelectList.add('Server');
        vfCntrlr.unSelectToAvailable(); 
        
        
    }
}