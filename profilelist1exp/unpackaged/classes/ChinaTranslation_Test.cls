/*

*Name: ChinaTranslation_Test
*Purpose:Test Class For ChinaTranslation
CR Request:14806

*/@IsTest
public class ChinaTranslation_Test {
    static list<Case> listCase;
    static list<Account> listAcc;
    static list<Contact> listCon;
    static list<Campaign> listCamp;
    static list<Opportunity> listOpp;
    @testsetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(True);
        list<Contact> listConTDF = TestDataFactory.CreateNContacts(1);
        insert listConTDF;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Master Account');
        insert listAccTDF;
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCampTDF;
        list<Case> listCaseTDF = TestDataFactory.createNCases(1);
        insert listCaseTDF;
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOppTDF;
    } 
    static testMethod void testParse() {
        /*                   Account testAccount1  = new Account(Name='Test Account 23455');
insert testAccount1;
Contact testContact1 = new Contact(AccountId=testAccount1.Id,
Email='testCon1@dell.com',
FirstName = 'Test', 
LastName = 'Contact',
Title='VP',
MailingStreet='123 Main',
MailingCity='Peoria',
MailingState='IL',
MailingPostalCode='33333',
Phone='3213213211',
MobilePhone='3213213211',
Fax='3213123211',
Partner_My_Account_GUID__c='34567');
insert testContact1;

Campaign testCampaign1 = new Campaign(Name='Test Campaign',
Campaign_Objective__c = 'LOB Conversion',
Type='DM',
Segment_Business_Unit__c='PUB',
//Region__c='ABU',
StartDate=System.Today() - 10,
EndDate=System.Today(),
Description='This is Test Campaign',                                            
Account_Play_Expiry_Date__c=System.today() + 60,
IsActive=true);

insert testCampaign1;
Case Testcase=new Case(AccountId=testAccount1.Id,Origin='Phone');
//insert Testcase; 
Opportunity oppt=new Opportunity(AccountId=testAccount1.Id); */
        listAcc = [select id from Account limit 1];
        listCon = [select id,AccountID from Contact limit 1];
        listCon[0].AccountID = listAcc[0].id;
        TriggerExecutionController.setSkipContactTriggers(True);
        update listCon;
        listCase = [select id,AccountID from Case limit 1];
        listCamp =  [select id from Campaign limit 1];
        listOpp = [select id from Opportunity limit 1];
        Id leadRTId= IdLookupUtils.getRecordTypeId('External Lead','Lead',true);
        // oppt.CloseDate = System.today().adddays(10);
        //   insert oppt;
        Lead testLead1 = new Lead(FirstName = 'NewTest',
                                  LastName = 'Lead',
                                  Company = 'Test Company',
                                  Status = 'Open',
                                  RecordTypeId = leadRTId,
                                  //Campaign__c = testCampaign1.id,
                                  Phone = '8877887',
                                  Contact__c = listCon[0].id,
                                  //    Case_Number__c=Testcase.id,
                                  Data_Center_Optimization__c = 'Virtualization',
                                  End_user_Productivity__c = 'SharePoint',
                                  IT_Process_Simplification__c = 'Flex Computing',
                                  Dell_can_contact_me_in_the_future__c = 'Yes',
                                  Decision_Making_Role__c = 'Influencer',
                                  Employees__c = '10000+',
                                  Dell_Existing_Customer__c = 'Yes',
                                  Purchase_Timeframe__c = 'Immediately',
                                  LeadSource = 'web',
                                  Lead_Type__c = 'Inbound',Legal_Local_Country__c='CHINA',
                                  Mg_Local_Country_Name__c='CHINA',
                                  Country_Code__c = 'US',
                                  
                                  Purchase_Influence_Over__c = 'Services - Client');//,
        //Questions_Comments__c = 'Sample Questions');
        TriggerExecutionController.setSkipLeadTriggers(True);
        insert testLead1;
        system.assertEquals('US', testLead1.Country_Code__c);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testLead1);
        ChinaTranslation cN  = new ChinaTranslation(sc);
        cN.jsonBody = 'test';
        cN.translateState();
        
        // Logic added
        CN.redirect();
        String strResPonceIs = '{\"from\":\"kor\",\"to\":\"en\",\"trans_result\":[{\"src\":\"\\ud558\\uc774\\ud14c\\ud06c \\uc2dc\\ud2f0\",\"dst\":\"high tech city\"},{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"\\ud558\\uc774\\ub370\\ub77c\\ubc14\\ub4dc\",\"dst\":\"the lava).\"}]}';
        Translation_Parser.TranslationParser ts = Translation_Parser.parse(strResPonceIs );
        Translation_Parser.TranslationParser ts1 = Translation_Parser.parse(strResPonceIs );
        list<string> listd=new list<string>{'test1','test2','test3','test4','test5','test6','test','test0','test8','test9','test10'};
            CN.str1 = 'sample\nsample';
        
        CN.phsicalAndPostal();
        CN.populatePhysical(testLead1,ts);
        CN.populatePostalAndPhysical1(testLead1,listd);
        CN.populatePostalAndPhysical3(testLead1,listd);
        CN.populatePostal1(testLead1,listd);
        
        try{
            CN.populatePostalAndPhysical(testLead1,ts);
            CN.populatePostalAndPhysical2(testLead1,ts1);
            CN.populatePostal(testLead1,ts);
            
        }catch(Exception ex){}
        ChinaTranslation.validateDoubleByteRegExp('부산광역시');  
    }
}