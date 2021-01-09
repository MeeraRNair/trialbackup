@isTest(seeAlldata=True)
public class AccountCertificationTrackerTest{

     private static testMethod void TestMethodOne() {
      
      Id partnerRTId = System.Label.RecType_Partner_Account; 
      
     Map<ID, Account> mapNewAccounts = new Map<ID, Account>([SELECT Id,
                                                                 Name,
                                                                 Partner_Relationship__c,
                                                                 RecordTypeId,
                                                                 IsPartner,
                                                                 Account_Country_Code__c  FROM Account
                                                                 where IsPartner=true and ( Partner_Relationship__c ='Preferred' OR Partner_Relationship__c ='Premier' )
                                                                 And RecordTypeId =: partnerRTId and Account_Country__c in ('CHINA','HONG KONG','TAIWAN','MACAU') LIMIT 6 ]);
                                                                 
    Map<ID, Account> mapOldAccounts = new Map<ID, Account>();
    
    for(id eachId : mapNewAccounts.keyset()){
    Account a = new Account();
    a.name = mapNewAccounts.get(eachId).name;
    a.Partner_Relationship__c = 'test';
    //a.IsPartner = true;
    
    mapOldAccounts.put(eachId,a);
    
    }
    
  
    
                                                                 
           AccountCertificationTracker.updateCertificationTrackerDetails(mapNewAccounts  ,mapNewAccounts  ,mapOldAccounts );                                                      
                                                                 
   
           AccountCertificationTracker.checkAndCreateCertificationTrackers(mapNewAccounts.keySet());
           AccountCertificationTracker.createCertificationTrackers(mapNewAccounts.keySet());
           
    }  
    
    

     private static testMethod void TestMethodTwo() {
      
      Id partnerRTId = System.Label.RecType_Partner_Account; 
      
     Map<ID, Account> mapNewAccounts = new Map<ID, Account>([SELECT Id,
                                                                 Name,
                                                                 Partner_Relationship__c,
                                                                 RecordTypeId,
                                                                 IsPartner,
                                                                 Account_Country_Code__c  FROM Account
                                                                 where IsPartner=true and ( Partner_Relationship__c ='Preferred' OR Partner_Relationship__c ='Premier' )
                                                                 And RecordTypeId =: partnerRTId  LIMIT 6 ]);
                                                                 
    Map<ID, Account> mapOldAccounts = new Map<ID, Account>();
    
    for(id eachId : mapNewAccounts.keyset()){
    Account a = new Account();
    a.name = mapNewAccounts.get(eachId).name;
    a.Partner_Relationship__c = 'test';
    //a.IsPartner = true;
    
    mapOldAccounts.put(eachId,a);
    
    }
    
  
    
                                                                 
           AccountCertificationTracker.updateCertificationTrackerDetails(mapNewAccounts  ,mapNewAccounts  ,mapOldAccounts );                                                      
                                                                 
   
           AccountCertificationTracker.checkAndCreateCertificationTrackers(mapNewAccounts.keySet());
           AccountCertificationTracker.createCertificationTrackers(mapNewAccounts.keySet());
           
    }      
    
    public static testmethod void testEvaluation(){             
        Account acc = new Account();
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
                    
        PageReference pageRef = Page.Certification_Evaluation;      
        pageRef.getParameters().put('acid',acc.id);
        Test.setCurrentPageReference(pageRef);  
        
        ApexPages.StandardController sc = new ApexPages.StandardController(certTracker);
        VFCntrlr_Certification_Evaluation certEval2 = new VFCntrlr_Certification_Evaluation();
        certEval2.getAccounts();
        certEval2.evaluate();
        certEval2.next();
        certEval2.previous();
        certEval2.getHasPreviousAndNext();
        certEval2.cancel();
        certEval2.result = true;
        certEval2.ShowMessage();
        certEval2.result = false;
        certEval2.ShowMessage();
              
        pageRef.getParameters().put('acid',null);
        pageRef.getParameters().put('Region','US');
        Test.setCurrentPageReference(pageRef);  
        
        ApexPages.StandardController sc4 = new ApexPages.StandardController(certTracker);
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
        certEval.Selected_Accts_lst.add(acc.id);
        certEval.AcctId_NameMap.put(acc.id, acc.name);
        certEval.Evaluation_Failed_Accts.add(acc.id);
        certEval.Evaluation_Batch_Accts.add(acc.id);
        certEval.Evaluate_EachAccount();
        certEval.ShowMessage();
    }
    
    public static testmethod void testEvaluation1(){             
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c = 'CA';
        acc.Partner_Relationship__c = 'Registered';      
        insert acc;
        
        Certification_Tracker__c certTracker = new Certification_Tracker__c();  
        certTracker.Evaluate_Criteria__c= true;
        certTracker.Account_name__c = acc.id;       
        insert certTracker;
        
        PageReference pageRef = Page.Certification_Evaluation;      
        pageRef.getParameters().put('acid',null);
        pageRef.getParameters().put('Region','Canada');
        Test.setCurrentPageReference(pageRef);  
        
        ApexPages.StandardController sc4 = new ApexPages.StandardController(certTracker);
        VFCntrlr_Certification_Evaluation certEval = new VFCntrlr_Certification_Evaluation();  
                
        certEval.getAccounts();      
        certEval.cancel();
        
    }
    
    /* public static testmethod void testEvaluation2(){  
        Country__c country34 = new Country__c();    
        country34.Region__c = 'LA';
        country34.Code__c = 'BR';  
        country34.name = 'Brazil';  
        country34.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        insert(country34);
                   
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='IN';
        acc.Partner_Relationship__c='Registered';      
        insert acc;
        
        Certification_Tracker__c certTracker = new Certification_Tracker__c();  
        certTracker.Evaluate_Criteria__c= true;
        certTracker.Account_name__c = acc.id;       
        insert certTracker;
        
        PageReference pageRef = Page.Certification_Evaluation;      
        pageRef.getParameters().put('acid',null);
        pageRef.getParameters().put('Region','APJ');
        Test.setCurrentPageReference(pageRef);  
        
        ApexPages.StandardController sc4 = new ApexPages.StandardController(certTracker);
        VFCntrlr_Certification_Evaluation certEval = new VFCntrlr_Certification_Evaluation();  
                
        certEval.getAccounts();      
        certEval.cancel();
    }*/
                                                           



}