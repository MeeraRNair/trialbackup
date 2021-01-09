/*
 * Author   : Anuj Shah
 * Purpose  :  create test data for Utils class. 
 *
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0                  FY20-0102       18-Oct-2019     Anuj            Created.
 */
 
@isTest
public class CaseCSHTriggerHandlerBITest {

    static testmethod void caseCreateTriggerTest(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Case", "Class_Name__c": "CaseCSHTriggerHandlerBI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        Account objAcc = new Account(Name = 'Testacc');
        insert objAcc;
        
        Profile pf= [Select Id from profile where Name='Presales Service Rep'];
        String strOrgId=UserInfo.getOrganizationId(); 
        String strDateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer intRandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String strUniqueName=strOrgId+strDateString+intRandomId;
        User uu1=new User(firstname = 'user1', 
                          lastName = 'XYZ', 
                          email = strUniqueName + '.123@dell.com', 
                          Username = strUniqueName + '@test' + strOrgId + '.org', 
                          EmailEncodingKey = 'ISO-8859-1', 
                          Alias = strUniqueName.substring(18, 23), 
                          TimeZoneSidKey = 'America/Los_Angeles', 
                          LocaleSidKey = 'en_US', 
                          LanguageLocaleKey = 'en_US', 
                          Badge_Number__c = 'test1' + Integer.valueOf(Math.rint(Math.random()*1000000)),
                          ProfileId = pf.Id
                         );
        insert uu1;
        
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
        objCase.Origin = 'EmailESP'; 
        objCase.Priority = 'Normal';
        objCase.SuppliedEmail = uu1.email;
        objCase.Unauthenticated_Case__c = true;
        objCase.Unauthenticated_Contact_Email__c = uu1.email;
        insert objCase;
        system.assertequals(idCSH,objCase.recordtypeid); 
        
    }
    
    static testmethod void caseCreateInternalTriggerTest(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Case", "Class_Name__c": "CaseCSHTriggerHandlerBI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        Account objAcc = new Account(Name = 'Testacc');
        insert objAcc;
        
        Profile pf= [Select Id from profile where Name='Presales Service Rep'];
        String strOrgId=UserInfo.getOrganizationId(); 
        String strDateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer intRandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String strUniqueName=strOrgId+strDateString+intRandomId;
        User uu1=new User(firstname = 'user1', 
                          lastName = 'XYZ', 
                          email = strUniqueName + '.123@dell.com', 
                          Username = strUniqueName + '@test' + strOrgId + '.org', 
                          EmailEncodingKey = 'ISO-8859-1', 
                          Alias = strUniqueName.substring(18, 23), 
                          TimeZoneSidKey = 'America/Los_Angeles', 
                          LocaleSidKey = 'en_US', 
                          LanguageLocaleKey = 'en_US', 
                          Badge_Number__c = 'test1' + Integer.valueOf(Math.rint(Math.random()*1000000)),
                          ProfileId = pf.Id
                         );
        insert uu1;
        
        Contact objCon = new Contact(
            AccountId = objAcc.Id,
            Email = 'test@live.com',
            phone = '123456',
            LastName = 'conLN',
            FirstName = 'conFN',
            Status__c = 'Open');
        insert objCon;
        Id idCSH= IdLookupUtils.getRecordTypeId('Channel Services Helpdesk (internal only)','Case',true);
        Case objCase = new Case();
        objCase.recordtypeid = idCSH;
        objCase.Status = 'Open';
        objCase.Unauthenticated_Case__c = false;
        objCase.AccountId = objAcc.Id;
        objCase.ContactId = objCon.id;
        objCase.Description = 'Unit Testing';
        objCase.Subject = 'Unit Testing';
        objCase.Origin = 'EmailESP'; 
        objCase.Priority = 'Normal';
        objCase.SuppliedEmail = uu1.email;
        insert objCase;
        system.assertequals(idCSH,objCase.recordtypeid); 
        
    }
}