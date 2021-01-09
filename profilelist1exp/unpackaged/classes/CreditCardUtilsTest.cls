/***********************************************************
* Revision   Name        Date           Description
* 1.0        Nooryati    06-03-2011     Test Class for CR 5886   
* 2.0        Devika      23-02-2015     Test Class for CR 10582
************************************************************/

@isTest(seealldata =false)
private class CreditCardUtilsTest {
    
     static testMethod void testGetters() {
        
        Note testNote, testNote2;
        testNote = new Note (Body = 'Amex Credit Card No: 378734493671000');
        testNote2 = new Note (Body = 'Phone Number: 0194638118, Shipping Address: Dell Global Business Center, 2900 Persiaran Apec, 36000 Cyberjaya.');
                
        Test.startTest();
        System.assertEquals(true, CreditCardUtils.getCreditCardValidation(testNote.Body));
        System.assertEquals(false, CreditCardUtils.getCreditCardValidation(testNote2.Body));
        Test.stopTest();
        
    }
    
   
    static testMethod void testIsValidCreditNum() {

        System.assert(CreditCardUtils.isValidCreditNum('5454545454545454'));
        System.assert(CreditCardUtils.isValidCreditNum('8763'));
        System.assert(!CreditCardUtils.isValidCreditNum('1111'));
    }
    
     static testMethod void testInsertNotewithCreditCardNo() {
        
        Note testNote = new Note (Body = 'Amex Credit Card No: 378734493671000');
        
       // testNote = new Note (Body = 'Phone Number: 0194638118, Shipping Address: Dell Global Business Center, 2900 Persiaran Apec, 36000 Cyberjaya.');
                
        Test.startTest();
        try{
            insert testNote;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Failed credit card validation on Note');            
        }
        Test.stopTest();
        
    }
    
    static testMethod void testGoGetters() {
        
        Note testNote, testNote2;
        testNote = new Note (Body = 'Amex Credit Card No: 378734493671000');
        testNote2 = new Note (Body = 'Phone Number: 0194638118, Shipping Address: Dell Global Business Center, 2900 Persiaran Apec, 36000 Cyberjaya.');
                
        Test.startTest();
        System.assertEquals(true, CreditCardUtils.getCreditCardValid(testNote.Body));
        System.assertEquals(false, CreditCardUtils.getCreditCardValid(testNote2.Body));
        Test.stopTest();
        
    }
    
    static testMethod void testInsertUpdateAccountwithCreditCardNo() {
         
        List<Account> accList = new List<Account>(); 
        Id endUserAccount  = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'GBL_Standard_RT' LIMIT 1].Id;      
        
        /****************Test Insert********************/
        Account acc1 =  new Account (name='Test132132',Account_Country__c='Bikini Bottom',type='Partner',
                            Participating_in_LOB_Program__c = true, RecordTypeId = endUserAccount,Description ='Amex Credit Card No: 378734493671000');
        accList.add(acc1);
        Account acc2 =  new Account (name='Test1242414',Account_Country__c='Bikini Bottom',type='Partner',
                            Participating_in_LOB_Program__c = true, RecordTypeId = endUserAccount,Description ='testnormaldata');        
        accList.add(acc2);        
                                      
          try{
            insert accList;
          }
          catch(DmlException e){
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Suspected financial information detected.');            
          } 
          

        /****************Test Update********************/
       
        Account acc3 =  new Account (name='Test1242414',Account_Country__c='Bikini Bottom',type='Partner',
                            Participating_in_LOB_Program__c = true, RecordTypeId = endUserAccount,Description ='testnormaldata'); 
        try{                         
        insert acc3; 
          }
          catch(exception e){}
        
          acc3.Description = 'Amex Credit Card No: 378734493671000';         
          try{
            update acc3;
          }
          catch(DmlException e){
            //System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Suspected financial information detected.');            
          }
        
        
    }
    
    static testMethod void testInsertUpdateContactwithCreditCardNo() {
         
        Id endUserAccount  = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'GBL_Standard_RT' LIMIT 1].Id;       
        
        /****************Test Insert********************/        
        Account acc1 =  new Account (name='Test132132',Account_Country__c='Bikini Bottom',type='Partner',
                            Participating_in_LOB_Program__c = true, RecordTypeId = endUserAccount,Description ='testData');        
        try{
        insert acc1;
        }
          catch(exception e){}
                  
        Contact con1 = new Contact(FirstName = 'test12132141',LastName='lastname12324',AccountId = acc1.Id,email='test@test.com',
                                   Recommend_Comment__c ='Amex Credit Card No: 378734493671000');
       
                             
          try{
              insert con1;
          }
          catch(DmlException e){
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Suspected financial information detected.');            
          }
         
        Contact con2 = new Contact(FirstName = 'test12132141',LastName='lastname12324',AccountId = acc1.Id,email='test@test.com',
             
                                 Recommend_Comment__c ='testPlaindata');      
        
        try{
        insert con2;      
        }
        catch(exception e){}
        /****************Test Update********************/        
        con2.Recommend_Comment__c = 'Amex Credit Card No: 378734493671000';         
          try{
            update con2;
          }
          catch(DmlException e){
            //System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Suspected financial information detected.');            
          }
        
    }
    
    static testMethod void testInsertUpdateopportunitywithCreditCardNo() {
         
     
        Id endUserAccount  = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'GBL_Standard_RT' LIMIT 1].Id;       
       
        
        /****************Test Insert********************/                        
        Account acc =  new Account (name='Test132132',Account_Country__c='Bikini Bottom',type='Partner',
                            Participating_in_LOB_Program__c = true, RecordTypeId = endUserAccount,Description ='testData');        
        try{
        insert acc;        
        
         }
          catch(exception e){}
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity testOpp1= new Opportunity(Name = 'Test oppty1', 
                                AccountId = acc.Id, 
                                Probability = 10,
                                Amount = 1000,
                                StageName='Discover - 10%',
                                CloseDate = Date.TODAY()); 
       oppList.add(testOpp1); 
       Opportunity testOpp2= new Opportunity(Name = 'Test oppty2', 
                                AccountId = acc.Id, 
                                Probability = 10,
                                Amount = 1000,
                                StageName='Discover - 10%',
                                NextStep = 'Amex Credit Card No: 378734493671000',
                                CloseDate = Date.TODAY()); 
       oppList.add(testOpp2); 
       
       Opportunity testOpp3= new Opportunity(Name = 'Test oppty3', 
  
                                AccountId = acc.Id, 
                                Probability = 10,
                                Amount = 1000,
                                StageName='Discover - 10%',
                                Description = 'Amex Credit Card No: 378734493671000',
                                CloseDate = Date.TODAY()); 
       oppList.add(testOpp3); 
        
        try{
            insert oppList;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Suspected financial information detected.');            
        }
  
      /****************Test Update********************/                          
      
      Opportunity testOpp4= new Opportunity(Name = 'Test oppty4', 
                                AccountId = acc.Id, 
                                Probability = 10,
                                Amount = 1000,
                                StageName='Discover - 10%',
                               CloseDate = Date.TODAY()); 
      try{
       insert testOpp4;      
        
            update testOpp4;
            
        }
        catch(DmlException e){
            //System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Suspected financial information detected.');            
        }
        
       Opportunity testOpp5= new Opportunity(Name = 'Test oppty5', 
                                AccountId = acc.Id, 
                                Probability = 10,
                                Amount = 1000,
                                StageName='Discover - 10%',
                                NextStep = 'testData',
                                CloseDate = Date.TODAY()); 
      try{
       insert testOpp5;   
       }
       catch(exception e){}
        testOpp5.NextStep ='Amex Credit Card No: 378734493671000' ;                
        try{
            update testOpp5;
            
        }
        catch(DmlException e){
           // System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Suspected financial information detected.');            
        }
             
       Opportunity testOpp6= new Opportunity(Name = 'Test oppty6', 
  
                                AccountId = acc.Id, 
                                Probability = 10,
                                Amount = 1000,
                                StageName='Discover - 10%',
                                Description = 'testData',
                                CloseDate = Date.TODAY()); 
     
       try{
       insert testOpp6;   
       }
       catch(exception e){}    
           
       testOpp6.Description = 'Amex Credit Card No: 378734493671000';                
       try{
            update testOpp6;
            
       }
        catch(DmlException e){
            //System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),'Suspected financial information detected.');            
       }
        
    }
}