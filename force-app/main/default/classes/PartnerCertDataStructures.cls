/******************************************************************************** 
Name        : PartnerCertDataStructures
Description : Used in NetExam Certification Evaluation Functionality. 
              This class defines the data structure used. 
---------------------------------------------------------* 
  Revision  Name            Date        CR#     Description
* 1.0       Meghana Gupta   11.06.2012  CR      Data Structure defined 
* 2.0       Krishnamoorthi  18.09.2012          Modified for R13.10 Maintenance CR 7290 
* 3.0       Meghana Gupta   10.12.2012          Release 14.2 -- Allow Multiple Demos, Demo Unit Missing Alert, 
                                                Populate Certification Completed.
************************************************************************************/

global with sharing class PartnerCertDataStructures {
    
    global enum CriteriaType{CERTIFICATION_REQUIREMENT, SALES_TRAINING_CRITERIA, 
                                   TECH_TRAINING_CRITERIA, GENERAL_TRAINING_CRITERIA, DEMO_UNIT }
     
    //Wrapper class AccountData....................
    global class AccountData{   
        global Id AccountId;      
        global String AcctName;  
        global String Country_code;
        global Id CountryId;
        global String Region;
        global String Partner_Relationship;
        global String Acquisition_Source;
//        global Map<String, String> courseIdToNameMap = new Map<String, String>();        
        global Map<Id, Set<String>> partnerCourseMap = new Map<Id, Set<String>>(); 
        global Set<String> CourseCodeList = new Set<String>();
        
        /*ex. ContactId Set<String>  {Course1 ID,   Course2 ID}*/
                            
        global Map<ID, Integer> DemoUnits = new  Map<ID, Integer>();
        global Map<ID, String> DemoId_NameMap = new  Map<ID, String>();
       // global Map<String, Integer> DemoUnits = new  Map<String, Integer>();
        global boolean DemoCriteriaMet=false;
        global boolean Final_DemoCriteriaMet=false;
        global boolean TrainingCriteriaMet=false;
        global boolean PremierCriteriaEnable = false;
        global Set<String> Certification_Area = new Set<String>();
        global Set<String> demoUnitsPurchased = new Set<String>();
        global Set<String> Certification_Completed = new Set<String>();
        global Map<Id,PartnerCertDataStructures.Criteria> IdToCriteriaObjectMap = new Map<Id,PartnerCertDataStructures.Criteria>();
        global Set<Certification_Requirement_Setup__c> Success_Reqmts = new Set<Certification_Requirement_Setup__c>();
        global Map<Id,Boolean> ReqmtsEvaluated = new Map<Id,Boolean>();    
        global String CertNames_for_DemoAlert = '';  
                
        //Map<String, String> CriteriaEvaluationResult = new List<String, String>();// this stores the evaluation result for evaluated criterias. Not a mandatory variable!!
        
       // global Map<String, List<Set<Id>>> PartnerCourseDetails = new Map<String, List<Set<Id>>>() ;    // This is for tracking the unique partners across the Sales and Tech trainings.
            /*examples:{            
                'Sales' =>  List{ 
                                set{con1, con2},
                                Set{con2, con4}
                            },
                'Tech' =>  List{ 
                                Set{con1, con2},
                                Set{con2, con4}
                            }
                }
        */
        global MAP<String,Map<String, List<Set<Id>>>> PartnerCourseDetails = new Map<String, Map<String, List<Set<Id>>>>() ;    // This is for tracking the unique partners across the Sales and Tech trainings.
            /*examples:{            
                'Sales' =>  FST ->List{ set{con1, con2},  Set{con2, con4} },
                            SST -> List { set{con1, con5} , set {con6, con 7} }
                'Tech' =>   FTT ->List{ set{con1, con2},  Set{con2, con4} },
                            STT -> List { set{con1, con5} , set {con6, con 7} }
                'General' =>
                }
        */
        
        //constructors for basic initialization 
        global AccountData(Id acctId){          
        //  this.AcctId = acctId;
            AccountId = acctId;                      
            Account acc = [SELECT id,name, Account_Country_Code__c,Partner_Relationship__c,Acquisition_Source__c,
                            (SELECT Contact__c, Course_Id__c,Course_Name__c,Course_Code__c 
                                FROM Partner_Courses__r 
                                where Course_Status__c = 'Completed' or Course_Status__c = 'Expired' ) ,
                            //Rev 2.0
                            //(Select Name, Demo_Unit_Type__c  from Demo_Units__r)
                            (Select Name, Demo_Unit_Setup_Name__c , Demo_Unit_Setup__c 
                                from Demo_Units__r)
                            FROM Account 
                            WHERE id = :acctId];
            
            AcctName = acc.name;
            List<Partner_Course__c> pcList = new List<Partner_Course__c>();
            List<Demo_Unit__c> demoUnit_list = new List<Demo_Unit__c>();
            
            if (acc != null){
                Acquisition_Source = acc.Acquisition_Source__c;
                pcList = acc.Partner_Courses__r;
                demoUnit_list  = acc.Demo_Units__r;
                Country_code = acc.Account_Country_Code__c;
                Partner_Relationship = acc.Partner_Relationship__c;
            }
            //get partner course details for the selected account
            
            for (Partner_Course__c pc : pcList){               
                Set<String> Course_List = new Set<String>();
                if (! partnerCourseMap.isEmpty()){
                    if (partnerCourseMap.containsKey(pc.Contact__c) ){
                        Course_List = partnerCourseMap.get(pc.Contact__c); // get existing Course ID list for the contact                      
                        partnerCourseMap.remove(pc.Contact__c); //remove old record from map
                    }                    
                }
                system.debug('Test--pc.Course_Code__c : ' + pc.Course_Code__c);
                // Course_List.add( pc.Course_ID__c);
                Course_List.add( pc.Course_Code__c );
                partnerCourseMap.put(pc.Contact__c, Course_List);
                
                if (!CourseCodeList.contains(pc.Course_Code__c))
                    CourseCodeList.add(pc.Course_Code__c);
                //if (!courseIdToNameMap.containsKey(pc.Course_ID__c)){
                //    courseIdToNameMap.put(pc.Course_ID__c, pc.Course_Code__c );
                //}
                
            } //for each partner course record
            
            for (Demo_Unit__c demo : demoUnit_list){
                Integer NoOfdemo = 0;
                //Rev 2.0
                //String demo_type =  demo.Demo_Unit_Type__c.toUpperCase();   
                /*String demo_type =  demo.Demo_Unit_Setup_Name__c.toUpperCase();
                
                if (!DemoUnits.isEmpty()){
                    if (DemoUnits.containsKey(demo_type ) ){
                        NoOfdemo = DemoUnits.get(demo_type ); // get existing count                     
                        DemoUnits.remove(demo_type ); //remove old record from map
                    }
                }   
                NoOfdemo = NoOfdemo + 1; //increment demo count
                DemoUnits.put(demo_type , NoOfdemo);    
                */
                // Rev.3
                if (!DemoUnits.isEmpty()){
                    if (DemoUnits.containsKey(demo.Demo_Unit_Setup__c) ){
                        NoOfdemo = DemoUnits.get(demo.Demo_Unit_Setup__c); // get existing count                     
                        DemoUnits.remove(demo.Demo_Unit_Setup__c ); //remove old record from map
                    }
                }   
                NoOfdemo = NoOfdemo + 1; //increment demo count
                DemoUnits.put(demo.Demo_Unit_Setup__c , NoOfdemo);   
                DemoId_NameMap.put(demo.Demo_Unit_Setup__c , demo.Demo_Unit_Setup_Name__c) ;
            }//for          
        } //constructor
    }   
    global virtual Class Criteria{ 
     //root class
        global Certification_Criteria_Setup__c criteria;
        global CriteriaType cr_type;
        //global Map <String, Integer> demoRequirmentMap = new Map <String, Integer>();
        global integer noOfDemoUnits;       
        global String cr_name ;
        global String postFixCriteriaExpression; //  String in post fix notation
        global List<String> criteriaExpressionItemList;   // in list format
        
        global Criteria(){
            
        }
        global Criteria(Certification_Criteria_Setup__c tmpCriteria){            
           criteria = tmpCriteria;
            cr_name = criteria.Certification_Criteria_Name__c;
            if (cr_name == 'Demo Unit'){
                cr_type = CriteriaType.DEMO_UNIT; 
                noOfDemoUnits = integer.valueOf(criteria.Number_of_Demo_Units__c);
                postFixCriteriaExpression = criteria.Criteria_Value_Ids_PostFixFormat__c;
                criteriaExpressionItemList =  criteria.Criteria_Value_Ids__c.split(';');
                //demoRequirmentMap.put(criteria.Certification_Criteria_Value__c, integer.valueOf(criteria.Number_of_Demo_Units__c));
            }
            else if (cr_name == 'First Sales Training' || cr_name == 'Second Sales Training' || cr_name == 'Third Sales Training' || cr_name == 'Fourth Sales Training'){
                cr_type = CriteriaType.SALES_TRAINING_CRITERIA;    
                postFixCriteriaExpression = criteria.Criteria_Value_Ids_PostFixFormat__c;
                criteriaExpressionItemList =  criteria.Criteria_Value_Ids__c.split(';');                         
            }
            else if (cr_name == 'First Technical Training' || cr_name == 'Second Technical Training' || cr_name == 'Third Technical Training' || cr_name == 'Fourth Technical Training'){
                cr_type = CriteriaType.TECH_TRAINING_CRITERIA;     
                postFixCriteriaExpression = criteria.Criteria_Value_Ids_PostFixFormat__c;
                criteriaExpressionItemList =  criteria.Criteria_Value_Ids__c.split(';');                         
                    
            }
            else if (cr_name == 'General Training Criteria' ){
                cr_type = CriteriaType.GENERAL_TRAINING_CRITERIA;  
                postFixCriteriaExpression = criteria.Criteria_Value_Ids_PostFixFormat__c;
                criteriaExpressionItemList =  criteria.Criteria_Value_Ids__c.split(';');          
            }
        }
    }
    global Class DemoCriteria extends Criteria{   
        global DemoCriteria(){          
        }
    }
    global Class CriteriaWithExpression extends Criteria{  
        global CriteriaWithExpression(String expression,String delimitter){
            postFixCriteriaExpression = expression;
            criteriaExpressionItemList = expression.split(delimitter);      
        }    
    }       
                                 
}