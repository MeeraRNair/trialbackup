/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      13796       FY17-DCS-0103   14-Dec-2016     Fenny           Update Install Base roll up summary in Account by invoke a flow
*/

@isTest
public class InstallBaseTriggerHandlerADTest{
    
    static testmethod void testDeleteInstallBase(){
        TriggerExecutionController.setSkipAccountTriggers(true);
        InstallBaseUtilities.isTest = true;
        
        Account acc = new Account(Name = 'testAccount', NumberOfEmployees = 14);
        insert acc; 
        
        //List<RecordType> RT=[select id from RecordType where SobjectType='Install_Base__c' and name='Software LOB' limit 1];
        Id ibRTId= IdLookupUtils.getRecordTypeId('Software LOB','Install_Base__c',true);
        
        
        List<Install_Base__c> listInstallBase = new List<Install_Base__c>();
        listInstallBase.add(new Install_Base__c(Account__c = acc.id, of_Employees__c = 11, LOB__c = 'software', RecordTypeid = ibRTId));
        listInstallBase.add(new Install_Base__c(Account__c = acc.id, of_Employees__c = 12, LOB__c = 'software', RecordTypeid = ibRTId));
        listInstallBase.add(new Install_Base__c(Account__c = acc.id, of_Employees__c = 14, LOB__c = 'software', RecordTypeid = ibRTId));
        insert listInstallBase;
        
        acc = [SELECT Competitive_Information_Count__c FROM Account WHERE Id = :acc.Id];
        system.assertEquals(listInstallBase.size(), acc.Competitive_Information_Count__c);
        
        Install_Base__c ib = [SELECT Id FROM Install_Base__c WHERE Id = :listInstallBase[1].Id];
        delete ib;
        
        acc = [SELECT Competitive_Information_Count__c FROM Account WHERE Id = :acc.Id];
        system.assertEquals((listInstallBase.size() - 1), acc.Competitive_Information_Count__c);
        
        TriggerExecutionController.setSkipAccountTriggers(false);
    }
}