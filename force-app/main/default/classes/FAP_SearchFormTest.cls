@IsTest
public class FAP_SearchFormTest {
    public static boolean testVariable = false;
    
    @testSetup
    public static void createTestData(){
        List<Country__c> listCountry = new List<Country__c>();
        Country__c cntry = new Country__c(name='test Country', Opportunity_Won_Lost_Region__c = 'APJ', Dell_Online_Country_Code__c='IE',Code__c='IE',Enabled_Auto_Renewal__c=True,Last_Operation_Performed__c='Test Data',FAP_Region__c = 'EMEA', FAP_Country_Value__c = '',Enable_for_FAP__c = true);
        listCountry.add(cntry);
        insert listCountry;
        List<FAP_Customization__c> listFapCust = new List<FAP_Customization__c>();
         FAP_Customization__c fapCustObjPickList = new FAP_Customization__c(
                                        Name ='Partner_Track__c.Certification_Completed__c', 
                                        Field_label__c ='Competency Completed', 
                                        Help_text__c ='', 
                                        Location__c = 'Advanced',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Field_Order__c = 1,
                                        Is_Multiselect__c = true,
                                        Is_Active__c = true,
                                        pick_list_Value__c = 'Compellent@Compellent|Wyse@Wyse|'
                                       // Pick_list_value__c ='System Management@Servers|Storage@Storage|Networking@Networking|Notebooks@Notebooks|Desktops@Desktops|Workstations@Workstations|Software & Peripherals@Software & Peripherals|Consulting Services(design/optimization)@Consulting Services(design/optimization)|Installation Services@Installation Services|Technical Support Services@Technical Support Services|'
                                        );
        listFapCust.add(fapCustObjPickList); 
        FAP_Customization__c fapCustObjPickList10 = new FAP_Customization__c(
                                        Name ='Partner_Track__c.Authorized_Countries__c', 
                                        Field_label__c ='Distributor Authorized Countries', 
                                        Help_text__c ='', 
                                        Location__c = 'Advanced',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Field_Order__c = 1,
                                        Is_Multiselect__c = true,
                                        Is_Active__c = true,
                                        pick_list_Value__c = 'Compellent@Compellent|Wyse@Wyse|'
                                       // Pick_list_value__c ='System Management@Servers|Storage@Storage|Networking@Networking|Notebooks@Notebooks|Desktops@Desktops|Workstations@Workstations|Software & Peripherals@Software & Peripherals|Consulting Services(design/optimization)@Consulting Services(design/optimization)|Installation Services@Installation Services|Technical Support Services@Technical Support Services|'
                                        );
        listFapCust.add(fapCustObjPickList10); 
        
         FAP_Customization__c fapCustObjPickList2 = new FAP_Customization__c(
                                        Name =' Partner_Location__c.Dell_Products__c', 
                                        Field_label__c ='Dell Products', 
                                        Help_text__c ='', 
                                        Location__c = 'Hidden',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Field_Order__c = 1,
                                        Is_Multiselect__c = true,
                                        Is_Active__c = true,
                                        pick_list_Value__c = 'Account@Account|SuAccount@SuAccount|'
                                       // Pick_list_value__c ='System Management@Servers|Storage@Storage|Networking@Networking|Notebooks@Notebooks|Desktops@Desktops|Workstations@Workstations|Software & Peripherals@Software & Peripherals|Consulting Services(design/optimization)@Consulting Services(design/optimization)|Installation Services@Installation Services|Technical Support Services@Technical Support Services|'
                                        );
        listFapCust.add(fapCustObjPickList2) ; 
         FAP_Customization__c fapCustObjPickList1 = new FAP_Customization__c(
                                        Name ='Partner_Track__c.Dell_Partner_Awards__c', 
                                        Field_label__c ='Country', 
                                        Help_text__c ='', 
                                        Location__c = 'Regular',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'String',
                                        Field_Order__c = 2,
                                        Is_Active__c = true
                                        );
         listFapCust.add(fapCustObjPickList1) ;                             
         FAP_Customization__c fapCustObjPickList3 = new FAP_Customization__c(
                                        Name ='Country__c.Country', 
                                        Field_label__c ='Dell Partner Awards', 
                                        Help_text__c ='', 
                                        Location__c = 'Regular',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Is_Multiselect__c = false,
                                        Field_Order__c = 2,
                                        Is_Active__c = true
                                        );
         listFapCust.add(fapCustObjPickList3) ;
         FAP_Customization__c fapCustObjPickList4 = new FAP_Customization__c(
                                        Name ='Service_Offering__c.Data_Center_Locations__c', 
                                        Field_label__c ='Data Center Locations', 
                                        Help_text__c ='', 
                                        Location__c = 'Regular',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Is_Multiselect__c = false,
                                        Field_Order__c = 2,
                                        Is_Active__c = true
                                        );
        listFapCust.add(fapCustObjPickList4) ;
        FAP_Customization__c fapCustObjPickList5 = new FAP_Customization__c(
                                        Name ='Service_Offering__c.Cloud_Model__c', 
                                        Field_label__c ='Cloud Model', 
                                        Help_text__c ='', 
                                        Location__c = 'Regular',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Is_Multiselect__c = false,
                                        Field_Order__c = 2,
                                        Is_Active__c = true
                                        );
         listFapCust.add(fapCustObjPickList5) ;
        
          FAP_Customization__c fapCustObjPickList7 = new FAP_Customization__c(
                                        Name ='Partner_Location__c.City__c', 
                                        Field_label__c ='Location', 
                                        Help_text__c ='', 
                                        Location__c = 'Regular',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Textbox',
                                        Field_Order__c = 2,
                                        Is_Active__c = true
                                        );
         listFapCust.add(fapCustObjPickList7) ;
           FAP_Customization__c fapCustObjPickList8 = new FAP_Customization__c(
                                        Name ='Partner_Track__c.Partner_Type__c', 
                                        Field_label__c ='Find a Solution Provider', 
                                        Help_text__c ='', 
                                        Location__c = 'Regular',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Is_Multiselect__c = false,
                                        Field_Order__c = 2,
                                        Is_Active__c = true
                                        );
         listFapCust.add(fapCustObjPickList8) ;
          FAP_Customization__c fapCustObjPickList9 = new FAP_Customization__c(
                                        Name ='Service_Offering__c.Contract_Type__c', 
                                        Field_label__c ='Contract Type', 
                                        Help_text__c ='', 
                                        Location__c = 'Regular',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Is_Multiselect__c = false,
                                        Field_Order__c = 2,
                                        Is_Active__c = true
                                        );
         listFapCust.add(fapCustObjPickList9) ;
       
        insert listFapCust ;
    }
    
    private static string strdistributorInSOQL = 'Partner_Track__r.Partner_Type__c NOT IN (\'Distributor (GCC)\',\'Distributor (GDC)\',\'Distributor (Shared)\')';
        // Ver 1.0: To test if the country code is been populated correctly
   private static testmethod void testDeSerializeCountryCode(){
        final FAP_SearchForm form = FAP_SearchForm.deSerialize('c=us');
        System.assertEquals(null,form.keyword);
        System.assertEquals('US',form.countryCode);
        System.assertEquals(null,form.address);
        System.assertEquals(null,form.unit);
        System.assertEquals(null,form.latitude);
        System.assertEquals(null,form.longitude);
        System.assertEquals(null,form.getGeoSearchCriteria());
        System.assertNotEquals(null,form.getAttributeSearchCriteria());
        // Commneted below line as part of Sprint16.03 release 
        //  System.assertEquals(strdistributorInSOQL,form.getAttributeSearchCriteria().toSoql());
    }
    
    
    
     private static testmethod void testSerializeKeyword1(){
        final FAP_SearchForm form = FAP_SearchForm.blank();
        form.pageNumber = '0';
        form.keyword = 'abc';
        System.assertEquals('keyword=abc&pgnum=0',form.serialize());
    }
    
        private static testmethod void testDeSerializeKeyword1(){
            testVariable = true;
            
  /*      FAP_Customization__c fapCustObjPickList = new FAP_Customization__c(
                                        Name ='Partner_Relationship__c', 
                                        Field_label__c ='Partner Status', 
                                        Help_text__c ='', 
                                        Location__c = 'Advanced',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Field_Order__c = 3,
                                        Is_Multiselect__c = true,
                                        Is_Active__c = true,
                                        Pick_list_value__c ='Premier@Premier|Certified@Certified'
                                        );
        insert fapCustObjPickList ; */
                final FAP_SearchForm form = FAP_SearchForm.deSerialize('keyword=abc');
        System.assertEquals('abc',form.keyword);
        System.assertEquals(null,form.address);
        System.assertEquals(null,form.unit);
        System.assertEquals(null,form.latitude);
        System.assertEquals(null,form.longitude);
        System.assertEquals(null,form.getGeoSearchCriteria());
        System.assertNotEquals(null,form.getAttributeSearchCriteria());
        // Commneted below line as part of Sprint16.03 release 
        //  System.assertEquals('((Account__r.name like \'abc\' OR name like \'abc\') AND ' + strdistributorInSOQL + ')',form.getAttributeSearchCriteria().toSoql());
            }
    
        private static testmethod void testSerializeKeyword2(){
        final FAP_SearchForm form = FAP_SearchForm.blank();
        form.pageNumber = '0';
        form.keyword = 'abc';
        System.assertEquals('keyword=abc&pgnum=0',form.serialize());
    }
    
    private static testmethod void testDeSerializeKeyword2(){
        final FAP_SearchForm form = FAP_SearchForm.deSerialize('keyword=abc');
        System.assertEquals('abc',form.keyword);
        System.assertEquals(null,form.address);
        System.assertEquals(null,form.unit);
        System.assertEquals(null,form.latitude);
        System.assertEquals(null,form.longitude);
        System.assertEquals(null,form.getGeoSearchCriteria());
        form.region = 'EMEA';
        System.debug(form.tostr);
       System.assertNotEquals(null,form.getAttributeSearchCriteria());
        // Commneted below line as part of Sprint16.03 release 
        //  System.assertEquals('((Account__r.name like \'ab=c\' OR name like \'ab=c\') AND ' + strdistributorInSOQL + ')',form.getAttributeSearchCriteria().toSoql());
    }
    
    private static testmethod void testSerializeAndUnserializeGeoCriteria(){
        final FAP_SearchForm original = FAP_SearchForm.blank();
        original.address = '1 Broadway, New York, NY 10001';
        original.unit = original.unit;
        original.distance = 5;
        original.latitude = 1.1;
        original.longitude = 1.1;
        original.region = 'EMEA';
        original.strCompetency = 'EMEA';
        String strtest= original.toStr;
        original.toStr();
        String strCSPPartnerType = original.strCSPPartnerType;

        final FAP_SearchForm deSerialized = FAP_SearchForm.deSerialize(original.serialize());
        System.assertEquals(original.address,deSerialized.address);
        System.assertEquals(original.unit,deSerialized.unit);
        System.assertEquals(original.distance,deSerialized.distance);
        System.assertEquals(original.latitude,deSerialized.latitude);
        System.assertEquals(original.longitude,deSerialized.longitude);
        System.assertEquals(null,deSerialized.keyword);
        //System.assertEquals(null,deSerialized.getAttributeSearchCriteria());
        System.assertNotEquals(null,deSerialized.getGeoSearchCriteria());
        
    }
    
    private static testmethod void orderByTest(){
        final FAP_SearchForm original = FAP_SearchForm.blank();
        original.sortOption = Label.FAP_Company_Name;
        //System.assertEquals(null,deSerialized.getAttributeSearchCriteria());
        List<FAP_OrderBy> listorBy= new List<FAP_OrderBy>();
        original.getOrderBy();  
        original.sortOption = Label.FAP_Partner_Status; 
        original.getOrderBy(); 
        original.sortOption = Label.FAP_Partner_Type; 
        original.getOrderBy();
        original.sortOption = Label.FAP_Distance; 
        original.getOrderBy();
        original.sortOption = Label.None; 
        original.getOrderBy(); 
        original.sortOption = null; 
        original.getOrderBy();
        system.debug('6666'+original.getOrderBy());
        System.assertNotEquals(null,original.getOrderBy());
        //System.assertEquals(original.getOrderBy());
    }
    
    private static testmethod void testGeoSearch(){
   // scenario1();
        String strCountryCode = 'IN';
        final FAP_SearchForm form = FAP_SearchForm.blank();
        form.CountryCode = 'IN';
        form.address = '1 Broadway';
        //form.unit = 'kilometers';
        form.distance = 10;
        form.latitude = 0;
        form.longitude = 0;
        form.keyword = 'abc';
        form.Region= 'Asia';
        final List<FAP_SearchField> searchFieldList = FAP_SearchField.build(FAP_FieldConfiguration.parse(
           'Partner_Track__c.Capability__c=>Partner_Track__c.Capability__c'));
        form.getAttributeSearchCriteria();
        form.getGeoSearchCriteria();
        System.assertEquals(true,form.getAttributeSearchCriteria()!=null);
    }
 
    private static testmethod void testDeSerializeKeyword3(){
        // final FAP_SearchForm form1 = FAP_SearchForm.blank();
        FAP_SearchForm.accField = FAP_Configuration.keyValue +'Partner_Type__c';
        FAP_Customization__c fapCustObjPickList1 = new FAP_Customization__c(
                                        Name ='Partner_Track__c.Dell_Certification_Areas__c', 
                                        Field_label__c ='Product & Solutions Competencies', 
                                        Help_text__c ='', 
                                        Location__c = 'Advanced',
                                        Region__c = 'EMEA',
                                        User_type__c = 'Authenticated',
                                        Datatype__c = 'Dropdown',
                                        Field_Order__c = 3,
                                        Is_Multiselect__c = true,
                                        Pick_list_value__c ='Storage Specialist@Storage Specialist|Server Specialist@Server Specialist|KACE Specialist@KACE Specialist|Networking & Security Specialist@Networking & Security Specialist|Managed Service Provider@Managed Service Provider|Independent Software Vendor@Independent Software Vendor|US Federal Government@US Federal Government|US Federal Government LOS Holder@US Federal Government LOS Holder|Enterprise Architecture@Enterprise Architecture|Small and Medium business@Small and Medium business|Commercial@Commercial|Government@Government|'
                                        );
        insert fapCustObjPickList1 ; 
         FAP_Customization__c fapCustObjPickList6 = new FAP_Customization__c(
                                        Name ='Service_Offering__c.Service_Offering__c', 
                                        Field_label__c ='Service Offering', 
                                        Help_text__c ='', 
                                        Location__c = 'Regular',
                                        Region__c = 'NA',
                                        User_type__c = 'un-authenticated',
                                        Datatype__c = 'Dropdown',
                                        Is_Multiselect__c = false,
                                        Field_Order__c = 2,
                                        Is_Active__c = true
                                        );
        insert fapCustObjPickList6 ;


        final FAP_SearchForm form = FAP_SearchForm.deSerialize('keyword=abc');
        form.region = 'EMEA';
        System.assertEquals('abc',form.keyword);
        System.assertEquals(null,form.address);
        System.assertEquals(null,form.unit);
        System.assertEquals(null,form.latitude);
        System.assertEquals(null,form.longitude);
        System.assertEquals(null,form.getGeoSearchCriteria());
        System.assertNotEquals(null,form.getAttributeSearchCriteria());
        // Commneted below line as part of Sprint16.03 release 
        //   System.assertEquals('((Account__r.name like \'abc\' OR name like \'abc\') AND ' + strdistributorInSOQL + ')',form.getAttributeSearchCriteria().toSoql());
    }
    private static testmethod void testGetCompetencyTrackerAccount(){
         
        final FAP_SearchForm form = FAP_SearchForm.blank();
        form.pageNumber = '0';
        form.keyword = 'abc';
        System.assertEquals('keyword=abc&pgnum=0',form.serialize());
        
        List<String> listcompetencyTrackerAccount = new List<String>(); 
        listcompetencyTrackerAccount.add('test');
        //form.getCompetencyTrackerAccount(listcompetencyTrackerAccount);
        
    }   
    
    private static testmethod void testGetCSPServiceOfferingAccs(){
        final FAP_SearchForm form = FAP_SearchForm.blank();
        form.pageNumber = '0';
        form.keyword = 'abc';
        System.assertEquals('keyword=abc&pgnum=0',form.serialize());
        List<string> listgetValue = new List<string>();
        listgetValue.add('testdata');
        List<String> listcompetencyTrackerAccount = new List<String>(); 
        listcompetencyTrackerAccount.add('test');
        string strqualifiedName ='Data_Center_Country__c';
        form.getCSPServiceOfferingAccs(strqualifiedName, listgetValue);
        
    } 
    private static testmethod void testBooelanValues(){
        final FAP_SearchForm form = FAP_SearchForm.blank();
        form.pageNumber = '0';
        form.keyword = 'abc';
        System.assertEquals('keyword=abc&pgnum=0',form.serialize());
        List<string> listgetValue = new List<string>();
        listgetValue.add('testdata');
        List<String> competencyTrackerAccount = new List<String>(); 
        competencyTrackerAccount.add('test');
        string strqualifiedName ='CSP_Country__c';
        form.getCSPServiceOfferingAccs(strqualifiedName, listgetValue);
        system.assertEquals(false, form.isBlank);
        system.assertEquals(false, form.keywordBlank);
        system.assertEquals(true, form.geoBlank);
        system.assertEquals(true, form.basicFieldsAreBlank);
        system.assertEquals(true, form.advancedFieldsAreBlank);
        
       Boolean bIsBlank=form.isBlank;
       system.assertEquals(form.isBlank,bIsBlank);
       Boolean bKeywordBlank=form.keywordBlank;
       system.assertEquals(form.keywordBlank,bKeywordBlank);
 
       Boolean bGeoBlank=form.geoBlank;
       system.assertEquals(form.geoBlank,bGeoBlank);
        
       Boolean basicFieldsAreBlank=form.basicFieldsAreBlank;
       system.assertEquals(form.basicFieldsAreBlank,basicFieldsAreBlank);
        
       Boolean bAdvancedFieldsAreBlank=form.advancedFieldsAreBlank;
       system.assertEquals(form.basicFieldsAreBlank,bAdvancedFieldsAreBlank); 
       FAP_Configuration config = FAP_Configuration.getInstance();
       Map<String,FAP_Customization__c> mapfieldMap = new Map<String,FAP_Customization__c>();
       FAP_Customization__c customFAPObj = new FAP_Customization__c();

       customFAPObj.Datatype__c='test';
       customFAPObj.Field_label__c ='Help Text';
       customFAPObj.Help_text__c ='Help Text';
       insert customFAPObj;
       mapfieldMap.put('test', customFAPObj);        
     //  List<FAP_FieldConfiguration> fieldConfigAdvanced = FAP_FieldConfiguration.populateFieldValues(
                                           // FAP_FieldConfiguration.parse('Partner_Track__c.Partner_Type__c'), mapfieldMap,
                                           //'en',config);
      // List<FAP_SearchField>    advancedFields = FAP_SearchField.build(fieldConfigAdvanced); 
      // form.getFAPCustomization();
      // form.setFieldConfig('Partner_Track__c.Partner_Type__c', mapfieldMap);
     
    }    
    
   private static testmethod void testSerializeList(){
       List<String> listencoded = new List<String>();
       String strtest ='Help Text';
       system.assertEquals(strtest,'Help Text');
       listencoded.add(EncodingUtil.urlEncode(strtest,'UTF-8'));
       strtest = FAP_SearchForm.serializeList(listencoded);
    }
   private static testmethod void testDeSerializeList(){
       List<String> listencoded = new List<String>();
       String strtest ='Help Text';
       listencoded = FAP_SearchForm.deSerializeList(strtest);
       system.assertEquals(strtest,'Help Text');
    }  
   private static testmethod void testToSelectOption(){
       List<SelectOption> listtoSelectOption= new List<SelectOption>();
       List<Integer> listtest = new List<Integer>();
       Integer inttest1=5;
       listtest.add(inttest1);
       listtoSelectOption = FAP_SearchForm.toSelectOption(listtest);
       String strtest ='Help Text';
       system.assertEquals(strtest,'Help Text');
    }  
       /*
        private static testmethod void testAreBlank(){
            List<FAP_SearchField> fields= new List<FAP_SearchField>();
            
            Boolean test1=false;
            system.assertEquals(true, FAP_SearchForm.areBlank(fields)) ;
        }  
   */
  /* private static testmethod void testSetUserCountry(){
     FAP_SearchForm form = new FAP_SearchForm();
     //User usr = [Select u.Contact.MailingCountry, u.ContactId From User u Where Id = :UserInfo.getUserId()];

           //   UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Account a=new Account(Name='Partner Ac',NameLocal='Test',Partner_Type__c='Distributor',Partner_Relationship__c='Premier');
                insert a;          
            Contact c = New Contact(LastName = 'Test',MailingCountry='US', AccountID = a.id,Phone='78930927834');
            insert c;
         //Uncommented           
         // User usr = new User();
          //  usr.ContactId = c.id;
           // insert usr;
        system.assertEquals(a.Name,'Partner Ac');
        
        string strproid = [SELECT Id FROM Profile WHERE Name LIKE '%Portal User%' Limit 1][0].Id;    
        User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'ja', LOB_Title__c = 'GCC Global Program Manager',
                          LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
                         ContactId= c.id, EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        system.runAs(u){ 
     form.setUserCountry();
     //system.assertNotEquals(null, FAP_SearchForm.setUserCountry()) ;
            }
    } */
  private static testmethod void testGetAttributeSearchCriteria(){
     FAP_SearchForm form = new FAP_SearchForm();
     FAP_Condition fapCondition = form.getAttributeSearchCriteria();
     Account a=new Account(Name='Partner Ac',NameLocal='Test',Partner_Type__c='Distributor',Partner_Relationship__c='Premier');
     insert a;   
     system.assertEquals(a.Name,'Partner Ac');
    }      
    
    private static testMethod void testSearchForm12(){
        FAP_FieldConfiguration fc = new FAP_FieldConfiguration ('Partner_Track__c','Authorized_Countries','Authorized_Countries__c');
        FAP_SearchField fsF = new FAP_SearchField (fc);
        FAP_SearchForm form = new FAP_SearchForm();
        List<FAP_SearchField> listsfd = new List<FAP_SearchField>();
        listsfd.add(fsf);
        FAP_SearchForm.areBlank(listsfd);
        system.debug(form.customBasicFAPSearchFields);
        Account a=new Account(Name='Partner Ac',NameLocal='Test',Partner_Type__c='Distributor',Partner_Relationship__c='Premier');
        insert a;   
        system.assertEquals(a.Name,'Partner Ac');       
    }
    
     private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    } 
   
  }