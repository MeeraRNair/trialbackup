/*
REVISION HISTORY
======================================================================================================================
* Revision CR Number   Release No    Date            Modified By     Description
* -------- ---------   ------------  -----------     ------------    -----------
  1.0                                                                created
  2.0      CR12720    FY17-DCS-0401  15-March-2016    Azwanti        replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
  3.0      CR12720    FY17-DCS-0701  30-May-2016      Sui Yee        replace RecordTypeId'Campaign 2.0'& lead 2.0 mandatory field.
  4.0      CR16091    FY19-DCS-0802  27-June-2018     Pallavi        reduced the code size as part of code reducing story 5101935
*/
@isTest
private class CMAP_PartnerDailySummaryBatchScedulrTest {
     
    static testMethod void myTest_Day_DSG(){
        TriggerExecutionController.setSkipAllTriggers(true);
        String str = 'today';
        set<Id> setId = new set<Id>();
        Boolean bool = true;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> lstAccount = new List<Account>();
        for(Integer k=0;k<40;k++){
            Account accountObj = new Account(name='Test'+k,Type = 'Partner', RecordTypeId = accRTId );
            lstAccount.add(accountObj);
        }
        insert lstAccount;
        
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0;i<lstAccount.size();i++){
            Contact cont = new Contact();
            cont.FirstName='TestContact1'+i;
            cont.LastName='TestContactlast1'+system.now().millisecond()+i; 
            cont.accountId=lstAccount[i].Id;
            cont.Email='TestContact1_'+i+ system.now().millisecond() +'@ust-global.com';
            cont.fax='01987645'+i;
            cont.MobilePhone= String.valueOf(Math.round(Math.random()*1000)) + '0'+i +system.now().millisecond();
            cont.Status__c = 'Marketing Suspect';
            cont.Phone= String.valueOf(Math.round(Math.random()*1000)) + '0'+i +system.now().millisecond();
            lstContact.add(cont);
        }
        insert lstContact;
           
        List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%NA PRM%' order by CreatedDate DESC limit 1];
        List<User> lstUsers = new List<User>();
        for(Integer j=0;j<lstContact.size();j++){     
            User partnerUser = new User();
            partnerUser.Username ='test765'+j + System.currentTimeMillis() + '@dell.com';
            partnerUser.Alias = 'test1'+j;
            partnerUser.Email='test3445@dell.com'; 
            partnerUser.FirstName='John';
            partnerUser.LastName='Doe'+j;
            partnerUser.ProfileId = partnerProfiles[0].Id;
            partnerUser.LanguageLocaleKey='en_US';
            partnerUser.LocaleSidKey='en_US';
            partnerUser.EmailEncodingKey='UTF-8';
            partnerUser.TimeZoneSidKey='America/Los_Angeles';
            partnerUser.Badge_Number__c='10108999'+system.now().millisecond()+j;
            partnerUser.isActive = TRUE;
            partnerUser.Enable_Partner_Lead_Management__c = true;
            partnerUser.Enable_Partner_Deal_Registration__c = true;
            partnerUser.Enable_notifications_about_Channel_Leads__c = true; 
            partnerUser.ContactId = lstContact[j].id;
            lstUsers.add(partnerUser);
        }
        Profile objProfile = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        User objeUser = [Select Id from User where Id !=: UserInfo.getUserId() and IsActive=true and ProfileId =:objProfile.Id Limit 1];
        System.RunAs(objeUser){
        insert lstUsers;
        }
        
        for(user usr : lstUsers){
            setId.add(usr.id);
        }
        
                List<Campaign> lstCampaigns = new List<Campaign>();
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        for(Integer m=0;m<lstUsers.size();m++){ 
            Campaign campObj = new Campaign();
            campObj.Name='Campaign_CMAP'+m;
            campObj.Campaign_Objective__c='Acquisition/Site Development';
            campObj.Type='Advisory Councils';
            campObj.Segment_Business_Unit__c='SMB';
            campObj.Region__c='ABU';
            campObj.Follow_Up_Role__c='Account Executive';                                
            campObj.Description='Test';        
            campObj.StartDate=system.today();
            campObj.EndDate=system.today();
            campObj.status='In Progress';
            campObj.Country_Code__c = 'BR - Brazil';
            campObj.Partner_Event_or_Campaign__c = TRUE;
            campObj.IsActive = true;
            campObj.RecordTypeId = campRTId;
            campObj.Allocation_Source__c = 'Dell Allocation';
            campObj.Nurture_Source__c = 'Dell Nurturing';                
            campObj.Total_Campaign_Targets_Planned__c = 1;
            campObj.Total_Value_Won_Opportunities_Planned__c = 1;
            campObj.Total_Value_Opportunities_Planned__c = 1;
            campObj.Partner_Campaign_Contact__c = lstUsers[m].Id;
            campObj.Partner_Campaign_Contact_Email__c = 'test@test.com';
            campObj.Lead_Routing__c ='Dell Standard';
            lstCampaigns.add(campObj);
        }
        insert lstCampaigns;
        
        Id DSGLeadRTId= IdLookupUtils.getRecordTypeId('DSG Partner','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        
        TriggerExecutionController.setSkipAllTriggers(false);
        CMAP_PartnerDailySummaryBatch reassignDailySummaryBatch = new CMAP_PartnerDailySummaryBatch();
        reassignDailySummaryBatch.type='today';
        reassignDailySummaryBatch.query = 'Select Id, RecordTypeId,Lead_Assigned_Date__c, Partner_User__c,Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' order by Partner_User__c';
        reassignDailySummaryBatch.prepareDailySummaryMail(str,setId,bool);
        Database.executeBatch(reassignDailySummaryBatch);
        
        //Pallavi- added the below statements as part of code reduce
        //for 2days
        String str1 = 'twoday';
        CMAP_PartnerDailySummaryBatch reassignDailySummaryBatch1 = new CMAP_PartnerDailySummaryBatch();
        reassignDailySummaryBatch1.type='twoDay';
        reassignDailySummaryBatch1.query = 'Select Id, RecordTypeId, Lead_Assigned_Date__c, Partner_User__c,Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' order by Partner_User__c';
        reassignDailySummaryBatch1.prepareDailySummaryMail(str1,setId,bool);
        Database.executeBatch(reassignDailySummaryBatch1);
        
        //for 5days
        String str2 = 'fiveday';
        Boolean bool1 = false;
        CMAP_PartnerDailySummaryBatch reassignDailySummaryBatch2 = new CMAP_PartnerDailySummaryBatch();
        reassignDailySummaryBatch2.type='fiveDay';
        reassignDailySummaryBatch2.query = 'Select Id, RecordTypeId, Lead_Assigned_Date__c, Partner_User__c,Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' order by Partner_User__c';
        reassignDailySummaryBatch2.prepareDailySummaryMail(str2,setId,bool1);
        Database.executeBatch(reassignDailySummaryBatch2);
    }
       
    static testMethod void myTest_Days(){
        TriggerExecutionController.setSkipAllTriggers(true);
        String str = 'twoday';
        set<Id> setId = new set<Id>();
        Boolean bool = false;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> lstAccount = new List<Account>();
        for(Integer k=0;k<40;k++){
            Account accountObj = new Account(name='Test'+k,Type = 'Partner', RecordTypeId = accRTId );
            lstAccount.add(accountObj);
        }
        
        insert lstAccount;
         
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0;i<lstAccount.size();i++){
            Contact cont = new Contact();
            cont.FirstName='TestContact1'+i;
            cont.LastName='TestContactlast1'+system.now().millisecond()+i; 
            cont.accountId=lstAccount[i].Id;
            cont.Email='TestContact1_'+i+ system.now().millisecond() +'@ust-global.com';
            cont.fax='01987645'+i;
            cont.MobilePhone= String.valueOf(Math.round(Math.random()*1000)) + '0'+i +system.now().millisecond();
            cont.Status__c = 'Marketing Suspect';
            cont.Phone= String.valueOf(Math.round(Math.random()*1000)) + '0'+i +system.now().millisecond();
            lstContact.add(cont);
        }
        insert lstContact;
        
        List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%NA PRM%' order by CreatedDate DESC limit 1];
        List<User> lstUsers = new List<User>();
        for(Integer j=0;j<lstContact.size();j++){     
            User partnerUser = new User();
            partnerUser.Username ='test765'+j + System.currentTimeMillis() + '@dell.com';
            partnerUser.Alias = 'test1'+j;
            partnerUser.Email='test3445@dell.com'; 
            partnerUser.FirstName='John';
            partnerUser.LastName='Doe'+j;
            partnerUser.ProfileId = partnerProfiles[0].Id;
            partnerUser.LanguageLocaleKey='en_US';
            partnerUser.LocaleSidKey='en_US';
            partnerUser.EmailEncodingKey='UTF-8';
            partnerUser.TimeZoneSidKey='America/Los_Angeles';
            partnerUser.Badge_Number__c='10108999'+system.now().millisecond()+j;
            partnerUser.isActive = TRUE;
            partnerUser.Enable_Partner_Lead_Management__c = true;
            partnerUser.Enable_Partner_Deal_Registration__c = true;
            partnerUser.Enable_notifications_about_Channel_Leads__c = true; 
            partnerUser.ContactId = lstContact[j].id;
            
            partnerUser.Enable_notifications_about_Channel_Leads__c = true;
            lstUsers.add(partnerUser);
        }
        Profile objProfile = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        User objeUser = [Select Id from User where Id !=: UserInfo.getUserId() and IsActive=true and ProfileId =:objProfile.Id Limit 1];
        System.RunAs(objeUser){
        insert lstUsers;
        }
        
        for(user usr : lstUsers){
            setId.add(usr.id);
        }
        
                List<Campaign> lstCampaigns = new List<Campaign>();
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        for(Integer m=0;m<lstUsers.size();m++){ 
            Campaign campObj = new Campaign();
            campObj.Name='Campaign_CMAP'+m;
            campObj.Campaign_Objective__c='Acquisition/Site Development';
            campObj.Type='Advisory Councils';
            campObj.Segment_Business_Unit__c='SMB';
            campObj.Region__c='ABU';
            campObj.Follow_Up_Role__c='Account Executive';                                
            campObj.Description='Test';        
            campObj.StartDate=system.today();
            campObj.EndDate=system.today();
            campObj.status='In Progress';
            campObj.Country_Code__c = 'BR - Brazil';
            campObj.Partner_Event_or_Campaign__c = TRUE;
            campObj.IsActive = true;
            campObj.RecordTypeId = campRTId;
            campObj.Allocation_Source__c = 'Dell Allocation';
            campObj.Nurture_Source__c = 'Dell Nurturing';                
            campObj.Total_Campaign_Targets_Planned__c = 1;
            campObj.Total_Value_Won_Opportunities_Planned__c = 1;
            campObj.Total_Value_Opportunities_Planned__c = 1;
            campObj.Partner_Campaign_Contact__c = lstUsers[m].Id;
            campObj.Partner_Campaign_Contact_Email__c = 'test@test.com';
            campObj.Lead_Routing__c ='Dell Standard';
            lstCampaigns.add(campObj);
        }
        insert lstCampaigns;
        
        Id DSGLeadRTId= IdLookupUtils.getRecordTypeId('DSG Partner','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        
        //Channel Lead
        List<Lead> lstLeads = new List<Lead>();
        for(Integer n=0;n<lstCampaigns.size();n++){
        Lead leadRec = new Lead();
        leadRec.lastName = 'Test Lead Record'+n;
        leadRec.email ='testcmap1@cmaptest.com';
        leadRec.status = 'Assigned to Channel partner';
        leadRec.Phone='88967544'+n;
        leadRec.Campaign__c  = lstCampaigns[n].Id;
        leadRec.Budget__c = 'No';
        leadRec.RecordTypeId = leadRTId;
        leadRec.Country = 'US';
        leadRec.Partner_Account__c = lstAccount[n].Id;
        leadRec.Solution_ProvIder_can_contact_me__c = FALSE;
        leadRec.Ready_For_Scoring__c = False;
        leadRec.Dell_Partner_can_contact_me__c = true;
        leadRec.Partner_User__c = lstUsers[n].Id;
        leadRec.Lead_Score__c= 'Visitor (Contact registered for event / other online form but did not attend)';
        leadRec.Company = 'Test Company'+n;
        leadRec.Status = 'Accepted By Channel Partner';
        leadRec.Send_email_for_Accepted_Status__c = true;
        lstLeads.add(leadRec);
        }
        
        insert lstLeads;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        //Pallavi- added the below statements as part of code reduce
        //for 1day
        String str4 = 'today';
        Batch_Weekly_Email_Controller objComp2 = new Batch_Weekly_Email_Controller();
        objComp2.thisUserId = lstUsers[0].Id;
        objComp2.thistypeOfEmail ='today';
        objComp2.getThisUserLeads();
        CMAP_PartnerDailySummaryBatch testDailySummaryBatch = new CMAP_PartnerDailySummaryBatch();
        testDailySummaryBatch.type='today';
        testDailySummaryBatch.query = 'Select Id, RecordTypeId, Lead_Assigned_Date__c, Partner_User__c,Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' order by Partner_User__c';
        testDailySummaryBatch.prepareDailySummaryMail(str4,setId,bool);
        Database.executeBatch(testDailySummaryBatch);
        
        //for 2days
        Batch_Weekly_Email_Controller objComp = new Batch_Weekly_Email_Controller();
        objComp.thisUserId = lstUsers[0].Id;
        objComp.thistypeOfEmail ='twoDay';
        objComp.getThisUserLeads();
        CMAP_PartnerDailySummaryBatch reassignDailySummaryBatch = new CMAP_PartnerDailySummaryBatch();
        reassignDailySummaryBatch.type='twoDay';
        reassignDailySummaryBatch.query = 'Select Id, RecordTypeId, Lead_Assigned_Date__c, Partner_User__c,Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' order by Partner_User__c';
        reassignDailySummaryBatch.prepareDailySummaryMail(str,setId,bool);
        Database.executeBatch(reassignDailySummaryBatch);
        
        //for 5days
        String str3 = 'fiveday';
        Batch_Weekly_Email_Controller objComp1 = new Batch_Weekly_Email_Controller();
        objComp1.thisUserId = lstUsers[0].Id;
        objComp1.thistypeOfEmail ='fiveDay';
        objComp1.getThisUserLeads();
        CMAP_PartnerDailySummaryBatch reassignDailySummaryBatch3 = new CMAP_PartnerDailySummaryBatch();
        reassignDailySummaryBatch3.type='fiveDay';
        reassignDailySummaryBatch3.query = 'Select Id, RecordTypeId,  Lead_Assigned_Date__c, Partner_User__c,Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' order by Partner_User__c';
        reassignDailySummaryBatch3.prepareDailySummaryMail(str3,setId,bool);
        Database.executeBatch(reassignDailySummaryBatch3);  
        
    }
    
    static testMethod void myTest_NullDays(){
        TriggerExecutionController.setSkipAllTriggers(true);
        String str = Null;
        set<Id> setId = new set<Id>();
        Boolean bool = false;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> lstAccount = new List<Account>();
        for(Integer k=0;k<40;k++){
            Account accountObj = new Account(name='Test'+k,Type = 'Partner', RecordTypeId = accRTId );
            lstAccount.add(accountObj);
        }
        
        insert lstAccount;
             
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0;i<lstAccount.size();i++){
            Contact cont = new Contact();
            cont.FirstName='TestContact1'+i;
            cont.LastName='TestContactlast1'+system.now().millisecond()+i; 
            cont.accountId=lstAccount[i].Id;
            cont.Email='TestContact1_'+i+ system.now().millisecond() +'@ust-global.com';
            cont.fax='01987645'+i;
            cont.MobilePhone= String.valueOf(Math.round(Math.random()*1000)) + '0'+i +system.now().millisecond();
            cont.Status__c = 'Marketing Suspect';
            cont.Phone= String.valueOf(Math.round(Math.random()*1000)) + '0'+i +system.now().millisecond();
            lstContact.add(cont);
        }
        insert lstContact;
                
        List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%NA PRM%' order by CreatedDate DESC limit 1];
        List<User> lstUsers = new List<User>();
        for(Integer j=0;j<lstContact.size();j++){     
            User partnerUser = new User();
            partnerUser.Username ='test765'+j + System.currentTimeMillis() + '@dell.com';
            partnerUser.Alias = 'test1'+j;
            partnerUser.Email='test3445@dell.com'; 
            partnerUser.FirstName='John';
            partnerUser.LastName='Doe'+j;
            partnerUser.ProfileId = partnerProfiles[0].Id;
            partnerUser.LanguageLocaleKey='en_US';
            partnerUser.LocaleSidKey='en_US';
            partnerUser.EmailEncodingKey='UTF-8';
            partnerUser.TimeZoneSidKey='America/Los_Angeles';
            partnerUser.Badge_Number__c='10108999'+system.now().millisecond()+j;
            partnerUser.isActive = TRUE;
            partnerUser.Enable_Partner_Lead_Management__c = true;
            partnerUser.Enable_Partner_Deal_Registration__c = true;
            partnerUser.Enable_notifications_about_Channel_Leads__c = true; 
            partnerUser.ContactId = lstContact[j].id;
            lstUsers.add(partnerUser);
        }
        Profile objProfile = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        User objeUser = [Select Id from User where Id !=: UserInfo.getUserId() and IsActive=true and ProfileId =:objProfile.Id Limit 1];
        System.RunAs(objeUser){
        insert lstUsers;
        }
        
        for(user usr : lstUsers){
            setId.add(usr.id);
        }
        
                List<Campaign> lstCampaigns = new List<Campaign>();
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        for(Integer m=0;m<lstUsers.size();m++){ 
            Campaign campObj = new Campaign();
            campObj.Name='Campaign_CMAP'+m;
            campObj.Campaign_Objective__c='Acquisition/Site Development';
            campObj.Type='Advisory Councils';
            campObj.Segment_Business_Unit__c='SMB';
            campObj.Region__c='ABU';
            campObj.Follow_Up_Role__c='Account Executive';                                
            campObj.Description='Test';        
            campObj.StartDate=system.today();
            campObj.EndDate=system.today();
            campObj.status='In Progress';
            campObj.Country_Code__c = 'BR - Brazil';
            campObj.Partner_Event_or_Campaign__c = TRUE;
            campObj.IsActive = true;
            campObj.RecordTypeId = campRTId;
            campObj.Allocation_Source__c = 'Dell Allocation';
            campObj.Nurture_Source__c = 'Dell Nurturing';                
            campObj.Total_Campaign_Targets_Planned__c = 1;
            campObj.Total_Value_Won_Opportunities_Planned__c = 1;
            campObj.Total_Value_Opportunities_Planned__c = 1;
            campObj.Partner_Campaign_Contact__c = lstUsers[m].Id;
            campObj.Partner_Campaign_Contact_Email__c = 'test@test.com';
            campObj.Lead_Routing__c ='Dell Standard';
            lstCampaigns.add(campObj);
        }
        insert lstCampaigns;
        
        Id DSGLeadRTId= IdLookupUtils.getRecordTypeId('DSG Partner','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        
        //Channel Lead
        List<Lead> lstLeads = new List<Lead>();
        for(Integer n=0;n<lstCampaigns.size();n++){
        Lead leadRec = new Lead();
        leadRec.lastName = 'Test Lead Record'+n;
        leadRec.email ='testcmap1@cmaptest.com';
        leadRec.status = 'Assigned to Channel partner';
        leadRec.Phone='88967544'+n;
        leadRec.Campaign__c  = lstCampaigns[n].Id;
        leadRec.Budget__c = 'No';
        leadRec.RecordTypeId = leadRTId;
        leadRec.Country = 'US';
        leadRec.Partner_Account__c = lstAccount[n].Id;
        leadRec.Solution_ProvIder_can_contact_me__c = FALSE;
        leadRec.Ready_For_Scoring__c = False;
        leadRec.Dell_Partner_can_contact_me__c = true;
        leadRec.Partner_User__c = lstUsers[n].Id;
        leadRec.Lead_Score__c= 'Visitor (Contact registered for event / other online form but did not attend)';
        leadRec.Company = 'Test Company'+n;
        lstLeads.add(leadRec);
        }
        
        insert lstLeads;
        TriggerExecutionController.setSkipAllTriggers(false);
        CMAP_PartnerDailySummaryBatch reassignDailySummaryBatch = new CMAP_PartnerDailySummaryBatch();
        reassignDailySummaryBatch.type=null;
        reassignDailySummaryBatch.query = 'Select Id, RecordTypeId, Lead_Assigned_Date__c, Partner_User__c,Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' order by Partner_User__c';
        reassignDailySummaryBatch.prepareDailySummaryMail(str,setId,bool);
        Database.executeBatch(reassignDailySummaryBatch);       
    }
      
    static testMethod void SchedulerTest() {
       Test.startTest();
        String CRON_EXP = '0 0 0 * * ?';
        CMAP_PartnerDailySummaryScheduler  sch = new CMAP_PartnerDailySummaryScheduler();
        String jobId = System.schedule('batchWeeklyEmail TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }   
}