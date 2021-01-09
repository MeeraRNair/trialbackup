@isTest(seeAllData=true)
public class AppProtocolControlPolicyConditionTest{
public static testMethod void testApps() {
System.Test.startTest() ;
        
        LoginHistory l = [ SELECT Application FROM LoginHistory Limit 1];
        /* Create a map for the event we’re going to build. */
        Map<String, String> eventData = new Map<String, String>();
        eventData.put('LoginHistoryId', l.Id);
        
         TxnSecurity.Event e = new TxnSecurity.Event(
            UserInfo.getOrganizationId(), /* organizationId */
            UserInfo.getUserId(), /* userId */
            'AuthSession', /* entityName */
            'Login', /* action */
            'LoginHistory', /* resourceType */
            '01pR00000009D2H', /* entityId */
            Datetime.newInstance(2016, 2, 15), /* timeStamp */
            eventData); /* data - Map with info about this event. */
            
            AppProtocolControlPolicyCondition condition =
            new AppProtocolControlPolicyCondition();
                condition.evaluate(e);

       // System.assertEquals(true, condition.evaluate(e));
        System.Test.stopTest() ;

   //System.assertEquals(false, condition.evaluate(e));
}

}