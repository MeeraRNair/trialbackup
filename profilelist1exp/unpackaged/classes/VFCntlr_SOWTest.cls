@isTest
private class VFCntlr_SOWTest{ 
    static  MDF_Program__c mdfProgram=new MDF_Program__c();    
    static Vendor__c parentVendor=new Vendor__c();
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c(); 
    static Rebate_Rule_Header__c RRHobj=new Rebate_Rule_Header__c();
    static List<Rebate_Rule_Line_Item__c> RRLIObjList=new List<Rebate_Rule_Line_Item__c>();
    static Rebate_Rule_Line_Item__c RRLIObj=new Rebate_Rule_Line_Item__c();
    static Rebate_Rule_Line_Item__c RRLIObj1=new Rebate_Rule_Line_Item__c();
    static Rebate_Rule_Line_Item__c RRLIObj2=new Rebate_Rule_Line_Item__c();
       
    static List<User> users = new List<User>();
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
    static Package__c packageObj=new Package__c(); 
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static Marketing_Plan__c mPlanCogs=new Marketing_Plan__c(); 
    static Marketing_Plan__c mPlanNCogs=new Marketing_Plan__c(); 
    static Marketing_Plan__c mPlanRebates=new Marketing_Plan__c(); 
    static Marketing_Plan__c mPlanHCount=new Marketing_Plan__c(); 
    static Marketing_Plan__c mPlanDefault=new Marketing_Plan__c();
    
    static Marketing_Plan__c mPlanHeadCountIngramMicro1 = new Marketing_Plan__c();
    static Marketing_Plan__c mPlanHeadCountIngramMicro2 = new Marketing_Plan__c();
    static Marketing_Plan__c mPlanHeadCountIngramMicro3 = new Marketing_Plan__c();
    static Marketing_Plan__c mPlanHeadCountIngramMicro4 = new Marketing_Plan__c();            
    Static List<Marketing_Plan__c> mPlanHeadCountList = new List<Marketing_Plan__c>(); 
    static Invoice__c invoiceObj=new Invoice__c(); 
    static Profile profiles;
    static List<MDF_Program__c> mdfList=new List<MDF_Program__c>();    
    static Marketing_Plan__c MarketingPlanRec=new Marketing_Plan__c();

    static MDF_Contact__c mdfContact = new MDF_Contact__c();
    static MDF_Associated_Contact__c mdfAssocContact = new MDF_Associated_Contact__c();
    
    static MDF_Contact__c mdfContact2 = new MDF_Contact__c();
    static MDF_Associated_Contact__c mdfAssocContact2 = new MDF_Associated_Contact__c();
     
     public static void createData(){ 
       Map<String,RecordType> recTypeMap=new Map<String,RecordType>();
       RecordType marketingPlanRT=new RecordType();
       profiles=[select id,name from Profile where name like '%MDF Program Owners%' limit 1];  
       //Query for Record Type
       List<RecordType> recordType = [select Id,name,SobjectType  from RecordType];
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();   
       Map<String,RecordType> RRLIRT =new Map<String,RecordType>();
       RecordType mdfContactRT=new RecordType();
       RecordType rt1 = new RecordType();
       RecordType rt2 = new RecordType();
       RecordType apvRT;
       
        TriggerExecutionController.setSkipAllTriggers(true);
       for(RecordType recType : recordType){       
            if(recType.SobjectType=='Marketing_Plan__c'){
                recTypeMap.put(recType.name,recType);   
                if(recType.name=='Volume Based Marketing Plan'){
                    marketingPlanRT=recType;
                }             
            } 
            if(recType.sObjectType=='Marketing_Plan__c' && recType.name=='Volume Based Marketing Plan'){
                marketingPlanRT = recType;
            }
            if(recType.sObjectType=='Associated_Programs_Vendors__c' && recType.name=='Vendor Association MP'){
                apvRT= recType;
            }

            if(recType.SobjectType=='Rebate_Rule_Line_Item__c'){
               RRLIRT.put(recType.Name,recType);                           
            }                                        

            if(recType.sObjectType=='MDF_Contact__c' && recType.name=='Product Manager Contact'){
                mdfContactRT = recType;
            }
                if(recType.sObjectType=='vendor__c'){
                   vendorRT.put(recType.Name,recType);
                }  
           }
           
           Vendor__c subVendor=new Vendor__c();
           parentVendor.name='TestVendor1';
           parentVendor.Partner_Status__c='Active';
           if(vendorRT.get('Vendor') != null){
               parentVendor.recordTypeId=vendorRT.get('Vendor').Id;
           }
           insert parentVendor;      
           
           
           for(Integer i = 0; i<4; i++){           
             subVendor= new Vendor__c(
                   Parent_Vendor__c=parentVendor.Id,
                   Name='TestSubVendorRec'+i,
                   Partner_Status__c='Active',
                   Partner_Type__c='Value',
                   Product_Category__c='Networking',
                   Contract_Types_eligible_for__c='Volume Based,Ala Carte',
                   recordTypeId=vendorRT.get('Sub Vendor').Id  
               );
               if(i==0){
                    subVendor.Ala_Carte_SOW_Template__c='OEM';
                    subVendor.Headcount_SOW_Template__c='Default';
                    subVendor.Rebates_SOW_Template__c='Default';
                    subVendor.Volume_Based_SOW_Template__c='OEM';
               }  
               if(i==1){
                    subVendor.Ala_Carte_SOW_Template__c='OEM';
                    subVendor.Headcount_SOW_Template__c='OEM';
                    subVendor.Rebates_SOW_Template__c='Default';
                    subVendor.Volume_Based_SOW_Template__c='OEM';
               }  
               if(i==2){
                    subVendor.Ala_Carte_SOW_Template__c='OEM';
                    subVendor.Headcount_SOW_Template__c='Default';
                    subVendor.Rebates_SOW_Template__c='OEM';
                    subVendor.Volume_Based_SOW_Template__c='OEM';
               }  
               if(i==3){
                    subVendor.Ala_Carte_SOW_Template__c='OEM';
                    subVendor.Headcount_SOW_Template__c='Default';
                    subVendor.Rebates_SOW_Template__c='OEM';
                    subVendor.Volume_Based_SOW_Template__c='Default';
               }    
                   vendorList.add(subVendor);
           }
           
           insert vendorList;
           
           
           
           mPlanCogs.name='MP-001';
           mPlanCogs.Vendor__c=vendorList[0].Id;
           mPlanCogs.Fiscal_Quarter__c='FY12Q2';
           mPlanCogs.Region__c='Americas';
           mPlanCogs.Contract_Type__c='Volume Based';
           mPlanCogs.RecordTypeId=recTypeMap.get('Volume Based Marketing Plan').Id; 
           //CR 7330
           mPlanCogs.Primary_Marketing_Contact_City__c='Chennai';
           mPlanCogs.Primary_Marketing_Contact_State__c='TN';
           mPlanCogs.Primary_Marketing_Contact_Zip__c='600015';
           mPlanCogs.Primary_Marketing_Contact_Country__c='India';
           mPlanCogs.Billing_City__c='Trivandrum';
           mPlanCogs.Billing_State__c='Kerala';
           mPlanCogs.Billing_Zip__c='695011';
           mPlanCogs.Billing_Contact_Country__c='India';
           
           mPlanHeadCountList.add(mPlanCogs);
           mPlanNCogs.name='MP-001';
           mPlanNCogs.Vendor__c=vendorList[1].Id;
           mPlanNCogs.Fiscal_Quarter__c='FY12Q1';
           mPlanNCogs.Region__c='Americas';
           mPlanNCogs.Contract_Type__c='Ala Carte';
           mPlanNCogs.RecordTypeId=recTypeMap.get('Ala Carte Marketing Plan').Id; 
           //CR 7330
           mPlanNCogs.Primary_Marketing_Contact_City__c='Chennai';
           mPlanNCogs.Primary_Marketing_Contact_State__c='TN';
           mPlanNCogs.Primary_Marketing_Contact_Zip__c='600015';
           mPlanNCogs.Primary_Marketing_Contact_Country__c='India';
           mPlanNCogs.Billing_City__c='Trivandrum';
           mPlanNCogs.Billing_State__c='Kerala';
           mPlanNCogs.Billing_Zip__c='695011';
           mPlanNCogs.Billing_Contact_Country__c='India';
           
           mPlanHeadCountList.add(mPlanNCogs);
           RRHobj.Name='Test RRH Rec';
           RRHobj.Vendor__c=vendorList[2].Id;
           RRHobj.Fiscal_Quarter__c='FY12Q1';
           RRHobj.Region__c='Americas';
           insert RRHobj;
           
    
           RRLIobj.RecordTypeId = RRLIRT.get('Flat Rate').Id;       
           RRLIobj.Rebate_Rule_Header__c= RRHobj.id; 
           RRLIobj.Effective_Date_From__c =date.newInstance(2011,2,18); 
           RRLIobj.Effective_Date_To__c =date.newInstance(2011,2,22);
           RRLIobj.Business_Segment__c ='PUB';  
           Insert RRLIobj;
           
           RRLIobj1.RecordTypeId = RRLIRT.get('SKU Based').Id;       
           RRLIobj1.Rebate_Rule_Header__c= RRHobj.id; 
           RRLIobj1.Effective_Date_From__c =date.newInstance(2011,2,18); 
           RRLIobj1.Effective_Date_To__c =date.newInstance(2011,2,22);
           RRLIobj1.Business_Segment__c ='PUB';  
           Insert RRLIobj1;       
    
           RRLIobj2.RecordTypeId = RRLIRT.get('Class / Sub Class').Id;       
           RRLIobj2.Rebate_Rule_Header__c= RRHobj.id; 
           RRLIobj2.Effective_Date_From__c =date.newInstance(2011,2,18); 
           RRLIobj2.Effective_Date_To__c =date.newInstance(2011,2,22);
           RRLIobj2.Business_Segment__c ='PUB';  
           Insert RRLIobj2; 
                  
           mPlanRebates.name='MP-001';
           mPlanRebates.Vendor__c=vendorList[2].Id;
           mPlanRebates.Fiscal_Quarter__c='FY12Q1';
           mPlanRebates.Region__c='Americas';
           mPlanRebates.Contract_Type__c='Rebates';
           mPlanRebates.Rebate_Rule_Header__c= RRHobj.Id;
           mPlanRebates.RecordTypeId=recTypeMap.get('Rebates Marketing Plan').Id; 
           //CR 7330
           mPlanRebates.Primary_Marketing_Contact_City__c='Chennai';
           mPlanRebates.Primary_Marketing_Contact_State__c='TN';
           mPlanRebates.Primary_Marketing_Contact_Zip__c='600015';
           mPlanRebates.Primary_Marketing_Contact_Country__c='India';
           mPlanRebates.Billing_City__c='Trivandrum';
           mPlanRebates.Billing_State__c='Kerala';
           mPlanRebates.Billing_Zip__c='695011';
           mPlanRebates.Billing_Contact_Country__c='India';
           
           mPlanHeadCountList.add(mPlanRebates);
           mPlanHCount.name='MP-001';
           mPlanHCount.Term__c='1';
           mPlanHCount.Vendor__c=vendorList[3].Id;
           mPlanHCount.Fiscal_Quarter__c='FY12Q1';
           mPlanHCount.Region__c='Americas';
           mPlanHCount.Contract_Type__c='Headcount';
           mPlanHCount.RecordTypeId=recTypeMap.get('Headcount Marketing Plan').Id; 
           //CR 7330
           mPlanHCount.Primary_Marketing_Contact_City__c='Chennai';
           mPlanHCount.Primary_Marketing_Contact_State__c='TN';
           mPlanHCount.Primary_Marketing_Contact_Zip__c='600015';
           mPlanHCount.Primary_Marketing_Contact_Country__c='India';
           mPlanHCount.Billing_City__c='Trivandrum';
           mPlanHCount.Billing_State__c='Kerala';
           mPlanHCount.Billing_Zip__c='695011';
           mPlanHCount.Billing_Contact_Country__c='India';
           
           mPlanHeadCountList.add(mPlanHCount);
           
           mPlanDefault.name='MP-001';
           mPlanDefault.Vendor__c=vendorList[3].Id;
           mPlanDefault.Fiscal_Quarter__c='FY12Q1';
           mPlanDefault.Region__c='Americas';
           mPlanDefault.Contract_Type__c='Volume Based';
           mPlanDefault.RecordTypeId=recTypeMap.get('Volume Based Marketing Plan').Id; 
           
           mPlanHeadCountList.add(mPlanDefault);
           
           mPlanHeadCountIngramMicro1.name='MP-001';
           mPlanHeadCountIngramMicro1.Vendor__c=vendorList[3].Id;
           mPlanHeadCountIngramMicro1.Fiscal_Quarter__c='FY12Q2';
           mPlanHeadCountIngramMicro1.Region__c='APJ';
           mPlanHeadCountIngramMicro1.Contract_Type__c='Volume Based';
           mPlanHeadCountIngramMicro1.Term__c='1';
           mPlanHeadCountIngramMicro1.RecordTypeId=recTypeMap.get('Volume Based Marketing Plan').Id; 
           
           mPlanHeadCountList.add(mPlanHeadCountIngramMicro1);
           
           mPlanHeadCountIngramMicro2.name='MP-001';
           mPlanHeadCountIngramMicro2.Vendor__c=vendorList[3].Id;
           mPlanHeadCountIngramMicro2.Fiscal_Quarter__c='FY12Q1';
           mPlanHeadCountIngramMicro2.Region__c='APJ';
           mPlanHeadCountIngramMicro2.Contract_Type__c='Volume Based';
           mPlanHeadCountIngramMicro2.Term__c='2';
           mPlanHeadCountIngramMicro2.RecordTypeId=recTypeMap.get('Volume Based Marketing Plan').Id; 
           
           mPlanHeadCountList.add(mPlanHeadCountIngramMicro2);    
    
           mPlanHeadCountIngramMicro3.name='MP-001';
           mPlanHeadCountIngramMicro3.Vendor__c=vendorList[3].Id;
           mPlanHeadCountIngramMicro3.Fiscal_Quarter__c='FY12Q1';
           mPlanHeadCountIngramMicro3.Region__c='EMEA';
           mPlanHeadCountIngramMicro3.Contract_Type__c='Volume Based';
           mPlanHeadCountIngramMicro3.Term__c='3';
           mPlanHeadCountIngramMicro3.RecordTypeId=recTypeMap.get('Volume Based Marketing Plan').Id; 
           
           mPlanHeadCountList.add(mPlanHeadCountIngramMicro3);
           
           
           mPlanHeadCountIngramMicro4.name='MP-001';
           mPlanHeadCountIngramMicro4.Vendor__c=vendorList[3].Id;
           mPlanHeadCountIngramMicro4.Fiscal_Quarter__c='FY12Q3';
           mPlanHeadCountIngramMicro4.Region__c='APJ';
           mPlanHeadCountIngramMicro4.Contract_Type__c='Volume Based';
           mPlanHeadCountIngramMicro4.Term__c='4';
           mPlanHeadCountIngramMicro4.RecordTypeId=recTypeMap.get('Volume Based Marketing Plan').Id; 
           
           mPlanHeadCountList.add(mPlanHeadCountIngramMicro4);
           insert mPlanHeadCountList;
           
           packageObj.Marketing_Plan__c=mPlanCogs.Id;
           packageObj.Status__c='Pending';
           packageObj.name='TestPkg';       
           insert packageObj;
            
            for(Integer i = 0; i<3; i++){           
                users.add(
                    new User(
                        Username='testuser'+i+ System.currentTimeMillis()+'@dell.com',
                        Alias = 'test'+i, 
                        Email='testuser'+i+'@dell.com', 
                        FirstName='John', 
                        LastName='Doe'+i, 
                        ProfileId =profiles.Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='John.doe'+i
                   )
                );
            }
            insert users;
           
            MDF_Program__c mdfObj;
            for(integer i=0;i<6;i++){
                mdfObj=new MDF_Program__c();
                mdfObj.Name='testMDF Program'+i;
                mdfObj.Program_Owner__c=users[0].id;
                mdfObj.POP_Owner__c=users[1].id;
                mdfObj.Program_Status__c='Pending';
                mdfObj.Pricing_Type__c='Variable';
                mdfObj.Fiscal_Quarter__c='FY12Q2';
                mdfObj.OwnerId=users[2].id;
                mdfObj.Rate_Card_Price__c=12356;
                mdfObj.Region__c='APJ'; 
                mdfObj.Business_Segment__c='CSMR';            
                if(i==4){
                    mdfObj.Business_Segment__c='LE';
                }
                mdfList.add(mdfObj);
            }
            insert mdfList; 
            
            for(Integer i = 0; i<6; i++){
                if(i==0){
                    apvList.add(
                       new Associated_Programs_Vendors__c(
                           Status__c='Accepted',
                           MDF_Program__c=mdfList[i].Id,
                           Package__c=packageObj.Id,
                           Vendor__c=vendorList[0].Id,
                           Marketing_Plan__c=mPlanHeadCountList[0].Id,
                           recordTypeId=apvRT.Id,
                           //recordTypeId=marketingPlanRT.Id,
                           Rate_Card_Price__c=mdfList[i].Rate_Card_Price__c,
                           Budgeted_Price__c=mdfList[i].Rate_Card_Price__c,
                           Employee_Cost_Center__c = '1234-5678-901230'
                       )
                   );
                }
                if(i==1){
                    apvList.add(
                       new Associated_Programs_Vendors__c(
                           Status__c='Accepted',
                           MDF_Program__c=mdfList[i].Id,
                           Package__c=packageObj.Id,
                           Vendor__c=vendorList[1].Id,
                           Marketing_Plan__c=mPlanHeadCountList[1].Id,
                           recordTypeId=apvRT.Id,
                           //recordTypeId=marketingPlanRT.Id,
                           Rate_Card_Price__c=mdfList[i].Rate_Card_Price__c,
                           Budgeted_Price__c=mdfList[i].Rate_Card_Price__c,
                           Employee_Cost_Center__c = '1234-5678-901231'
                       )
                   );
                }
                if(i==2){
                    apvList.add(
                       new Associated_Programs_Vendors__c(
                           Status__c='Accepted',
                           MDF_Program__c=mdfList[i].Id,
                           Package__c=packageObj.Id,
                           Vendor__c=vendorList[2].Id,
                           Marketing_Plan__c=mPlanHeadCountList[2].Id,
                           recordTypeId=apvRT.Id,
                           //recordTypeId=marketingPlanRT.Id,
                           Rate_Card_Price__c=mdfList[i].Rate_Card_Price__c,
                           Budgeted_Price__c=mdfList[i].Rate_Card_Price__c,
                           Employee_Cost_Center__c = '1234-5678-901232'
                       )
                   );
                }
                if(i==3){
                    apvList.add(
                       new Associated_Programs_Vendors__c(
                           Status__c='Accepted',
                           MDF_Program__c=mdfList[i].Id,
                           Package__c=packageObj.Id,
                           Vendor__c=vendorList[3].Id,
                           Marketing_Plan__c=mPlanHeadCountList[3].Id,
                           recordTypeId=apvRT.Id,
                           //recordTypeId=marketingPlanRT.Id,
                           Rate_Card_Price__c=mdfList[i].Rate_Card_Price__c,
                           Budgeted_Price__c=mdfList[i].Rate_Card_Price__c,
                           Employee_Cost_Center__c = '1234-5678-901233'
                       )
                   );
                }
                
                if(i==4){
                    apvList.add(
                       new Associated_Programs_Vendors__c(
                           Status__c='Accepted',
                           MDF_Program__c=mdfList[i].Id,
                           Package__c=packageObj.Id,
                           Vendor__c=vendorList[1].Id,
                           Marketing_Plan__c=mPlanHeadCountList[1].Id,
                           recordTypeId=apvRT.Id,
                           //recordTypeId=marketingPlanRT.Id,
                           Rate_Card_Price__c=mdfList[i].Rate_Card_Price__c,
                           Budgeted_Price__c=mdfList[i].Rate_Card_Price__c,
                           Employee_Cost_Center__c = '1234-5678-901234'
                       )
                   );
                }
                if(i==5){
                    apvList.add(
                       new Associated_Programs_Vendors__c(
                           Status__c='Accepted',
                           MDF_Program__c=mdfList[i].Id,
                           //Package__c=packageObj.Id,
                           Vendor__c=vendorList[0].Id,
                           Marketing_Plan__c=mPlanHeadCountList[0].Id,
                           recordTypeId=apvRT.Id,
                           //recordTypeId=marketingPlanRT.Id,
                           Rate_Card_Price__c=mdfList[i].Rate_Card_Price__c,
                           Budgeted_Price__c=mdfList[i].Rate_Card_Price__c,
                           Employee_Cost_Center__c = '1234-5678-901235'
                       )
                   );
                }
               
           }
           insert apvList;
    
            mdfContact.Name = 'Mr Tam';
            mdfContact.Status__c = 'Active';
            mdfContact.Region__c = 'GBL';
            mdfContact.recordTypeId = mdfContactRT.Id ;
            mdfContact.Primary_Secondary__c = 'Primary';       
            
            insert mdfContact;    
           
            mdfAssocContact.Vendor__c =vendorList[3].Id;
            mdfAssocContact.mdf_Contact__c=mdfContact.Id;
           
            insert mdfAssocContact;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
     }
     public static testMethod void testVFCntlr_selectSOW(){
        createData();       
        PageReference pageRef = Page.selectSOWTemplate;
        Test.setCurrentPage(pageRef);
        Test.startTest();  
        VFCntlr_selectSOW controller1 = new VFCntlr_selectSOW(new ApexPages.StandardController(mPlanHeadCountList[0]));
        PageReference selectedSOW1=controller1.selectSOWTemplates();
        VFCntlr_selectSOW controller2 = new VFCntlr_selectSOW(new ApexPages.StandardController(mPlanHeadCountList[1]));
        PageReference selectedSOW2=controller2.selectSOWTemplates();
        VFCntlr_selectSOW controller3 = new VFCntlr_selectSOW(new ApexPages.StandardController(mPlanHeadCountList[2]));
        PageReference selectedSOW3=controller3.selectSOWTemplates();
        VFCntlr_selectSOW controller4 = new VFCntlr_selectSOW(new ApexPages.StandardController(mPlanHeadCountList[3]));
        PageReference selectedSOW4=controller4.selectSOWTemplates();
                          
        Test.stopTest(); 
     }
    //COGS SOW Test 
     public static testMethod void testVFCntlr_COGSSOW(){
        createData();       
        PageReference pageRef = Page.SOWCogs;
        Test.setCurrentPage(pageRef);
        Test.startTest();  
        VFCntlr_COGSSOW controller = new VFCntlr_COGSSOW(new ApexPages.StandardController(mPlanHeadCountList[0]));
       
        Test.stopTest(); 
     }
     

//NonCOGS SOW Test

     public static testMethod void testVFCntlr_SOWNonCogs(){
        createData();       
        PageReference pageRef = Page.SOWNonCogs;
        Test.setCurrentPage(pageRef);
        Test.startTest();  
        VFCntrlr_NonCogsSOW controller = new VFCntrlr_NonCogsSOW(new ApexPages.StandardController(mPlanHeadCountList[1]));
       
        Test.stopTest();  
     }
     
     
//Headcount SOW Test
     public static testMethod void testVFCntlr_HeadCountSOW(){
        createData();       
        PageReference pageRef = Page.SOWHeadCount;
        Test.setCurrentPage(pageRef);
        Test.startTest();  
        VFCntlr_HeadCountSOW controller = new VFCntlr_HeadCountSOW(new ApexPages.StandardController(mPlanHeadCountList[3]));
      
        Test.stopTest();  
     } 
//VFCntlr_SOWHeadCountValidation test
 public static testMethod void testVFCntlr_SOWHeadCountValidation1(){
        createData();    
        Test.startTest();  
        ApexPages.currentPage().getParameters().put('id', mPlanHeadCountList[3].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(mPlanHeadCountList[3]); 
        MDF_Program__c mdfObj;
            
                mdfObj=new MDF_Program__c();
                mdfObj.Name='testMDF Program';
                mdfObj.Program_Owner__c=users[0].id;
                mdfObj.POP_Owner__c=users[1].id;
                mdfObj.Program_Status__c='Pending';
                mdfObj.Pricing_Type__c='Variable';
                mdfObj.Fiscal_Quarter__c='FY12Q1';
                mdfObj.OwnerId=users[2].id;
                mdfObj.Rate_Card_Price__c=12356;
                mdfObj.Region__c='APJ'; 
                mdfObj.Business_Segment__c='CSMR';            
                mdfObj.Business_Segment__c='LE';
                
            insert mdfObj; 
            
        
        Associated_Programs_Vendors__c ass = new Associated_Programs_Vendors__c();
       
        ass.vendor__c = mPlanHeadCountList[3].vendor__c;
        ass.Marketing_Plan__c = mPlanHeadCountList[3].Id;
        ass.status__c = 'Accepted';
        ass.MDF_Program__c=mdfObj.Id;
        ass.Employee_Cost_Center__c = '1234-5678-901236';
        insert ass; 
        
        VFCntlr_SOWHeadCountValidation controller = new VFCntlr_SOWHeadCountValidation(sc);
        controller.redirectToSowHeadCount();
        
        VFCntlr_SOWHeadCountValidation controller1 = new VFCntlr_SOWHeadCountValidation(sc);
        
        MDF_Program__c mdfObj1;
            
                mdfObj1=new MDF_Program__c();
                mdfObj1.Name='testMDF Program';
                mdfObj1.Program_Owner__c=users[0].id;
                mdfObj1.POP_Owner__c=users[1].id;
                mdfObj1.Program_Status__c='Pending';
                mdfObj1.Pricing_Type__c='Variable';
                mdfObj1.Fiscal_Quarter__c='FY12Q2';
                mdfObj1.OwnerId=users[2].id;
                mdfObj1.Rate_Card_Price__c=12356;
                mdfObj1.Region__c='APJ'; 
                mdfObj1.Business_Segment__c='CSMR';            
                mdfObj1.Business_Segment__c='LE';
                
            insert mdfObj1;
        Associated_Programs_Vendors__c ass1 = new Associated_Programs_Vendors__c();
        ass1.vendor__c = mPlanHeadCountList[3].vendor__c;
        ass1.Marketing_Plan__c = mPlanHeadCountList[3].Id;
        ass1.status__c = 'Accepted';
        ass1.MDF_Program__c=mdfObj1.Id;
        ass1.Employee_Cost_Center__c = '1234-5678-901237';
        insert ass1; 
        
        controller1.redirectToSowHeadCount();  
        Test.stopTest();  
     } 
     public static testMethod void testVFCntlr_SOWHeadCountValidation2(){
        createData();       
        Test.startTest();  
        ApexPages.currentPage().getParameters().put('id', mPlanHeadCountList[3].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(mPlanHeadCountList[3]); 
        
        MDF_Program__c mdfObj;
            
                mdfObj=new MDF_Program__c();
                mdfObj.Name='testMDF Program';
                mdfObj.Program_Owner__c=users[0].id;
                mdfObj.POP_Owner__c=users[1].id;
                mdfObj.Program_Status__c='Pending';
                mdfObj.Pricing_Type__c='Variable';
                mdfObj.Fiscal_Quarter__c='FY12Q1';
                mdfObj.OwnerId=users[2].id;
                mdfObj.Rate_Card_Price__c=12356;
                mdfObj.Region__c='APJ'; 
                mdfObj.Business_Segment__c='CSMR';            
                mdfObj.Business_Segment__c='LE';
                
            insert mdfObj; 
        
        VFCntlr_SOWHeadCountValidation controller = new VFCntlr_SOWHeadCountValidation(sc);
        controller.redirectToSowHeadCount();
        
        VFCntlr_SOWHeadCountValidation controller1 = new VFCntlr_SOWHeadCountValidation(sc);
        
        MDF_Program__c mdfObj1;
            
                mdfObj1=new MDF_Program__c();
                mdfObj1.Name='testMDF Program';
                mdfObj1.Program_Owner__c=users[0].id;
                mdfObj1.POP_Owner__c=users[1].id;
                mdfObj1.Program_Status__c='Pending';
                mdfObj1.Pricing_Type__c='Variable';
                mdfObj1.Fiscal_Quarter__c='FY12Q2';
                mdfObj1.OwnerId=users[2].id;
                mdfObj1.Rate_Card_Price__c=12356;
                mdfObj1.Region__c='APJ'; 
                mdfObj1.Business_Segment__c='CSMR';            
                mdfObj1.Business_Segment__c='LE';
                
            insert mdfObj1;
           
        controller1.redirectToSowHeadCount();  
        Test.stopTest();  
     } 
             
//Rebates SOW Test   
     public static testMethod void testVFCntlr_RebatesSOW(){
        createData();       
        PageReference pageRef = Page.SOWRebates;
        Test.setCurrentPage(pageRef);
        Test.startTest();  
        VFCntlr_RebatesSOW controller = new VFCntlr_RebatesSOW(new ApexPages.StandardController(mPlanHeadCountList[2]));
       
        List <Rebate_Rule_Line_Item__c> RRLI_List1=controller.getRRLI_List_FR(); 
        List <Rebate_Rule_Line_Item__c> RRLI_List2=controller.getRRLI_List_SKU(); 
        List <Rebate_Rule_Line_Item__c> RRLI_List3=controller.getRRLI_List_Class(); 
        
        Boolean bool1=controller.getlineitem();  
        Boolean bool2=controller.getFR_RT();  
        Boolean bool3=controller.getSKU_RT();  
        Boolean bool4=controller.getClass_RT();  
        Boolean bool11=controller.getSKU_amount();  
        Boolean bool12=controller.getSKU_rebate(); 
        Boolean bool13=controller.getSKU_sku(); 
        Boolean bool14=controller.getSKU_mfg(); 
        Boolean bool15=controller.getSKU_maxAmount(); 
        Boolean bool16=controller.getSKU_minUnit(); 
        Boolean bool17=controller.getSKU_maxUnit(); 
        Boolean bool18=controller.getSKU_comments(); 
        Boolean bool21=controller.getClass_amount(); 
        Boolean bool22=controller.getClass_rebate(); 
        Boolean bool23=controller.getClass_class(); 
        Boolean bool24=controller.getClass_subClass(); 
        Boolean bool25=controller.getClass_maxAmount(); 
        Boolean bool26=controller.getClass_minUnit(); 
        Boolean bool27=controller.getClass_maxUnit (); 
        Boolean bool28=controller.getClass_comments();
        Boolean bool31=controller.getFR_flatrate(); 
        Boolean bool32=controller.getFR_mfg(); 
        Boolean bool33=controller.getFR_comments(); 
        Test.stopTest(); 
     }  
       

//Default SOW Test  -Rebates OEM
     public static testMethod void testVFCntlr_DefaultSOW(){
        createData();       
        PageReference pageRef = Page.SOWDefault;
        Test.setCurrentPage(pageRef);
        Test.startTest();  
        SOWDefaultCtrlExt controller1 = new SOWDefaultCtrlExt(new ApexPages.StandardController(mPlanHeadCountList[4]));
        controller1.getvendorRecord();
        controller1.getMarketingPlanRec();
        controller1.getmdfContact();
        controller1.getapvRecords();
        controller1.getBudgetedPrice();
        
        VFCntlr_DefaultSOW controller2 = new VFCntlr_DefaultSOW(new ApexPages.StandardController(mPlanHeadCountList[4]));
        controller2.getvendorRecord();
        controller2.getMarketingPlanRec();
        controller2.getmdfContact();
        controller2.getapvRecords();
        controller2.getBudgetedPrice();
        
        Test.stopTest();  
     } 
      //COGS OEM SOW Test 
     public static testMethod void testVFCntlr_COGSOEMSOW(){
        createData();       
        PageReference pageRef = Page.SOWCOGSOEM;
        Test.setCurrentPage(pageRef);
        Test.startTest();  
        VFCntlr_COGSOEMSOW controller = new VFCntlr_COGSOEMSOW(new ApexPages.StandardController(mPlanHeadCountList[0]));
       List<Associated_Programs_Vendors__c> associatedPgmVendorList=controller.getAPVList(); 
        Marketing_Plan__c mPlan=controller.getMarketingPlan();         
        List<VFCntlr_COGSOEMSOW.DisplayDetails> wrapperRecords=controller.getDisplayDetails();
        List<VFCntlr_COGSOEMSOW.BSgmntAPV> BSgmntAPVRecs=controller.getBSgmntAPV();
        MDF_Contact__c mdfCntct=controller.getmdfContact();
        //Boolean bolPkg=controller.getPkgApvErr();
        Test.stopTest(); 
     }          
     
//SOWHeadcountIngramMicroCtrlExt   
     public static testMethod void testSOWHeadcountIngramMicroCtrlExt(){
        createData();       
        PageReference pageRef = Page.SOWHeadcountIngramMicro;
        Test.setCurrentPage(pageRef);
        Test.startTest();  
        SOWHeadcountIngramMicroCtrlExt controller1 = new SOWHeadcountIngramMicroCtrlExt(new ApexPages.StandardController(mPlanHeadCountList[5]));
        SOWHeadcountIngramMicroCtrlExt controller2 = new SOWHeadcountIngramMicroCtrlExt(new ApexPages.StandardController(mPlanHeadCountList[6]));
        SOWHeadcountIngramMicroCtrlExt controller3 = new SOWHeadcountIngramMicroCtrlExt(new ApexPages.StandardController(mPlanHeadCountList[7]));
        SOWHeadcountIngramMicroCtrlExt controller4 = new SOWHeadcountIngramMicroCtrlExt(new ApexPages.StandardController(mPlanHeadCountList[8]));
        controller1.getapvProgramRcd();
        controller1.getmarketingPlanRec();
        controller1.getfiscalQuater();
        controller1.getprogramPrice();
        Test.stopTest(); 
     } 
//Headcount OEM template
    public static testMethod void testSOWHeadcountOEMCtrlExt(){
        createData();  
        PageReference pageRef1 = Page.SOW_Headcount_OEM;
        Test.setCurrentPage(pageRef1);
        Test.startTest();  
        //VFCntlr_HeadcountOEM cntrlr = new VFCntlr_HeadcountOEM(new ApexPages.StandardController(mPlanHeadCountIngramMicro1));   
        VFCntlr_HeadcountOEM cntrlr = new VFCntlr_HeadcountOEM(new ApexPages.StandardController(mPlanHeadCountList[3]));     
        cntrlr.getmdfContact(); 
        cntrlr.getbudgetprice(); 
        cntrlr.getbudgetpricesum();
        cntrlr.getquaterlybudgetprice();
        cntrlr.getAPVList();
        cntrlr.getprogramdetail(); 
        Test.stopTest(); 
     }
 
    
}