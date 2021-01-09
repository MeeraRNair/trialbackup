@isTest
private class VFCntrlr_VolumeBasedForecastTest {
    
    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static Volume_Based_Forecast__c savedVBC = new Volume_Based_Forecast__c();
    public static Map <String,RecordType> vendorRTmap = new Map <String,RecordType>();
    public static List <Outlook_Forecast__c> olfc = new List <Outlook_Forecast__c>();
    public static List <Outlook_Forecast_Line_Item__c> line = new List <Outlook_Forecast_Line_Item__c>();
    public static Map <String,RecordType> mpRTmap = new Map <String,RecordType>();
    public static Marketing_Plan__c mp = new Marketing_Plan__c();
    public static List <MDF_Program__c> mdfpgmlist = new List <MDF_Program__c>{};
    public static List <Associated_Programs_Vendors__c> mpapvList = new List <Associated_Programs_Vendors__c>();
    public static Map <String,RecordType> fcRTmap = new Map <String,RecordType>();
    public static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like'%MDF Program Owners%' limit 1];    
    public static Volume_Based_Forecast__c vbcexisting = new Volume_Based_Forecast__c();
    public static User u1 = new User();
    public static Marketing_Plan__c mpalacarte= new Marketing_Plan__c();
    public static List<Marketing_Plan__c> mpList= new List<Marketing_Plan__c>();
    public static void createdata(){
        
        for(RecordType rtElt:[Select Name,Id From RecordType where sObjectType='Vendor__c']){   
                     vendorRTmap.put(rtElt.Name,rtElt);            
        }
        for(RecordType rtElt:[Select Name,Id From RecordType where sObjectType='Marketing_Plan__c']){   
                     mpRTmap.put(rtElt.Name,rtElt);            
        }
        for(RecordType rtElt:[Select Name,Id From RecordType where sObjectType='Volume_Based_Forecast__c']){   
                     fcRTmap.put(rtElt.Name,rtElt);            
        }
        
        u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
        insert u1;
        //creating a parent vendor
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
        parentVendor.Partner_Status__c='Active';
        parentVendor.recordTypeId=vendorRTmap.get('Vendor').Id;
        
        insert parentVendor;
        
        // creating a sub vendor
        subvendor.Parent_Vendor__c=parentVendor.Id;
       //subvendor.Name='TestSubVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subvendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
        subvendor.Partner_Status__c='Active';
        subvendor.Partner_Type__c='Value';
        subvendor.Product_Category__c='Networking';
        subvendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
        subvendor.recordTypeId= vendorRTmap.get('Sub Vendor').Id;
        
        insert subvendor;
       
        Outlook_Forecast__c olfc1 =  new Outlook_Forecast__c(Name='one', Fiscal_Quarter__c ='FY12Q4', Region__c='EMEA', Category__c='Outlook 1');
        olfc.add(olfc1);
        Outlook_Forecast__c olfc2 =  new Outlook_Forecast__c(Name='two', Fiscal_Quarter__c ='FY12Q4', Region__c='EMEA', Category__c='Outlook 2');
        olfc.add(olfc2);
        Outlook_Forecast__c olfc3 =  new Outlook_Forecast__c(Name='three', Fiscal_Quarter__c ='FY12Q4', Region__c='EMEA', Category__c='Final Outlook');
        olfc.add(olfc3);
        Outlook_Forecast__c olfc4 =  new Outlook_Forecast__c(Name='four', Fiscal_Quarter__c ='FY12Q4', Region__c='EMEA', Category__c='Final Invoice Amount');
        olfc.add(olfc4);
        
        insert olfc;
        
        Outlook_Forecast_Line_Item__c line1 = new Outlook_Forecast_Line_Item__c(Vendor__c =subvendor.Id, LE__c=100, CSMR__c=100, SMB__c=100, PUB__c=100, Outlook_Forecast__c=olfc[0].Id);
        line.add(line1);
        Outlook_Forecast_Line_Item__c line2 = new Outlook_Forecast_Line_Item__c(Vendor__c =subvendor.Id, LE__c=100, CSMR__c=100, SMB__c=100, PUB__c=100, Outlook_Forecast__c=olfc[1].Id);
        line.add(line2);
        Outlook_Forecast_Line_Item__c line3 = new Outlook_Forecast_Line_Item__c(Vendor__c =subvendor.Id, LE__c=100, CSMR__c=100, SMB__c=100, PUB__c=100, Outlook_Forecast__c=olfc[2].Id);
        line.add(line3);
        Outlook_Forecast_Line_Item__c line4 = new Outlook_Forecast_Line_Item__c(Vendor__c =subvendor.Id, LE__c=100, CSMR__c=100, SMB__c=100, PUB__c=100, Outlook_Forecast__c=olfc[3].Id);
        line.add(line4);
        
        insert line;
        
        mp.name='MP-001';
        mp.Vendor__c=subvendor.Id;
        mp.Fiscal_Quarter__c='FY12Q4';
        mp.Region__c='EMEA';
        mp.Contract_Type__c='Volume Based';
        mp.RecordTypeId=mpRTmap.get('Volume Based Marketing Plan').Id;  
        mp.Currency_Code__c='INR';  
        //insert mp; 
        mpList.add(mp);
        
        
        mpalacarte.name='MP-002';
        mpalacarte.Vendor__c=subvendor.Id;
        mpalacarte.Fiscal_Quarter__c='FY12Q4';
        mpalacarte.Region__c='EMEA';
        mpalacarte.Contract_Type__c='Ala Carte';
        mpalacarte.RecordTypeId=mpRTmap.get('Ala Carte Marketing Plan').Id;  
        mpalacarte.Currency_Code__c='INR';     
        //insert mpalacarte; 
        mpList.add(mpalacarte);
        
        insert mpList;
        
        for(Integer i=0;i<3;i++){
            MDF_Program__c pgm = new MDF_Program__c();
            pgm.Name = 'Name'+i;
            mdfpgmlist.add(pgm); 
            pgm.Program_Owner__c=u1.Id;
            pgm.POP_Owner__c=u1.Id;
            pgm.Fiscal_Quarter__c='FY12Q4';
        }
        insert mdfpgmlist;
        
        Associated_Programs_Vendors__c apv1 = new Associated_Programs_Vendors__c(MDF_Program__c = mdfpgmlist[0].Id,      
                                                                                 Status__c = 'Accepted',    
                                                                                 Accounting_Treatment__c = 'COGS Offset',
                                                                                 POP_Status__c='Not Executed',
                                                                                 POP_Status_Reason__c='Vendor Absent – Charge',
                                                                                 Invoice_Amount__c=10 , 
                                                                                 Vendor__c = subvendor.Id,
                                                                                 LE__c=0,CSMR__c=0,SMB__c=0,PUB__c=0,Marketing_Plan__c = mpList[0].Id,
                                                                                 Employee_Cost_Center__c = '1234-5678-901220');
        mpapvList.add(apv1);   
        
        Associated_Programs_Vendors__c apv2 = new Associated_Programs_Vendors__c(MDF_Program__c = mdfpgmlist[1].Id,      
                                                                                 Status__c = 'Accepted',    
                                                                                 Accounting_Treatment__c = 'COGS Offset',
                                                                                 Vendor__c = subvendor.Id,
                                                                                 LE__c=1,CSMR__c=1,SMB__c=1,PUB__c=1,Marketing_Plan__c = mpList[1].Id,
                                                                                 Employee_Cost_Center__c = '1234-5678-901221');
        mpapvList.add(apv2);
        
        Associated_Programs_Vendors__c apv3 = new Associated_Programs_Vendors__c(MDF_Program__c = mdfpgmlist[2].Id,      
                                                                                 Status__c = 'Accepted',    
                                                                                 Accounting_Treatment__c = 'COGS Offset',
                                                                                 Vendor__c = subvendor.Id,
                                                                                 LE__c=2,CSMR__c=2,SMB__c=2,PUB__c=2,Marketing_Plan__c = mpList[1].Id,
                                                                                 Employee_Cost_Center__c = '1234-5678-901222');
        mpapvList.add(apv3);
       
        insert mpapvList;
        
        vbcexisting.Sub_Vendor__c = subvendor.Id;
        vbcexisting.Fiscal_Quarter__c = 'FY12Q3';
        vbcexisting.Region__c = 'EMEA';
        vbcexisting.Volume_Based__c = 10;
        vbcexisting.Volume_Based_Forecast_filed__c = 100000;
        vbcexisting.CSMR__c = 25;
        vbcexisting.LE__c = 25;
        vbcexisting.PUB__c = 25;
        vbcexisting.SMB__c = 25;
        vbcexisting.Name = 'First';
        vbcexisting.RecordTypeId = fcRTmap.get('Volume Based').Id;
        insert vbcexisting;
        
    }
    
    static testMethod void myUnitTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        createdata();
        
        Test.startTest();
        Volume_Based_Forecast__c vbc = new Volume_Based_Forecast__c();
        vbc.Sub_Vendor__c = subvendor.Id;
        vbc.Fiscal_Quarter__c = 'FY12Q4';
        vbc.Region__c = 'EMEA';
        vbc.Volume_Based__c = 10;
        vbc.Volume_Based_Forecast_filed__c = 100000;
        vbc.CSMR__c = 25;
        vbc.LE__c = 25;
        vbc.PUB__c = 25;
        vbc.SMB__c = 25;
        vbc.Name = 'First';
        vbc.RecordTypeId = fcRTmap.get('Volume Based').Id;
        
        //modified
        PageReference  pr=new PageReference('apex/volumebasedForeCastNewPage?RecordType='+fcRTmap.get('Volume Based').Id);
        Test.setCurrentPage(pr);
        VFCntrlr_VolumeBasedForecast cntrlr = new VFCntrlr_VolumeBasedForecast(new ApexPages.StandardController(vbc));
        PageReference redirectUrl=cntrlr.redirect();
        PageReference savedpage = cntrlr.saveObj();
        
        vbc.CSMR__c=30;
        vbc.CSMR__c=25;
        vbc.Volume_Based_Forecast_filed__c=100050;
        vbc.CSMR__c=30;
        vbc.LE__c=20;
        cntrlr.saveObj();
        cntrlr.getNewObj();
        
        Volume_Based_Forecast__c savedvbcquery=[Select Id,Sub_Vendor__c,Fiscal_Quarter__c,Region__c,Volume_Based__c,Volume_Based_Forecast_filed__c,RecordTypeId,Name from Volume_Based_Forecast__c where Sub_Vendor__c=:subvendor.Id and Region__c=:'EMEA' and Fiscal_Quarter__c = 'FY12Q4' and RecordTypeId =:fcRTmap.get('Volume Based').Id];      
        
        PageReference expectedpage = new PageReference('/apex/volumebasedForeCastViewPage?id='+savedvbcquery.Id);
        Test.setCurrentPage(expectedpage);
        
        MDF_Program_Wish_List__c mywishlist = new MDF_Program_Wish_List__c();
        mywishlist.MDF_Forecast__c=savedvbcquery.Id;
        mywishlist.MDF_Program__c=mdfpgmlist[1].Id;
        insert mywishlist;
     
        cntrlr.newWishlist();
        cntrlr.wislistId=mywishlist.Id;
        cntrlr.deleteWishlist();
        
        cntrlr.redirectViewPage();
        PageReference pr1 = new PageReference('apex/volumebasedForeCastNewPage?RecordType='+fcRTmap.get('Ala Carte').Id);
        Test.setCurrentPage(pr1);
        cntrlr.redirect();
        
        Volume_Based_Forecast__c alcfc = new Volume_Based_Forecast__c();
        alcfc.Sub_Vendor__c = subvendor.Id;
        alcfc.Fiscal_Quarter__c = 'FY12Q4';
        alcfc.Region__c = 'APJ';
        alcfc.AlaCarte_MDF_Forecast_CSMR__c=1;
        alcfc.AlaCarte_MDF_Forecast_LE__c=2;
        alcfc.AlaCarte_MDF_Forecast_PUB__c=3;
        alcfc.AlaCarte_MDF_Forecast_SMB__c=4;
        alcfc.Name = 'First';
        alcfc.RecordTypeId=fcRTmap.get('Ala Carte').Id;
        insert alcfc;
        Volume_Based_Forecast__c alcfcquery =[Select Id from Volume_Based_Forecast__c where Sub_Vendor__c =:subvendor.Id and Fiscal_Quarter__c = 'FY12Q4'and Region__c = 'APJ'and RecordTypeId=:fcRTmap.get('Ala Carte').Id];
        PageReference pr2 = new PageReference('/apex/volumebasedForeCastViewPage?id='+alcfcquery.Id);
        Test.setCurrentPage(pr2);
        cntrlr.redirectViewPage();
        cntrlr.getNewObj();
        PageReference pr3 = new PageReference('/apex/volumebasedForeCastViewPage?id='+savedvbcquery.Id);
        Test.setCurrentPage(pr);
        VFCntrlr_VolumeBasedForecast cntrlr2 = new VFCntrlr_VolumeBasedForecast(new ApexPages.StandardController(savedvbcquery));
        cntrlr2.myVBFrec.Fiscal_Quarter__c='FY12Q3';
        cntrlr2.saveObj();
        line[3].CSMR__c=200;
        update line;
        alcfc.Region__c='EMEA';
        update alcfc;
        alcfc.Region__c='Americas';
        update alcfc;
        mpapvList[2].Marketing_Plan__c=mpList[1].Id;
        update mpapvList[2];
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}