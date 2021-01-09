@isTest
private class PartnerCertDataStructuresTest{
  static list<Course__c>  listCourse;
  static list<Account> listAcc;
  static list<contact> listCon;
  static list<Demo_Unit__c> listDemo;
  static list<Demo_Unit_Setup__c> listDemoset;
  static list<Partner_Course__c> listpartnercourse;
  static list<Certification_Criteria_Setup__c> listcertCriteriaSetup;
  static list<Certification_Requirement_Setup__c> listcertReqSetup;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1,'Partner Account');
        listAccTDF[0].status__c = 'Active';
        listAccTDF[0].Account_Country_Code__c='US';
        listAccTDF[0].Partner_Relationship__c='Registered';     
        insert listAccTDF;
        system.debug('listAccTDF>>>>>'+listAccTDF);
        list<contact> listconTDF = TestDataFactory.createNContacts(1);
        listconTDF[0].accountid = listAccTDF[0].id;
        insert listconTDF;
        List<Demo_Unit_Setup__c> listDemosetupTDF =  TestDataFactory.createNDemoUnitSetup(1);
        insert listDemosetupTDF;
        system.debug('listDemosetupTDF>>>>'+listDemosetupTDF);
        list<Demo_Unit__c> listDemoTDF = TestDataFactory.createNDemounit(2);
        listDemoTDF[0].Demo_Unit_Setup__c = listDemosetupTDF[0].Id;
        listDemoTDF[0].Partner_Account_Name__c = listAccTDF[0].id;
        listDemoTDF[0].TSR_Name__c = 'Doyle';
        listDemoTDF[0].Contact_Name__c = 'Doyle';
        listDemoTDF[1].Demo_Unit_Setup__c = listDemosetupTDF[0].Id;
        listDemoTDF[1].Partner_Account_Name__c = listAccTDF[0].id;
        listDemoTDF[1].TSR_Name__c = 'Doyle';
        listDemoTDF[1].Contact_Name__c = 'Doyle';
       insert listDemoTDF; 
        system.debug('listDemoTDF>>>>'+listDemoTDF);
        list<Course__c>  listCourseTDF = TestDataFactory.createNCourse(1);
        insert listCourseTDF;
        system.debug('listCourseTDF>>>'+listCourseTDF);
        List<Partner_Course__c> listpartnercourseTDF =  TestDataFactory.createNPartnerCourse(2);
        listpartnercourseTDF[0].Contact__c = listConTDF[0].id;
        listpartnercourseTDF[0].Account__c = listAccTDF[0].id;
        listpartnercourseTDF[0].Course__c = listCourseTDF[0].id;
        listpartnercourseTDF[0].Course_Completed_Date__c = System.today()-7;
        listpartnercourseTDF[0].Course_Score__c = 2;
        listpartnercourseTDF[1].Contact__c = listConTDF[0].id;
        listpartnercourseTDF[1].Account__c = listAccTDF[0].id;
        listpartnercourseTDF[1].Course__c = listCourseTDF[0].id;
        listpartnercourseTDF[1].Course_Completed_Date__c = System.today()-7;
        listpartnercourseTDF[1].Course_Score__c = 2;
        insert listpartnercourseTDF;
        list<Certification_Requirement_Setup__c> listcertReqSetupTDF = TestDataFactory.createNCertificationReqSetUp(1);
        listcertReqSetupTDF[0].name='newcertreqsetup';
        listcertReqSetupTDF[0].Apply_Requirement_To__c='Global';
        listcertReqSetupTDF[0].Certification_Name__c = 'Server Certified';
        insert listcertReqSetupTDF[0];
        list<Certification_Criteria_Setup__c> listcertCriteriaSetupTDF = TestDataFactory.createNCertificationCriteriaSetup(4);
        listcertCriteriaSetupTDF[0].Certification_Criteria_Name__c = 'Demo Unit';
        listcertCriteriaSetupTDF[0].Certification_Criteria_Value__c = 'EQL Demo';
        listcertCriteriaSetupTDF[0].Criteria_Value_Ids__c = listDemosetupTDF[0].Id;
        listcertCriteriaSetupTDF[0].Certification_Requirement_Setup__c = listcertReqSetupTDF[0].id;
        listcertCriteriaSetupTDF[0].Number_of_Demo_Units__c = 1;
        listcertCriteriaSetupTDF[0].Certification_Criteria_Order__c = 2;
        listcertCriteriaSetupTDF[1].Certification_Criteria_Name__c = 'First Sales Training';
        listcertCriteriaSetupTDF[1].Condition__c = 'All';
        listcertCriteriaSetupTDF[1].Certification_Criteria_Value__c = 'Blades Server';
        listcertCriteriaSetupTDF[1].Criteria_Value_Ids__c = '101';
        listcertCriteriaSetupTDF[1].Certification_Requirement_Setup__c = listcertReqSetupTDF[0].id;
        listcertCriteriaSetupTDF[1].Certification_Criteria_Order__c = 3;
        listcertCriteriaSetupTDF[2].Certification_Criteria_Name__c = 'First Technical Training';
        listcertCriteriaSetupTDF[2].Condition__c = 'All';
        listcertCriteriaSetupTDF[2].Certification_Criteria_Value__c = 'Blades Server';
        listcertCriteriaSetupTDF[2].Criteria_Value_Ids__c = '101';
        listcertCriteriaSetupTDF[2].Certification_Requirement_Setup__c = listcertReqSetupTDF[0].id;
        listcertCriteriaSetupTDF[2].Certification_Criteria_Order__c = 1;
        listcertCriteriaSetupTDF[3].Certification_Criteria_Name__c = 'General Training Criteria';
        listcertCriteriaSetupTDF[3].Certification_Criteria_Value__c = 'Blades Server';
        listcertCriteriaSetupTDF[3].Criteria_Value_Ids__c = '101';
        listcertCriteriaSetupTDF[3].Certification_Requirement_Setup__c = listcertReqSetupTDF[0].id;
        listcertCriteriaSetupTDF[3].Certification_Criteria_Order__c = 4;
		insert listcertCriteriaSetupTDF;

    }  

    public static testmethod void testPartnerCertDataStructures(){
    /*    Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';
        acc.Partner_Relationship__c='Registered';  
        acc.RecordTypeid = [select Id from RecordType where SobjectType = 'Account' and Name = 'Partner Account'].id;    
        insert acc;
               
        Contact con = new Contact();
        con.lastname = 'Langley';
        con.email = 'langley@xyz.com';
        con.accountid = acc.id;
        insert con;
        
        Demo_Unit_Setup__c duseql = new Demo_Unit_Setup__c(
                    Name = 'EQL Demo',
                    Active__c = true);
        insert duseql;
        
        Demo_Unit__c demoUnit = new Demo_Unit__c();
        //demoUnit.Demo_Unit_Type__c = 'EQL Demo';
        demoUnit.Demo_Unit_Setup__c = duseql.Id;
        demoUnit.Order_Number__c = '123';
        demoUnit.Order_Date__c = System.today();
        demoUnit.T_C__c = 'Yes';
        demoUnit.Partner_Account_Name__c = acc.id;
        demoUnit.TSR_Name__c = 'Doyle';
        demoUnit.Contact_Name__c = 'Doyle';
        demoUnit.Contact_Email__c = 'doyle@xyz.com';
        insert demoUnit;
        
        Demo_Unit__c demoUnit2 = new Demo_Unit__c();
        //demoUnit2.Demo_Unit_Type__c = 'EQL Demo';
        demoUnit2.Demo_Unit_Setup__c = duseql.Id;
        demoUnit2.Order_Number__c = '123';
        demoUnit2.Order_Date__c = System.today();
        demoUnit2.T_C__c = 'Yes';
        demoUnit2.Partner_Account_Name__c = acc.id;
        demoUnit2.TSR_Name__c = 'Doyle';
        demoUnit2.Contact_Name__c = 'Doyle';
        demoUnit2.Contact_Email__c = 'doyle@xyz.com';
        insert demoUnit2;

        Course__c course= new Course__c();
        course.Course_Name__c = 'Blades Server';
        course.Credit_Hours__c = 8;
        course.Course_ID__c = '101';
        course.Course_Type__c = 'Elearning';
        course.Course_Modality__c = 'ELearning';
        course.Course_Description__c = 'Dell sales';
        insert course;
      */
        listAcc =  [select id from Account limit 1];
        system.assertEquals(listAcc[0].id, listAcc[0].id);
        listcon  = [select id from Contact limit 1];
        listDemoset = [select id from Demo_Unit_Setup__c limit 1];
        listCourse = [select id from Course__c limit 1 ];
        listpartnercourse = [select id,Contact__c,Account__c,Course__c from Partner_Course__c limit 2];
        listcertReqSetup = [select id,Apply_Requirement_To__c,Certification_Name__c,name from Certification_Requirement_Setup__c limit 1];
        listcertCriteriaSetup = [select id,Certification_Criteria_Name__c,Criteria_Value_Ids_PostFixFormat__c,Certification_Criteria_Value__c,Criteria_Value_Ids__c,Certification_Requirement_Setup__c,Number_of_Demo_Units__c,Certification_Criteria_Order__c from Certification_Criteria_Setup__c limit 4];
     /*   Partner_Course__c pc = new Partner_Course__c();
        pc.Contact__c = listCon[0].id;
        pc.Account__c = listAcc[0].id;
        pc.Course__c = listCourse[0].id;
        pc.Course_Completed_Date__c = System.today()-7;
        pc.Course_Score__c = 2;
        insert pc;
        
        Partner_Course__c pc2 = new Partner_Course__c();
        pc2.Contact__c = listCon[0].id;
        pc2.Account__c = listAcc[0].id;
        pc2.Course__c = listCourse[0].id;
        pc2.Course_Completed_Date__c = System.today()-7;
        pc2.Course_Score__c = 2;
        insert pc2;

        Certification_Requirement_Setup__c certReqSetup = new Certification_Requirement_Setup__c();
        certReqSetup.name='newcertreqsetup';
        certReqSetup.Apply_Requirement_To__c='Global';
        certReqSetup.Certification_Name__c = 'Server Certified';
        insert certReqSetup;
        
        Certification_Criteria_Setup__c certCriteriaSetup = new Certification_Criteria_Setup__c();
        certCriteriaSetup.Certification_Criteria_Name__c = 'Demo Unit';
        certCriteriaSetup.Certification_Criteria_Value__c = 'EQL Demo';
        certCriteriaSetup.Criteria_Value_Ids__c = listDemoset[0].Id;
        certCriteriaSetup.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup.Number_of_Demo_Units__c = 1;
        certCriteriaSetup.Certification_Criteria_Order__c = 2;
        insert certCriteriaSetup;

        Certification_Criteria_Setup__c certCriteriaSetup2 = new Certification_Criteria_Setup__c();
        certCriteriaSetup2.Certification_Criteria_Name__c = 'First Sales Training';
        certCriteriaSetup2.Condition__c = 'All';
        certCriteriaSetup2.Certification_Criteria_Value__c = 'Blades Server';
        certCriteriaSetup2.Criteria_Value_Ids__c = '101';
        certCriteriaSetup2.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup2.Certification_Criteria_Order__c = 3;
        insert certCriteriaSetup2;

        Certification_Criteria_Setup__c certCriteriaSetup3 = new Certification_Criteria_Setup__c();
        certCriteriaSetup3.Certification_Criteria_Name__c = 'First Technical Training';
        certCriteriaSetup3.Condition__c = 'All';
        certCriteriaSetup3.Certification_Criteria_Value__c = 'Blades Server';
        certCriteriaSetup3.Criteria_Value_Ids__c = '101';
        certCriteriaSetup3.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup3.Certification_Criteria_Order__c = 1;
        insert certCriteriaSetup3;

        Certification_Criteria_Setup__c certCriteriaSetup4 = new Certification_Criteria_Setup__c();
        certCriteriaSetup4.Certification_Criteria_Name__c = 'General Training Criteria';
        certCriteriaSetup4.Certification_Criteria_Value__c = 'Blades Server';
        certCriteriaSetup4.Criteria_Value_Ids__c = '101';
        certCriteriaSetup4.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup4.Certification_Criteria_Order__c = 4;
        insert certCriteriaSetup4;
*/
        PartnerCertDataStructures certds = new PartnerCertDataStructures();
        PartnerCertDataStructures.Accountdata accdata = new PartnerCertDataStructures.Accountdata(listAcc[0].id);
        PartnerCertDataStructures.Criteria criteria = new PartnerCertDataStructures.Criteria();
        PartnerCertDataStructures.Criteria criteria2 = new PartnerCertDataStructures.Criteria(listcertCriteriaSetup[0]);
        PartnerCertDataStructures.Criteria criteria3 = new PartnerCertDataStructures.Criteria(listcertCriteriaSetup[1]);
        PartnerCertDataStructures.Criteria criteria4 = new PartnerCertDataStructures.Criteria(listcertCriteriaSetup[2]);
        PartnerCertDataStructures.Criteria criteria5 = new PartnerCertDataStructures.Criteria(listcertCriteriaSetup[3]);
        PartnerCertDataStructures.DemoCriteria demoCriteria = new PartnerCertDataStructures.DemoCriteria();
        PartnerCertDataStructures.CriteriaWithExpression criteriaExp = new PartnerCertDataStructures.CriteriaWithExpression('first;second;third',';');
        
    }
}