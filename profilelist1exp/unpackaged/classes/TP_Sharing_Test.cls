/* Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR15172    	FY18-DCS-0102   27-Nov-2017     Harsha        	Unit test to cover the TP_Sharing
 */

@isTest
public class TP_Sharing_Test {
    
    public static testMethod void sharingtest(){
        triggerexecutioncontroller.setSkipAllTriggers(True);
                
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
            try{
                tp.manager_approver__c = tpSales.id;
                update tp;
            }
            catch(exception e){}
        }
    }
}