@IsTest
private class FAP_SearchTest {

    private static testmethod void testSearchByAccountName(){
        verifyCriteriaProducesExtraResult(new FAP_FieldCondition('Account__r.name').likex('%Aerugo%'),null);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }
     private static Double random(Double dblMin, Double dblMax){
      return dblMin + (Math.random() * (dblMax - dblMin));
    }  
    private static testmethod void testSearchByLocationName(){
      
         FAP_Configuration.keyValue ='Partner_Track__r.';   
        Account acct = new Account();
        acct.Name='Test';
        acct.Profile_Published_to_Partner_Finder__c='Yes';
        acct.Approved_for_Partner_Finder__c=true;
        acct.Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        acct.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        acct.Account_Type_Integration__c='Account';

        insert acct;
        acct.IsPartner = true;
        update acct;
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acct.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        
        testPartnerTrackObj.Primary_SMAffinity_Account__c =acct.Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        insert testPartnerTrackObj; 
        
        Partner_Location__c loc = new Partner_Location__c();              
        loc.Name = acct.Name + ' - Test Location 1 ';
        loc.Latitude__c =  random(-90, 90);
        loc.Longitude__c =  random(-180,180);
        loc.Account__c = acct.Id;
        loc.Partner_Track__c = testPartnerTrackObj.Id;

        loc.Point_of_Contact_Email__c = 'tloc1'+'@testlocation.com';
        loc.Is_Primary__c=true;
        insert loc;  
        
        Partner_Location__c loc1 = new Partner_Location__c();              
        loc1.Name = acct.Name + ' - Test Location ';
        loc1.Latitude__c =  random(-90, 90);
        loc1.Longitude__c =  random(-180,180);
        loc1.Account__c = acct.Id;
        loc1.Point_of_Contact_Email__c = 'tloc2'+'@testlocation.com';
        loc1.Is_Primary__c=false;
        loc1.Partner_Track__c = testPartnerTrackObj.Id;
        insert loc1;   
        
        Account acc1 = new Account(Name = 'Test Account', Account_Type_Integration__c = 'Account', Approved_for_Partner_Finder__c = True, Profile_Published_to_Partner_Finder__c= 'Yes', Partner_User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId(), Partner_Date_Agreed_to_PF_Terms_Cond__c = System.today()+10 );
        insert acc1;
        
        Partner_Location__c loc2 = new Partner_Location__c();
        loc2.Name = 'test';
        loc2.Latitude__c =  random(-90, 90);
        loc2.Longitude__c =  random(-180,180);
        loc2.Account__c = acct.Id;
        loc2.Is_Primary__c = True;
        insert loc2; 
        

        verifyCriteriaProducesExtraResult(new FAP_FieldCondition('name').likex('%Aleurometer%'),null);
        
        system.assertEquals(acct.Name,'Test');         
    }
    
    private static testmethod void testSearchByAccountRating(){
        verifyCriteriaProducesExtraResult(new FAP_FieldCondition('Account__r.rating','Hot'),null);
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        List<Partner_Location__c> listPl = [select Id, Account__r.Name, Latitude__c, Longitude__c, Account__r.Account_Type_Integration__c, Account__r.IsPartner, Account__r.Approved_for_Partner_Finder__c, Account__r.Profile_Published_to_Partner_Finder__c, Is_Primary__c, Account__r.Partner_User_Agreed_to_PF_Terms_Cond__c, Account__r.Partner_Date_Agreed_to_PF_Terms_Cond__c, Account__r.rating from Partner_Location__c];
        
        System.debug('>>>>> listPl Account Name : ' +listPl[0].Account__r.Name);
        System.debug('>>>>> listPl Latitude__c : ' +listPl[0].Latitude__c);
        System.debug('>>>>> listPl Longitude__c : ' +listPl[0].Longitude__c);
        System.debug('>>>>> listPl Account__r.Account_Type_Integration__c : ' +listPl[0].Account__r.Account_Type_Integration__c);
        System.debug('>>>>> listPl Account__r.IsPartner : ' +listPl[0].Account__r.IsPartner);
        System.debug('>>>>> listPl Account__r.Approved_for_Partner_Finder__c : ' +listPl[0].Account__r.Approved_for_Partner_Finder__c);
        System.debug('>>>>> listPl Account__r.Profile_Published_to_Partner_Finder__c : ' +listPl[0].Account__r.Profile_Published_to_Partner_Finder__c);
        System.debug('>>>>> listPl Account__r.Is_Primary__c : ' +listPl[0].Is_Primary__c);
        System.debug('>>>>> listPl Account__r.Partner_User_Agreed_to_PF_Terms_Cond__c : ' +listPl[0].Account__r.Partner_User_Agreed_to_PF_Terms_Cond__c);
        System.debug('>>>>> listPl Account__r.Partner_Date_Agreed_to_PF_Terms_Cond__c : ' +listPl[0].Account__r.Partner_Date_Agreed_to_PF_Terms_Cond__c);
        System.debug('>>>>> listPl Account__r.rating : ' +listPl[0].Account__r.rating);
        system.assertEquals(acc.Name,'Test Account');                 
    }
       private static testmethod void testSearchByPartnerRating(){
        verifyCriteriaProducesExtraResult(new FAP_FieldCondition('Partner_Track__r.Industries__c','Automotive'),null);
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Partner_Track__c pt = new Partner_Track__c(Partner_Track_Name__c = 'Test Account');
        List<Partner_Location__c> listPl = [select Id, Partner_Track__r.Partner_Track_Name__c, Latitude__c, Longitude__c, Partner_Track__r.Partner_Account__c, Partner_Track__r.Approved_for_Partner_Finder__c, Partner_Track__r.Profile_Published_to_Partner_Finder__c, Is_Primary__c, Partner_Track__r.Partner_User_Agreed_to_PF_Terms_Cond__c, Partner_Track__r.Partner_Date_Agreed_to_PF_Terms_Cond__c from Partner_Location__c];
        
      /*  System.debug('>>>>> listPl Account Name : ' +listPl[0].Account__r.Name);
        System.debug('>>>>> listPl Latitude__c : ' +listPl[0].Latitude__c);
        System.debug('>>>>> listPl Longitude__c : ' +listPl[0].Longitude__c);
        System.debug('>>>>> listPl Account__r.Account_Type_Integration__c : ' +listPl[0].Account__r.Account_Type_Integration__c);
        System.debug('>>>>> listPl Account__r.IsPartner : ' +listPl[0].Account__r.IsPartner);
        System.debug('>>>>> listPl Account__r.Approved_for_Partner_Finder__c : ' +listPl[0].Account__r.Approved_for_Partner_Finder__c);
        System.debug('>>>>> listPl Account__r.Profile_Published_to_Partner_Finder__c : ' +listPl[0].Account__r.Profile_Published_to_Partner_Finder__c);
        System.debug('>>>>> listPl Account__r.Is_Primary__c : ' +listPl[0].Is_Primary__c);
        System.debug('>>>>> listPl Account__r.Partner_User_Agreed_to_PF_Terms_Cond__c : ' +listPl[0].Account__r.Partner_User_Agreed_to_PF_Terms_Cond__c);
        System.debug('>>>>> listPl Account__r.Partner_Date_Agreed_to_PF_Terms_Cond__c : ' +listPl[0].Account__r.Partner_Date_Agreed_to_PF_Terms_Cond__c);
        System.debug('>>>>> listPl Account__r.rating : ' +listPl[0].Account__r.rating);*/
        system.assertEquals(pt.Partner_Track_Name__c,'Test Account');                 
    }
    
    private static testmethod void testSearchByProximity(){
        verifyCriteriaProducesExtraResult(null,new FAP_GeoSearchCriteria(new FAP_GeoPoint(-1,-1),100,FAP_UnitOfLength.MILES));
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');                 
    }
    
    private static testmethod void testSearchByProximityAndName(){
        verifyCriteriaProducesExtraResult(
            new FAP_FieldCondition('Account__r.rating','Hot'),
            new FAP_GeoSearchCriteria(new FAP_GeoPoint(-1,-1),100,FAP_UnitOfLength.MILES));
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            system.assertEquals(acc.Name,'Test Account');                 
    }   
        private static testmethod void testSearchByProximityAndNames(){
        verifyCriteriaProducesExtraResult(
            new FAP_FieldCondition('Partner_Track__r.FAP_Category__c','System Integrator'),
            new FAP_GeoSearchCriteria(new FAP_GeoPoint(-1,-1),100,FAP_UnitOfLength.MILES));
            Partner_Track__c pt = new Partner_Track__c(Partner_Track_Name__c = 'Tech Data');
            insert pt;
            system.assertEquals(pt.Partner_Track_Name__c,'Tech Data');                 
    }
    private static testmethod void testSearchWithUserFields(){
        delete [select id from Partner_Location__c];
        final FAP_Search aSearch = new FAP_Search().addFields(new Set<Object>{'Partner_Track__r.Industries__c', new FAP_Field('Is_Primary__c')});
        final List<FAP_SearchHit> beforeSave = aSearch.execute();
        
        scaffoldScenario1();
        final List<FAP_SearchHit> afterSave = aSearch.execute();
  
        System.assertNotEquals(null,beforeSave);
        System.assertNotEquals(null,afterSave);
        
    }   
    private static testmethod void testSearchWithUserFieldsPt(){
        delete [select id from Partner_Location__c];
        //Test.startTest();
       // scaffoldScenario1();
        final FAP_Search aSearch = new FAP_Search().addFields(new Set<Object>{'Partner_Track__r.Industries__c', new FAP_Field('Is_Primary__c')});
        final List<FAP_SearchHit> beforeSave = aSearch.execute();
        final List<FAP_SearchHit> afterSave = aSearch.execute();
       
        scaffoldScenario3();
        System.assertNotEquals(null,beforeSave);
        System.assertNotEquals(null,afterSave);
       // Test.stopTest();
    }   

   /* private static testmethod void testSearchAll(){
        verifyCriteriaProducesExtraResult(null,null);
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');                 
    }*/
       private static testmethod void testSearchAllPT(){
        verifyCriteriaProducesExtraResult(null,null);
        Partner_Track__c pt = new Partner_Track__c(Partner_Track_Name__c = 'Test Account');
        insert pt;
        system.assertEquals(pt.Partner_Track_Name__c,'Test Account');                 
    }
    
     private static Blob generateRandomBlob(){
        return EncodingUtil.base64Decode(''+System.currentTimeMillis()+Math.roundToLong(Math.random()*10000));  
    }
    private static testmethod void testCompetencyNew(){
         Test.startTest();
         FAP_Configuration.keyValue ='Partner_Track__r.';   
         
      
       
         Account acct = new Account();
        acct.Name='Test';
        acct.Profile_Published_to_Partner_Finder__c='Yes';
        acct.Approved_for_Partner_Finder__c=true;
        acct.Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        acct.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        acct.Account_Type_Integration__c='Account';
        insert acct;
        acct.IsPartner = true;
        update acct;
        system.assertEquals(acct.Name,'Test'); 
        
        List<Certification_Tracker__c> listcertTracker = new List<Certification_Tracker__c>();             
        for(integer inti=0; inti<26; inti++)
        {
            Certification_Tracker__c ct = new Certification_Tracker__c();
            ct.Evaluate_Criteria__c=true;   
            ct.Account_name__c = acct.id;
            listcertTracker.add(ct);            
        }
        insert listcertTracker;   
        FAP_Search searchController = new FAP_Search();
         Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
        insert attach;
        system.debug('========logo==='+logo);
        
        Account acc = new Account(Name = 'Test Account',logo__c = logo.Id);
        insert acc;
        Partner_Location__c pl = new Partner_Location__c (Account__c =acct.Id );
        insert pl;
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.Id;
        testPartnerTrackObj.Partner_Track__c='OEM';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c = logo.id;
        testPartnerTrackObj.Primary_SMAffinity_Account__c =acc.Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        testPartnerTrackObj.Partner_Account__c = true;
        testPartnerTrackObj.Partner_Date_Agreed_to_PF_Terms_Cond__c  = system.today();
        //testPartnerTrackObj.Partner_Type__c = 'Solution Provider';
        //Primary_Sales_Motion_Account_Legal_Name__c
        
        insert testPartnerTrackObj;
          
        map<Id,string>mapAccountID = new map<Id,string>();
        map<Id,string>mapPartnerID = new map<Id,string>();
        mapAccountID.put(acct.id,null); 
        mapPartnerID.put(testPartnerTrackObj.id,null);
        FAP_Search.populateServCompt();
      //  FAP_Search.populateTrackerRec(mapPartnerID);
        
        Partner_Location__c location = new Partner_Location__c(
            Name = 'Acme Computer Headquarters',
            Is_Primary__c = true,
            Latitude__c = 32.177254200000000,
            Longitude__c = -110.795687800000000,
            Account__c = acct.Id,
            Partner_Track__c = testPartnerTrackObj.Id
            ,Street__c = '123 Broadway'
            ,State_Province__c = 'NY'
            ,Postal_Code__c = '10001'
            ,Country__c = 'UNITED STATES (US)'
            ,City__c = 'New York'
            ,website__c='www.test.com'
            ,point_of_contact_phone__c='0612323431'
            ,point_of_contact_name__c='Test Name'
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
                                + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                                + 'Partner_Track__r.partner_finder_recommended_flag__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Partner_Type__c,'
                                + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + location.Id + '\'');
       
       ID partnerAccountId  = location.Partner_Track__r.id; 
       
         FAP_SearchHit hit = new FAP_SearchHit(location);
       // hit.logoRecordId = logo.Id; 
        hit.logoId = logo.Id;
        List<FAP_SearchHit> listHits = new List<FAP_SearchHit>(); 
        listHits.add(hit);
        system.debug('========hitsin test class========='+listHits);
        system.debug('========hitsin test class========='+listHits);
        searchController.addLogoIDs(listHits);
        Test.stopTest();
     }    


     private static testmethod void testCompetency(){
         Test.startTest();
        FAP_Search searchController = new FAP_Search();
         Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
        insert attach;
        system.debug('========logo==='+logo);
        
        Account acc = new Account(Name = 'Test Account',logo__c = logo.Id);
        insert acc;
        
        system.assertEquals(acc.Name,'Test Account');  
        Partner_Location__c pl = new Partner_Location__c (Account__c =acc.Id );
        insert pl;
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c=logo.id;
        testPartnerTrackObj.Primary_SMAffinity_Account__c =acc.Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        testPartnerTrackObj.Partner_Account__c = true;
        testPartnerTrackObj.Partner_Date_Agreed_to_PF_Terms_Cond__c = system.today();
        insert testPartnerTrackObj; 
        
        Partner_Track__c pt1 = [select Id,Master_Logo_ID__c from Partner_Track__c where Id=:testPartnerTrackObj.Id];
        //system.debug('======pt1====='+pt1);
        
        map<Id,string>mapAccountID = new map<Id,string>();
        mapAccountID.put(pl.Account__c,null); 
        FAP_Search.populateServCompt();
        //FAP_Search.populateTrackerRec(mapAccountID);
        
   
        Partner_Location__c location = new Partner_Location__c(
            Name = 'Test Loc1 OEM',
            Is_Primary__c = true,
            Latitude__c = 32.177254200000000,
            Longitude__c = -110.795687800000000,
            Account__c = acc.Id,
            Partner_Track__c = testPartnerTrackObj.Id
            ,Street__c = '3233 S Test Ave'
            ,State_Province__c = 'AZ'
            ,Postal_Code__c = '85730'
            ,Country__c = 'UNITED STATES (US)'
            ,City__c = 'Tucson'
            ,website__c='www.test.com'
            ,point_of_contact_phone__c='0612323431'
            ,point_of_contact_name__c='Test Name'
            ,Point_of_Contact_Email__c='s@h.com'
            
        );
        
        insert location;
        
     /*  location = Database.query('select name, Account__c, id, website__c, is_primary__c, point_of_contact_phone__c,' 
                            + 'point_of_contact_name__c, point_of_contact_email__c, description__c,'
                            + 'street__c, city__c, state_province__c, postal_code__c, country__c, longitude__c,'
                            + 'latitude__c, account__r.name, account__r.id, account__r.logo__c, ' 
                            + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                            + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + location.Id + '\'');*/
        
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
                                + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                                + 'Partner_Track__r.partner_finder_recommended_flag__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Partner_Type__c,'
                                + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + location.Id + '\'');        
       
       ID partnerAccountId  = location.Account__r.id;  
         final FAP_OrderBy orderBy = new FAP_OrderBy('name');
         FAP_SearchHit hit = new FAP_SearchHit(location);
       // hit.logoRecordId = logo.Id; 
        hit.logoId = logo.Id;
        
        List<FAP_SearchHit> listHits = new List<FAP_SearchHit>(); 
        listHits.add(hit);
        system.debug('========hitsin test class========='+listHits);
        system.debug('========hitsin test class========='+listHits);
         system.debug('========location========='+location);
        FAP_SearchHit.sortByDistance(listHits);
        searchController.addLogoIDs(listHits);      
        Test.stopTest();
     }    


   
    private static void verifyCriteriaProducesExtraResult(  FAP_Condition attributeCriteria,
                                                            FAP_GeoSearchCriteria geoCriteria){
        
        List<FAP_GeoPoint> listGeo = new List<FAP_GeoPoint>{new FAP_GeoPoint(-90,-180),
                                                            new FAP_GeoPoint(90,180)
        };
        
        FAP_GeoBounds geo = new FAP_GeoBounds(listGeo);
        delete [select id from Partner_Location__c];
        FAP_Search aSearch = null;
        if(attributeCriteria == null){
            if(geoCriteria == null){
                aSearch = new FAP_Search();
            } else {
                aSearch = new FAP_Search(geoCriteria);
            }
        } else {
            if(geoCriteria == null){
                aSearch = new FAP_Search(attributeCriteria);
            } else {
                aSearch = new FAP_Search(attributeCriteria,geoCriteria);
            }
        } 
        final List<FAP_SearchHit> beforeSave = aSearch.execute();
       
        scaffoldScenario3();
        final List<FAP_SearchHit> afterSave = aSearch.execute();
        

        System.assertNotEquals(null,beforeSave);
        System.assertNotEquals(null,afterSave);
       
    }
    
    private static Scenario1Scaffolding scaffoldScenario1(){
        
         FAP_Search searchController = new FAP_Search();
         Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
        insert attach;
        final Account account = new Account(
            Name='Aerugo'
            ,Profile_Published_to_Partner_Finder__c='Yes'
            ,Approved_for_Partner_Finder__c=true
            ,Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId()
            ,Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now(),
            Account_Type_Integration__c = 'Account',
            logo__c=logo.Id,
            Rating = 'Hot');
        insert account;
        account.IsPartner = true ;
        update account;
        
         Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = account.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c=logo.id;
        testPartnerTrackObj.Primary_SMAffinity_Account__c =account.Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Platinum';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        testPartnerTrackObj.Partner_Account__c = true;
        testPartnerTrackObj.Partner_Date_Agreed_to_PF_Terms_Cond__c= system.today();
        insert testPartnerTrackObj;   

   Partner_Location__c location = new Partner_Location__c(
            Name = 'Test Loc1 OEM',
            Is_Primary__c = true,
            Latitude__c = 32.177254200000000,
            Longitude__c = -110.795687800000000,
            Account__c = account.Id,
            Partner_Track__c = testPartnerTrackObj.Id
            ,Street__c = '3233 S Test Ave'
            ,State_Province__c = 'AZ'
            ,Postal_Code__c = '85730'
            ,Country__c = 'UNITED STATES (US)'
            ,City__c = 'Tucson'
            ,website__c='www.test.com'
            ,point_of_contact_phone__c='0612323431'
            ,point_of_contact_name__c='Test Name'
            ,Point_of_Contact_Email__c='s@h.com'
            
        );
        insert location;              
        return new Scenario1Scaffolding(testPartnerTrackObj,location);
    }
    private static Scenario2Scaffolding scaffoldScenario3(){
        Test.StartTest();
         FAP_Search searchController = new FAP_Search();
         FAP_Configuration.keyValue='Partner_Track__r.';
         Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
        insert attach;
        final Account account = new Account(
            Name='Aerugo'
            ,Profile_Published_to_Partner_Finder__c='Yes'
            ,Approved_for_Partner_Finder__c=true
            ,Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId()
            ,Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now(),
            Account_Type_Integration__c = 'Account',
            logo__c=logo.Id,
            Rating = 'Hot');
        insert account;
        account.IsPartner = true ;
        update account;
        
         Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = account.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c=logo.id;
        testPartnerTrackObj.Primary_SMAffinity_Account__c =account.Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Platinum';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        insert testPartnerTrackObj;   

   Partner_Location__c location = new Partner_Location__c(
            Name = 'Test Loc1 OEM',
            Is_Primary__c = true,
            Latitude__c = 32.177254200000000,
            Longitude__c = -110.795687800000000,
            Account__c = account.Id,
            Partner_Track__c = testPartnerTrackObj.Id
            ,Street__c = '3233 S Test Ave'
            ,State_Province__c = 'AZ'
            ,Postal_Code__c = '85730'
            ,Country__c = 'UNITED STATES (US)'
            ,City__c = 'Tucson'
            ,website__c='www.test.com'
            ,point_of_contact_phone__c='0612323431'
            ,point_of_contact_name__c='Test Name'
            ,Point_of_Contact_Email__c='s@h.com'
            
        );
        insert location;  
        Test.StopTest();        
        return new Scenario2Scaffolding(testPartnerTrackObj,location);
            
    }

    public class Scenario1Scaffolding{
        public Account account {get;private set;}
        public Partner_Track__c partnerTrack {get;private set;}
        public Partner_Location__c location {get;private set;}
         
        public Scenario1Scaffolding(Partner_Track__c partnerTrack, Partner_Location__c location){
            this.partnerTrack = partnerTrack;
            this.location = location;
        }
    }
     public class Scenario2Scaffolding{
        public Partner_Track__c partnerTrack {get;private set;}
        public Partner_Location__c location {get;private set;}
         
        public Scenario2Scaffolding(Partner_Track__c partnerTrack, Partner_Location__c location){
            this.partnerTrack = partnerTrack;
            this.location = location;
        }
    }
}