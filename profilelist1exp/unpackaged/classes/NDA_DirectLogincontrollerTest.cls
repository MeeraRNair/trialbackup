@istest
public class NDA_DirectLogincontrollerTest {
    @istest
    public static void getRequest(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new NDA_DirectLogincontrollerMock());
        NDA_DirectLogincontroller  objNDA= new NDA_DirectLogincontroller ();
        String strProfile = objNDA.getCommunication();
        objNDA.getCall();
        system.assertEquals('System Administrator Mock Class',strProfile);
        test.stopTest();
    }
}