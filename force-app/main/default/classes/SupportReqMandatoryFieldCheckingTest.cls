/*
 * Name            : SupportReqMandatoryFieldCheckingTest
 * Description     : test class for SupportReqMandatoryFieldChecking class
 * Revision  Name           Date                Description
 ----------------------------------------------------------------------------
 * 1.0       Azwanti        23/07/2013          RL14.10 SOM : CR8529-Mandatory Fields Validation for Selected Request Type
 * 2.0      Krishnamoorthi  09-June-2015        16.07(MAJ-S-03) CR 11561: GSD User Story (162173) - To validate the Contact (Customer Contact Information (Name)) related fields are not empty in Support Request 
 * 2.1      Kokila          23-July-2015        CR 11707: User Story 177472: Provide Contact record edit link and display all blank Contact fields in the Customer_Contact_InformationName__c error message
 * 3.0      Kokila          11-Aug-2015         CR 11808: To make Suggested Delivery Method as Mandatory when Solution Architect drop down selection is "Yes"
 */
@isTest
private class SupportReqMandatoryFieldCheckingTest {

    static opportunity op;
    static List<Support_Request_Submission_Rule__c> SRRuleList;
    static string actualErrMsg;
    static Contact con;
 
    static testMethod void solutionArchitectMandatoryField() {
        createTestData();
        Id RecordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
        //v3.0 Start
        /*Support_Request__c sr = new Support_Request__c();
        sr.Opportunity__c = op.id;
        sr.Solution_Architect__c = 'Yes';   
        sr.Custom_Service_Support__c = 'Custom Service Solution';     
        sr.RecordTypeId = RecordTypeId;     
        
        try{
           Test.Starttest();
            insert sr;
            Test.Stoptest();
        }catch(Exception e){
            //string errMsg = 'You have selected Yes for Solution Architect. Please complete the required fields in the Solution Architect Support section of the form so that your request can be submitted.';
            string errMsg = 'You must enter a value';
            System.assert(e.getMessage().contains(errMsg));
        } */
    
        List<Support_Request__c> sr_Man = new List<Support_Request__c>();
            
        sr_Man.add(new Support_Request__c(RecordTypeId = RecordTypeId, Opportunity__c = op.id, 
                                    Solution_Architect__c = 'Yes',
                                    Engagement_Time_Frame__c = System.Today() + 10, 
                                    Decision_Date__c = System.Today() + 10, 
                                    Custom_Service_Support__c = 'Custom Service Solution', Comments__c = 'Test Comments', 
                                    Customer_Contact_InformationName__c = con.Id));
       
        try{
            Test.Starttest();
            insert sr_Man;  
            Test.Stoptest();
        }catch(Exception e){
            //string errMsg = 'You have selected Yes for Solution Architect. Please complete the required fields in the Solution Architect Support section of the form so that your request can be submitted.';
            string errMsg = 'You must enter a value';
            System.assert(e.getMessage().contains(errMsg));
        } //v3.0 End
     
    } 
    
    static testMethod void projectDurationMandatoryField() {
        createTestData();
        Id RecordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
        Support_Request__c sr = new Support_Request__c();
        sr.Opportunity__c = op.id;
        sr.Solution_Architect__c = 'Yes';  
        sr.Custom_Service_Support__c = 'Custom Service Solution';     
        sr.RecordTypeId = RecordTypeId;     
        
        try{
           Test.Starttest();
            insert sr;
            Test.Stoptest();
        }catch(Exception e){
            //string errMsg = 'You have selected Yes for Solution Architect. Please complete the required fields in the Solution Architect Support section of the form so that your request can be submitted.';
            string errMsg = 'You must enter a value';
            System.assert(e.getMessage().contains(errMsg));
        } 
    }
    
    static testMethod void servicesFinanceMandatoryField() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep - Non SSO%' ORDER BY Name DESC LIMIT 1];
    
        List<User> testUser = new List<User>();
            
        testUser.add(new User(Username='testSalesUser1' +'@dell.com',
                                    Alias = 'Test1', 
                                    Email='testSalesUser1'+'@dell.com',            
                                    LastName='Test1',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test1'+System.currentTimeMillis())); 

        System.runAs(testUser[0]){
        
            createTestData();
            Id RecordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
            Support_Request__c sr = new Support_Request__c();
            sr.Opportunity__c = op.id;
            sr.Services_Finance_Support__c = 'Yes';    
            sr.Custom_Service_Support__c = 'Custom Service Solution';    
            sr.RecordTypeId = RecordTypeId;
          
            try{
                   Test.Starttest();
                    insert sr;
                    Test.Stoptest();
                }catch(Exception e){
                    //string errMsg = 'You have selected Yes for Services Finance Support. Please complete the required fields in the Services Finance Support section of the form so that your request can be submitted.'; 
                    string errMsg = 'You must enter a value';   
                    System.assert(e.getMessage().contains(errMsg));
                }
        }           
    }
    
    static testMethod void solArchitectServFinanceMandatoryField() {
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep - Non SSO%' ORDER BY Name DESC LIMIT 1];
    
        List<User> testUser1 = new List<User>();
            
        testUser1.add(new User(Username='testSalesUser1' +'@dell.com',
                                    Alias = 'Test1', 
                                    Email='testSalesUser1'+'@dell.com',            
                                    LastName='Test1',
                                    ProfileId = profile1.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test1'+System.currentTimeMillis())); 

        System.runAs(testUser1[0]){
        
            createTestData();
            Id RecordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
            Support_Request__c sr = new Support_Request__c();
            sr.Opportunity__c = op.id;
            sr.Solution_Architect__c = 'Yes';
            sr.Services_Finance_Support__c = 'Yes';  
            sr.Custom_Service_Support__c = 'Custom Service Solution'; 
            sr.RecordTypeId = RecordTypeId;     
            
            try{
               Test.Starttest();
                insert sr;
                Test.Stoptest();
            }catch(Exception e){
                //string errMsg = System.Label.SupportReqMandatoryErrMsg;
                string errMsg = 'You must enter a value';
                //string errMsg = 'You have selected Yes for Solution Architect and Services Finance Support. Please complete the required fields in the Solution Architect Support and Services Finance Support section of the form so that your request can be submitted.';
                System.assert(e.getMessage().contains(errMsg));
            }
       } 
    }
      /*
    v2.0 - 16.07(MAJ-S-03)  CR 11561: GSD User Story (162173) - To validate the Contact (Customer Contact Information (Name)) related fields are not empty in Support Request
    */
    /*static testMethod void customerContactInformationMandatoryCheck() {
        createTestData();
        Id RecordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
        Support_Request__c sr = new Support_Request__c();
        sr.Opportunity__c = op.id;
        sr.RecordTypeId = RecordTypeId;
        sr.Solution_Architect__c = 'Yes';
        sr.Custom_Service_Support__c = 'Custom Service Solution'; 
        sr.Engagement_Time_Frame__c = System.Today() + 13;
        sr.Project_Type__c = 'CWS';
        sr.Project_Duration_months__c = 2;
        sr.Decision_Date__c = System.Today() + 10;
        sr.Primary_Work_Delivery_Language__c = 'English';
        sr.Comments__c = 'Test Comments';
        sr.Deliverable_Due_Date__c = System.Today() + 15;
        sr.Customer_Contact_InformationName__c = con.Id;    
             
        
        Test.Starttest();
        try{
             insert sr;
        }catch(Exception e){
            //Check error message for blank Phone field
            string errMsg = 'You must enter Phone value in Contact';
            System.assert(e.getMessage().contains(errMsg));
        }
        
        con.Phone='3213213211';
        con.Email = '';
        update con;
        
        try{
             insert sr;
        }catch(Exception e){
            //Check error message for blank Email field
            string errMsg = 'You must enter Email value in Contact';
            System.assert(e.getMessage().contains(errMsg));
        }
        
        con.Email = 'Email_115@dellTeam.Com';
        con.MailingStreet='';
        update con;
        
        try{
             insert sr;
        }catch(Exception e){
            //Check error message for blank MailingStreet field
            string errMsg = 'You must enter MailingStreet value in Contact';
            System.assert(e.getMessage().contains(errMsg));
        }
        
        con.MailingStreet='123 Main';
        con.MailingCity='';
        update con;
        
        try{
             insert sr;
        }catch(Exception e){
            //Check error message for blank MailingCity field
            string errMsg = 'You must enter MailingCity value in Contact';
            System.assert(e.getMessage().contains(errMsg));
        }

        Test.Stoptest();        
    }*/
    
    /*
    v2.1 - Provide Contact record edit link and display all blank Contact fields in the Customer_Contact_InformationName__c error message
    */
    static testMethod void customerContactInformationMandatoryCheck() {
    
        Profile profile2 = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep - Non SSO%' ORDER BY Name DESC LIMIT 1];
    
        List<User> testUser2 = new List<User>();
            
        testUser2.add(new User(Username='testSalesUser2' +'@dell.com',
                                    Alias = 'Test2', 
                                    Email='testSalesUser2'+'@dell.com',            
                                    LastName='Test2',
                                    ProfileId = profile2.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test2'+System.currentTimeMillis())); 

        System.runAs(testUser2[0]){        
            createTestData();
            Id RecordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
            Support_Request__c sr = new Support_Request__c();
            sr.Opportunity__c = op.id;
            sr.RecordTypeId = RecordTypeId;
            sr.Solution_Architect__c = 'Yes';
            sr.Custom_Service_Support__c = 'Custom Service Solution'; 
            sr.Engagement_Time_Frame__c = System.Today() + 13;
            sr.Project_Type__c = 'CWS';
            sr.Project_Duration_months__c = 2;
            sr.Decision_Date__c = System.Today() + 10;
            sr.Primary_Work_Delivery_Language__c = 'English';
            sr.Comments__c = 'Test Comments';
            sr.Deliverable_Due_Date__c = System.Today() + 15;
            sr.Customer_Contact_InformationName__c = con.Id;
            sr.Suggested_Delivery_Method__c = 'Custom';    //v3.0 Added
                 
            
            Test.Starttest();
            try{
                 insert sr;
            }catch(Exception e){
                string errMsg = 'Selected Contact is missing Phone value.';
                system.assert(e.getMessage().contains(errMsg));
            }
                        
            con.Phone='3213213211';
            con.Email = '';
            update con;
            
            try{
                 insert sr;
            }catch(Exception e){
                string errMsg = 'Selected Contact is missing Email value.';
                system.assert(e.getMessage().contains(errMsg));
            }
                  
            con.Email = '';
            con.MailingStreet='';
            con.MailingCity='';
            con.MailingState='';
            con.MailingCountry='';
            update con;
            
            try{
                 insert sr;
            }catch(Exception e){
                string errMsg = 'Selected Contact is missing Email, Mailing Street, Mailing City, Mailing State/Province, Mailing Country values.';
                system.assert(e.getMessage().contains(errMsg));              
            } 
            Test.Stoptest();  
           }      
    }

    static void createTestData(){
             
        Account testAccount = new Account(Name='testAccount');     
        insert testAccount;
        
        con = new Contact();
        con.AccountID = testAccount.ID;
        con.Email = 'Email_115@dellTeam.Com';
        con.FirstName = 'TestContact'; 
        con.LastName = '1'; 
        con.Title='VP';
        con.MailingStreet='123 Main';
        con.MailingCity='Peoria';
        con.MailingState='IL';
        con.MailingCountry='US';
        con.MailingPostalCode='33333';
        //con.Phone='3213213211';
        con.MobilePhone='3213213211';
        con.Fax='3213123211';
        con.Status__c = 'Marketing Suspect';      
        insert con;  
        
        SRRuleList = new List<Support_Request_Submission_Rule__c>();
        op = new opportunity();
        op.name = 'test opportunity';
        op.StageName = '10%';
        op.CloseDate = System.Today();
        op.Quest_Software_Contact__c= con.id;
        insert op;                
        
    }
    
    }