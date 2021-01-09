/***********************************************************
* Name          : ManageCSESupportRequest
* Description   : Apex class
* ---------------------------------------------------------
* Revision  Name       Date        Description
* 1.0       Supriya    17.12.2012  CR 7783 Support Request Validation
************************************************************/
Public Class ManageCSESupportRequest{
    Static List<Support_Request__c> supportRequestListNew=new List<Support_Request__c>();
    Static Map<Id,Support_Request__c> supportRequestMapOld=new Map<Id,Support_Request__c>();
    Static List<Sales_Motion_User_Role__c> SMUserRole=new List<Sales_Motion_User_Role__c>();
    Static List<Sales_Motion_CS__c> SMCustomSetting=new List<Sales_Motion_CS__c>();  
    Static List<String> roleList=new List<String>();
    Static Map<String,Sales_Motion_CS__c> cstmSettingMap=new Map<String,Sales_Motion_CS__c>(); 
    Static String strCstmSolnEnggSprtRT;
    Static Id HPCRecordTypeId = Schema.SObjectType.Support_Request__c.getRecordTypeInfosByName().get('Request HPC Engineering Support').getRecordTypeId();    
    //Static List<CSE_Support_Request_Roles_Temp_del__c> SRRolesTempList=new List<CSE_Support_Request_Roles_Temp_del__c>(); 
    
    Static Set<String> editableFieldSet=new Set<String>();
    Static List<String> editableFieldList = new List<String>();
    Static Map<String,String> editableFieldMap=new Map<String,String>(); 

    Static String ErrorMessage;
    
    Static Set<String> roleSet=new Set<String>();
    Static String sBreak = '</br>';
    
    Public Static void findCSERoleOfLoggedInUser(List<Support_Request__c> SRNewList,Map<Id,Support_Request__c> SROldMap,List<Id> userId){ 
        supportRequestListNew=SRNewList;
        supportRequestMapOld=SROldMap;
        strCstmSolnEnggSprtRT=IdLookupUtils.getRecordTypeId('Request PG Custom Solutions Engineering Support', 'Support_Request__c', true);
        for(Sales_Motion_User_Role__c roleVar:[Select Id,Role__c,Username__c from Sales_Motion_User_Role__c where Username__c in:userId]){
            SMUserRole.add(roleVar);
            roleList.add(roleVar.Role__c);
            roleSet.add(roleVar.Role__c);
        }    
        for(Sales_Motion_CS__c cstmSetting:[Select Id,Name,Editable__c from Sales_Motion_CS__c where name in:roleList]){
            List<String> editableFlds=(StringUtils.defaultString(cstmSetting.Editable__c).replaceAll('[ \n\r\t\f]','').toLowerCase()).Split(',');
            //List<String> readOnlyFlds=(StringUtils.defaultString(cstmSetting.Read_Only__c).replaceAll('[ \n\r\t\f]','').toLowerCase()).Split(',');
            SMCustomSetting.add(cstmSetting);
            cstmSettingMap.put(cstmSetting.Name,cstmSetting);           
            for(String str:editableFlds){
                editableFieldSet.add(str);
                editableFieldMap.put(str,str);
            }
        } 
        ValidateSupportRequest();        
               
    } 
    
    Public Static void ValidateSupportRequest(){ 
        ErrorMessage='';
        String editableErr='';
        String statusFldErr='';
        
        Map<String, Schema.SObjectField> m = Schema.SObjectType.Support_Request__c.fields.getMap();        
       
        for(Support_Request__c SRRec:supportRequestListNew){
            if(StringUtils.equalsIgnoreCase(SRRec.RecordTypeId,strCstmSolnEnggSprtRT) || StringUtils.equalsIgnoreCase(SRRec.RecordTypeId,HPCRecordTypeId) ){
                Support_Request__c SprtReqOldRec=supportRequestMapOld.get(SRRec.Id);
                if(editableFieldSet.size()>0){
                     for(String str:editableFieldSet){
                      String tempStr=str.trim();
                      Schema.SObjectField f = m.get(tempStr.toLowerCase());
                      if(f!=null){
                        Schema.DescribeFieldResult d = f.getDescribe();
                        String fieldAPIName=d.getName();
                        String NewRecValue=String.ValueOf(SRRec.get(fieldAPIName));
                         System.debug('##### Schema field describe NewRecValue editable'+ NewRecValue);
                            if(NewRecValue==''||NewRecValue==null){
                               editableFieldList.add(d.getLabel());   
                            }
                        System.debug('##### Schema field describe NewRecValue editableerr2'+ editableErr);
                        
                    }
                 }
                   for(Integer i=0 ; i<editableFieldList.size() ;i++){
                    if(i+1 >= editableFieldList.size()){
                       editableErr= editableErr+editableFieldList[i];
                    }
                    else{
                        editableErr= editableErr+editableFieldList[i] + ',';
                    }    
                    }  
               } 
               
               // Validation against Status
               if(roleSet.contains('CSE Intake Manager') || roleSet.contains('Project Manager')||roleSet.contains('Business Consultant') || roleSet.contains('Engineer') || roleSet.contains('CSE Admin')){               
               if((SRRec.Status__c=='In Review' || SRRec.Status__c== 'Pending Final Review')&&(SRRec.Business_Consultant__c==null || SRRec.Project_Manager__c==null)){
                        statusFldErr=statusFldErr+'Please assign Project Manager and Business Consultant in the CSE Support Request form if the status is' + '\t' + SRRec.Status__c;  
               }
               if(SRRec.Status__c== 'In Quote'&&(SRRec.Business_Consultant__c==null || SRRec.Project_Manager__c==null)){
                        statusFldErr=statusFldErr+'Please assign Project Manager and Business Consultant in the CSE Support Request form if the status is' + '\t' + SRRec.Status__c;  
               }  
               else if(SRRec.Status__c=='In Quote'&&((SRRec.CSE_Revenue_Quoted__c==null)||(SRRec.Accounting_Quarter__c==null))){
                        statusFldErr=statusFldErr+'Please enter value in the CSE Revenue Quoted and Accounting Quarter field in the form if status is In Quote.  ';                                
               }
               
               if(SRRec.Status__c== 'In Process'&&(SRRec.Business_Consultant__c==null || SRRec.Project_Manager__c==null)){
                        statusFldErr=statusFldErr+'Please assign Project Manager and Business Consultant in the CSE Support Request form if the status is' + '\t' + SRRec.Status__c;  
               }
               else if(((SRRec.Status__c=='In Process')&&(SRRec.Pro_Bono__c=='No'))&&(((SRRec.DOMS_Order_Number__c=='') || (SRRec.DOMS_Order_Number__c==null))||((SRRec.FSR_Number__c=='') || (SRRec.FSR_Number__c==null)) ||((SRRec.Cost_Center_Number_cse__c=='') || (SRRec.Cost_Center_Number_cse__c==null))||((SRRec.Company_Number__c=='') || (SRRec.Company_Number__c==null)))){
                        statusFldErr=statusFldErr+'Please enter value in the DOMS Order Number,FSR Number,Cost Center Number and Company Number.  ';                                
               }
                
                if(SRRec.Status__c== 'In Sustaining'&&(SRRec.Business_Consultant__c==null || SRRec.Project_Manager__c==null)){
                        statusFldErr=statusFldErr+'Please assign Project Manager and Business Consultant in the CSE Support Request form if the status is' + '\t' + SRRec.Status__c;  
                }
                else if(SRRec.Status__c=='In Sustaining'&&SRRec.Exit_Report_Submitted__c!='Yes'){
                        statusFldErr=statusFldErr+'Please make Exit Report Submitted=yes if status is In Sustaining.';                                
                }
                
                if(SRRec.Status__c== 'Complete'&&(SRRec.Business_Consultant__c==null || SRRec.Project_Manager__c==null)){
                        statusFldErr=statusFldErr+'Please assign Project Manager and Business Consultant in the CSE Support Request form if the status is' + '\t' + SRRec.Status__c;  
                }
                else if(SRRec.Status__c=='Complete'&&SRRec.CSE_Revenue_Received__c==null){
                        statusFldErr=statusFldErr+'Please enter value in CSE Revenue Received field if status is Complete.  ';                                
                } 
                
                if((SRRec.Status__c=='On-Hold'||SRRec.Status__c=='Declined'||SRRec.Status__c=='Expired'||SRRec.Status__c=='Referred')&&(SRRec.Reason__c=='' || SRRec.Reason__c==null)){
                        statusFldErr=statusFldErr+'Please enter value in  Reason field if status is On-hold OR Expired OR Declined Or Referred.   ';                                
                }
              }  
                if(editableErr!=''||statusFldErr!=''){                   
                   System.debug('##### editableErr'+ editableErr);
                   if(VFCntrlr_CSEPlatform.SKIP_CSE_CUSTOM_VALIDATION == False){
                    if(editableErr!=''){  
                         editableErr='Please enter value in following fields: '+ editableErr;                     
                        ErrorMessage=ErrorMessage+editableErr+'.  ';
                    }
                    if(statusFldErr!='' ){                        
                        ErrorMessage=ErrorMessage+statusFldErr;
                    }
                    System.debug('##### Schema field describe NewRecValue ErrorMessage'+ ErrorMessage);
                    SRRec.addError(ErrorMessage);
                    ErrorMessage='';
                   }
                } 
            }
        }  
    }  
}