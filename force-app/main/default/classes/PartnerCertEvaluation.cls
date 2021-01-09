/******************************************************************************** 
Name        : PartnerCertEvaluation 
Description : Used in NetExam Certification Evaluation Functionality. 
              This class contains the evaluation logic. 
---------------------------------------------------------* 
  Revision  Name            Date        CR#     Description
* 1.0       Meghana Gupta   11.06.2012  CR      Evaluation logic 
* 2.0       Meghana Gupta   10.29.2012          Evaluate one account at a time. Check Prerequisites.
                                                Handle 'Too Many Script Statements' Error.
* 3.0       Meghana Gupta   10.12.2012          Release 14.2 -- Allow Multiple Demos, Demo Unit Missing Alert, 
                                                Populate Certification Completed.
* 4.0       Sree Prakash    01.01.2014  9041    Premier Partner to have eight unique people to complete the required training.  
* 5.0       Jaya Kumar      12.02.2014  CRQ0895 Manually_Added_Competency__c set to false for custom object Certified By Competency                                     
************************************************************************************/


global class PartnerCertEvaluation {    
    ExpressionUtils ExpUtils = new ExpressionUtils(); // class in which many functions are defined
        
    //map to store Requirement setup details for a country for each Certification Name
    Map<String, Map<String, List<Certification_Requirement_Setup__c>>>  nameToCountryCertReqSetupMap = new  Map<String, Map<String, List<Certification_Requirement_Setup__c> >>();
    
    //map to store criteria id to criteria instance -criteria record details
    integer cnt=0;
    PartnerCertDataStructures.AccountData acData;    
    Boolean HasDemoCriteria;
    String currCriteriaType ='';
    string Different_CRS_For_Same_Region = '';
    String DellCompetencies = '', CertCompletedInclude = '';
   
    global String Evaluate(ID AcctId){                 
      try{  
            
            String Evaluation_result = null;
            // PartnerCertDataStructures.AccountData will get account details along with demo units and partner course records
           acData = new PartnerCertDataStructures.AccountData(AcctId);        
           //get country details from country codes    
            if (acData.Country_code != null){
                Country__c acct_country = [select id,name, Code__c, region__c 
                                        from Country__c
                                        where Code__c = :acData.Country_code limit 1];            
                
                if (acct_country != null){  
                    acData.CountryId = acct_country.id;   
                    if (acData.Country_code == 'US'){
                        acData.Region = 'US';
                    }
                    else if (acData.Country_code == 'CA'){
                        acData.Region = 'Canada';
                    }
                    else{
                        if ( acct_country.region__c == 'EC-EMEA')
                            acData.Region = 'EMEA-EM';
                        else
                            acData.Region = acct_country.region__c;                     
                    }
                }
            }
            if ( acData.partnerCourseMap.keyset().size() <= integer.valueOf(System.Label.NetExam_BatchContactCount)){
                List<String> Certifications = getCertificationNames();  
                getRequirementSetups(Certifications,acData);          
                boolean result = EvaluateAllCriterias(Certifications); 
                system.debug('Test--Certifications : ' + Certifications);   
                system.debug('Test--result : ' + result);   
                if (result){
                    UpdateTrackerRecords(acData);
                    Evaluation_result = 'Success';
                }
            }
            else{
                Evaluation_result = 'BatchJob';
                 // Get Email address of logged in user            
                String email = [Select email from user where id = :UserInfo.getUserId()].email;             
                id batchinstanceid = database.executeBatch(new NetExam_EvaluateAccount(acData, email),1); // evaluate one reqmt at a time      
                
                      
            }
            return Evaluation_result;
      }//try      
     catch(Exception ex){  
        system.debug('###DEBUG### Error Evaluate -- '+ex.getMessage());
         return null;   
      }
    }   
    global List<String> getCertificationNames(){
          //.... get all valid certification names from the picklist values 
        List<String> Certifications = new List<string>();
        Schema.DescribeFieldResult CertificationName_field = Certification_Requirement_Setup__c.Certification_Name__c.getDescribe();
        for (Schema.PicklistEntry f : CertificationName_field.getPicklistValues()){
            Certifications.add(f.getLabel());
        }
        system.debug('Test--Certifications : ' + Certifications);        
        return Certifications;
    }  
    global boolean getRequirementSetups( List<String> Certifications, PartnerCertDataStructures.AccountData tmp_acData){
        acData = tmp_acData;
        //get Requirement setup and related criteria details for all Certifications for all countries in the above list and global requirements
        List<Certification_Criteria_Setup__c> Criteria_list = new List<Certification_Criteria_Setup__c>();
        system.debug('Test--Criteria_list.size() : ' + Criteria_list.size());
                      
        for (Certification_Requirement_Setup__c r : [select id, Criteria_Rule__c ,  Country__c,
                                                        Apply_Requirement_To__c, Certification_Name__c , Region__c,
                                                        Acquisition__c, Prerequisites__c, Prerequisite_Count__c,
                                                          (select id, name,Certification_Requirement_Setup__c,
                                                         Certification_Criteria_Name__c, Condition__c,
                                                         Criteria_Value_Ids__c, Number_of_Demo_Units__c ,
                                                         Criteria_Value_Ids_PostFixFormat__c,
                                                         Certification_Criteria_Value__c
                                                         from Certification_Criteria_Setups__r ),                                                         
                                                         (select id, Certification_Requirement_Setup__c, Condition__c,
                                                            Prerequisites__c, Prerequisites_Ids__c                                                            
                                                            from Certification_Prerequisites_Setups__r)
                                                      from Certification_Requirement_Setup__c
                                                      where ((Country__c = :acData.CountryId and Apply_Requirement_To__c = 'Country')
                                                      OR (Region__c = :acData.Region and Apply_Requirement_To__c = 'Region')
                                                      OR Apply_Requirement_To__c = 'Global')                                                              
                                                      and Active__c = true                                                          
                                                      and Certification_Name__c in :Certifications ])
        {
           // if (r.Criteria_Rule__c != null && r.Criteria_Rule__c  != ''){     

            if (isValidRequirmentSetup(r) == true){   
                String c_code ; 
                if (r.Apply_Requirement_To__c == 'Global')
                    c_code  = 'Global';
                else if (r.Apply_Requirement_To__c == 'Region')
                    c_code  = acData.Region ;
                else
                    c_code  = acData.Country_code;                    
                   
                Map<String, List<Certification_Requirement_Setup__c>> tmpMap_Code_to_Rqmt;                
                if (nameToCountryCertReqSetupMap.get(r.Certification_Name__c) == null)
                    tmpMap_Code_to_Rqmt  = new Map<String, List<Certification_Requirement_Setup__c>>();
                else  
                    tmpMap_Code_to_Rqmt = nameToCountryCertReqSetupMap.get(r.Certification_Name__c);
               
                List<Certification_Requirement_Setup__c> tmpListReqmt = new List<Certification_Requirement_Setup__c>() ;
                if (tmpMap_Code_to_Rqmt.containsKey(c_code)){
                    tmpListReqmt = tmpMap_Code_to_Rqmt.get(c_code);
                }
                tmpListReqmt.add(r);
                tmpMap_Code_to_Rqmt.put(c_code , tmpListReqmt);                                                   
                nameToCountryCertReqSetupMap.put(r.Certification_Name__c,tmpMap_Code_to_Rqmt);
                if (!r.Certification_Criteria_Setups__r.isEmpty())
                    Criteria_list.addAll(r.Certification_Criteria_Setups__r);
            }
        }        
        //for all certification requirement ids --- get criteria details in the map                 
        for (Certification_Criteria_Setup__c criteria : Criteria_list){                             
            PartnerCertDataStructures.Criteria Cr = new PartnerCertDataStructures.Criteria(criteria); 
            acData.IdToCriteriaObjectMap.put(criteria.id, Cr);          
        }       
        return true;
    }
    global list<Id> getRequriementIds( List<String> Certifications, PartnerCertDataStructures.AccountData tmp_acData){
        list<Id> reqmtIds = new list<Id>();
        getRequirementSetups(Certifications,tmp_acData);
         // for each certification type 
        for (String cert : Certifications ) {            
            Map<String, List<Certification_Requirement_Setup__c>> country_reqSetup = nameToCountryCertReqSetupMap.get(cert);                
            if (country_reqSetup != null){
                List<Certification_Requirement_Setup__c> certRequirment_lst = country_reqSetup.get(tmp_acData.Country_code);
                if (certRequirment_lst == null){
                    certRequirment_lst = country_reqSetup.get(tmp_acData.Region);
                }
                if (certRequirment_lst == null){
                    certRequirment_lst = country_reqSetup.get('Global');
                }
                
                for (Certification_Requirement_Setup__c certRequirment : certRequirment_lst ){
                    if (certRequirment.Prerequisites__c == true && certRequirment.Prerequisite_Count__c==0){
                        continue; //dont check reqmt
                    }
                    else if(certRequirment.Prerequisites__c == true && certRequirment.Prerequisite_Count__c>0){
                        reqmtIds.add(certRequirment.id);
                    }
                    else
                       reqmtIds.add(certRequirment.id);                
                }    //for            
              }
        }//cert         
        return reqmtIds;
    }
    global PartnerCertDataStructures.AccountData evaluateReqmt_BatchClass(PartnerCertDataStructures.AccountData tmpacData,Certification_Requirement_Setup__c certRequirment){
        boolean result;
        acData = tmpacData;
        //IdToCriteriaObjectMap = new Map<Id,PartnerCertDataStructures.Criteria>();
         for (Certification_Criteria_Setup__c criteria : certRequirment.Certification_Criteria_Setups__r){                    
            PartnerCertDataStructures.Criteria Cr = new PartnerCertDataStructures.Criteria(criteria);            
            tmpacData.IdToCriteriaObjectMap.put(criteria.id, Cr);
        }   
        if(certRequirment.Prerequisites__c == true && certRequirment.Prerequisite_Count__c>0){                        
            result = evaluatePrerequisite(certRequirment);
            if (result){
                result = evaluateRequirementSetup(certRequirment);
            }
         }
         else
            result = evaluateRequirementSetup(certRequirment);  
        
        return acData;
    }
    /*global PartnerCertDataStructures.AccountData evaluatePrerequisite_BatchClass(PartnerCertDataStructures.AccountData tmpacData,Certification_Requirement_Setup__c rqmt){
        acData = tmpacData;
        evaluateRequirementSetup(rqmt);
        return acData;
    }*/
    public Boolean EvaluateAllCriterias (List<String> Certifications){        
        String finalResult, item1, item2;           
        ExpressionUtils.Stack resultStack = new ExpressionUtils.Stack();  // stack for result handling           
        String operator;
        
        // for each certification type 
        for (String cert : Certifications ) {
            currCriteriaType = '';
            Map<String, List<Certification_Requirement_Setup__c>> country_reqSetup = nameToCountryCertReqSetupMap.get(cert);
                
            if (country_reqSetup != null){
                List<Certification_Requirement_Setup__c> certRequirment_lst = country_reqSetup.get(acData.Country_code);
                if (certRequirment_lst == null){
                    certRequirment_lst = country_reqSetup.get(acData.Region);
                }
                if (certRequirment_lst == null){
                    certRequirment_lst = country_reqSetup.get('Global');
                }                
                for (Certification_Requirement_Setup__c certRequirment : certRequirment_lst ){
                    if (certRequirment.Prerequisites__c == true && certRequirment.Prerequisite_Count__c==0){
                        continue; //dont check reqmt
                    }
                    else if(certRequirment.Prerequisites__c == true && certRequirment.Prerequisite_Count__c>0){                        
                        boolean result = evaluatePrerequisite(certRequirment);
                        if (result){
                            evaluateRequirementSetup(certRequirment);
                        }
                    }
                    else
                       evaluateRequirementSetup(certRequirment);               
                }    //for            
              }
            }//cert      
         return true;  
    }//EvaluateAllCriterias
           
    global boolean evaluatePrerequisite(Certification_Requirement_Setup__c certRequirment){  
        ExpressionUtils ExpUtils = new ExpressionUtils();
        Boolean finalResult = false;
        for (Certification_Prerequisites_Setup__c cpSetup :  certRequirment.Certification_Prerequisites_Setups__r){         
            //get postfix expression from hidden field
            List<String> prerequisiteList = cpSetup.Prerequisites_Ids__c.split(';');
            //List<String> prerequisiteList = cpSetup.PrerequisiteIds_PostfixExp__c.split(';');
           
            Integer x=0 ;
            if (cpSetup.Condition__c == 'All' || cpSetup.Condition__c == null){
                x = prerequisiteList.size();
            }           
            else{
                //List<String> strCond = cpSetup.Condition__c.split(' '); // Any 1 or Any 2 or Any 3
                String cond = cpSetup.Condition__c.right(cpSetup.Condition__c.length()-3).trim();
                x = integer.valueOf(cond);
            }                
            if (x<=0){
                return false;
            }
            
            Integer counter = 0;  
            integer evaluatedConditions = 0;    
            finalResult = false;
            for (String micro_criteria : prerequisiteList){
                micro_criteria = ExpUtils.convertInFixToPostFixNotation(micro_criteria );//not required if postfix - field used
                Boolean result =  evaluatePrerequisiteOption(micro_criteria);    
                evaluatedConditions++;
                if(result==true){
                    counter++;
                }   
                if (counter >= x){
                    finalResult = true;
                    break;
                }
                else if (counter+(prerequisiteList.size()-evaluatedConditions) < x){
                    //Ex. total conditions = 5,  Condition = 3 ...Counter = 0 (only one condition is completed) and evaluatedConditions=3
                    // 0 + (5-3) == 2 --- i.e. even after evaluating next conditions, ANY 3 --can not be achieved...so skip next conditions.
                    finalResult = false;
                    break;
                }                
            }//end of micro criteria iteration
            
            if (!finalResult){
                return false; 
            }      
        }
        return finalResult;
    }    
    
    public boolean evaluatePrerequisiteOption(String micro_criteria){ 
        List<String> mCriteria = micro_criteria.split(' ');
        String tmpResult;
        if (mCriteria.size() == 1){
            tmpResult = evaluatePrerequisite_Operand(mCriteria.get(0));
        }
        else{
            ExpressionUtils.Stack resultStack = new ExpressionUtils.Stack();        
            String operand1, operand2;
                
            for (String item : mCriteria){
                 if (! ExpUtils.isOperator(item)){
                    resultStack.push(item);
                }           
                else if (ExpUtils.isOperator(item)){
                    operand1 = resultStack.pop();
                    operand2 = resultStack.pop();           
                    if(!ExpUtils.isEvaluated(operand1)){ 
                       operand1 = evaluatePrerequisite_Operand(operand1);                  
                    }                   
                    if(!ExpUtils.isEvaluated(operand2)){ 
                         operand2 = evaluatePrerequisite_Operand(operand2);                    
                    }             
                    resultStack.push(ExpUtils.evaluateSimpleCondition(operand1, operand2, item));
                } 
            }// end of for loop - end of expression evaluation. So what left in stack would be the final result
            
            tmpResult = resultStack.pop();        
            if(!ExpUtils.isEvaluated(tmpResult)){
                  tmpResult = evaluatePrerequisite_Operand(tmpResult);         
            }
        } 
        return ExpUtils.StrToBool(tmpResult); 
    }
    
    public String evaluatePrerequisite_Operand(String operand){    
        String oprType = operand.left(3);
        operand = operand.Right(operand.length() - 3); // get operand code
 
        if (oprType == 'CC_'){
            //if operand is course code --- starts with CC_ i.e. Prerequisite option is Course
           
            return ExpUtils.BoolToStr(acData.CourseCodeList.contains(operand));
        }
        else{
            //else if operand is requirement setup --- starts with CR_  i.e. Prerequisite option is Requirement Setup
            List<Certification_Requirement_Setup__c> r =[select id, Criteria_Rule__c ,  Country__c,
                                                        Apply_Requirement_To__c, Certification_Name__c , Region__c,
                                                        Acquisition__c, Prerequisites__c, 
                                                          (select id, name,Certification_Requirement_Setup__c,
                                                         Certification_Criteria_Name__c, Condition__c,
                                                         Criteria_Value_Ids__c, Number_of_Demo_Units__c ,
                                                         Criteria_Value_Ids_PostFixFormat__c,
                                                         Certification_Criteria_Value__c
                                                         from Certification_Criteria_Setups__r ),                                                         
                                                         (select id, Certification_Requirement_Setup__c, Condition__c,
                                                            Prerequisites__c, Prerequisites_Ids__c
                                                            from Certification_Prerequisites_Setups__r)
                                                      from Certification_Requirement_Setup__c
                                                      where id = :operand 
                                                      and Active__c = true];
            
            if (r.isEmpty())
                return ExpUtils.sFALSE; 
            else{
                if (isValidRequirmentSetup(r.get(0)) == true)
                    return ExpUtils.BoolToStr(evaluateRequirementSetup(r.get(0)));             
                else
                    return ExpUtils.sFALSE;                 
            }
        }        
        return ExpUtils.sFALSE;         
    }     
    
    global boolean evaluateRequirementSetup(Certification_Requirement_Setup__c certRequirment ){
      
        String finalResult, item1, item2;           
        ExpressionUtils.Stack resultStack = new ExpressionUtils.Stack();  // stack for result handling           
        String operator, result;
        Boolean RemqtComplete = false;
                
        if (acData.ReqmtsEvaluated.containsKey(certRequirment.id)){
            
            return acData.ReqmtsEvaluated.get(certRequirment.id);  
        }                
        
        acData.PartnerCourseDetails.clear();
        HasDemoCriteria = false;
        String Requirement_Criteria_Rule = ExpUtils.convertInFixToPostFixNotation(certRequirment.Criteria_Rule__c); // postfix format
        
        List<String> req_Criteria_rule = Requirement_Criteria_Rule.split(' ');                
        for (String crStr : req_Criteria_rule ){   
            if (! ExpUtils.isOperator(crStr)) {
                 resultStack.push(crStr);  
            }
            else{                               
                 operator = crStr;
                 item1 = resultStack.pop();
                 item2 = resultStack.pop();
                 result = evaluateExpression(item1, item2, operator);
                 resultStack.push(result);             //pushing the result to the resultStack
           }
       }//end of for                
       finalResult = resultStack.pop();                  
       if (!ExpUtils.isEvaluated(finalResult)){                           
            finalResult = evaluateCriteria(finalResult);                            
       }                
       //only if the result is true, unique partner users for the trainings are to be checked.
       if(ExpUtils.isTrue(finalResult) && currCriteriaType == 'TRAINING'){
            //evaluate for the duplicates. if the evaluation result is true then final result is true.
            finalResult = checkTrainingUniquePartners();
       } 
         
      //identify which certification requirement it is and assign a proper value to the account object => certification areas set.    
      if (ExpUtils.isTrue(finalResult)){
        if(currCriteriaType != ''){                         
            acData.TrainingCriteriaMet = true;
            acData.Certification_Completed.add(certRequirment.Certification_Name__c);
            if (acData.TrainingCriteriaMet == true && ((HasDemoCriteria == true && acData.DemoCriteriaMet == true) || HasDemoCriteria == false )){                
                acData.Certification_Area.add(certRequirment.Certification_Name__c);
                acData.Success_Reqmts.add(certRequirment);
                RemqtComplete = true;               
            }
            else if (acData.TrainingCriteriaMet == true && HasDemoCriteria == true && acData.DemoCriteriaMet == false ){    
                if (acData.CertNames_for_DemoAlert == ''){
                    acData.CertNames_for_DemoAlert = certRequirment.Certification_Name__c;
                }
                else{
                    acData.CertNames_for_DemoAlert = acData.CertNames_for_DemoAlert + ';' + certRequirment.Certification_Name__c;
                }
            }            
        }//if currCriteriaType !=''          
      }//if ExpUtils.IsTrue(finalResult)
      acData.ReqmtsEvaluated.put(certRequirment.id,RemqtComplete); 
    
      return RemqtComplete;
    }
    
    public String evaluateExpression(String operand1,String operand2,String operator){
        
        List<String> itemList = new List<String>{operand1, operand2}; // adds the operands into a list
        String pivoteOperand, otherOperand;
        integer iteration = 1, pivoteOperandIndex = 0, otherOperandIndex = 1;        
        do{ 
            pivoteOperand = itemList[pivoteOperandIndex];
            otherOperand = itemList[otherOperandIndex];
            if(iteration >= 3 && ! ExpUtils.isEvaluated(pivoteOperand)){   //if iteration== 3 means none of them had been evaluated.(ID, ID, AND/OR)                 
                pivoteOperand = evaluateCriteria(pivoteOperand); // result is directly overwritten to the operand variable and the list element.
                itemList[pivoteOperandIndex] =  pivoteOperand;                
            }               
            if(ExpUtils.isEvaluated(pivoteOperand)){
                /*
                 Commented following lines in order to achieve below given scenario
                 If 1st criteria is First Sales Training and 2nd Criteria is Demo Unit
                 then based on 1st criteria's result 2nd criteria was getting ignored
                 where as we need to evaluate training and demo unit criteria independently.
                */
                /*if (ExpUtils.isTrue(pivoteOperand) && operator =='OR')
                    return ExpUtils.sTRUE;
                else if(ExpUtils.isFalse(pivoteOperand) && operator =='AND') 
                    return ExpUtils.sFalse;
                else */
                if(ExpUtils.isEvaluated(otherOperand)) {
                    return ExpUtils.evaluateSimpleCondition(pivoteOperand, otherOperand, operator);
                }    
            }//if
            //swapping the order    ::  1 >>0 , 0 >>1
            pivoteOperandIndex = (pivoteOperandIndex ==1?0:1) ;
            otherOperandIndex = (otherOperandIndex ==1?0:1);
        
            iteration++;            
        }while(iteration <= 4);
       
        return ExpUtils.sFALSE;
    }    
    public String evaluateCriteria(String criteriaId ){            
        Boolean result;
        if (acData.IdToCriteriaObjectMap == null)
            return ExpUtils.sFALSE;
            
        if (! acData.IdToCriteriaObjectMap.containsKey(criteriaId))
            return ExpUtils.sFALSE;
            
        PartnerCertDataStructures.Criteria criteriaItem = acData.IdToCriteriaObjectMap.get(criteriaId);
                       
         //------------Demo Unit evaluation----------
        if(criteriaItem.cr_type == PartnerCertDataStructures.CriteriaType.DEMO_UNIT){   
            HasDemoCriteria = true;       
            PartnerCertDataStructures.Criteria currentCriteria = acData.IdToCriteriaObjectMap.get(criteriaId);                      
            //result = evaluateDemoUnitCriteria(currentCriteria);
            result = evaluateDemoUnitCertificationCriteria(currentCriteria);            
              
            /* Commented returning 'False', as Requirement Criteria rule has combination of both
               Training and Demo Unit Criteria, if demo unit is false and all other training criteria are
               true then we need to return True for Training Criteria, so need to ignore 
               Demo Unit criteria result, since at present Demo Units are evalauted independetly.   */
            /*                               
            for(String Demounit : currentCriteria.demoRequirmentMap.keySet()){   //chance for null pointer issue?
                // if any required demo unit is not available under account, result is false.
               if(!accntDemoUnits.keySet().contains(Demounit.toUpperCase()) )
               {    
                    //return ExpUtils.sFalse;                                      
                    result = false;
               }
               else{                
                    if (accntDemoUnits.get(Demounit.toUpperCase()) >= currentCriteria.demoRequirmentMap.get(Demounit)){
                        tempResult = true;
                        acData.demoUnitsPurchased.add(DemoUnit);
                    }
                    else
                        tempResult = false;
                                           
                    result = result==null ? tempResult: result && tempResult;
                                        
                    //if(!result) return ExpUtils.sFalse;
               
               }           
                
                   /*  ------TEMP CODE ------------ 27-JUL-2012 --------------- 
                   TEMP static code fix for CRQ - to consider EQL and Compellent as optional to each other
                   i.e. if Demo Unit criteria is EQL and EQL demo unit is not present but Compllent is there, 
                   then criteria is met and vice-versa.
                   THIS IS A TEMPORARY FIX FOR REQUIREMENT WHERE USER CAN SPECIFIY OPTIONAL DEMO UNITS
                   IN NEXT RELEASE THIS CODE NEEDS TO BE CHANGED AND LOGIC SHOULD BE IMPLEMENTED.           
                   -------------------------------------------------------------------------------------------* /
                       if (!result && (Demounit.toUpperCase() == 'EQL DEMO' || Demounit.toUpperCase() == 'COMPELLENT DEMO')){
                           
                           Integer NoOfEQL_InAcct =0;
                           Integer NoOfCompellent_InAcct = 0;
                           
                           if (accntDemoUnits.keySet().contains('COMPELLENT DEMO')) {
                               NoOfCompellent_InAcct = accntDemoUnits.get('COMPELLENT DEMO');
                           }
                           
                           if (accntDemoUnits.keySet().contains('EQL DEMO')){
                               NoOfEQL_InAcct = accntDemoUnits.get('EQL DEMO');
                           }
                           if ((NoOfEQL_InAcct+NoOfCompellent_InAcct) >= currentCriteria.demoRequirmentMap.get(Demounit)){
                                result = true;
                                acData.demoUnitsPurchased.add(DemoUnit);
                            }
                       }
                       /*  ------TEMP CODE ------------ 27-JUL-2012 --------------- * /
            }//for */
            //set democriteria met flag to true for the account
            acData.DemoCriteriaMet = result; 
            if (result)
                acData.Final_DemoCriteriaMet = result;
                
            return ExpUtils.sTrue;    // ExpUtils.BoolToStr(result);     
        }       
        //------------Training evaluation----------
        if(criteriaItem.cr_type == PartnerCertDataStructures.CriteriaType.SALES_TRAINING_CRITERIA 
                || criteriaItem.cr_type == PartnerCertDataStructures.CriteriaType.TECH_TRAINING_CRITERIA
                || criteriaItem.cr_type == PartnerCertDataStructures.CriteriaType.GENERAL_TRAINING_CRITERIA){ 
            
            currCriteriaType = 'TRAINING';          
            PartnerCertDataStructures.Criteria currentCriteria =acData.IdToCriteriaObjectMap.get(criteriaId);
            Map<Id, Set<String>> contactCertMap = acData.partnerCourseMap ;
            //Map<String, String> partnerCourseId_to_NameMap = acData.courseIdToNameMap;
            Boolean tempResult;        
            Set<Id> contactIdSet = EvaluateCertificationCriteria(contactCertMap, currentCriteria ); 
            //calling a method to store all those curresponding contact IDs for unique combination later.
           
           if( !contactIdSet.isEmpty())
               addToAccountTrainingMap (contactIdSet, criteriaItem.cr_type, criteriaItem.cr_name );        
    
            if(contactIdSet==null || contactIdSet.size() == 0){
                return ExpUtils.sFALSE;
            }
            else{             
                return ExpUtils.sTRUE;
            }
        }    
        return ExpUtils.sTRUE;
    } //evaluateCriteria
    
    public boolean  evaluateDemoUnitCertificationCriteria (PartnerCertDataStructures.Criteria criteria ){ 
        //  criteria contatins(cert1 Cert2 OR; Cert3 cert4 OR).  
        ExpressionUtils ExpUtils = new ExpressionUtils();
        List<String> criteriaStrList = criteria.criteriaExpressionItemList;  // criteria.postFixCriteriaExpression.split(';');
 
        String cond = criteria.criteria.Condition__c;        
        integer x; //Integer x = (cond == 'Any 1') ? 1:((cond == 'Any 2')?2:criteriaStrList.size());   //x = X in AnyX(AnyOne:x=1; AnyTwo:x=2)
        if (cond == 'All' || cond ==null){
            x = criteriaStrList.size();
        }
        else{
            cond = cond.right(cond.length()-3).trim();
            x = integer.valueOf(cond);
        }            
        if (x<=0){
            return false;
        }
        Integer counter=0;   
        Integer evaluatedConditions = 0;
       
        Boolean finalResult = false;
        for (String micro_criteria : criteriaStrList){
            micro_criteria = ExpUtils.convertInFixToPostFixNotation(micro_criteria);
            Boolean result =  evaluateDemoUnitCriteria(micro_criteria,criteria);            
            evaluatedConditions++;
            if(result==true){
                counter++;
            }   
            if (counter >= x){
                finalResult = true;
                break;
            }
            else if (counter+(criteriaStrList.size()-evaluatedConditions) < x){
                //Ex. total conditions = 5,  Condition = 3 ...Counter = 0 (only one condition is completed) and evaluatedConditions=3
                // 0 + (5-3) == 2 --- i.e. even after evaluating next conditions, ANY 3 --can not be achieved...so skip next conditions.
                finalResult = false;
                break;
            }           
        }//end of micro criteria iteration
            
        return finalResult;
    }
    
    public boolean evaluateDemoUnitCriteria(String micro_criteria,PartnerCertDataStructures.Criteria criteria){         
        list<String> demounits_purchased = new list<String>();
        //if( criteria.postFixCriteriaExpression == null)
        //    return false;
        
        List<String> mCriteria = micro_criteria.split(' ');
        //list<String> mCriteria = criteria.postFixCriteriaExpression.split(' ');
        String tmpResult;
        if (mCriteria.size() == 1){
            tmpResult = evaluateOperand_DemoUnit(mCriteria.get(0), criteria);
            if (ExpUtils.isTrue(tmpResult)){
                demounits_purchased.add(acData.DemoId_NameMap.get(mCriteria.get(0)));
            }
        }
        else{
            ExpressionUtils.Stack resultStack = new ExpressionUtils.Stack();        
            String operand1, operand2;
            String tmpDemo;            
            for (String item : mCriteria){
                 if (! ExpUtils.isOperator(item)){
                    resultStack.push(item);
                }           
                else if (ExpUtils.isOperator(item)){
                    operand1 = resultStack.pop();
                    operand2 = resultStack.pop();           
                    if(!ExpUtils.isEvaluated(operand1)){ 
                       tmpDemo = operand1;
                       operand1 = evaluateOperand_DemoUnit(operand1,criteria);  
                     
                       if (ExpUtils.isTrue(operand1)){
                            demounits_purchased.add(acData.DemoId_NameMap.get(tmpDemo));
                        }                
                    }
                   
                    if(!ExpUtils.isEvaluated(operand2)){ 
                         tmpDemo = operand2;
                         operand2 = evaluateOperand_DemoUnit(operand2, criteria);
                       
                        if (ExpUtils.isTrue(operand2)){
                            demounits_purchased.add(acData.DemoId_NameMap.get(tmpDemo));
                        }
                    }             
                    resultStack.push(ExpUtils.evaluateSimpleCondition(operand1, operand2, item));
                } 
            }// end of for loop - end of expression evaluation. So what left in stack would be the final result
            
            tmpResult = resultStack.pop();        
            if(!ExpUtils.isEvaluated(tmpResult)){
                tmpDemo = tmpResult;
                tmpResult = evaluateOperand_DemoUnit(tmpResult,criteria); //,partnerCourseId_to_NameMap );        
                if (ExpUtils.isTrue(tmpResult)){
                    //demounits_purchased.add(tmpDemo);
                    demounits_purchased.add(acData.DemoId_NameMap.get(tmpDemo));
                }   
            }
        }           
        if (ExpUtils.isTrue(tmpResult)){
            acData.demoUnitsPurchased.addAll(demounits_purchased);
        }         
        return ExpUtils.StrToBool(tmpResult); 
    }
    
    public String evaluateOperand_DemoUnit(String Demounit,  PartnerCertDataStructures.Criteria criteria){ 
        String result;
        integer noOfDemoUnits = criteria.noOfDemoUnits;
          
        //Map<String, Integer> accntDemoUnits = acData.DemoUnits;
        Map<ID, Integer> accntDemoUnits = acData.DemoUnits;
            
        //if(!accntDemoUnits.keySet().contains(Demounit.toUpperCase()) ){
        if(!accntDemoUnits.keySet().contains(Demounit)){    
            result = ExpUtils.sFalse;
        }
        else{           
             //if (accntDemoUnits.get(Demounit.toUpperCase()) >= noOfDemoUnits){
            if (accntDemoUnits.get(Demounit) >= noOfDemoUnits){
                result = ExpUtils.sTRUE;                
            }
            else{
                result = ExpUtils.sFalse;
            }           
        }  
        return result;          
    }
    
    public Set<Id>  EvaluateCertificationCriteria (Map<Id, Set<String>> ContactToCertMap, PartnerCertDataStructures.Criteria criteria ){ 
        //  criteria contatins(cert1 Cert2 OR; Cert3 cert4 OR).  
        ExpressionUtils ExpUtils = new ExpressionUtils();
        Set<Id> resultantContactIds = new Set<Id>();    
        List<String> criteriaStrList = criteria.criteriaExpressionItemList;  // criteria.postFixCriteriaExpression.split(';');
 
        String cond = criteria.criteria.Condition__c;        
        integer x; //Integer x = (cond == 'Any 1') ? 1:((cond == 'Any 2')?2:criteriaStrList.size());   //x = X in AnyX(AnyOne:x=1; AnyTwo:x=2)
        if (cond == 'All' || cond ==null){
            x = criteriaStrList.size();
        }
        else{
            cond = cond.right(cond.length()-3).trim();
            x = integer.valueOf(cond);
        }            
        if (x<=0){
            return resultantContactIds;
        }
        Integer counter;   
        Integer evaluatedConditions = 0;
        for (Id contactId : ContactToCertMap.keyset()){     
            counter = 0;
            evaluatedConditions = 0;
            Set<String> certIdSet = ContactToCertMap.get(contactId);// set of certificate ids            
            Boolean finalResult = false;
            for (String micro_criteria : criteriaStrList){
                micro_criteria = ExpUtils.convertInFixToPostFixNotation(micro_criteria );
                Boolean result =  evaluateCertificate(micro_criteria, certIdSet);            
                evaluatedConditions++;
                if(result==true){
                    counter++;
                }   
                if (counter >= x){
                    finalResult = true;
                    break;
                }
                else if (counter+(criteriaStrList.size()-evaluatedConditions) < x){
                    //Ex. total conditions = 5,  Condition = 3 ...Counter = 0 (only one condition is completed) and evaluatedConditions=3
                    // 0 + (5-3) == 2 --- i.e. even after evaluating next conditions, ANY 3 --can not be achieved...so skip next conditions.
                    finalResult = false;
                    break;
                }           
            }//end of micro criteria iteration
            if (finalResult){
                resultantContactIds.add(contactId);
                if (resultantContactIds.size() == 4)
                    break;
            }
        }//end of contact map iteration        
        return resultantContactIds;
    }
    public boolean evaluateCertificate(String micro_criteria,Set<String> certIdSet){ 
        List<String> mCriteria = micro_criteria.split(' ');
        String tmpResult;
        if (mCriteria.size() == 1){
            tmpResult = evaluateOperand(mCriteria.get(0),certIdSet);
        }
        else{
            ExpressionUtils.Stack resultStack = new ExpressionUtils.Stack();        
            String operand1, operand2;          
            for (String item : mCriteria){
                 if (! ExpUtils.isOperator(item)){
                    resultStack.push(item);
                }           
                else if (ExpUtils.isOperator(item)){
                    operand1 = resultStack.pop();
                    operand2 = resultStack.pop();           
                    if(!ExpUtils.isEvaluated(operand1)){ 
                        operand1 = evaluateOperand(operand1,certIdSet); //,partnerCourseId_to_NameMap);                   
                    }                  
                    if(!ExpUtils.isEvaluated(operand2)){ 
                        operand2 = evaluateOperand(operand2,certIdSet); //,partnerCourseId_to_NameMap);                   
                    }             
                    resultStack.push(ExpUtils.evaluateSimpleCondition(operand1, operand2, item));
                } 
            }// end of for loop - end of expression evaluation. So what left in stack would be the final result
            
            tmpResult = resultStack.pop();        
            if(!ExpUtils.isEvaluated(tmpResult)){
                tmpResult = evaluateOperand(tmpResult,certIdSet); //,partnerCourseId_to_NameMap );        
            }
        }
        return ExpUtils.StrToBool(tmpResult); 
    }
    
    public String evaluateOperand(String operand,Set<String> certIdSet){        
        return ExpUtils.BoolToStr(certIdSet.contains(operand));          
    }    
    public void addToAccountTrainingMap (Set<Id> contactIdSet, PartnerCertDataStructures.CriteriaType crType, String cr_name ){     
        Map<String, Map<String, List<Set<Id>>>> partnerCourseMap = acData.PartnerCourseDetails;
        String ctype;        
        /* -------------------------------------------------
            SALES AND TECHNICAL PEOPLE SHOULD BE ALL UNIQUE
           --------------------------------------------------  */
        if(crType == PartnerCertDataStructures.CriteriaType.SALES_TRAINING_CRITERIA){            
            ctype = 'SALES_TECH';
        }   
        else if(crType == PartnerCertDataStructures.CriteriaType.TECH_TRAINING_CRITERIA){            
            ctype = 'SALES_TECH';
        }
        else if(crType == PartnerCertDataStructures.CriteriaType.GENERAL_TRAINING_CRITERIA){
            ctype = 'General';
        }           
        else return;
        
        if(partnerCourseMap == null){              
            partnerCourseMap = new Map<String, Map<String, List<Set<Id>>>>();
        }
        if(partnerCourseMap.get(ctype)==null){  
            Map<String, List<Set<Id>>> tmpMap = new Map<String, List<Set<Id>>>();
            tmpMap.put(cr_name , new List<Set<Id>>{contactIdSet});
            partnerCourseMap.put(ctype,tmpMap);                   
        }
        else{           
            if(partnerCourseMap.get(ctype).get(cr_name)==null){  
                Map<String, List<Set<Id>>> tmpMap = partnerCourseMap.get(ctype);
                tmpMap.put(cr_name , new List<Set<Id>>{contactIdSet});
                partnerCourseMap.put(ctype,tmpMap);
            
            }
            else{
                partnerCourseMap.get(ctype).get(cr_name).add(contactIdSet);   
           }
        }               
    }//addToAccountTrainingMap     
    
    public String checkTrainingUniquePartners(){        
        Map<String, Map<String, List<Set<Id>>>> partnerCourseMap = acData.PartnerCourseDetails;
        for (String type: partnerCourseMap.keySet()){  
            if (type != 'General'){                       
               // Set<id> consolidatedSet = new Set<id>();            
                List<Set<id>> consolidatedSet_tmpList = new List<Set<id>>(); 
                           
                for (String crName : partnerCourseMap.get(type).keySet()){
                    /* ....For same type of criteria record (say First  Sales Training )   Check if there is atleast one common contact who has done both group of course 
                    i.e. One contact that is satisfying both criteria of same type  if Intersection of contact set has atleast one value    */
                    
                    Set<id> tmp_consolidatedSet = new Set<id>();  
                    for (Set<id> contactIdSet : partnerCourseMap.get(type).get(crName) ){
                        if(contactIdSet==null || contactIdSet.size()==0)
                            return ExpUtils.sFALSE;                        
                        if (tmp_consolidatedSet.isEmpty()){
                            tmp_consolidatedSet.addAll(contactIdSet);
                        }
                        else{
                            tmp_consolidatedSet.retainAll(contactIdSet);
                        }
                    }
                    if(tmp_consolidatedSet==null || tmp_consolidatedSet.size()==0)
                        return ExpUtils.sFALSE;
                            
                    consolidatedSet_tmpList.add(tmp_consolidatedSet);
                }
                system.debug('Test--consolidatedSet_tmpList.size() : ' + consolidatedSet_tmpList.size() );
                system.debug('Test--consolidatedSet_tmpList : ' + consolidatedSet_tmpList);
                Different_CRS_For_Same_Region = Different_CRS_For_Same_Region + consolidatedSet_tmpList.size();
                system.debug('Test--Different_CRS_For_Same_Region1 : ' + Different_CRS_For_Same_Region);

                boolean result = chkUniqueContact(consolidatedSet_tmpList );
                if (!result)
                    return ExpUtils.sFALSE;                
            }//if
        }//for             
        return ExpUtils.sTRUE;   
    }    
    public boolean chkUniqueContact(List<Set<Id>> PartnerContactIds){
        Integer Training_Type_Count = PartnerContactIds.size();
        //Set<String> Training_Type_Count_All = new Set<String>();        
        //Training_Type_Count_All.add(Training_Type_Count_All + string.valueOf(PartnerContactIds.size()));
        //Training_Type_Count_All = string.valueOf(Training_Type_Count_All) + ' ' + string.valueOf(PartnerContactIds.size());
        
        // CR# 9041 (8035): #1 - START
        // If there are 8 unique trainings, PremierCriteriaEnable checkbox will be checked, else, unchecked.
        system.debug('Test--Training_Type_Count : ' + Training_Type_Count); 
        //system.debug('Test--Training_Type_Count_All : ' + Training_Type_Count_All); 
        system.debug('Test--Training_Type_Count : ' + PartnerContactIds);
        system.debug('Test--Different_CRS_For_Same_Region2 : ' + Different_CRS_For_Same_Region);
        if(Training_Type_Count == 8 || Different_CRS_For_Same_Region.contains('8') == true){
            acData.PremierCriteriaEnable = true;
        }
        else{
            acData.PremierCriteriaEnable = false;
        }
        // CR# 9041 (8035): #1 - END
                       
        Set<id> consolidatedSet = new Set<id>();            
        if ( Training_Type_Count <= 2){
            for (Set<id> contactIdSet :PartnerContactIds){
                if(contactIdSet==null || contactIdSet.size()==0)
                    return FALSE;
                 consolidatedSet.addAll(contactIdSet);
            }           
               
            if (consolidatedSet.size()==1 && Training_Type_Count == 1)
                return TRUE;            
            else if(consolidatedSet.size() < 2)  
                return FALSE;
            else
                return TRUE;
        }
        else{           
            for (Id Contact1 : PartnerContactIds.get(0)){
                consolidatedSet.clear();
                consolidatedSet.add(Contact1);  
              
                for (Id Contact2 : PartnerContactIds.get(1)){
                    if(! consolidatedSet.contains(Contact2)){
                        consolidatedSet.add(Contact2);  
                
                        for (Id Contact3 : PartnerContactIds.get(2)){
                           if(! consolidatedSet.contains(Contact3)){
                                consolidatedSet.add(Contact3);   
                                if (Training_Type_Count == 3){
                                    return true; // got 3 unique contacts
                                }
                                else{                                   
                                    for (Id Contact4 : PartnerContactIds.get(3)){
                                        if(! consolidatedSet.contains(Contact4)){
                                            consolidatedSet.add(Contact4);
                                            
                                            // CR# 9041 (8035): #2 - START
                                            // Modified code to check for more than 4 and till 8 criteria for Premier 
                                            if (Training_Type_Count == 4){                       
                                                return true; //got 4 unique contacts
                                            }  
                                            else{
                                                for (Id Contact5 : PartnerContactIds.get(4)){
                                                    if(! consolidatedSet.contains(Contact5)){
                                                        consolidatedSet.add(Contact5);   
                                            
                                                        if (Training_Type_Count == 5){
                                                            return true; //got 5 unique contacts 
                                                        }
                                                        else{
                                                            for (Id Contact6 : PartnerContactIds.get(5)){
                                                                if(! consolidatedSet.contains(Contact6)){
                                                                    consolidatedSet.add(Contact6);   
                                                        
                                                                    if (Training_Type_Count == 6){
                                                                        return true; //got 6 unique contacts 
                                                                    }
                                                                    else{
                                                                        for (Id Contact7 : PartnerContactIds.get(6)){
                                                                            if(! consolidatedSet.contains(Contact7)){
                                                                                consolidatedSet.add(Contact7);   
                                                                    
                                                                                if (Training_Type_Count == 7){
                                                                                    return true; //got 7 unique contacts 
                                                                                }
                                                                                else{
                                                                                    for (Id Contact8 : PartnerContactIds.get(7)){
                                                                                        if(! consolidatedSet.contains(Contact8)){
                                                                                            consolidatedSet.add(Contact8);
                                                                                                return true; //got 8 unique contacts 
                                                                                            
                                                                                        }//if - con8
                                                                                    }// for - con 8                                                                     


                                                                                    consolidatedSet.remove(Contact7);
                                                                                } //else - con 7
                                                                            }//if - con7
                                                                        }// for - con 7                                                                     



                                                                        consolidatedSet.remove(Contact6);
                                                                    } //else - con 6
                                                                }//if - con6
                                                            }// for - con 6                                                     


                                                            consolidatedSet.remove(Contact5);
                                                        } //else - con 5
                                                    }//if - con5
                                                }// for - con 5                                             


                                                consolidatedSet.remove(Contact4);
                                            } //else - con 4
                                            // CR# 9041 (8035): #2 - END                                           
                                             
                                        }//if                                
                                    }//con 4
                                    consolidatedSet.remove(Contact3);
                               }//else
                            }//if              
                        }//con 3
                        consolidatedSet.remove(Contact2);
                    }//if
                }//con2 
            }//con1 
        }
        return false;
    }
        
    global boolean UpdateTrackerRecords(PartnerCertDataStructures.AccountData tmp_acData){   
        Certification_Tracker__c CertTracker = [select id, Account_Name__c,
                                                        Demo_Unit_Criteria_Met__c, Evaluate_Criteria__c, 
                                                        Training_Criteria_Met__c, Dell_Certification_Areas__c,
                                                        Demo_Units_Purchased__c ,Certification_Completed__c, Premier_Criteria_Enable__c, Competencies_meeting_Premier_Criteria__c
                                                from Certification_Tracker__c
                                                where Account_Name__c = :tmp_acData.AccountId
                                                limit 1 ];  
        CertTracker.Demo_Unit_Criteria_Met__c =  tmp_acData.Final_DemoCriteriaMet;         
        String demounit;
        if (tmp_acData.Final_DemoCriteriaMet == true){                
            for (String demo : tmp_acData.demoUnitsPurchased){
                if (demounit == null)
                    demounit = demo;
                else
                    demounit = demounit + ';' + demo;
            }                
        }
        CertTracker.Demo_Units_Purchased__c = demounit;
        CertTracker.Training_Criteria_Met__c =  tmp_acData.TrainingCriteriaMet;
        system.debug('Test--tmp_acData.TrainingCriteriaMet : '+ tmp_acData.TrainingCriteriaMet);
        CertTracker.Evaluate_Criteria__c = false;
        CertTracker.DemoAlert__c = tmp_acData.CertNames_for_DemoAlert;
        String cert_area;
        if (tmp_acData.TrainingCriteriaMet == true){                
            for (String area : tmp_acData.Certification_Completed){
                if (cert_area == null)
                    cert_area = area;
                    //cert_area = 'Data Protection;' + area;
                else
                    cert_area = cert_area + ';' + area;
                    //cert_area = cert_area + ';' + 'Data Protection;' + area;
            }               
        }
        CertTracker.Certification_Completed__c = cert_area;
        system.debug('Test--CertTracker.Certification_Completed__c : '+ CertTracker.Certification_Completed__c);        
        
        // CR# 9041 (8035): #3 - START
        // Checking/Unchecking the PremierCriteriaEnable checkbox based on 8 or less unique trainings.
        CertTracker.Premier_Criteria_Enable__c =  tmp_acData.PremierCriteriaEnable;
        system.debug('Test--Premier_Criteria_Enable__c : ' + CertTracker.Premier_Criteria_Enable__c );
        system.debug('Test--tmp_acData.Certification_Area.isEmpty() : ' + tmp_acData.Certification_Area.isEmpty());
        // CR# 9041 (8035): #3 - END
        
        
        //Check Master Program Names.
        //////////////.....check MP----country-wise,region,global----------------
        
        String DellCertArea_n_MP = '';
        String mpNames = '';
        if (! tmp_acData.Certification_Area.isEmpty()){  
            List<Master_Program_Setup__c> MasterProgList = getMasterPrograms(tmp_acData);//get master programs to be checked for this account
            system.debug('Test--MasterProgList.size()-1 : ' + MasterProgList.size());
            Set<String> certNamesinMP_to_remove = new Set<String>(); 
            
            if(MasterProgList.size() > 0){
            for (Master_Program_Setup__c mp :MasterProgList) {
                Set<String> MP_certNames = new Set<String>();
                MP_certNames.addAll(mp.Certification_Name__c.split(';'));
                
                system.debug('Test--MP_certNames : ' + MP_certNames);
                system.debug('Test--mp.Certification_Name__c : ' + mp.Certification_Name__c);
                system.debug('Test--DellCertArea_n_MP : ' + DellCertArea_n_MP);
                system.debug('Test--tmp_acData.Certification_Area : ' + tmp_acData.Certification_Area);
                
                if (tmp_acData.Certification_Area.containsAll(MP_certNames)){
                    if (DellCertArea_n_MP == ''){
                        DellCertArea_n_MP = mp.Master_Program_Name__c;
                        mpNames = mp.Master_Program_Name__c;                        
                    }
                    else{
                        DellCertArea_n_MP = DellCertArea_n_MP + ';' + mp.Master_Program_Name__c;
                        mpNames = mpNames + '; ' + mp.Master_Program_Name__c;
                    }
                    certNamesinMP_to_remove.addAll(MP_certNames);
                }           
            }
            }
               
            //mpNames = DellCertArea_n_MP;  
            Set<string> finalDellCert = tmp_acData.Certification_Area;
            system.debug('Test--finalDellCert1 : ' + finalDellCert);
            finalDellCert.removeAll(certNamesinMP_to_remove); 
            system.debug('Test--finalDellCert2 : ' + finalDellCert);
            
            for (String dCert : finalDellCert){
                if (DellCertArea_n_MP == '')
                    DellCertArea_n_MP = dCert;
                else
                    DellCertArea_n_MP = DellCertArea_n_MP + ';' + dCert;
            }     
        }
        CertTracker.Dell_Certification_Areas__c = DellCertArea_n_MP;
        CertTracker.Certification_Area_MasterProgramNames__c =   mpNames;           
        if (tmp_acData.Final_DemoCriteriaMet == true || tmp_acData.TrainingCriteriaMet == true){
            CertTracker.Last_Evaluation_date__c = date.today();
        }           
        
        // CR# 9041 (8035): #4 - START
        // Populating the "Competencies_meeting_Premier_Criteria__c" field if the "PremierCriteriaEnable" field is checked.       
        if(tmp_acData.PremierCriteriaEnable == true){
            CertTracker.Competencies_meeting_Premier_Criteria__c = DellCertArea_n_MP;
        }
        else{
            CertTracker.Competencies_meeting_Premier_Criteria__c = null;
        }
        system.debug('Test--CertTracker.Competencies_meeting_Premier_Criteria__c : '+ CertTracker.Competencies_meeting_Premier_Criteria__c);        
        // CR# 9041 (8035): #4 - END

        update CertTracker;  
        
        // CR# 9041 (8035): #5 - START
        if(! tmp_acData.Certification_Area.isEmpty()){      
            String DellCompetencies = '', CertCompletedInclude = '';
            List<Master_Program_Setup__c> MasterProgLst = getMasterPrograms(tmp_acData); //get master programs to be checked for this account
            
            if(MasterProgLst.size() > 0){
                List<Certification_Tracker__c> certTrackLst = getCertTracker(tmp_acData); //get details from Certification Tracker
        
                //system.debug('Test--certTrackLst : ' + certTrackLst);
                system.debug('Test--certTrackLst.size() : ' + certTrackLst.size());
                
                if(certTrackLst.size() > 0 || certTrackLst != null){
                    Set<String> MP_CertNames_Remove = new Set<String>(); 
                    
                    for (Master_Program_Setup__c mp :MasterProgLst) {
                        Set<String> MP_CertNames_Contain = new Set<String>();
                        MP_CertNames_Contain.addAll(mp.Certification_Name__c.split(';'));
                        DellCompetencies += ';' + mp.Master_Program_Name__c;
                        MP_CertNames_Remove.addAll(MP_CertNames_Contain);
                        system.debug('Test--DellCompetencies1 : ' + DellCompetencies);
                    }
                    
                    Set<string> MP_finalDellCert = tmp_acData.Certification_Area;
                    //MP_finalDellCert = MP_finalDellCert.replace('{', '');
                    system.debug('Test--MP_finalDellCert1 : ' + MP_finalDellCert);
                    MP_finalDellCert.removeAll(MP_CertNames_Remove);
                    system.debug('Test--MP_finalDellCert2 : ' + MP_finalDellCert);
                    system.debug('Test--DellCompetencies2 : ' + DellCompetencies);
        
                    if(MP_finalDellCert.size() > 0){
                        for (String dCert1 : MP_finalDellCert){
                            //CertTracker.Dell_Certification_Areas__c = MP_finalDellCert + ';' + DellCompetencies;
                            CertTracker.Dell_Certification_Areas__c = dCert1 + ';' + DellCompetencies;                
                        }
                    }
                    else{
                        CertTracker.Dell_Certification_Areas__c = DellCompetencies;          
                    }
        
                    //for (String dCert1 : MP_finalDellCert){
                        //if(MP_finalDellCert.size() > 0){
                        //    //CertTracker.Dell_Certification_Areas__c = MP_finalDellCert + ';' + DellCompetencies;
                        //    CertTracker.Dell_Certification_Areas__c = dCert1 + ';' + DellCompetencies;
                        //}
                        //else{
                        //    CertTracker.Dell_Certification_Areas__c = DellCompetencies;                    
                        //}
                        //system.debug('Test--DellCompetencies3 : ' + DellCompetencies);
                    //}
                    
                    if(tmp_acData.PremierCriteriaEnable == true){
                        CertTracker.Competencies_meeting_Premier_Criteria__c = CertTracker.Dell_Certification_Areas__c;
                    }
                    else{
                        CertTracker.Competencies_meeting_Premier_Criteria__c = '';
                    }
                    
                    update CertTracker;  
                }
            }
        }
        // CR# 9041 (8035): #5 - END

        
        //insert into certified by certification
        List<Certified_by_Certification__c> cList = new list<Certified_by_Certification__c>();        
        ////check duplications..........        
        List<Certified_by_Certification__c> existingCCList = [select Certification__c, Acquisition_Source__c
                                                                From Certified_by_Certification__c
                                                                Where Account__c = :tmp_acData.AccountId];
        Set<String> certAqcList = new Set<String>();
         for (Certified_by_Certification__c c : existingCCList){
             String tmp = c.Certification__c;
             if ( c.Acquisition_Source__c != null && c.Acquisition_Source__c != '')
                 tmp = tmp + '_' + c.Acquisition_Source__c;
                
             if (!certAqcList.contains(tmp)){
                 certAqcList.add(tmp);
             }           
         }
        
        /*
        //  CODE commented for CRQ ....
        // No match needed between Requirement Setup--Acquisition & Account-Acquisition Source 

        for (Certification_Requirement_Setup__c r : tmp_acData.Success_Reqmts){
            Set<String> setAcquisitions = new Set<String>();
            //String CertByCert_NewAcquistion='';
            
            boolean flag = false ;
            if (r.Acquisition__c == null  && tmp_acData.Acquisition_Source == null){
                //if both Acq. are null, enter record in Certified by Certification with Acq=NULL
                flag = true;                                    
            }
            else if (r.Acquisition__c != null && tmp_acData.Acquisition_Source  == null) {
                // if Reqmt->Acq is not null, but Account->Acq is null ---> Do not add record to  Certified by Certification
                flag= false;
            }
            else if (r.Acquisition__c != null && tmp_acData.Acquisition_Source != null){    
                //Account->Acq is multipiclist, so check for each Acq. name
                for (String Account_acq : tmp_acData.Acquisition_Source.split(';')){
                    //Check if Reqmt->Acquisition contains Account-Acq name
                    //Ex. Remqt->Acq = 'Compellent - Grandfathered' and Account-Acquisition Source = 'Compellent' -- add record to Certified by Certification
                    if (r.Acquisition__c.Contains(Account_acq)){
                        flag = true;
                        //CertByCert_NewAcquistion = Account_acq;
                        //CertByCert_NewAcquistion = tmp_acData.Acquisition_Source;
                        break;
                    }
                }               
            }
            else if (r.Acquisition__c == null && tmp_acData.Acquisition_Source != null){ 
               // setAcquisitions.addAll(tmp_acData.Acquisition_Source.split(';'));
                //CertByCert_NewAcquistion = tmp_acData.Acquisition_Source;
                flag = true;
            }
                        
            if (flag == true){
                 String tmpCertAcq = r.Certification_Name__c ;
                 
                //if (CertByCert_NewAcquistion != null && CertByCert_NewAcquistion != '')
                 //   tmpCertAcq = tmpCertAcq + '_' + CertByCert_NewAcquistion;

                
            if (tmp_acData.Acquisition_Source != null && tmp_acData.Acquisition_Source != '')
                    tmpCertAcq = tmpCertAcq + '_' + tmp_acData.Acquisition_Source;
                
                
                //INSERT RECORD IN Certified by Certification
               // if (setAcquisitions.isEmpty()){
                     if (!certAqcList.contains(tmpCertAcq)){                
                         Certified_by_Certification__c cRec = new Certified_by_Certification__c();                        
                         cRec.Account__c = tmp_acData.AccountId;
                         cRec.Certification__c = r.Certification_Name__c;
                         cRec.Acquisition_Source__c = tmp_acData.Acquisition_Source ; //CertByCert_NewAcquistion;
                         cRec.Date_Achieved__c = date.today();
                         cRec.Partner_Relationship__c = tmp_acData.Partner_Relationship;
                          
                         // CRQ 0895                          
                         cRec.Manually_Added_Competency__c = false;
                                       
                         cList.add(cRec);
                        
                         certAqcList.add(tmpCertAcq);
                     }
               // }
               // else{
               //     for (String str :setAcquisitions ) {   
               //         tmpCertAcq = r.Certification_Name__c + '_' + str;    
                 //       if (!certAqcList.contains(tmpCertAcq)){       
                 //           Certified_by_Certification__c cRec = new Certified_by_Certification__c();                        
                 //           cRec.Account__c = tmp_acData.AccountId;
                 //           cRec.Certification__c = r.Certification_Name__c;
                 //           cRec.Acquisition_Source__c = str;                       
                 //           cRec.Date_Achieved__c = date.today();
                 //           cRec.Partner_Relationship__c = tmp_acData.Partner_Relationship;                
                 //           cList.add(cRec);
                 //           
                 //           certAqcList.add(tmpCertAcq);
                 //       }
                  //  }
                //} 
            }           
        }*/

        //Check for Duplications 
        for (Certification_Requirement_Setup__c r : tmp_acData.Success_Reqmts){
            String tmpCertAcq = r.Certification_Name__c ;
                 
            if (tmp_acData.Acquisition_Source != null && tmp_acData.Acquisition_Source != '')
                tmpCertAcq = tmpCertAcq + '_' + tmp_acData.Acquisition_Source;
                
                
            //INSERT RECORD IN Certified by Certification
              if (!certAqcList.contains(tmpCertAcq)){                
                 Certified_by_Certification__c cRec = new Certified_by_Certification__c();                        
                 cRec.Account__c = tmp_acData.AccountId;
                cRec.Certification__c = r.Certification_Name__c;
                 cRec.Acquisition_Source__c = tmp_acData.Acquisition_Source ; 
                 cRec.Date_Achieved__c = date.today();
                 cRec.Partner_Relationship__c = tmp_acData.Partner_Relationship;   
                   
                 // CRQ 0895                          
                 cRec.Manually_Added_Competency__c = false;
                                                       
                 cList.add(cRec);                
                 certAqcList.add(tmpCertAcq);
             }           
        }
    
         if (! cList.isEmpty()){
             insert cList;
         }             
        return true;
    }  
      
    public List<Master_Program_Setup__c> getMasterPrograms(PartnerCertDataStructures.AccountData tmp_acData){          
        String queryCertCriteria = '';          
        for (String certArea : tmp_acData.Certification_Area ){
            if (queryCertCriteria == '')
                queryCertCriteria = ' Certification_Name__c includes (\'' +  certArea + '\'';
            else
                queryCertCriteria = queryCertCriteria + ' , \'' + certArea + '\'';
        }
        system.debug('Test--queryCertCriteria : ' + queryCertCriteria);
        if (queryCertCriteria != ''){
            queryCertCriteria = queryCertCriteria + ' ) ';
            String query = 'select name, Certification_Name__c, Competency_F1Name__c, Master_Program_Name__c '                      
                 + ' from Master_Program_Setup__c '
                 + ' where Active__c = true  '
                 + ' AND ((Country__c = \'' + tmp_acData.CountryId + '\' and Apply_Requirement_To__c = \'Country\') '
                 + ' OR   (Region__c = \'' + tmp_acData.Region + '\' and Apply_Requirement_To__c = \'Region\') '
                 + ' OR    Apply_Requirement_To__c = \'Global\' ) AND'  
                 + queryCertCriteria ;

            system.debug('Test--Query : ' + query);
            return Database.query(query);
        }                 
        else
            return null;                
    }    

    public List<Certification_Tracker__c> getCertTracker(PartnerCertDataStructures.AccountData tmp_acData){          
        List<Master_Program_Setup__c> MasterProgLst = getMasterPrograms(tmp_acData); //get master programs to be checked for this account

        String queryCertCriteria1 = '';
        if(MasterProgLst.size() > 0 || MasterProgLst != null){          
        for (String certArea1 : MasterProgLst[0].Competency_F1Name__c.split(',')){
            if (queryCertCriteria1 == '')
                queryCertCriteria1 = ' Certification_Completed__c includes (' +  certArea1 + '';
            else
                queryCertCriteria1 = queryCertCriteria1 + ' , ' + certArea1 + '';
        }
        }        
        if (queryCertCriteria1 != ''){
            queryCertCriteria1 = queryCertCriteria1 + ' ) ';
            string acName = '(\'' + tmp_acData.AccountId + '\')'; 
            String query1 = 'Select Id, Dell_Certification_Areas__c, Certification_Completed__c, Account_Name__c From Certification_Tracker__c where Account_Name__c IN ' + acName + ' and ' + queryCertCriteria1 ;

            system.debug('Test--Query1 : ' + query1);
            return Database.query(query1);
        }
                         
        else
            return null;
        
    }                    

    // Check if any criteria or prerequisite has setup where Criteria_value or prerequisite_value is null
    boolean isValidRequirmentSetup(Certification_Requirement_Setup__c r){   
        
        if (r.Criteria_Rule__c == null || r.Criteria_Rule__c  == '')
            return false;            
                
        for (Certification_Prerequisites_Setup__c cpSetup :  r.Certification_Prerequisites_Setups__r){
            if (cpSetup.Prerequisites_Ids__c == '' || cpSetup.Prerequisites_Ids__c == null)
                return false;           
        }
        
        for(Certification_Criteria_Setup__c criteria : r.Certification_Criteria_Setups__r){
            if (criteria.Criteria_Value_Ids__c == '' || criteria.Criteria_Value_Ids__c == null )
                return false;                           
        }       
        return true;        
    }       
}