/*-----------------------------------------------------------------------------------------------------------------------------
TEST CLASS FOR PartnerCertEvaluation & NetExam_EvaluateAccount
-----------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class PartnerCertEvaluationTest{
    
    public static testmethod void testPartnerCertEvaluation(){
        // insert country data
        Country__c country3 = new Country__c();    
        country3.Region__c = 'APJ';
        country3.Code__c = 'IN';  
        country3.name = 'India';  
        country3.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        insert(country3);
        
        // insert course data
        list<Course__c> course_lst = new list<Course__c>();        
        Course__c c = new Course__c(Course_Id__c='101', Course_Name__c='DELL101 - Dell Test Course',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course', Credit_Hours__c=8);
        course_lst.add(c);
        
        Course__c c1 = new Course__c(Course_Id__c='102', Course_Name__c='DELL102 - Dell Test Course1',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course1', Credit_Hours__c=8 );
        course_lst.add(c1);
        
        Course__c c2 = new Course__c(Course_Id__c='103', Course_Name__c='DELL103 - Dell Test Course3',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course3', Credit_Hours__c=8);
        course_lst.add(c2);
        
        Course__c c3 = new Course__c(Course_Id__c='104', Course_Name__c='DELL104 - Dell Test Course4',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course3', Credit_Hours__c=8);
        course_lst.add(c3);
        insert course_lst;
        
        // insert Account data      
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';        
        acc.Partner_Relationship__c='Registered'; 
        acc.RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false);   
        acc.Account_Country_Code__c='IN'; 
        insert acc;
        
        // insert Certification Tracker data    
        Certification_Tracker__c certTracker = new Certification_Tracker__c();
        certTracker.Evaluate_Criteria__c= true;
        certTracker.Account_name__c = acc.id;
        insert certTracker;
        
        // insert Contact data
        List<Contact> lstContact = new List<Contact>();      
        for (integer i = 1 ; i <=2; i++){            
            Contact con = new Contact(AccountId=acc.id, FirstName='Test',LastName='test', email='netexam@dell.com');          
            lstContact.add(con);   
        }
        insert lstContact;
        
        // insert partner course data
        List<Partner_Course__c> pcLst = new List<Partner_Course__c> ();
        Partner_Course__c pc1 = new Partner_Course__c(Account__c = acc.id, Contact__c=lstContact.get(0).id,
                                          Course__c = c.id,
                                          Course_Completed_Date__c=System.today()-5, 
                                          Course_Score__c = 10);
            
        Partner_Course__c pc2 = new Partner_Course__c(Account__c = acc.id, Contact__c=lstContact.get(1).id,
                                          Course__c =  c2.id,
                                          Course_Completed_Date__c=System.today()-5, 
                                          Course_Score__c = 40);
        pcLst.add(pc1);        
        pcLst.add(pc2);     
        insert pcLst;
        
        // insert Demo Unit Setup data
        Demo_Unit_Setup__c ds1 = new Demo_Unit_Setup__c(Name = 'EQL Demo',Active__c=true, Demo_Unit_Description__c='EQL Demo');
        Demo_Unit_Setup__c ds2 = new Demo_Unit_Setup__c(Name = 'Networking Demo',Active__c=true, Demo_Unit_Description__c ='Networking Demo');
        insert ds1;        
        insert ds2;

        // insert demo unit data
        Demo_Unit__c dm1 = new Demo_Unit__c(Partner_Account_Name__c= acc.id, Contact_Name__c=lstContact.get(0).FirstName,
                                      Contact_Email__c = 'netexam@dell.com',
                                      Order_Date__c=System.today()-5, Order_Number__c='13',
                                      Demo_Unit_Type__c= ds1.id, T_C__c='Y',TSR_Name__c='abc');
        insert dm1;        
        Demo_Unit__c dm2 = new Demo_Unit__c(Partner_Account_Name__c= acc.id, Contact_Name__c=lstContact.get(0).FirstName,
                                      Contact_Email__c = 'netexam@dell.com',
                                      Order_Date__c=System.today()-5, Order_Number__c='13',
                                      Demo_Unit_Type__c=ds2.id, T_C__c='Y',TSR_Name__c='abc');
        insert dm2;
        //insert master program details:
        
        
        //insert Certification Requirement details
        list<Certification_Requirement_Setup__c> reqlst = new list<Certification_Requirement_Setup__c>();
        Certification_Requirement_Setup__c certReqSetup = new Certification_Requirement_Setup__c();
        certReqSetup.name='test1';
        certReqSetup.Apply_Requirement_To__c='Global';
        certReqSetup.Certification_Name__c = 'Server';        
        certReqSetup.Active__c = true;
        reqlst.add(certReqSetup);
        
        Certification_Requirement_Setup__c certReqSetup1 = new Certification_Requirement_Setup__c();
        certReqSetup1.name='test1';
        certReqSetup1.Apply_Requirement_To__c='Country';
        certReqSetup1.Country__c = country3.id;
        certReqSetup1.Certification_Name__c = 'Storage';        
        certReqSetup1.Active__c = true;
        certReqSetup1.Prerequisites__c =true;
        reqlst.add(certReqSetup1);
        
        Certification_Requirement_Setup__c certReqSetup2 = new Certification_Requirement_Setup__c();
        certReqSetup2.name='test1';
        certReqSetup2.Apply_Requirement_To__c='Country';
        certReqSetup2.Country__c = country3.id;
        certReqSetup2.Certification_Name__c = 'Networking';        
        certReqSetup2.Active__c = true;
        reqlst.add(certReqSetup2);
        
        Certification_Requirement_Setup__c certReqSetup3 = new Certification_Requirement_Setup__c();
        certReqSetup3.name='test1';
        certReqSetup3.Apply_Requirement_To__c='Region';
        certReqSetup3.Country__c = null;
        certReqSetup3.Region__c = 'APJ';
        certReqSetup3.Certification_Name__c = 'Systems Management';  
        certReqSetup3.Prerequisites__c = false;     
        certReqSetup3.Active__c = true;
        reqlst.add(certReqSetup3);
        
        Certification_Requirement_Setup__c certReqSetup4 = new Certification_Requirement_Setup__c();
        certReqSetup4.name='test1';
        certReqSetup4.Apply_Requirement_To__c='Region';
        certReqSetup4.Country__c = null;
        certReqSetup4.Region__c = 'APJ';
        certReqSetup4.Certification_Name__c = 'Server';        
        certReqSetup4.Active__c = true;
        certReqSetup4.Prerequisites__c =true;
        reqlst.add(certReqSetup4);
        insert reqlst;
              
        
        //insert Certification Criteria Setup details
        List<Certification_Criteria_Setup__c> lstCriteria = new List<Certification_Criteria_Setup__c>();
                
        Certification_Criteria_Setup__c certCriteriaSetup = new Certification_Criteria_Setup__c();
        certCriteriaSetup.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup.Certification_Criteria_Order__c = 1;
        certCriteriaSetup.Certification_Criteria_Name__c = 'First Sales Training';
        certCriteriaSetup.Condition__c= 'All';
        certCriteriaSetup.Certification_Criteria_Value__c = c.Course_Name__c + ' OR ' + c1.Course_Name__c ;
        certCriteriaSetup.Criteria_Value_Ids__c = 'DELL101 OR DELL102'; // c.Course_Code__c + ' OR ' + c1.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup);
                       
        Certification_Criteria_Setup__c certCriteriaSetup1 = new Certification_Criteria_Setup__c();
        certCriteriaSetup1.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup1.Certification_Criteria_Order__c = 2;
        certCriteriaSetup1.Certification_Criteria_Name__c = 'Demo Unit';
        certCriteriaSetup1.Number_of_Demo_Units__c = 1;
        certCriteriaSetup1.Certification_Criteria_Value__c =  dm1.name;
        certCriteriaSetup1.Criteria_Value_Ids__c = dm1.id;
        lstCriteria.add(certCriteriaSetup1);
        
        Certification_Criteria_Setup__c certCriteriaSetup2 = new Certification_Criteria_Setup__c();
        certCriteriaSetup2.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup2.Certification_Criteria_Order__c = 1;
        certCriteriaSetup2.Certification_Criteria_Name__c = 'First Technical Training';
        certCriteriaSetup2.Condition__c= 'Any 1';
        certCriteriaSetup2.Certification_Criteria_Value__c = c2.Course_Name__c ;
        certCriteriaSetup2.Criteria_Value_Ids__c = 'DELL103'; //c2.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup2);
         
        Certification_Criteria_Setup__c certCriteriaSetup3 = new Certification_Criteria_Setup__c();
        certCriteriaSetup3.Certification_Requirement_Setup__c = certReqSetup3.id;
        certCriteriaSetup3.Certification_Criteria_Order__c = 2;
        certCriteriaSetup3.Certification_Criteria_Name__c = 'Demo Unit';
        certCriteriaSetup3.Number_of_Demo_Units__c = 1;
        certCriteriaSetup3.Certification_Criteria_Value__c =  ds2.name;
        certCriteriaSetup3.Criteria_Value_Ids__c =  ds2.id;
        lstCriteria.add(certCriteriaSetup3);
        
        Certification_Criteria_Setup__c certCriteriaSetup4 = new Certification_Criteria_Setup__c();
        certCriteriaSetup4.Certification_Requirement_Setup__c = certReqSetup2.id;
        certCriteriaSetup4.Certification_Criteria_Order__c = 2;
        certCriteriaSetup4.Certification_Criteria_Name__c = 'Demo Unit';
        certCriteriaSetup4.Number_of_Demo_Units__c = 1;
        certCriteriaSetup4.Certification_Criteria_Value__c =  ds1.name + ' OR ' +  ds2.name;
        certCriteriaSetup4.Criteria_Value_Ids__c =  ds1.id + ' OR ' +  ds2.id;
        lstCriteria.add(certCriteriaSetup4);
        
        Certification_Criteria_Setup__c certCriteriaSetup5 = new Certification_Criteria_Setup__c();
        certCriteriaSetup5.Certification_Requirement_Setup__c = certReqSetup1.id;
        certCriteriaSetup5.Certification_Criteria_Order__c = 1;
        certCriteriaSetup5.Certification_Criteria_Name__c = 'General Training Criteria';
        certCriteriaSetup5.Condition__c= 'All';
        certCriteriaSetup5.Certification_Criteria_Value__c = c2.Course_Name__c ;
        certCriteriaSetup5.Criteria_Value_Ids__c = 'DELL102' ; // c2.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup5);
        
        Certification_Criteria_Setup__c certCriteriaSetup6 = new Certification_Criteria_Setup__c();
        certCriteriaSetup6.Certification_Requirement_Setup__c = certReqSetup4.id;
        certCriteriaSetup6.Certification_Criteria_Order__c = 1;
        certCriteriaSetup6.Certification_Criteria_Name__c = 'General Training Criteria';
        certCriteriaSetup6.Condition__c= 'All';
        certCriteriaSetup6.Certification_Criteria_Value__c = c2.Course_Name__c ;
        certCriteriaSetup6.Criteria_Value_Ids__c = 'DELL102' ; // c2.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup6);
        insert lstCriteria;
        
        //insert prerequisites
        Certification_Prerequisites_Setup__c cp = new Certification_Prerequisites_Setup__c(Certification_Requirement_Setup__c = certReqSetup1.id,
                                                                                            Condition__c = 'All', 
                                                                                            Prerequisites__c = certReqSetup2.name + ' OR ' + c2.Course_Name__c,
                                                                                            Prerequisites_Ids__c = 'CR_'+ certReqSetup2.id + ' OR CC_DELL102' );
        insert cp;
        //insert master programs
        Master_Program_Setup__c mp = new Master_Program_Setup__c(Master_Program_Name__c = 'TestMP', Apply_Requirement_To__c ='Global',
                                                                    Active__c=true, Certification_Name__c='Server');
        
        insert mp;
        
        //insert Certified by Certification
        Certified_by_Certification__c cc = new Certified_by_Certification__c(Account__c = acc.id, Acquisition_Source__c = 'CML', Manually_Added_Competency__c=false,
                                                                               Certification__c='Server',Date_Achieved__c=System.today(), Partner_Relationship__c='registered');
        insert cc;
        
        PartnerCertEvaluation eval = new PartnerCertEvaluation();
        eval.evaluate(acc.id);        
           
    }
    
    public static testmethod void testPartnerCertEvaluation2(){
         // insert country data
        Country__c country3 = new Country__c();    
        country3.Region__c = 'Canada';
        country3.Code__c = 'CA';  
        country3.name = 'Canada'; 
        country3.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        insert(country3);
        
        // insert course data
        list<Course__c> course_lst = new list<Course__c>();        
        Course__c c = new Course__c(Course_Id__c='101', Course_Name__c='DELL101 - Dell Test Course',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course', Credit_Hours__c=8);
        course_lst.add(c);
        
        Course__c c1 = new Course__c(Course_Id__c='102', Course_Name__c='DELL102 - Dell Test Course1',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course1', Credit_Hours__c=8 );
        course_lst.add(c1);
        
        Course__c c2 = new Course__c(Course_Id__c='103', Course_Name__c='DELL103 - Dell Test Course3',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course3', Credit_Hours__c=8);
        course_lst.add(c2);
        
        Course__c c3 = new Course__c(Course_Id__c='104', Course_Name__c='DELL104 - Dell Test Course4',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course3', Credit_Hours__c=8);
        course_lst.add(c3);
        insert course_lst;
        
        // insert Account data      
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        
        acc.Partner_Relationship__c='Registered'; 
        acc.RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false);   
        acc.Account_Country_Code__c = 'CA'; 
        insert acc;
        
        // insert Certification Tracker data    
        Certification_Tracker__c certTracker = new Certification_Tracker__c();
        certTracker.Evaluate_Criteria__c= true;
        certTracker.Account_name__c = acc.id;
        insert certTracker;
        
        // insert Contact data
       
        
        List<Contact> lstContact = new List<Contact>();      
        for (integer i = 1 ; i <=2; i++){
           
            Contact con = new Contact(AccountId=acc.id, FirstName='Test',LastName='test', email='netexam@dell.com');          
            lstContact.add(con);   
        }
        insert lstContact;
        
        // insert partner course data
        List<Partner_Course__c> pcLst = new List<Partner_Course__c> ();
        Partner_Course__c pc1 = new Partner_Course__c(Account__c = acc.id, Contact__c=lstContact.get(0).id,
                                          Course__c = c.id,
                                          Course_Completed_Date__c=System.today()-5, 
                                          Course_Score__c = 10);
            
        Partner_Course__c pc2 = new Partner_Course__c(Account__c = acc.id, Contact__c=lstContact.get(1).id,
                                          Course__c =  c2.id,
                                          Course_Completed_Date__c=System.today()-5, 
                                          Course_Score__c = 40);
        pcLst.add(pc1);        
        pcLst.add(pc2);     
        
        insert pcLst;
        
        // insert Demo Unit Setup data
        Demo_Unit_Setup__c ds1 = new Demo_Unit_Setup__c(Name = 'EQL Demo',Active__c=true, Demo_Unit_Description__c='EQL Demo');
        Demo_Unit_Setup__c ds2 = new Demo_Unit_Setup__c(Name = 'Networking Demo',Active__c=true, Demo_Unit_Description__c ='Networking Demo');
        insert ds1;        
        insert ds2;

        // insert demo unit data
        Demo_Unit__c dm1 = new Demo_Unit__c(Partner_Account_Name__c= acc.id, Contact_Name__c=lstContact.get(0).FirstName,
                                      Contact_Email__c = 'netexam@dell.com',
                                      Order_Date__c=System.today()-5, Order_Number__c='13',
                                      Demo_Unit_Type__c= ds1.id, T_C__c='Y',TSR_Name__c='abc');
        insert dm1;        
       
        //insert master program details:
        
        
        //insert Certification Requirement details
        list<Certification_Requirement_Setup__c> reqlst = new list<Certification_Requirement_Setup__c>();
        Certification_Requirement_Setup__c certReqSetup = new Certification_Requirement_Setup__c();
        certReqSetup.name='test1';
        certReqSetup.Apply_Requirement_To__c='Global';
        certReqSetup.Certification_Name__c = 'Server';        
        certReqSetup.Active__c = true;
        reqlst.add(certReqSetup);
        
        Certification_Requirement_Setup__c certReqSetup1 = new Certification_Requirement_Setup__c();
        certReqSetup1.name='test1';
        certReqSetup1.Apply_Requirement_To__c='Country';
        certReqSetup1.Country__c = country3.id;
        certReqSetup1.Certification_Name__c = 'Storage';        
        certReqSetup1.Active__c = true;
        reqlst.add(certReqSetup1);
        
        Certification_Requirement_Setup__c certReqSetup2 = new Certification_Requirement_Setup__c();
        certReqSetup2.name='test1';
        certReqSetup2.Apply_Requirement_To__c='Country';
        certReqSetup2.Country__c = country3.id;
        certReqSetup2.Certification_Name__c = 'Networking';        
        certReqSetup2.Active__c = true;
        reqlst.add(certReqSetup2);
        
        Certification_Requirement_Setup__c certReqSetup3 = new Certification_Requirement_Setup__c();
        certReqSetup3.name='test1';
        certReqSetup3.Apply_Requirement_To__c='Region';
        certReqSetup3.Country__c = null;
        certReqSetup3.Region__c = 'Canada';
        certReqSetup3.Certification_Name__c = 'Systems Management';        
        certReqSetup3.Active__c = true;
        certReqSetup3.Prerequisites__c =true;
        
        reqlst.add(certReqSetup3);
        insert reqlst;
        
        //insert Certification Criteria Setup details
        List<Certification_Criteria_Setup__c> lstCriteria = new List<Certification_Criteria_Setup__c>();
                
        Certification_Criteria_Setup__c certCriteriaSetup = new Certification_Criteria_Setup__c();
        certCriteriaSetup.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup.Certification_Criteria_Order__c = 1;
        certCriteriaSetup.Certification_Criteria_Name__c = 'First Sales Training';
        certCriteriaSetup.Condition__c= 'All';
        certCriteriaSetup.Certification_Criteria_Value__c = c.Course_Name__c + ' OR ' + c1.Course_Name__c ;
        certCriteriaSetup.Criteria_Value_Ids__c = 'DELL101 OR DELL102'; // c.Course_Code__c + ' OR ' + c1.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup);
                       
        Certification_Criteria_Setup__c certCriteriaSetup1 = new Certification_Criteria_Setup__c();
        certCriteriaSetup1.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup1.Certification_Criteria_Order__c = 2;
        certCriteriaSetup1.Certification_Criteria_Name__c = 'Demo Unit';
        certCriteriaSetup1.Number_of_Demo_Units__c = 1;
        certCriteriaSetup1.Certification_Criteria_Value__c =  dm1.name;
        certCriteriaSetup1.Criteria_Value_Ids__c = dm1.id;
        lstCriteria.add(certCriteriaSetup1);
        
        Certification_Criteria_Setup__c certCriteriaSetup2 = new Certification_Criteria_Setup__c();
        certCriteriaSetup2.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup2.Certification_Criteria_Order__c = 1;
        certCriteriaSetup2.Certification_Criteria_Name__c = 'First Technical Training';
        certCriteriaSetup2.Condition__c= 'All';
        certCriteriaSetup2.Certification_Criteria_Value__c = c2.Course_Name__c ;
        certCriteriaSetup2.Criteria_Value_Ids__c = 'DELL103'; //c2.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup2);
         
        Certification_Criteria_Setup__c certCriteriaSetup3 = new Certification_Criteria_Setup__c();
        certCriteriaSetup3.Certification_Requirement_Setup__c = certReqSetup2.id;
        certCriteriaSetup3.Certification_Criteria_Order__c = 2;
        certCriteriaSetup3.Certification_Criteria_Name__c = 'Demo Unit';
        certCriteriaSetup3.Number_of_Demo_Units__c = 1;
        certCriteriaSetup3.Certification_Criteria_Value__c =  ds2.name;
        certCriteriaSetup3.Criteria_Value_Ids__c =  ds2.id;
        lstCriteria.add(certCriteriaSetup3);
        
        Certification_Criteria_Setup__c certCriteriaSetup4 = new Certification_Criteria_Setup__c();
        certCriteriaSetup4.Certification_Requirement_Setup__c = certReqSetup3.id;
        certCriteriaSetup4.Certification_Criteria_Order__c = 2;
        certCriteriaSetup4.Certification_Criteria_Name__c = 'Demo Unit';
        certCriteriaSetup4.Number_of_Demo_Units__c = 1;
        certCriteriaSetup4.Certification_Criteria_Value__c =  ds1.name + ' OR ' +  ds2.name;
        certCriteriaSetup4.Criteria_Value_Ids__c =  ds1.id + ' OR ' +  ds2.id;
        lstCriteria.add(certCriteriaSetup4);
        
        Certification_Criteria_Setup__c certCriteriaSetup5 = new Certification_Criteria_Setup__c();
        certCriteriaSetup5.Certification_Requirement_Setup__c = certReqSetup1.id;
        certCriteriaSetup5.Certification_Criteria_Order__c = 1;
        certCriteriaSetup5.Certification_Criteria_Name__c = 'General Training Criteria';
        certCriteriaSetup5.Condition__c= 'Any 1';
        certCriteriaSetup5.Certification_Criteria_Value__c = c2.Course_Name__c ;
        certCriteriaSetup5.Criteria_Value_Ids__c = 'DELL102' ; // c2.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup5);
        
        insert lstCriteria;
        
        PartnerCertEvaluation eval = new PartnerCertEvaluation();
        eval.evaluate(acc.id);        
        
    }
    
    public static testmethod void testPartnerCertEvaluation3(){
        // insert country data
        Country__c country3 = new Country__c();    
        country3.Region__c = 'US';
        country3.Code__c = 'US';  
        country3.name = 'United States'; 
        country3.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        insert(country3);
        
                // insert course data
        list<Course__c> course_lst = new list<Course__c>();        
        Course__c c = new Course__c(Course_Id__c='101', Course_Name__c='DELL101 - Dell Test Course',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course', Credit_Hours__c=8);
        course_lst.add(c);
        
        Course__c c1 = new Course__c(Course_Id__c='102', Course_Name__c='DELL102 - Dell Test Course1',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course1', Credit_Hours__c=8 );
        course_lst.add(c1);
        
        Course__c c2 = new Course__c(Course_Id__c='103', Course_Name__c='DELL103 - Dell Test Course3',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course3', Credit_Hours__c=8);
        course_lst.add(c2);
        
        Course__c c3 = new Course__c(Course_Id__c='104', Course_Name__c='DELL104 - Dell Test Course4',
                                      Course_Type__c ='eLearning', Course_Modality__c='test', 
                                      Course_Description__c='Dell Test Course3', Credit_Hours__c=8);
        course_lst.add(c3);
        insert course_lst;
        
        // insert Account data      
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        
        acc.Partner_Relationship__c='Registered'; 
        acc.RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false);   
        acc.Account_Country_Code__c= 'US';      
        insert acc;
        
        // insert Certification Tracker data    
        Certification_Tracker__c certTracker = new Certification_Tracker__c();
        certTracker.Evaluate_Criteria__c= true;
        certTracker.Account_name__c = acc.id;
        insert certTracker;
        
        // insert Contact data
        List<Contact> lstContact = new List<Contact>();      
        for (integer i = 0 ; i <=65; i++){
           
            Contact con = new Contact(AccountId=acc.id, FirstName='Test',LastName='test', email='netexam@dell.com');          
            lstContact.add(con);   
        }
        insert lstContact;
        
        // insert partner course data
        List<Partner_Course__c> pcLst = new List<Partner_Course__c> ();
        
        for (integer i = 1 ; i <=65; i++){
         
            Partner_Course__c pc1 = new Partner_Course__c(Account__c = acc.id, Contact__c=lstContact.get(i).id,
                                          Course__c = c.id,
                                          Course_Completed_Date__c=System.today()-5, 
                                          Course_Score__c = 10);
            
            
            Partner_Course__c pc2 = new Partner_Course__c(Account__c = acc.id, Contact__c=lstContact.get(i).id,
                                          Course__c =  c2.id,
                                          Course_Completed_Date__c=System.today()-5, 
                                          Course_Score__c = 40);
            pcLst.add(pc1);        
            pcLst.add(pc2);     
        }
        
         Partner_Course__c pc3 = new Partner_Course__c(Account__c = acc.id, Contact__c=lstContact.get(0).id,
                                          Course__c = c1.id,
                                          Course_Completed_Date__c=System.today()-5, 
                                          Course_Score__c = 10);
        insert pcLst;
        
        // insert Demo Unit Setup data
        Demo_Unit_Setup__c ds1 = new Demo_Unit_Setup__c(Name = 'EQL Demo',Active__c=true, Demo_Unit_Description__c='EQL Demo');
        Demo_Unit_Setup__c ds2 = new Demo_Unit_Setup__c(Name = 'Networking Demo',Active__c=true, Demo_Unit_Description__c ='Networking Demo');
        insert ds1;        
        insert ds2;

        // insert demo unit data
        Demo_Unit__c dm1 = new Demo_Unit__c(Partner_Account_Name__c= acc.id, Contact_Name__c=lstContact.get(0).FirstName,
                                      Contact_Email__c = 'netexam@dell.com',
                                      Order_Date__c=System.today()-5, Order_Number__c='13',
                                      Demo_Unit_Type__c= ds1.id, T_C__c='Y',TSR_Name__c='abc');
        insert dm1;        
        Demo_Unit__c dm2 = new Demo_Unit__c(Partner_Account_Name__c= acc.id, Contact_Name__c=lstContact.get(0).FirstName,
                                      Contact_Email__c = 'netexam@dell.com',
                                      Order_Date__c=System.today()-5, Order_Number__c='13',
                                      Demo_Unit_Type__c=ds2.id, T_C__c='Y',TSR_Name__c='abc');
        insert dm2;
        //insert master program details:
        
        
        //insert Certification Requirement details      
        Certification_Requirement_Setup__c certReqSetup = new Certification_Requirement_Setup__c();
        certReqSetup.name='test1';
        certReqSetup.Apply_Requirement_To__c='Global';
        certReqSetup.Certification_Name__c = 'Server';        
        certReqSetup.Active__c = true;    
        certReqSetup.Prerequisites__c =true;        
        insert certReqSetup;      
        
          Certification_Requirement_Setup__c certReqSetup1 = new Certification_Requirement_Setup__c();
        certReqSetup1.name='test1';
        certReqSetup1.Apply_Requirement_To__c='Global';
        certReqSetup1.Certification_Name__c = 'Security';        
        certReqSetup1.Active__c = true;    
        certReqSetup1.Prerequisites__c = true;      
        insert certReqSetup1;      
                       
        //insert Certification Criteria Setup details
        List<Certification_Criteria_Setup__c> lstCriteria = new List<Certification_Criteria_Setup__c>();
                
        Certification_Criteria_Setup__c certCriteriaSetup = new Certification_Criteria_Setup__c();
        certCriteriaSetup.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup.Certification_Criteria_Order__c = 1;
        certCriteriaSetup.Certification_Criteria_Name__c = 'First Sales Training';
        certCriteriaSetup.Condition__c= 'All';
        certCriteriaSetup.Certification_Criteria_Value__c = c.Course_Name__c + ' OR ' + c1.Course_Name__c ;
        certCriteriaSetup.Criteria_Value_Ids__c = 'DELL101 OR DELL102'; // c.Course_Code__c + ' OR ' + c1.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup);
                       
        Certification_Criteria_Setup__c certCriteriaSetup1 = new Certification_Criteria_Setup__c();
        certCriteriaSetup1.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup1.Certification_Criteria_Order__c = 2;
        certCriteriaSetup1.Certification_Criteria_Name__c = 'Demo Unit';
        certCriteriaSetup1.Number_of_Demo_Units__c = 1;
        certCriteriaSetup1.Certification_Criteria_Value__c =  ds1.name;
        certCriteriaSetup1.Criteria_Value_Ids__c = ds1.id;
        lstCriteria.add(certCriteriaSetup1);
        
        Certification_Criteria_Setup__c certCriteriaSetup2 = new Certification_Criteria_Setup__c();
        certCriteriaSetup2.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup2.Certification_Criteria_Order__c = 3;
        certCriteriaSetup2.Certification_Criteria_Name__c = 'First Technical Training';
        certCriteriaSetup2.Condition__c= 'ANY 1';
        certCriteriaSetup2.Certification_Criteria_Value__c = c2.Course_Name__c ;
        certCriteriaSetup2.Criteria_Value_Ids__c = 'DELL103'; //c2.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup2);  

        Certification_Criteria_Setup__c certCriteriaSetup3 = new Certification_Criteria_Setup__c();
        certCriteriaSetup3.Certification_Requirement_Setup__c = certReqSetup.id;
        certCriteriaSetup3.Certification_Criteria_Order__c = 1;
        certCriteriaSetup3.Certification_Criteria_Name__c = 'Second Technical Training';
        certCriteriaSetup3.Condition__c= 'ANY 1';
        certCriteriaSetup3.Certification_Criteria_Value__c = c2.Course_Name__c ;
        certCriteriaSetup3.Criteria_Value_Ids__c = 'DELL103'; //c2.Course_Code__c;        
        lstCriteria.add(certCriteriaSetup3);        
        
         Certification_Criteria_Setup__c certCriteriaSetup4 = new Certification_Criteria_Setup__c();
        certCriteriaSetup4.Certification_Requirement_Setup__c = certReqSetup1.id;
        certCriteriaSetup4.Certification_Criteria_Order__c = 2;
        certCriteriaSetup4.Certification_Criteria_Name__c = 'Demo Unit';
        certCriteriaSetup4.Number_of_Demo_Units__c = 1;
        certCriteriaSetup4.Certification_Criteria_Value__c =  ds1.name;
        certCriteriaSetup4.Criteria_Value_Ids__c = ds1.id;
        lstCriteria.add(certCriteriaSetup4);
        
        insert lstCriteria;
        
        //insert prerequisites
        Certification_Prerequisites_Setup__c cp = new Certification_Prerequisites_Setup__c(Certification_Requirement_Setup__c = certReqSetup.id,
                                                                                            Condition__c = 'ANY 1', 
                                                                                            Prerequisites__c = c2.Course_Name__c,
                                                                                            Prerequisites_Ids__c ='CC_DELL102' );
        insert cp;
        //insert master programs
        Master_Program_Setup__c mp = new Master_Program_Setup__c(name ='TEst', Master_Program_Name__c = 'TestMP', Apply_Requirement_To__c ='Global',
                                                                    Active__c=true, Certification_Name__c='Server');
        
        insert mp;
        
        Test.startTest();
        PartnerCertEvaluation eval = new PartnerCertEvaluation();
        eval.evaluate(acc.id);    

        PartnerCertDataStructures.AccountData acData = new PartnerCertDataStructures.AccountData(acc.id);
        acData.Region = 'US';
        acData.CountryId = country3.id;
        acData.AccountId = acc.id;
        acData.demoUnitsPurchased.add(ds1.name);
        acData.Certification_Completed.add('Server');
        acData.Certification_Completed.add('Security') ;
        acData.Certification_Area.add('Server');        
        acData.Certification_Area.add('Security');
        acData.Acquisition_Source = null;
        acData.Partner_Relationship = 'Registered';
        acData.Success_Reqmts.add(certReqSetup);
        acData.DemoCriteriaMet = true;
        acData.TrainingCriteriaMet = true;
        acData.CertNames_for_DemoAlert = 'Networking';
        eval.UpdateTrackerRecords(acData);      
        
        acData.Acquisition_Source = 'Compellent';       
        eval.UpdateTrackerRecords(acData); 
        
        acData.Acquisition_Source = null;
        certReqSetup.Acquisition__c = 'Compellent';
        update certReqSetup;
        eval.UpdateTrackerRecords(acData);    
                
        acData.Acquisition_Source = 'Compellent';       
        eval.UpdateTrackerRecords(acData); 
        
        acData.Acquisition_Source = 'SonicWall';        
        eval.UpdateTrackerRecords(acData); 
        
        acData.Acquisition_Source = 'Compellent ; SonicWall';       
        eval.UpdateTrackerRecords(acData); 
       
        List<Set<Id>> PartnerContactIds = new List<Set<Id>>();
        Set<Id> pcSet = new Set<Id>();
        pcSet.add(lstContact.get(0).id);
        pcSet.add(lstContact.get(1).id);        
        pcSet.add(lstContact.get(2).id);
        pcSet.add(lstContact.get(3).id);
        PartnerContactIds.add(pcSet);
        
        pcSet = new Set<Id>();
        pcSet.add(lstContact.get(2).id);
        pcSet.add(lstContact.get(3).id);        
        pcSet.add(lstContact.get(4).id);
        pcSet.add(lstContact.get(5).id);
        PartnerContactIds.add(pcSet);
        
        pcSet = new Set<Id>();
        pcSet.add(lstContact.get(6).id);
        pcSet.add(lstContact.get(7).id);        
        pcSet.add(lstContact.get(8).id);
        pcSet.add(lstContact.get(9).id);
        PartnerContactIds.add(pcSet);
        
        pcSet = new Set<Id>();
        pcSet.add(lstContact.get(10).id);
        pcSet.add(lstContact.get(11).id);       
        pcSet.add(lstContact.get(12).id);
        pcSet.add(lstContact.get(13).id);
        PartnerContactIds.add(pcSet);
        
        eval.chkUniqueContact(PartnerContactIds);
        Test.stopTest();
    }
    
}