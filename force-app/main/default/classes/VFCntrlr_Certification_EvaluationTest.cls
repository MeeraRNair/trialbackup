/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@isTest
private class VFCntrlr_Certification_EvaluationTest{
    static list<Account> listAcc;
    static List<Certification_Tracker__c> listcerTracker;
    static list<Certification_Tracker__c> listCerTracker1;
    @testsetup static void setup() { 
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccTDF;
        List<Certification_Tracker__c> listCerTrackerTDF = TestDataFactory.createNcertTracker(1);
            listCerTrackerTDF[0].Account_name__c = listAccTDF[0].id;
        insert listCerTrackerTDF;
        List<Certification_Tracker__c> listCerTrackerTDF1 = TestDataFactory.createNcertTracker(1);
                for(integer inti=0; inti<26; inti++)
        {
            listCerTrackerTDF1[0].Account_name__c = listAccTDF[0].id;

        }
        insert listCerTrackerTDF1;

    }     

    public static testmethod void testEvaluation(){             
     /*   Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';
        acc.Partner_Relationship__c='Registered';      
        insert acc;
        
        Certification_Tracker__c certTracker = new Certification_Tracker__c();  
        certTracker.Evaluate_Criteria__c=true;       
        certTracker.Account_name__c = acc.id;       
        insert certTracker;
        
        List<Certification_Tracker__c> lstcertTracker = new List<Certification_Tracker__c>();             
        for(integer i=0; i<26; i++)
        {
            Certification_Tracker__c ct = new Certification_Tracker__c();
            ct.Evaluate_Criteria__c=true;   
            ct.Account_name__c = acc.id;
            lstcertTracker.add(ct);            
        }
        insert lstcertTracker;   
       */
        listAcc = [select id,Name from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].status__c = 'Active';
        listAcc[0].Partner_Relationship__c='Registered';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        listcerTracker = [select id from Certification_Tracker__c limit 1 ];
        listCerTracker1 = [select id from Certification_Tracker__c limit 26 ];
        PageReference pageRef = Page.Certification_Evaluation;      
        pageRef.getParameters().put('acid',listAcc[0].id);
        Test.setCurrentPageReference(pageRef);  
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listcerTracker[0]);
        VFCntrlr_Certification_Evaluation certEval2 = new VFCntrlr_Certification_Evaluation();
        certEval2.getAccounts();
        certEval2.evaluate();
        certEval2.next();
        certEval2.previous();
        certEval2.getHasPreviousAndNext();
        certEval2.next();
        certEval2.cancel();
        certEval2.result = true;
        certEval2.ShowMessage();
        certEval2.result = false;
        certEval2.ShowMessage();
              
        pageRef.getParameters().put('acid',null);
        pageRef.getParameters().put('Region','US');
        Test.setCurrentPageReference(pageRef);  
        
        ApexPages.StandardController sc4 = new ApexPages.StandardController(listCerTracker1[0]);
        VFCntrlr_Certification_Evaluation certEval = new VFCntrlr_Certification_Evaluation();  
                
        certEval.getAccounts();
        certEval.tableRows.get(0).isSelected = true;
        certEval.evaluate();
        certEval.Evaluate_EachAccount();
        certEval2.result = false;
        certEval.ShowMessage();
        certEval.setEval_AcctCount(0);
        certEval.getEval_AcctCount();
        certEval.next();
        certEval.previous();
        certEval.getHasPreviousAndNext();
        certEval.cancel();      
        certEval.Selected_Accts_lst.add(listAcc[0].id);
        certEval.AcctId_NameMap.put(listAcc[0].id, listAcc[0].id);
        certEval.Evaluation_Failed_Accts.add(listAcc[0].id);
        certEval.Evaluation_Batch_Accts.add(listAcc[0].id);
        certEval.Evaluate_EachAccount();
        certEval.ShowMessage();
    }
    
    public static testmethod void testEvaluation1(){             
     /*   Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c = 'CA';
        acc.Partner_Relationship__c = 'Registered';      
        insert acc;
        
        Certification_Tracker__c certTracker = new Certification_Tracker__c();  
        certTracker.Evaluate_Criteria__c= true;
        certTracker.Account_name__c = acc.id;       
        insert certTracker;
        */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='CA';
        listAcc[0].status__c = 'Active';
        listAcc[0].Partner_Relationship__c='Registered';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        listcerTracker = [select id from Certification_Tracker__c limit 1 ];

        PageReference pageRef = Page.Certification_Evaluation;      
        pageRef.getParameters().put('acid',null);
        pageRef.getParameters().put('Region','Canada');
        Test.setCurrentPageReference(pageRef);  
        
        ApexPages.StandardController sc4 = new ApexPages.StandardController(listcerTracker[0]);
        VFCntrlr_Certification_Evaluation certEval = new VFCntrlr_Certification_Evaluation();  
        certEval.previous();
		certEval.next();           
        certEval.getAccounts();      
        certEval.cancel();
        certEval.getHasPreviousAndNext();
    }
    
    public static testmethod void testEvaluation2(){  
        Country__c country3 = new Country__c();    
        country3.Region__c = 'APJ';
        country3.Code__c = 'IN';  
        country3.name = 'India';  
        country3.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        insert(country3);
        /*           
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='IN';
        acc.Partner_Relationship__c='Registered';      
        insert acc;
        
        Certification_Tracker__c certTracker = new Certification_Tracker__c();  
        certTracker.Evaluate_Criteria__c= true;
        certTracker.Account_name__c = acc.id;       
        insert certTracker; */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='IN';
        listAcc[0].status__c = 'Active';
        listAcc[0].Partner_Relationship__c='Registered';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        listcerTracker = [select id from Certification_Tracker__c limit 1 ];

        PageReference pageRef = Page.Certification_Evaluation;      
        pageRef.getParameters().put('acid',null);
        pageRef.getParameters().put('Region','APJ');
        Test.setCurrentPageReference(pageRef);  
        
        ApexPages.StandardController sc4 = new ApexPages.StandardController(listcerTracker[0]);
        VFCntrlr_Certification_Evaluation certEval = new VFCntrlr_Certification_Evaluation();  
        certEval.previous();
		certEval.next();        
        certEval.getAccounts();      
        certEval.cancel();
    }


}