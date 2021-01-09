/*
* Author   : Subhasini Bhosal
* Purpose  : Utility test class for creating Case related data after update. 
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0                  FY20-1002       21-Aug-2019     Subhasini        Test method for case resolved notification to case team members .
*/

@isTest
private class CaseTeamNotifyCaseTriggerHandlerAUTest {
    static testmethod void caseTeamCaseTriggerTest(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUpdate' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Case", "Class_Name__c": "CaseTeamNotificationCaseTriggerHandlerAU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        Account objAcc = new Account(Name = 'Testacc');
        insert objAcc;
        
        Contact objCon = new Contact(
            AccountId = objAcc.Id,
            Email = 'test@live.com',
            phone = '123456',
            LastName = 'conLN',
            FirstName = 'conFN',
            Status__c = 'Open');
        insert objCon;
        
        Id idCSH= IdLookupUtils.getRecordTypeId('Channel Services Helpdesk','Case',true);
        Case objCase = new Case();
        objCase.recordtypeid = idCSH;
        objCase.Status = 'Open';
        objCase.Unauthenticated_Case__c = false;
        objCase.AccountId = objAcc.Id;
        objCase.ContactId = objCon.id;
        objCase.Description = 'Unit Testing';
        objCase.Subject = 'Unit Testing';
        
        Case objCase1 = new Case();
        objCase1.recordtypeid = idCSH;
        objCase1.Status = 'Open';
        objCase1.Unauthenticated_Case__c = false;
        objCase1.AccountId = objAcc.Id;
        objCase1.ContactId = objCon.id;
        objCase1.Description = 'Unit Testing';
        objCase1.Subject = 'Unit Testing';
        
        List<Case> listCase = new List<Case>();
        listCase.add(objCase);
        listCase.add(objCase1);
        insert listCase;
        
        system.assertequals(idCSH,objCase.recordtypeid); 
        final List<Profile> stdProfiles = [select Id, Name from Profile where Name like 'System Administrator' limit 1];
        
        User u = new User(
            Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
            Alias = 'adm', 
            Email='MyTestAdmin009@dell.com', 
            FirstName='MyTestAdmin1', 
            LastName='MyTestAdmin1',  
            ProfileId = stdProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Admin007', 
            isActive = TRUE
            
        );
        insert u;
        
        CaseTeamRole caseTeamRole = new CaseTeamRole();
        System.runAs (u) {            
            caseTeamRole.Name = 'Test Role';
            caseTeamRole.AccessLevel = 'Read';
            insert CaseTeamRole;
        }
        
        
        List<CaseTeamMember> listCaseTeams = new List<CaseTeamMember>();
        
        CaseTeamMember caseTeamCon = new CaseTeamMember(parentId = listCase[0].id,MemberId = objCon.Id,TeamRoleId = CaseTeamRole.Id);
        listCaseTeams.add(caseTeamCon);   
        
        CaseTeamMember caseTeamUser = new CaseTeamMember(parentId = listCase[0].id,MemberId = u.Id,TeamRoleId = CaseTeamRole.Id);
        listCaseTeams.add(caseTeamUser);  
        Insert listCaseTeams;
        
        System.runAs ( u ) {
            listCase[0].Status = 'Resolved';
            update listCase;
        }
        system.assertequals(listCase[0].Status,'Resolved'); 
        
        Test.startTest();
        
        CSHCaseTeamUtilities.sendEmailToCaseTeam(listCase);
        Test.stopTest();
         system.assert(listCaseTeams.size()>0); 
        
        
    }
    
}