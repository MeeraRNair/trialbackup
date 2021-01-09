@isTest
public class WebServiceExceptionHandlingTest {
    static testMethod void testExceptionHandle(){
        WebServiceExceptionHandling.insertException('reqBody', 'resBody', 987654 , 'testHandle', 'Exception__c');
        Database.SaveResult[] listsr1 =new Database.SaveResult[]{};
        Database.SaveResult sr = (Database.SaveResult)
    JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
         listsr1.add(sr);
         WebServiceExceptionHandling.exceptionHandlingMethod(listsr1,'exceptionhandling','exceptionProcess','exceptionError',null,null);
         system.assertEquals('test','test');
    }     
}