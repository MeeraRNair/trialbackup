@IsTest
private class afterInsertUpdateCertTrackerTest {   
 // TEST CLASS FOR afterInsertUpdateTriggerOnCertificationTracker and CertificationTracker_UpdateSuggestion class

    //method for Field update
    Static testmethod void updateSuggestionTest(){
    Test.startTest();   
    CertificationTracker_UpdateSuggestion.isTestExecution = true; 
    List<String> lstLeadID = new List<String>();    
        //Create partner Account
        Account acc = new Account(
                      Name = 'Test Account',
                      Account_Country__c = 'INDIA',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active');
       Account accchina = new Account(
                      Name = 'Test Account',
                      Account_Country__c = 'CHINA',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active');

        System.debug('###Before Insert: account- ' +acc.id);
        insert acc;
        insert accchina;
        System.debug('@@@@@@ After Insert: account- ' +acc.id);

        //tracker
        Certification_Tracker__c tracker;
        List<Certification_Tracker__c> trackerList = new List<Certification_Tracker__c>();
        for(integer i=0;i<10;i++){
            tracker = new Certification_Tracker__c(
                                                Account_Name__c = acc.Id,
                                                CurrencyIsoCode = 'INR',                                        
                                                Qualified_as_Dell_Preferred_Partner__c = true,
                                                Qualified_as_Dell_Premier_Partner__c = false);
            System.debug('### Before Insert: Tracker- '+tracker);  
            tracker = new Certification_Tracker__c(
                                                Account_Name__c = accchina.Id,
                                                CurrencyIsoCode = 'INR',                                        
                                                Qualified_as_Dell_Preferred_Partner__c = true,
                                                Qualified_as_Dell_Premier_Partner__c = false);
            System.debug('### Before Insert: Tracker- '+tracker);    
            trackerList.add(tracker);
        }
         try{
                insert trackerList;
        }catch(Exception ex){}
        System.debug('@@@@@ After Insert: Tracker- '+tracker);

        //update tracker
        for(integer i=0;i<10;i++){
            trackerList[i].Qualified_as_Dell_Preferred_Partner__c = false;
            trackerList[i].Qualified_as_Dell_Premier_Partner__c = true;                       
            trackerList[i].Premier_Criteria_Enable__c = true;                       
        }
        try{
        update trackerList;
        }catch(exception ex){}
        System.debug('@@@@ After Update: Tracker- '+tracker);
        
    //result        
        for(Lead lead_result : [SELECT ID,Account__c FROM Lead WHERE Account__c =: acc.id]){            
            lstLeadID.add(lead_result.Id);
            AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
            response.OracleError = '';
            response.ErrorDescription = '';
            response.IsAccountDuplicate=true;           
            response.ID = '375836';            
            CertificationTracker_UpdateSuggestion.result = response;
            //call future method
            CertificationTracker_UpdateSuggestion.TrackerUpdateSuggestion(lstLeadID);
            System.debug('###Result: '+ lead_result);
            //check whether the Lead ID field is not null
            System.assertNotEquals(lead_result.ID,null);  
            System.debug('@@@@@@@ Lead: '+ lead_Result);
        }
        Test.stopTest();
    }   
    
        //method for new value - first time insert
    Static testmethod void updateSuggestionTest_newValue(){
    Test.startTest();   
    CertificationTracker_UpdateSuggestion.isTestExecution = true;
    List<String> lstLeadID = new List<String>();        
        //Create partner Account
        Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active');
        System.debug('###Before Insert: account- ' +acc.id);
        insert acc;
        System.debug('@@@@@ After Insert: account- ' +acc.id);

        //tracker
        Certification_Tracker__c tracker;
        List<Certification_Tracker__c> trackerList = new List<Certification_Tracker__c>();
        for(integer i=0;i<10;i++){
            tracker = new Certification_Tracker__c(
                                                Account_Name__c = acc.Id,
                                                CurrencyIsoCode = 'INR',                                                
                                                Qualified_as_Dell_Preferred_Partner__c = false,
                                                Qualified_as_Dell_Premier_Partner__c = true, Premier_Criteria_Enable__c = true);
            System.debug('### Before Insert: Tracker- '+tracker);    
            trackerList.add(tracker);
        }
        try{
        insert trackerList;
        System.debug('@@@@ After Insert: Tracker- '+tracker);
            }catch(Exception ex){}
        //update tracker
        for(integer i=0;i<10;i++){
            trackerList[i].Qualified_as_Dell_Preferred_Partner__c = true;
            trackerList[i].Qualified_as_Dell_Premier_Partner__c = false;                        
        }
        try{
        update trackerList;
            System.debug('@@@@@@ After Update: Tracker- '+tracker);
            }catch(Exception ex){}
        for(Lead lead_result : [SELECT ID,Account__c FROM Lead WHERE Account__c =: acc.id]){   
            lstLeadID.add(lead_result.Id);
            AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
            response.OracleError = '';
            response.ErrorDescription = '';
            response.IsAccountDuplicate=true;           
            response.ID = '375836';            
            CertificationTracker_UpdateSuggestion.result = response;
            //call future method
            CertificationTracker_UpdateSuggestion.TrackerUpdateSuggestion(lstLeadID);       
            System.debug('###Result: '+ lead_result);
            //check whether the Lead ID field is not null
            System.assertNotEquals(lead_result.ID ,null);  
            System.debug('@@@@@@@ Lead: '+ lead_Result);
        }
        Test.stopTest();
    }
//  populating Account field, Dell_Certification_Areas test - new value
    Static testmethod void populateDellCertAreaTest_newValue(){
        Test.startTest();
        //Create partner Account
        Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active',
                       Tracker_Dell_Certification_Areas__c='');
        System.debug('###Before Insert: account- ' +acc.id);
        insert acc;
        System.debug('@@@@@ After Insert: account- ' +acc);
        //tracker
        Certification_Tracker__c tracker;
            tracker = new Certification_Tracker__c(
                                                Account_Name__c = acc.Id,
                                                CurrencyIsoCode = 'INR',
                                                Dell_Certification_Areas__c='Server');
            System.debug('### Before Insert: Tracker- '+tracker);    
        
        insert tracker;
        System.debug('@@@@ After Insert: Tracker- '+tracker);
        //result                
        for(Account acc_result : [SELECT Id,Tracker_Dell_Certification_Areas__c FROM Account WHERE Name =: acc.id]){            
            System.debug('###Result: '+ acc_result);
            //check whether the Tracker_Dell_Certification_Areas__c is not null
            System.assertNotEquals(acc_result.Tracker_Dell_Certification_Areas__c,null);  
            System.debug('@@@@@@@ Account: '+ acc_result.Tracker_Dell_Certification_Areas__c);
        }
        Test.stopTest();
    }   
    //  populating Account field, Dell_Certification_Areas test - update
    Static testmethod void populateDellCertAreaTest(){
    Test.startTest();
        //Create partner Account
        Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active',
                      Tracker_Dell_Certification_Areas__c = '');
        System.debug('###Before Insert: account- ' +acc.id);
        insert acc;
        System.debug('@@@@@ After Insert: account- ' +acc);
        //tracker
        Certification_Tracker__c tracker;               
            tracker = new Certification_Tracker__c(
                                                Account_Name__c = acc.Id,
                                                CurrencyIsoCode = 'INR',
                                                Dell_Certification_Areas__c='Server');
            System.debug('### Before Insert: Tracker- '+tracker);            
        
        insert tracker;
        System.debug('@@@@ After Insert: Tracker- '+tracker);
        //update tracker        
            tracker.Dell_Certification_Areas__c = 'Storage';                    
        update tracker;
        System.debug('@@@@@@ After Update: Tracker- '+tracker);       
        //Result
        for(Account acc_result : [SELECT Id,Tracker_Dell_Certification_Areas__c FROM Account WHERE Name =: acc.id]){    
            System.debug('###Result: '+ acc_result);
            //check whether the Tracker_Dell_Certification_Areas__c is not null
            System.assertNotEquals(acc_result.Tracker_Dell_Certification_Areas__c,null);  
            System.debug('@@@@@@@ Result: '+ acc_result.Tracker_Dell_Certification_Areas__c);
        }
        Test.stopTest();
    }
    //send suggestion with valid ID
    Static testmethod void sendSuggestion_validIDTest(){
    Test.startTest();
    CertificationTracker_UpdateSuggestion.isTestExecution = true; 
    List<String> lstLeadID = new List<String>();
        //Create partner Account
        Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active');
        System.debug('###Before Insert: account- ' +acc.id);
        insert acc;
        System.debug('@@@@@@ After Insert: account- ' +acc.id);

        //tracker
        Certification_Tracker__c tracker;
        List<Certification_Tracker__c> trackerList = new List<Certification_Tracker__c>();
        for(integer i=0;i<10;i++){
            tracker = new Certification_Tracker__c(
                                                Account_Name__c = acc.Id,
                                                CurrencyIsoCode = 'INR',                                        
                                                Qualified_as_Dell_Preferred_Partner__c = true,
                                                Qualified_as_Dell_Premier_Partner__c = false);
            System.debug('### Before Insert: Tracker- '+tracker);    
            trackerList.add(tracker);
        }
        try{
        insert trackerList;
        System.debug('@@@@@ After Insert: Tracker- '+tracker);
        }catch(Exception ex){}
        //Lead lead_result : [SELECT ID,Account__c FROM Lead WHERE Account__c =: acc.id]
        for(Lead lead_result : [SELECT Account__r.Account_ID__c, Account__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                                Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                                CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                                Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                                NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                                Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                                Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                                Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                                Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                                Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                                Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, //Questions_Comments__c, 
                                Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c,
                                Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                                Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c  //CR2574
                                FROM Lead
                                WHERE Account__c =: acc.id]){
        lstLeadID.add(lead_result.Id);
            AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
            response.OracleError = '';
            response.ErrorDescription = '';
            response.IsAccountDuplicate=true;           
            response.ID = '375836';            
            CertificationTracker_UpdateSuggestion.result = response;
            //call future method
            CertificationTracker_UpdateSuggestion.TrackerUpdateSuggestion(lstLeadID);
        }
        Test.stopTest();
    }
    //send suggestion with ID=0
    Static testmethod void sendSuggestion_IDTest(){
    Test.startTest(); 
    CertificationTracker_UpdateSuggestion.isTestExecution = true; 
    string ExcludeCountry = 'CHINA,HONG KONG,TAIWAN,MACAU';
    List<String> lstLeadId = new List<String>();
        //Create partner Account
        Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active');
        System.debug('###Before Insert: account- ' +acc.id);
        insert acc;
        System.debug('@@@@@@ After Insert: account- ' +acc.id);

        //tracker
        Certification_Tracker__c tracker;
        List<Certification_Tracker__c> trackerList = new List<Certification_Tracker__c>();
        for(integer i=0;i<10;i++){
            tracker = new Certification_Tracker__c(
                                                Account_Name__c = acc.Id,
                                                CurrencyIsoCode = 'INR',
                                                                                        
                                                Qualified_as_Dell_Preferred_Partner__c = true,
                                                Qualified_as_Dell_Premier_Partner__c = false);
            System.debug('### Before Insert: Tracker- '+tracker);    
            trackerList.add(tracker);
        }
        try{
        insert trackerList;
        }catch(Exception ex){}
        System.debug('@@@@@ After Insert: Tracker- '+tracker);
        //Lead lead_result : [SELECT ID,Account__c FROM Lead WHERE Account__c =: acc.id]
        for(Lead lead_result : [SELECT Account__r.Account_ID__c, Account__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                                Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                                CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                                Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                                NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                                Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                                Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                                Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                                Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                                Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                                Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, //Questions_Comments__c, 
                                Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c,
                                Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                                Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c  //CR2574
                                FROM Lead
                                WHERE Account__c =: acc.id]){
            lstLeadId.add(lead_result.Id);            
            AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
            response.OracleError = '';
            response.ErrorDescription = '';
            response.IsAccountDuplicate=true;           
            response.ID = '0';
            CertificationTracker_UpdateSuggestion.result = response;
            //call future method 
            CertificationTracker_UpdateSuggestion.TrackerUpdateSuggestion(lstLeadId);
        }
        Test.stopTest();
    }
    //send suggestion valid ID=null
    Static testmethod void sendSuggestion_NullIDTest(){
    string ExcludeCountry = 'CHINA,HONG KONG,TAIWAN,MACAU';
    Test.startTest();
    CertificationTracker_UpdateSuggestion.isTestExecution = true; 
        List<String> lstLeadId = new List<String>();        
        //Create partner Account
        Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active');
        System.debug('###Before Insert: account- ' +acc.id);
        insert acc;
        System.debug('@@@@@@ After Insert: account- ' +acc.id);

        //tracker
        Certification_Tracker__c tracker;
        List<Certification_Tracker__c> trackerList = new List<Certification_Tracker__c>();
        for(integer i=0;i<10;i++){
            tracker = new Certification_Tracker__c(
                                                Account_Name__c = acc.Id,
                                                CurrencyIsoCode = 'INR',                                        
                                                Qualified_as_Dell_Preferred_Partner__c = true,
                                                Qualified_as_Dell_Premier_Partner__c = false);
            System.debug('### Before Insert: Tracker- '+tracker);   
            try{ 
            trackerList.add(tracker);
            }catch(Exception ex){}
        }
        try{
        insert trackerList;
        System.debug('@@@@@ After Insert: Tracker- '+tracker);
        }catch(Exception ex){}
        //Lead lead_result : [SELECT ID,Account__c FROM Lead WHERE Account__c =: acc.id]
        for(Lead lead_result : [SELECT Account__r.Account_ID__c, Account__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                                Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                                CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                                Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                                NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                                Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                                Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                                Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                                Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                                Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                                Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c,//Questions_Comments__c, 
                                Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c,
                                Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                                Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c  //CR2574
                                FROM Lead
                                WHERE Account__c =: acc.id]){
            lstLeadId.add(lead_result.Id);                 
            AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
            response.OracleError = '';
            response.ErrorDescription = '';
            response.IsAccountDuplicate=true;           
            response.ID = '';
            CertificationTracker_UpdateSuggestion.result = response;            
            //call future method 
            CertificationTracker_UpdateSuggestion.TrackerUpdateSuggestion(lstLeadId);
        }
        Test.stopTest();
    }
}