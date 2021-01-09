@isTest
public class SurveyResponseTriggerHandlerAITest
{
    @isTest
    static void testAfterInsert()
    {
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Profile> listProfile = [select id,name from profile where name like '%System Administrator%' limit 1];   
        User standardUser = new User(Username='MyUsername' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='Email@dell.com', 
                                    FirstName='MyUserFirstName', 
                                    LastName='MyUserLastName',  
                                    ProfileId = listProfile.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c = 'Maritz'+String.ValueOf(Math.round(Math.random()*100000)),
                                    isActive = TRUE,
                                    Resource_Manager_Role__c='Inside Sales Rep');
        insert standardUser;
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        System.assert(testAccount != null);
        Contact testContact = new Contact(LastName = 'Test Contact',AccountId=testAccount.Id,Phone='12345678');
        insert testContact;
        AccountTeamMember atm = new AccountTeamMember(AccountId=testAccount.Id,TeamMemberRole='Inside Sales Manager',UserId=standardUser.Id);
        insert atm;
        Account_Team_Role__c atRole = new Account_Team_Role__c(Name='Inside Sales Manager');
        insert atRole;
        List<NPS_Mapping__c> listOfNpsMapping = new List<NPS_Mapping__c>();
        NPS_Mapping__c caseCreationMapping = new NPS_Mapping__c(Name='Case Creation',Source__c='Segment__c,NPS_Score__c,Status__c',Type__c='Case Creation');
        listOfNpsMapping.add(caseCreationMapping);
        NPS_Mapping__c caseOwnerMapping = new NPS_Mapping__c(Name='Case Owner',Source__c='Segment__c,Region__c',Type__c='Case Owner');
        listOfNpsMapping.add(caseOwnerMapping);
        NPS_Mapping__c caseOwnerMapping1 = new NPS_Mapping__c(Name='Case Owner Tier',Source__c='Segment__c,Region__c,Commercial_Account_Tier__c',Type__c='Case Owner');
        listOfNpsMapping.add(caseOwnerMapping1);
        NPS_Mapping__c passiveMapping = new NPS_Mapping__c(Name='Passive Promoter',Source__c='Segment__c,Region__c',Type__c='Passive Promoter');
        listOfNpsMapping.add(passiveMapping);
        NPS_Mapping__c passiveMapping1 = new NPS_Mapping__c(Name='Passive Promoter Tier',Source__c='Segment__c,Region__c,Commercial_Account_Tier__c',Type__c='Passive Promoter');
        listOfNpsMapping.add(passiveMapping1);
        NPS_Mapping__c fieldMapping = new NPS_Mapping__c(Name = 'Case Mapping',Source__c = 'MaritzCX__Survey_Response__c.MaritzCX__Metric_1__c',Target__c = 'Case.Segment__c',Type__c = 'Mapping');
        listOfNpsMapping.add(fieldMapping);
        NPS_Mapping__c fieldMapping1 = new NPS_Mapping__c(Name = 'Survey Response Mapping',Source__c = 'NPS_Matrix__c.Additional_Recipient_1__c',Target__c = 'MaritzCX__Survey_Response__c.Additional_Recipient_1__c',Type__c = 'Mapping');
        listOfNpsMapping.add(fieldMapping1);
        NPS_Mapping__c fieldAdvocate = new NPS_Mapping__c(Name = 'Field Advocate',Source__c = 'Segment__c,NPS_Score__c',Target__c = 'MaritzCX__Survey_Response__c.Field_Advocate__c',Type__c = 'Field Advocate');
        listOfNpsMapping.add(fieldAdvocate);
        NPS_Mapping__c validationMapping1 = new NPS_Mapping__c(Name = 'Validation',Source__c = 'Segment__c',Target__c = 'MaritzCX__Metric_1__c',Type__c = 'Validation');
        listOfNpsMapping.add(validationMapping1);
        NPS_Mapping__c validationMapping2 = new NPS_Mapping__c(Name = 'Validation',Source__c = 'Region__c',Target__c = 'MaritzCX__Metric_3__c',Type__c = 'Validation');
        listOfNpsMapping.add(validationMapping2);
        NPS_Mapping__c validationMapping3 = new NPS_Mapping__c(Name = 'Validation',Source__c = 'Commercial_Account_Tier__c',Target__c = 'Commercial_Account_Tier__c',Type__c = 'Validation');
        listOfNpsMapping.add(validationMapping3);
        NPS_Mapping__c validationMapping4 = new NPS_Mapping__c(Name = 'Validation',Source__c = 'Status__c',Target__c = 'MaritzCX__Respondent_State__c',Type__c = 'Validation');
        listOfNpsMapping.add(validationMapping4);
        NPS_Mapping__c validationMapping5 = new NPS_Mapping__c(Name = 'Validation',Source__c = 'CX_Email__c',Target__c = 'MaritzCX__Metric_4__c',Type__c = 'Validation');
        listOfNpsMapping.add(validationMapping5);
        NPS_Mapping__c validationMapping6 = new NPS_Mapping__c(Name = 'Validation',Source__c = 'OMS_Case_Manager__c',Target__c = 'MaritzCX__Metric_5__c',Type__c = 'Validation');
        listOfNpsMapping.add(validationMapping6);
        NPS_Mapping__c validationMapping7 = new NPS_Mapping__c(Name = 'Validation',Source__c = 'GCP_PM__c',Target__c = 'MaritzCX__Metric_6__c',Type__c = 'Validation');
        listOfNpsMapping.add(validationMapping7);
        NPS_Mapping__c validationMapping8 = new NPS_Mapping__c(Name = 'Validation',Source__c = 'NPS_Score__c',Target__c = 'MaritzCX__Key_Metric_1__c',Type__c = 'Validation');
        listOfNpsMapping.add(validationMapping8);
        insert listOfNpsMapping;
        List<NPS_Matrix__c> listOfMatrix = new List<NPS_Matrix__c>();
        NPS_Matrix__c matrix = new NPS_Matrix__c(Name='Case Creation',Type__c='Case Creation',Segment__c='Enterprise',NPS_Score__c=6,Status__c='Completed',IsActive__c=true);
        listOfMatrix.add(matrix);
        NPS_Matrix__c matrix1 = new NPS_Matrix__c(Name='Case Owner',IsActive__c=true,Type__c='Case Owner',Segment__c='Enterprise',NPS_Score__c=6,Region__c='APAC',Additional_Recipient_1__c=atRole.Id,Account_Team_Role_1__c=atRole.Id,CX_Email__c=true,OMS_Case_Manager__c=true,GCP_PM__c=true);
        listOfMatrix.add(matrix1);
        NPS_Matrix__c matrix2 = new NPS_Matrix__c(Name='Case Owner Tier',IsActive__c=true,Type__c='Case Owner',Segment__c='Enterprise',NPS_Score__c=6,Region__c='APAC',Additional_Recipient_1__c=atRole.Id,Account_Team_Role_1__c=atRole.Id,CX_Email__c=true,OMS_Case_Manager__c=true,GCP_PM__c=true,Commercial_Account_Tier__c='T1');
        listOfMatrix.add(matrix2);
        NPS_Matrix__c matrix3 = new NPS_Matrix__c(Name='Passive Promoter',IsActive__c=true,Type__c='Passive Promoter',Segment__c='Commercial',NPS_Score__c=7,Region__c='APAC',Additional_Recipient_1__c=atRole.Id,Account_Team_Role_1__c=atRole.Id,CX_Email__c=true,OMS_Case_Manager__c=true,GCP_PM__c=true);
        listOfMatrix.add(matrix3);
        NPS_Matrix__c matrix4 = new NPS_Matrix__c(Name='Passive Promoter Tier',IsActive__c=true,Type__c='Passive Promoter',Segment__c='Commercial',NPS_Score__c=7,Region__c='APAC',Additional_Recipient_1__c=atRole.Id,Account_Team_Role_1__c=atRole.Id,CX_Email__c=true,OMS_Case_Manager__c=true,GCP_PM__c=true,Commercial_Account_Tier__c='T1');
        listOfMatrix.add(matrix4);
        NPS_Matrix__c matrix5 = new NPS_Matrix__c(Name='Field Advocate',IsActive__c=true,Type__c='Field Advocate',Segment__c='Commercial',NPS_Score__c=7,Region__c='APJ',Advocate__c='test@dell.com');
        listOfMatrix.add(matrix5);
        insert listOfMatrix;
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipCaseTriggers(true);
        List<MaritzCX__Survey_Response__c> listOfResponse = new List<MaritzCX__Survey_Response__c>();
        MaritzCX__Survey_Response__c response = new MaritzCX__Survey_Response__c(MaritzCX__ALG_Response_Id__c=123,MaritzCX__ALG_Survey_Id__c=123,Name='Test Response',MaritzCX__Contact_Id__c=testContact.Id,MaritzCX__Account__c=testAccount.Id,MaritzCX__Key_Metric_1__c=6,MaritzCX__Metric_1__c='Enterprise',MaritzCX__Metric_3__c='APAC',MaritzCX__Metric_4__c='test@test.com,test@test1.com',MaritzCX__Metric_5__c='test@test.com,test@test1.com',MaritzCX__Metric_6__c='test@test.com',MaritzCX__Respondent_State__c='Completed');
        listOfResponse.add(response);
        MaritzCX__Survey_Response__c response1 = new MaritzCX__Survey_Response__c(MaritzCX__ALG_Response_Id__c=1234,MaritzCX__ALG_Survey_Id__c=1234,Name='Test Response',MaritzCX__Contact_Id__c=testContact.Id,MaritzCX__Account__c=testAccount.Id,MaritzCX__Key_Metric_1__c=6,MaritzCX__Metric_1__c='Enterprise',MaritzCX__Metric_3__c='APAC',MaritzCX__Metric_4__c='test@test.com',MaritzCX__Metric_5__c='test@test.com',MaritzCX__Metric_6__c='test@test.com');
        listOfResponse.add(response1);
        MaritzCX__Survey_Response__c response2 = new MaritzCX__Survey_Response__c(MaritzCX__ALG_Response_Id__c=1235,MaritzCX__ALG_Survey_Id__c=1235,Name='Test Response',MaritzCX__Contact_Id__c=testContact.Id,MaritzCX__Account__c=testAccount.Id,MaritzCX__Key_Metric_1__c=7,MaritzCX__Metric_1__c='Commercial',MaritzCX__Metric_3__c='APAC',MaritzCX__Metric_4__c='test@test.com,test@test1.com',MaritzCX__Metric_5__c='test@test.com,test@test1.com',MaritzCX__Metric_6__c='test@test.com');
        listOfResponse.add(response2);
        insert listOfResponse;
        TriggerExecutionController.setSkipCaseTriggers(false);
    }
}