@IsTest
private class EnvironmentTest {

    private static testmethod void testIsProduction() {
        
        System.debug('###  Environment.DELL_PRODUCTION_ORG_ID :' + Environment.DELL_PRODUCTION_ORG_ID);
        System.debug('###  UserInfo.getOrganizationId() :' + UserInfo.getOrganizationId());
        System.debug('isProduction() :' + Environment.isProduction());        
        System.debug('getShortOrgId() :' + Environment.getShortOrgId());
        
        //test global static Boolean isProduction()
        System.assertEquals(Environment.DELL_PRODUCTION_ORG_ID.equals(UserInfo.getOrganizationId()),Environment.isProduction());        
        
        //test static String getShortOrgId()        
        System.assertEquals(StringUtils.substring(UserInfo.getOrganizationId(),0,15),Environment.getShortOrgId());
    }

    private static testmethod void isSandbox() {
        System.debug('UserInfo.getOrganizationId() in isSandBox :' + UserInfo.getOrganizationId());
        System.debug('isSandbox() :' + Environment.isSandbox());
        
        //test global static Boolean isSandbox(){
        System.assertEquals(!Environment.DELL_PRODUCTION_ORG_ID.equals(UserInfo.getOrganizationId()),Environment.isSandbox());      

    }
}