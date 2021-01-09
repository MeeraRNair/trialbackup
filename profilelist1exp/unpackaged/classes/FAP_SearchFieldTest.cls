@IsTest
private class FAP_SearchFieldTest {

    private static testmethod void testBuild(){
        final List<FAP_SearchField> fields = FAP_SearchField.build(new List<FAP_FieldConfiguration>{
            new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
            new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
            new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()),
                
                new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe())
        });
        
        System.assertNotEquals(null,fields);
        //System.assertEquals(1,fields.size());
        FAP_SetOfThreeSearchFields.createFromList(fields );
    }

}