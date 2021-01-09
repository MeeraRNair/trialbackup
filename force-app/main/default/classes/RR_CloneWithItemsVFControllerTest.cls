@isTest
private class RR_CloneWithItemsVFControllerTest {
    
    public static Rebate_Rule_Header__c Rheader = new Rebate_Rule_Header__c();
    public static List <Rebate_Rule_Line_Item__c> RlineItemlist =  new List <Rebate_Rule_Line_Item__c>();
    public static RecordType vendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Vendor'];
    public static RecordType subvendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Sub Vendor'];
    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    
    
    public static void createdata(){
        
        // creating a parent vendor
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
        parentVendor.Partner_Status__c='Active';
        parentVendor.recordTypeId=vendorRT.Id;          
        insert parentVendor;
        
        // creating a sub vendor
        subvendor.Parent_Vendor__c=parentVendor.Id;
       //subVendor.Name='TestSubVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
        subvendor.Partner_Status__c='Active';
        subvendor.Partner_Type__c='Value';
        subvendor.Product_Category__c='Networking';
        subvendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
        subvendor.recordTypeId= subvendorRT.Id;       
        insert subvendor;
        
        Rheader.Name = 'testRH';
        Rheader.Fiscal_Quarter__c = 'FY12Q2';
        Rheader.Region__c ='APJ';
        Rheader.Sub_Region__c='APJ';        
        Rheader.Vendor__c = subvendor.Id;
//        Rheader.Rebate_Rule_Name__c = 'testRH';
        Rheader.Status__c='Pending';
        insert Rheader;
        
        for(Integer i=0;i<5;i++){
            Rebate_Rule_Line_Item__c linitem = new Rebate_Rule_Line_Item__c();
            linitem.Rebate_Rule_Header__c = Rheader.Id;
            linitem.Effective_Date_From__c=date.valueof('2011-05-30 00:00:00');
            linitem.Effective_Date_To__c=date.valueof('2011-06-30 00:00:00');
            RlineItemlist.add(linitem);
        }insert RlineItemlist;
    }
    
    static testMethod void myUnitTest1() {
        
          createdata();
          // setup a reference to the page the controller is expecting with the parameters

          system.debug('hiiiiiii->'+Rheader.Id);
          PageReference pr = Page.RebateRuleClonePage;
          ApexPages.currentPage().getParameters().put('id',Rheader.Id);
          Test.setCurrentPage(pr);
          
          //Controller
          RR_CloneWithItemsVFController cntrlr = new RR_CloneWithItemsVFController(new ApexPages.StandardController(Rheader));
          cntrlr.clone_RRH = Rheader; 
          system.debug('hiiiiiii->'+cntrlr.clone_RRH);
          //Rebate_Rule_Header__c rrh=cntrlr.getnew_RRH();
         // rrh.Fiscal_Quarter__c='FY12Q2';
        //  cntrlr.setnew_RRH(rrh);
          Boolean bool = cntrlr.getdisplayerr();
          Boolean bool2 = cntrlr.getnewfiscalyr();       
          Boolean bool3 = cntrlr.getfiscalyrerr();
          Boolean bool4 = cntrlr.getduprecordexist();
          PageReference ref = cntrlr.RRCloneWithItems();

    }
    
    static testMethod void myUnitTest2() {
        
          createdata();
          // setup a reference to the page the controller is expecting with the parameters

          system.debug('hiiiiiii->'+Rheader.Id);
          PageReference pr = Page.RebateRuleClonePage;
          ApexPages.currentPage().getParameters().put('id',Rheader.Id);
          Test.setCurrentPage(pr);
          
          //Controller
          RR_CloneWithItemsVFController cntrlr = new RR_CloneWithItemsVFController(new ApexPages.StandardController(Rheader));
          cntrlr.clone_RRH = Rheader; 
          system.debug('hiiiiiii->'+cntrlr.clone_RRH);
          //Rebate_Rule_Header__c rrh=cntrlr.getnew_RRH();
          //rrh.Fiscal_Quarter__c='FY12Q1';
         // cntrlr.setnew_RRH(rrh);
          Boolean bool1 = cntrlr.getdisplayerr();
          Boolean bool2 = cntrlr.getnewfiscalyr();       
          Boolean bool3 = cntrlr.getfiscalyrerr();
          Boolean bool4 = cntrlr.getduprecordexist();
          system.assert(bool2==True);
          system.assert(bool4==False);
          System.assertEquals(bool1,False); 
          System.assertEquals(bool3,False);  
          PageReference ref = cntrlr.RRCloneWithItems();

    }    
    
     static testMethod void myUnitTest3() {
        
          createdata();
          // setup a reference to the page the controller is expecting with the parameters

          system.debug('hiiiiiii->'+Rheader.Id);
          PageReference pr = Page.RebateRuleClonePage;
          ApexPages.currentPage().getParameters().put('id',Rheader.Id);
          Test.setCurrentPage(pr);
          
          //Controller
          RR_CloneWithItemsVFController cntrlr = new RR_CloneWithItemsVFController(new ApexPages.StandardController(Rheader));
          cntrlr.clone_RRH = Rheader; 
          
          system.debug('hiiiiiii->'+cntrlr.clone_RRH);
          //Rebate_Rule_Header__c rrh=cntrlr.getnew_RRH();
         // rrh.Fiscal_Quarter__c='FY12Q2';
        //  cntrlr.setnew_RRH(rrh);
          Boolean bool = cntrlr.getdisplayerr();
          Boolean bool2 = cntrlr.getnewfiscalyr();       
          Boolean bool3 = cntrlr.getfiscalyrerr();
          Boolean bool4 = cntrlr.getduprecordexist();
          cntrlr.new_RRH.Fiscal_Quarter__c = 'FY12Q3';
          
         
                
          PageReference ref = cntrlr.RRCloneWithItems();
          

    }
    
    static testMethod void testApproval() {
        createdata();
        Profile profiles=[select id,name from Profile where name LIKE '%Marketing Operation%' limit 1];
        User userElt=new User(
            Username='testuser'+ System.currentTimeMillis() +'@dell.com',
            Alias = 'test', 
            Email='testuser@dellteam.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = profiles.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='testuser'                     
        );
        Rebate_Rule_Header__c Rheader2 = new Rebate_Rule_Header__c();
        Rheader2.Name = 'testRH1';
        Rheader2.Fiscal_Quarter__c = 'FY12Q2';
        Rheader2.Region__c ='APJ';
        Rheader2.Sub_Region__c='APJ';            
        Rheader2.Vendor__c = subvendor.Id;
        //            Rheader2.Rebate_Rule_Name__c = 'testRH';
        Rheader2.Status__c='Pending';
        insert Rheader2;
        System.runAs(userElt){
            PageReference pr = Page.RRAutoApprovePage;
            ApexPages.currentPage().getParameters().put('id',Rheader2.Id);
            Test.setCurrentPage(pr);
            RR_CloneWithItemsVFController cntrlr = new RR_CloneWithItemsVFController(new ApexPages.StandardController(Rheader2));   
            cntrlr.AutoApproveRR();
        }
//        System.assert(Rheader2.Status__c);
        Rebate_Rule_Header__c RheaderApproved=[select Name,Status__c from Rebate_Rule_Header__c where id=:Rheader2.Id] ;
//        System.assertEquals('Approved',RheaderApproved.Status__c);        
        
//        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
//        System.assertEquals('Approved', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());
       
        PageReference pr = Page.RebateRuleClonePage;
        ApexPages.currentPage().getParameters().put('id',Rheader.Id);
        Test.setCurrentPage(pr);
        
        //Controller
        RR_CloneWithItemsVFController cntrlr = new RR_CloneWithItemsVFController(new ApexPages.StandardController(Rheader));
        cntrlr.clone_RRH = Rheader; 
        system.debug('hiiiiiii->'+cntrlr.clone_RRH);
       // Rebate_Rule_Header__c rrh=cntrlr.getnew_RRH();
       // rrh.Fiscal_Quarter__c='FY12Q1';
       // cntrlr.setnew_RRH(rrh);
        Boolean bool = cntrlr.getdisplayerr();
        Boolean bool2 = cntrlr.getnewfiscalyr();       
        Boolean bool3 = cntrlr.getfiscalyrerr();
        Boolean bool4 = cntrlr.getduprecordexist();
        System.assertEquals(bool2,True);
        System.assertEquals(bool3,False);  
        System.assertEquals(bool4,False);
        System.assertEquals(bool2,True);
        PageReference ref = cntrlr.RRCloneWithItems();        
        
      
    }
    
    static testMethod void testduplicatechktgr() {
            createdata();
//          Insert a duplicate record.  
            Rebate_Rule_Header__c Rheader2 = new Rebate_Rule_Header__c();           
            Rheader2.Name = 'testRH';
            Rheader2.Fiscal_Quarter__c = 'FY12Q1';
            Rheader2.Region__c ='APJ';
            Rheader2.Sub_Region__c='APJ';
            Rheader2.Vendor__c = subvendor.Id;
            Rheader2.Status__c='Pending';
            try{ 
                insert Rheader2; 
            } catch ( System.DmlException e) {
            system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Duplicate record already exists.Enter a new value'),
                  e.getMessage());   
            }
            
           
     }    
    
}