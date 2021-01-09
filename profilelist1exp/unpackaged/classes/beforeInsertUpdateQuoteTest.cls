/***********************************************************
* Name          : beforeInsertUpdateQuoteTest 
* Description   : beforeInsertUpdateQuote Test
* ---------------------------------------------------------
* Revision      CR#             Release      Name                             Date              Description
* 1.0           8628            14.10        Che Saidi, Shahiruni Wahida      04 Sept 2013      Creation
*
*
************************************************************/

@isTest
private class beforeInsertUpdateQuoteTest {

    static testMethod void myUnitTest() {
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'Storage Systems');
        insert product;
        PricebookEntry entry = new PricebookEntry(UnitPrice = 0.00, Product2Id = product.Id, Pricebook2Id = '01s300000001iPvAAI', UseStandardPrice = false, 
        											IsActive = true);
        insert entry;
        Opportunity oppty = new Opportunity(Name = 'UnitTestOppty', StageName = 'Win - 100%', CloseDate = Date.today().addDays(-5), Competitor_Lost_To__c = 'Unknown');
        insert oppty;
        Quote quote = new Quote (Name = 'UnitTestQuote', OpportunityId = oppty.Id, Pricebook2Id = '01s300000001iPvAAI');
        insert quote;
        //system.assert(123.45, quote.GrandTotalFromTrigger__c);
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 100.0, quantity = 2.0, discount = 10,
                                                QuoteId = quote.Id, PricebookEntryId = entry.Id);
        insert qli;
        Quote q = [SELECT TotalPrice, GrandTotal, GrandTotalFromTrigger__c FROM Quote WHERE Id = :quote.Id];
        system.debug('^^^^^^^^^^^^^^^^^^ 1 ^^^^^^^^^^^^^^^^^^^ ' + quote.TotalPrice);
        system.debug('^^^^^^^^^^^^^^^^^^ 2 ^^^^^^^^^^^^^^^^^^^ ' + quote.GrandTotal);
        system.debug('^^^^^^^^^^^^^^^^^^ 3 ^^^^^^^^^^^^^^^^^^^ ' + quote.GrandTotalFromTrigger__c);
    }
}