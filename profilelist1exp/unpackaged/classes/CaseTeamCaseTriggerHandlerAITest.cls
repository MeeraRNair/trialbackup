/*
 * Author   : Haribabu Adra
 * Purpose  : Utility test class for creating Case related data. 
 *
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0                  FY20-1002       09-Aug-2019     Hari A            Created.
 */
@isTest
public class CaseTeamCaseTriggerHandlerAITest {
    static testmethod void caseTeamCaseTriggerTest(){
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Case", "Class_Name__c": "CaseTeamCaseTriggerHandlerAI"},';
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
        insert objCase;
        system.assertequals(idCSH,objCase.recordtypeid); 
       
    } 

}