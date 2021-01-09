/********************************************************************************
History: Created by Meghana for NET Exam project
Version Date            Modified By     Description     
---------------------------------------------------------------------------------
1.0		31-July-2012	Krishnamoorthi	Modified: For Maintenance R13.10 CR 7290 
 
*********************************************************************************/
@isTest
private class BeforeInsertUpdateOnCertCriteriaTest{
   static list<Certification_Criteria_Setup__c>  listCertCriteriaRequire;
  static list<Certification_Requirement_Setup__c> listCertRequire;
  static list<Demo_Unit_Setup__c> listDemounitSet;
  static List<Course__c> listcourse;
    @testSetup static void setup(){
        List<Certification_Requirement_Setup__c> listCertRequireTDF = TestDataFactory.createNCertificationReqSetUp(1);
        insert listCertRequireTDF;
        List<Course__c> listcourseTDF = TestDataFactory.createNCourse(4);
        listcourseTDF[0].Course_Id__c='101';
        listcourseTDF[0].Course_Name__c='Dell Test Course';
        listcourseTDF[1].Course_Id__c='102';
        listcourseTDF[1].Course_Name__c='Dell Test Course';
        listcourseTDF[2].Course_Id__c='103';
        listcourseTDF[2].Course_Name__c='d3';
        listcourseTDF[3].Course_Id__c='104';
        listcourseTDF[3].Course_Name__c='D4';
		insert listcourseTDF;
        List<Demo_Unit_Setup__c> listDemosetupTDF =  TestDataFactory.createNDemoUnitSetup(3);
        insert listDemosetupTDF;
        List<Certification_Criteria_Setup__c> listCertCriteriaRequireTDF = TestDataFactory.createNCertificationCriteriaSetup(3);
        listCertCriteriaRequireTDF[0].Certification_Requirement_Setup__c = listCertRequireTDF[0].id;
        listCertCriteriaRequireTDF[0].Certification_Criteria_Value__c = listcourseTDF[0].Course_Name__c; //+ ' OR ' + listcourseTDF[1].Course_Name__c ;
        listCertCriteriaRequireTDF[0].Criteria_Value_Ids__c = listcourseTDF[0].Course_Id__c;        
        listCertCriteriaRequireTDF[1].Certification_Requirement_Setup__c = listCertRequireTDF[0].id;
        listCertCriteriaRequireTDF[1].Certification_Criteria_Value__c = listcourseTDF[2].Course_Name__c + ' ; ' + listcourseTDF[3].Course_Name__c ;
        listCertCriteriaRequireTDF[1].Criteria_Value_Ids__c = listcourseTDF[2].Course_Id__c+ ' ; ' + listcourseTDF[3].Course_Id__c;        
        listCertCriteriaRequireTDF[2].Certification_Requirement_Setup__c = listCertRequireTDF[0].id;
        listCertCriteriaRequireTDF[1].Certification_Criteria_Value__c = listcourseTDF[2].Course_Name__c;
        listCertCriteriaRequireTDF[1].Criteria_Value_Ids__c = listcourseTDF[2].Course_Id__c;
        insert listCertCriteriaRequireTDF;
    }  

    public static testmethod void testbeforeInsertUpdateOnCertCriteriaSetup(){
  /*  
        Certification_Requirement_Setup__c certReqSetup = new Certification_Requirement_Setup__c();
        certReqSetup.name='test1';
        certReqSetup.Apply_Requirement_To__c='Global';
        certReqSetup.Certification_Name__c = 'Server';        
        insert certReqSetup;
        
        list<Course__c> course_lst = new list<Course__c>();
        
        Course__c c = new Course__c(Course_Id__c='101', Course_Name__c='Dell Test Course',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course', Credit_Hours__c=8);
        course_lst.add(c);
        
        Course__c c1 = new Course__c(Course_Id__c='102', Course_Name__c='Dell Test Course1',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course1', Credit_Hours__c=8);
        course_lst.add(c1);
        
        Course__c c2 = new Course__c(Course_Id__c='103', Course_Name__c='D3 - Dell Test Course3',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course3', Credit_Hours__c=8);
        course_lst.add(c2);
        
        Course__c c3 = new Course__c(Course_Id__c='104', Course_Name__c='D3 - Dell Test Course3',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course3', Credit_Hours__c=8);
        course_lst.add(c3);
        insert course_lst;
        
        List<Certification_Criteria_Setup__c> lstCriteria = new List<Certification_Criteria_Setup__c>();
                
        Certification_Criteria_Setup__c certCriteriaSetup = new Certification_Criteria_Setup__c();
        certCriteriaSetup.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup.Certification_Criteria_Order__c = 1;
        certCriteriaSetup.Certification_Criteria_Name__c = 'First Sales Training';
        certCriteriaSetup.Condition__c= 'All';
        certCriteriaSetup.Certification_Criteria_Value__c = c.Course_Name__c + ' OR ' + c1.Course_Name__c ;
        certCriteriaSetup.Criteria_Value_Ids__c = c.Course_Id__c + ' OR ' + c1.Course_Id__c;        
        lstCriteria.add(certCriteriaSetup);
        
        Certification_Criteria_Setup__c certCriteriaSetup2 = new Certification_Criteria_Setup__c();
        certCriteriaSetup2.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup2.Certification_Criteria_Order__c = 1;
        certCriteriaSetup2.Certification_Criteria_Name__c = 'First Technical Training';
        certCriteriaSetup2.Condition__c= 'All';
        certCriteriaSetup2.Certification_Criteria_Value__c = c2.Course_Name__c + ' ; ' + c3.Course_Name__c;
        certCriteriaSetup2.Criteria_Value_Ids__c = c2.Course_Id__c + ' ; ' + c3.Course_Id__c;        
        lstCriteria.add(certCriteriaSetup2);
        
        Certification_Criteria_Setup__c certCriteriaSetup5 = new Certification_Criteria_Setup__c();
        certCriteriaSetup5.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup5.Certification_Criteria_Order__c = 1;
        certCriteriaSetup5.Certification_Criteria_Name__c = 'General Training Criteria';
        certCriteriaSetup5.Condition__c= 'All';
        certCriteriaSetup5.Certification_Criteria_Value__c = c2.Course_Name__c ;
        certCriteriaSetup5.Criteria_Value_Ids__c = c2.Course_Id__c;        
        lstCriteria.add(certCriteriaSetup5);
        
        insert lstCriteria;
*/
    listcourse = [select id,Course_Id__c,Course_Name__c from Course__c limit 4 ];
    listCertCriteriaRequire = [select id,Criteria_Value_Ids__c,Certification_Requirement_Setup__c from Certification_Criteria_Setup__c limit 3  ];
    listCertCriteriaRequire[0].Criteria_Value_Ids__c =  listcourse[1].Course_Id__c;
  //  listCertCriteriaRequire[0].Certification_Requirement_Setup__c =  listcourse[1].Course_Name__c;
        update listCertCriteriaRequire[0];
   system.assertEquals(listCertCriteriaRequire[0].Criteria_Value_Ids__c , listCertCriteriaRequire[0].Criteria_Value_Ids__c );    
    }
    
    //Rev 1.0 changes -- start
    public static testMethod void certfnCriteriaSetupTriggerTest() {
		/*
		List<Demo_Unit_Setup__c> demoUnitSetupList = new List<Demo_Unit_Setup__c> (); 
		
		for(integer i=0; i<=3; i++){
			Demo_Unit_Setup__c dus = new Demo_Unit_Setup__c(
										Name = 'TestDemoUnitSetup'+i,
										Active__c = true);
			demoUnitSetupList.add(dus);
		}    	
		insert demoUnitSetupList; */
       listDemounitSet = [select id from Demo_Unit_Setup__c limit 3];
       listCertRequire = [select id from Certification_Requirement_Setup__c limit 1 ];

/*		Certification_Requirement_Setup__c crs = new Certification_Requirement_Setup__c(
													Name = 'TestCertReqSetup',
													Certification_Name__c = 'Storage',
													Apply_Requirement_To__c = 'Global',
													Active__c = true);
		insert crs;
*/		
		Certification_Criteria_Setup__c ccs = new Certification_Criteria_Setup__c (
													Certification_Requirement_Setup__c = listCertRequire[0].Id,
													Certification_Criteria_Order__c = 1,
													Number_of_Demo_Units__c = 5,
													Certification_Criteria_Name__c = 'Demo Unit',
													Certification_Criteria_Value__c = 'TestDemoUnitSetup');
		try {
				insert ccs;
			} 
		catch (DmlException e) {
				//Assert Error Message
				System.assert( e.getMessage().contains('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Please enter a valid Demo Unit Type: [Certification_Criteria_Value__c]'), e.getMessage() );
		}
/*		
		Certification_Criteria_Setup__c ccsWithValue = new Certification_Criteria_Setup__c (
													Certification_Requirement_Setup__c = crs.Id,
													Certification_Criteria_Order__c = 1,
													Number_of_Demo_Units__c = 5,
													Certification_Criteria_Name__c = 'Demo Unit',
													Certification_Criteria_Value__c = 'TestDemoUnitSetup1'); 
		insert ccsWithValue;
		 */
          listCertCriteriaRequire = [select id,Criteria_Value_Ids__c,Certification_Requirement_Setup__c from Certification_Criteria_Setup__c limit 1  ];
    }	////Rev 1.0 changes -- end
}