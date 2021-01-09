/***********************************************************
* Name          : Test_CaseManagement
* Description   : Test Class for CaseManagement class
* ---------------------------------------------------------
* Revision  Name       Date             Description
*  1.0      Rahul      26. March. 2018  To validate the case managment class functionality
************************************************************/

@isTest
public class Test_CaseManagement{
    
    
    public static testMethod void test1(){
        TriggerExecutionController.setSkipAccountTriggers(True);
        TriggerExecutionController.setSkipContactTriggers(True);
        TriggerExecutionController.setSkipOpportunityTriggers(True);
        TriggerExecutionController.setSkipUserTriggers(True);
        TriggerExecutionController.setSkipCaseTriggers(True);
        TriggerExecutionController.setSkipCampaignTriggers(True);
        TriggerExecutionController.setSkipCampaignValidator(True);
        
        List<Case> lstCase = new List<Case>();
        Map<Id, Case> mapOldCases = new Map<Id, Case> ();
        Map<Id, Account> mapRelatedAccounts = new Map<Id, Account>();
        
        
        List<Case> lstCase1 = new List<Case>();
        Map<Id, Case> mapOldCases1 = new Map<Id, Case> ();
        
        Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> accData = new List<Account>();
        Account testAccount = new Account(Name='testOppDistiUser Test Account', 
                                          RecordTypeId = accRTyId, 
                                          Partner_Type__c = 'COMMERCIAL',
                                          Partner_Tier__c = 'Tier',
                                          Partner_Relationship__c = 'Registered',
                                          Account_Country__c = 'United States' );        
        accData.add(testAccount);
        insert accData;
        
        Country__c indiaCountry = new Country__c(Name = 'India', Region__c = 'APJ', Code__c = 'en_IN', CurrencyIsoCode = 'USD');
        insert indiaCountry;
        
        AccountTeamMember objATM = new AccountTeamMember (UserId = UserInfo.getUserId(), TeamMemberRole = 'Account Executive', AccountId = accData[0].Id); 
        insert objATM;
        
        Contact newCont = new Contact(FirstName = 'MyTestContact7653',
                                      LastName = 'MyTestContact76523',
                                      AccountId =testAccount.Id,
                                      Status__c  =  'Marketing Suspect',
                                      Email = 'MyTestContactEmail_3@dell.com',
                                      Fax = '12344567',
                                      // MobilePhone = '0987676534',
                                      Last_Operation_Performed__c = 'testing');
        //Phone = '123453400');
        insert newCont;
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];
        
        User partnerUserGC = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                      Alias = 'MTU9', 
                                      Email='MyTestUser9@dell.com', 
                                      FirstName='MyTestUser9', 
                                      LastName='MyTestUser9',  
                                      ProfileId = p.Id, 
                                      LanguageLocaleKey='zh_CN', 
                                      LocaleSidKey='zh_CN', 
                                      EmailEncodingKey='UTF-8', 
                                      TimeZoneSidKey='America/Los_Angeles',
                                      Badge_Number__c='Test99826513', 
                                      isActive = TRUE,
                                      ContactId = newCont.Id);
        insert partnerUserGC;
        
        
        Id trcrRTId = StaticFactory.getRecordTypeIdByName('Case', 'Training & Certification');
        Id lead2RTId = IdLookupUtils.getRecordTypeId('Talk to Dell','Lead',true);
        Id pLMCaseRTId= IdLookupUtils.getRecordTypeId('Global Lead Management Intake','Case',true);
        List<Campaign> listCamp = new List<Campaign>();
        Id campRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);
        Campaign cMAPtestCampaign = new Campaign(Name='CMAP Campaign',
                                                 Campaign_Objective__c = 'LOB Conversion',
                                                 Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
                                                 StartDate=System.Today() - 10,
                                                 EndDate=System.Today(),
                                                 Description='This is Test Campaign',
                                                 IsActive=true,
                                                 RecordTypeID= campRTId,
                                                 partner_Inquiry_Case_Owner__c = 'Account Owner');
        listCamp.add(cMAPtestCampaign);
        insert listCamp;
        Lead sLead = new Lead(LastName = 'Test Sales Lead', 
                              Lead_Type__c = 'Inbound',
                              RecordTypeId =lead2RTId, 
                              Email = 'testcmap@test.com',
                              Status = 'Accepted',
                              Phone = '88967544',
                              Country = 'US',
                              Campaign__c = cMAPtestCampaign.Id,
                              Company = 'Test Company',
                              LeadSource='Partner',
                              Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');
        insert sLead;
        
        case newCase = new Case();
        newCase.RecordTypeId = pLMCaseRTId;
        newCase.NPS_Category__c = 'ractor';
        newCase.Requesting_Region__c = 'Global';
        newCase.Sub_Type_Internal_User__c = 'Lead Load Request';
        newCase.Lead_Type__c = 'Inbound Lead';
        newCase.Country_Area__c = 'India';
        newCase.SuppliedEmail ='';
        newCase.AccountId = testAccount.Id;
        newCase.ContactId = newCont.id;
        //  newCase.Order_Number__c = '123432';
        newCase.Alternate_Phone__c = '745476';
        newCase.Description = '1';
        newCase.Subject = '2';
        newCase.Priority = 'High';
        newCase.Status = 'Open';
        newCase.Country_Area__c = 'India';
        newCase.Origin ='Partner Portal';
        newCase.Sub_Type_Partner_User__c = 'Access Issues';
        newCase.Sub_Type_Internal_User__c = 'Access Issues';
        newCase.Case_Category__c = 'Internal';
        newCase.Lead_ID__c=sLead.Id;
        newCase.OwnerId = UserInfo.getUserId();
        
        case newCase1 = new Case();
        newCase1.RecordTypeId = pLMCaseRTId;
        newCase1.NPS_Category__c = 'ractor';
        newCase1.Requesting_Region__c = 'Global';
        newCase1.Sub_Type_Internal_User__c = 'Lead Load Request';
        newCase1.Lead_Type__c = 'Inbound Lead';
        newCase1.Country_Area__c = 'India';
        newCase1.SuppliedEmail ='';
        newCase1.ContactId = newCont.id;
        //  newCase.Order_Number__c = '123432';
        newCase1.Alternate_Phone__c = '745476';
        newCase1.Description = '1';
        newCase1.Subject = '2';
        newCase1.Priority = 'High';
        newCase1.Status = 'Open';
        newCase1.Country_Area__c = 'India';
        newCase1.Origin ='Partner Portal';
        newCase1.Sub_Type_Partner_User__c = 'Access Issues';
        newCase1.Sub_Type_Internal_User__c = 'Access Issues';
        newCase1.Case_Category__c = 'Internal';
        newCase1.OwnerId = UserInfo.getUserId();
        
        
        Case partnerLMCase = new Case();
        
        partnerLMCase.RecordTypeId=pLMCaseRTId;
        partnerLMCase.Subject = 'Test Partner LM Intake Case';
        partnerLMCase.Description = 'Test Partner LM Intake Case';                                                  
        partnerLMCase.Priority = 'Medium';
        partnerLMCase.Requesting_Country__c = 'India';
        partnerLMCase.Requesting_Region__c = 'APJ';
        partnerLMCase.Pickup_Address_Details__c = 'Test';
        partnerLMCase.ContactId = newCont.Id;
        partnerLMCase.AccountId = accData[0].id;
        partnerLMCase.Sub_Type_Internal_User__c='Lead Load Request';
        partnerLMCase.Lead_Type__c='Inbound Lead';
        partnerLMCase.Alternate_Phone__c='1234656';
        partnerLMCase.Lead_ID__c=sLead.Id;
        partnerLMCase.Status = 'Open';
        
        
        Test.startTest();
        insert newCase;
        insert newCase1;
        
        
        
        lstCase.add(newCase);
        lstCase1.add(newCase1);
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON6464',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'rahul.mishra@dell.com',
                            Username = 'rahul.mishra@delldit3.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8', 
                            LocaleSidKey = 'en_US',
                            Badge_Number__c = 'test6354'
                           );
        
        insert usr;  
        system.assertEquals(usr, usr);
        mapOldCases.put(newCase.Id, newCase);
        mapOldCases1.put(newCase1.Id, newCase1);
        mapRelatedAccounts.put(accData[0].id, accData[0]);
            
        CaseManagement.validateAndPopulateFields(lstCase, mapOldCases, mapRelatedAccounts);
        CaseManagement.validateAndPopulateFields(lstCase1, mapOldCases1, mapRelatedAccounts);
             
        //  }
        
    }
    
}