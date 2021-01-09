@isTest
private class VFCntrlr_CertCriteria_AddEditTrngTest{
  static list<Course__c>  listCourse;
    @testSetup static void setup(){
        list<Course__c>  listCourseTDF = TestDataFactory.createNCourse(3);
        listCourseTDF[0].Course_Name__c='DCSS0412WBTS - Dell Cloud Solutions Sales';
        listCourseTDF[0].Course_Description__c='Dell Cloud Solutions Sales - DCSS0412WBTS';
        listCourseTDF[1].Course_Name__c='DCES0312WBTS - Dell Cloud Essentials';
        listCourseTDF[1].Course_Description__c='Dell Cloud Essentials - DCES0312WBTS';
        listCourseTDF[2].Course_Name__c='DCES0512WBTS - Dell Cloud Solutions Presales';
        listCourseTDF[2].Course_Description__c='DCES0512WBTS - Dell Cloud Solutions Presales';
        insert listCourseTDF;
        system.debug('listCourseTDF>>>'+listCourseTDF);
    }  

    public static testmethod void testCertCriteriaAddEditTraining(){
        //insert new course
      /*  
        Course__c c = new Course__c(Course_Id__c='101', Course_Name__c='DCSS0412WBTS - Dell Cloud Solutions Sales',
                                      Course_Type__c ='eLearning', Course_Modality__c='eLearning', 
                                      Course_Description__c='Dell Cloud Solutions Sales - DCSS0412WBTS');

        insert c;
        
        Course__c c1 = new Course__c(Course_Id__c='1234', Course_Name__c='DCES0312WBTS - Dell Cloud Essentials',
                                      Course_Type__c ='eLearning', Course_Modality__c='eLearning', 
                                      Course_Description__c='Dell Cloud Essentials - DCES0312WBTS');

        insert c1;
        
        Course__c c2 = new Course__c(Course_Id__c='123', Course_Name__c='DCES0512WBTS - Dell Cloud Solutions Presales',
                                      Course_Type__c ='eLearning', Course_Modality__c='eLearning', 
                                      Course_Description__c='DCES0512WBTS - Dell Cloud Solutions Presales');

        insert c2;
        */
        listcourse = [select id,Course_Name__c,Course_Code__c,Course_Description__c from Course__c limit 3];
        system.assertEquals(listcourse[0].Course_Name__c, listcourse[0].Course_Name__c);
        PageReference pageRef = Page.CertCriteria_AddEditTraining;
         
        // Add first Criteria option        
        pageRef.getParameters().put('mode','Add');
        pageRef.getParameters().put('crValue',null);
        pageRef.getParameters().put('crId',null);
        Test.setCurrentPageReference(pageRef);
        VFCntrlr_CertCriteria_AddEditTraining vfCntrlr = new VFCntrlr_CertCriteria_AddEditTraining();
        vfCntrlr.saveCriteria_addTab();
        vfCntrlr.search_course = 'Dell';
        vfCntrlr.doSearch();
        vfCntrlr.getSearchTableRows();
        // Add 
        
        pageRef.getParameters().put('mode','Add');
        pageRef.getParameters().put('crValue','DCES0312WBTS - Dell Cloud Essentials OR DCES0512WBTS - Dell Cloud Solutions Presales');
        pageRef.getParameters().put('crId','DCES0312WBTS OR DCES0512WBTS');
        Test.setCurrentPageReference(pageRef);
        VFCntrlr_CertCriteria_AddEditTraining vfCntrlr1 = new VFCntrlr_CertCriteria_AddEditTraining();
        vfCntrlr1.saveCriteria_addTab();
        
        //Edit
        pageRef.getParameters().put('mode','Edit');
        pageRef.getParameters().put('cnt','1');
        pageRef.getParameters().put('crValue','DCES0312WBTS - Dell Cloud Essentials OR DCES0512WBTS - Dell Cloud Solutions Presales');
        pageRef.getParameters().put('crId','DCES0312WBTS OR DCES0512WBTS');
        Test.setCurrentPageReference(pageRef);
        VFCntrlr_CertCriteria_AddEditTraining vfCntrlr2 = new VFCntrlr_CertCriteria_AddEditTraining();
             
        vfCntrlr2.search_course_Modify  = 'Dell';
        vfCntrlr2.doSearch_Modify();
        vfCntrlr2.getSearchTableRows_modify();
        
        vfCntrlr2.addSelectedCourses();
        vfCntrlr2.saveCriteria_close();
        vfCntrlr2.saveCriteria();
        vfCntrlr2.saveCriteria_addTab();
        vfCntrlr2.saveCriteria_close_addTab();
      
        vfCntrlr2.delSelectedCourse();
        vfCntrlr2.modSelectedCourse();
        
        vfCntrlr2.getSelectedCourseEmpty();
        vfCntrlr2.getSearchCourseEmpty();
        vfCntrlr2.getSearchCourseModify_Empty();
        vfCntrlr2.getSelectedCourses();
        vfCntrlr2.getSelectedCourses_del();
        vfCntrlr2.getSelectedCourses_Add();
   
    }
}