@IsTest
private class FAP_FieldIndexTest {

    private static testmethod void testLoadMetadataForTypes(){
        final FAP_FieldIndex validator = new FAP_FieldIndex().indexType(
            new List<Schema.DescribeSObjectResult>{
                Schema.sObjectType.Account,
                Schema.sObjectType.Partner_Location__c
            }
        );
            
        System.assertEquals(true,validator.isValidField('Account', 'Rating'));
        System.assertEquals(true,validator.isValidField('Account.Rating'));
        System.assertEquals(true,validator.isValidField('Partner_Location__c', 'Is_Primary__c'));
        System.assertEquals(true,validator.isValidField('Partner_Location__c.Is_Primary__c'));

        System.assertEquals(false,validator.isValidField('Account', 'asdfaasdf41e4qwedsdfd'));
        System.assertEquals(false,validator.isValidField('asdfaasdf41e4qwedsdfd', 'asdfaasdf41e4qwedsdfd'));
    }

}