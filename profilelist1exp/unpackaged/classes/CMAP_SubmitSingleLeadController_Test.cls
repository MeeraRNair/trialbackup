/* 
REVISION HISTORY
================
Version     Author      Date            Release#    	CR#     Description
-------     ------      ----            --------    	---     -----------
1.0         Jiji        11-Nov-2012     14.2         	--     Test class for CMAP_SubmitSingleLead.
2.0        Anamika      12-Jan-2014     16.03         	10741   handling VR exception for field Partner_Campaign_Contact_Email__c
3.0			Azwanti		16-May-2016		FY17-DCS-0602	13147	LM2_6-Fix Test Class Impacted on Campaign RT Deactivated (Part 2)
*/
@isTest
private class   CMAP_SubmitSingleLeadController_Test {

     static testMethod void WithoutEndCustomerTest() {
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        CMAP_Helper.skipinsert = true;
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
       
        Contact newCont = new Contact(FirstName='TestContactFN9',
                 LastName='TestContactLN9',
                 accountId=newAcc.Id,
                 Email='TestContactEmail9@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 Status__c = 'Marketing Suspect',
                 Phone='0000000');
        insert newCont;
        
       final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
                                               
       User partnerUser = new User(
                    Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'tt2', 
                    Email='MyTest009@dell.com', 
                    FirstName='MyTestUser09', 
                    LastName='MyTestUser09',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    ContactId = newCont.id
                );
       insert partnerUser;
       
       Campaign newCampgn = new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing', 
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact__c = partnerUser.Id,
                 Partner_Campaign_Contact_Email__c = 'test@test.com'); //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c(Campaign__c = newCampgn.Id,
                                                                                Partner_Account__c = newAcc.Id
                                                                                );
        insert pcm;
        System.runAs(partnerUser){
            PageReference  pr = new PageReference('/apex/CMAP_SubmitSingleLead?campId='+newCampgn.Id);//+'&campName='+testData.campObj.Name);
            Test.setCurrentPage(pr);
            
            CMAP_SubmitSingleLeadController controller = new CMAP_SubmitSingleLeadController(new ApexPages.StandardController(new Lead()));
            controller.myLead.Company = 'Test Company';
            controller.myLead.Country = 'Test Country';
            controller.myLead.FirstName = 'Test First Name';
            controller.myLead.LastName = 'Test Last Name';
            controller.myLead.Email = 'Test@email.com';
            controller.getshowSaveContactCheckbox();
            controller.getmylead();
            controller.nextButton();
            controller.myLead.Phone = '9999999999';
            controller.nextButton();
            controller.submitButton();
            controller.displaySuccessMsg();
        }
        List<Lead> newLeads = [select id, Name, Status, Campaign__c from Lead where //Id = :myLead.Id
                        Company = 'Test Company' 
                        and Country = 'Test Country' 
                        and email = 'Test@email.com' 
                        and LastName = 'Test Last Name'
                        and FirstName = 'Test First Name'
                       ];
        if(newLeads.Size() > 0){
            System.assertNotEquals(newLeads[0],NULL);
            System.assertEquals(newLeads[0].Status,'Open - Channel Lead');
            System.assertEquals(newLeads[0].Campaign__c,newCampgn.Id);
        }
    }
    static testMethod void WithEndCustomerTest() {
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        CMAP_Helper.skipinsert = true;
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
              
        Contact newCont = new Contact(FirstName='TestContactFN9',
                 LastName='TestContactLN9',
                 accountId=newAcc.Id,
                 Email='TestContactEmail9@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 Status__c = 'Marketing Suspect',
                 Phone='0000000');
        insert newCont;
        
       final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
                                               
       User partnerUser = new User(
                    Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'tt2', 
                    Email='MyTest009@dell.com', 
                    FirstName='MyTestUser09', 
                    LastName='MyTestUser09',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    ContactId = newCont.id
                );
       insert partnerUser;
       
       Campaign newCampgn = new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact__c = partnerUser.Id,
                 Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c(Campaign__c = newCampgn.Id,
                                                                                Partner_Account__c = newAcc.Id
                                                                                );
        insert pcm;
        End_Customer__c endCustomer = new End_Customer__c(
                                        Partner_Account__c = newAcc.Id,
                                        Name = 'Test Company1',
                                        Mailing_city__c = 'Test City' ,
                                        Mailing_country__c = 'Test Country1',
                                        Mailing_State__c = 'Test State',
                                        Mailing_street__c = 'Test Street',
                                        Status__c ='Active',
                                        Website__c = 'www.salesforce.com',
                                        Zip_Code__c = '664455',
                                        Account_Industry__c = 'Agriculture'
                                        
                                        );
        insert endCustomer ;
        System.runAs(partnerUser){
            PageReference  pr = new PageReference('/apex/CMAP_SubmitSingleLead?campId='+newCampgn.Id);
            Test.setCurrentPage(pr);
            
            CMAP_SubmitSingleLeadController controller = new CMAP_SubmitSingleLeadController(new ApexPages.StandardController(new Lead()));
            controller.ldObj.Search_My_Customer__c = endCustomer.Id;
            controller.populateCompanyInfo();
            controller.ldObj.Search_My_Customer_Contact__c = NULL;
            controller.myLead.Save_Contact_Details_for_selected_Custom__c = TRUE;
            controller.myLead.FirstName = 'Test First Name1';
            controller.myLead.LastName = 'Test Last Name1';
            controller.nextButton();
            controller.myLead.Email = 'Test@email1.com';
            controller.myLead.Phone = '9999999999';
            controller.getmylead();
            controller.nextButton();
            controller.submitButton();
            controller.displaySuccessMsg();
        }
        List<Lead> newLeadcreated = [select id, Name, Status,Campaign__c  from Lead where //Id = :myLead.Id
                        Company = 'Test Company1' 
                        and Country = 'Test Country1' 
                        and email = 'Test@email1.com' 
                        and LastName = 'Test Last Name1'
                        and FirstName = 'Test First Name1'
                         ];
        if(newLeadcreated.Size() > 0){
            System.assertNotEquals(newLeadcreated[0] ,NULL);
            System.assertEquals(newLeadcreated[0].Status,'Open - Channel Lead');
            System.assertEquals(newLeadcreated[0].Campaign__c,newCampgn.Id);
        }
    }
    static testMethod void WithEndCustomerContactTest() {
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        CMAP_Helper.skipinsert = true;
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        
        Contact newCont = new Contact(FirstName='TestContactFN9',
                 LastName='TestContactLN9',
                 accountId=newAcc.Id,
                 Email='TestContactEmail9@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 Status__c = 'Marketing Suspect',
                 Phone='0000000');
        insert newCont;
        
       final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
                                               
       User partnerUser = new User(
                    Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'tt2', 
                    Email='MyTest009@dell.com', 
                    FirstName='MyTestUser09', 
                    LastName='MyTestUser09',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    ContactId = newCont.id
                );
       insert partnerUser;
       
       Campaign newCampgn = new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',    
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',                    
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact__c = partnerUser.Id,
                 Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c(Campaign__c = newCampgn.Id,
                                                                                Partner_Account__c = newAcc.Id
                                                                                );
        insert pcm;
        End_Customer__c endCustomer = new End_Customer__c(
                                        Partner_Account__c = newAcc.Id,
                                        Name = 'Test Company2',
                                        Mailing_city__c = 'Test City' ,
                                        Mailing_country__c = 'Test Country2',
                                        Mailing_State__c = 'Test State',
                                        Mailing_street__c = 'Test Street',
                                        Status__c ='Active',
                                        Website__c = 'www.salesforce.com',
                                        Zip_Code__c = '664455',
                                        Account_Industry__c = 'Agriculture'
                                      );
        insert endCustomer ;
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(
                                        Name = 'Test Contact',
                                        Last_Name__c = 'Test Last Name2',
                                        Email__c = 'Test@Email2.com',
                                        Fax__c = '243455',
                                        Phone__c = '23435466',
                                        Mobile__c ='324235566',
                                        End_Customer__c = endCustomer.Id,
                                        Title__c = 'Test Title',
                                        Status__c = 'Active'
                                        
                                        );
        insert endCustomerContact;
        System.runAs(partnerUser){
            PageReference  pr = new PageReference('/apex/CMAP_SubmitSingleLead?campId='+newCampgn.Id+'&campName='+newCampgn.Name+'&eCusId='+endCustomer.Id);
            Test.setCurrentPage(pr);
            
            CMAP_SubmitSingleLeadController controller = new CMAP_SubmitSingleLeadController(new ApexPages.StandardController(new Lead()));
            controller.ldObj.Search_My_Customer__c = endCustomer.Id;
            controller.populateCompanyInfo();
            controller.ldObj.Search_My_Customer_Contact__c = endCustomerContact.Id;
            controller.populateContactInfo();
            //controller.getshowSaveContactCheckbox();
            controller.getmylead();
            controller.nextButton();
            controller.submitButton();
            //controller.displaySuccessMsg();
        }
        List<Lead> newLeads = [select id, Name, Status, Campaign__c from Lead where //Id = :myLead.Id
                        Company = 'Test Company2' 
                        and Country = 'Test Country2' 
                        and email = 'Test@Email2.com' 
                        and LastName = 'Test Last Name2'
                        and Search_My_Customer__c = :endCustomer.Id
                        and Search_My_Customer_Contact__c = :endCustomerContact.Id
                        ];
        if(newLeads.Size() > 0){
            System.assertNotEquals(newLeads[0],NULL);
            System.assertEquals(newLeads[0].Status,'Open - Channel Lead');
            System.assertEquals(newLeads[0].Campaign__c,newCampgn.Id); 
        }
    }
    static testMethod void fromeCustomerTest() {
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        CMAP_Helper.skipinsert = true;
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;

       
        Contact newCont = new Contact(FirstName='TestContactFN9',
                 LastName='TestContactLN9',
                 accountId=newAcc.Id,
                 Email='TestContactEmail9@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 Status__c = 'Marketing Suspect',
                 Phone='0000000');
        insert newCont;
        
       final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
                                               
       User partnerUser = new User(
                    Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'tt2', 
                    Email='MyTest009@dell.com', 
                    FirstName='MyTestUser09', 
                    LastName='MyTestUser09',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE,
                    Enable_Partner_Lead_Management__c = TRUE,
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    ContactId = newCont.id
                );
       insert partnerUser;
       
       Campaign newCampgn = new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU', 
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',                       
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact__c = partnerUser.Id,
                 Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
        insert newCampgn;

        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c(Campaign__c = newCampgn.Id,
                                                                                Partner_Account__c = newAcc.Id
                                                                                );
        insert pcm;
        End_Customer__c endCustomer = new End_Customer__c(
                                        Partner_Account__c = newAcc.Id,
                                        Name = 'Test Company',
                                        Mailing_city__c = 'Test City' ,
                                        Mailing_country__c = 'Test Country',
                                        Mailing_State__c = 'Test State',
                                        Mailing_street__c = 'Test Street',
                                        Status__c ='Active',
                                        Website__c = 'www.salesforce.com',
                                        Zip_Code__c = '664455',
                                        Account_Industry__c = 'Agriculture'
                                      );
        insert endCustomer ;
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(
                                        Name = 'Test Contact',
                                        Last_Name__c = 'Test Last Name',
                                        Email__c = 'Test@Email.com',
                                        Fax__c = '243455',
                                        Phone__c = '23435466',
                                        Mobile__c ='324235566',
                                        End_Customer__c = endCustomer.Id,
                                        Title__c = 'Test Title',
                                        Status__c = 'Active'
                                        
                                        );
        insert endCustomerContact;
        System.runAs(partnerUser) {
            PageReference  pr = new PageReference('/apex/CMAP_SubmitSingleLead?campId='+newCampgn.Id+'&eCusId='+endCustomer.Id);
            Test.setCurrentPage(pr);
            
            CMAP_SubmitSingleLeadController controller = new CMAP_SubmitSingleLeadController(new ApexPages.StandardController(new Lead()));
            controller.ldObj.Search_My_Customer__c = endCustomer.Id;
            controller.populateCompanyInfo();
            controller.ldObj.Search_My_Customer_Contact__c = endCustomerContact.Id;
            controller.populateContactInfo();
            //controller.getshowSaveContactCheckbox();
            controller.getmylead();
            controller.nextButton();
            controller.previousButton();
            controller.submitButton();
            controller.displaySuccessMsg();
        }
        List<Lead> newLeads = [select id, Name, Status, Campaign__c from Lead where //Id = :myLead.Id
                        Search_My_Customer__c = :endCustomer.Id
                        and Search_My_Customer_Contact__c = :endCustomerContact.Id 
                        ];
       if(newLeads.Size() > 0){
            System.assertNotEquals(newLeads[0],NULL);
            System.assertEquals(newLeads[0].Status,'Open - Channel Lead');
            System.assertEquals(newLeads[0].Campaign__c,newCampgn.Id);
        }
        
    }
}