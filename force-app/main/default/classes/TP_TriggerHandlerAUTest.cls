@IsTest
public class TP_TriggerHandlerAUTest {
	public static testMethod void sharingtest(){
       // triggerexecutioncontroller.setSkipAllTriggers(True);
                  String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Territory_Plan__c", "Class_Name__c": "TP_TriggerHandlerAU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        //User Record INSERTION
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        List<User> listUser = new List<User>();
        User tpManager1 = new User( Username='TestTPM' +System.currentTimeMillis() + '@test.com',
                             Alias = 'TPM'+056,
                             Email='testTPM'+ 012 +'@dell.com',
                             FirstName='TPM'+0,
                             LastName='TestBA'+100,
                             ProfileId = userProfile.Id,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US',
                             EmailEncodingKey='UTF-8',
                             TimeZoneSidKey='America/Los_Angeles',
                             Badge_Number__c='9000' + String.valueOf(Math.round(Math.random()*1000000000)));
        
        User tpSales = new User( Username='TesttpSales' +System.currentTimeMillis() + '@test.com',
                             Alias = 'tpSal'+056,
                             Email='testtpSales'+ 012 +'@dell.com',
                             FirstName='tpSales'+0,
                             LastName='TestBA'+100,
                             ProfileId = userProfile.Id,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US',
                             EmailEncodingKey='UTF-8',
                             TimeZoneSidKey='America/Los_Angeles',
                             Badge_Number__c='9000' + String.valueOf(Math.round(Math.random()*1000000000)));
        
        User tpManager2 = new User( Username='TestTPM2' +System.currentTimeMillis() + '@test.com',
                             Alias = 'TPM2'+056,
                             Email='testTPM2'+ 012 +'@dell.com',
                             FirstName='TPM2'+0,
                             LastName='TestBA2'+100,
                             ProfileId = userProfile.Id,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US',
                             EmailEncodingKey='UTF-8',
                             TimeZoneSidKey='America/Los_Angeles',
                             Badge_Number__c='9000' + String.valueOf(Math.round(Math.random()*1000000000)));
        
        listUser.add(tpManager1);
        listUser.add(tpSales);
        listUser.add(tpManager2);        
        insert listUser;
        triggerexecutioncontroller.setSkipAllTriggers(False);

        system.runas(tpSales){
            Territory_plan__c tp = new Territory_plan__c(name = 'test tp plan', manager_approver__c = tpManager1.id);
            insert tp;
            tp.manager_approver__c = tpManager2.id;
            update tp;

            Territory_Plan__Share tpShare = [SELECT AccessLevel, UserOrGroupId FROM Territory_Plan__Share WHERE ParentId = :tp.Id AND RowCause = :Schema.Territory_Plan__Share.RowCause.manual];
            system.assertEquals(tpManager2.Id, tpShare.UserOrGroupId);
            system.assertEquals('Edit', tpShare.AccessLevel);

            List<Territory_Plan__Share> listTPShr = [SELECT Id FROM Territory_Plan__Share WHERE UserOrGroupId = :tpManager1.Id];
            system.assertEquals(true, (listTPShr == null || listTPShr.isEmpty()));

            //try{
            //    tp.manager_approver__c = tpSales.id;
            //    update tp;
            //}
            //catch(exception e){}
        }
    }
}