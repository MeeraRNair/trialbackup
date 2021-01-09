@isTest
private class TestContractManagement{

    static  MDF_Program__c mdfProgram=new MDF_Program__c();    
    static Vendor__c parentVendor=new Vendor__c();
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c(); 
    
       
    static List<User> users = new List<User>();
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
    static Package__c packageObj=new Package__c(); 
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static Marketing_Plan__c mPlanCogs=new Marketing_Plan__c(); 
    static Marketing_Plan__c mPlanNCogs=new Marketing_Plan__c(); 
    
          
    static Invoice__c invoiceObj=new Invoice__c(); 
    static Profile profiles;
    static List<MDF_Program__c> mdfList=new List<MDF_Program__c>();    
    static Marketing_Plan__c MarketingPlanRec=new Marketing_Plan__c();

    static MDF_Contact__c mdfContact = new MDF_Contact__c();
    static MDF_Associated_Contact__c mdfAssocContact = new MDF_Associated_Contact__c();
    
    static MDF_Contact__c mdfContact2 = new MDF_Contact__c();
    static MDF_Associated_Contact__c mdfAssocContact2 = new MDF_Associated_Contact__c();
    
    static MDF_Contact__c partnerContact = new MDF_Contact__c();
    static MDF_Associated_Contact__c partnerMdfAssocContact = new MDF_Associated_Contact__c();
    
    static MDF_Contact__c coMarketingContact = new MDF_Contact__c();
    static MDF_Associated_Contact__c coMarketingAssoContact  = new MDF_Associated_Contact__c();
    
    static List<MDF_Contact__c> mdfContactList=new List<MDF_Contact__c>();
    static List<MDF_Associated_Contact__c> mdfAssociatedCntctLst=new List<MDF_Associated_Contact__c>();
    
    
    static Map<String,RecordType> contactRecTypeMap=new Map<String,RecordType>();
     
     public static void createData(){ 
       Map<String,RecordType> recTypeMap=new Map<String,RecordType>();
       Map<String,RecordType> vendorRT=new Map<String,RecordType>(); 
       Map<String,RecordType> RRLIRT =new Map<String,RecordType>();
       RecordType apvRT;
       for(RecordType recType:[select id,name,SobjectType  from RecordType 
                                where SobjectType='Marketing_Plan__c' OR
                                sObjectType='Rebate_Rule_Line_Item__c' OR
                                sObjectType='vendor__c' or
                                sObjectType='MDF_Contact__c' or
                                sObjectType='Associated_Programs_Vendors__c']){
            if(recType.SobjectType=='Marketing_Plan__c'){
                recTypeMap.put(recType.name,recType);  
            } 
            if(recType.sObjectType=='Rebate_Rule_Line_Item__c'){
                RRLIRT.put(recType.name,recType); 
            }
            if(recType.sObjectType=='vendor__c'){
                vendorRT.put(recType.name,recType);   
            }
            if(recType.sObjectType=='MDF_Contact__c'){
                contactRecTypeMap.put(recType.name,recType);  
            } 
            if(recType.sObjectType=='Associated_Programs_Vendors__c' && recType.name=='Vendor Association MP'){
                apvRT=recType;  
            }                   
                                  
        } 
       profiles=[Select id,name from profile where name like 'MDF Program Owners%' limit 1];
       for(Integer i = 0; i<4; i++){           
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
                    Badge_Number__c='John.doe'+i,
                    Profile_Region__c='Americas'
               )
            );
        }
        insert users;
        
       
       Vendor__c subVendor;
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;       
       insert parentVendor;      
       
       
       for(Integer i = 0; i<1; i++){           
            subVendor= new Vendor__c(
               Parent_Vendor__c=parentVendor.Id,
               //Name='TestSubVendor'+i, // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
               Name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+i, // Fenny added on 21-Feb-2013
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
           
               vendorList.add(subVendor);
       }
       
       insert vendorList;
       
       
       
       mPlanCogs.name='MP-001';
       mPlanCogs.Vendor__c=vendorList[0].Id;
       mPlanCogs.Fiscal_Quarter__c='FY12Q2';
       mPlanCogs.Region__c='Americas';
       mPlanCogs.Sub_Region__c='North America';
       mPlanCogs.Contract_Type__c='Volume Based';
       mPlanCogs.RecordTypeId=recTypeMap.get('Volume Based Marketing Plan').Id; 
       mPlanCogs.Currency_Code__c='CAD';
       mPlanCogs.Contract_Status__c='Pending';
       insert mPlanCogs; 
       
       
       mPlanNCogs.name='MP-001';
       mPlanNCogs.Vendor__c=vendorList[0].Id;
       mPlanNCogs.Fiscal_Quarter__c='FY12Q2';
       mPlanNCogs.Region__c='AWZP';
       mPlanNCogs.Sub_Region__c='XCVB';
       mPlanNCogs.Contract_Type__c='Ala Carte';
       mPlanNCogs.RecordTypeId=recTypeMap.get('Ala Carte Marketing Plan').Id; 
       mPlanNCogs.Currency_Code__c='CAD';
       mPlanNCogs.Contract_Status__c='Pending';
       insert mPlanNCogs;
       
       
              
       
       packageObj.Marketing_Plan__c=mPlanCogs.Id;
       packageObj.Status__c='Pending';
       packageObj.name='TestPkg';       
       insert packageObj;
        
        mdfContact.Name = 'Mr Tam';
        mdfContact.Status__c = 'Active';
        mdfContact.Region__c = 'Americas';
        mdfContact.Sub_Region__c = 'North America';
        mdfContact.recordTypeId = contactRecTypeMap.get('Product Manager Contact').Id ;
        mdfContact.Primary_Secondary__c = 'Primary';       
        mdfContactList.add(mdfContact);
        
                
        partnerContact.Name = 'Mr Tam';
        partnerContact.Status__c = 'Active';
        partnerContact.Region__c = 'GBL';
        partnerContact.recordTypeId = contactRecTypeMap.get('Partner Contact').Id;
        partnerContact.Primary_Secondary__c = 'Primary'; 
        partnerContact.Partner_Contact_Type__c ='Billing';   
        partnerContact.Phone__c='1111';
        partnerContact.email__c='hanan.justin@ust-global.com';
        mdfContactList.add(partnerContact);
       
        
        coMarketingContact.Name = 'Mr Tam';
        coMarketingContact.Status__c = 'Active';
        coMarketingContact.Region__c = 'Americas';
        coMarketingContact.Sub_Region__c='North America';
        coMarketingContact.Country__c='US';
        coMarketingContact.Business_Segment__c='LE';
        coMarketingContact.recordTypeId = contactRecTypeMap.get('Co-Marketing Contact').Id;
        coMarketingContact.Primary_Secondary__c = 'Primary';   
        coMarketingContact.User__c=users[0].Id;  
        coMarketingContact.Notify_When_APV_Created__c=true; 
        mdfContactList.add(coMarketingContact);      
         
        
        insert mdfContactList;
        
        
        mdfAssocContact.Vendor__c =vendorList[0].Id;
        mdfAssocContact.mdf_Contact__c=mdfContact.Id;
        mdfAssociatedCntctLst.add(mdfAssocContact);

        
       
        partnerMdfAssocContact.Vendor__c =vendorList[0].Id;
        partnerMdfAssocContact.mdf_Contact__c=partnerContact.Id;
        mdfAssociatedCntctLst.add(partnerMdfAssocContact);
       
        coMarketingAssoContact.Vendor__c =vendorList[0].Id;
        coMarketingAssoContact.mdf_Contact__c=coMarketingContact.Id;
        mdfAssociatedCntctLst.add(coMarketingAssoContact);
        
        insert mdfAssociatedCntctLst;   
        
        
       
        MDF_Program__c mdfObj;
        for(integer i=0;i<2;i++){
            mdfObj=new MDF_Program__c();
            mdfObj.Name='testMDF Program'+i;
            mdfObj.Program_Owner__c=users[0].id;
            mdfObj.POP_Owner__c=users[1].id;
            mdfObj.Program_Status__c='Approved';
            mdfObj.Pricing_Type__c='Variable';
            mdfObj.Fiscal_Quarter__c='FY12Q2';
            mdfObj.OwnerId=users[2].id;
            mdfObj.Rate_Card_Price__c=12356;
            mdfObj.Region__c='Americas'; 
            mdfObj.SUb_Region__c='North America'; 
            mdfObj.Country__c='US'; 
            //mdfObj.Region__c='APJ'; 
            mdfObj.Business_Segment__c='LE';            
            if(i==1){
                mdfObj.Business_Segment__c='CSMR';
            }
            mdfList.add(mdfObj);
        }
        insert mdfList; 
        
        for(Integer i = 0; i<2; i++){            
                apvList.add(
                   new Associated_Programs_Vendors__c(
                       Status__c='Pending',
                       MDF_Program__c=mdfList[i].Id,
                       Package__c=packageObj.Id,
                       Vendor__c=vendorList[0].Id,
                       Marketing_Plan__c=mPlanCogs.Id,
                       recordTypeId=apvRT.Id,
                       Rate_Card_Price__c=mdfList[i].Rate_Card_Price__c,
                       Budgeted_Price__c=mdfList[i].Rate_Card_Price__c,                       
                       LE__c=100,
                       PUB__c=100,
                       SMB__c=300,
                       CSMR__c=500
                   )
               );
       }
       insert apvList;       
    }
    
    public static testMethod void testCurrencyCode(){
        createData();
        mPlanCogs.Currency_Code__c='INR';
        update mPlanCogs; 
    }
    public static testMethod void testBillingMarketingContactUpdate(){
        createData();
        mPlanCogs.Billing_Contact_Country__c='Canada';
        update mPlanCogs; 
    }
    public static testMethod void testMarketingPlanStatusUpdate(){
        createData();        
        mPlanCogs.Contract_Status__c='Signed';
        update mPlanCogs;
        mPlanCogs.Contract_Status__c='Reviewed';
        update mPlanCogs;
        mPlanCogs.Contract_Status__c='Pending';
        update mPlanCogs;
        
        mPlanNCogs.Contract_Status__c='Signed';
        mPlanNCogs.fiscal_quarter__c='FY13Q1';
        update mPlanNCogs;        
    }
    public static testMethod void testProductManagerAPproval(){
        createData();
        apvList[0].Budgeted_Price__c=99889;
        apvList[0].Product_Manager_Approval__c='Approved by product Manager';
        update apvList[0]; 
    } 
    /*
    public static testMethod void testEchoSign(){
        createData();
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
        agreement.Marketing_Plan__c = mPlanCogs.Id;
        agreement.Name = 'test agreement';
        agreement.mdf_contact__c =partnerContact.Id;
        agreement.echosign_dev1__Additional_Recipient_1_User__c=users[0].Id;
        agreement.echosign_dev1__Additional_Recipient_2_User__c=users[1].Id;
        agreement.echosign_dev1__Additional_Recipient_3_User__c=users[2].Id;
        agreement.echosign_dev1__Recipient_User__c=users[3].Id;                   
        insert agreement;
        
        agreement.echosign_dev1__Status__c ='Waiting for Counter-Signature';
        update agreement; 
    }*/
}