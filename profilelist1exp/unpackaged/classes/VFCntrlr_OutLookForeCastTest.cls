@isTest
private class VFCntrlr_OutLookForeCastTest {
    
    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static List <Associated_Programs_Vendors__c> apvList = new List <Associated_Programs_Vendors__c>();
    public static Marketing_Plan__c mp = new Marketing_Plan__c();
    public static RecordType vendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Vendor'];
    public static RecordType subvendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Sub Vendor'];
    public static RecordType mpRT = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Volume Based Marketing Plan'];
    public static List <MDF_Program__c> pgmlist =  new List <MDF_Program__c>{};
    public static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like'%MDF Program Owners%' limit 1];
    public static User u1 = new User();
        
    public static void createdata(){        
        u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
        insert u1;
        
        //creating a parent vendor
        parentVendor.name='TestVendor123';
        parentVendor.Partner_Status__c='Active';
        parentVendor.recordTypeId=vendorRT.Id;
        
        insert parentVendor;        
        
        // creating a sub vendor
        subvendor.Parent_Vendor__c=parentVendor.Id;
        subvendor.Name='TestSubVendor';
        subvendor.Partner_Status__c='Active';
        subvendor.Partner_Type__c='Value';
        subvendor.Product_Category__c='Networking';
        subvendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
        subvendor.recordTypeId= subvendorRT.Id;
        
        insert subvendor;
        
        // creating an MP
        mp.name='MP-001';
        mp.Vendor__c=subvendor.Id;
        mp.Fiscal_Quarter__c='FY12Q1';
        mp.Region__c='EMEA';
        mp.Contract_Type__c='Volume Based';
        mp.RecordTypeId=mpRT.Id;
       
        insert mp; 
        
        // creating apvs
        for(Integer i=0;i<2;i++){
        MDF_Program__c pgm = new MDF_Program__c();
        pgm.Name = 'Name'+i;
        pgm.Program_Owner__c=u1.Id;
        pgm.POP_Owner__c=u1.Id;
        pgmlist.add(pgm);
        }
        insert pgmlist;
        for(Integer i=0;i<2;i++){
        Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
        apv.Vendor__c = subvendor.Id;
        apv.Marketing_Plan__c = mp.Id;
        apv.Status__c = 'Accepted';
        apv.MDF_Program__c = pgmlist[i].Id;
        apv.Budgeted_Price__c = i;                              
        apvList.add(apv);           
       }insert apvList;
    }
    
    static testMethod void myUnitTest() {        
        Test.startTest();
        
        createdata();   
        
        Outlook_Forecast__c vbf = new Outlook_Forecast__c();
        vbf.Fiscal_Quarter__c = 'FY12Q1';
        vbf.Region__c = 'EMEA';
        vbf.Category__c = 'Outlook 1';                      
        
        PageReference  pr=new PageReference('apex/outLookForecast');
        Test.setCurrentPage(pr);
        VFCntrlr_OutLookForeCast cntrlr = new VFCntrlr_OutLookForeCast(new ApexPages.StandardController(vbf));
        cntrlr.showVendors();
        PageReference actualpage = cntrlr.saveOutLookForeCastLineItem();
        Outlook_Forecast__c vbfsaved = cntrlr.myOutLookForeCasts;
        String expected = '/'+ vbfsaved.Id;
        String actual = actualpage.getUrl();
        System.assertEquals(expected,actual);
        system.debug('hiiiiiiiiiiiiiiiiiiiiiiiiii------------actual'+ actual +'expected'+expected);
        cntrlr.getoutLookForcastLineItemList();
        cntrlr.getvendorIds();
        
        Outlook_Forecast__c ofc1 = new Outlook_Forecast__c(Fiscal_Quarter__c = 'FY12Q2',Region__c = 'EMEA',Category__c = 'Final Invoice Amount');
        insert ofc1;
        Outlook_Forecast__c ofc1qry = [Select Id from Outlook_Forecast__c where Fiscal_Quarter__c = 'FY12Q2'and Region__c = 'EMEA'and Category__c = 'Final Invoice Amount'];
        
        Outlook_Forecast__c ofc2 = new Outlook_Forecast__c(Fiscal_Quarter__c = 'FY12Q2',Region__c = 'EMEA',Category__c = 'Final Invoice Amount');        
        Database.SaveResult sr = Database.insert(ofc2,false);
        system.assertEquals(sr.isSuccess(), false);
                
        Outlook_Forecast__c ofc3 = new Outlook_Forecast__c(Fiscal_Quarter__c = 'FY12Q2',Region__c = 'EMEA',Category__c = 'Outlook 1');
        insert ofc3;
        Outlook_Forecast__c ofc3qry = [Select Id from Outlook_Forecast__c where Fiscal_Quarter__c = 'FY12Q2'and Region__c = 'EMEA'and Category__c = 'Outlook 1'];
        
        Outlook_Forecast__c ofc4 = new Outlook_Forecast__c(Fiscal_Quarter__c = 'FY12Q2',Region__c = 'EMEA',Category__c = 'Outlook 1');        
        Database.SaveResult sr2 = Database.insert(ofc4,false); 
        system.assertEquals(sr2.isSuccess(), false);
        
        Outlook_Forecast__c ofc5 = new Outlook_Forecast__c(Fiscal_Quarter__c = 'FY12Q2',Region__c = 'EMEA',Category__c = 'Final Outlook');
        insert ofc5;
        Outlook_Forecast__c ofc5qry = [Select Id from Outlook_Forecast__c where Fiscal_Quarter__c = 'FY12Q2'and Region__c = 'EMEA'and Category__c = 'Final Outlook'];
        Outlook_Forecast__c ofc6 = new Outlook_Forecast__c(Fiscal_Quarter__c = 'FY12Q2',Region__c = 'EMEA',Category__c = 'Final Outlook');        
        Database.SaveResult sr3 = Database.insert(ofc6,false);       
        system.assertEquals(sr3.isSuccess(), false); 
        
        Outlook_Forecast__c ofc7 = new Outlook_Forecast__c(Fiscal_Quarter__c = 'FY12Q3',Region__c = 'EMEA',Category__c = 'Final Invoice Amount');
        insert ofc7;
        Outlook_Forecast__c ofc7qry = [Select Id from Outlook_Forecast__c where Fiscal_Quarter__c = 'FY12Q3'and Region__c = 'EMEA'and Category__c = 'Final Invoice Amount'];
        
        Outlook_Forecast__c ofc8 = new Outlook_Forecast__c(Fiscal_Quarter__c = 'FY12Q3',Region__c = 'EMEA',Category__c = 'Final Invoice Amount');        
        Database.SaveResult sr4 = Database.insert(ofc8,false);       
        system.debug('aaaabbb');
        system.assertEquals(sr4.isSuccess(), false); 
        system.debug('aaaa sr4.isSuccess()'+sr4.isSuccess());
        List <Outlook_Forecast_Line_Item__c> lineitemlist = [select Id from Outlook_Forecast_Line_Item__c where Outlook_Forecast__c=:ofc7qry.Id];
        update lineitemlist;
        
        Test.stopTest();
    }
        
    static testMethod void myUnitTest1() {        
        Test.startTest(); 
        createdata();
                       
        Outlook_Forecast__c vbf2 = new Outlook_Forecast__c();
        vbf2.Fiscal_Quarter__c = 'FY12Q1';
        vbf2.Region__c = 'EMEA';
        vbf2.Category__c = 'Outlook 2';        
               
        PageReference  pr2=new PageReference('apex/outLookForecast');
        Test.setCurrentPage(pr2);
        VFCntrlr_OutLookForeCast cntrlr2 = new VFCntrlr_OutLookForeCast(new ApexPages.StandardController(vbf2));
        cntrlr2.showVendors();
        PageReference actualpage2 = cntrlr2.saveOutLookForeCastLineItem();
        Outlook_Forecast__c vbfsaved2 = cntrlr2.myOutLookForeCasts;
        String expected2 = '/'+ vbfsaved2.Id;
        String actual2 = actualpage2.getUrl();
        System.assertEquals(expected2,actual2);
        system.debug('hiiiiiiii2222222222222222222------------actual'+ actual2 +'expected'+expected2);
        cntrlr2.getoutLookForcastLineItemList();
        cntrlr2.getvendorIds();     
        Test.stopTest();
    }
    static testMethod void myUnitTest2() {        
        Test.startTest();  
        createdata();                     
        Outlook_Forecast__c vbf3 = new Outlook_Forecast__c();
        vbf3.Fiscal_Quarter__c = 'FY12Q1';
        vbf3.Region__c = 'EMEA';
        vbf3.Category__c = 'Final Outlook';        
               
        PageReference  pr3=new PageReference('apex/outLookForecast');
        Test.setCurrentPage(pr3);
        VFCntrlr_OutLookForeCast cntrlr3 = new VFCntrlr_OutLookForeCast(new ApexPages.StandardController(vbf3));
        cntrlr3.showVendors();
        PageReference actualpage3 = cntrlr3.saveOutLookForeCastLineItem();
        Outlook_Forecast__c vbfsaved3 = cntrlr3.myOutLookForeCasts;
        String expected3 = '/'+ vbfsaved3.Id;
        String actual3 = actualpage3.getUrl();
        System.assertEquals(expected3,actual3);
        system.debug('hiiiiiiii33333333333333333------------actual'+ actual3 +'expected'+expected3);
        cntrlr3.getoutLookForcastLineItemList();
        cntrlr3.getvendorIds();     
        Test.stopTest();
    }
    static testMethod void myUnitTest3() {        
        Test.startTest();
        createdata();
                        
        Outlook_Forecast__c vbf4 = new Outlook_Forecast__c();
        vbf4.Fiscal_Quarter__c = 'FY12Q1';
        vbf4.Region__c = 'EMEA';
        vbf4.Category__c = 'Final Invoice Amount';        
               
        PageReference  pr4=new PageReference('apex/outLookForecast');
        Test.setCurrentPage(pr4);
        VFCntrlr_OutLookForeCast cntrlr4 = new VFCntrlr_OutLookForeCast(new ApexPages.StandardController(vbf4));
        cntrlr4.showVendors();
        PageReference actualpage4 = cntrlr4.saveOutLookForeCastLineItem();
        Outlook_Forecast__c vbfsaved4 = cntrlr4.myOutLookForeCasts;
        String expected4 = '/'+ vbfsaved4.Id;
        String actual4 = actualpage4.getUrl();
        System.assertEquals(expected4,actual4);
        system.debug('hiiiiiiii4444444444444444------------actual'+ actual4 +'expected'+expected4);
        cntrlr4.getoutLookForcastLineItemList();
        cntrlr4.getvendorIds();    
        
        Outlook_Forecast__c vbf5 = new Outlook_Forecast__c();
        vbf5.Fiscal_Quarter__c = 'FY12Q1';
        vbf5.Region__c = 'EMEA';
        vbf5.Category__c = 'Final Invoice Amount';      
               
        PageReference  pr5=new PageReference('apex/outLookForecast');
        Test.setCurrentPage(pr5);
        VFCntrlr_OutLookForeCast cntrlr5 = new VFCntrlr_OutLookForeCast(new ApexPages.StandardController(vbf5));
        cntrlr5.showVendors();
        PageReference actualpage5 = cntrlr5.saveOutLookForeCastLineItem();  
        
        Test.stopTest();
    }
    
}