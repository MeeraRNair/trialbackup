/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Fenny       7-Aug-2012      13.7                Test method failed during stabilizing week
*/
@isTest
private class  VFCntrlr_AssociateProgramsNPartnersTest {
    
    static  MDF_Program__c mdfProgram=new MDF_Program__c(); 
    //static  MDF_Program__c mdfProgram2=new MDF_Program__c(); 
    static  MDF_Program__c mdfProgram3=new MDF_Program__c(); 
    //static  MDF_Program__c mdfProgram4=new MDF_Program__c();   
    static  Proposed_Associated_Program_Vendor__c proposedApv1=new Proposed_Associated_Program_Vendor__c(); 
    static Vendor__c parentVendor=new Vendor__c();
    static List<MDF_Program__c> mdfList=new List<MDF_Program__c>();
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();    
    static Profile profiles;
    static List<User> users = new List<User>();    
    static List<Vendor__c> vendorList=new List<Vendor__c>();
    static List<VFCntrlr_AssociateProgramsNPartners.ProgramWrapper> wrapperObjList=new List<VFCntrlr_AssociateProgramsNPartners.ProgramWrapper>(); 
    static List<VFCntrlr_AssociateProgramsNPartners.ProgramWrapper> wrapperObjList1=new List<VFCntrlr_AssociateProgramsNPartners.ProgramWrapper>(); 
    public static Rebate_Rule_Header__c Rheader = new Rebate_Rule_Header__c();
    public static List <Rebate_Rule_Line_Item__c> RlineItemlist =  new List <Rebate_Rule_Line_Item__c>();
    public static List <Proposed_Associated_Program_Vendor__c > pApvlist =  new List <Proposed_Associated_Program_Vendor__c >();
                           
    public static void insertTestData(){
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();       
       Map<String,RecordType> mdfpgmRT=new Map<String,RecordType>();    
              
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];
       
            
       profiles=[select id,name from Profile where name like 'MDF Program Owners%' limit 1];       
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }

        for(RecordType mdfprgm:[Select Id,Name,SobjectType From RecordType where sObjectType='MDF_Program__c'])    {           
            mdfpgmRT.put(mdfprgm.Name,mdfprgm);
        }  
       
       try{    
           parentVendor.name= string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A' ;
//'TestVendor';
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
                       recordTypeId=vendorRT.get('Sub Vendor').Id,
                       Vendor_Unique_Field__c = 'TestUnique' +i
                   )
               );
           }
           vendorList[1].Budgeted_Discount__c=1;
           insert vendorList; 
                  
           
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
            
            mdfProgram.Name='testMDF Program1';
            mdfProgram.Program_Owner__c=users[0].id;
            mdfProgram.POP_Owner__c=users[1].id;
            mdfProgram.Program_Status__c='Approved';
            mdfProgram.Pricing_Type__c='Variable';
            mdfProgram.Fiscal_Quarter__c='FY12Q1';
            mdfProgram.OwnerId=users[2].id;
            mdfProgram.Rate_Card_Price__c=12356;
            mdfProgram.Region__c='Americas'; 
            mdfProgram.Sub_Region__c='North America';
            mdfProgram.Country__c='US'; 
            mdfProgram.Business_Segment__c='CSMR';             
            insert mdfProgram;
             
            /*mdfProgram2.Name='testMDF Program2';
            mdfProgram2.Program_Owner__c=users[0].id;
            mdfProgram2.POP_Owner__c=users[1].id;
            mdfProgram2.Program_Status__c='Approved';
            mdfProgram2.Pricing_Type__c='Variable';
            mdfProgram2.Fiscal_Quarter__c='FY12Q1';
            //mdfProgram2.OwnerId=users[2].id;
            mdfProgram2.Rate_Card_Price__c=12356;
            mdfProgram2.Region__c='Americas'; 
            mdfProgram2.Sub_Region__c='North America';
            mdfProgram2.Country__c='US'; 
            mdfProgram2.business_segment__c='CSMR';       
            insert mdfProgram2;*/
            
            mdfProgram3.Name='testMDF Program3';
            mdfProgram3.Program_Owner__c=users[0].id;
            mdfProgram3.POP_Owner__c=users[1].id;
            mdfProgram3.Program_Status__c='Approved';
            mdfProgram3.Pricing_Type__c='Variable';
            mdfProgram3.Fiscal_Quarter__c='FY12Q1';
            //mdfProgram3.OwnerId=users[2].id;
            mdfProgram3.Rate_Card_Price__c=12356;
            mdfProgram3.Region__c='Americas';
            mdfProgram3.business_segment__c='CSMR';
            mdfProgram3.Sub_Region__c='xqqx';
            mdfProgram3.Country__c='urrw'; 
            insert mdfProgram3;
            
    
                    
            for(Integer i = 0; i<3; i++){
               apvList.add(
                   new Associated_Programs_Vendors__c(
                       Status__c='Pending',
                       MDF_Program__c=mdfProgram.Id,
                       Vendor__c=vendorList[i].Id,
                       recordTypeId=apvRT.Id,
                       Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
                       Budgeted_Price__c=mdfProgram.Rate_Card_Price__c
                      
                   )
               );
           }
           
           for(Integer i = 0; i<3; i++){
               apvList.add(
                   new Associated_Programs_Vendors__c(
                       Status__c='Pending',
                       MDF_Program__c=mdfProgram3.Id,
                       Vendor__c=vendorList[i].Id,                   
                       recordTypeId=apvRT.Id,
                       Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
                       Budgeted_Price__c=mdfProgram.Rate_Card_Price__c
                   )
               );
           }
           
           insert apvList;
    
            MDF_Program__c mdfObj;
            for(integer i=0;i<4;i++){
                mdfObj=new MDF_Program__c();
                mdfObj.Name='testMDF Program' + i;
                mdfObj.Program_Owner__c=users[0].id;
                mdfObj.POP_Owner__c=users[1].id;
                mdfObj.Program_Status__c='Approved';
                mdfObj.Pricing_Type__c='Variable';
                mdfObj.Fiscal_Quarter__c='FY12Q2';
                //mdfObj.OwnerId=users[2].id;
                mdfObj.Rate_Card_Price__c=12356;
                mdfObj.Business_Segment__c='CSMR';
                mdfObj.Region__c='APJ'; 
                mdfList.add(mdfObj);
            }
            //insert mdfList; 
            
            /*mdfProgram4.Name='testMDF Program1';
            mdfProgram4.recordTypeId=mdfpgmRT.get('Event').id;
            mdfProgram4.Program_Owner__c=users[0].id;
            mdfProgram4.POP_Owner__c=users[1].id;
            mdfProgram4.Program_Status__c='Approved';
            mdfProgram4.Pricing_Type__c='Non-Variable';
            mdfProgram4.Fiscal_Quarter__c='FY12Q2';
            mdfProgram4.OwnerId=users[2].id;
            mdfProgram4.Rate_Card_Price__c=12356;
            mdfProgram4.Region__c='Americas'; 
            mdfProgram4.Sub_Region__c='North America';
            mdfProgram4.Country__c='US'; 
            mdfProgram4.Business_Segment__c='CSMR';  
            mdfProgram4.Event_Date__c=date.valueof('2011-05-30 00:00:00');
            system.debug('######Test data####'+  mdfProgram4); 
            mdfList.add(mdfProgram4);   
            //insert mdfProgram4;  */  
            
            insert mdfList;   
            
            proposedApv1.Business_Segment__c= mdfProgram.Business_Segment__c;
            proposedApv1.MDF_Program__c=mdfProgram.Id;
            proposedApv1.Program_Owner__c=mdfProgram.Program_Owner__c;                                  
            proposedApv1.Program_Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c;
            proposedApv1.Status__c='Pending';
            proposedApv1.Vendor__c=vendorList[1].Id  ;
            
            insert proposedApv1;
            
        }catch (exception e){
            system.debug('####Insert exception####'+e);
        }
    }
 
    //Test method for VFCntrlr_AssociateProgramsNPartnersTest
       
    public static testMethod void myUnitTest(){
        insertTestData();
        Proposed_Associated_Program_Vendor__c proposedApv2=new Proposed_Associated_Program_Vendor__c(Id=proposedApv1.Id);
        Decimal budPrice=0;
        Vendor__c vendorobj=vendorList[1];
        VFCntrlr_AssociateProgramsNPartners.ProgramWrapper pgmWrapperElt;
        wrapperObjList=new List<VFCntrlr_AssociateProgramsNPartners.ProgramWrapper>(); 
        List<VFCntrlr_AssociateProgramsNPartners.thousandBlocks> thousandRecList=new List<VFCntrlr_AssociateProgramsNPartners.thousandBlocks>(); 
        PageReference pageRef =new PageReference('/apex/ProposePartnerProgramAssociation?id={!vendorobj.Id}');
        List<String> bseg= new string[]{'CSMR','LE'};
        
         mdfList.add(mdfProgram);       
         for(MDF_Program__c pgm:mdfList){        
                
            if((pgm.Pricing_Type__c=='Variable') || (vendorobj.Budgeted_Discount__c==null)){
                budPrice=pgm.Rate_Card_Price__c;               
            }
            if(pgm.Pricing_Type__c=='Non-Variable' && pgm.Rate_Card_Price__c!=null && vendorobj.Budgeted_Discount__c!=null){                    
                budPrice=pgm.Rate_Card_Price__c*((100 - vendorobj.Budgeted_Discount__c)/100);
            } 
            pgmWrapperElt=new VFCntrlr_AssociateProgramsNPartners.ProgramWrapper(pgm);
            pgmWrapperElt.budgetedPriceDec=budPrice; 
            pgmWrapperElt.selected=true;            
            wrapperObjList.add(pgmWrapperElt);
        }
        
        thousandRecList.add(new VFCntrlr_AssociateProgramsNPartners.thousandBlocks(wrapperObjList,2));
        
        Test.setCurrentPage(pageRef);
        VFCntrlr_AssociateProgramsNPartners controller = new  VFCntrlr_AssociateProgramsNPartners(new ApexPages.StandardController (vendorobj)); 
        List<SelectOption> BSegoption=controller.getBusinessSegmentOptions();
        List<String> selectedBS =controller.getBusinessSegment();         
        controller.setBusinessSegment(bseg);
        
        List<String> selectedbseg=controller.getSelected();
        controller.setSelected(bseg);
        
        List<SelectOption> optionList1=controller.getUnSelectedOptions();
        
        pagereference pr1 =controller.doSelect() ;        
        
        List<String> unselectedbseg=controller.getUnSelected() ;
        controller.setUnSelected(unselectedbseg);         
        List<SelectOption> optionList2=controller.getSelectedOptions();
        
        
        mdf_program__c  mdfprgm=controller.getMDFProgram();
        controller.setMDFProgram(mdfProgram);
 
        
        List<VFCntrlr_AssociateProgramsNPartners.ProgramWrapper> wrapList= controller.getApvWrapperList();
        controller.setApvWrapperList(wrapperObjList);
   
        Boolean apvexist=controller.getNoApv();        
        pagereference pr2=controller.doUnSelect();
        pagereference pr3=controller.doSelectALL();         
        pagereference pr4 =controller.doUnSelectALL();
        
               
        
        PageReference pr5 =controller.ShowWrapperAPVRecordsForProposeAPV();
        controller.setApvWrapperList(wrapperObjList);
        PageReference pr6 =controller.insertProposedProgramRecs();
        String sortDir=controller.getSortDirection() ;
        sortDir='ASC';
        controller.setSortDirection(sortDir);  
        
        proposedApv2.Status__c='Accepted';
        update proposedApv2;
      
        mdfProgram3.POP_Owner__c=users[2].id;
        update mdfProgram3;
    }
 
    public static testMethod void TestPartnerProgramAssociation(){
        insertTestData();
        
        mdf_program__c mdfPGM=new mdf_program__c(); 
            mdfPGM.Name='testmdfPGM';
            mdfPGM.Program_Owner__c=users[1].id;
            mdfPGM.POP_Owner__c=users[1].id;
            mdfPGM.Program_Status__c='Approved';
            mdfPGM.Pricing_Type__c='Variable';
            mdfPGM.Fiscal_Quarter__c='FY12Q1';
            mdfPGM.OwnerId=users[2].id;
            mdfPGM.Rate_Card_Price__c=12356;
            mdfPGM.Region__c='Americas'; 
            mdfPGM.Sub_Region__c='North America';
            mdfPGM.Country__c='US'; 
            mdfPGM.Business_Segment__c='CSMR';             
            insert mdfPGM;
       
        Decimal budPrice=0;
        Vendor__c vendorobj=vendorList[1];
        VFCntrlr_AssociateProgramsNPartners.ProgramWrapper pgmWrapperElt;
        wrapperObjList=new List<VFCntrlr_AssociateProgramsNPartners.ProgramWrapper>(); 
        List<VFCntrlr_AssociateProgramsNPartners.thousandBlocks> thousandRecList=new List<VFCntrlr_AssociateProgramsNPartners.thousandBlocks>(); 
        
        
        PageReference pageRef =new PageReference('/apex/PartnerProgramAssociation?id={!vendorobj.Id}');
        List<String> bseg= new string[]{'CSMR'};
        
         mdfList.add(mdfProgram);       
         for(MDF_Program__c pgm:mdfList){        
                
            if((pgm.Pricing_Type__c=='Variable') || (vendorobj.Budgeted_Discount__c==null)){
                budPrice=pgm.Rate_Card_Price__c;               
            }
            if(pgm.Pricing_Type__c=='Non-Variable' && pgm.Rate_Card_Price__c!=null && vendorobj.Budgeted_Discount__c!=null){                    
                budPrice=pgm.Rate_Card_Price__c*((100 - vendorobj.Budgeted_Discount__c)/100);
            } 
            pgmWrapperElt=new VFCntrlr_AssociateProgramsNPartners.ProgramWrapper(pgm);
            pgmWrapperElt.budgetedPriceDec=budPrice; 
            pgmWrapperElt.selected=true;
            //pgmWrapperElt.pgmWELt=pgm;
            wrapperObjList.add(pgmWrapperElt);
        }
        
        thousandRecList.add(new VFCntrlr_AssociateProgramsNPartners.thousandBlocks(wrapperObjList,2));
        
        Test.setCurrentPage(pageRef);
        VFCntrlr_AssociateProgramsNPartners controller = new  VFCntrlr_AssociateProgramsNPartners(new ApexPages.StandardController (vendorobj)); 
        controller.getProfileVisibility();
        List<SelectOption> BSegoption=controller.getBusinessSegmentOptions();
        List<String> selectedBS =controller.getBusinessSegment();         
        controller.setBusinessSegment(bseg);
        
        List<String> selectedbseg=controller.getSelected();
        controller.setSelected(bseg);
        
        List<SelectOption> optionList1=controller.getUnSelectedOptions();
        
        pagereference pr1 =controller.doSelect() ;        
        
        List<String> unselectedbseg=controller.getUnSelected() ;
        controller.setUnSelected(unselectedbseg);         
        List<SelectOption> optionList2=controller.getSelectedOptions();
        
        
        mdf_program__c  mdfprgm=controller.getMDFProgram();
        mdfprgm.Business_Segment__c='CSMR';        
        
        controller.setMDFProgram(mdfprgm);
        PageReference pr7=controller.ShowWrapperAPVRecords();
        
        mdf_program__c  mdfprgm2=controller.getMDFProgram();
        mdfprgm2.Business_Segment__c='CSMR';  
        mdfprgm2.Region__c='APJ'; 
        controller.setMDFProgram(mdfprgm2);
        PageReference prRegion=controller.ShowWrapperAPVRecords();
        
        mdf_program__c  mdfprgm3=controller.getMDFProgram();
        mdfprgm3.Business_Segment__c='CSMR';  
        mdfprgm3.Region__c='APJ'; 
        controller.setMDFProgram(mdfprgm3);
        PageReference prRegion1=controller.ShowWrapperAPVRecords();
        
        mdf_program__c  mdfprgm4=controller.getMDFProgram();
        mdfprgm4.Business_Segment__c='CSMR';  
        mdfprgm4.Region__c='APJ';
        mdfprgm4.Fiscal_Quarter__c='FY12Q2';
        controller.setMDFProgram(mdfprgm4);
        PageReference prFQ=controller.ShowWrapperAPVRecords();
   
        mdf_program__c  mdfprgm5=controller.getMDFProgram();
        mdfprgm5.Business_Segment__c='CSMR';  
        mdfprgm5.Region__c='APJ';
        mdfprgm5.Fiscal_Quarter__c='FY12Q2';     
        mdfprgm5.Sub_Region__c='North America';
        controller.setMDFProgram(mdfprgm5);
        PageReference prSR=controller.ShowWrapperAPVRecords();
                   
        mdf_program__c  mdfprgm6=controller.getMDFProgram();
        mdfprgm6.Business_Segment__c='CSMR';  
        mdfprgm6.Region__c='Americas';
        mdfprgm6.Fiscal_Quarter__c='FY12Q1';     
        mdfprgm6.Sub_Region__c='North America';
        mdfprgm6.Country__c='US'; 
        controller.setMDFProgram(mdfprgm6);
        
        //List<VFCntrlr_AssociateProgramsNPartners.ProgramWrapper> wrapList= controller.getApvWrapperList();
        List<VFCntrlr_AssociateProgramsNPartners.thousandBlocks> thousandBlkList=controller.getThousandRecList();
        PageReference prCountry=controller.ShowWrapperAPVRecords();
 
        controller.setThousandRecList(thousandRecList);  
        controller.getDisplayTable();    
        controller.getDisplayForm();    
        controller.getNoAPVList();
        
        PageReference pr8 =controller.insertPartnerProgramRecs(); 

    }
    
    public static testMethod void testNoAPVList(){
        insertTestData();
        
        mdf_program__c mdfPGM=new mdf_program__c(); 
            mdfPGM.Name='testmdfPGM';
            mdfPGM.Program_Owner__c=users[1].id;
            mdfPGM.POP_Owner__c=users[1].id;
            mdfPGM.Program_Status__c='Approved';
            mdfPGM.Pricing_Type__c='Variable';
            mdfPGM.Fiscal_Quarter__c='FY12Q1';
            mdfPGM.OwnerId=users[2].id;
            mdfPGM.Rate_Card_Price__c=12356;
            mdfPGM.Region__c='Americas'; 
            mdfPGM.Sub_Region__c='North America';
            mdfPGM.Country__c='US'; 
            mdfPGM.Business_Segment__c='CSMR';             
            insert mdfPGM;
       
        Decimal budPrice=0;
        Vendor__c vendorobj=vendorList[1];
        VFCntrlr_AssociateProgramsNPartners.ProgramWrapper pgmWrapperElt;
        wrapperObjList=new List<VFCntrlr_AssociateProgramsNPartners.ProgramWrapper>(); 
        List<VFCntrlr_AssociateProgramsNPartners.thousandBlocks> thousandRecList=new List<VFCntrlr_AssociateProgramsNPartners.thousandBlocks>(); 
        
        
        PageReference pageRef =new PageReference('/apex/PartnerProgramAssociation?id={!vendorobj.Id}');
        List<String> bseg= new string[]{'CSMR'};
        
         mdfList.add(mdfProgram);       
         for(MDF_Program__c pgm:mdfList){        
                
            if((pgm.Pricing_Type__c=='Variable') || (vendorobj.Budgeted_Discount__c==null)){
                budPrice=pgm.Rate_Card_Price__c;               
            }
            if(pgm.Pricing_Type__c=='Non-Variable' && pgm.Rate_Card_Price__c!=null && vendorobj.Budgeted_Discount__c!=null){                    
                budPrice=pgm.Rate_Card_Price__c*((100 - vendorobj.Budgeted_Discount__c)/100);
            } 
            pgmWrapperElt=new VFCntrlr_AssociateProgramsNPartners.ProgramWrapper(pgm);
            pgmWrapperElt.budgetedPriceDec=budPrice; 
            pgmWrapperElt.selected=true;
            //pgmWrapperElt.pgmWELt=pgm;
            wrapperObjList.add(pgmWrapperElt);
        }
        
        thousandRecList.add(new VFCntrlr_AssociateProgramsNPartners.thousandBlocks(wrapperObjList,2));
        
        Test.setCurrentPage(pageRef);
        VFCntrlr_AssociateProgramsNPartners controller = new  VFCntrlr_AssociateProgramsNPartners(new ApexPages.StandardController (vendorobj)); 
        controller.getProfileVisibility();
        List<SelectOption> BSegoption=controller.getBusinessSegmentOptions();
        List<String> selectedBS =controller.getBusinessSegment();         
        controller.setBusinessSegment(bseg);
        
        List<String> selectedbseg=controller.getSelected();
        controller.setSelected(bseg);
        
        List<SelectOption> optionList1=controller.getUnSelectedOptions();
        
        pagereference pr1 =controller.doSelect() ;        
        
        List<String> unselectedbseg=controller.getUnSelected() ;
        controller.setUnSelected(unselectedbseg);         
        List<SelectOption> optionList2=controller.getSelectedOptions();

        mdf_program__c  mdfprgm6=controller.getMDFProgram();
        mdfprgm6.Business_Segment__c='CSMR';  
        mdfprgm6.Region__c='Americas';
        mdfprgm6.Fiscal_Quarter__c='FY12Q1';     
        mdfprgm6.Sub_Region__c='North America';
        mdfprgm6.Country__c='US'; 
        controller.setMDFProgram(mdfprgm6);
      
        List<VFCntrlr_AssociateProgramsNPartners.thousandBlocks> thousandBlkList=controller.getThousandRecList();
        PageReference prCountry=controller.ShowWrapperAPVRecords();

    }
    
    //Test method for DateValidationForFiscalQtr
    public static testMethod void RRDateValidationTest(){
        insertTestData();
        
        Rheader.Name = 'testRH';
        Rheader.Fiscal_Quarter__c = 'FY12Q2';
        Rheader.Region__c ='APJ';
        Rheader.Sub_Region__c='APJ';        
        Rheader.Vendor__c = vendorList[1].Id;
        Rheader.Status__c='Pending';
        insert Rheader;
        
        for(Integer i=0;i<5;i++){
            Rebate_Rule_Line_Item__c linitem = new Rebate_Rule_Line_Item__c();
            linitem.Rebate_Rule_Header__c = Rheader.Id;
            if(i==1){
                linitem.Effective_Date_From__c=date.valueof('2011-05-30 00:00:00');
                linitem.Effective_Date_To__c=date.valueof('2011-06-30 00:00:00');
            }
            if(i==2){
                linitem.Effective_Date_From__c=date.valueof('2012-05-30 00:00:00');
                linitem.Effective_Date_To__c=date.valueof('2011-06-30 00:00:00');
            }            
            RlineItemlist.add(linitem);
        }
        try{
            insert RlineItemlist;          
        }catch (exception e){
            system.debug('####Insert exception####'+e);
        }    
    }
    
    public static testMethod void attcahmentNameTest(){   
        Proof_of_Performance_POP__c POPRec = new Proof_of_Performance_POP__c();
        POP_Line_Item__c POPLIRec = new POP_Line_Item__c();
        Attachment attachfile = new Attachment();
        String filecontent='This is a test attachment';
        
        insertTestData();
        
        POPRec.Name = 'TestPOP';
        POPRec.MDF_Program__c = mdfProgram.Id;       
        
        insert POPRec;
       
        //for(Integer i = 0; i<3; i++){  
        POPLIRec.Proof_of_Performance_POP__c = POPRec.id;
        POPLIRec.Vendor__c = vendorList[1].Id;
        //}
        insert POPLIRec;   
        
        /* insert the attachment */                
        attachfile.parentId = POPLIRec.id ;
        attachfile.Body = Blob.valueOf(filecontent);
        attachfile.Name = 'TestPOP.doc'; // Ver 1.0

        insert attachfile;
    
    } 
    
}