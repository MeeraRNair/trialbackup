@IsTest
private class FAP_FormFieldTest {

    private static testmethod void testBuild(){
        final List<FAP_FormField> fields = FAP_FormField.build(new List<FAP_FieldConfiguration>{
            new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe())
            ,new FAP_FieldConfiguration('Account','NumberOfEmployees',null)
                .populateFieldsFromDescribe(Account.NumberOfEmployees.getDescribe())
            ,new FAP_FieldConfiguration('Account','Profile_Published_to_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Profile_Published_to_Partner_Finder__c.getDescribe())
        });
        FAP_FieldConfiguration config = new FAP_FieldConfiguration();
        system.assertEquals(config.objectName,null); 
    }
    
    private static testmethod void testFieldNames(){
        final List<FAP_FormField> fields = FAP_FormField.build(new List<FAP_FieldConfiguration>{
            new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe())
            ,new FAP_FieldConfiguration('Account','NumberOfEmployees',null)
                .populateFieldsFromDescribe(Account.NumberOfEmployees.getDescribe())
            ,new FAP_FieldConfiguration('Account','Profile_Published_to_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Profile_Published_to_Partner_Finder__c.getDescribe())
        });
        
        Set<Object> setFieldNames = FAP_FormField.fieldNames(fields);
        System.assertNotEquals(null,setFieldNames);
        System.assert(setFieldNames.contains('Approved_for_Partner_Finder__c'));
        System.assert(setFieldNames.contains('NumberOfEmployees'));
        System.assert(setFieldNames.contains('Profile_Published_to_Partner_Finder__c'));
    }
    
    private static testmethod void testPopulateFields(){
        final List<FAP_FormField> fields = FAP_FormField.build(new List<FAP_FieldConfiguration>{
            new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe())
            ,new FAP_FieldConfiguration('Account','NumberOfEmployees',null)
                .populateFieldsFromDescribe(Account.NumberOfEmployees.getDescribe())
            ,new FAP_FieldConfiguration('Account','Profile_Published_to_Partner_Finder__c',null)
                .populateFieldsFromDescribe(Account.Profile_Published_to_Partner_Finder__c.getDescribe())
/*            ,new FAP_FieldConfiguration('Account','multiselect_test__c',null)
                .populateFieldsFromDescribe(Account.multiselect_test__c.getDescribe())
*/                
             
        });
        System.assertNotEquals(null,fields);
        System.assertEquals(3,fields.size());
        System.assertEquals(null,fields.get(0).typedValue);
        System.assertEquals(null,fields.get(1).typedValue);
        System.assertEquals(null,fields.get(2).typedValue);

        Account acct = new Account(
          Approved_for_Partner_Finder__c = true
          ,NumberOfEmployees = 10
          ,Profile_Published_to_Partner_Finder__c = 'Yes'
//          ,multiselect_test__c = 'A;B'
        );
        
        FAP_FormField.populateFields(fields,acct);


        System.assertNotEquals(null,fields);
        System.assertEquals(3,fields.size());
        System.assertEquals(acct.Approved_for_Partner_Finder__c,fields.get(0).typedValue);
        System.assertEquals(acct.NumberOfEmployees,fields.get(1).typedValue);
        System.assertEquals(acct.Profile_Published_to_Partner_Finder__c,fields.get(2).typedValue);
        //System.assertEquals(acct.multiselect_test__c,fields.get(3).typedValue);
    }
    
    private static testmethod void testBOOLEAN(){
        final FAP_FormField field = new FAP_FormField(new FAP_FieldConfiguration('Account','Approved_for_Partner_Finder__c',null)
            .populateFieldsFromDescribe(Account.Approved_for_Partner_Finder__c.getDescribe()));

        System.assertEquals('Account',field.objectName);
        System.assertNotEquals(null,field.label);
        System.assertNotEquals(null,field.length);
        System.assertEquals('approved_for_partner_finder__c',FAP_StringUtils.lowerCase(field.localName));
        System.assertNotEquals(null,field.name);
        System.assertNotEquals(null,field.picklistValues);
        System.assert(field.picklistValues.size() <= 0);
        System.assertEquals(Schema.DisplayType.BOOLEAN,field.displayType);
        System.assertEquals(null,field.value);
        System.assertNotEquals(null,field.values);
        System.assert(field.values.size() <= 0);

        System.assertEquals('BOOLEAN',field.fieldType);
        System.assertEquals(true,field.blank);
        System.assertEquals(false,field.notBlank);
        System.assertEquals(false,field.isMultiselectPicklist);
        System.assertEquals(null,field.typedValue);
        
        field.value = 'true';

        System.assertEquals(false,field.blank);
        System.assertEquals(true,field.notBlank);
        System.assertEquals(true,field.typedValue);
    }

    private static testmethod void testINTEGER(){
        final FAP_FormField field = new FAP_FormField(new FAP_FieldConfiguration('Account','NumberOfEmployees',null)
            .populateFieldsFromDescribe(Account.NumberOfEmployees.getDescribe()));

        System.assertEquals('Account',field.objectName);
        System.assertNotEquals(null,field.label);
        System.assertNotEquals(null,field.length);
        System.assertEquals('numberofemployees',FAP_StringUtils.lowerCase(field.localName));
        System.assertNotEquals(null,field.name);
        System.assertNotEquals(null,field.picklistValues);
        System.assert(field.picklistValues.size() <= 0);
        System.assertEquals(Schema.DisplayType.INTEGER,field.displayType);
        System.assertEquals(null,field.value);
        System.assertNotEquals(null,field.values);
        System.assert(field.values.size() <= 0);

        System.assertEquals('INTEGER',field.fieldType);
        System.assertEquals(true,field.blank);
        System.assertEquals(false,field.notBlank);
        System.assertEquals(false,field.isMultiselectPicklist);
        System.assertEquals(null,field.typedValue);

        field.value = '10';

        System.assertEquals(false,field.blank);
        System.assertEquals(true,field.notBlank);
        System.assertEquals(10,field.typedValue);

        field.value = 'x';

        System.assertEquals(true,field.blank);
        System.assertEquals(false,field.notBlank);
        System.assertEquals(null,field.typedValue);
    }

    private static testmethod void testPICKLIST(){
        final FAP_FormField field = new FAP_FormField(new FAP_FieldConfiguration('Account','Profile_Published_to_Partner_Finder__c',null)
            .populateFieldsFromDescribe(Account.Profile_Published_to_Partner_Finder__c.getDescribe()));
        System.assertEquals('Account',field.objectName);
        System.assertNotEquals(null,field.label);
        System.assertNotEquals(null,field.length);
        System.assertEquals('profile_published_to_partner_finder__c',FAP_StringUtils.lowerCase(field.localName));
        System.assertNotEquals(null,field.name);
        System.assertNotEquals(null,field.picklistValues);
        System.assert(field.picklistValues.size() > 0);
        System.assertEquals(Schema.DisplayType.PICKLIST,field.displayType);
        System.assertEquals(null,field.value);
        System.assertNotEquals(null,field.values);
        System.assert(field.values.size() <= 0);

        System.assertEquals('PICKLIST',field.fieldType);
        System.assertEquals(true,field.blank);
        System.assertEquals(false,field.notBlank);
        System.assertEquals(false,field.isMultiselectPicklist);
        System.assertEquals(null,field.typedValue);

        field.value = 'Yes';
        System.assertEquals('Yes',field.typedValue);
        System.assertNotEquals(null,field.typedValueLabel);
    }

}