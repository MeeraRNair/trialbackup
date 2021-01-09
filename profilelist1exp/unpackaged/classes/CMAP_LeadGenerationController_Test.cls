/* 
REVISION HISTORY
================
Version    Author    Date            Release#    CR#    Description
-------    ------    ----            --------    ---    -----------
1.0        Bianca    09-Nov-2012     14.2        ---    Test class for CMAP_LeadGenerationController
2.0        Bianca    14-Nov-2012     14.2        ---    Modified the test method to include CMAP_TestDataGenerator test data
3.0        Afiq      18-Sep-2015     16.10       11982  Adding test logic for new field
4.0        Sakshi    09-Jul-2018                 16103  Fix test class issue
5.0        Sonali    27-Feb-2019     FY20-0402   17125  Fix PMD violations
6.0        Shue      19-Mar-2019     FY20-0402   ----   Partner Account assignement, test coverage fix
*/
@isTest
private class CMAP_LeadGenerationController_Test {

    static testMethod void myUnitTest() {
        //TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Helper.skipinsert = true;
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        
        //6.0 Start
        testData.getPartnerUser(true);
        testData.getAccount(true);
        testData.getCampaign(true);
        
        Partner_Campaign_Management__c accCampRecord = new Partner_Campaign_Management__c(
            //Partner_Account__c = testData.accountObj.Id,
            Partner_Account__c = testData.smaObj.Id,  //6.0
            //Partner_Account__c = listAcc[0].Id,  //6.0
            Campaign__c = testData.campObj.Id
        );
        insert accCampRecord;
        //6.0 End
        //TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        PageReference  pr = new PageReference('/apex/CMAP_LeadGenerationInterface');
        Test.setCurrentPage(pr);
        Test.stopTest(); 
    }

    static testMethod void myEndCustomerUnitTest() {
        CMAP_Helper.skipinsert = true;
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        Test.startTest();
        testData.getPartnerUser(true);
        testData.getAccount(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        Account newAccount =new Account(name='Test',Type = 'Partner', RecordTypeId = accRTId,Master_Group_Id__c= testData.accountObj.Id);
        PamCMAPutilityClass.getUserssUnderSalesMotion(newAccount);
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        Campaign newCampaigns = new Campaign();
        newCampaigns = new Campaign(Name='Campaign_CMAP',
                    //Campaign_Objective__c='Acquisition/Site Development',
                    Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                    Region__c='ABU',                        
                    Follow_Up_Role__c='Account Executive',
                    Description='Test',StartDate=system.today(),EndDate=system.today(),
                    status='In Progress',
                    Country_Code__c = 'BR - Brazil',
                    Partner_Event_or_Campaign__c = False,
                    IsActive = true,
                    Allocation_Source__c = 'Dell Allocation ABU',
                    Nurture_Source__c = 'Dell Nurturing',
                    Total_Campaign_Targets_Planned__c = 1,
                    Total_Value_Won_Opportunities_Planned__c = 1,
                    Total_Value_Opportunities_Planned__c = 1,
                    Partner_Campaign_Contact_Email__c = 'test@test.com');
        insert newCampaigns;   
        End_Customer__c endCustomer = new End_Customer__c(
                                        //Partner_Account__c = testData.accountObj.Id,
                                        Partner_Account__c = testData.smaObj.Id,  //6.0
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
        Partner_Campaign_Management__c accCampRecord = new Partner_Campaign_Management__c(
                                        //Partner_Account__c = testData.accountObj.Id,
                                        Partner_Account__c = testData.smaObj.Id,  //6.0
                                        Campaign__c = newCampaigns.Id                                         
                                        );
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User sysAdmin = [SELECT id FROM User WHERE profileId =: p.id and IsActive=true LIMIT 1];
        System.runAs(sysAdmin){
            insert AccCampRecord ;
        }
        Test.stopTest();
        PageReference  pr = new PageReference('/apex/CMAP_LeadGenerationInterface?eCusId='+endCustomer.Id);
        Test.setCurrentPage(pr);
        

        //System.runAs(PartnerUser) {
        System.runAs(testData.PartnerUser) {
            CMAP_LeadGenerationController controller= new CMAP_LeadGenerationController(new ApexPages.StandardController(new Lead()));
            controller.eCusId = endCustomer.Id;
            //controller.selcampId =testData.campObj.Id; 
            controller.getcampaignName();
            //controller.getcampaignName();
            controller.getCampaignList();
            controller.first();
            controller.next();
            controller.previous();
            controller.last();    
            controller.con.getHasNext();
            controller.con.getHasPrevious();
            controller.con.getPageNumber();
            
            controller.submitSingleLeadButton(); 
            controller.submitMultipleLeadsButton(); 
            /*String nextPage3 = controller.continueButton().getUrl();
            System.assert(nextPage3!= NULL);*/
       }
    }
}