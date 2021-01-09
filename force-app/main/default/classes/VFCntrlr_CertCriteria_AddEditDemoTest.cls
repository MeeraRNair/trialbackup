@isTest
private class VFCntrlr_CertCriteria_AddEditDemoTest{

    public static testmethod void testCertCriteriaAddEditDemo(){
        //insert new course
        
        Demo_Unit_Setup__c ds = new Demo_Unit_Setup__c(Name='EQL Demo',  Active__c=true);
        insert ds;
        
        Demo_Unit_Setup__c ds1 = new Demo_Unit_Setup__c(Name='CML Demo',  Active__c=true);
        insert ds1;
        
        Demo_Unit_Setup__c ds2 = new Demo_Unit_Setup__c(Name='KACE Demo',  Active__c=true);
        insert ds2;
        
        PageReference pageRef = Page.CertCriteria_AddEditDemo;
         
        // Add first Criteria option        
        pageRef.getParameters().put('mode','Add');
        pageRef.getParameters().put('crValue',null);
        pageRef.getParameters().put('crId',null);
        Test.setCurrentPageReference(pageRef);
        VFCntrlr_CertCriteria_AddEditDemo vfCntrlr = new VFCntrlr_CertCriteria_AddEditDemo();
        vfCntrlr.saveCriteria_addTab();
        vfCntrlr.search_demo = 'EQL';
        vfCntrlr.doSearch();
        vfCntrlr.getSearchTableRows();
        // Add 
        
        pageRef.getParameters().put('mode','Add');
        pageRef.getParameters().put('crValue','EQL Demo OR KACE Demo');     
        pageRef.getParameters().put('crId', ds.id + ' OR ' +  ds2.id);
        Test.setCurrentPageReference(pageRef);
        VFCntrlr_CertCriteria_AddEditDemo vfCntrlr1 = new VFCntrlr_CertCriteria_AddEditDemo();
        vfCntrlr1.saveCriteria_addTab();
        
        //Edit
        pageRef.getParameters().put('mode','Edit');
        pageRef.getParameters().put('cnt','1');
         pageRef.getParameters().put('crValue','EQL Demo OR KACE Demo');
        pageRef.getParameters().put('crId', ds.id + ' OR ' +  ds2.id);
        Test.setCurrentPageReference(pageRef);
        VFCntrlr_CertCriteria_AddEditDemo vfCntrlr2 = new VFCntrlr_CertCriteria_AddEditDemo();
             
        vfCntrlr2.search_demo_Modify  = 'EQL';
        vfCntrlr2.doSearch_Modify();
        vfCntrlr2.getSearchTableRows_modify();
        
        vfCntrlr2.addSelectedDemo();
        vfCntrlr2.saveCriteria_close();
        vfCntrlr2.saveCriteria();
        vfCntrlr2.saveCriteria_addTab();
        vfCntrlr2.saveCriteria_close_addTab();
      
        vfCntrlr2.delSelecteddemo();
        vfCntrlr2.modSelecteddemo();
        
        vfCntrlr2.getSelecteddemoEmpty();
        vfCntrlr2.getSearchdemoEmpty();
        vfCntrlr2.getSearchdemoModify_Empty();
        vfCntrlr2.getSelectedDemos();
        vfCntrlr2.getSelectedDemos_del();
        vfCntrlr2.getSelectedDemos_Add();
   
    }
}