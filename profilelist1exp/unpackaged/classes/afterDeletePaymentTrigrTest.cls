@isTest
private class afterDeletePaymentTrigrTest {

    private static testmethod void afterDeletePaymentTrigger(){
    
        Account account = new Account(name='HubTest',account_country_code__c='US');
        insert account;
        Mn__DellMNProgram__c PRoURec = new Mn__DellMNProgram__c();
        insert PRoURec;
        
        Mn__DellMnPayment__c PaymentURec = new Mn__DellMnPayment__c();
        PaymentURec.Mn__Program__c = PRoURec.id;
        PaymentURec.Mn__Partner__c = account.id;
        
       insert PaymentURec;
        List <Mn__DellMnPayment__c>  PaymentUTest = [Select Mn__PYMT_PKG_ID__c, Id from Mn__DellMnPayment__c where Id = : PaymentURec.id];
        delete PaymentURec;
        
        Test.startTest();
            
        List <Partner_Hub_Record_Deleted__c>  PartnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = : PaymentURec.id];
        Integer myIntegerKey = Integer.valueOf(PaymentUTest[0].Mn__PYMT_PKG_ID__c);

        //Convert Integer type to String
        String myStringKey = String.valueOf(myIntegerKey);
        PartnerHubRecTest[0].Key_Identifier__c = myStringKey ;
        PartnerHubRecTest[0].Record_GUID__c = PaymentUTest[0].Id ;
        PartnerHubRecTest[0].Type__c = 'Payment' ;
                
        Test.stopTest();
        delete account;
		delete PRoURec;
    }
}