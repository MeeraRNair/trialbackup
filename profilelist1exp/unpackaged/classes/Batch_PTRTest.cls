@isTest

public class Batch_PTRTest
{

    public static testmethod void insertPTRForPTTest(){
    Account a=new Account(Master_Group_Affinity_ID__c='2911584790',Name='Master1');
    insert a;
     Account sa4=new Account(Account_ID__c='22222',Name='Salesmotion3');
     insert sa4;
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
         testPartnerTrackObj.Master_Group_Id__c =a.id; //listaccList.get(0).id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = a.Master_Group_Affinity_Id__c;
        testPartnerTrackObj.Partner_Track_AffinityId__c=a.Master_Group_Affinity_Id__c;//'1234';
        insert testPartnerTrackObj;
        list<Partner_Track_Relationship__c> listptrList=new list<Partner_Track_Relationship__c>();
        Partner_Track_Relationship__c pt1 = new Partner_Track_Relationship__c(PTR_AffinityId__c='34554',Sales_Motion_Account_AffinityId__c= '22222',Master_Group_AffinityId__c= '232323',Partner_Track_AffinityId__c = '12344',Is_Processed__c = false);
        Partner_Track_Relationship__c pt2 = new Partner_Track_Relationship__c(PTR_AffinityId__c='3455',Sales_Motion_Account_AffinityId__c= '3412342',Master_Group_AffinityId__c= '12433',Partner_Track_AffinityId__c = '1234',Is_Processed__c = false);
        Partner_Track_Relationship__c pt3 = new Partner_Track_Relationship__c(PTR_AffinityId__c='34556',Sales_Motion_Account_AffinityId__c= '341234',Master_Group_AffinityId__c= '124334',Partner_Track_AffinityId__c = '123',Is_Processed__c = false);
        listptrList.add(pt1);
        listptrList.add(pt2);
        listptrList.add(pt3);
        insert listptrList;
          System.assertNotEquals(pt2.PTR_AffinityId__c,pt3.PTR_AffinityId__c);
    
    
   /* PTRHandler ptrh=new PTRHandler();
        try{ptrh.insertPTRForPT(listptrList);}catch(exception e){}*/
    
    }
    
public static testmethod void handlerPTRupdate(){
  Partner_Request__c request = new Partner_Request__c();
  request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.Org_State__c = 'state';
        request.Org_Postal_Code__c = 'postalcode';      
        request.Address_Line_1__c = 'Address 1';
        request.Address_Line_2__c = 'Address 2';
        request.Address_Line_3__c = 'Address 3';
        request.City__c = 'city';
        request.State__c = 'state';
        request.Postal_Code__c = 'postalcode';
        request.Last_Name__c = 'Test Last Name';
        insert request;
 Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        list<Account> listaccList=new list<Account>();
        Account a=new Account(Master_Group_Affinity_ID__c='232323',Name='Master1');
        Account a1=new Account(Master_Group_Affinity_ID__c='124334',Name='Master2');
        Account a2=new Account(Master_Group_Affinity_ID__c='124322334',Name='Master3');
        Account sa1=new Account(Account_ID__c='3412342',Name='Salesmotion1',RecordTypeId = accRTyId,Partner_Registration__c=request.id);
        Account sa2=new Account(Account_ID__c='22222',Name='Salesmotion2',RecordTypeId = accRTyId);
        Account sa3=new Account(Account_ID__c='34123421',Name='Salesmotion3',RecordTypeId = accRTyId);
        Account sa4=new Account(Account_ID__c='3412342',Name='Salesmotion3',RecordTypeId = accRTyId);
        listaccList.add(a);
        listaccList.add(a1);
        listaccList.add(a2);
        listaccList.add(sa1);
        listaccList.add(sa2);
        listaccList.add(sa3);
        insert listaccList;
       for(Account agl:listaccList){
           agl.isPartner=true;
           }
       update listaccList;
    list<Partner_Track_Relationship__c> listptrList=new list<Partner_Track_Relationship__c>(); 
        Partner_Track_Relationship__c pt1 = new Partner_Track_Relationship__c(PTR_AffinityId__c='34554',Sales_Motion_Account_AffinityId__c= '22222',Master_Group_AffinityId__c= '232323',Partner_Track_AffinityId__c = '12344',Is_Processed__c = false);
        Partner_Track_Relationship__c pt2 = new Partner_Track_Relationship__c(PTR_AffinityId__c='3455',Sales_Motion_Account_AffinityId__c= '3412342',Master_Group_AffinityId__c= '12433',Partner_Track_AffinityId__c = '1234',Is_Processed__c = false);
        Partner_Track_Relationship__c pt3 = new Partner_Track_Relationship__c(PTR_AffinityId__c='34556',Sales_Motion_Account_AffinityId__c= '341234',Master_Group_AffinityId__c= '124334',Partner_Track_AffinityId__c = '123',Is_Processed__c = false);
        listptrList.add(pt1);
        listptrList.add(pt2);
        listptrList.add(pt3);
        insert listptrList;
        map<id,Partner_Track_Relationship__c > mapOldPTR =new map<id,Partner_Track_Relationship__c >();
        mapOldPTR .put(listptrList.get(0).id,listptrList.get(0));
         map<id,Partner_Track_Relationship__c > mapNewPTR =new map<id,Partner_Track_Relationship__c >();
        mapOldPTR .put(listptrList.get(1).id,listptrList.get(1));
        PTRHandler ptrh=new PTRHandler();
        try{ptrh.updatePTR(mapOldPTR,mapNewPTR);}catch(exception e){}
        System.assertNotEquals(pt2.PTR_AffinityId__c,pt3.PTR_AffinityId__c);
    
}
public static testmethod void handlerPTR(){
         Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        list<Account> listaccList=new list<Account>();
        Account a=new Account(Master_Group_Affinity_ID__c='2911584791',Name='Master1');
        Account a1=new Account(Master_Group_Affinity_ID__c='124334',Name='Master2');
        Account a2=new Account(Master_Group_Affinity_ID__c='124322334',Name='Master3');
        Account sa1=new Account(Account_ID__c='341234',Name='Salesmotion1',RecordTypeId = accRTyId);
        Account sa2=new Account(Account_ID__c='22222',Name='Salesmotion2',RecordTypeId = accRTyId);
        Account sa3=new Account(Account_ID__c='3412342',Name='Salesmotion3',RecordTypeId = accRTyId);
        Account sa4=new Account(Account_ID__c='341234',Name='Salesmotion3',RecordTypeId = accRTyId);
        listaccList.add(a);
        listaccList.add(a1);
        listaccList.add(a2);
        listaccList.add(sa1);
        listaccList.add(sa2);
        listaccList.add(sa3);
        insert listaccList;
       for(Account agl:listaccList){
           agl.isPartner=true;
           }
       update listaccList;
       Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c =listaccList[0].id; //listaccList.get(0).id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listaccList[0].Master_Group_Affinity_Id__c;
        testPartnerTrackObj.Partner_Track_AffinityId__c=listaccList[0].Master_Group_Affinity_Id__c;//'1234';
        insert testPartnerTrackObj;
      
       TriggerExecutionController.setSkipAllTriggers(true); 
        Partner_Track__c pt=new Partner_Track__c(Master_Group_Affinity_Id__c = listaccList[0].Master_Group_Affinity_Id__c,Partner_Track_AffinityId__c=listaccList[0].Master_Group_Affinity_Id__c,Primary_Sales_Motion_Affinity_ID__c='123');
        insert pt;
        
         Contact newCont = new Contact(FirstName = 'MyTestContact7653',
                           LastName = 'MyTestContact76523',
                           Account =listaccList.get(0),
                           AccountId =listaccList.get(0).Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_3@dell.com',
                           Fax = '12344567',
                           EligibleTracks__c=testPartnerTrackObj.id+';'+pt.id,
                          // MobilePhone = '0987676534',
                           Last_Operation_Performed__c = 'testing');
                           //Phone = '123453400');
        insert newCont;
        listaccList.get(3).Partner_Track__c=pt.id;
        listaccList.get(3).Master_Group_Id__c=listaccList.get(0).id;
        update listaccList;
         
        TriggerExecutionController.setSkipAllTriggers(false); 
        Test.startTest();
           
     list<string> listsma=new list<string>();
     listsma.add('341234');
     listsma.add('22222');
     list<string> listmaf=new list<string>();
     listmaf.add('232323');
     listmaf.add('124334');
     list<string> listpta=new list<string>();
     listpta.add('1234');
     listpta.add('22222');
     TriggerExecutionController.setSkipAllTriggers(true); 
     
     try{PTRHandler.grantRevokeAccessToSM(listsma,listmaf,listpta,'test');}catch(exception e){}
      System.assertEquals(newCont.FirstName,'MyTestContact7653');
     TriggerExecutionController.setSkipAllTriggers(false); 
    Test.stopTest();
    }
    public static testmethod void batchPTR(){
         Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        list<Account> listaccList=new list<Account>();
        Account a=new Account(Master_Group_Affinity_ID__c='232323',Name='Master1');
        Account a1=new Account(Master_Group_Affinity_ID__c='12433',Name='Master2');
        Account a2=new Account(Master_Group_Affinity_ID__c='124322334',Name='Master3');
        Account sa1=new Account(Account_ID__c='341234',Name='Salesmotion1',RecordTypeId = accRTyId);
        Account sa2=new Account(Account_ID__c='22222',Name='Salesmotion2',RecordTypeId = accRTyId);
        Account sa3=new Account(Account_ID__c='3412342',Name='Salesmotion3',RecordTypeId = accRTyId);
        Account sa4=new Account(Account_ID__c='341234',Name='Salesmotion3',RecordTypeId = accRTyId);
        listaccList.add(a);
        listaccList.add(a1);
        listaccList.add(a2);
        listaccList.add(sa1);
        listaccList.add(sa2);
        listaccList.add(sa3);
        insert listaccList;
       for(Account agl:listaccList){
           agl.isPartner=true;
           }
           
        
       update listaccList;
       Contact newCont = new Contact(FirstName = 'MyTestContact7653',
                           LastName = 'MyTestContact76523',
                           AccountId =listaccList.get(0).Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_3@dell.com',
                           Fax = '12344567',
                          // MobilePhone = '0987676534',
                           Last_Operation_Performed__c = 'testing');
                           //Phone = '123453400');
       // insert newCont;
       
        Partner_Track__c pt=new Partner_Track__c(Partner_Track_AffinityId__c='1234',Primary_Sales_Motion_Affinity_ID__c='3412342443');
        insert pt;

       list<Partner_Track_Relationship__c> listptrList1=new list<Partner_Track_Relationship__c>(); 
        /* list<Partner_Track_Relationship__c> listptrList1=new list<Partner_Track_Relationship__c>(); 
        Partner_Track_Relationship__c pt1 = new Partner_Track_Relationship__c(PTR_AffinityId__c='34554',Sales_Motion_Account_AffinityId__c= '22222',Master_Group_AffinityId__c= '232323',Partner_Track_AffinityId__c = '12344',Is_Processed__c = false);
        Partner_Track_Relationship__c pt2 = new Partner_Track_Relationship__c(PTR_AffinityId__c='3455',Sales_Motion_Account_AffinityId__c= '3412342',Master_Group_AffinityId__c= '12433',Partner_Track_AffinityId__c = '1234',Is_Processed__c = false);
        Partner_Track_Relationship__c pt3 = new Partner_Track_Relationship__c(PTR_AffinityId__c='34556',Sales_Motion_Account_AffinityId__c= '34123423',Master_Group_AffinityId__c= '124334',Partner_Track_AffinityId__c = '123',Is_Processed__c = false);
        listptrList.add(pt1);
        listptrList.add(pt2);
        listptrList.add(pt3);
        insert listptrList;
        listptrList.get(0).Sales_Motion_Account_AffinityId__c='222222';
        listptrList.get(1).Master_Group_AffinityId__c='124334';
        listptrList.get(2).Partner_Track_AffinityId__c ='1234';
        listptrList.get(0).Is_Processed__c=true;
        update listptrList;*/
         Partner_Track_Relationship__c pt4 = new Partner_Track_Relationship__c(PTR_AffinityId__c='34557',Sales_Motion_Account_AffinityId__c= '3412342',Master_Group_AffinityId__c= '124322334',Partner_Track_AffinityId__c = '1234',Is_Processed__c = false);
         Partner_Track_Relationship__c pt5 = new Partner_Track_Relationship__c(PTR_AffinityId__c='34558',Sales_Motion_Account_AffinityId__c= '3412342',Master_Group_AffinityId__c= '124322334',Partner_Track_AffinityId__c = '1234',Is_Processed__c = false);
        listptrList1.add(pt4); 
        listptrList1.add(pt5);
        insert listptrList1;
        listptrList1.get(0).Sales_Motion_Account_AffinityId__c='3412342';
        listptrList1.get(1).Master_Group_AffinityId__c='124322334';
        listptrList1.get(1).Partner_Track_AffinityId__c ='1234';
        listptrList1.get(0).Is_Processed__c=true;
        update listptrList1;
        Test.startTest();
           map<id,Partner_Track_Relationship__c> mapPtr=new map<id,Partner_Track_Relationship__c>();
           mapPtr.putall(listptrList1);
     Batch_PTR obj = new Batch_PTR();
     DataBase.executeBatch(obj); 
      PTRHandler pth=new PTRHandler();
    // pth.insertPTRForPT(listptrList1);
     pth.onBoardNewSM(mapPtr);
     pth.mailToMasterGroupAdmin(listptrList1,mapPtr);
     list<string> listsma=new list<string>();
     listsma.add('341234');
     listsma.add('22222');
     list<string> listmaf=new list<string>();
     listmaf.add('232323');
     listmaf.add('124334');
     list<string> listpta=new list<string>();
     listpta.add('1234');
     listpta.add('22222');
     try{
         PTRHandler.grantRevokeAccessToSM(listsma,listmaf,listpta,'test');
        }catch(exception e){}
         System.assertEquals(pt4.PTR_AffinityId__c,'34557');
         System.assertEquals(pt5.PTR_AffinityId__c,'34558');
        
    Test.stopTest();
      System.assertEquals(pt4.PTR_AffinityId__c,'34557');
    }
     @isTest static void executeTest(){ 
SchedulableContext sc = null;
           Test.StartTest();
    Batch_PTR_Scheduler sch1 = new Batch_PTR_Scheduler();
    String strsch = '0 0 23 * * ?';
     Batch_PTR bat = new Batch_PTR();
     
     DataBase.executeBatch(bat,50);
     sch1.execute(sc);
     List<AsyncApexJob> listBatchjobs = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
       System.assertEquals(2, listBatchjobs.size(), 'expecting two apex batch job');
     Test.stopTest();
}
   
}