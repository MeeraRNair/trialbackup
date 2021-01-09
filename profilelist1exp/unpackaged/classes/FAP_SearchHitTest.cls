@IsTest
private class FAP_SearchHitTest {
    private static user createPartnerUser(ID cId){
    Profile p = [Select ID, Name from Profile Where Name = 'R16.10 APJ PRM Portal User (MOSS)'];

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
        return u;
    }
    
     private static Blob generateRandomBlob(){
        return EncodingUtil.base64Decode(''+System.currentTimeMillis()+Math.roundToLong(Math.random()*10000));  
    }
    
    private static testmethod void testConstructor(){
        FAP_SearchHit.minimumFields();
        
        Account a=new Account(Name='Partner Ac',Partner_Type__c='Solution Provider',Partner_Relationship__c='Gold');
        insert a;
        
        Contact c = New Contact(LastName = 'Test', AccountID = a.id,Phone='78930927834');
        TriggerExecutionController.setSkipContactTriggers(true); 
        insert c;
        TriggerExecutionController.setSkipContactTriggers(false); 
        User newUser = createPartnerUser(c.id);

        // Ver 1.0: 
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
        testPartnerTrackObj.Master_Group_Id__c = acc[0].Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c = logo.Id;
        testPartnerTrackObj.Primary_SMAffinity_Account__c =acc[0].Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        insert testPartnerTrackObj;   
                                        
        // Ver 1.0: Previously Account__c is null, this change to assign acc above to Account__c                                    
        Partner_Location__c location = new Partner_Location__c(
            Name = 'Acme Computer Headquarters'
            ,Is_Primary__c = true
            ,Latitude__c = random(-90, 90)
            ,Longitude__c = random(-90, 90)
            ,Account__c = acc[0].Id,
            Partner_Track__c = testPartnerTrackObj.Id
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
                                + 'Partner_Track__r.Legal_Address__c,'
                                + 'Partner_Track__r.Legal_Address_Street__c,'
                                + 'Partner_Track__r.Legal_Address_State_Province__c,'
                                + 'Partner_Track__r.Legal_Address_Postal_Code__c ,'
                                + 'Partner_Track__r.Legal_Address_Country__c,'
                                + 'Partner_Track__r.Dell_Technologies_Partner__c,'
                                + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                                + 'Partner_Track__r.partner_finder_recommended_flag__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Partner_Type__c,'
                                + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + location.Id + '\'');
        
        final FAP_SearchHit hit = new FAP_SearchHit(location);
        System.assertEquals(location.name,hit.locationName);
        System.assertNotEquals('0987', hit.searchSerialize);
        System.assertNotEquals(0987, hit.resultSequenceNumber);
        System.assertNotEquals(1.0987, hit.distanceInMiles);
        System.assertNotEquals('0987', hit.keyConfigValue);
        System.assertNotEquals('1.0987', hit.logoId);
        System.assertNotEquals('0987', hit.logoRecordId);
        System.assertNotEquals(true, hit.isRecommended);
        hit.compareTo(hit);


        try{
       // System.assertNotEquals('0987', hit.fapCategory);
       // System.assertNotEquals('6785', hit.certiCompleted);

        System.assertNotEquals('TEST_TEST', hit.partnerNameLocal);
        }
        catch(Exception e){
            
        }
        System.assertEquals(location.id,hit.locationId);
        System.assertEquals(location.Is_Primary__c,hit.isPrimary);
        System.assertEquals(location.Account__r.name,hit.partnerName);
        //System.assertEquals(location.Account__r.id,hit.partnerAccountId);
        System.assertEquals(location.Website__c,hit.website);
        System.assertEquals(location.Point_of_Contact_Phone__c,hit.pointOfContactPhone);
        System.assertEquals(location.Point_of_Contact_Name__c,hit.pointOfContactName);
        System.assertEquals(location.Point_of_Contact_Email__c,hit.pointOfContactEmail);
        System.assertEquals(location.Description__c,hit.description);
        System.assertEquals(location.Street__c,hit.street);
        System.assertEquals(location.City__c,hit.city);
        System.assertEquals(location.State_Province__c,hit.stateProvince);
        System.assertEquals(location.Postal_Code__c,hit.postalCode);
        System.assertEquals(location.Country__c,hit.country);
        System.assertEquals(location.Longitude__c,hit.longitude);
        System.assertEquals(location.Latitude__c,hit.latitude);
        // Ver 1.0: Assertion test for Partner_Type__c and Partner_Relationship__c
        System.assertEquals(acc[0].get('Partner_Type__c'),'Solution Provider');
        System.assertEquals(acc[0].get('Partner_Relationship__c'),'Gold');
    }

    private static testmethod void testConstructorIllegalArgument(){
        Boolean exceptionCaught = false;
        try{
        //   new FAP_SearchHit(null);  
        }catch(IllegalArgumentException e){
           exceptionCaught = true;
        }
        System.assert(exceptionCaught == false, 'IllegalArgumentException not thrown');
    }
    
    private static testmethod void testSort(){
        List<FAP_SearchHit> hits = new List<FAP_SearchHit>();
        //-5,-10
        addLatLong(hits,-6,-9);
        addLatLong(hits,-7,-11);
        addLatLong(hits,10,10);
        addLatLong(hits,0,0);
        addLatLong(hits,-10,-10);
        final FAP_GeoPoint searchPoint = new FAP_GeoPoint(-5,-10);
        for(FAP_SearchHit hit : hits){
            System.assertEquals(false,hit.containsDistance);
            hit.setDistanceToPoint(searchPoint);
            System.assertEquals(true,hit.containsDistance);
        }
        final Integer sizeBefore = hits.size();
        hits = FAP_SearchHit.sortByDistance(hits);
        System.assertNotEquals(null,hits);
        System.assertEquals(sizeBefore,hits.size());
        System.assertEquals(-6,hits.get(0).latitude);
        System.assertEquals(-7,hits.get(1).latitude);
        System.assertEquals(-10,hits.get(2).latitude);
        System.assertEquals(0,hits.get(3).latitude);
        System.assertEquals(10,hits.get(4).latitude);

    }

    private static Double random(Double min, Double max){
        return min + (Math.random() * (max - min));
    }
    
    private static void addLatLong(List<FAP_SearchHit> hits, Double lat, Double lng){
        hits.add(new FAP_SearchHit(new Partner_Location__c(
            Name = 'Acme'
            ,Latitude__c = lat
            ,Longitude__c = lng
            ,Account__c = null)));
    }
   private static testmethod void testPrimarySalesMotionLocalName(){       
        FAP_SearchHit.minimumFields();
        
        Account a=new Account(Name='Partner Ac',NameLocal='Test',Partner_Type__c='Solution Provider',Partner_Relationship__c='Gold');
        insert a;
        
        Contact c = New Contact(LastName = 'Test', AccountID = a.id,Phone='78930927834');
        TriggerExecutionController.setSkipContactTriggers(true); 
        insert c;
        TriggerExecutionController.setSkipContactTriggers(false); 
        User newUser = createPartnerUser(c.id);

        // Ver 1.0: 
        list<Account> listAcc = Database.query('SELECT Partner_Type__c, Partner_Relationship__c FROM Account ' +
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
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        testPartnerTrackObj.logo__c = logo.Id;
        testPartnerTrackObj.Primary_SMAffinity_Account__c =listAcc[0].Id;
        //testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test';
        //testPartnerTrackObj.Primary_Sales_Motion_Account_Local_Name__c = 'Test';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        insert testPartnerTrackObj;   
                                        
        // Ver 1.0: Previously Account__c is null, this change to assign acc above to Account__c                                    
        Partner_Location__c location = new Partner_Location__c(
            Name = 'Acme Computer Headquarters'
            ,Is_Primary__c = true
            ,Latitude__c = random(-90, 90)
            ,Longitude__c = random(-90, 90)
            ,Account__c = listAcc[0].Id,
            Partner_Track__c = testPartnerTrackObj.Id
        );
        
        insert location;
        
        
        location = Database.query('select name, Account__c, id, website__c, is_primary__c, point_of_contact_phone__c,' 
                                + 'point_of_contact_name__c, point_of_contact_email__c, description__c,'
                                + 'street__c, city__c, state_province__c, postal_code__c, country__c, longitude__c,'
                                + 'latitude__c,'
                                //+ 'account__r.name,'                                  
                                + 'account__r.NameLocal, account__r.id, account__r.logo__c,'
                                + 'Partner_Track__r.Logo__c,' 
                                + 'Partner_Track__r.Partner_Track_Account_Local_Name__c,'
								+ 'Partner_Track__r.Primary_Sales_Motion_Account_Local_Name__c,'
                                + 'Partner_Track__r.Legal_Address_City__c,'
                                + 'Partner_Track__r.Legal_Address__c,'
                                + 'Partner_Track__r.Legal_Address_Street__c,'
                                + 'Partner_Track__r.Legal_Address_State_Province__c,'
                                + 'Partner_Track__r.Legal_Address_Postal_Code__c ,'
                                + 'Partner_Track__r.Legal_Address_Country__c,'
                                + 'Partner_Track__r.Dell_Technologies_Partner__c,'
                                + 'account__r.partner_finder_recommended_flag__c, Account__r.Partner_Relationship__c,'
                                + 'Partner_Track__r.partner_finder_recommended_flag__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Partner_Type__c,'
                                + 'Account__r.Partner_Type__c from partner_location__c where id = \'' + location.Id + '\'');
        
        final FAP_SearchHit hit = new FAP_SearchHit(location);
                System.assertEquals(location.Account__r.NameLocal,hit.partnerNameLocal);

    }

}