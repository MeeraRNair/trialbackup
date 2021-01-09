@isTest(SeeAllData=true)
private class MarketingResultsCtrlExtTest{

    static Invoice__c currentInvoice;
    static  MDF_Program__c mdfProgram=new MDF_Program__c(); 
    static  MDF_Program__c alamdfProgram=new MDF_Program__c(); 
    static  MDF_Program__c HeadCountProgram=new MDF_Program__c(); 
    static Vendor__c parentVendor=new Vendor__c();
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c(); 
    static List<User> users = new List<User>();
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
    static Package__c packageObj=new Package__c(); 
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static Marketing_Plan__c marketingPlan=new Marketing_Plan__c(); 
    static Marketing_Plan__c marketingPlanheadcount=new Marketing_Plan__c(); 
    static Marketing_Plan__c marketingPlanAlacarte=new Marketing_Plan__c(); 
    static Marketing_Plan__c marketingPlanRebate=new Marketing_Plan__c(); 
    static Invoice__c invoiceObj=new Invoice__c(); 
    static Profile profiles;
    
    static MDF_Contact__c mdfContact = new MDF_Contact__c();
    static MDF_Associated_Contact__c mdfAssocContact = new MDF_Associated_Contact__c();
    
public static void createData(){
       
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();
       
       RecordType marketingPlanRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       RecordType alamarketingPlanRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Ala Carte Marketing Plan' limit 1];
       
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];

       RecordType mdfContactRT=[Select Name, Id From RecordType where 
       sObjectType='MDF_Contact__c' and name='Partner Contact' limit 1];
       
       profiles=[select id,name from Profile where name like 'MDF Program Owners' limit 1];
       
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }
       parentVendor.name='TestVendor1';
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;
       
       insert parentVendor;
       
       for(Integer i = 0; i<=3; i++){
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
       marketingPlan.Contract_Status__c = 'Signed';
       marketingPlan.Invoice_Amount__c=12356;
       
       insert marketingPlan; 
       
        marketingPlanheadcount.name='MP-001';
       marketingPlanheadcount.Vendor__c=vendorList[0].Id;
       marketingPlanheadcount.Fiscal_Quarter__c='FY12Q1';
       marketingPlanheadcount.Region__c='Americas';
       marketingPlanheadcount.Contract_Type__c='HeadCount';
       marketingPlanheadcount.RecordTypeId=marketingPlanRT.Id;
       marketingPlanheadcount.invoice__c=invoiceObj.Id;
       marketingPlanheadcount.Contract_Status__c = 'Signed';
       marketingPlanheadcount.Invoice_Amount__c=12356;

       insert marketingPlanheadcount;
       
        marketingPlanAlacarte.name='MP-001';
       marketingPlanAlacarte.Vendor__c=vendorList[0].Id;
       marketingPlanAlacarte.Fiscal_Quarter__c='FY12Q1';
       marketingPlanAlacarte.Region__c='Americas';
       marketingPlanAlacarte.Contract_Type__c='Ala Carte';
       marketingPlanAlacarte.RecordTypeId=alamarketingPlanRT.Id;
       marketingPlanAlacarte.invoice__c=invoiceObj.Id;
       marketingPlanAlacarte.Contract_Status__c = 'Signed';
       marketingPlanAlacarte.Invoice_Amount__c=12356;       
       insert marketingPlanAlacarte;
       
        marketingPlanRebate.name='MP-001';
       marketingPlanRebate.Vendor__c=vendorList[0].Id;
       marketingPlanRebate.Fiscal_Quarter__c='FY12Q1';
       marketingPlanRebate.Region__c='Americas';
       marketingPlanRebate.Contract_Type__c='Rebate';
       marketingPlanRebate.RecordTypeId=marketingPlanRT.Id;
       marketingPlanRebate.invoice__c=invoiceObj.Id;
       marketingPlanRebate.Contract_Status__c = 'Signed';
       marketingPlanRebate.Invoice_Amount__c=12356;       
       insert marketingPlanRebate;
       
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
                    Badge_Number__c='John.doe'+i
               )
            );
        }
        insert users;
        
        mdfProgram.Name='testMDF Program';
        mdfProgram.Program_Owner__c=users[0].id;
        mdfProgram.POP_Owner__c=users[1].id;
        mdfProgram.Program_Status__c='Approved';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q1';
        mdfProgram.OwnerId=users[2].id;
        mdfProgram.Rate_Card_Price__c=12356;
        
        insert mdfProgram;
        
        alamdfProgram.Name='testMDF ala Program';
        alamdfProgram.Program_Owner__c=users[0].id;
        alamdfProgram.POP_Owner__c=users[1].id;
        alamdfProgram.Program_Status__c='Approved';
        alamdfProgram.Pricing_Type__c='Variable';
        alamdfProgram.Fiscal_Quarter__c='FY12Q1';
        alamdfProgram.OwnerId=users[2].id;
        alamdfProgram.Rate_Card_Price__c=12356;
        
        insert alamdfProgram;
        
        HeadCountProgram.Name='testMDF HC Program';
        HeadCountProgram.Program_Owner__c=users[0].id;
        HeadCountProgram.POP_Owner__c=users[1].id;
        HeadCountProgram.Program_Status__c='Approved';
        HeadCountProgram.Pricing_Type__c='Variable';
        HeadCountProgram.Fiscal_Quarter__c='FY12Q1';
        HeadCountProgram.OwnerId=users[2].id;
        HeadCountProgram.Rate_Card_Price__c=12356;
        
        insert HeadCountProgram;
        
       for(Integer i = 0; i<=3; i++){
           Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
                  // apv.Status__c='Pending';
                  apv.Status__c='Signed';
                   apv.Package__c=packageObj.Id;
                   apv.Vendor__c=vendorList[i].Id;
                   apv.POP_Status__c = 'Executed';
                   if(i==3){
                    apv.MDF_Program__c=alamdfProgram.Id;
                    apv.Marketing_Plan__c=marketingPlanAlacarte.Id;
                   }
                   else if(i==2)
                   {
                    apv.MDF_Program__c=HeadCountProgram.Id;
                    apv.Marketing_Plan__c= marketingPlanheadcount.Id;
                   }
                   else{
                    apv.MDF_Program__c=mdfProgram.Id;
                    apv.Marketing_Plan__c=marketingPlan.Id;
                   }
                   apv.recordTypeId=apvRT.Id;
                   apv.Rate_Card_Price__c=896542;
                   apv.Budgeted_Price__c=56932;
                   apv.Invoice_Amount__c=98980;
                   
                   apvList.add(apv);
       }
       insert apvList;
              

       RecordType MDFContRT=[Select Name, Id From RecordType where
               sObjectType='MDF_Contact__c' and name='Product Manager Contact' limit 1];
               
        mdfContact.Name = 'Mr Tam';
        mdfContact.Status__c = 'Active';
        mdfContact.Region__c = invoiceObj.Region__c;
        mdfContact.recordTypeId = MDFContRT.Id ;
        mdfContact.Primary_Secondary__c = 'Primary';       
        insert mdfContact;
       
       mdfAssocContact.Vendor__c =vendorList[0].Id;
       mdfAssocContact.mdf_Contact__c=mdfContact.Id;
       
       insert mdfAssocContact;
       
       ///////////
       
        
       
       /* List<MarketingResultsCtrlExt.MarketingPlanWrapperCls> marketingPlanIteratedList=new List<MarketingResultsCtrlExt.MarketingPlanWrapperCls>(); 
        MarketingResultsCtrlExt.MarketingPlanWrapperCls wrapperElt=new MarketingResultsCtrlExt.MarketingPlanWrapperCls(marketingPlan);
        wrapperElt.selected=true;       
        marketingPlanIteratedList.add(wrapperElt);
        
        //Ala Carte
        MarketingResultsCtrlExt.MarketingPlanWrapperCls alawrapperElt=new MarketingResultsCtrlExt.MarketingPlanWrapperCls(marketingPlanAlacarte);
        alawrapperElt.selected=true;       
        marketingPlanIteratedList.add(alawrapperElt);
       
        pageReference pref = Page.MarketingResults;
        pref.getParameters().put('id',invoiceObj.id);
        Test.setCurrentPage(pref);
        
        MarketingResultsCtrlExt con = new MarketingResultsCtrlExt(new ApexPages.StandardController(invoiceObj));  
        List<MarketingResultsCtrlExt.MarketingPlanWrapperCls> listElt = con.getmarketingPlanIteratedList();
       //con.setmarketingPlanIteratedList(marketingPlanIteratedList);
        con.insertSelectedMarketingPlans();*/
        
    }
    
    static testMethod void testInvoicePackage(){
        TriggerExecutionController.setSkipAllTriggers(true);
        createdata();

        List<MarketingResultsCtrlExt.MarketingPlanWrapperCls> marketingPlanIteratedList=new List<MarketingResultsCtrlExt.MarketingPlanWrapperCls>(); 
        MarketingResultsCtrlExt.MarketingPlanWrapperCls wrapperElt=new MarketingResultsCtrlExt.MarketingPlanWrapperCls(marketingPlan);
        wrapperElt.selected=true;       
        marketingPlanIteratedList.add(wrapperElt);
        
        //Ala Carte
        MarketingResultsCtrlExt.MarketingPlanWrapperCls alawrapperElt=new MarketingResultsCtrlExt.MarketingPlanWrapperCls(marketingPlanAlacarte);
        alawrapperElt.selected=true;       
        marketingPlanIteratedList.add(alawrapperElt);
        
        //HeadCount 
        MarketingResultsCtrlExt.MarketingPlanWrapperCls HeadCountElt=new MarketingResultsCtrlExt.MarketingPlanWrapperCls(marketingPlanHeadCount);
        HeadCountElt.selected=true;       
        marketingPlanIteratedList.add(HeadCountElt);
            
        PageReference pref = Page.MarketingResults;
        pref.getParameters().put('id',invoiceObj.id);
        Test.setCurrentPage(pref);
        
        MarketingResultsCtrlExt con = new MarketingResultsCtrlExt(new ApexPages.StandardController(invoiceObj));  
        List<MarketingResultsCtrlExt.MarketingPlanWrapperCls> listElt = con.getmarketingPlanIteratedList();
        con.setmarketingPlanIteratedList(marketingPlanIteratedList);

       // pref = con.insertSelectedMarketingPlans();
       
        pref = con.insertAttachment();
        con.insertSelectedMarketingPlans();
        con.getMPIDset();
        con.getInvoicePackage();

        con.getmarketingPlanList();

        con.getMDFAssociatedContact();
        con.getvolumeBasedAPVPgmList(); 
        con.getheadCountAPVPgmList(); 
        con.getalaCarteAPVPgmList(); 
        
        con.getalaCarteBudgetedPrice();
        con.getheadCountInvoiceAmount();  
        con.getheadCountBudgetedPrice();
        con.getGenerateBtn();
        con.getAttachBtn();
        con.getalaCarteInvoiceAmnt();
        con.getVolumeBasedMPList();
        con.getalaCarteMPList();
        
        //VolumeBasedMP
        String header;
        List<Associated_Programs_Vendors__c> apvendorList = new List<Associated_Programs_Vendors__c>();
        VolumeBasedMP vmp = new VolumeBasedMP (header, apvendorList);  
        vmp.getHeader();
        vmp.getAssociatedVendorsList();
        vmp.getbudgetedPrice();
        vmp.getinvoiceAmount();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}