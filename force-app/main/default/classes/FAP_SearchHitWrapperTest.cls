/**
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Fenny       13-Apr-2012     13.4        7055    Display PartnerDirect logo respectively to partner status & type
1.1         Vismy       26-Mar-2019     0402                Test class coverage
1.2         Akshita     5-Dec-2019      0102                Test class coverage    
**/
@IsTest
private class FAP_SearchHitWrapperTest {
    
    private static Double random(Double min, Double max){
        return min + (Math.random() * (max - min));
    }
    private static testmethod void testToJson(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        Account a=new Account(Name='Partner Ac',NameLocal='Test',Partner_Type__c='Distributor',Partner_Relationship__c='Premier',FAP_Category__c= 'Small Business Reseller');
        insert a;        
        list<Account> acc = Database.query('SELECT Partner_Type__c, Partner_Relationship__c FROM Account ' +
                                        'WHERE IsPartner = true LIMIT 1');        
       
        Contact c = New Contact(LastName = 'Test', AccountID = a.id,Phone='78930927834');
        insert c;
        
        Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = a.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c = logo.Id;
        testPartnerTrackObj.Primary_SMAffinity_Account__c = a.Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'test1223';
        testPartnerTrackObj.Website__c = 'test.abc@gmail.com';
        testPartnerTrackObj.Partner_Self_Description_Long__c = 'testest';
        
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        testPartnerTrackObj.Certification_Completed__c = 'Storage';
        testPartnerTrackObj.FAP_Category__c = 'Small Business Reseller';
        insert testPartnerTrackObj;   
        
        //User newUser = createPartnerUser(c.id);                 
        Partner_Location__c location = new Partner_Location__c(
            Name = 'acme'
            ,Is_Primary__c = true
            ,Latitude__c = 1.1
            ,Longitude__c = 1.1
            ,Account__c = a.id
            ,Street__c = '123 Broadway'
            ,State_Province__c = 'NY'
            ,Postal_Code__c = '10001'
            ,Country__c = 'UNITED STATES'
            ,City__c = 'New York'
            ,Partner_Track__c = testPartnerTrackObj.Id
            ,Website__c = 'www.google.com'
            ,isMainContact__c = false
            ,Point_of_Contact_Phone__c = '919939393'
            ,Point_of_Contact_Name__c = 'Test Name'
            ,Point_of_Contact_Email__c = 'test@gmail.com'
            ,Description__c = 'Test Desc'
        );
          
        insert location;

        
        location = Database.query('select name, Account__c, id, website__c, is_primary__c, point_of_contact_phone__c,Partner_Track__r.Legal_Address__c,' 
                                + 'point_of_contact_name__c, point_of_contact_email__c, description__c,'
                                + 'street__c, city__c,isMainContact__c, state_province__c, postal_code__c, country__c, longitude__c,'
                                + 'latitude__c, account__r.name, account__r.id, account__r.logo__c, '
                                + 'account__r.FAP_Category__c,'
                                + 'Partner_Track__r.FAP_Category__c,'
                                + 'Partner_Track__r.Logo__c,' 
                                + 'Partner_Track__r.Certification_Completed__c,' 
                                + 'Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c,'
                                + 'Partner_Track__r.Partner_Track_Account_Local_Name__c ,'
                                + 'Partner_Track__r.Legal_Address_City__c,'
                                + 'Partner_Track__r.Legal_Address_Street__c,'
                                + 'Partner_Track__r.Legal_Address_State_Province__c,'
                                + 'Partner_Track__r.Legal_Address_Postal_Code__c ,'
                                + 'Partner_Track__r.Legal_Address_Country__c,'
                                + 'Partner_Track__r.Dell_Technologies_Partner__c,'
                                + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                                + 'Partner_Track__r.partner_finder_recommended_flag__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Partner_Type__c,'
                                + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + location.Id + '\'');        
        
        
        ID partnerAccountId  = location.Partner_Track__r.id; 
        
        FAP_SearchHit searchHit = new FAP_SearchHit(location);
        searchHit.mapPL.put(partnerAccountId,'Storage');
        searchHit.mapServiceCompetency.put('Storage','Converged/Hyper-Converged Infrastructure Services');
        final FAP_SearchHitWrapper wrapped = new FAP_SearchHitWrapper(searchHit,config);
        
               
        final List<FAP_SearchHitWrapper> hits = new List<FAP_SearchHitWrapper>{
           new FAP_SearchHitWrapper(new FAP_SearchHit(location),config),
           new FAP_SearchHitWrapper(new FAP_SearchHit(location),config)
        };
        for(Integer i = 1; i <= hits.size(); i++){
            hits.get(i-1).wrapped.resultSequenceNumber = i;
            System.assertNotEquals(null,  hits.get(i-1).wrapped.resultSequenceNumber);
            System.assertNotEquals(null,  hits.get(i-1).wrapped.locationName);
             System.assertNotEquals(null,  hits.get(i-1).wrapped.partnerName);
             System.assertNotEquals(null,  hits.get(i-1).wrapped.partnerNameLocal);
          //   System.assertNotEquals(null,  hits.get(i-1).wrapped.fapcategory);

            System.assertEquals(null, hits.get(i-1).wrapped.mapPL.get(partnerAccountId));
        }

        system.debug('######## expect value: ' + '{ "locations" : [' 
               + '{"name":"acme","id":null,"state":"NY","latitude":1.1,"street":"123 Broadway","recordNumber":"1"' 
               + ',"postalCode":"10001","longitude":1.1,"country":"UNITED STATES","city":"New York"}' 
               + ',{"name":"acme","id":null,"state":"NY","latitude":1.1,"street":"123 Broadway","recordNumber":"2"' 
               + ',"postalCode":"10001","longitude":1.1,"country":"UNITED STATES","city":"New York"}' 
               + ']}');
        
        
        system.debug('######## result value: ' + FAP_SearchHitWrapper.toJson(hits));
        system.assertNotEquals(null, FAP_SearchHitWrapper.toJson(hits));
        FAP_SearchHitWrapper.toJson(hits);
        
       
    }    

    private static testmethod void testToJsonEmptyList(){
        System.assertEquals('{ "locations" : []}',FAP_SearchHitWrapper.toJson(null));
    }    

   private static testmethod void testFields(){
       
        FAP_Configuration config = FAP_Configuration.getInstance();
        Account a=new Account(Name='Partner Ac',Partner_Type__c='Distributor',Partner_Relationship__c='Premier');
        insert a;        
        list<Account> acc = Database.query('SELECT Partner_Type__c, Partner_Relationship__c FROM Account ' +
                                        'WHERE IsPartner = true LIMIT 1');        
       
        Contact c = New Contact(LastName = 'Test', AccountID = a.id,Phone='78930927834');
        insert c;
        
        
        Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = a.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c = logo.Id;
        //testPartnerTrackObj.Primary_SMAffinity_Account__c =acc[0].Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'test1223';
        testPartnerTrackObj.Website__c = 'test.abc@gmail.com';
        testPartnerTrackObj.Partner_Self_Description_Long__c = 'testest';
        
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        testPartnerTrackObj.Certification_Completed__c = 'Storage';
        insert testPartnerTrackObj;   
        
        //User newUser = createPartnerUser(c.id);   

        Partner_Location__c location = new Partner_Location__c(
            Name = 'acme'
            ,Is_Primary__c = true
            ,Latitude__c = 1.1
            ,Longitude__c = 1.1
            ,Account__c = a.id
            ,Street__c = '123 Broadway'
            ,State_Province__c = 'NY'
            ,Postal_Code__c = '10001'
            ,Country__c = 'UNITED STATES'
            ,City__c = 'New York'
            ,website__c='www.test.com'
            ,point_of_contact_phone__c='0612323431'
            ,point_of_contact_name__c='Test Name'
            ,Partner_Track__c = testPartnerTrackObj.Id
            
        );
       insert location;
       
        location = Database.query('select name, Account__c, id, website__c, is_primary__c, point_of_contact_phone__c,' 
                                + 'point_of_contact_name__c, point_of_contact_email__c, description__c,'
                                + 'street__c, city__c, state_province__c, postal_code__c, country__c, longitude__c,'
                                + 'latitude__c, account__r.name, account__r.id, account__r.logo__c, '
                                + 'Partner_Track__r.Logo__c,' 
                                + 'Partner_Track__r.Certification_Completed__c,' 
                                + 'Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c,'
                                + 'Partner_Track__r.Partner_Track_Account_Local_Name__c ,'
                                + 'Partner_Track__r.Legal_Address_City__c,'
                                + 'Partner_Track__r.Legal_Address_Street__c,'
                                + 'Partner_Track__r.Legal_Address_State_Province__c,'
                                + 'Partner_Track__r.Legal_Address_Postal_Code__c ,'
                                + 'Partner_Track__r.Legal_Address_Country__c,'
                                + 'Partner_Track__r.Dell_Technologies_Partner__c,'
                                + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                                + 'Partner_Track__r.partner_finder_recommended_flag__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Partner_Type__c,'
                                + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + location.Id + '\'');
       
       ID partnerAccountId  = location.Partner_Track__r.id; 
       
       FAP_SearchHit searchHit = new FAP_SearchHit(location);
        searchHit.mapPL.put(partnerAccountId,'Server;Wsyse for VDI;Dell Technologies Cloud;FAP OEM;Data Analytics;Business Applications;Unified Workspace;High Performance Computing;Internet of Things (IoT)');
        searchHit.mapServiceCompetency.put('Server','Hybrid Cloud Platform Servics');
        final FAP_SearchHitWrapper wrapped = new FAP_SearchHitWrapper(searchHit,config);
        
       
       Map<String,String> mapServiceCompetency =new Map<String,String>();
        mapServiceCompetency.put('storage','storage');
       //FAP_SearchHit searchHit = new FAP_SearchHit(location);
       //searchHit.userRequestedFieldValues
        final FAP_SearchHitWrapper wrapper = new FAP_SearchHitWrapper(new FAP_SearchHit(location),config);
        Map<Id,String> mapPL = new Map<Id,String>();
        mapPL.put(partnerAccountId,'test');
        System.debug(wrapper.point); 
        System.debug(wrapper.containsDistance);
        System.debug(wrapper.distanceInKilometers); 
        System.debug(wrapper.distanceInMiles);
        System.debug(wrapper.isRecommended); 
        System.debug(wrapper.logoId);
        System.assertEquals(null, new FAP_SearchHit(location).mapPL.get(partnerAccountId));       
    }

    private static testmethod void testNullWrappedConstructorArgument(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SearchHitWrapper(null,null);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testNullConfigConstructorArgument(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SearchHitWrapper(new FAP_SearchHit(new Partner_Location__c()),null);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }
    
    private static user createPartnerUser(ID cId){
    Profile p = [Select ID, Name from Profile Where Name = 'R16.10 APJ PRM Portal User (MOSS)'];
    test.startTest();
    user u = New User(
        UserName = 'test_' + math.random() + '@test.com',
        FirstName = 'Test-First',
        LastName = 'Test-Last',
        Alias = 'test',
        email = 'test' + math.random() + '@test.com',
        CommunityNickName = string.valueOf(math.random()).substring(0,6),
        ProfileID = p.id,
        TimeZoneSidKey = 'America/New_York', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        LanguageLocaleKey = 'en_US',
        ContactID = cId,
        Badge_Number__c ='46568'

        );

    insert u;
    test.stopTest();
        return u;
    }    
    
  private static testmethod void testPartnerDirectLogoURL(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        Account a=new Account(Name='Partner Ac',Partner_Type__c='Distributor',Partner_Relationship__c='Gold',Dell_Certification_Areas__c='Server');
        insert a;        
        list<Account> acc = Database.query('SELECT Partner_Type__c,Dell_Certification_Areas__c,Partner_Relationship__c FROM Account ' +
                                        'WHERE IsPartner = true LIMIT 1');     


        Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = a.Id;
        testPartnerTrackObj.Partner_Track__c='OEM';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c = logo.Id;
        testPartnerTrackObj.Primary_SMAffinity_Account__c = a.Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'test1223';
        testPartnerTrackObj.Website__c = 'test.abc@gmail.com';
        testPartnerTrackObj.Partner_Self_Description_Long__c = 'testest';
        
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        testPartnerTrackObj.Certification_Completed__c = 'Storage';
        insert testPartnerTrackObj;   
        
        Partner_Location__c loc = new Partner_Location__c(
            Name = 'Acme Computer Headquarters'
            ,Is_Primary__c = true
            ,Latitude__c = random(-90, 90)
            ,Longitude__c = random(-90, 90)
            ,Account__c = a.Id
            ,Partner_Track__c = testPartnerTrackObj.Id
        );
        
        insert loc;
        loc = Database.query('select name, Account__c, id, website__c, is_primary__c, point_of_contact_phone__c,' 
                                + 'point_of_contact_name__c, point_of_contact_email__c, description__c,'
                                + 'street__c, city__c, state_province__c, postal_code__c, country__c, longitude__c,'
                                + 'latitude__c, account__r.name, account__r.id, account__r.logo__c, '
                                + 'Partner_Track__r.Logo__c,' 
                                + 'Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c,'
                                + 'Partner_Track__r.Partner_Track_Account_Local_Name__c ,'
                                + 'Partner_Track__r.Legal_Address_City__c,'
                                + 'Partner_Track__r.Legal_Address_Street__c,'
                                + 'Partner_Track__r.Legal_Address_State_Province__c,'
                                + 'Partner_Track__r.Legal_Address_Postal_Code__c ,'
                                + 'Partner_Track__r.Legal_Address_Country__c,'
                                + 'Partner_Track__r.Dell_Technologies_Partner__c,'
                                + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                                + 'Partner_Track__r.partner_finder_recommended_flag__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Partner_Type__c,'
                                + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + loc.Id + '\'');
      final FAP_SearchHit hit = new FAP_SearchHit(loc);
      hit.userRequestedFieldValues=null;
      //string fieldName='Account__r.Certification_Completed__c';
      Map<String,Object> userRequestedFieldValues1 = new Map<String,Object>();
      
      //userRequestedFieldValues1.put('Account__r.Certification_Completed__c', 'Server');
      
      Map<String,Object> userRequestedFieldValues2 = new Map<String,Object>();
      ID partnerAccountId  = loc.Partner_Track__r.id;
        //FAP_SearchHit hit = new FAP_SearchHit(location);
        hit.mapPL.put(partnerAccountId,'Networking');
        hit.mapServiceCompetency.put('Networking','Converged/Hyper-Converged Infrastructure Services');
        final FAP_SearchHitWrapper wrapped = new FAP_SearchHitWrapper(hit,config);
          
      userRequestedFieldValues2.put('Account__r.Dell_Certification_Areas__c','Server;Storage;Networking;Data Protection Services;Core Client;Client Data Security;Workstation;Software Defined Infrastructure;Cloud Client-Computing;Connected Workforce;Hybrid Cloud Platform Services;Hybrid Cloud;Software Defined Infrastructure;IT Transformation;Converged/Hyper-Converged Infrastructure;Desktop Virtualization Solutions;Digital Transformation');
      hit.userRequestedFieldValues=userRequestedFieldValues2;
        FAP_SearchHitWrapper wrapper = new FAP_SearchHitWrapper(hit, config);
        system.assertEquals('OEM', wrapper.wrapped.partnerType);
        system.assertEquals('Gold', wrapper.wrapped.partnerRelationship);
        system.assertEquals(true, wrapper.partnerDirectLogoURL.length() > 0);
      
    }  
    
  private static testmethod void testSearchHitWrapperConstructor(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        Account a=new Account(Name='Partner Ac',Partner_Type__c='Distributor',Partner_Relationship__c='Premier');
        insert a;        
        list<Account> acc = Database.query('SELECT Partner_Type__c, Partner_Relationship__c FROM Account ' +
                                        'WHERE IsPartner = true LIMIT 1');                                                            
        
        Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = a.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c = logo.Id;
        //testPartnerTrackObj.Primary_SMAffinity_Account__c =acc[0].Id;
        
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        testPartnerTrackObj.Certification_Completed__c = 'Storage';
        insert testPartnerTrackObj;   
        
      Partner_Location__c location = new Partner_Location__c(
            Name = 'Acme Computer Headquarters'
            ,Is_Primary__c = true
            ,Latitude__c = random(-90, 90)
            ,Longitude__c = random(-90, 90)
            ,Account__c = a.Id
            ,Partner_Track__c = testPartnerTrackObj.Id
        );
        
        insert location;
        location = Database.query('select name, Account__c, id, website__c, is_primary__c, point_of_contact_phone__c,' 
                                + 'point_of_contact_name__c, point_of_contact_email__c, description__c,'
                                + 'street__c, city__c, state_province__c, postal_code__c, country__c, longitude__c,'
                                + 'latitude__c, account__r.name, account__r.id, account__r.logo__c, '
                                + 'Partner_Track__r.Logo__c,' 
                                + 'Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c,'
                                + 'Partner_Track__r.Partner_Track_Account_Local_Name__c ,'
                                + 'Partner_Track__r.Legal_Address_City__c,'
                                + 'Partner_Track__r.Legal_Address_Street__c,'
                                + 'Partner_Track__r.Legal_Address_State_Province__c,'
                                + 'Partner_Track__r.Legal_Address_Postal_Code__c ,'
                                + 'Partner_Track__r.Legal_Address_Country__c,'
                                + 'Partner_Track__r.Dell_Technologies_Partner__c,'
                                + 'Partner_Track__r.Certification_Completed__c,'
                                + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                                + 'Partner_Track__r.partner_finder_recommended_flag__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Partner_Type__c,'
                                + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + location.Id + '\'');
      
        FAP_SearchHit hit = new FAP_SearchHit(location);
        ID partnerAccountId  = hit.partnerAccountId;
       
        Map<String,String> mapServiceCompetency =new Map<String,String>();
        mapServiceCompetency.put('storage','storage');
        final FAP_SearchHitWrapper wrapper = new FAP_SearchHitWrapper(new FAP_SearchHit(location),config);
        Map<Id,String> mapPL = new Map<Id,String>();
        mapPL.put(partnerAccountId,hit.partnerAccountId);
        System.assertEquals(partnerAccountId, hit.partnerAccountId);      
      
        List<string> dellCompetencies = new List<String>();
        dellCompetencies.add('Storage');
        Map<String,FAP_FormField> fields = new Map<String,FAP_FormField>();
        Map<String,FAP_FormField> fieldLookup = new Map<String,FAP_FormField>();
        List<FAP_FieldConfiguration> searchScreenFieldsInResultList = config.searchScreenFieldsInResultList;
      
        String dellcomp = 'Storage';
        Map<String,Object> userRequestedFieldValues = new Map<String,Object>();
        userRequestedFieldValues.put('test', location);
        for(FAP_FieldConfiguration fieldConfiguration : searchScreenFieldsInResultList){
           System.assertNotEquals(null, fieldConfiguration.objectName);
            //fields.put(fieldConfiguration.fieldName, new FAP_FormField(fieldConfiguration));
           // fieldLookup.put(fieldConfiguration.fieldName, new FAP_FormField(fieldConfiguration));
           
        }
       for(String field : fieldLookup.keySet()){
           System.assertNotEquals(null, field);
            dellcomp = dellcomp+';'+(String) userRequestedFieldValues.get(field);   
           System.assertNotEquals(null, dellcomp);
       }

        if((dellcomp != null && dellcomp != '')){              
                dellCompetencies =  dellcomp.split(';');
                for(string strObj:dellCompetencies){                                      
                    strObj = strObj.trim();  
                     System.assertNotEquals(null, strObj);
                }
        }     
      
    }  
     private static Blob generateRandomBlob(){
        return EncodingUtil.base64Decode(''+System.currentTimeMillis()+Math.roundToLong(Math.random()*10000));  
    }
    
     private static testmethod void testFieldsNew(){
       
        FAP_Configuration config = FAP_Configuration.getInstance();
        Account a=new Account(Name='Partner Ac',Partner_Type__c='Distributor',Partner_Relationship__c='Premier');
        insert a;        
        list<Account> acc = Database.query('SELECT Partner_Type__c, Partner_Relationship__c FROM Account ' +
                                        'WHERE IsPartner = true LIMIT 1');        
       
        Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = a.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c = logo.Id;
        //testPartnerTrackObj.Primary_SMAffinity_Account__c =acc[0].Id;
        
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        testPartnerTrackObj.Certification_Completed__c = 'Storage';
        testPartnerTrackObj.Services_Competencies__c = 'Client Services Deployment';
        insert testPartnerTrackObj;   
                                        
       
        
        Contact c = New Contact(LastName = 'Test', AccountID = a.id,Phone='78930927834');
        insert c;
        //User newUser = createPartnerUser(c.id);   

        Partner_Location__c location = new Partner_Location__c(
            Name = 'acme'
            ,Is_Primary__c = true
            ,Latitude__c = 1.1
            ,Longitude__c = 1.1
            ,Account__c = a.id
            ,Street__c = '123 Broadway'
            ,State_Province__c = 'NY'
            ,Postal_Code__c = '10001'
            ,Country__c = 'UNITED STATES'
            ,City__c = 'New York'
            ,website__c='www.test.com'
            ,point_of_contact_phone__c='0612323431'
            ,point_of_contact_name__c='Test Name'
            ,Partner_Track__c = testPartnerTrackObj.Id
            
        );
       insert location;
       
        location = Database.query('select name, Account__c, id, website__c, is_primary__c, point_of_contact_phone__c,Partner_Track__r.Legal_Address__c,' 
                                + 'point_of_contact_name__c, point_of_contact_email__c, description__c,'
                                + 'street__c, city__c, state_province__c, postal_code__c, country__c, longitude__c,'
                                + 'latitude__c, account__r.name, account__r.id, account__r.logo__c, '
                                + 'Partner_Track__r.Logo__c,' 
                                + 'Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c,'
                                + 'Partner_Track__r.Partner_Track_Account_Local_Name__c ,'
                                + 'Partner_Track__r.Legal_Address_City__c,'
                                + 'Partner_Track__r.Legal_Address_Street__c,'
                                + 'Partner_Track__r.Legal_Address_State_Province__c,'
                                + 'Partner_Track__r.Legal_Address_Postal_Code__c ,'
                                + 'Partner_Track__r.Legal_Address_Country__c,'
                                + 'Partner_Track__r.Dell_Technologies_Partner__c,'
                                + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                                + 'Partner_Track__r.Certification_Completed__c,'
                                + 'Partner_Track__r.Services_Competencies__c ,'
                                + 'Partner_Track__r.partner_finder_recommended_flag__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Partner_Type__c,'
                                + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + location.Id + '\'');
       
       ID partnerAccountId  = location.Partner_Track__r.id; 
       
       Map<String,String> mapServiceCompetency =new Map<String,String>();
        mapServiceCompetency.put('storage','storage');
       FAP_SearchHit searchHit = new FAP_SearchHit(location);
       //searchHit.userRequestedFieldValues
        final FAP_SearchHitWrapper wrapper = new FAP_SearchHitWrapper(new FAP_SearchHit(location),config);
        Map<Id,String> mapPL = new Map<Id,String>();
        mapPL.put(partnerAccountId,'test');
       searchHit.mapPL=mapPL;
        final FAP_SearchHitWrapper wrap1 = new FAP_SearchHitWrapper(searchHit,config);

        System.debug(wrapper.point); 
        System.debug(wrapper.containsDistance);
        System.debug(wrapper.distanceInKilometers); 
        System.debug(wrapper.distanceInMiles);
        System.debug(wrapper.isRecommended); 
        System.debug(wrapper.logoId);
        System.assertEquals(null, new FAP_SearchHit(location).mapPL.get(partnerAccountId));       
    }
}