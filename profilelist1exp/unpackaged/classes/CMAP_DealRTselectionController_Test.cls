/* 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0                  14.2            09-Nov-2012     Bianca          Test class for CMAP_DealRTselectionController
 * 2.0                  14.2            14-Nov-2012     Bianca          Modified the test method to include CMAP_TestDataGenerator test data
 * 3.0      10736       16.03           22-Dec-2015     Ragu            Changes for CR 10736.
 * 4.0      13147       FY17-DCS-0602   16-May-2016     Azwanti         LM2_6-Fix Test Class Impacted on Campaign RT Deactivated (Part 2)
 * 5.0      16129       FY19-DCS-0802   10-July-2018    Naga            Deleted duplicated code as part of code clean up
 */
@isTest
private class CMAP_DealRTselectionController_Test {
    //v5.0 Start
    static CMAP_Queue_Settings__c objCust;
    static Lead leadObj;
    static user partnerUser1;
    
    static testmethod void testData() {
    
    CMAP_TestDataGenerator testData= new CMAP_TestDataGenerator();
    testData.getAccount(true);

        TriggerExecutionController.setSkipAllTriggers(true);
        Id leadAssignmentRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
        Id accRTId= StaticFactory.getRecordTypeIdByName('Account', 'Partner Account');
        Id campRTId= StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); //4.0
        
        Account newAcc = new Account(Name='MyTestAccount9', Type = 'Partner', RecordtypeId = accRTId,Partner_Track__c=testData.PTaccountObj.Id);
        insert newAcc;
        
        System.assertEquals(newAcc.Name,'MyTestAccount9');  
             
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                                     LastName = 'MyTestContact9',
                                     AccountId = newAcc.Id,
                                     Status__c  =  'Marketing Suspect',
                                     Email = 'MyTestContactEmail_9@ust-global.com',
                                     Fax = '1234567',
                                     MobilePhone = '0987654',
                                     Last_Operation_Performed__c = 'testing',
                                     Phone = '1234500',
                                     EligibleTracks__c=newAcc.Partner_Track__c
                                     );
        insert newCont;
        
       
        
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        partnerUser1 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyTestUser9@dell.com', 
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='99826513', 
                                    isActive = TRUE,
                                    //Enable_As_Partner_Lead_Super_User__c = TRUE,
                                    //AccountId = accountObj.Id,
                                    ContactId = newCont.Id);
        insert partnerUser1;
        
        objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust;
        
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                        //Campaign_Objective__c='Acquisition/Site Development',
                                        Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                        Region__c='ABU',                        
                                        Follow_Up_Role__c='Account Executive',
                                        Description='Test',StartDate=system.today(),EndDate=system.today(),
                                        status='In Progress',
                                        Allocation_Source__c = 'Dell Allocation ABU',
                                        Nurture_Source__c = 'Dell Nurturing',
                                        Country_Code__c = 'BR - Brazil',
                                        Lead_Routing__c = 'Dell Standard',
                                        Partner_Event_or_Campaign__c = False,
                                        // Partner_Campaign_Contact__c = partnerUser1.Id,
                                        //  Partner_Campaign_Contact_Email__c = 'Test@dell.com',
                                        IsActive = true,
                                        RecordTypeId = campRTId,
                                        Total_Value_Won_Opportunities_Planned__c = 1,
                                        Total_Value_Opportunities_Planned__c = 1);
        insert newCampgn;
       
        End_Customer__c endCustomer = new End_Customer__c(Partner_Account__c = newAcc.Id,
                                                            Name = 'Test Company', Mailing_city__c = 'Test City' ,
                                                            Mailing_country__c = 'Test Country', Mailing_State__c = 'Test State',
                                                            Mailing_street__c = 'Test Street', Status__c ='Active',
                                                            Website__c = 'www.salesforce.com', Zip_Code__c = '664455',
                                                            Account_Industry__c = 'Agriculture');
        insert endCustomer ;
        
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Name = 'Test Contact',
                                                                                Last_Name__c = 'Test Last Name',Email__c = 'Test@Email.com',
                                                                                Fax__c = '243455', Phone__c = '23435466',
                                                                                Mobile__c ='324235566', End_Customer__c = endCustomer.Id,
                                                                                Title__c = 'Test Title', Status__c = 'Active');
        insert endCustomerContact;
        leadObj = new Lead(lastName = 'Test Lead',
                                email ='testcmap@cmaptest.com',
                                status = 'Open - Channel Lead',
                                Phone='88967544',
                                Partner_Account__c = newAcc.Id,
                                country = 'US',
                                Country_CN__c = 'UNITED STATES',
                                Partner_User__c = partnerUser1.Id,
                               // Partner_User__c = '0053B000000F2vJ',
                                Ready_For_Scoring__c = TRUE,
                                Budget__c ='Yes',
                                Purchase_Timeframe__c = 'Immediately',
                                Campaign__c  = newCampgn.Id,
                                Search_My_Customer__c = endCustomer.Id,
                                Search_My_Customer_Contact__c = endCustomerContact.Id,
                                RecordTypeId = leadAssignmentRTId,
                                Total_Expected_Dell_Revenue__c = 1,
                                Related_Contact__c = newCont.Id,
                                Called_Customer__c = 'Yes',
                                Sales_Qualified__c = 'Unqualified',
                                //OwnerId = objCust.Id,
                                Company = 'Test Company');
        insert leadObj;
         
         //User loggedInUser = [select Id,Contact.Id from user where id = : UserInfo.getUserId()];
         
         /*User loggedInUser = partnerUser1;
         String con = loggedInUser.Contact.Id;
         contact cont= new contact(id=con);
         system.debug('*********cont.Selected_Track_Account__c'+cont.Selected_Track_Account__c); 
         system.debug('*********cont.'+cont); 
         cont.Selected_Track_Account__c=leadObj.Partner_Account__c;
         update cont;
         system.debug('*********cont.Selected_Track_Account__c'+cont.Selected_Track_Account__c); */
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    //v5.0 End
    static testMethod void withEndCustomerTest() {
        //TriggerExecutionController.setSkipAllTriggers(true);
        testData();  //v5.0
        //TriggerExecutionController.setSkipAllTriggers(false);
        Test.StartTest();
        PageReference pageRef = new PageReference('/apex/CMAP_NewDealRTSelectionPage?leadId=' + leadObj.Id);
        Test.setCurrentPage(pageRef);
        CMAP_DealRTselectionController controller = new CMAP_DealRTselectionController(new ApexPages.StandardController(new Lead()));
        controller.strLeadId = leadObj.Id;
        controller.redirect();
        
        leadObj.Sales_Qualified__c = 'Qualified';
        update leadObj;
        controller = new CMAP_DealRTselectionController(new ApexPages.StandardController(new Lead()));
        controller.strLeadId = leadObj.Id;
         system.runAs(partnerUser1){
        String strNextPage = controller.redirect().getUrl();
        System.assert(strNextPage != NULL);
        }
        Test.StopTest();
    }
    
    static testMethod void dealRegwithoutEndCustomerTest() {
      //  TriggerExecutionController.setSkipAllTriggers(true);
          testData();  //v5.0
     //   TriggerExecutionController.setSkipAllTriggers(false);
        Test.StartTest();
        PageReference pageRef = new PageReference('/apex/CMAP_NewDealRTSelectionPage?leadId='+leadObj.Id);
        Test.setCurrentPage(pageRef);
        CMAP_DealRTselectionController controller = new CMAP_DealRTselectionController(new ApexPages.StandardController(new Lead()));
        controller.strLeadId = leadObj.Id;
        controller.getSelectedRecordType();
        controller.getRecordTypes();
        //controller.getrecordTypenames();
        controller.setSelectedRecordType('Register Deal with an End Customer');
        controller.continueButton();
        controller.cancelButton();
        controller.redirect();
        String strNextPage = controller.Continuebutton().getUrl();
        System.assert(strNextPage!= NULL);
        Test.StopTest();
    }
    
    static testMethod void dealRegwithEndCustomerTest() {
  
        //TriggerExecutionController.setSkipAllTriggers(true);
        testData();   //v5.0
        //TriggerExecutionController.setSkipAllTriggers(false);
        Test.StartTest();
        system.runAs(partnerUser1){
        PageReference pageRef = new PageReference('/apex/CMAP_NewDealRTSelectionPage?leadId='+leadObj.Id);
        Test.setCurrentPage(pageRef);
        CMAP_DealRTselectionController controller = new CMAP_DealRTselectionController(new ApexPages.StandardController(new Lead()));
        controller.strLeadId = leadObj.Id;
        controller.getSelectedRecordType();
        controller.getRecordTypes();
        //controller.getSelectedRecordType();
        controller.setSelectedRecordType('Register Deal without an End Customer');
        controller.continueButton();
        controller.cancelButton();
        String strNextPage = controller.Continuebutton().getUrl();
        System.assert(strNextPage!= NULL);
        }
        Test.StopTest();
    }
    
}