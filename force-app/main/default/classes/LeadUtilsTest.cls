@isTest
public class LeadUtilsTest{
   static testMethod void test_assignLeadStatusForChannelUser(){
        User usr = [Select Id,Name from User Where Profile.Name LIKE '%Channel Agency%' and IsActive=true LIMIT 1];
        system.runAs(usr){
                Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
                Id CampRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0', 'Campaign', true);
                Id leadRTId = IdLookupUtils.getRecordTypeId('Channel Lead 2.0', 'Lead', true);
                Account accountObj = new Account(name='Dummy Account 123',Type = 'Partner', RecordTypeId = accRTId );
                insert accountObj ;
                
                Campaign campObj = new Campaign();
                campObj.Name='Campaign_CMAP';
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
                campObj.Partner_Campaign_Contact_Email__c = 'test@test.com';
                campObj.Lead_Routing__c ='Dell Standard';
                TriggerExecutionController.setSkipCampaignTriggers(true);
                insert campObj;
                TriggerExecutionController.setSkipCampaignTriggers(false);
            
            
                CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
                objCust.Queue_Id__c = '00GA0000002y6hl';
                objCust.Queue_Name__c = 'Channel_eClerx';
                objCust.Name ='Channel_eClerx';
                insert objCust ;
    
                Lead leadRec = new Lead();
                leadRec.lastName = 'Test Lead Record';
                leadRec.email ='testcmap1@cmaptest.com';
                leadRec.status = 'Assigned to Channel partner';
                leadRec.Phone='889675447';
                //leadRec.OwnerId='00GA0000002y6hl';
                leadRec.Campaign__c  = campObj.Id;
                leadRec.Budget__c = 'No';
                leadRec.RecordTypeId = leadRTId;
                leadRec.Country = 'US';
                leadRec.Partner_Account__c = accountObj.Id;
                leadRec.Solution_ProvIder_can_contact_me__c = FALSE;
                leadRec.Ready_For_Scoring__c = False;
                leadRec.Dell_Partner_can_contact_me__c = true;
                leadRec.Lead_Type__c ='Inbound';
                leadRec.Lead_Score__c= 'Visitor (Contact registered for event / other online form but did not attend)';
                leadRec.Company = 'Test Company';               
                Test.StartTest();
                insert leadRec;
                Test.StopTest();
                Lead ld =[Select Id,LeadSource from Lead Where Id=:leadRec.Id];
                System.assertEquals(ld.LeadSource,'Outside Agency');
        }
   }
}