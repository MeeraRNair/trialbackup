/*
REVISION HISTORY
======================================================================================================================
Version    Author    Date            Release#          CR#    Description
-------    ------    ----            --------          ---    -----------
1.0        Vasavi.M  14-Dec-2016     FY17-DCS-0103     13807   Fix the mandatory fields issue with camapaign record and recordtype
2.0        Sriram    26-May-2017     FY18-DCS-0702     14401   Non SSO  Profile Clean Up
3.0        Azwanti   18-Jul-2017     FY18-DCS-0802     14454 remove Lead Qualification
*/
@isTest
private class CMAP_overrideCloneController_Test {
     /*static testMethod void cloneRedirect(){
        Test.startTest();
        Triggerexecutioncontroller.setSkipAllTriggers(True); 
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        Id CampaignRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //1.0
        CMAP_Helper.skipinsert = true;
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where name like 'System Administrator' 
                                               limit 1];   
        user usr=new user(Username='shaundell1001@acme.com',
                     Alias = 'CloneSA', 
                     Email='testleadclone@dell.com', 
                     FirstName='Johns',LastName='DoewHello',
                     LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8',
                     TimeZoneSidKey='America/Los_Angeles',
                     //Enable_As_Partner_Lead_Super_User__c = TRUE, 
                     IsActive =TRUE,Badge_Number__c='CloneSA',
                     ProfileId=partnerProfiles[0].Id); 
        insert usr;
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                //1.0 Start
                Lead_Routing__c = 'Not Applicable',
                Partner_Campaign_Contact__c = usr.id,
                Partner_Campaign_Contact_Email__c = 'test@mail.com',
                RecordTypeId= CampaignRTId);
                //1.0 End
               // RecordTypeId='012A0000000VnHF' );
         insert campDirectObj;
         
         Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');
        insert leadObj;
        PageReference  pr = new PageReference('/apex/CMAP_overrideCloneButton?clone=1&retURL='+leadObj.Id+'&scontrolCaching=1&sfdc.override=1&id='+leadObj.Id);
        Test.setCurrentPage(pr);
        System.runAs(usr) {
           CMAP_overrideCloneController cntrlr = new CMAP_overrideCloneController(new ApexPages.StandardController(new Lead()));           
            cntrlr.redirect();          
        }
        Triggerexecutioncontroller.setSkipAllTriggers(false); 
        Test.stopTest();
    }*/
    static testMethod void cloneRedirectbySales(){
        Test.startTest();
        Triggerexecutioncontroller.setSkipAllTriggers(True); 
        Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        Id CampaignRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //1.0
        CMAP_Helper.skipinsert = true;
        //CR 14401 -Start
       /* final List<Profile> userProfiles = [select id,name from Profile 
                                               where name like '%GBL Sales Rep - Non SSO%' limit 1];  */
       final List<Profile> userProfiles = [select id,name from Profile 
                                               where name like '%GBL Sales Rep%' limit 1];
        //CR 14401 -End
        user usr=new user(Username='shaun@acmeclone.com',
                     Alias = 'Clone', 
                     Email='testcloning@dell.com', 
                     FirstName='Johns',LastName='DoewHello',
                     LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8',
                     TimeZoneSidKey='America/Los_Angeles',
                     IsActive =TRUE,Badge_Number__c='Clone',
                     ProfileId=userProfiles[0].Id); 
        insert usr;
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = FALSE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                //1.0 Start
                Lead_Routing__c = 'Not Applicable',
                Partner_Campaign_Contact__c = usr.id,
                Partner_Campaign_Contact_Email__c = 'test@mail.com',
                RecordTypeId= CampaignRTId);
                //1.0 End
         insert campDirectObj;
         Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');
        insert leadObj;
        PageReference  pr = new PageReference('/apex/CMAP_overrideCloneButton?clone=1&retURL='+leadObj.Id+'&scontrolCaching=1&sfdc.override=1&id='+leadObj.Id);
        Test.setCurrentPage(pr);
        System.runAs(usr) {
            CMAP_overrideCloneController cntrlr = new CMAP_overrideCloneController(new ApexPages.StandardController(new Lead()));           
            cntrlr.okbutton = true;
            cntrlr.redirect();
            cntrlr.okbuttonAction();        
        }
        
           CMAP_overrideCloneController cntrlr1 = new CMAP_overrideCloneController(new ApexPages.StandardController(new Lead()));           
           cntrlr1.okbutton = true;
           cntrlr1.redirect();
           cntrlr1.okbuttonAction();
                
        Triggerexecutioncontroller.setSkipAllTriggers(false); 
        Test.stopTest();
    }
}