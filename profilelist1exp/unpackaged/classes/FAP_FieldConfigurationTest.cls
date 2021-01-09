@IsTest
private class FAP_FieldConfigurationTest {

    private static testmethod void testParseNull(){
        final List<FAP_FieldConfiguration> fieldConfigurations = FAP_FieldConfiguration.parse(null);

        System.assertNotEquals(null,fieldConfigurations);
        System.assertEquals(0,fieldConfigurations.size());
    }

    private static testmethod void testParseBlankString(){
        final List<FAP_FieldConfiguration> fieldConfigurations = FAP_FieldConfiguration.parse('   ');

        System.assertNotEquals(null,fieldConfigurations);
        System.assertEquals(0,fieldConfigurations.size());
    }

    private static testmethod void testParse1(){
        final List<FAP_FieldConfiguration> fieldConfigurations = FAP_FieldConfiguration.parse(
           'Account.Partner_Type_METADATA__c=>Partner_Type__c|Partner_Location__c.Is_Primary__c');

        System.assertNotEquals(null,fieldConfigurations);
        System.assertEquals(2,fieldConfigurations.size());

        System.assertEquals('Account',fieldConfigurations.get(0).objectName);
        System.assertEquals('Partner_Type_METADATA__c',fieldConfigurations.get(0).fieldName);
        System.assertEquals('Partner_Type__c',fieldConfigurations.get(0).applyToFieldName);

        System.assertEquals('Partner_Location__c',fieldConfigurations.get(1).objectName);
        System.assertEquals('Is_Primary__c',fieldConfigurations.get(1).fieldName);
        System.assertEquals(true,FAP_StringUtils.isBlank(fieldConfigurations.get(1).applyToFieldName));
        
    }

    private static testmethod void testParse2(){
        final List<FAP_FieldConfiguration> fieldConfigurations = FAP_FieldConfiguration.parse(
           '  Account    .  Partner_Type_METADATA__c   =>   Account   .  Partner_Type__c  |  Partner_Location__c .  Is_Primary__c ');

        System.assertNotEquals(null,fieldConfigurations);
        System.assertEquals(2,fieldConfigurations.size());

        System.assertEquals('Account',fieldConfigurations.get(0).objectName);
        System.assertEquals('Partner_Type_METADATA__c',fieldConfigurations.get(0).fieldName);
        System.assertEquals('Partner_Type__c',fieldConfigurations.get(0).applyToFieldName);

        System.assertEquals('Partner_Location__c',fieldConfigurations.get(1).objectName);
        System.assertEquals('Is_Primary__c',fieldConfigurations.get(1).fieldName);
        System.assertEquals(true,FAP_StringUtils.isBlank(fieldConfigurations.get(1).applyToFieldName));
        
    }

    private static testmethod void testPopulateFromDescribe(){
        final FAP_FieldConfiguration config = new FAP_FieldConfiguration();
        config.populateFieldsFromDescribe(Account.Profile_Published_to_Partner_Finder__c.getDescribe());
        
        System.assertNotEquals(null,config.label);
        System.assertNotEquals(null,config.length);
        System.assertEquals('Profile_Published_to_Partner_Finder__c',config.localName);
        System.assertNotEquals(null,config.name);
        System.assertNotEquals(null,config.picklistValues);
        System.assert(config.picklistValues.size() > 0);
        System.assertEquals(Schema.DisplayType.PICKLIST ,config.displayType);
    }
    
    //Ver 1.0 Test class for  populateFieldValues method.
    private static testmethod void testPopulateFieldValues(){
        FAP_Configuration c = FAP_Configuration.getInstance();
        final List<FAP_FieldConfiguration> fieldConfigurations = FAP_FieldConfiguration.parse(
           ' Account.DELL_Capability__c=>Account.DELL_Capability__c');

     //String urlpartnrtype  = (FAP_PageUtils.param('pt')!=null?FAP_PageUtils.param('pt').toLowerCase():'');
        Map<String,FAP_Customization__c> basicFieldsMap = new Map<String,FAP_Customization__c>();
        FAP_Customization__c fapCust = new FAP_Customization__c(
                                                Name ='Account.DELL_Capability__c', 
                                                Field_label__c ='DELL Capability', 
                                                Help_text__c ='Communications', 
                                                Location__c = 'Regular',
                                                Is_Active__c = true,
                                                Is_Multiselect__c = true,
                                                Region__c = 'EMEA',
                                                User_type__c = 'Authenticated',
                                                Datatype__c = 'Dropdown',
                                                Field_Order__c = 5,
                                                Pick_list_value__c ='Test@Test|Test1@Test2'
                                                );
        List<FAP_FieldConfiguration> fConfigList = new List<FAP_FieldConfiguration>();
        basicFieldsMap.put('DELL_Capability__c',fapCust);
        PageReference p = Page.FAP_PartnerSearch;
        Test.setCurrentPage(p);   
        ApexPages.currentPage().getParameters().put('pt', 'abc');
        final List<FAP_FieldConfiguration> fieldConfigurations1 = FAP_FieldConfiguration.populateFieldValues(fieldConfigurations,
                                    basicFieldsMap,'English',c);
        System.assertNotEquals(null,fConfigList);  
        
         FAP_Translation__c trans = new FAP_Translation__c();
         trans.Value__c = 'DELL Capability';
         trans.English__c = 'test';
         trans.Swedish__c ='Kommunikation';
         insert trans;  


        sObject queriedTrans = [select Value__c,Brazilian_Portuguese__c,Chinese_Simplified__c,
                                                 Chinese_Traditional__c,Czech__c,Danish__c,Dutch__c,
                                                 English__c,Finnish__c,French__c,German__c,Hungarian__c,
                                                 Italian__c,Japanese__c,Korean__c,Polish__c,Russian__c,
                                                 Spanish__c,Swedish__c,Thai__c,Turkish__c from FAP_Translation__c Where Id =: trans.Id
                                                 and Value__c = 'DELL Capability'];

      
       FAP_FieldConfiguration config = new FAP_FieldConfiguration('Account','Name','test');
        
       final FAP_FieldConfiguration configNew = new FAP_FieldConfiguration();
       configNew.populateFieldsFromDescribe(Account.Country_Description__c.getDescribe());
    }
    
    
      
}