/*
REVISION HISTORY
======================================================================================================================
Version    Author    Date            Release#       CR#     Description
-------    ------    ----            --------    ---    -----------
1.0         vikas KH                0202            Implemented TDF
*/
@isTest
private class Channel_Email_Accepted_Leads_CtrlTest {
    Static list<Account> listAcc;
    static list<Contact> listCon;
    static list<Campaign> listCamp;
    static list<user> listuser;
    static list<user> listuser1;
    @testSetup Static void setup(){
        List<Account> listAccTDF = TestDataFactory.createNAccount(40,'Partner Account');
        insert listAccTDF;
        list<user> listuserTDF = TestDataFactory.createNPortalUser(40);
        listuserTDF[0].isActive=true;
        insert listuserTDF;
        list<user> listUserTDF1 = TestDataFactory.CreateNGenralUsers(1);
        insert listuserTDF1;
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(40, 'Campaign 2.0');
        insert listCampTDF;
    }
    static testMethod void thisUserLeadsTest(){
        TriggerExecutionController.setSkipAllTriggers(true);
 /*       Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
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
        */
        
  /*      List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%NA PRM%' order by CreatedDate DESC limit 1];
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
        */
        listAcc = [select id from Account limit 40];
        for(Integer intk=0;intk<40;intk++){
            for(Account acc:listAcc){
                Acc.Type= 'Partner';
            }
        }
        update listAcc;
        system.assertEquals(listAcc[0].Type, listAcc[0].Type);
        Test.startTest();
        listuser = [select id from user Where isActive=true limit 40];
   /*             for(Integer k=0;k<40;k++){

        listuser[0].Enable_notifications_about_Channel_Leads__c = true;
                }
        listuser1 = [select id from user WHERE Profile.Name like 'System Administrator' limit 1 ];
        
        System.RunAs(listuser[1]){
            update listuser;
        }
*/
        listCamp = [select id, name from Campaign limit 40];
 //       List<Campaign> lstCampaigns = new List<Campaign>();
 //       Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        for(Integer intm=0;intm<listUser.size();intm++){ 
            for(Campaign campObj: listCamp){
            campObj.Name='Campaign_CMAP'+intm;
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
            campObj.Allocation_Source__c = 'Dell Allocation';
            campObj.Nurture_Source__c = 'Dell Nurturing';                
            campObj.Total_Campaign_Targets_Planned__c = 1;
            campObj.Total_Value_Won_Opportunities_Planned__c = 1;
            campObj.Total_Value_Opportunities_Planned__c = 1;
            campObj.Partner_Campaign_Contact__c = listUser[intm].Id;
            campObj.Partner_Campaign_Contact_Email__c = 'test@test.com';
            campObj.Lead_Routing__c ='Dell Standard';
            }
        }
            update listCamp;
        
        Id dSGLeadRTId= IdLookupUtils.getRecordTypeId('DSG Partner','Lead',true);
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        
        //Channel Lead
        List<Lead> listLeads = new List<Lead>();
        for(Integer intn=0;intn<listCamp.size();intn++){
        Lead leadRec = new Lead();
        leadRec.lastName = 'Test Lead Record'+intn;
        leadRec.email ='testcmap1@cmaptest.com';
        leadRec.status = 'Assigned to Channel partner';
        leadRec.Phone='88967544'+intn;
        leadRec.Campaign__c  = listCamp[intn].Id;
        leadRec.Budget__c = 'No';
        leadRec.RecordTypeId = leadRTId;
        leadRec.Country = 'US';
        leadRec.Partner_Account__c = listAcc[intn].Id;
        leadRec.Solution_ProvIder_can_contact_me__c = FALSE;
        leadRec.Ready_For_Scoring__c = False;
        leadRec.Dell_Partner_can_contact_me__c = true;
        leadRec.Partner_User__c = listUser[intn].Id;
        leadRec.Lead_Score__c= 'Visitor (Contact registered for event / other online form but did not attend)';
        leadRec.Company = 'Test Company'+intn;
        leadRec.Status = 'Accepted By Channel Partner';
        leadRec.Send_email_for_Accepted_Status__c = true;
        listLeads.add(leadRec);
        }
        
        insert listLeads;
        TriggerExecutionController.setSkipAllTriggers(false);
        Channel_Email_Accepted_Leads_Ctrl objComp = new Channel_Email_Accepted_Leads_Ctrl();
        objComp.thisUserId = listUser[0].Id;
        objComp.thistypeOfEmail ='twoDay';
        objComp.getThisUserLeads();
        Test.stopTest();
    }
    
}