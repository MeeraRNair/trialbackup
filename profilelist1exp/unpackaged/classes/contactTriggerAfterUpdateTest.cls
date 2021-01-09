/* ---------------------------------------------------------
* Revision  Name            Date        Release         Description
* 1.0                                                   Creation
* 2.0       Krishnamoorthi  05.06.2015  16.07(MAJ-S-03) CR 11561: GSD User Story (162173) - To update the Contact (Customer Contact Information (Name)) 
                                                        fields in Support Request when the Contact Phone, Email or Address details updated
************************************************************/

@isTest
private class contactTriggerAfterUpdateTest {

    static testMethod void UpdateContactPRStatusComplete(){
      Id  REQUEST_RECORD_TYPE_UPDATE_User = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER, 'Partner_Request__c', true);
      Contact testContactObjt = createTestData();
      
      testContactObjt.Last_Operation_Performed__c = 'Vendor Updated';
      testContactObjt.Vendor_Update_Datetime__c= System.today();
      testContactObjt.Is_Enabled_for_Incentives__c= true;
      testContactObjt.Is_Vendor_Updated__c = true;
      Update testContactObjt;
      
      Partner_Request__C testPRObjt = [Select Status__c from Partner_Request__c 
                                       where Contact__c =:testContactObjt.id]; 
      
      System.assertEquals(PartnerConstants.REG_STATUS_COMPLETE,testPRObjt.Status__c);
    
    }

    static testMethod void UpdateContactPRStatusInComplete(){
      Id   REQUEST_RECORD_TYPE_UPDATE_User = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER, 'Partner_Request__c', true);
      Contact testContactObjt = createTestData();
      
      testContactObjt.Last_Operation_Performed__c = 'Vendor Sync failed';
      testContactObjt.Vendor_Update_Datetime__c= System.today();
      testContactObjt.Is_Enabled_for_Incentives__c= true;
      testContactObjt.Is_Vendor_Updated__c = true;
      Update testContactObjt;
      
      Partner_Request__C testPRObjt = [Select Status__c from Partner_Request__c 
                                       where (Status__c = :PartnerConstants.REG_STATUS_INCOMPLETE OR Status__c = :PartnerConstants.REG_STATUS_DRAFT) AND RecordTypeId = :REQUEST_RECORD_TYPE_UPDATE_USer
                                       AND contact__r.Vendor_Update_Datetime__c != null AND Contact__c =:testContactObjt.id ORDER BY CreatedDate Desc ]; 
      
      System.assertEquals(PartnerConstants.REG_STATUS_INCOMPLETE,testPRObjt.Status__c);
    }




   private static Contact createTestData(){
      Id  REQUEST_RECORD_TYPE_UPDATE_User = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER, 'Partner_Request__c', true);
      
 
      Account testAccObjt= new Account (name='Test1',Account_Country_Code__c='BB',Account_Country__c='Bikini Bottom',type='Partner',
                                        RecordTypeId = System.Label.RecType_Partner_Account);
      insert testAccObjt;
      
      
      Contact testContactObjt= new Contact(AccountID = testAccObjt.ID, Email = 'Email_1@dellTeam.Com', FirstName = 'SpongeBob', LastName = '1', Title='VP',MailingStreet='123 Main',
                   MailingCity='Peoria', MailingState='IL', MailingPostalCode='33333',Phone='3213213211',MobilePhone='3213213211',Fax='3213123211',
                   Status__c = 'Marketing Suspect');
      
      insert testContactObjt;             
                   
     
      Partner_Request__c testPRObjt = new Partner_Request__c (recordTypeID=  REQUEST_RECORD_TYPE_UPDATE_USER, Account__c =  testAccObjt.ID, contact__C=testContactObjt.ID, 
                                                  status__C=PartnerConstants.REG_STATUS_DRAFT );
                                                  
      insert testPRObjt;             
   
      return testContactObjt; 
   
   }
  
/*
    v2.0 CR 11561: GSD User Story (162173) - To update the Contact (Customer Contact Information (Name)) 
                                            fields in Support Request when the Contact Phone, Email or Address details updated
    */
    
    static testMethod void updateContactFieldsInSR() {
        
        Account testAccount = new Account(Name='testAccount');     
        insert testAccount; 
        
        Opportunity testOpp = new opportunity();
        testOpp.name = 'test opportunity';
        testOpp.StageName = '10%';
        testOpp.CloseDate = System.Today();
        insert testOpp;  
        
        Contact testContactObjt= new Contact(AccountID = testAccount.ID, Email = 'Email_115@dellTeam.Com', FirstName = 'TestContact', LastName = '1', Title='VP',MailingStreet='123 Main', MailingCity='Peoria', MailingState='IL', MailingCountry='US', MailingPostalCode='33333',Phone='3213213211',MobilePhone='3213213211',Fax='3213123211',Status__c = 'Marketing Suspect');      
        insert testContactObjt;             

        //Get  Request Custom Service Support Record type id
        Id  RCSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);    

        Support_Request__c SR = new Support_Request__c(RecordTypeId = RCSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Solution_Architect__c = 'Yes',
                                    Engagement_Time_Frame__c = System.Today() + 10, Project_Type__c = 'CWS', Project_Duration_months__c = 2, 
                                    Decision_Date__c = System.Today() + 10, Primary_Work_Delivery_Language__c = 'English',
                                    Custom_Service_Support__c = 'Custom Service Solution', Comments__c = 'Test Comments', Deliverable_Due_Date__c = System.Today() + 15, Customer_Contact_InformationName__c = testContactObjt.Id);
        Test.startTest();
        insert SR;

        //Query the fields in Support Request object
        Support_Request__c SR2 = [SELECT Id, Customer_Contact_Information_Name__c, Customer_Contact_Information_Phone__c, Customer_Contact_Information_Email__c, Primary_Work_Delivery_Address_1__c, Primary_Work_Delivery_City__c, Primary_Work_Delivery_State_Province__c,
        Primary_Work_Delivery_Country__c FROM Support_Request__c WHERE Id =: SR.Id];    
        
        //Query the fields in Contact object
        Contact con2 = [SELECT Id, Name, Phone, Email, MailingStreet, MailingCity, MailingState, MailingCountry FROM Contact 
                    WHERE Id =: testContactObjt.Id];    
        
        //Assert the Contact fields are populated in Support Request object
        System.assertEquals(con2.Name,SR2.Customer_Contact_Information_Name__c);
        System.assertEquals(con2.Phone,SR2.Customer_Contact_Information_Phone__c);
        System.assertEquals(con2.Email,SR2.Customer_Contact_Information_Email__c);
        System.assertEquals(con2.MailingStreet,SR2.Primary_Work_Delivery_Address_1__c);
        System.assertEquals(con2.MailingCity,SR2.Primary_Work_Delivery_City__c);
        System.assertEquals(con2.MailingState,SR2.Primary_Work_Delivery_State_Province__c);
        System.assertEquals(con2.MailingCountry,SR2.Primary_Work_Delivery_Country__c);   
        
        //Update the Contact details
        con2.Email = 'Email_225@dellTeam.Com';
        con2.LastName = '2';
        con2.Phone = '3213213333';
        con2.MailingStreet = '1234 Main';
        con2.MailingCity = 'Peoria2';
        con2.MailingState = 'IL2';
        con2.MailingCountry = 'US2';
        update con2;
        
        Support_Request__c SR3 = [SELECT Id, Customer_Contact_Information_Name__c, Customer_Contact_Information_Phone__c, Customer_Contact_Information_Email__c, Primary_Work_Delivery_Address_1__c, Primary_Work_Delivery_City__c, Primary_Work_Delivery_State_Province__c,
        Primary_Work_Delivery_Country__c FROM Support_Request__c WHERE Id =: SR2.Id];
        
        Contact con3 = [SELECT Id, Name, Phone, Email, MailingStreet, MailingCity, MailingState, MailingCountry FROM Contact 
                    WHERE Id =: con2.Id];
                    
        //Assert the new Contact field values are updated in Support Request object
        System.assertEquals(con3.Name,SR3.Customer_Contact_Information_Name__c);
        System.assertEquals(con3.Phone,SR3.Customer_Contact_Information_Phone__c);
        System.assertEquals(con3.Email,SR3.Customer_Contact_Information_Email__c);
        System.assertEquals(con3.MailingStreet,SR3.Primary_Work_Delivery_Address_1__c);
        System.assertEquals(con3.MailingCity,SR3.Primary_Work_Delivery_City__c);
        System.assertEquals(con3.MailingState,SR3.Primary_Work_Delivery_State_Province__c);
        System.assertEquals(con3.MailingCountry,SR3.Primary_Work_Delivery_Country__c);          
        
        Test.stopTest();
    }   

}