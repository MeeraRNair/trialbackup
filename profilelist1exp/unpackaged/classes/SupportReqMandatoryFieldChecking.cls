/*------------------------------------------------------------------------------------------------------------------------------------------------------
* Name            : SupportReqMandatoryFieldChecking
* Description     : contain fields mandatory validation on Support Request page
* Revision  Name           Date              Description
---------------------------------------------------------------------------------------------------------------------------------------------------------
* 1.0       Azwanti         23/07/2013        RL14.10 SOM: CR8529-Mandatory Fields Validation for Selected Request Type
* 1.1       Azwanti         09/10/2013        RL14.10 SOM: CR8529 CRQ 0832-Remove "Primary Work/Delivery Address line 2" as mandatory field
* 2.0       Krishnamoorthi  03/06/2015        CR 11561: GSD User Story (162173): Pre-Populate the Contact (Customer Contact Information (Name)) fields
                                                and display the existing validation error messages in the field Customer_Contact_InformationName__c - Contact
* 2.1       Krishnamoorthi  08/07/2015        CR 11707: User Story 177472: Provide Contact record edit link and display all blank Contact fields 
                                                in the Customer_Contact_InformationName__c error message
* 3.0       Kokila          11/08/2015        CR 11808: To make Suggested Delivery Method as Mandatory when Solution Architect drop down selection is "Yes"
                                                                                                                                            
-----------------------------------------------------------------------------------------------------------------------------------------------------------*/
public class SupportReqMandatoryFieldChecking{
    //initialize    
    Public String saErrMsg; 
    Public String fieldErrMsg = 'You must enter a value';  
    Public boolean solutionArchitechtFieldNull;  
    Public boolean serviceFinanceFieldNull;
    
    Public void checkMandatoryFields(Support_Request__c sr){

        String contactURL = '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + sr.Customer_Contact_InformationName__c + '/e' + '" target="_blank">Click here to edit the Contact in a new tab/window.</a>'; //v2.1 variable to get the Contact URL
        String contactFields = ''; //v2.1 variable to get the blank Contact fields

        if(SupportRequestUtil.SKIP_SUPPORT_REQUEST_TRIGGERS == false) { // v2.0- To skip the validation when Support Request is updated from Contact - CR 11561
            if(sr.Solution_Architect__c == 'Yes'){            
                if(sr.Engagement_Time_Frame__c == null || sr.Customer_Contact_Information_Name__c == null || sr.Customer_Contact_Information_Phone__c == null || 
                    sr.Customer_Contact_Information_Email__c == null || sr.Project_Type__c == null || sr.Decision_Date__c == null || sr.Primary_Work_Delivery_Address_1__c  == null ||
                    //CRQ0832
                    /*sr.Primary_Work_Delivery_Address_2__c == null || */
                    sr.Primary_Work_Delivery_City__c  == null || sr.Primary_Work_Delivery_State_Province__c  == null ||
                    sr.Primary_Work_Delivery_Country__c == null || sr.Primary_Work_Delivery_Language__c == null || sr.Suggested_Delivery_Method__c == null){  //v3.0 - Modified 

                        solutionArchitechtFieldNull = true;               
                }
                //fix SIT defect #79963
                if(sr.Custom_Service_Support__c == 'Custom Service Solution' && sr.Project_Duration_months__c == null){
                    solutionArchitechtFieldNull = true;     
                }
                
                //BR16.6 & 16.7 : throw field required message if Solution Architect Support section fields have null value
                //v2.0 - CR 11561: Display the existing validation error messages of 7 read-only fields in Customer_Contact_InformationName__c - Contact
                if(sr.Engagement_Time_Frame__c == null) {
                    sr.Engagement_Time_Frame__c.addError(fieldErrMsg);    
                }
                
                if(sr.Customer_Contact_InformationName__c == null) {
                    sr.Customer_Contact_InformationName__c.addError(fieldErrMsg);//v2.1
                }
                
                if(sr.Customer_Contact_Information_Name__c == null){
                    //sr.Customer_Contact_Information_Name__c.addError(fieldErrMsg);//v2.0
                    //sr.Customer_Contact_InformationName__c.addError('You must enter Name value in Contact.' + ' ' + contactURL, false);//v2.1
                    if(contactFields != '') {
                        contactFields = contactFields + ', ' + 'Name';
                    }
                    else {
                        contactFields = 'Name';
                    }
                }
                if(sr.Customer_Contact_Information_Phone__c == null){
                    //sr.Customer_Contact_Information_Phone__c.addError(fieldErrMsg);//v2.0
                    //sr.Customer_Contact_InformationName__c.addError('You must enter Phone value in Contact.' + ' ' + contactURL, false);//v2.1
                    if(contactFields != '') {
                        contactFields = contactFields + ', ' + 'Phone';
                    }
                    else {
                        contactFields = 'Phone';
                    }
                }
                if(sr.Customer_Contact_Information_Email__c == null){
                    //sr.Customer_Contact_Information_Email__c.addError(fieldErrMsg);//v2.0
                    //sr.Customer_Contact_InformationName__c.addError('You must enter Email value in Contact.' + ' ' + contactURL, false);//v2.1
                    if(contactFields != '') {
                        contactFields = contactFields + ', ' + 'Email';
                    }
                    else {
                        contactFields = 'Email';
                    }
                }
                if(sr.Project_Type__c == null){
                    sr.Project_Type__c.addError(fieldErrMsg);
                }
                //v3.0 - Added Error message to the field 'Suggested Delivery_Method'  
                if(sr.Suggested_Delivery_Method__c == null){
                    sr.Suggested_Delivery_Method__c.addError(fieldErrMsg);
                }    
                if(sr.Decision_Date__c == null){
                    sr.Decision_Date__c.addError(fieldErrMsg);
                }
                if(sr.Primary_Work_Delivery_Address_1__c  == null){
                    //sr.Primary_Work_Delivery_Address_1__c.addError(fieldErrMsg);//v2.0
                    //sr.Customer_Contact_InformationName__c.addError('You must enter MailingStreet value in Contact.' + ' ' + contactURL, false);//v2.1
                    if(contactFields != '') {
                        contactFields = contactFields + ', ' + 'Mailing Street';
                    }
                    else {
                        contactFields = 'Mailing Street';
                    }
                }
                //CRQ0832
             /*   if(sr.Primary_Work_Delivery_Address_2__c == null){
                    sr.Primary_Work_Delivery_Address_2__c.addError(fieldErrMsg);
                } */
                if(sr.Primary_Work_Delivery_City__c == null){
                    //sr.Primary_Work_Delivery_City__c.addError(fieldErrMsg);//v2.0
                    //sr.Customer_Contact_InformationName__c.addError('You must enter MailingCity value in Contact.' + ' ' + contactURL, false);//v2.1
                    if(contactFields != '') {
                        contactFields = contactFields + ', ' + 'Mailing City';
                    }
                    else {
                        contactFields = 'Mailing City';
                    }
                }
                if(sr.Primary_Work_Delivery_State_Province__c == null){
                    //sr.Primary_Work_Delivery_State_Province__c.addError(fieldErrMsg);//v2.0
                    //sr.Customer_Contact_InformationName__c.addError('You must enter MailingState value in Contact.' + ' ' + contactURL, false);//v2.1
                    if(contactFields != '') {
                        contactFields = contactFields + ', ' + 'Mailing State/Province';
                    }
                    else {
                        contactFields = 'Mailing State/Province';
                    }
                }
                if(sr.Primary_Work_Delivery_Country__c == null){
                    //sr.Primary_Work_Delivery_Country__c.addError(fieldErrMsg);//v2.0
                    //sr.Customer_Contact_InformationName__c.addError('You must enter MailingCountry value in Contact.' + ' ' + contactURL, false);//v2.1
                    if(contactFields != '') {
                        contactFields = contactFields + ', ' + 'Mailing Country';
                    }
                    else {
                        contactFields = 'Mailing Country';
                    }
                }
                
                //v2.1 -- Display error message in Customer_Contact_InformationName__c if any of the 7 Contact fields are blank -- Start
                if(sr.Customer_Contact_InformationName__c != null && contactFields != ''){
                        if(contactFields.contains(',')) {
                            sr.Customer_Contact_InformationName__c.addError('Selected Contact is missing' + ' ' + contactFields + ' values. ' + contactURL, false);
                        }
                        else {
                            sr.Customer_Contact_InformationName__c.addError('Selected Contact is missing' + ' ' + contactFields + ' value. ' + contactURL, false);
                        }
                }
                //v2.1 -- End
                
                if(sr.Primary_Work_Delivery_Language__c == null){
                    sr.Primary_Work_Delivery_Language__c.addError(fieldErrMsg);
                }
                if(sr.Project_Duration_months__c == null && sr.Custom_Service_Support__c == 'Custom Service Solution'){
                    sr.Project_Duration_months__c.addError(fieldErrMsg);    
                }
            } 
            
            if(sr.Services_Finance_Support__c == 'Yes'){
                //BR16.3 : throw field required message if Services Finance Support section fields have null value            
                if(sr.Pricing_Cycle_Status__c == null || sr.HW_SW_or_other_Financing_Dell_owned__c == null || sr.Customer_Pricing_Due_Date__c == null){                    
                    serviceFinanceFieldNull = true;  
                }
                if(sr.Pricing_Cycle_Status__c == null){
                    sr.Pricing_Cycle_Status__c.addError(fieldErrMsg); 
                }       
                if(sr.HW_SW_or_other_Financing_Dell_owned__c == null){              
                    sr.HW_SW_or_other_Financing_Dell_owned__c.addError(fieldErrMsg);    
                } 
                if(sr.Customer_Pricing_Due_Date__c == null){
                    sr.Customer_Pricing_Due_Date__c.addError(fieldErrMsg);      
                }
            }    
            
            //BR16.1 : throw error message when Solution Architect and/or Services Finance Support resource selected WITH any of the resourse mandatory fields is null
            if(sr.Solution_Architect__c == 'Yes' && solutionArchitechtFieldNull == true){
                if(sr.Services_Finance_Support__c == 'Yes' && serviceFinanceFieldNull == true){
                    saErrMsg = System.Label.SupportReqMandatoryErrMsg;        
                }
                else{
                    saErrMsg = 'You have selected Yes for Solution Architect. Please complete the required fields in the Solution Architect Support section of the form so that your request can be submitted.';                       
                }
            }
            else if(sr.Services_Finance_Support__c == 'Yes' && serviceFinanceFieldNull == true){
                //1. Resourse Type selected with mandatory field null
                saErrMsg = 'You have selected Yes for Services Finance Support. Please complete the required fields in the Services Finance Support section of the form so that your request can be submitted.';                                  
            }
            
            if(String.isNotBlank(saErrMsg)){
                sr.addError(saErrMsg);
            } 
        }   
    }    
}