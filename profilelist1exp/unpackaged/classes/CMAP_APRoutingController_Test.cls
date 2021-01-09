/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      16144       FY19-0802   10-July-2018    Naga        Deleted duplicated and unused code as part of code clean up
 * 
 */
@isTest
private class CMAP_APRoutingController_Test {
   static CMAP_Queue_Settings__c objCust;
   static Lead CLleadObj;
   static Account_Play__c apRecord;
   static Contact newCMAPCont;
   static testMethod void testData(){
       Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id apRTId= IdLookupUtils.getRecordTypeId('GBL_Account_Play_RT_R10.10','Account_Play__c',true);
        Date dt = System.Today();
        Id u = userinfo.getUserId();
        Id CampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);
        CMAP_Helper.skipinsert = true;
        Account newCMAPAcc = new Account(name='MyTestAccountCMAP');
        insert newCMAPAcc;
   
   objCust = new CMAP_Queue_Settings__c();
   objCust.Queue_Id__c = '00GA0000002y6hl';
   objCust.Queue_Name__c = 'Channel_eClerx';
   objCust.Name ='Channel_eClerx';
   insert objCust;
                
   newCMAPCont = new Contact(Salutation = 'Mr.',
                 FirstName='MyTestContactCMAP',
                 LastName='MyTestContactCMAP',
                 Title = 'Test Title',
                 accountId=newCMAPAcc.Id,
                 Email='MyTestCMAPContactEmail_3@ust-global.com',
                 fax='9876543',
                 phone = '99888778',
                 MobilePhone='536389097',
                 Status__c = 'Prospect',
                 Last_Operation_Performed__c = 'testing',
                 MailingCountry = 'US', 
                 MailingCity='City Test',
                 MailingState = 'Test State',
                 MailingStreet = 'Test Street',
                 MailingPostalCode = '683520'
                 );
        insert newCMAPCont;
        Campaign CMAP_Channel_camp= new Campaign(Name='TestCampaign_CL',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Dell Allocation',
                Nurture_Source__c = 'Dell Nurturing',
                IsActive = true,
                RecordTypeId = CampRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  CMAP_Channel_camp;        
        Campaign CMAP_dirAP_camp= new Campaign(Name='TestCampaign_Direct',
                Campaign_Objective__c='Acquisition/Site Development',
                Vertical__c ='Consulting',
                StartDate=system.today(),
                EndDate=system.today(),
                Segment_Business_Unit__c='Channel',
                Business_Unit__c = 'LE - G500',
                Region__c='ABU',
                Follow_Up_Role__c='Account Executive',
                Solution__c = 'IS - Integrated Security',
                Account_Play__c = TRUE,
                Is_this_Account_Play_Campaign__c = TRUE,
                Account_Play_Expiry_Date__c = System.Today()+360,
                Type='Advisory Councils',
                Description='Test',
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                RecordTypeId = CampRTId, 
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
         insert  CMAP_dirAP_camp;
        apRecord = new Account_Play__c( recordTypeId = apRTId,
                                        Status__c = 'Requires Follow-Up',
                                        Account__c = newCMAPAcc.Id,
                                        Campaign__c = CMAP_dirAP_camp.Id,
                                        Primary_Contact__c = newCMAPCont.Id,
                                        Customer_Consents_to_Engage_Dell_Partner__c = TRUE,
                                        What_is_their_implementation_deadline__c = System.Today(),
                                        Roadblocks__c  = 'No Road Bloack',
                                        Desired_Outcome__c = 'OutCome',
                                        Estimated_Budget__c = 10922,
                                        Do_they_have_access_to_approved_funds__c = 'Yes', 
                                        Interested_in_DFS_funding__c='No',
                                        Account_Executive__c = u                    
                                     );
         insert apRecord;
       CLleadObj = new Lead(lastName = 'Test CL Lead1',
                            firstName = 'CMAP CL',
                            Salutation = 'Mr.',
                            MobilePhone = '098645678',
                            fax = '87687689',
                            Employees__c = '100 - 499',
                            Title = 'Consultant',
                            City = 'Test City',
                            State = 'Test State',
                            PostalCode = '9876545',
                            Account_Play__c = apRecord.Id,
                            Country ='US',
                            Dell_can_contact_me_in_the_future__c='Yes',
                            AnnualRevenue = 10187879,
                            Decision_Making_Role__c = 'Business User',
                            Questions_Comments__c = 'Test Customer Comments', 
                            Sales_Comments__c = 'Test Sales Comments', 
                            Marketing_Comments__c = 'Test Marketing Comments',
                            email ='testdircmap@cmaptest.com',
                            status = 'Qualified - Channel Ready',
                            Phone='88967544',
                            Origin__c = 'Channel Lead 2.0',
                            Campaign__c = CMAP_Channel_camp.Id,
                            recordTypeId = leadRTId,
                            Budget__c = 'Yes',
                            Purchase_Timeframe__c ='Immediate',
                            Company = 'Test Company');
        insert CLleadObj ;
        
   }
   static testMethod void routeAPToChannel() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();        
        testdata();
        Id newId;
        Id pContactId;       
        PageReference pref = new PageReference('/apex/CMAP_RouteAccountPlay?APId='+apRecord.Id);        
        Test.setCurrentPage(pref);
        CMAP_APRoutingController leadapRoutingCntrlr = new CMAP_APRoutingController (new ApexPages.StandardController(new Account_Play__c()));
        leadapRoutingCntrlr.apObj = apRecord ;
        leadapRoutingCntrlr.APId = apRecord.Id;
        leadapRoutingCntrlr.addToPermissionset();
        leadapRoutingCntrlr.redirect();
        leadapRoutingCntrlr.enableContinueButton();
        system.currentpagereference().getparameters().put('radioName',newCMAPCont.id);
        //leadapRoutingCntrlr.selUserId = newCMAPCont.Id;
        leadapRoutingCntrlr.first();
        leadapRoutingCntrlr.last();
        leadapRoutingCntrlr.previous();
        leadapRoutingCntrlr.next();
        leadapRoutingCntrlr.getContactDetails();
        leadapRoutingCntrlr.con.getHasNext();
        leadapRoutingCntrlr.con.getHasPrevious();
        leadapRoutingCntrlr.con.getPageNumber(); 
        leadapRoutingCntrlr.redirect();
        leadapRoutingCntrlr.newId= CLleadObj.Id;
        leadapRoutingCntrlr.pContactId = newCMAPCont.id;
        //leadapRoutingCntrlr.newContact();
        leadapRoutingCntrlr.cancelButton();
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
   }
   static testMethod void CommentsPLfromAPTOChannel() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        testData();
        Id newId;
        Id pContactId;
        PageReference pref = new PageReference('/apex/CMAP_RouteAccountPlay?APId='+apRecord.Id);        
        Test.setCurrentPage(pref);
        CMAP_APRoutingController leadapRoutingCntrlr = new CMAP_APRoutingController (new ApexPages.StandardController(new Account_Play__c()));
        leadapRoutingCntrlr.apObj = apRecord ;
        leadapRoutingCntrlr.APId = apRecord.Id;
        leadapRoutingCntrlr.clRecord = CLleadObj;
        leadapRoutingCntrlr.newId= CLleadObj.Id;
        leadapRoutingCntrlr.pContactId = newCMAPCont.id;
        leadapRoutingCntrlr.enableContinue = TRUE;
        leadapRoutingCntrlr.saveButton();        
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
   }
   static testMethod void CreatenewContact() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        testData();
        Id newId;
        Id pContactId;
        PageReference pref = new PageReference('/apex/CMAP_RouteAccountPlay?APId ='+apRecord.Id+'&pContactId='+newCMAPCont.Id );
        Test.setCurrentPage(pref);
        CMAP_APRoutingController leadapRoutingCntrlr = new CMAP_APRoutingController (new ApexPages.StandardController(new Account_Play__c()));
        leadapRoutingCntrlr.apObj = apRecord ;
        leadapRoutingCntrlr.APId = apRecord.Id;
        system.currentpagereference().getparameters().put('radioName',newCMAPCont.id);
        leadapRoutingCntrlr.enableContinueButton();
        //system.currentpagereference().getparameters().put('radioName',newCMAPCont.id);
        leadapRoutingCntrlr.primaryContact = newCMAPCont.id;
        leadapRoutingCntrlr.first();
        leadapRoutingCntrlr.last();
        leadapRoutingCntrlr.previous();
        leadapRoutingCntrlr.next();
        leadapRoutingCntrlr.getContactDetails();
        leadapRoutingCntrlr.con.getHasNext();
        leadapRoutingCntrlr.con.getHasPrevious();
        leadapRoutingCntrlr.con.getPageNumber(); 
        leadapRoutingCntrlr.redirect();
        leadapRoutingCntrlr.pContactId = newCMAPCont.id;
        leadapRoutingCntrlr.newId= CLleadObj.Id;
        //leadapRoutingCntrlr.newContact();
        leadapRoutingCntrlr.cancelButton();
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
   }
   
}