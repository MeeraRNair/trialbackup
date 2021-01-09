/*
* Author   : Krishnamoorthi
* Purpose  : Test class for ServicesProvidedSearchFormCtrl.
*        
* Revision  Ref Number  Release No      Date            Modified By     Description
* --------  ----------  ----------      -----------     ------------    -----------
* 1.0       CR 12482    R16.12          18-Dec-2015     Krishnamoorthi  Created.
* 2.0       CR 15690    FY19-DCE-0602   27-Apr-2018     Emily           Field Trip clean up for Account (Part 2)
*/

@isTest
public class ServicesProvidedSearchFormCtrlTest {
    
    //Search logic unit test code
    static testMethod void testServicesProvidedSearchFormCtrl(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        //Insert test Account
        //v2.0 removing Services related fields from Account
        Account testAcct = new Account(Name='Test Account', Reference_Type__c='Respond to RFx', Dell_Services_Industry__c='BFSI');
         
                                    
        insert testAcct; 
        
        //Insert test Services Product records
        Product2 newPrdct1 = new Product2(Name = 'Test Product1', ProductCode = 'prdcd1', Description = 'ProductDesc1', Product_Line_Desc__c = 'ProductLineD1', IsActive = TRUE, Family = 'Services', Product_ID__c = '12345' + System.currentTimeMillis());
        insert newPrdct1;
        
        Product2 newPrdct2 = new Product2(Name = 'Test Product2', ProductCode = 'prdcd2', Description = 'ProductDesc2', Product_Line_Desc__c = 'ProductLineD2', IsActive = TRUE, Family = 'Services', Product_ID__c = '12345' + System.currentTimeMillis());
        insert newPrdct2;
        
        Product2 newPrdct3 = new Product2(Name = 'Test Product3', ProductCode = 'prdcd3', Description = 'ProductDesc3', Product_Line_Desc__c = 'ProductLineD3', IsActive = TRUE, Family = 'Services', Product_ID__c = '12345' + System.currentTimeMillis());
        insert newPrdct3;
        
        Product2 newPrdct4 = new Product2(Name = 'Test Product4', ProductCode = 'prdcd4', Description = 'ProductDesc4', Product_Line_Desc__c = 'ProductLineD4', IsActive = TRUE, Family = 'Services', Product_ID__c = '12345' + System.currentTimeMillis());
        insert newPrdct4;
        
        Product2 newPrdct5 = new Product2(Name = 'Test Product5', ProductCode = 'prdcd5', Description = 'ProductDesc5', Product_Line_Desc__c = 'ProductLineD5', IsActive = TRUE, Family = 'Services', Product_ID__c = '12345' + System.currentTimeMillis());
        insert newPrdct5;
        
        //Insert test Sales Product record
        Product2 newPrdct6 = new Product2(Name = 'Test Product6', ProductCode = 'prdcd6', Description = 'ProductDesc6', Product_Line_Desc__c = 'ProductLineD6', IsActive = TRUE, Family = 'Sales', Product_ID__c = '12345' + System.currentTimeMillis());
        insert newPrdct6;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        List <Services_Provided__c> SP = new List<Services_Provided__c>();
        Test.startTest();
        ServicesProvidedSearchFormCtrl SPcntrlr = new ServicesProvidedSearchFormCtrl(new ApexPages.StandardSetController(SP));
        SPcntrlr.strBrandDesc = 'Test';
        SPcntrlr.strProductGroup = '';
        SPcntrlr.strProductDesc = '';
        SPcntrlr.strProductLineDesc = '';
        SPcntrlr.PAGE_SIZE = 3;
        SPcntrlr.doSearch();
        
        //Assert only 5 Services products are queried, not the Sales Product after the search
        system.assertEquals(5, SPcntrlr.setCon.getResultSize());

        //Check for the pagination variables
        SPcntrlr.getproductListWrap();
        SPcntrlr.colCheck = true;
        SPcntrlr.acctId = testAcct.Id;
        SPcntrlr.selectAllProducts();
        List<ServicesProvidedSearchFormCtrl.productWrapper> searchedProducts = SPcntrlr.productListWrap;
        
        system.assert(searchedProducts[0].prodCheck);
        system.assert(searchedProducts[1].prodCheck);
        system.assert(searchedProducts[2].prodCheck);
        
        system.assert(SPcntrlr.hasNext);
        system.assert(!SPcntrlr.hasPrevious);
        SPcntrlr.next();
        SPcntrlr.getproductListWrap();
        system.assert(SPcntrlr.hasPrevious);
        SPcntrlr.colCheck = true;
        SPcntrlr.selectAllProducts();
        SPcntrlr.previous();
        system.assert(SPcntrlr.hasNext);
        system.assert(!SPcntrlr.hasPrevious);
        SPcntrlr.getproductListWrap();
        SPcntrlr.Save();
        
        //Check for new Services Provided records are inserted after Saving the selected Products
        List <Services_Provided__c> SPRecordList = new List<Services_Provided__c>();
        SPRecordList = [SELECT Id, Account__r.Id, Services_Product__c FROM Services_Provided__c WHERE Account__r.Id =: testAcct.Id];
        system.assertEquals(5, SPRecordList.size());
        system.assertEquals(testAcct.Id, SPRecordList[0].Account__r.Id);
        
        //Check for some other condition to cover the code
        SPcntrlr.getHasPreviousAndNext();
        SPcntrlr.strProductGroup = 'prdcd2';
        SPcntrlr.strProductDesc = 'ProductDesc5';
        SPcntrlr.strProductLineDesc = 'ProductlineDesc5';
        SPcntrlr.doSearch();
        Test.stopTest();
    }

}