/**
 * This class contains unit tests for validating the behavior of RedirectRouteToChannelExtension Apex classe
 * .
 *
 CR 15422 - Created on 6-Feb-2017 - Ashutosh (Neo)
 
 */
@isTest
private class RedirectToLeadConvertExtensionTest {

    static testMethod void doRedirectTest() {
      /*This method was intended to test the method behind the Route Channel Button On Lead where on clicking of button triggers the
      page redirect */

        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); 
        Campaign CMAP_dir_camp= new Campaign(Name='TestCampaign_Direct',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                //Allocation_Source__c = 'Dell Allocation ABU'
                //Nurture_Source__c = 'Dell Nurturing'
                IsActive = true,
                RecordTypeId = campRTId,                            
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',//v3.0
                //Partner_Campaign_Contact__c=partnerUser.Id,//3.0
                Total_Value_Opportunities_Planned__c = 1);
         insert  CMAP_dir_camp;
         Lead SegleadObj = new Lead(lastName = 'Test Dir Lead1',
                firstName = 'CMAP',
                Salutation = 'Mr.',
                MobilePhone = '098645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                City = 'Test City',
                State = 'Test State',
                PostalCode = '9876545',
                Dell_can_contact_me_in_the_future__c='Yes',
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  CMAP_dir_camp.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Country_Code__c = 'AE',
                LeadSource = 'Web',//v3.0 - added since its required field
                Lead_Type__c = 'Inbound',//v3.0
                Company = 'Test Company');
        insert SegleadObj;
        if(SegleadObj != null){
          ApexPages.StandardController sc = new ApexPages.StandardController(SegleadObj);
         RedirectToLeadConvertExtension testData = new RedirectToLeadConvertExtension(sc);
          testData.doRedirect();
        }
    }
}