/**
* This class contains unit tests for validating the behavior of the class MarketingOpptyAssnUtils.
*
* @author: Raymond Yip
* @date: 28-Sep-2009
*
* Revision History
* ------------------------------------------------------------------
* 1.  28-Sep-2009  Raymond Yip    Created
* 2.  04-Jan-2010  Raymond Yip    Included test method for CR2137 for beforeinsertupdatecampaigntrigger.
* 3.  19-Jan-2010  Raymond Yip    Commented test method for CR2137. CR removed from R11.1
* 4.  18-Mar-2010  Men Mee        Update CreateTestData(). Change Opportunity.Account to Opportunity.AccountId
* 5.  25-Sep-2010  Krishna        Uncommented test method(s) for CR 2137 (R11.10)
* 6.  09-Aug-2011  Men Mee        CR 6507 Validate test result
* 7.  23-Jul-2013  Emily      CR8469 - Lattice to SFDC - added new parameter to convertRelnshipLead_AccountPlayToOppty and updateRelnshipLead_AccountPlayStatus
*/
@isTest
private class MarketingOpptyAssnUtilsTest{

    static List<Relationship_Lead__c> relanshipTestDataList;
    static List<Account_Play__c> accountPlayTestDataList;
    static List<Opportunity> opportunityTestDataList;

    static Campaign campaignForAPTestData;
    static Campaign campaignForRLTestData;
    static Contact contactTestData;
    static Account accountTestData;
    
    static testMethod void testPickListValues() {

        Test.startTest();
        //Test picklist values of Lead Generation's Status
        Schema.DescribeFieldResult relnshipLeadStatus = Relationship_Lead__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> relnshipLeadStatusPickListValues = relnshipLeadStatus.getPicklistValues();

        Map<String, Schema.PicklistEntry> relnshipLeadStatusEntryMap = new Map<String, Schema.PicklistEntry>();
        for(Schema.PicklistEntry entry : relnshipLeadStatusPickListValues) {
            relnshipLeadStatusEntryMap.put(entry.getLabel(), entry);          
        }

        //System.assert(relnshipLeadStatusEntryMap.containsKey('Requires Follow-Up'));
        System.assert(relnshipLeadStatusEntryMap.containsKey('Accepted - Completed Follow-Up'));
        //System.assert(relnshipLeadStatusEntryMap.containsKey('Future Follow-Up'));
        //System.assert(relnshipLeadStatusEntryMap.containsKey('Rejected - Completed Follow-Up'));
        //System.assert(relnshipLeadStatusEntryMap.containsKey('Awaiting Follow-Up'));
        //System.assert(relnshipLeadStatusEntryMap.containsKey('Opportunity not Created'));     


        //test picklist values of Lead Generation's Opportunity Status
        Schema.DescribeFieldResult relnshipLeadOpptyStatus = Relationship_Lead__c.Opportunity_Status__c.getDescribe();
        List<Schema.PicklistEntry> relnshipLeadOpptyStatusPickListValues = relnshipLeadOpptyStatus.getPicklistValues();

        Map<String, Schema.PicklistEntry> relnshipLeadOpptyStatusEntryMap = new Map<String, Schema.PicklistEntry>();
        for(Schema.PicklistEntry entry : relnshipLeadOpptyStatusPickListValues) {
            relnshipLeadOpptyStatusEntryMap.put(entry.getLabel(), entry);          
        }

        System.assert(relnshipLeadOpptyStatusEntryMap.containsKey('Existing Opportunity'));
        System.assert(relnshipLeadOpptyStatusEntryMap.containsKey('New Opportunity'));
        //System.assert(relnshipLeadOpptyStatusEntryMap.containsKey('No Opportunity'));
        //System.assert(relnshipLeadOpptyStatusEntryMap.containsKey('Future Opportunity'));


        //test picklist values of Sales Play's Status
        Schema.DescribeFieldResult accountPlayStatus = Account_Play__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> accountPlayStatusPickListValues = accountPlayStatus.getPicklistValues();

        Map<String, Schema.PicklistEntry> accountPlayStatusEntryMap = new Map<String, Schema.PicklistEntry>();
        for(Schema.PicklistEntry entry : accountPlayStatusPickListValues) {
            accountPlayStatusEntryMap.put(entry.getLabel(), entry);          
        }

        //System.assert(accountPlayStatusEntryMap.containsKey('Opportunity not Created'));
        //System.assert(accountPlayStatusEntryMap.containsKey('Closed - Expired'));
        //System.assert(accountPlayStatusEntryMap.containsKey('Awaiting Follow-Up'));
        //System.assert(accountPlayStatusEntryMap.containsKey('Rejected - Completed Follow-Up'));
        //System.assert(accountPlayStatusEntryMap.containsKey('Future Follow-Up'));
        System.assert(accountPlayStatusEntryMap.containsKey('Accepted - Completed Follow-Up'));
        //System.assert(accountPlayStatusEntryMap.containsKey('Requires Follow-Up'));     

        //test picklist values of Sales Play's Opportunity Status  
        Schema.DescribeFieldResult accountPlayOpptyStatus = Account_Play__c.Opportunity_Status__c.getDescribe();
        List<Schema.PicklistEntry> accountPlayOpptyStatusPickListValues = accountPlayOpptyStatus.getPicklistValues();

        Map<String, Schema.PicklistEntry> accountPlayOpptyStatusEntryMap = new Map<String, Schema.PicklistEntry>();
        for(Schema.PicklistEntry entry : accountPlayOpptyStatusPickListValues) {
            accountPlayOpptyStatusEntryMap.put(entry.getLabel(), entry);          
        }

        System.assert(accountPlayOpptyStatusEntryMap.containsKey('Existing Opportunity'));
        System.assert(accountPlayOpptyStatusEntryMap.containsKey('New Opportunity'));
        //System.assert(accountPlayOpptyStatusEntryMap.containsKey('No Opportunity'));
        //System.assert(accountPlayOpptyStatusEntryMap.containsKey('Future Opportunity'));
        Test.stoptest();
    }

    //testmethod for convertRelnshipLead_AccountPlayToOppty(Map<String, String> opptyToObjMap,Map<String, String> opptyToCampiagnMap,String  opptyStatValue)
    //this method calls another two methods, which has their own test method
    static testMethod void testconvertRelnshipLead_AccountPlayToOppty() {

    //Passing empty maps just to cover the code of this method.
    //This methods call another two methods, which has their own test method
        MarketingOpptyAssnUtils.convertRelnshipLead_AccountPlayToOppty(new Map<String, String>(), new Map<String, String>(), 'Existing Opportunity', new set<String>());  

    }
    
    //testMethod to test updateRelnshipLead_AccountPlayStatus(Map<String, String> opptyToObjMap , String opptyStatValue)
    static testMethod void testUpdateRelnshipLead_accountPlayStatus() {
        CreateTestData();
       // Test.startTest();

        Map<String, String> opptyToObjectMap = new Map<String, String>();

        for(Opportunity oppty : opportunityTestDataList) {

            opptyToObjectMap.put(oppty.Id, oppty.Source_Id__c);

        }

        MarketingOpptyAssnUtils.associateWithRelationshipLeadAndAccountPlay(opportunityTestDataList);
        MarketingOpptyAssnUtils.updateRelnshipLead_AccountPlayStatus(opptyToObjectMap, 'Existing Opportunity', new set<String>());

        System.debug('###DEBUG### relanshipTestDataList = ' + relanshipTestDataList);

        //the method called above should have updated some values. This query retrieves the records
        //that do not have the expected values after the call.
        List<Relationship_Lead__c> incorrectRelnLeadList = [SELECT Id, Opportunity_Status__c,Status__c,Opportunity_Created__c,Opportunity__c 
                                                            FROM Relationship_Lead__c 
                                                            WHERE ID IN :relanshipTestDataList
                                                            AND Opportunity__c = ''
                                                            AND Status__c !='Accepted - Completed Follow-Up'
                                                            AND Opportunity_Status__c != 'Existing Opportunity'
                                                            AND Opportunity_Created__c = false];
        
        System.debug('### size(): '+ incorrectRelnLeadList.size());     
        System.assert(incorrectRelnLeadList.size() <= 0);  

        //the method called above should have updated some values. This query retrieves the records
        //that do not have the expected values after the call
        List<Account_Play__c> incorrectAccountPlayList = [SELECT Id, Opportunity_Status__c,Status__c,Opportunity_Created__c,Opportunity__c 
                                                        FROM Account_Play__c 
                                                        WHERE ID IN :accountPlayTestDataList
                                                        AND Opportunity__c = ''
                                                        AND Status__c !='Accepted - Completed Follow-Up'
                                                        AND Opportunity_Status__c != 'Existing Opportunity'
                                                        AND Opportunity_Created__c = false];

        System.assert(incorrectAccountPlayList.size() <= 0);

      //  Test.stopTest();
        
        //6
        //List<OpportunityContactRole> ocr = [SELECT ContactId, Role FROM OpportunityContactRole WHERE OpportunityId = :opportunityTestDataList[0].Id ];
        //System.assertEquals(1, ocr.size());
        //System.assertEquals(contactTestData.Id, ocr[0].ContactId);
        //System.assertEquals('Unknown', ocr[0].Role);
    }
    
    //TestMethod for insertCampaignInfluence(Map<String, String> opptyToCampaignMap)
    static testMethod void testinsertCampaignInfluence() {
        CreateTestData();
        //Test.startTest();

        List<Opportunity> campaignTestOpptyList = new List<Opportunity>();

        for(integer i=0; i < 10; i++) {
            campaignTestOpptyList.add(new Opportunity(
                                        Name = 'Oppty No.' + i,
                                        Account = accountTestData,
                                        Type='Run Rate',
                                        Solution_Type__c='Business Processing',
                                        //CurrencyIsoCode='',
                                        CloseDate=System.Today(),
                                        StageName='Plan - 1%',
                                        Lattice_PreLead_External_ID__c = relanshipTestDataList[0].Id,
                                        Marketing_Created_Opportunity__c = true,
                                        CampaignId=campaignForAPTestData.Id)
            );      

        }
        TriggerExecutionController.setSkipAllTriggers(true);
        insert campaignTestOpptyList;

        Map<String, String> opptyToCampaignMap = new Map<String, String>();

        for(Opportunity oppty : campaignTestOpptyList) {
            System.assert(oppty.CampaignId == campaignForAPTestData.Id);

            opptyToCampaignMap.put(oppty.Id, campaignForRLTestData.Id);
        }

        MarketingOpptyAssnUtils.associateWithRelationshipLeadAndAccountPlay(campaignTestOpptyList);
        MarketingOpptyAssnUtils.insertCampaignInfluence(opptyToCampaignMap);    

        TriggerExecutionController.setSkipAllTriggers(false);
        //should test if Campaign Influence is created. But since we can't retrieve the Camapign Influence
        //from API, this code only check if Primary Camapign Source is changed
        for(Opportunity oppty : [SELECT Id, CampaignId FROM Opportunity WHERE Id IN :campaignTestOpptyList]) {
            System.assert(oppty.CampaignId == campaignForAPTestData.Id);        
        }

       // Test.stopTest();
    }
    
    //Raymond 19-Jan-2010 - commented. CR removed from R11.1.  [Krishna 25-Sep-2010: Uncommented for CR 2137 R 11.10]
    
    static testmethod void testUpdateCampaignAPExpiryDate() {
        CreateTestData();
        //Test.startTest();
        
        
        campaignForAPTestData.Account_play_expiry_date__c = system.today() + 10;        
        update campaignForAPTestData;
        
        Campaign resultCampaign = [select send_notification__c from campaign where id=:campaignForAPTestData.id][0];
        //asserts that the boolean field was updated
        system.assert(resultCampaign.send_notification__c == true);
        
        //Forcefully flips the value again for testing.
        campaignForAPTestData.send_notification__c = false;        
        update campaignForAPTestData;
        
        //Now updates just the description.
        campaignForAPTestData.Description = campaignForAPTestData.Description + '## 2137 is tested';
        update campaignForAPTestData;
        
        resultCampaign = [select send_notification__c from campaign where id=:campaignForAPTestData.id][0];
        //asserts that the boolean field was not updated.
        system.assert(resultCampaign.send_notification__c == false);
        
        //Test.stopTest();

        
    }
    


    static void CreateTestData() {
        Test.startTest();
        
        
        accountTestData = new Account(Name='Test Account');
        insert accountTestData;

        System.debug('###DEBUG### accountTestData = ' + accountTestData);


        contactTestData = new Contact(AccountId=accountTestData.Id,
                                    Email='testCon@dell.com',
                                    FirstName = 'ContactExcSafeWord1', 
                                    LastName = 'ContactExcSafeWord1',
                                    Title='VP',
                                    MailingStreet='123 Main',
                                    MailingCity='Peoria',
                                    MailingState='IL',
                                    MailingPostalCode='33333',
                                    Phone='3213213211',
                                    MobilePhone='3213213211',
                                    Fax='3213123211',
                                    Partner_My_Account_GUID__c='3456');
        insert contactTestData;    

        System.debug('###DEBUG### contactTestData = ' + contactTestData);

        list<RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Campaign' and DeveloperName != 'Campaign_2_0' and IsActive = true];
        
        campaignForAPTestData = new Campaign(Name='Test Campaign',
                                            Campaign_Objective__c = 'LOB Conversion',
                                            Type='Sales Touch',
                                            Segment_Business_Unit__c='PUB',
                                            //Region__c='ABU',
                                            StartDate=System.Today() - 10,
                                            EndDate=System.Today(),
                                            Is_this_Account_Play_Campaign__c = TRUE,
                                            Description='This is Test Campaign',
                                            Account_Play_Expiry_Date__c=System.today() + 60,
                                            IsActive = true,
                                            send_notification__c = false,
                                            recordtypeid = RecType[0].Id);
        insert campaignForAPTestData;

        System.debug('###DEBUG### campaignForAPTestData = ' + campaignForAPTestData);

        campaignForRLTestData = new Campaign(Name='Test Campaign',
                                            Campaign_Objective__c = 'LOB Conversion',
                                            Type='DM',
                                            Segment_Business_Unit__c='PUB',
                                            //Region__c='ABU',
                                            StartDate=System.Today() - 10,
                                            EndDate=System.Today(),
                                            Description='This is Test Campaign',                                            
                                            Account_Play_Expiry_Date__c=System.today() + 60,
                                            IsActive = true,
                                            recordtypeid = RecType[0].Id);

        insert campaignForRLTestData;
        System.debug('###DEBUG### campaignForRLTestData = ' + campaignForRLTestData);


        relanshipTestDataList = new List<Relationship_Lead__c>();
        accountPlayTestDataList = new List<Account_Play__c>();  
        for(Integer i=0; i < 10; i++) {
            relanshipTestDataList.add(new Relationship_Lead__c(
                                    Campaign__c=campaignForRLTestData.Id, 
                                    Contact__c = contactTestData.Id,
                                    Status__c = 'Requires Follow-Up',
                                    CM_Source__c = 'TESTID' + i) //should actually be CM Id, using dummy values here as quick fix
            );      


        accountPlayTestDataList.add(new Account_Play__c(Account__c=accountTestData.Id,Campaign__c=campaignForAPTestData.Id,Campaign_Vehicle__c=campaignForAPTestData.Type));  
        }

        insert relanshipTestDataList;    
        System.debug('###DEBUG### relanshipTestDataList = ' + relanshipTestDataList);

        insert accountPlayTestDataList;    
        System.debug('###DEBUG### accountPlayTestDataList = ' + accountPlayTestDataList);

        opportunityTestDataList= new List<Opportunity>();

        for(Relationship_Lead__c lg : relanshipTestDataList) {
            opportunityTestDataList.add(
                new Opportunity(
                    Name='Oppty ' + lg.Id, 
                    AccountId=accountTestData.Id, 
                    Type='Run Rate',
                    Solution_Type__c='Business Processing',
                    //CurrencyIsoCode='',
                    CloseDate=System.Today(),
                    StageName='Plan - 1%',
                    Marketing_Created_Opportunity__c = true,
                    Forecast_Category_Override__c='Best Case',
                    RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE, 
                    Source_Id__c = lg.Id)
            );  

        }

        for(Account_Play__c sp : accountPlayTestDataList) {
            opportunityTestDataList.add(
                new Opportunity(
                Name='Oppty ' + sp.Id, 
                AccountId=accountTestData.Id, 
                Type='Run Rate',
                Solution_Type__c='Business Processing',
                //CurrencyIsoCode='',
                CloseDate=System.Today(),
                StageName='Plan - 1%',
                Marketing_Created_Opportunity__c = true,
                Forecast_Category_Override__c='Best Case',
                RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE, 
                Source_Id__c = sp.Id)
            );  

        }
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        insert opportunityTestDataList;
        TriggerExecutionController.setSkipAllTriggers(false);
        System.debug(opportunityTestDataList);
        }

}