/* 
    Revision    CR Number        Release No      Date            Modified By     Description
    --------    ---------        ----------      -----------     ------------    -----------
    2.0         CR12724           0403            26-Mar-2016     Jessie         Modified to support the removal of 'Contact Duplication Check VF' and adoption of standard out-of-box Contact Duplication 
    3.0         CR 15378          0203            09-Jan-2018     Ravali         Remove the code related to NPS_Criteria_met__c field
    
    
*/
        
    
@isTest
private class TestContact {
    
    static Contact_Exclusion__c cx = new Contact_Exclusion__c();
    static Contact[] ct = new List<Contact>();
    static Account acct = new Account();
    
    static testMethod void TestBeforeInsertWithFirstNameExclusion(){
        Test.startTest();
        
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.First_Name__c = 'TestFirstNameExclusion';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, FirstName = 'TestFirstNameExclusion')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid First Name. First Name entered is listed in the exclusion list.', e.getMessage());
            }
        }

        Test.stopTest();        
    }
    
    static testMethod void TestBeforeInsertWithLastNameExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Last_Name__c = 'TestLastNameExclusion';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, LastName = 'TestLastNameExclusion')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Last Name. Last Name entered is listed in the exclusion list.', e.getMessage());
            }
        }
    
        Test.stopTest();
    }
     
    static testMethod void TestBeforeInsertWithEmailExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Email__c = 'email1@test.com';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, Email = 'email1@test.com')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Email. Email entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }

    static testMethod void TestBeforeInsertWithAssistantEmailExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Email__c = 'email2@test.com';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, Assistant_Email__c = 'email2@test.com')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Email. Email entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }

    static testMethod void TestBeforeInsertWithAlternateEmailExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Email__c = 'email3@test.com';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, Alternate_Email__c = 'email3@test.com')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Email. Email entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }

    /*
    static testMethod void TestBeforeInsertWithLegacyInvalidEmailExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Email__c = 'email4@test.com';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, Legacy_Invalid_Email__c = 'email4@test.com')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Email. Email entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }
    */

    static testMethod void TestBeforeInsertWithFaxExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Phone__c = '1234321';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, Fax = '1234321')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Number. The Number entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }
    
    static testMethod void TestBeforeInsertWithPhoneExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Phone__c = '1234321';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, Phone = '1234321')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Number. The Number entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }

    static testMethod void TestBeforeInsertWithAssistantPhoneExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Phone__c = '2234321';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, AssistantPhone = '2234321')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Number. The Number entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }

    static testMethod void TestBeforeInsertWithHomePhoneExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Phone__c = '3234321';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, HomePhone = '3234321')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Number. The Number entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }

    static testMethod void TestBeforeInsertWithMobilePhoneExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Phone__c = '4234321';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, MobilePhone = '4234321')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Number. The Number entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }

    static testMethod void TestBeforeInsertWithOtherPhoneExclusion(){
        Test.startTest();
  
        //create test record for contact exclusion
        cx = new Contact_Exclusion__c();
        cx.Phone__c = '5234321';
        insert cx;

        //create and try to insert contact with exclusion
        ct = new List<Contact>{
            new Contact(AccountId = acct.Id, OtherPhone = '5234321')
        };
        
        Database.SaveResult[] listResults = Database.insert(ct, false);
        for(Database.SaveResult result : listResults) {
            //check that insert fails
            System.assertNotEquals(true, result.isSuccess());
            for(Database.Error e : result.getErrors()) {
                //check that error is added to the field
                System.assertEquals('Invalid Number. The Number entered is listed in the exclusion list', e.getMessage());
            }
        }
    
        Test.stopTest();
    }
     
     // 15.03 CR 9016
    
    static testMethod void TestIncNPSqualifiedcontact(){
    Account acc = new Account();
    acc.Name = 'testAccount';
    acc.NPS_Qualified_Contacts__c = 1;
    insert acc;
   
    Contact con = new Contact();
    con.AccountId = acc.Id;
    //con.Email = Null;
    con.phone = '6739';
    con.LastName = 'conLastName';
    con.FirstName = 'conFirstName';
    con.Status__c = 'Customer';
    con.Email_Opt_In__c = 'yes';
    con.Survey__c = 'yes';
    con.Decision_Making_Role__c = 'Technical Buyer';
    //con.NPS_Criteria_Met__c = False; //v3.0
    
    insert con;
    //con.Email = 'test@test.com';
    //con.NPS_Criteria_Met__c = True; //v3.0
    update con;
    }
    
    // 15.03 CR 9016
    
    static testMethod void TestDecNPSqualifiedcontact(){
    Account acc = new Account();
    acc.Name = 'testAccount';
    acc.NPS_Qualified_Contacts__c = 1;
    insert acc;
   
    Contact con = new Contact();
    con.AccountId = acc.Id;
    con.Email = 'test@test.com';
    con.phone = '6739';
    con.LastName = 'conLastName';
    con.FirstName = 'conFirstName';
    con.Status__c = 'Customer';
    con.Email_Opt_In__c = 'yes';
    con.Survey__c = 'yes';
    con.Decision_Making_Role__c = 'Technical Buyer';
    //con.NPS_Criteria_Met__c = True; //v3.0
      
    insert con;
    //con.Email = Null;
    //con.NPS_Criteria_Met__c = False; //v3.0
    update con;
    }
    
    //v2.0 - start
    static testMethod void TestCreateAndPopulateDataFromLeadWithLeadQualification(){
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        Account acc = new Account();
        acc.Name = 'testAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        insert acc;
       
        Lead lead = new Lead();
        
        lead.FirstName = 'Direct';
        lead.LastName = 'Direct';
        lead.Email = '123456@test.com';
        lead.Phone = '123456789';
        lead.LeadSource = 'Web';
        lead.Company = 'Dell Internal';
        lead.Lead_Type__c = 'Inbound';
        //lead.Country = 'India';  
        lead.recordTypeId = [SELECT Id FROM RecordType where sObjectType ='Lead' and Name ='Lead Qualification'].Id;
        //lead.RecordType.Name = 'Direct Lead 2.0';
        insert lead;
       
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Email = 'test@test.com';
        con.phone = '6739';
        con.LastName = 'conLastName';
        con.FirstName = 'conFirstName';
        con.Status__c = 'Customer';
        con.Survey__c = 'yes';
        con.Decision_Making_Role__c = 'Technical Buyer';
        //con.NPS_Criteria_Met__c = True; //v3.0
        con.source_id__c = lead.id;
                           
        insert con;
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();
        
    }
  
    static testMethod void TestCreateAndPopulateDataFromExternalLead(){
        Account acc = new Account();
        acc.Name = 'testAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        insert acc;
       
        Lead lead = new Lead();
        
        lead.FirstName = 'Direct';
        lead.LastName = 'Direct';
        lead.Email = '123456@test.com';
        lead.Phone = '123456789';
        lead.LeadSource = 'Web';
        lead.Company = 'Dell Internal';
        lead.Lead_Type__c = 'Inbound';
        lead.Country = 'India'; 
        lead.recordTypeId = [SELECT Id FROM RecordType where sObjectType ='Lead' and Name ='External Lead'].Id;
        insert lead;
       
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Email = 'test@test.com';
        con.phone = '6739';
        con.LastName = 'conLastName';
        con.FirstName = 'conFirstName';
        con.Status__c = 'Customer';
        con.Survey__c = 'yes';
        con.Decision_Making_Role__c = 'Technical Buyer';
        //con.NPS_Criteria_Met__c = True; //v3.0
        con.source_id__c = lead.id;
                           
        insert con;
        
    }
    //v2.0 - end 
}