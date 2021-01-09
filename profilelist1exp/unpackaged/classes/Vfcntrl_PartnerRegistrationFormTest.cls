@IsTest
Private class Vfcntrl_PartnerRegistrationFormTest {


            
        Private static testmethod void testgetmethods(){
              Test.startTest();
        
        Country__c country = new Country__c(Code__c = 'IN',Name = 'India',Region__c ='APJ',
            dial_code__c = '123',Is_Active_Partner_Country__c = true,Inc_Vendor_Name__c = 'Dell Achievers',
            Inc_Vendor_End_Point__c = 'test'); 
             insert country;
            Partner_Type__c partnerType = new Partner_Type__c(Name='pt_test', Country__c=country.id, Translated_Partner_Type_Name__c='translated pt_test',Is_Active__c=true, Sort_Order__c=99); 
        insert partnerType;
        Test.stopTest();
          
           
         Partner_Request__c request = new Partner_Request__c(Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456');
        
         insert request;
            
        String str1 = null;
        String  str2 = null;
        String str3 = null;
        String  str4 = null;
        String str5 = 'india';
        String  str6 = 'IN';
    
       Map<string,string> countryMap= new Map<string,string>();
       countryMap.put(str1,str2);
       countryMap.put(str5,str6);  
       
       Map<string,string> countryCodeMap= new Map<string,string>();
       countryCodeMap.put(str3,str4);
      List<PartnerRegistrationFormFieldHelper> prfields = new List<PartnerRegistrationFormFieldHelper>();
      List<String> strList = new List<String>();
        strList.add(str5);
        
          Vfcntrl_PartnerRegistrationForm PR = new Vfcntrl_PartnerRegistrationForm();
           Vfcntrl_PartnerRegistrationForm.countryList.add(country);
           Vfcntrl_PartnerRegistrationForm.countryMap = countryMap;
           Vfcntrl_PartnerRegistrationForm.countryCodeMap= countryCodeMap;
           Vfcntrl_PartnerRegistrationForm.UserRegion= 'APJ';
           Vfcntrl_PartnerRegistrationForm.getLanguage();
           Vfcntrl_PartnerRegistrationForm.getPartnerTypeOptions('india',true);
           Vfcntrl_PartnerRegistrationForm.getPreferredDellDistributorOptions('india');
           Vfcntrl_PartnerRegistrationForm.getSponsoringDistributorOptions('india');
           Vfcntrl_PartnerRegistrationForm.getLabels();
           Vfcntrl_PartnerRegistrationForm.regionList.add(country);
         // Vfcntrl_PartnerRegistrationForm.loadRequest('test123');
           Vfcntrl_PartnerRegistrationForm.TabLabelsandCountryListMethod();
           Vfcntrl_PartnerRegistrationForm.getcountryList();
          Vfcntrl_PartnerRegistrationForm.getCountry();
          Vfcntrl_PartnerRegistrationForm.isvalidLanguage('en_us');
         // Vfcntrl_PartnerRegistrationForm.updateFieldConfigMap('company', 'Head of the Company', true);
         Vfcntrl_PartnerRegistrationForm.fetchRegion('india');
         Vfcntrl_PartnerRegistrationForm.fetchPartnertypes('india',true);
           
            Vfcntrl_PartnerRegistrationForm.fetchExstngPRDetails(request.id,'test','english');
           
          
             
         //inner class 
           Vfcntrl_PartnerRegistrationForm.exstngPRDetailsWrapper innerInst = new Vfcntrl_PartnerRegistrationForm.exstngPRDetailsWrapper();
           list<PartnerRegistrationFormTabHelper> PRList  = new  list<PartnerRegistrationFormTabHelper>();
            PartnerRegistrationFormTabHelper PRCls = new PartnerRegistrationFormTabHelper('test1', 'test2');
            list<PartnerRegistrationFormFieldHelper>  PRFieldHelperList  = new  list<PartnerRegistrationFormFieldHelper>();
           innerInst.tabs = new list<PartnerRegistrationFormTabHelper>();
           innerInst.tabs.add(PRCls);
           innerInst.accessDenied = true;
           PRList.add(PRCls);
           
        
           
           //partnerSelectionTab
           Vfcntrl_PartnerRegistrationForm.partnerSelectionTab PartnerSelTab =new Vfcntrl_PartnerRegistrationForm.partnerSelectionTab('partnerSelectionTab','partnerSelectionTab');
           
           //ContactTab  
           Vfcntrl_PartnerRegistrationForm.ContactTab  conTab =new Vfcntrl_PartnerRegistrationForm.ContactTab('contactTab','contactTab');
           
           //ContactTab  
           Vfcntrl_PartnerRegistrationForm.CompanyTab compTab =new Vfcntrl_PartnerRegistrationForm.CompanyTab('CompanyTab','CompanyTab');
           
           //ContactTab  
           Vfcntrl_PartnerRegistrationForm.FocusTab focTab =new Vfcntrl_PartnerRegistrationForm.FocusTab('focusTab','focusTab');
           
           //ContactTab  
           Vfcntrl_PartnerRegistrationForm.SegmentTab segTab =new Vfcntrl_PartnerRegistrationForm.SegmentTab('segmentTab','segmentTab');
           
           //ContactTab  
           Vfcntrl_PartnerRegistrationForm.ServiceTab servTab =new Vfcntrl_PartnerRegistrationForm.ServiceTab('serviceTab','serviceTab');
           
           
           PartnerSelTab.decorate(PRFieldHelperList);
           conTab.decorate(PRFieldHelperList);
           compTab.decorate(PRFieldHelperList);
           focTab.decorate(PRFieldHelperList);
           segTab.decorate(PRFieldHelperList);
           servTab.decorate(PRFieldHelperList);
        
    //  prfields = Vfcntrl_PartnerRegistrationForm.decorate(strList);
          
           
          
          
        }
        
    
      public static testmethod void testLoadRequest(){
      Country__c country = new Country__c(Code__c = 'IN',Name = 'India',Region__c ='APJ',
            dial_code__c = '123',Is_Active_Partner_Country__c = true,Inc_Vendor_Name__c = 'Dell Achievers',
            Inc_Vendor_End_Point__c = 'test'); 
            
      Partner_Request__c request = new Partner_Request__c(Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456');
      insert request;
      
          Vfcntrl_PartnerRegistrationForm PR = new Vfcntrl_PartnerRegistrationForm();
       //  Vfcntrl_PartnerRegistrationForm.loadRequest(request.id);
      }
     Private static Country__c createCountry() {
        Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.dial_code__c = '123';
        country.Is_Active_Partner_Country__c = true;
        country.Inc_Vendor_Name__c = 'Dell Achievers';
        country.Inc_Vendor_End_Point__c = 'test';
        List<QueueSobject> queues = [select QueueId from QueueSobject where SobjectType = 'Partner_Request__c' limit 1];
        if(queues.size()>0){
            country.Partner_Support_Queue_ID__c = queues.get(0).QueueId;
        }
        country.Partner_Support_Email__c = 'test@test.com';
        return country;
    }
    
    public static testmethod void testUploadAttachment(){
    
    Map<String,String> cm= new Map<String,String>();
    cm.put(null,null);

    Vfcntrl_PartnerRegistrationForm.countryMap  = cm;
    
             TriggerExecutionController.setSkipUserTriggers(True);
         
        Country__c country = new Country__c(Code__c = 'IN',Name = 'India',Region__c ='APJ',
            dial_code__c = '123',Is_Active_Partner_Country__c = true,Inc_Vendor_Name__c = 'Dell Achievers',
            Inc_Vendor_End_Point__c = 'test'); 
             insert country;
            Partner_Type__c partnerType = new Partner_Type__c(Name='pt_test', Country__c=country.id, Translated_Partner_Type_Name__c='translated pt_test',Is_Active__c=true, Sort_Order__c=99); 
        insert partnerType;
        
          
           
         Partner_Request__c request = new Partner_Request__c(Email__c='s@test.com',Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456',Primary_Channel_Model__c='Consumer Partner');
        
         insert request;
          
        
             User usr = [Select id from User where Id = :UserInfo.getUserId()];
             
             System.RunAs(usr)

     {

        Test.startTest();

      
             
          Attachment attach=new Attachment(); 
                attach.Name='Unit Test Attachment'; 
                Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
                attach.body=bodyBlob; attach.parentId=request.id;
                insert attach;
                
           Lead le= new lead();
           
            Account account = new Account(Name='pt_test', Account_Country_Code__c=country.code__c);
        insert account;
        account.IsPartner=true;
        update account;
        
        Contact contact = new Contact(FirstName='pt_FirstName',LastName='pt_LastName', Email = request.Email__c , AccountId=account.id);
        insert contact;
           
        /*   List<Profile> partnerProfiles = [select id,name from Profile where Name LIKE '%PRM Portal%' order by createddate desc  limit 1];
        List<UserRole> partnerRoles = [select id,name from UserRole where Name LIKE '%Partner User%' limit 1];
       
            User user = new User(
                Username= generateRandomBlob() +'@pttest.com',
                Alias = 'test1',
                Email= request.Email__c,
                FirstName='John',
                LastName='Doe1',
                ProfileId = partnerProfiles[0].Id,
                Partner_Domain_Name__c = 'test.com',
                
                UserRoleId = partnerRoles[0].Id,
                
             //   AccountId = account.id,
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8',
                TimeZoneSidKey='America/Los_Angeles',
                Badge_Number__c=null,
              ContactId = contact.id,
              IsActive = TRUE,
                Enable_Partner_Admin__c = true
                
            );
           list<user> partnerAdminList = new list<user>();
           partnerAdminList.add(user);
            insert user;
            */
     Test.stopTest();
       
           
        
       
         Vfcntrl_PartnerRegistrationForm.saveTheFile(request.id, 'Unit Test Attachment', 'base64Data', 'contentType', request ,  'company', 'India' ); 
        Vfcntrl_PartnerRegistrationForm.saveChunk(request.id, 'Unit Test Attachment', 'base64Data', 'contentType',attach.id, request ,  'company', 'India','en_us__C' ); 
   Partner_Request__c request1 = new Partner_Request__c(Application_Environments__c='None',Area_of_Interest_Non_GC__c='None',
   Job_Category_Non_GC__c='None',Job_Title_Non_GC__c='None',Primary_Customer_Non_GC__c='None',Primary_Vertical_Market_Segment_Non_GC__c='None',
   Secondary_Customer_Segment_Non_GC__c='None',individual_Principals__c='None',Address_Line_1__c='addLine1',Address_Line_2__c='addLine2',Address_Line_3__c='addLine3',City__c='city',State__c='state',Postal_Code__c='12345',Country__c=country.id,Phone__c='123',Fax__c='456',Primary_Channel_Model__c='Consumer Partner');
    Vfcntrl_PartnerRegistrationForm.savePartReq(request1 , 'India', 'Company');
    Vfcntrl_PartnerRegistrationForm.prepareComResponseWrapper('India','pt_test');
    Vfcntrl_PartnerRegistrationForm.saveChunk(request.id, 'Unit Test Attachment', 'base64Data', 'contentType','', request ,  'company', 'India' ,'en_us__C'); 
    Vfcntrl_PartnerRegistrationForm.getLead(request.id);
    
    Vfcntrl_PartnerRegistrationForm.populateLead(le, request);
    Vfcntrl_PartnerRegistrationForm.populateLead(null, request);
    Vfcntrl_PartnerRegistrationForm.handlePartnerTypeChangeMethod('Consumer Partner','India','english');
    //Vfcntrl_PartnerRegistrationForm.doUpdateCountryDependentFields('english');
   // Vfcntrl_PartnerRegistrationForm.doSendEmail(request, 'india', 'matchAccId','userDomain', 'comments' );
     Vfcntrl_PartnerRegistrationForm.doUpdateFieldConfig();
     Vfcntrl_PartnerRegistrationForm.getDependentOptionsImpl('PartnerRequest','Job_Category','Job_Title','Job_Category');
    
     Vfcntrl_PartnerRegistrationForm.savePartReq1 (request1, 'Service', 'India');
   }
    }
    
     private static Blob generateRandomBlob(){
        return EncodingUtil.base64Decode(''+System.currentTimeMillis()+Math.roundToLong(Math.random()*10000));  
    }

}