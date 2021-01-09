/**
 * Name: PublicGroupUpdateTestClass
 * Author: Patrick Redor
 * Date: November 05,2012
 */
@isTest
private class PublicGroupUpdateTestClass{
    
    static testMethod void PublicGroupUpdateTestMethod() {
        Group grp = new Group(Name = 'SnP: TestBrand Product Managers', DeveloperName = 'SnP_TestBrand_Product_Managers');
        insert grp;
        
        User u1 = [SELECT Id, Alias FROM User WHERE Id = '00570000001J28O'];
        User u2 = [SELECT Id, Alias FROM User WHERE Id = '005A00000018WZq'];
        
        S_P_DR_Criteria__c spdr = new S_P_DR_Criteria__c(Name = 'Test Criteria', Brand_Desc__c = 'TestBrand',
                                        Product_Line_Desc__c = 'Test', Min_NET__c = 1000, Min_Qty__c = 50,
                                        Min_days_before_Book_Date__c = 5, CurrencyIsoCode = 'USD', Region__c = 'EMEA',
                                        PM1__c = u1.id, PM2__c = u2.id);
        Test.startTest();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert spdr;
        }
        
        Test.stopTest();
    }
}