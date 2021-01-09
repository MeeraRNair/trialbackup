/***********************************************************
* Description          : Test Class for CampaignMemberUtils 
* ---------------------------------------------------------
* Revision      Release         Name    Date            Description
* 1.0           12.7            MenMee  27.06.2011      CR6340 Convert Lead to CampaignMember  
* 2.0           FY17-DCS-1101   Azwanti 23.09.2016      CR13494 LM2_6-Retire ability to create new Account Play/Relationship Lead record        
* 3.0           FY18-DCS-0802   Azwanti 11.07.2017      CR14454 remove Lead Qualification
* 3.1           FY18-DCS-0802   Sajith  19-Jul-2017     CR14599 added mandatory field 'Marketing Primary Solution Interest'
***********************************************************/

@isTest
private class CampaignMemberUtilsTest {

    static List<Contact> testConList = new List<Contact>();
    static List<Lead> testLeadList = new List<Lead>();
    static Campaign testCampaign = new Campaign();
    static Set<ID> testID = new Set<ID>();
    static Campaign testCampaign1 = new Campaign();//azwanti uncommented
    static Campaign testCampaign2 = new Campaign(); //v2.0
    static CampaignMember testCampaignMember= new CampaignMember();
    static CampaignMember testCampaignMember1= new CampaignMember(); //azwanti uncommented
    static Relationship_Lead__c testRL = new Relationship_Lead__c();
    static List<CampaignMember> lstCM = new List<CampaignMember> ();
    static List<Campaign> lstCampaign = new List<Campaign>();
    
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }
    
    static testMethod void ConvertLeadToCMToRLTest() {
        // Skip all the triggers to avoid Too Many SOQL Query issue
        TriggerExecutionController.setSkipAllTriggers(true);
        
        TestDataCreation();
        system.debug('wanti testID: '+testID.size());
        //CampaignMemberUtils.CreateNewCMFromLead(new Map<Id, Set<Id>> {testCampaign.Id => new Set<Id> {testConList[1].Id}}, testLeadList, testID);
        
        System.debug('##### Create new CM (Lead -> CM)');
         //Test.startTest();
        for(integer i=0; i<2; i++) {
            testLeadList[i].Status = 'Marketing Ready';
        }
        // Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();                        
        //Database.update(testLeadList, false);
        update testLeadList;
        
        
        //RESULT: testLeadList[0] successfully create CM and testLeadList[1] will not   
        List<CampaignMember> testNewCMList = [SELECT Id, CM_Status__c, Custom_Lead__c FROM CampaignMember WHERE ContactId IN :testConList ORDER BY Id];
        //System.assertEquals(3, testNewCMList.size());   v2.0
        //System.assertEquals('Sent', testNewCMList[1].CM_Status__c);
        System.assertEquals(testLeadList[0].Id, testNewCMList[1].Custom_Lead__c);                
        
        System.debug('##### Create new RL and associate back to Lead (CM -> RL -> Lead)');
        
        testnewCMList[1].CM_Status__c = 'Requires Follow-Up';
        Test.stopTest();
        update testnewCMList;        
        
        //RESULT: 1) RL is created and asscoate with CM and Lead, 2) Lead status get updated to Sales Ready Convert To RL and 3) CM get updated with RL info
        List<Relationship_Lead__c> testNewRLList = [SELECT Id FROM Relationship_Lead__c WHERE CM_Source__c = :testNewCMList[1].Id AND Lead_Id_Do_Not_Edit__c = :testLeadList[0].Id];
        //System.assertEquals(1, testNewRLList.size());
        //System.assertEquals('Sales Ready - Converted to RL', [SELECT Status FROM Lead WHERE Id = :testLeadList[0].Id][0].Status);
        
        
        
        //List<CampaignMember> testUpdatedCMList = [SELECT Id, Relationship_Lead__c, Relationship_Lead_Created__c, Relationship_Lead_Opportunity_Status__c FROM CampaignMember WHERE Id = :testNewCMList[1].Id];        
        //System.assertEquals(testNewRLList[0].Id, testUpdatedCMList[0].Relationship_Lead__c);
        //System.assertEquals(true, testUpdatedCMList[0].Relationship_Lead_Created__c);
        //System.assertEquals(null, testUpdatedCMList[0].Relationship_Lead_Opportunity_Status__c);
    }
    
   // v2.0
    static testMethod void createRLandCMFromLead() {
        // Skip all the triggers to avoid Too Many SOQL Query issue
        TriggerExecutionController.setSkipAllTriggers(true);
        TestDataCreation();
        // Revert back the skip all triggers
        
        
        System.debug('##### Create RL to trigger creation of CM');        
        Test.startTest();        
        Relationship_Lead__c newRL = new Relationship_lead__c(Contact__c = testConList[0].Id, Campaign__c = lstCampaign[2].id, //testCampaign.Id,
                                                  CM_Source__c = testLeadList[0].Id, Lead_Id_Do_Not_Edit__c = testLeadList[0].Id, Status__c = 'Requires Follow-Up');
        insert newRL; 
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
        //RESULT: CM is created also after RL created.
        List<CampaignMember> actualCMList = [SELECT Id, Relationship_Lead__c, Relationship_Lead_Created__c, Relationship_Lead_Opportunity_Status__c FROM CampaignMember 
                                                WHERE CampaignId = :lstCampaign[2].id //:testCampaign.Id 
                                                and ContactId = :testConList[0].Id];
        
         List<Relationship_Lead__c> actualRLList = [SELECT Id, CM_Source__c FROM Relationship_Lead__c WHERE Id = :newRL.Id]; 
        //v2.0 commented
        //System.assertEquals(actualCMList[0].Id, actualRLList[0].CM_Source__c);
      //  System.assertEquals(actualCMList[0].Relationship_Lead__c, actualRLList[0].Id);
      //  System.assertEquals(true, actualCMList[0].Relationship_Lead_Created__c);
    }   
    
    static testMethod void associateLeadWithCMandRL() {
        // Skip all the triggers to avoid Too Many SOQL Query issue
        TriggerExecutionController.setSkipAllTriggers(true);
        TestDataCreation();
        // Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);
              
        System.debug('##### Check for existing RL');
        
        //Map<String, List<Relationship_Lead__c>> rlMap = CampaignMemberUtils.getDuplicateRL(new Map<Id, Set<Id>> {testCampaign.Id => new Set<Id> {testConList[1].Id}});
       // Map<String, List<Relationship_Lead__c>> rlMap = CampaignMemberUtils.getDuplicateRL(new Map<Id, Set<Id>> {lstCampaign[0].Id => new Set<Id> {testConList[1].Id}});
        
        //R15.03 azwanti fix test class
        //Map<String, CampaignMember> cmMap = CampaignMemberUtils.getDuplicateCM(new Map<Id, Set<Id>> {testCampaign.Id => new Set<Id> {testConList[1].Id}});
        Map<String, CampaignMember> cmMap = CampaignMemberUtils.getDuplicateCM(new Map<Id, Set<Id>> {lstCampaign[0].Id => new Set<Id> {testConList[1].Id}});
        System.assertEquals(1, cmMap.size());
        
        Test.startTest();    
        System.debug('##### Associate Lead with CM and RL');        
        //CampaignMemberUtils.associateLeadToCMRL(testLeadList[1], rlMap.get(testCampaign.Id +':'+testConList[1].Id)[0]);
   //     CampaignMemberUtils.associateLeadToCM(testLeadList[1],lstCM[1]);//testCampaignMember1); //azwanti uncommented
        map<Id,CampaignMember> mapCampaignMem = new map<Id,CampaignMember>();
        for(CampaignMember objMem: lstCM) {
            
            mapCampaignMem.put(objMem.Id,objMem);
            
        }
        CampaignMemberUtils.generateCMFieldHistory(mapCampaignMem,mapCampaignMem);
        
        
        //RESULT: 1)Lead is update to Sales Ready Convert To RL, 2) RL Lead Id = Lead , 3) CM custom lead  = lead
        List<Lead> updatedLeadList = [SELECT Status FROM Lead WHERE Id =:testLeadList[1].Id];
      //  System.assertEquals('Sales Ready - Converted to RL', updatedLeadList[0].Status); v2.0
        Test.stopTest();
        
        //System.assertEquals(1, [SELECT Count() FROM Relationship_Lead__c WHERE Lead_Id_Do_Not_Edit__c =:testLeadList[1].Id]);  v2.0
        //System.assertEquals(1, [SELECT Count() FROM CampaignMember WHERE Custom_Lead__c = :testLeadList[1].Id]);
    }
    
    //v3.0
    static testMethod void createCMfromLeadTest() {
        Id campPartnerComRT = IdLookupUtils.getRecordTypeId('Channel Partner Communications', 'Campaign', true); 
        Campaign testCmpgn = new Campaign(RecordTypeId = campPartnerComRT,
                                    Name='Test Campaign',
                                    Campaign_Objective__c = 'LOB Conversion',
                                    Type='DM',
                                    Segment_Business_Unit__c='PUB',                                 
                                    StartDate=System.Today() - 10,
                                    EndDate=System.Today(),
                                    Description='This is Test Campaign',
                                    IsActive=true,
                                    Lead_Routing__c = 'Not Applicable'); //v2.0
        insert testCmpgn;
        
        Account testAccount  = new Account(Name='Test Account');
        insert testAccount;
        
        Contact testCon = new Contact(AccountId=testAccount.Id,
                                          Email='testCon@dell.com',
                                          FirstName = 'Test', 
                                          LastName = 'Contact for CM',
                                          Title='VP',
                                          MailingStreet='123 Main',
                                          MailingCity='Peoria',
                                          MailingState='IL',
                                          MailingPostalCode='33333',
                                          Phone='9823213211',
                                          MobilePhone='3213213211',
                                          Fax='3213123211');
        insert testCon;
       
        system.debug('before BYPASS_createLeadFromCM: '+GlobalVariables.BYPASS_createLeadFromCM);
        GlobalVariables.BYPASS_createLeadFromCM = false;
        system.debug('after BYPASS_createLeadFromCM:'+GlobalVariables.BYPASS_createLeadFromCM);
        
        Id leadQRT = IdLookupUtils.getRecordTypeId('Lead Qualification', 'Lead', true);        
        Lead testLead = new Lead(FirstName = 'test',
                                 LastName = 'Lead createNewCMFromLead',
                                 Company = 'Comp ABC',
                                 Status = 'Marketing Ready',
                                 Email = 'no_reply@dell.com',
                                 Campaign__c = testCmpgn.id, //testCampaign.id,
                                 Contact__c = testCon.id,
                                 RecordTypeId = leadQRT, 
                                 LeadSource = 'Other',
                                 Lead_Type__c = 'Inbound',
                                 Lead_Capture_DateTime__c = System.now()); 
        insert testLead;
        
    }    
    
    static void TestDataCreation() {
        integer i;

        testCampaign = new Campaign(Name='Test Campaign',
                                    Campaign_Objective__c = 'LOB Conversion',
                                    Type='DM',
                                    Segment_Business_Unit__c='PUB',                                 
                                    StartDate=System.Today() - 10,
                                    EndDate=System.Today(),
                                    Description='This is Test Campaign',
                                    IsActive=true,
                                    Lead_Routing__c = 'Not Applicable'); //v2.0
        lstCampaign.add(testCampaign);
        
        testCampaign1 = new Campaign(Name='Test Campaign1',
                                    Campaign_Objective__c = 'LOB Conversion',
                                    Type='DM',
                                    Segment_Business_Unit__c='PUB',                                 
                                    StartDate=System.Today() - 10,
                                    EndDate=System.Today(),
                                    Description='This is Test Campaign1',
                                    IsActive=true,
                                    Lead_Routing__c = 'Not Applicable');  //v2.0
        lstCampaign.add(testCampaign1);  
        
        Id channelCampaignRT = IdLookupUtils.getRecordTypeId('Channel Partner Communications', 'Campaign', true);
        testCampaign2 = new Campaign(Name='Test Campaign2',
                                     RecordTypeId = channelCampaignRT, //v2.0
                                    Campaign_Objective__c = 'LOB Conversion',
                                    Type='DM',
                                    Segment_Business_Unit__c='PUB',                                 
                                    StartDate=System.Today() - 10,
                                    EndDate=System.Today(),
                                    Description='This is Test Campaign2',
                                    IsActive=true,
                                    Lead_Routing__c = 'Not Applicable'); //v2.0
        lstCampaign.add(testCampaign2);
        
        insert lstCampaign;
        
        Account testAccount  = new Account(Name='Test Account');
        insert testAccount;
        
        for (i=0; i< 2; i++ ) {
            Contact testContact = new Contact(AccountId=testAccount.Id,
                                    Email='testCon@dell.com',
                                    FirstName = 'Test', 
                                    LastName = 'Contact'+i,
                                    Title='VP',
                                    MailingStreet='123 Main',
                                    MailingCity='Peoria',
                                    MailingState='IL',
                                    MailingPostalCode='33333',
                                    Phone='3213213211'+i,
                                    MobilePhone='3213213211',
                                    Fax='3213123211');
            testConList.add(testContact);
        }                                   
        insert testConList;
        for(Contact c:testConList)
        {
            testID.add(c.ID);
        }
       
        
       // Id leadQualificationRT = IdLookupUtils.getRecordTypeId('Lead Qualification', 'Lead', true); //v3.0
        Id directLeadRT = IdLookupUtils.getRecordTypeId('Direct Lead 2.0', 'Lead', true);
        for(i=0; i< 2;i++) {
            Lead testLead = new Lead(FirstName = 'test',
                            LastName = 'Lead'+i,
                            Company = 'Test Company',
                            Status = 'Open',
                            Email = 'no_reply@dell.com',
                            Campaign__c = lstCampaign[0].id, //testCampaign.id,
                            Contact__c = testConList[i].id,
                            RecordTypeId = directLeadRT, // v2.0 change to Direct Lead 2.0 RT
                            //v2.0 added LeadSource and Lead Type since its required field
                            LeadSource = 'Other',
                            Lead_Type__c = 'Inbound',
                            Country_Code__c = 'US',
                            Lead_Capture_DateTime__c = System.now(),
                            Marketing_Primary_Solution_Interest__c='HCI');//v3.1 
            testLeadList.add(testLead); 
        }
        insert testLeadList;
        
        
        //To create an existing CM and RL record with testConList[i]
        // testCampaignMember = new CampaignMember(CampaignId = testCampaign.Id, Campaign_Vehicle__c = testCampaign.Type,
        //                                                    ContactId = testConList[1].Id, CM_Status__c = 'Requires Follow-Up');
        testCampaignMember = new CampaignMember(CampaignId = lstCampaign[0].Id, Campaign_Vehicle__c = lstCampaign[0].Type,
                                                            ContactId = testConList[1].Id, CM_Status__c = 'Requires Follow-Up');
                                                            
        //insert testCampaignMember;
        lstCM.add(testCampaignMember);
        
        //R15.03 azwanti fix test class
        //testCampaignMember1 = new CampaignMember(CampaignId = testCampaign1.Id, Campaign_Vehicle__c = testCampaign.Type,
        //                                                    ContactId = testConList[1].Id, CM_Status__c = 'Sent',Custom_Lead__c = testLeadList[0].id );
        testCampaignMember1 = new CampaignMember(CampaignId = lstCampaign[1].Id, Campaign_Vehicle__c = lstCampaign[0].Type,
                                                            ContactId = testConList[1].Id, CM_Status__c = 'Sent',Custom_Lead__c = testLeadList[0].id );
        
        //insert testCampaignMember1;        
        lstCM.add(testCampaignMember1);
        
        insert lstCM;
         //azwanti fix 
    }
 }