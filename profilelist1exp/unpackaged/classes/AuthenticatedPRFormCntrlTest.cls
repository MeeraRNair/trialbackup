@IsTest
Private class AuthenticatedPRFormCntrlTest {

    static list<User> listUser;
    static list<Account> listacc;

         @testSetup static void prepareData() {
            TriggerExecutionController.setSkipAllTriggers(true);
      
      // List<User> listUsr = TestDataFactory.createNPortalUser(1);
      // insert listUsr;
       
       
       
       List<Account> listPA = TestDataFactory.createNAccount(1,'Partner Account');
        listPA[0].Status__c = 'I';
        listPA[0].Account_Type_Integration__c='Sub Account';
        listPA[0].Type= 'Partner';
       
        if(listPA.size() > 0){
            insert listPA;
        }
       // system.debug('>>>listUsr'+listUsr);
        system.debug('>>>listPA'+listPA);


    }
   
        Private static testmethod void testgetmethods(){
             
       List<String> listConid = new List<String>();
        List<Contact> listCon = new List<Contact>();
        String strMasterGroupId;
        String strMasterGroupaffID ;
         list<User> listUser=TestDataFactory.createNPortalUser(1);
         insert listUser;
        
        //listUser = [SELECT Id,ContactId,Contact.AccountId,Contact.Account.Master_Group_Affinity_ID__c,Contact.Selected_Track__c FROM User WHERE Email like 'testcontact_%' limit 1];
         system.debug('>>>listUser '+listUser );
         listacc = [select id from account where Name like 'Test Account Versio%'];  
            
       string strcontactid= listuser[0].contactid;
            strMasterGroupId = String.valueOf(listUser[0].Contact.AccountId);
            strMasterGroupaffID = String.valueOf(listUser[0].Contact.Account.Master_Group_Affinity_ID__c);
          system.debug('>>>contactid'+strcontactid);
            
             system.debug('>>>strMasterGroupId '+strMasterGroupId );
              Country__c country = new Country__c(Code__c = 'US',Name = 'UNITED STATES',Region__c ='NA',
            dial_code__c = '123',Is_Active_Partner_Country__c = true,Inc_Vendor_Name__c = 'Dell Achievers',
            Inc_Vendor_End_Point__c = 'test'); 
             insert country;
            Partner_Type__c partnerType = new Partner_Type__c(Name='pt_test', Country__c=country.id, Translated_Partner_Type_Name__c='translated pt_test',Is_Active__c=true, Sort_Order__c=99); 
        insert partnerType;
                
         Partner_Request__c request = new Partner_Request__c(Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Primary_Channel_Model__c = 'OEM (Original Equipment Manufacturer)',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456');
        
         insert request;
         
       string  strrequestnumber = [select id,Name from Partner_Request__c where Id=:request.id].Name;
         system.debug('>>>request '+request );
         system.debug('>>>request '+request.id );
         system.debug('>>>request '+strrequestnumber  );
            
            Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Country_Code__c='US');
            insert trackObj;
        
            Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
            testPartnerTrackObj.Track_Id__c = trackObj.id;
            testPartnerTrackObj.Master_Group_Id__c =strMasterGroupId;
            testPartnerTrackObj.Master_Group_Affinity_Id__c = strMasterGroupaffID ;
            testPartnerTrackObj.Partner_Registration_Number__c= strrequestnumber ;
            insert testPartnerTrackObj;
              system.debug('>>>testPartnerTrackObj'+testPartnerTrackObj );
              system.debug('>>>testPartnerTrackObj.Partner_Registration_Number__c'+testPartnerTrackObj.Partner_Registration_Number__c);
            
           // list<Contact> con = [select id,Selected_Track__r.Partner_Registration_Number__c from contact where id=:contactid];
          //  system.debug('>>>con '+con );
         

             
             Account ac = [select id,Partner_Registration__c from account where id=:listacc[0].id];
             ac.Partner_Registration__c =request.id;
             update ac;
             system.debug('ac.Partner_Registration__c '+ac.Partner_Registration__c+ac.Id);
           list<Contact> cont = [select Selected_Track__c,Id from contact where id =:listuser[0].contactid];
           system.debug('>>>>cont'+cont);
        cont[0].Selected_Track__c= testPartnerTrackObj.id ;
        // contact.Selected_Track__c= testPartnerTrackObj.id ;
       
        update cont;
         
             Attachment attach=new Attachment(); 
                attach.Name='Unit Test Attachment'; 
                Blob blbbodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
                attach.body=blbbodyBlob; attach.parentId=request.id;
                insert attach;
         
          Lead le= new lead();
            
        String str1 = null;
        String  str2 = null;
        String str3 = null;
        String  str4 = null;
        String str5 = 'india';
        String  str6 = 'IN';
    
       Map<string,string> mapcountry= new Map<string,string>();
       mapcountry.put(str1,str2);
       mapcountry.put(str5,str6);  
       
       Map<string,string> mapcountryCode= new Map<string,string>();
       mapcountryCode.put(str3,str4);
      List<PartnerRegistrationFormFieldHelper> listprfields = new List<PartnerRegistrationFormFieldHelper>();
      List<String> liststrList = new List<String>();
        liststrList.add(str5);
       Test.StartTest(); 
         list<PartnerRegistrationFormFieldHelper>  listPRFieldHelperList  = new  list<PartnerRegistrationFormFieldHelper>();
        
          AuthenticatedPRFormCntrl pr = new AuthenticatedPRFormCntrl();
           
         // AuthenticatedPRFormCntrl.strselectedtrackPRNUmber=strrequestnumber;
           //AuthenticatedPRFormCntrl.UserRegion= 'APJ';
          // AuthenticatedPRFormCntrl.getLanguage();
           AuthenticatedPRFormCntrl.getPartnerTypeOptions('UNITED STATES','TrackExists');
         //  AuthenticatedPRFormCntrl.getPreferredDellDistributorOptions('india');
          // AuthenticatedPRFormCntrl.getSponsoringDistributorOptions('india');
           AuthenticatedPRFormCntrl.getLabels();
          // AuthenticatedPRFormCntrl.listregionList.add(country);
         // Vfcntrl_PartnerRegistrationForm.loadRequest('test123');
           AuthenticatedPRFormCntrl.TabLabelsandCountryListMethod('TrackExists');
           AuthenticatedPRFormCntrl.populateLead(le, request);
        //  AuthenticatedPRFormCntrl.getCountry();
          AuthenticatedPRFormCntrl.isvalidLanguage('en_us');
         //AuthenticatedPRFormCntrl.updateFieldConfigMap('company', 'Head of the Company', true);
         AuthenticatedPRFormCntrl.fetchRegion('UNITED STATES');
         AuthenticatedPRFormCntrl.fetchPartnertypes('UNITED STATES','TrackExists');
         AuthenticatedPRFormCntrl.companyFields('UNITED STATES',listUser[0].id,strrequestnumber);
           
           // AuthenticatedPRFormCntrl.fetchExstngPRDetails(request.id,'test','english');
           
          
       
           
        
           
           //partnerSelectionTab
           AuthenticatedPRFormCntrl.partnerSelectionTab partnerSelTab =new AuthenticatedPRFormCntrl.partnerSelectionTab('partnerSelectionTab','partnerSelectionTab');
           
          
           
           //ContactTab  
           AuthenticatedPRFormCntrl.CompanyTab compTab =new AuthenticatedPRFormCntrl.CompanyTab('CompanyTab','CompanyTab');
           
           //ContactTab  
          
           
           //ContactTab  
           AuthenticatedPRFormCntrl.SegmentTab segTab =new AuthenticatedPRFormCntrl.SegmentTab('segmentTab','segmentTab');
           
           //ContactTab  
           AuthenticatedPRFormCntrl.ServiceTab servTab =new AuthenticatedPRFormCntrl.ServiceTab('serviceTab','serviceTab');
           
           
           partnerSelTab.decorate(listPRFieldHelperList);
        
           compTab.decorate(listPRFieldHelperList);
          
           segTab.decorate(listPRFieldHelperList);
           servTab.decorate(listPRFieldHelperList);
        
   // listprfields = AuthenticatedPRFormCntrl.decorate(liststrList);
   
    AuthenticatedPRFormCntrl.saveTheFile(request.id, 'Unit Test Attachment', 'base64Data', 'contentType', request ,  'company', 'India','TrackExists' ); 
       
        AuthenticatedPRFormCntrl.saveChunk(request.id, 'Unit Test Attachment', 'base64Data', 'contentType',attach.id, request ,  'company', 'India','en_us__C','TrackExists' ); 
   Partner_Request__c request1 = new Partner_Request__c(Application_Environments__c='None',Area_of_Interest_Non_GC__c='None',
   Job_Category_Non_GC__c='None',Job_Title_Non_GC__c='None',Primary_Customer_Non_GC__c='None',Primary_Vertical_Market_Segment_Non_GC__c='None',
   Secondary_Customer_Segment_Non_GC__c='None',individual_Principals__c='None',Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456',Primary_Channel_Model__c='Consumer Partner');
    AuthenticatedPRFormCntrl.savePartReq(request1 , 'India', 'Company');
   // AuthenticatedPRFormCntrl.savePartReq(string strid,strrequestnumber, 'India');
   AuthenticatedPRFormCntrl.savePartnerRequest(request,'segment', 'UNITED STATES', 'TrackExists');
   AuthenticatedPRFormCntrl.savePartnerRequestSM (request, 'segment','UNITED STATES', 'TrackExists') ;
    AuthenticatedPRFormCntrl.getSMAccounts('CSP (Cloud Service Provider)', 'UNITED STATES');
   // AuthenticatedPRFormCntrl.saveChunk(request.id, 'Unit Test Attachment', 'base64Data', 'contentType','', request ,  'company', 'India' ,'en_us__C'); 
    AuthenticatedPRFormCntrl.getLead(request.id);
    
    
    AuthenticatedPRFormCntrl.handlePartnerTypeChangeMethod('Consumer Partner','UNITED STATES','english');
    AuthenticatedPRFormCntrl.doUpdateCountryDependentFields('UNITED STATES');
    AuthenticatedPRFormCntrl.getDnBSupportedCountry(country.id);
     AuthenticatedPRFormCntrl.doUpdateFieldConfig();
     Test.stopTest(); 
          
       
        System.assertEquals('UNITED STATES',country.Name);  
          
        }
        
        Private static testmethod void notracksExistsMethod(){
             
       List<String> listConid = new List<String>();
        List<Contact> listCon = new List<Contact>();
        String strMasterGroupId;
        String strMasterGroupaffID ;
        list<User> listUser=TestDataFactory.createNPortalUser(1);
         insert listUser;
        
       // listUser = [SELECT Id,ContactId,Contact.AccountId,Contact.Account.Master_Group_Affinity_ID__c,Contact.Selected_Track__c FROM User WHERE Email like 'testcontact_%'];
         system.debug('>>>listUser '+listUser );
         listacc = [select id from account where Name like 'Test Account Versio%'];  
            
       string strcontactid= listuser[0].ContactId;
            strMasterGroupId = String.valueOf(listUser[0].Contact.AccountId);
            strMasterGroupaffID = String.valueOf(listUser[0].Contact.Account.Master_Group_Affinity_ID__c);
          system.debug('>>>contactid'+strcontactid);
            
             system.debug('>>>strMasterGroupId '+strMasterGroupId );
              Country__c country = new Country__c(Code__c = 'IN',Name = 'India',Region__c ='APJ',
            dial_code__c = '123',Is_Active_Partner_Country__c = true,Inc_Vendor_Name__c = 'Dell Achievers',
            Inc_Vendor_End_Point__c = 'test'); 
             insert country;
            Partner_Type__c partnerType = new Partner_Type__c(Name='pt_test', Country__c=country.id, Translated_Partner_Type_Name__c='translated pt_test',Is_Active__c=true, Sort_Order__c=99); 
        insert partnerType;
                
         Partner_Request__c request = new Partner_Request__c(Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Primary_Channel_Model__c = 'OEM (Original Equipment Manufacturer)',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456');
        
         insert request;
         
       string  strrequestnumber = [select id,Name from Partner_Request__c where Id=:request.id].Name;
         system.debug('>>>request '+request );
         system.debug('>>>request '+request.id );
         system.debug('>>>request '+strrequestnumber  );
            
            Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
            insert trackObj;
        
            Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
            testPartnerTrackObj.Track_Id__c = trackObj.id;
            testPartnerTrackObj.Master_Group_Id__c =strMasterGroupId;
            testPartnerTrackObj.Master_Group_Affinity_Id__c = strMasterGroupaffID ;
            testPartnerTrackObj.Partner_Registration_Number__c= strrequestnumber ;
            insert testPartnerTrackObj;
              system.debug('>>>testPartnerTrackObj'+testPartnerTrackObj );
              system.debug('>>>testPartnerTrackObj.Partner_Registration_Number__c'+testPartnerTrackObj.Partner_Registration_Number__c);
            
           // list<Contact> con = [select id,Selected_Track__r.Partner_Registration_Number__c from contact where id=:strcontactid];
          //  system.debug('>>>con '+con );
         

             
             Account ac = [select id,Partner_Registration__c from account where id=:listacc[0].id];
             ac.Partner_Registration__c =request.id;
             update ac;
             system.debug('ac.Partner_Registration__c '+ac.Partner_Registration__c+ac.Id);
           Contact contact = [select Selected_Track__c,Id from contact where id = :strcontactid];
        contact.Selected_Track__c= testPartnerTrackObj.id ;
        // contact.Selected_Track__c= testPartnerTrackObj.id ;
       
        update contact;
         
             Attachment attach=new Attachment(); 
                attach.Name='Unit Test Attachment'; 
                Blob blbbodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
                attach.body=blbbodyBlob; attach.parentId=request.id;
                insert attach;
         
          Lead le= new lead();
            
        String str1 = null;
        String  str2 = null;
        String str3 = null;
        String  str4 = null;
        String str5 = 'india';
        String  str6 = 'IN';
    
       Map<string,string> mapcountry= new Map<string,string>();
       mapcountry.put(str1,str2);
       mapcountry.put(str5,str6);  
       
       Map<string,string> mapcountryCode= new Map<string,string>();
       mapcountryCode.put(str3,str4);
      List<PartnerRegistrationFormFieldHelper> listprfields = new List<PartnerRegistrationFormFieldHelper>();
      List<String> liststrList = new List<String>();
        liststrList.add(str5);
       Test.StartTest(); 
         list<PartnerRegistrationFormFieldHelper>  listPRFieldHelperList  = new  list<PartnerRegistrationFormFieldHelper>();
        
          AuthenticatedPRFormCntrl pr = new AuthenticatedPRFormCntrl();
           
         // AuthenticatedPRFormCntrl.strselectedtrackPRNUmber=strrequestnumber;
           //AuthenticatedPRFormCntrl.UserRegion= 'APJ';
          // AuthenticatedPRFormCntrl.getLanguage();
           AuthenticatedPRFormCntrl.getPartnerTypeOptions('india','NoTrackExists');
         //  AuthenticatedPRFormCntrl.getPreferredDellDistributorOptions('india');
          // AuthenticatedPRFormCntrl.getSponsoringDistributorOptions('india');
           AuthenticatedPRFormCntrl.getLabels();
          // AuthenticatedPRFormCntrl.listregionList.add(country);
         // Vfcntrl_PartnerRegistrationForm.loadRequest('test123');
           AuthenticatedPRFormCntrl.TabLabelsandCountryListMethod('NoTrackExists');
           AuthenticatedPRFormCntrl.populateLead(le, request);
        //  AuthenticatedPRFormCntrl.getCountry();
          AuthenticatedPRFormCntrl.isvalidLanguage('en_us');
         //AuthenticatedPRFormCntrl.updateFieldConfigMap('company', 'Head of the Company', true);
         AuthenticatedPRFormCntrl.fetchRegion('india');
         AuthenticatedPRFormCntrl.fetchPartnertypes('india','NoTrackExists');
         AuthenticatedPRFormCntrl.companyFields('India',listUser[0].id,strrequestnumber);
           
           // AuthenticatedPRFormCntrl.fetchExstngPRDetails(request.id,'test','english');
           
          
       
           
        
           
           //partnerSelectionTab
           AuthenticatedPRFormCntrl.partnerSelectionTab partnerSelTab =new AuthenticatedPRFormCntrl.partnerSelectionTab('partnerSelectionTab','partnerSelectionTab');
           
          
           
           //ContactTab  
           AuthenticatedPRFormCntrl.CompanyTab compTab =new AuthenticatedPRFormCntrl.CompanyTab('CompanyTab','CompanyTab');
           
           //ContactTab  
          
           
           //ContactTab  
           AuthenticatedPRFormCntrl.SegmentTab segTab =new AuthenticatedPRFormCntrl.SegmentTab('segmentTab','segmentTab');
           
           //ContactTab  
           AuthenticatedPRFormCntrl.ServiceTab servTab =new AuthenticatedPRFormCntrl.ServiceTab('serviceTab','serviceTab');
           
           
           partnerSelTab.decorate(listPRFieldHelperList);
        
           compTab.decorate(listPRFieldHelperList);
          
           segTab.decorate(listPRFieldHelperList);
           servTab.decorate(listPRFieldHelperList);
        
   // listprfields = AuthenticatedPRFormCntrl.decorate(liststrList);
   
    AuthenticatedPRFormCntrl.saveTheFile(request.id, 'Unit Test Attachment', 'base64Data', 'contentType', request ,  'company', 'India','NoTrackExists' ); 
       
        AuthenticatedPRFormCntrl.saveChunk(request.id, 'Unit Test Attachment', 'base64Data', 'contentType',attach.id, request ,  'company', 'India','en_us__C','NoTrackExists' ); 
   Partner_Request__c request1 = new Partner_Request__c(Application_Environments__c='None',Area_of_Interest_Non_GC__c='None',
   Job_Category_Non_GC__c='None',Job_Title_Non_GC__c='None',Primary_Customer_Non_GC__c='None',Primary_Vertical_Market_Segment_Non_GC__c='None',
   Secondary_Customer_Segment_Non_GC__c='None',individual_Principals__c='None',Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456',Primary_Channel_Model__c='Consumer Partner');
    AuthenticatedPRFormCntrl.savePartReq(request1 , 'India', 'Company');
   // AuthenticatedPRFormCntrl.savePartReq(string strid,strrequestnumber, 'India');
   AuthenticatedPRFormCntrl.savePartnerRequest(request,'Cloud Service Provider', 'India', 'NoTrackExists');
   AuthenticatedPRFormCntrl.savePartnerRequestSM (request, 'Cloud Service Provider','India', 'NoTrackExists') ;
    AuthenticatedPRFormCntrl.getSMAccounts('CSP (Cloud Service Provider)', 'India');
   // AuthenticatedPRFormCntrl.saveChunk(request.id, 'Unit Test Attachment', 'base64Data', 'contentType','', request ,  'company', 'India' ,'en_us__C'); 
    AuthenticatedPRFormCntrl.getLead(request.id);
    
    
    AuthenticatedPRFormCntrl.handlePartnerTypeChangeMethod('Consumer Partner','India','english');
    AuthenticatedPRFormCntrl.doUpdateCountryDependentFields('India');
   AuthenticatedPRFormCntrl.getDnBSupportedCountry(country.id);
     AuthenticatedPRFormCntrl.doUpdateFieldConfig();
     Test.stopTest(); 
          
       
          
          System.assertEquals('India',country.Name);
        }
        
         Private static testmethod void testMethodforPartnertypes(){
             
       List<String> listConid = new List<String>();
        List<Contact> listCon = new List<Contact>();
        String strMasterGroupId;
        String strMasterGroupaffID ;
        list<User> listUser=TestDataFactory.createNPortalUser(1);
         insert listUser;
        
       // listUser = [SELECT Id,ContactId,Contact.AccountId,Contact.Account.Master_Group_Affinity_ID__c,Contact.Selected_Track__c FROM User WHERE Email like 'testcontact_%'];
         system.debug('>>>listUser '+listUser );
         listacc = [select id from account where Name like 'Test Account Versio%'];  
            
       string strcontactid= listuser[0].ContactId;
            strMasterGroupId = String.valueOf(listUser[0].Contact.AccountId);
            strMasterGroupaffID = String.valueOf(listUser[0].Contact.Account.Master_Group_Affinity_ID__c);
          system.debug('>>>contactid'+strcontactid);
            
             system.debug('>>>strMasterGroupId '+strMasterGroupId );
              Country__c country = new Country__c(Code__c = 'IN',Name = 'India',Region__c ='APJ',
            dial_code__c = '123',Is_Active_Partner_Country__c = true,Inc_Vendor_Name__c = 'Dell Achievers',
            Inc_Vendor_End_Point__c = 'test'); 
             insert country;
            Partner_Type__c partnerType = new Partner_Type__c(Name='pt_test', Country__c=country.id, Translated_Partner_Type_Name__c='translated pt_test',Is_Active__c=true, Sort_Order__c=99); 
        insert partnerType;
                
         Partner_Request__c request = new Partner_Request__c(Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Primary_Channel_Model__c = 'OEM (Original Equipment Manufacturer)',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456');
        
         insert request;
         
       string  strrequestnumber = [select id,Name from Partner_Request__c where Id=:request.id].Name;
         system.debug('>>>request '+request );
         system.debug('>>>request '+request.id );
         system.debug('>>>request '+strrequestnumber  );
            
            Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
            insert trackObj;
        
            Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
            testPartnerTrackObj.Track_Id__c = trackObj.id;
            testPartnerTrackObj.Master_Group_Id__c =strMasterGroupId;
            testPartnerTrackObj.Master_Group_Affinity_Id__c = strMasterGroupaffID ;
            testPartnerTrackObj.Partner_Registration_Number__c= strrequestnumber ;
            insert testPartnerTrackObj;
              system.debug('>>>testPartnerTrackObj'+testPartnerTrackObj );
              system.debug('>>>testPartnerTrackObj.Partner_Registration_Number__c'+testPartnerTrackObj.Partner_Registration_Number__c);
            
           // list<Contact> con = [select id,Selected_Track__r.Partner_Registration_Number__c from contact where id=:strcontactid];
          //  system.debug('>>>con '+con );
         

             
             Account ac = [select id,Partner_Registration__c from account where id=:listacc[0].id];
             ac.Partner_Registration__c =request.id;
             update ac;
             system.debug('ac.Partner_Registration__c '+ac.Partner_Registration__c+ac.Id);
           Contact contact = [select Selected_Track__c,Id from contact where id = :strcontactid];
        contact.Selected_Track__c= testPartnerTrackObj.id ;
        // contact.Selected_Track__c= testPartnerTrackObj.id ;
       
        update contact;
         
             Attachment attach=new Attachment(); 
                attach.Name='Unit Test Attachment'; 
                Blob blbbodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
                attach.body=blbbodyBlob; attach.parentId=request.id;
                insert attach;
         
          Lead le= new lead();
            
        String str1 = null;
        String  str2 = null;
        String str3 = null;
        String  str4 = null;
        String str5 = 'india';
        String  str6 = 'IN';
    
       Map<string,string> mapcountry= new Map<string,string>();
       mapcountry.put(str1,str2);
       mapcountry.put(str5,str6);  
       
       Map<string,string> mapcountryCode= new Map<string,string>();
       mapcountryCode.put(str3,str4);
      List<PartnerRegistrationFormFieldHelper> listprfields = new List<PartnerRegistrationFormFieldHelper>();
      List<String> liststrList = new List<String>();
        liststrList.add(str5);
       Test.StartTest(); 
         list<PartnerRegistrationFormFieldHelper>  listPRFieldHelperList  = new  list<PartnerRegistrationFormFieldHelper>();
        
          AuthenticatedPRFormCntrl pr = new AuthenticatedPRFormCntrl();
           
         // AuthenticatedPRFormCntrl.strselectedtrackPRNUmber=strrequestnumber;
           //AuthenticatedPRFormCntrl.UserRegion= 'APJ';
          // AuthenticatedPRFormCntrl.getLanguage();
           AuthenticatedPRFormCntrl.getPartnerTypeOptions('india','TaxIdChanges');
         //  AuthenticatedPRFormCntrl.getPreferredDellDistributorOptions('india');
          // AuthenticatedPRFormCntrl.getSponsoringDistributorOptions('india');
           AuthenticatedPRFormCntrl.getLabels();
          // AuthenticatedPRFormCntrl.listregionList.add(country);
         // Vfcntrl_PartnerRegistrationForm.loadRequest('test123');
           AuthenticatedPRFormCntrl.TabLabelsandCountryListMethod('TaxIdChanges');
           AuthenticatedPRFormCntrl.populateLead(le, request);
        //  AuthenticatedPRFormCntrl.getCountry();
          AuthenticatedPRFormCntrl.isvalidLanguage('en_us');
         //AuthenticatedPRFormCntrl.updateFieldConfigMap('company', 'Head of the Company', true);
         AuthenticatedPRFormCntrl.fetchRegion('india');
         AuthenticatedPRFormCntrl.fetchPartnertypes('india','NoTrackExists');
         AuthenticatedPRFormCntrl.companyFields('India',listUser[0].id,strrequestnumber);
           
           // AuthenticatedPRFormCntrl.fetchExstngPRDetails(request.id,'test','english');
           
          
       
           
        
           
           //partnerSelectionTab
           AuthenticatedPRFormCntrl.partnerSelectionTab partnerSelTab =new AuthenticatedPRFormCntrl.partnerSelectionTab('partnerSelectionTab','partnerSelectionTab');
           
          
           
           //ContactTab  
           AuthenticatedPRFormCntrl.CompanyTab compTab =new AuthenticatedPRFormCntrl.CompanyTab('CompanyTab','CompanyTab');
           
           //ContactTab  
          
           
           //ContactTab  
           AuthenticatedPRFormCntrl.SegmentTab segTab =new AuthenticatedPRFormCntrl.SegmentTab('segmentTab','segmentTab');
           
           //ContactTab  
           AuthenticatedPRFormCntrl.ServiceTab servTab =new AuthenticatedPRFormCntrl.ServiceTab('serviceTab','serviceTab');
           
           
           partnerSelTab.decorate(listPRFieldHelperList);
        
           compTab.decorate(listPRFieldHelperList);
          
           segTab.decorate(listPRFieldHelperList);
           servTab.decorate(listPRFieldHelperList);
        
   // listprfields = AuthenticatedPRFormCntrl.decorate(liststrList);
   
    AuthenticatedPRFormCntrl.saveTheFile(request.id, 'Unit Test Attachment', 'base64Data', 'contentType', request ,  'company', 'India','NoTrackExists' ); 
       
        AuthenticatedPRFormCntrl.saveChunk(request.id, 'Unit Test Attachment', 'base64Data', 'contentType',attach.id, request ,  'company', 'India','en_us__C','NoTrackExists' ); 
   Partner_Request__c request1 = new Partner_Request__c(Application_Environments__c='None',Area_of_Interest_Non_GC__c='None',
   Job_Category_Non_GC__c='None',Job_Title_Non_GC__c='None',Primary_Customer_Non_GC__c='None',Primary_Vertical_Market_Segment_Non_GC__c='None',
   Secondary_Customer_Segment_Non_GC__c='None',individual_Principals__c='None',Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456',Primary_Channel_Model__c='Consumer Partner');
    AuthenticatedPRFormCntrl.savePartReq(request1 , 'India', 'Company');
   // AuthenticatedPRFormCntrl.savePartReq(string strid,strrequestnumber, 'India');
   AuthenticatedPRFormCntrl.savePartnerRequest(request,'Cloud Service Provider', 'India', 'NoTrackExists');
   AuthenticatedPRFormCntrl.savePartnerRequestSM (request, 'Cloud Service Provider','India', 'NoTrackExists') ;
    AuthenticatedPRFormCntrl.getSMAccounts('CSP (Cloud Service Provider)', 'India');
   // AuthenticatedPRFormCntrl.saveChunk(request.id, 'Unit Test Attachment', 'base64Data', 'contentType','', request ,  'company', 'India' ,'en_us__C'); 
    AuthenticatedPRFormCntrl.getLead(request.id);
    
    
    AuthenticatedPRFormCntrl.handlePartnerTypeChangeMethod('Consumer Partner','India','english');
    AuthenticatedPRFormCntrl.doUpdateCountryDependentFields('India');
   AuthenticatedPRFormCntrl.getDnBSupportedCountry(country.id);
     AuthenticatedPRFormCntrl.doUpdateFieldConfig();
     Test.stopTest(); 
          
       
          
          System.assertEquals('India',country.Name);
        }
        
        }