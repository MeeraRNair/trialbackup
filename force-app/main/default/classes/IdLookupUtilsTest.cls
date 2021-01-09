@IsTest
private class IdLookupUtilsTest {
    
    private static testmethod void testGetRecordTypeByIdNormal(){
        //test: public static Id getRecordTypeId(String name, String sobjectName, boolean isActive){
        List<RecordType> recordTypes = [
            select id,name,sobjecttype from RecordType where IsActive = true limit 1
        ];
        System.assert(recordTypes.size()>0, 'Test cannot be executed: No active record types exist');
        Id actual = IdLookupUtils.getRecordTypeId(recordTypes.get(0).name, 
            recordTypes.get(0).sobjecttype, true);
        System.assertEquals(recordTypes.get(0).id, actual); 
    }

    private static testmethod void testGetRecordTypeByIdBadInput(){
        //test: public static Id getRecordTypeId(String name, String sobjectName, boolean isActive){
        Id actual = IdLookupUtils.getRecordTypeId('test123','CustomObject', true);
        System.assertEquals(null, actual); 
    }


    private static testmethod void testIdFromAccountLegacyIdPartnerRequestId(){
        //test:public static String getIdFromAccountLegacyId(String LegacyId){
        System.assertEquals(IdLookupUtils.getIdFromAccountLegacyId('SFDC_a0CR0000001sV1F'),'a0CR0000001sV1F');
                
    }
    
    private static testmethod void testIdFromAccountLegacyIdNull(){
        //test:public static String getIdFromAccountLegacyId(String LegacyId){
        System.assertEquals(IdLookupUtils.getIdFromAccountLegacyId(''),'');
                
    }
    
    private static testmethod void testIdFromAccountLegacyIdNonPartnerRequestid(){
        //test:public static String getIdFromAccountLegacyId(String LegacyId){
        System.assertEquals(IdLookupUtils.getIdFromAccountLegacyId('a0CR0000001sV1F'),'');
                
    }
    
    private static testmethod void testPrefixIdNormal(){
        //test:public static String getIdPrefix(String recordId){
        System.assertEquals(IdLookupUtils.getIdPrefix('a0CR0000001sV1F'),'a0C');
                
    }
    
    private static testmethod void testPrefixIdNull(){
        //test:public static String getIdPrefix(String recordId){
        System.assertEquals(IdLookupUtils.getIdPrefix(null),'');
                
    }
    
    private static testmethod void testGetShortGUID(){
        //test: public static String getShortGUID(String recordId)        
        System.assertEquals('006R0000005OWd5',IdLookupUtils.getShortGUID('006R0000005OWd5IAG'));
        System.assertEquals('',IdLookupUtils.getShortGUID(null));
    }
}