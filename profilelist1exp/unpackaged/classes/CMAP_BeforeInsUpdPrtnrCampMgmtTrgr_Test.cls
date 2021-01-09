/*
REVISION HISTORY
======================================================================================================================
Version    Author    Date            Release#       CR#    Description
-------    ------    ----            --------       ---    -----------
1.0                                                         created  
2.0        Azwanti  15-March-2016   FY17-DCS-0401   12720   replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
*/

@isTest
private class CMAP_BeforeInsUpdPrtnrCampMgmtTrgr_Test {

    static testMethod void hasOnePartner() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;   
        
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                recordTypeId = campRTId,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        Partner_Campaign_Management__c partnerCampObj = new Partner_Campaign_Management__c(
                   //Name='PCM1',
                    partner_Account__c=newAcc.Id,
                    Campaign__c=campChannelObj.Id,
                    Primary_Partner__c=true,
                    CurrencyIsoCode='USD'
                    );
        Account newAcc1 = new Account(name='Test1', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc1;   
        
        Campaign campChannelObj1= new Campaign(Name='Campaign_CMAP1',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                recordTypeId = campRTId,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj1;
        Partner_Campaign_Management__c partnerCampObj2 = new Partner_Campaign_Management__c(
                    //Name='PCM2',
                    Partner_Account__c=newAcc1.Id,
                    Campaign__c=campChannelObj1.Id,
                    Primary_Partner__c=true,
                    CurrencyIsoCode='SGD'
                    );
        test.startTest();
        insert partnerCampObj;
        insert partnerCampObj2;
        test.stopTest();
        system.assertEquals(partnerCampObj.Campaign__c, campChannelObj.Id);
        system.assertEquals(partnerCampObj2.Campaign__c, campChannelObj1.Id);
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void deleteOnePartner() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;   
        
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                recordTypeId = campRTId,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        Partner_Campaign_Management__c partnerCampObj = new Partner_Campaign_Management__c(
                   //Name='PCM1',
                    partner_Account__c=newAcc.Id,
                    Campaign__c=campChannelObj.Id,
                    Primary_Partner__c=true,
                    CurrencyIsoCode='USD'
                    );
        insert partnerCampObj;
        Account newAcc1 = new Account(name='Test1', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc1;   
        
        Campaign campChannelObj1= new Campaign(Name='Campaign_CMAP1',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                recordTypeId = campRTId,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj1;
        Partner_Campaign_Management__c partnerCampObj2 = new Partner_Campaign_Management__c(
                    //Name='PCM2',
                    Partner_Account__c=newAcc1.Id,
                    Campaign__c=campChannelObj1.Id,
                    Primary_Partner__c=False,
                    CurrencyIsoCode='SGD'
                    );
        
        insert partnerCampObj2;
        test.startTest();
        delete partnerCampObj; 
        test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
                                    
    }
}