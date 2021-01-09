//2.0      03-Jun-2018    sharad  : CR15884  ,VIPER: - APV Creation from Marketing Plan Page
@isTest
private class ViperContractManagementTest{

    static  MDF_Program__c mdfProgram=new MDF_Program__c(); 
    static  MDF_Program__c mdfProgram2=new MDF_Program__c(); 
    static  MDF_Program__c mdfProgram3=new MDF_Program__c(); 
    static  List<MDF_Program__c> mdfProgramData = new List<MDF_Program__c>();
    static Vendor__c parentVendor=new Vendor__c();
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c(); 
    static List<User> users = new List<User>();
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
    static Package__c packageObj=new Package__c(); 
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static Marketing_Plan__c marketingPlan=new Marketing_Plan__c(); 
    static Invoice__c invoiceObj=new Invoice__c(); 
    static Profile profiles;
    static List<MDF_Program__c> mdfList=new List<MDF_Program__c>();
    static List<ViperContractManagement.MPWrapper> testObj=new List<ViperContractManagement.MPWrapper>(); 
    static Marketing_Plan__c MarketingPlanRec=new Marketing_Plan__c();
    //static Marketing_Plan__c marketingPlanHC=new Marketing_Plan__c();
    static MDF_Contact__c mdfContact = new MDF_Contact__c();
    static MDF_Associated_Contact__c mdfAssocContact = new MDF_Associated_Contact__c();
    
    
    public static void createData(){       
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();       
       RecordType marketingPlanRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       RecordType marketingPlanHCRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Headcount Marketing Plan' limit 1];
       
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];
       
       RecordType mdfContactRT=[Select Name, Id From RecordType where sObjectType='MDF_Contact__c' and name='Product Manager Contact' limit 1]; 
       
       
       profiles=[select id,name from Profile where name like 'MDF Program Owners' limit 1]; 
       
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }
      // parentVendor.name='TestVendor'+System.now().millisecond();
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A';
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;       
       insert parentVendor;
       
       for(Integer i = 0; i<3; i++){
           vendorList.add(
               new Vendor__c(
                   Parent_Vendor__c=parentVendor.Id,
                   Name='TestSubVendor'+i,
                   Partner_Status__c='Active',
                   Partner_Type__c='Value',
                   Product_Category__c='Networking',
                   Contract_Types_eligible_for__c='Volume Based,Ala Carte',
                   recordTypeId=vendorRT.get('Sub Vendor').Id
               )
           );
       }
       
       insert vendorList; 
       invoiceObj.name='Inv-001';
       invoiceObj.Vendor__c=vendorList[0].Id;
       invoiceObj.Fiscal_Quarter__c='FY12Q1';
       invoiceObj.Region__c='Americas';
       invoiceObj.Contract_Type__c='Volume Based, Ala Carte, Headcount';
       insert invoiceObj;     
       
       marketingPlan.name='MP-001';
       marketingPlan.Vendor__c=vendorList[0].Id;
       marketingPlan.Fiscal_Quarter__c='FY12Q1';
       marketingPlan.Region__c='Americas';
       marketingPlan.Contract_Type__c='Volume Based';
       marketingPlan.RecordTypeId=marketingPlanRT.Id;
       marketingPlan.invoice__c=invoiceObj.Id;
       //marketingPlan.business_segment__c='CSMR';
       insert marketingPlan; 
       
       packageObj.Marketing_Plan__c=marketingPlan.Id;
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
                    Badge_Number__c='John.doe'+i,
                    Profile_Region__c= 'Americas'                    
               )
            );
        }
        insert users;
        
        
        mdfContact.Name = 'Mr Tam';
        mdfContact.Status__c ='Active';
        mdfContact.Region__c ='Americas';
        mdfContact.recordTypeId = mdfContactRT.Id ;
        mdfContact.Primary_Secondary__c ='Primary';
        mdfContact.Status__c='Active';
        mdfContact.Sub_Region__c='North America';
        mdfContact.User__c=users[1].Id;     
        
        insert mdfContact;    
        
        mdfAssocContact.Vendor__c =vendorList[0].Id;
        mdfAssocContact.mdf_Contact__c=mdfContact.Id;
        
        insert mdfAssocContact;
        
        mdfProgram.Name='testMDF Program1';
        mdfProgram.Program_Owner__c=users[0].id;
        mdfProgram.POP_Owner__c=users[1].id;
        mdfProgram.Program_Status__c='Approved';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q1';
        mdfProgram.OwnerId=users[2].id;
        mdfProgram.Rate_Card_Price__c=12356;
        mdfProgram.Region__c='Americas'; 
        mdfProgram.Sub_Region__c='xyz';
        mdfProgram.Country__c='uvw'; 
        mdfProgram.Business_Segment__c='CSMR';        
        mdfProgramData.add(mdfProgram);
         
        mdfProgram2.Name='testMDF Program2';
        mdfProgram2.Program_Owner__c=users[0].id;
        mdfProgram2.POP_Owner__c=users[1].id;
        mdfProgram2.Program_Status__c='Approved';
        mdfProgram2.Pricing_Type__c='Variable';
        mdfProgram2.Fiscal_Quarter__c='FY12Q1';
        mdfProgram2.OwnerId=users[2].id;
        mdfProgram2.Rate_Card_Price__c=12356;
        mdfProgram2.Region__c='Americas'; 
        mdfProgram2.Sub_Region__c='xxxx';
        mdfProgram2.Country__c='udvw';         
        mdfProgramData.add(mdfProgram2);
        
        mdfProgram3.Name='testMDF Program3';
        mdfProgram3.Program_Owner__c=users[0].id;
        mdfProgram3.POP_Owner__c=users[1].id;
        mdfProgram3.Program_Status__c='Approved';
        mdfProgram3.Pricing_Type__c='Variable';
        mdfProgram3.Fiscal_Quarter__c='FY12Q1';
        mdfProgram3.OwnerId=users[2].id;
        mdfProgram3.Rate_Card_Price__c=12356;
        mdfProgram3.Region__c='Americas';
        mdfProgram3.business_segment__c='CSMR';
        mdfProgram3.Sub_Region__c='xqqx';
        mdfProgram3.Country__c='urrw'; 
        mdfProgramData.add(mdfProgram3);
        
        insert mdfProgramData;
        
        for(Integer i = 0; i<3; i++){
           apvList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Pending',
                   MDF_Program__c=mdfProgramData[i].Id,
                   Package__c=packageObj.Id,
                   Vendor__c=vendorList[i].Id,
                   Marketing_Plan__c=marketingPlan.Id,
                   recordTypeId=apvRT.Id,
                   Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
                   Budgeted_Price__c=mdfProgram.Rate_Card_Price__c,
                   Invoice_Amount__c=98980
                   
               )
           );
       }
       insert apvList;
       
       List<Budgeted_Price_Distribution__c> BDPData = new List<Budgeted_Price_Distribution__c>();
       Budgeted_Price_Distribution__c bpdElt1=new Budgeted_Price_Distribution__c(
       Business_Segment__c='CSMR',
       Contract_Type__c='Volume Based',
       CSMR__c=25,
       LE__c=25,
       PUB__c=25,
       SMB__c=25 );
       BDPData.add(bpdElt1);
       
       Budgeted_Price_Distribution__c bpdElt2=new Budgeted_Price_Distribution__c(
       Business_Segment__c='CSMR',
       Contract_Type__c='Ala Carte',
       CSMR__c=25,
       LE__c=25,
       PUB__c=25,
       SMB__c=25 );
       BDPData.add(bpdElt2);
       
       Budgeted_Price_Distribution__c bpdElt3=new Budgeted_Price_Distribution__c(
       Business_Segment__c='CSMR',
       Contract_Type__c='Headcount',
       CSMR__c=25,
       LE__c=25,
       PUB__c=25,
       SMB__c=25 );
       BDPData.add(bpdElt3);
       
       insert BDPData;
       
        MDF_Program__c mdfObj;
        for(integer i=0;i<4;i++){
            mdfObj=new MDF_Program__c();
            mdfObj.Name='testMDF Program';
            mdfObj.Program_Owner__c=users[0].id;
            mdfObj.POP_Owner__c=users[1].id;
            mdfObj.Program_Status__c='Approved';
            mdfObj.Pricing_Type__c='Variable';
            mdfObj.Fiscal_Quarter__c='FY12Q2';
            mdfObj.OwnerId=users[2].id;
            mdfObj.Rate_Card_Price__c=12356;
            mdfObj.Region__c='APJ'; 
            mdfList.add(mdfObj);
        }
        insert mdfList; 
        
        MarketingPlanRec.name='MP-001';
        MarketingPlanRec.Vendor__c=vendorList[0].Id;
        MarketingPlanRec.Fiscal_Quarter__c='FY12Q2';
        MarketingPlanRec.Region__c='APJ';
        MarketingPlanRec.Contract_Type__c='Volume Based';
        MarketingPlanRec.RecordTypeId=marketingPlanRT.Id;
        MarketingPlanRec.invoice__c=invoiceObj.Id;
        //MarketingPlanRec.Business_Segment__c='CSMR';
        MarketingPlanRec.Term__c='4';
        insert MarketingPlanRec;
        
    }
    
    public static testMethod void testViperContractManagement(){ 
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();       
        PageReference pageRef = Page.MPProgramAssociation;
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ViperContractManagement controller = new ViperContractManagement(new ApexPages.StandardController(marketingPlan));
        Boolean contactErrorMessageDisplay=controller.getAPVList();
        Boolean DisplaySubVendorList=controller.getProgramList();        
        LIST<MDF_Program__c> MDFProgramList2=controller.getMDFProgramList(); 
        Boolean bolElt=controller.getInsert();
        List<Associated_Programs_Vendors__c> apvRecList=controller.getAPVs();        
        Volume_Based_Rule_Header__c vbrhElt=controller.getVolumeBasedRH();        
        controller.setVolumeBasedRH(vbrhElt);
        Boolean bolVBRH=controller.getCreateVBRH();
        Rebate_Rule_Header__c rrhElt=controller.getRebateRH();
        controller.setRebateRH(rrhElt);
        Boolean bolRRH=controller.getCreateRRH();
        List<SelectOption> optionList2=controller.getDisplayItems();
        String idList=controller.getRuleIds();
        controller.setRuleIds(idList);
        Boolean bolMPList=controller.getMPlanOptionList();
        List<ViperContractManagement.MPWrapper> mpWrapperList=controller.getListOfMpWrapperRecords();
        controller.setListOfMpWrapperRecords(mpWrapperList);
        List<ViperContractManagement.ProgramWrapper> pgmWrapperList=controller.getListOfPgmWrapperRecs();
        controller.setListOfPgmWrapperRecs(pgmWrapperList);
        Boolean bol=controller.getApvErr();
        Boolean bolAC=controller.getAlacarteErr();
        List<Volume_Based_Rule_Line_Item__c> vbrhLnItemList=controller.getVBRHLLnList();
         Test.stopTest();
         TriggerExecutionController.setSkipAllTriggers(false);
    }
  
    
    public static testMethod void testUpdateAPVs(){
        List<ViperContractManagement.MPWrapper> mpWrapperList=new List<ViperContractManagement.MPWrapper>(); 
        ViperContractManagement.MPWrapper wrapper;
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();       
        PageReference pageRef = Page.MPProgramAssociation;
        Test.setCurrentPage(pageRef);
        Test.startTest();
        for(Associated_Programs_Vendors__c apv:apvList){  
            wrapper=new ViperContractManagement.MPWrapper(apv); 
            wrapper.selected=true;             
            mpWrapperList.add(wrapper);
        }
        ViperContractManagement controller = new ViperContractManagement(new ApexPages.StandardController(marketingPlan));
        controller.setListOfMpWrapperRecords(mpWrapperList);
        PageReference pageRefUpdate=controller.updateMPAPVRecords();
         Test.stopTest();
         TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    public static testMethod void testUpdateAPVsHC(){
        List<ViperContractManagement.MPWrapper> mpWrapperList=new List<ViperContractManagement.MPWrapper>(); 
        ViperContractManagement.MPWrapper wrapper;
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();       
        PageReference pageRef = Page.MPProgramAssociation;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        for(Associated_Programs_Vendors__c apv:apvList){  
            wrapper=new ViperContractManagement.MPWrapper(apv); 
            wrapper.selected=true;             
            mpWrapperList.add(wrapper);
        }        
        ViperContractManagement controller = new ViperContractManagement(new ApexPages.StandardController(MarketingPlanRec));
        controller.setListOfMpWrapperRecords(mpWrapperList);
        PageReference pageRefUpdate=controller.updateMPAPVRecords();
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    public static testMethod void testinsertAPVs(){
        List<ViperContractManagement.ProgramWrapper> pgmWrapperList=new List<ViperContractManagement.ProgramWrapper>(); 
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();
        ViperContractManagement.ProgramWrapper wrapper;
        PageReference pageRef2 = Page.MPProgramAssociation;
        Test.setCurrentPage(pageRef2); 
        Test.startTest();  
        for(integer i=0;i<mdfList.size();i++){
            wrapper=new ViperContractManagement.ProgramWrapper(mdfList[i]);
            wrapper.selected=true;
            pgmWrapperList.add(wrapper);
        }
        ViperContractManagement controller = new ViperContractManagement(new ApexPages.StandardController(MarketingPlanRec));
        controller.getListOfPgmWrapperRecs();
        controller.setListOfPgmWrapperRecs(pgmWrapperList);           
          
        PageReference pageRefInsert=controller.insertAPVs();
        Test.stopTest();    
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    public static testMethod void testUpdateMarketingPlanRuleHeaderVBRH(){
        List<ViperContractManagement.ProgramWrapper> pgmWrapperList=new List<ViperContractManagement.ProgramWrapper>(); 
        Volume_Based_Rule_Header__c vbrhObj=new Volume_Based_Rule_Header__c();
        Volume_Based_Rule_Header__c vbrhObj1;
        List<Volume_Based_Rule_Header__c> vbrhList=new List<Volume_Based_Rule_Header__c>(); 
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();
        PageReference pageRef2 = Page.MPRuleHeader;
        Test.setCurrentPage(pageRef2);
        Test.startTest();
        ViperContractManagement controller = new ViperContractManagement(new ApexPages.StandardController(MarketingPlanRec));
       
        PageReference pageRefInsert=controller.updateMarketingPlanRuleHeader();
        PageReference pageRefInsertVBRH=controller.SaveVBRH();
        vbrhObj.name='Test VBRH';
        vbrhObj.Vendor__c=marketingPlanRec.Vendor__c;
        vbrhObj.Fiscal_Quarter__c=marketingPlanRec.Fiscal_Quarter__c;
        vbrhObj.Region__c=marketingPlanRec.Region__c;
        vbrhObj.Sub_Region__c='NAX';
        vbrhObj.Country__c='USAX';
        insert vbrhObj; 
        
        PageReference pageRefInsert2=controller.updateMarketingPlanRuleHeader(); 
        
        for(Integer i=0;i<2;i++){
            vbrhObj1=new Volume_Based_Rule_Header__c();
            vbrhObj1.name='VBRH'+i;
            vbrhObj1.Vendor__c=marketingPlanRec.Vendor__c;
            vbrhObj1.Fiscal_Quarter__c=marketingPlanRec.Fiscal_Quarter__c;
            vbrhObj1.Region__c=marketingPlanRec.Region__c; 
            vbrhObj1.Sub_Region__c='NAXX'+i;
            vbrhObj1.Country__c='USAXX'+i;
            vbrhList.add(vbrhObj1);
        }
        insert vbrhList; 
        
        String ruleId=controller.getRuleIds();
        controller.setRuleIds(ruleId);
        
        PageReference pageRefInsert3=controller.updateMarketingPlanRuleHeader2();
        
        
        MarketingPlanRec.Contract_Status__c='Signed';
        update MarketingPlanRec; 
        Test.stopTest();  
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    
   public static testMethod void testUpdateMarketingPlanRuleHeaderRRH(){
         
         RecordType mPlanRebatesRT=[Select Name, Id From RecordType where sObjectType='Marketing_Plan__c' and name='Rebates Marketing Plan' limit 1];
         TriggerExecutionController.setSkipAllTriggers(true);
        createData();
        Test.startTest();
        marketingPlan=new Marketing_Plan__c();
        marketingPlan.name='MP-001';
        marketingPlan.Vendor__c=vendorList[0].Id;
        marketingPlan.Fiscal_Quarter__c='FY17Q1';
        marketingPlan.Region__c='Americas';
        marketingPlan.Contract_Type__c='Rebates';
        marketingPlan.RecordTypeId=mPlanRebatesRT.Id;
       
        insert marketingPlan;
       
        List<ViperContractManagement.ProgramWrapper> pgmWrapperList=new List<ViperContractManagement.ProgramWrapper>(); 
        Rebate_Rule_Header__c rrhObj=new Rebate_Rule_Header__c();
        Rebate_Rule_Header__c rrhObj1;
        List<Rebate_Rule_Header__c> rrhList=new List<Rebate_Rule_Header__c>(); 
        
        
        PageReference pageRef2 = Page.MPRuleHeader;
        Test.setCurrentPage(pageRef2);
        
        ViperContractManagement controller = new ViperContractManagement(new ApexPages.StandardController(marketingPlan));
       
         Rebate_Rule_Header__c rrh=controller.getRebateRH();
         //rrh.Rebate_Rule_Name__c='Test1';
         rrh.Vendor__c=marketingPlan.Vendor__c;
         rrh.Fiscal_Quarter__c=marketingPlan.Fiscal_Quarter__c;
         rrh.Region__c=marketingPlan.Region__c;
         rrh.name='Test1';  
        
        controller.setRebateRH(rrh);
         
            
        PageReference pageRefInsert=controller.updateMarketingPlanRuleHeader();
        PageReference pageRefInsertRRH=controller.SaveRRH();
        //rrhObj.Rebate_Rule_Name__c='Test1';
        rrhObj.Vendor__c=marketingPlan.Vendor__c;
        rrhObj.Fiscal_Quarter__c=marketingPlan.Fiscal_Quarter__c;
        rrhObj.Region__c=marketingPlan.Region__c;
        rrhObj.name='Test New';
        insert rrhObj; 
        
        PageReference pageRefInsert2=controller.updateMarketingPlanRuleHeader(); 
        
        for(Integer i=0;i<2;i++){
            rrhObj1=new Rebate_Rule_Header__c();
            rrhObj1.name='Test1'+i;
            rrhObj1.Vendor__c=marketingPlanRec.Vendor__c;
            rrhObj1.Fiscal_Quarter__c=marketingPlanRec.Fiscal_Quarter__c;
            rrhObj1.Region__c=marketingPlanRec.Region__c;
            rrhList.add(rrhObj1);
        }
        insert rrhList; 
        
        String ruleId=controller.getRuleIds();
        controller.setRuleIds(ruleId);
        
        PageReference pageRefInsert3=controller.updateMarketingPlanRuleHeader2();
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
          
    }//EOM 
    
    
     public static testMethod void testAutoApproveMPlan(){
        
        List<Marketing_Plan__c> MarketingPlanList=new List<Marketing_Plan__c>(); 
        RecordType mPlanRebatesRT=[Select Name, Id From RecordType where sObjectType='Marketing_Plan__c' and name='Rebates Marketing Plan' limit 1];
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();
        Test.startTest();
        marketingPlan=new Marketing_Plan__c();
        marketingPlan.name='MP-001';
        marketingPlan.Vendor__c=vendorList[0].Id;
        marketingPlan.Fiscal_Quarter__c='FY12Q1';
        marketingPlan.Region__c='Americas';
        marketingPlan.Contract_Type__c='Rebates';
        marketingPlan.ownerId=UserInfo.getUserId();
        marketingPlan.RecordTypeId=mPlanRebatesRT.Id;
       
        insert marketingPlan;
        
        marketingPlan.Contract_Status__c='Signed';
        update marketingPlan;
        
        MarketingPlanList.add(marketingPlan); 
    
        ViperContractManagement.autoApproveMarketingPlanRecord(MarketingPlanList);   
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
     }  
    
    
    //UpdateBudgetedPriceDistribution()
        
        
    public static testMethod void testUpdateBudgetedPriceDistribution(){
        Associated_Programs_Vendors__c apvRec;       
        List<Associated_Programs_Vendors__c> APVBPDList=new List<Associated_Programs_Vendors__c>(); 
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();
        
       List <RecordType> sltRT = [SELECT Name, Id FROM RecordType where sObjectType='Marketing_Plan__c' AND (name='Volume Based Marketing Plan' OR name='Ala Carte Marketing Plan' OR name='Headcount Marketing Plan') ORDER BY Name ASC];
        List<Marketing_Plan__c> sltMP = new List<Marketing_Plan__c>();
        
        Marketing_Plan__c vbMP = new Marketing_Plan__c(name='MP-001', Vendor__c=vendorList[0].Id, Fiscal_Quarter__c='FY12Q1', Region__c='AmericasXX', Contract_Type__c='Volume Based', RecordTypeId=sltRT[2].Id);
        sltMP.add(vbMP);
        Marketing_Plan__c acMP = new Marketing_Plan__c(name='MP-001', Vendor__c=vendorList[0].Id, Fiscal_Quarter__c='FY12Q1', Region__c='Americas', Contract_Type__c='Ala Carte', RecordTypeId=sltRT[0].Id);
        sltMP.add(acMP);
        Marketing_Plan__c hcMP = new Marketing_Plan__c(name='MP-001', Vendor__c=vendorList[0].Id, Fiscal_Quarter__c='FY12Q1', Region__c='Americas', Contract_Type__c='Headcount', RecordTypeId=sltRT[1].Id);
        sltMP.add(hcMP);

        Test.startTest();
        insert sltMP;
        
        
        for(integer i=0;i<apvList.size();i++){
            apvRec=new Associated_Programs_Vendors__c(id=apvList[i].Id,Budgeted_Price__c=99999); 
            if(i==0){
                apvRec.marketing_plan__c=sltMP[0].Id;
            }
            if(i==1){
                apvRec.marketing_plan__c=sltMP[1].Id;
            }
            if(i==2){
                apvRec.marketing_plan__c=sltMP[2].Id;
            }       
            APVBPDList.add(apvRec); 
        }
        update APVBPDList; 
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
   }
   
    public static testMethod void testBeforeAfterMarketingPlanTrigger(){
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();
        
        RecordType mPlanRebatesRT=[Select Name, Id From RecordType where sObjectType='Marketing_Plan__c' and name='Rebates Marketing Plan' limit 1];
        Test.startTest();       
        marketingPlan=new Marketing_Plan__c();
        marketingPlan.name='MP-001';
        marketingPlan.Vendor__c=vendorList[0].Id;
        marketingPlan.Fiscal_Quarter__c='FY12Q1';
        marketingPlan.Region__c='Americas';
        marketingPlan.Sub_Region__c='North America';
        marketingPlan.Contract_Type__c='Rebates';
        marketingPlan.RecordTypeId=mPlanRebatesRT.Id;
        
        insert marketingPlan;
        
        marketingPlan.Fiscal_Quarter__c='FY12Q2';
        update marketingPlan; 
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }  
     
    
}