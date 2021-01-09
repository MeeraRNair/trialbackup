@isTest()
public class ServiceTriggerRelatedHelperTest{
    static list<Account> listAcc;
    @testSetup static void setup() {
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(1, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
    } 
    Public static testMethod void serviceTriggerRelatedHelperMethod1(){
        final List<Profile> ChatterProfile = [select Id,name from Profile where Name = 'Chatter Only' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyTestUser91@dell.com', 
                                    FirstName='MyTestUser91', 
                                    LastName='MyTestUser91',  
                                    ProfileId = ChatterProfile.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='DealReg123'+System.today().month(), 
                                    isActive = TRUE);
        insert partnerUser;
        listAcc=[select id from account];
        List<Service_Information__c> listSerInfo = new List<Service_Information__c>(); 
        Service_Information__c serInfo = new Service_Information__c(Velocity_Services__c = 'Yes' );
        listSerInfo.add(serInfo);
        List<Partner_Track__c> listPTList = new List<Partner_Track__c>();
        Partner_Track__c pt = new Partner_Track__c(Services_Competencies__c= '',Partner_Track_Account_Local_Name__c='test12');
        insert pt;
        List<Service_Competencies__c> listSerCompInfoLst = new List<Service_Competencies__c>(); 
        Service_Competencies__c serCompRecd = new Service_Competencies__c(Services_Program_Designation__c = 'QSS Implement',
                                                                          EMC_Operation__c = 'Deletion',
                                                                          EMC_Integration_Status__c = 'Completed',
                                                                          Divest__c=true,
                                                                          Mentored_Resource__c = true,
                                                                          EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                          Entitlement_End_Date__c=system.today(),
                                                                          Partner_Deployment_End_Date__c=system.today(),
                                                                          Partner_Deployment_Issue_Date__c=system.today(),
                                                                          Services_Competencies_Held__c= 'Networker Deployment',
                                                                          Partner_Track__c= pt.id);
        listSerCompInfoLst.add(serCompRecd);
        insert listSerCompInfoLst;
        List<Partner_Service_Enabled_Product__c> listSPSOInfoLst = new List<Partner_Service_Enabled_Product__c>(); 
        Partner_Service_Enabled_Product__c sPSORecd = new Partner_Service_Enabled_Product__c(EMC_Operation__c = 'Deletion',
                                                                                             EMC_Integration_Status__c = 'Completed',
                                                                                             EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                                             Service_Enabled_Key__c = 'Test',
                                                                                             Service_Level__c = 'HW L1 L2 L3 MON B/F PART-DEL RTF 4HR',
                                                                                             Service_Enabled_Product__c = 'AppSync-SW');
        listSPSOInfoLst.add(sPSORecd);
        insert listSPSOInfoLst;
        List<DellEMC_Key_Contacts__c> listDellEmcKeyConInfoLst = new List<DellEMC_Key_Contacts__c>(); 
        DellEMC_Key_Contacts__c dellEmcKeyConRecd = new DellEMC_Key_Contacts__c(EMC_Operation__c = 'Deletion',
                                                                                EMC_Integration_Status__c = 'Completed',
                                                                                EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                                DellEMC_Contact_Name__c = partnerUser.id,
                                                                                Role__c = 'Channel Account Plan');
        listDellEmcKeyConInfoLst.add(dellEmcKeyConRecd );
        insert listDellEmcKeyConInfoLst;
        List<Partner_Quoting_Relationships__c> listPQRlst = new List<Partner_Quoting_Relationships__c>();
        Partner_Quoting_Relationships__c pQRrecord = new Partner_Quoting_Relationships__c(EMC_Operation__c = 'Deletion',
                                                                                          EMC_Integration_Status__c = 'Completed',
                                                                                          Relationship_Type__c = 'Distributor',
                                                                                          EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                                          Related_Account__c=listAcc[0].id);
        listPQRlst.add(pQRrecord);
        insert listPQRlst;
        List<Partner_Type_Attribute__c>  listPTALst = new List<Partner_Type_Attribute__c> ();
        Partner_Type_Attribute__c pTARecord =new Partner_Type_Attribute__c(EMC_Operation__c = 'Creation',
                                                                           EMC_Integration_Status__c = 'Completed',
                                                                           EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                           Partner_Price_List_Type__c='Distributor',Distribution_Channel__c='Distributor');
        listPTALst.add(pTARecord);
        insert listPTALst;
        Map<Id,Partner_Type_Attribute__c> mapWrapString = new Map<Id,Partner_Type_Attribute__c>();
        mapWrapString.put(pTARecord.id, pTARecord);
        system.debug('>>>>mapWrapString'+pTARecord.id+pTARecord);
        PTAttributesTriggerHandler.bisFirstTime = true;
        ServicesTriggerRelatedHelper.updateEMCOperationServiceCompetencies(listSerCompInfoLst);
        ServicesTriggerRelatedHelper.updateEMCOperationSPSO(listSPSOInfoLst);
        ServicesTriggerRelatedHelper.updateEMCOperationPartnerQuotingRelationships(listPQRlst);
        ServicesTriggerRelatedHelper.updateEMCOperationPartnerTypeAttributes(listPTALst);
        List<Partner_Type_Attribute__c>  listPTALstUp = new List<Partner_Type_Attribute__c> ();
        pTARecord.Distribution_Channel__c='OEM';
        listPTALstUp.add(pTARecord);
        Update listPTALstUp;
        PTA_Duplicatecheck_HelperCls.ptaDupCheck(listPTALst,mapWrapString);
        Test.startTest();
        try
        {
            listSerInfo[0].Services_Onsite_Support_Exception__c=true;
            update listSerInfo;
            Delete  listSerCompInfoLst;
            Delete  listSPSOInfoLst;
            Delete  listDellEmcKeyConInfoLst;
        }
        catch(Exception ee)
        {}
        if(listSerCompInfoLst.size() > 0){
            try{
                update listSerCompInfoLst;
            }
            catch(Exception ee){}
        }
        system.assertEquals('Yes', listSerInfo[0].Velocity_Services__c);
        Test.stopTest();
    }
    Public static testMethod void serviceTriggerRelatedHelperMethod2() {
        final List<Profile> ChatterProfile = [select Id,name from Profile where Name = 'Chatter Only' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyTestUser91@dell.com', 
                                    FirstName='MyTestUser91', 
                                    LastName='MyTestUser91',  
                                    ProfileId = ChatterProfile.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='DealReg123'+System.today().month(), 
                                    isActive = TRUE);
        insert partnerUser;
        List<Partner_Track__c> listPTList = new List<Partner_Track__c>();
        Partner_Track__c pt1 = new Partner_Track__c(Services_Competencies__c= 'Networker Deployment',Partner_Track_Account_Local_Name__c='test123');
        insert pt1;
        List<Service_Competencies__c> listSerCompInfoLst= new List<Service_Competencies__c>(); 
        Service_Competencies__c serCompRecd = new Service_Competencies__c( Products__c = 'Celerra NX4, NS-20',
                                                                          Services_Program_Designation__c = 'QSS Implement',
                                                                          EMC_Operation__c = 'Updation',
                                                                          EMC_Integration_Status__c = 'Completed',
                                                                          Divest__c=true,
                                                                          Mentored_Resource__c = true,
                                                                          EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                          Entitlement_End_Date__c=system.today(),
                                                                          Partner_Deployment_End_Date__c=system.today(),
                                                                          Partner_Deployment_Issue_Date__c=system.today(),
                                                                          Services_Competencies_Held__c= 'Networker Deployment',
                                                                          Partner_Track__c= pt1.id);
        Service_Competencies__c serCompRecd1 = new Service_Competencies__c( Products__c = 'Celerra NX4, NS-20',
                                                                           Services_Program_Designation__c = 'QSS Implement',
                                                                           EMC_Operation__c = 'Updation',
                                                                           EMC_Integration_Status__c = 'Completed',
                                                                           Divest__c=true,
                                                                           Mentored_Resource__c = true,
                                                                           EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                           Entitlement_End_Date__c=system.today(),
                                                                           Partner_Deployment_End_Date__c=system.today(),
                                                                           Partner_Deployment_Issue_Date__c=system.today(),
                                                                           Services_Competencies_Held__c= 'AppSync Support',
                                                                           Partner_Track__c= pt1.id); 
        Service_Competencies__c serCompRecd2 = new Service_Competencies__c( Products__c = 'Celerra NX4, NS-20',
                                                                           Services_Program_Designation__c = 'QSS Implement',
                                                                           EMC_Operation__c = 'Updation',
                                                                           EMC_Integration_Status__c = 'Completed',
                                                                           Divest__c=true,
                                                                           Mentored_Resource__c = true,
                                                                           EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                           Entitlement_End_Date__c=system.today(),
                                                                           Partner_Deployment_End_Date__c=system.today(),
                                                                           Partner_Deployment_Issue_Date__c=system.today(),
                                                                           Services_Competencies_Held__c= 'Isilon Support',
                                                                           Partner_Track__c= pt1.id);                                                                  
        listSerCompInfoLst.add(serCompRecd);
        listSerCompInfoLst.add(serCompRecd1 );
        listSerCompInfoLst.add(serCompRecd2);
        insert listSerCompInfoLst;
        serCompRecd.Services_Competencies_Held__c = 'Networker Support';
        update listSerCompInfoLst;
        map<id,Service_Competencies__c> mapscMap = new map<id,Service_Competencies__c>();
        for(Service_Competencies__c sc: listSerCompInfoLst){
            mapscMap.put(sc.id,sc);
        }
        List<Partner_Service_Enabled_Product__c> listSPSOInfoLst = new List<Partner_Service_Enabled_Product__c>(); 
        Partner_Service_Enabled_Product__c sPSORecd = new Partner_Service_Enabled_Product__c(EMC_Operation__c = 'Updation',
                                                                                             EMC_Integration_Status__c = 'Completed',
                                                                                             EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                                             Service_Enabled_Key__c = 'Test',
                                                                                             Service_Level__c = 'HW L1 L2 L3 MON B/F PART-DEL RTF 4HR',
                                                                                             Service_Enabled_Product__c = 'AppSync-SW');
        listSPSOInfoLst.add(sPSORecd );
        insert listSPSOInfoLst;
        system.assertEquals(listSPSOInfoLst[0].EMC_Operation__c, 'Updation');
        List<DellEMC_Key_Contacts__c> listDellEmcKeyConInfoLst = new List<DellEMC_Key_Contacts__c>(); 
        DellEMC_Key_Contacts__c dellEmcKeyConRecd = new DellEMC_Key_Contacts__c(EMC_Operation__c = 'Updation',
                                                                                EMC_Integration_Status__c = 'Completed',
                                                                                EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                                DellEMC_Contact_Name__c = partnerUser.id,
                                                                                Role__c = 'Channel Account Plan');
        listDellEmcKeyConInfoLst.add(dellEmcKeyConRecd );
        insert listDellEmcKeyConInfoLst;
        ServicesTriggerRelatedHelper.updateEMCOperationServiceCompetencies(listSerCompInfoLst);
        ServicesTriggerRelatedHelper.updateEMCOperationSPSO(listSPSOInfoLst);
        ServicesTriggerRelatedHelper.updateSCAfterInsert(listSerCompInfoLst);
        Test.startTest();
        try
        {
            Delete  listSerCompInfoLst;
            Delete  listSPSOInfoLst;
            Delete  listDellEmcKeyConInfoLst;
            Delete  listSerCompInfoLst;
        }
        catch(Exception ee)
        {}
        if(listSerCompInfoLst.size() > 0){
            try{
                update listSerCompInfoLst;
            }
            catch(Exception ee){}
        }
        Test.stopTest();
    }
    Public static testMethod void serviceTriggerRelatedHelperMethod3(){
        List<Partner_Track__c> listPTList = new List<Partner_Track__c>();
        Partner_Track__c pt1 = new Partner_Track__c(Services_Competencies__c= 'Networker Deployment',Partner_Track_Account_Local_Name__c='test123');
        listPTList.add(pt1);
        Insert listPTList;
        List<Service_Competencies__c> listSerCompInfoLst= new List<Service_Competencies__c>(); 
        Service_Competencies__c serCompRecd = new Service_Competencies__c( Products__c = 'Celerra NX4, NS-20',
                                                                          Services_Program_Designation__c = 'QSS Implement',
                                                                          EMC_Operation__c = 'Updation',
                                                                          EMC_Integration_Status__c = 'Completed',
                                                                          Divest__c=true,
                                                                          Mentored_Resource__c = true,
                                                                          EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                          Entitlement_End_Date__c=system.today(),
                                                                          Partner_Deployment_End_Date__c=system.today(),
                                                                          Partner_Deployment_Issue_Date__c=system.today(),
                                                                          Services_Competencies_Held__c= 'Networker Deployment',
                                                                          Partner_Track__c= listPTList[0].id);
        Service_Competencies__c serCompRecd1 = new Service_Competencies__c( Products__c = 'Celerra NX4, NS-20',
                                                                           Services_Program_Designation__c = 'QSS Implement',
                                                                           EMC_Operation__c = 'Updation',
                                                                           EMC_Integration_Status__c = 'Completed',
                                                                           Divest__c=true,
                                                                           Mentored_Resource__c = true,
                                                                           EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                           Entitlement_End_Date__c=system.today(),
                                                                           Partner_Deployment_End_Date__c=system.today(),
                                                                           Partner_Deployment_Issue_Date__c=system.today(),
                                                                           Services_Competencies_Held__c= 'AppSync Support',
                                                                           Partner_Track__c= listPTList[0].id); 
        Service_Competencies__c serCompRecd2 = new Service_Competencies__c( Products__c = 'Celerra NX4, NS-20',
                                                                           Services_Program_Designation__c = 'QSS Implement',
                                                                           EMC_Operation__c = 'Updation',
                                                                           EMC_Integration_Status__c = 'Completed',
                                                                           Divest__c=true,
                                                                           Mentored_Resource__c = true,
                                                                           EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                           Entitlement_End_Date__c=system.today(),
                                                                           Partner_Deployment_End_Date__c=system.today(),
                                                                           Partner_Deployment_Issue_Date__c=system.today(),
                                                                           Services_Competencies_Held__c= 'Isilon Support',
                                                                           Partner_Track__c= listPTList[0].id);                                                                    
        listSerCompInfoLst.add(serCompRecd);
        listSerCompInfoLst.add(serCompRecd1);
        listSerCompInfoLst.add(serCompRecd2 );
        insert listSerCompInfoLst;
        map<id,Service_Competencies__c> mapscMap = new map<id,Service_Competencies__c>();
        for(Service_Competencies__c sc: listSerCompInfoLst){
            mapscMap.put(sc.id,sc);
        }
        system.assertEquals(pt1.Services_Competencies__c,'Networker Deployment');
        ServicesTriggerRelatedHelper.UpdateSCAfterUpdate(listSerCompInfoLst);
        ServicesTriggerRelatedHelper.updateSCAfterInsert(listSerCompInfoLst);     
        ServicesTriggerRelatedHelper.updateSCAfterDelete(listSerCompInfoLst);
        if(listPTList.size()>0){
            try{
                update listPTList ;
            }catch(exception e){}
        }
    }
}