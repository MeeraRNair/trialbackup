/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 13379                02-Aug-2016     Meera         Customer Selection - Check Duplicates before Adding New Customer
 * 
 * 
 *      
 */
@isTest
private class DealReg_CustomerSelectionHelperTest {

    static testMethod void dunsnumdupeTest() {
        // Create Partner Account
        TriggerExecutionController.setSkipAllTriggers(true);
        Account partneraccount = new Account(name='DupeTestAcc',account_country_code__c='US');
        insert partneraccount ;
        partneraccount.isPartner = true;
        partneraccount.Type = 'Partner';
        update partneraccount;
        
        
        
        End_Customer__c newendcutomer = new End_Customer__c();
        newendcutomer.DUNS_Number__c = '111111';
        newendcutomer.Name = 'Test Dupe DUNS Zeus';
        newendcutomer.Mailing_street__c = 'Test sreet';
        newendcutomer.Mailing_city__c = 'Test City';
        newendcutomer.Mailing_State__c = 'Test State';
        newendcutomer.Zip_Code__c = '34454';
        newendcutomer.Mailing_country__c = 'United States';
        newendcutomer.Tax_Id__c = '34567';
        newendcutomer.Source_System__c = 'Deal Registration';
        newendcutomer.Partner_Account__c = partneraccount.Id;
        insert newendcutomer;
        
        //Create end customer contact
        End_Customer_Contact__c endcustomerCntact = new End_Customer_Contact__c();
        
        endcustomerCntact.End_Customer__c = newendcutomer.id;
        endcustomerCntact.Last_Name__c = 'DupeTest';
        endcustomerCntact.Name = 'Zeus';
        endcustomerCntact.Email__c = 'NoReply@dell.com';
        endcustomerCntact.Source_System__c = 'Deal Registration';
        insert endcustomerCntact;
        
        Test.startTest();
        
        System.assertEquals(DealReg_CustomerSelectionHelper.checkEndCustomerDuplicate('111111',null,partneraccount.id).Name,newendcutomer.Name);
        System.assertEquals(DealReg_CustomerSelectionHelper.checkEndCustomerDuplicate(null,'Test Dupe DUNS Zeus',partneraccount.id).Name,newendcutomer.Name);
        System.assertEquals(DealReg_CustomerSelectionHelper.checkEndCustomerContactDuplicate('NoReply@dell.com',newendcutomer.id),'Zeus DupeTest');
        Test.stopTest();
        
        
    }
}