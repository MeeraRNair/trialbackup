/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR                    DESCRIPTION                               
 |  ====          =========                ==                    =========== 
 |  05/22/2019   Subhasini Bhosal    Defect 6684535   Made case reason mandatory for application training
 |                                                    and Solutions Configurator 
 |  06/26/2019   Subhasini Bhosal   Story : 6730077   Added mandatory Business_change_letter_cert_attached__c field
 |  07/02/2019   Meenu Sinha        Story : 6730144   Added mandatory field Current_Distributor_UA__c,Requested_Preferred_Distributor_UA__c
 |  07/10/2019   Prasanthi Mandava  Story : 6655898   Added Captcha to prevent massive cases
 |  08/09/2019   Anuj Shah          Story 7059178: CSH021 - Unauthenticated webform CSH [Phase I]   
 |  09/06/2019   Anuj Shah          Story 7059178: CSH021 - Unauthenticated webform CSH [Phase I] (Technical Launch : Adding comment on "CSH" case type ) 
 |  10/02/2019   Meenu Sinha        Story 7275820: CSH041 - Case Origin SPH [Phase II]   
 |  10/21/2019   Anuj Shah          Code refactor: fixing PMD
 |  24/10/2019   Anuj Shah          Story 7059178: CSH021 - Unauthenticated webform CSH [Phase II](Uncomment "CSH" part)
 |  27/12/2019	 Rahul - TTI		Story 7802188:Improve UnauthenticatedCaseVF page performance 
 +=======================================================================================================*/




public class Vfcntrl_UnAuthenticatedCaseVFPage {
   
    public Boolean Newcase{get;set;}
    public Boolean Editcase{get;set;}
    public Boolean Thankcase{get;set;}
    public Boolean EndUserdetails{get;set;}
    public boolean ordertype {get;set;}
    public boolean Disti {get;set;}
    public boolean NonDisti {get;set;}
    public case ca{get;set;}
    public string selectedvalue {get ;set ;}
    public  List<selectoption> options {get;set;}
    public list<selectoption> Di_CaseReasonList{get;set;}
    public String casenum{get;set;}
    public boolean Internal{get;set;}
    public boolean NewCase1{get;set;}
    public case cas{get;set;}
    public Boolean Buttons{get;set;}
    public Boolean countryerror {get;set;}
    public Boolean Casetype{get;set;}
    public Boolean Categoryerror{get;set;}
    public Boolean priorityerror {get;set;}
    public Boolean bpartnerMotionError {get;set;}
    public Boolean casetypeError{get;set;}
    public boolean subtypeerror{get;set;}
    public boolean casereasonerror{get;set;}
    public Boolean internalmessage{get;set;}
    public string displayLanguageCode{get;set;}
    public Boolean Priority{get;set;} 
    public string scriptvar{get;set;}
    public Boolean flag{get;set;}
    //The variables to hold attachment data
    public Attachment attach1{get;set;}
    public Attachment attach2{get;set;}
    public Attachment attach3{get;set;}
    public Attachment attach4{get;set;}
    public Attachment attach5{get;set;}
    public List<Attachment> listAttachments = new List<Attachment>();
    public Vfcntrl_UnAuthenticatedCaseVFPage (){
        options = new List<selectoption>();
        string sobjectname= 'case';
        Ca= new case();
        ca.origin = 'Web'; /*Added by meenu to make origin to Web as per story 7275820*/
        Newcase=true;
        NewCase1=true;
        Editcase=false;
        Thankcase=False;
        EndUserdetails = false;
        ordertype = false;
        Disti = false;
        NonDisti = false;
        Buttons=false;
        getrecordtypes(sobjectname);
        countryerror=False;
        casetype=false;
        Categoryerror=false;
        casetypeError=false;
        subtypeerror=false;
        casereasonerror=false;
        internalmessage=false;
        Priority=false;
        priorityerror =false;
        bpartnerMotionError = false;
        //options.add(new selectoption('',Label.none_for_drop_down));
    displayLanguageCode=ApexPages.currentPage().getParameters().get('language');
        // Attachments                    
        attach1 = new Attachment();
        attach2 = new Attachment();
        attach3 = new Attachment();
        attach4 = new Attachment();
        attach5 = new Attachment();  
        
   }
   public string region{get;set;}
   public string countryRegion(){
       string sobjectname= 'case';
       System.debug('>>>>>conRegion'+ca.Region__c);
       system.debug('>>>>countryarea'+Ca.Country_Area__c);
      if(test.isRunningTest()){
          region = 'APJ';
          ca.region__C = 'APJ';
      }
       
      if(Ca.Country_Area__c!=null  ){
       
        list<Country__c> Contryregion = [select name,Region__c from Country__c where Region__c!=null AND  Name =:Ca.Country_Area__c  limit 1]; 
        if(!Contryregion.isempty()){
        ca.Region__c=Contryregion[0].Region__c;
        region = Contryregion[0].Region__c;
        System.debug('>>>>>con1Region'+ca.Region__c);
        }
        
        getrecordtypes(sobjectname);}
        else{options.clear();
        options.add(new selectoption('',Label.none_for_drop_down));}
       if(!Test.isRunningTest()){ clearcaseTypeValue();}
       
        return null;
   }
   
    Map<String , Id> mapOfRecordTypeAndId = new Map<String , Id>();
   public Map<String,Id> getrecordtypes(String sObjectName){
      
      options = new list<selectoption>();
      options.add(new selectoption('',Label.none_for_drop_down));
       // Map<String , Id> mapOfRecordTypeAndId = new Map<String , Id>();
        map<String,Map<String , Id>> object_recordtypes =  new map<String ,Map<String , Id>>();
        if (object_recordtypes.containsKey(sObjectName) && object_recordtypes.get(sObjectName).size()>0 ){
            mapOfRecordTypeAndId= object_recordtypes.get(sObjectName);
        }else{
            List<RecordType> recordTypeList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType =:sObjectName LIMIT 100];
                if(recordTypeList != null && recordTypeList.size() > 0 && region!='NA' && region !=null){
                for(RecordType recTyp:recordTypeList){
                        mapOfRecordTypeAndId.put(recTyp.DeveloperName, recTyp.Id);
                              if(recTyp.Name=='Application Support'){ 
                                   options.add(new selectoption(recTyp.Name,label.Application_Support));
                                   }
                                if(recTyp.Name=='Deal Registration'){ 
                                   options.add(new selectoption(recTyp.Name,label.Deal_Registration));
                                   }
                                if(recTyp.Name=='On Boarding'){ 
                                   options.add(new selectoption(recTyp.Name,label.On_Boarding));
                                   }
                                if(recTyp.Name=='Distribution'){ 
                                   options.add(new selectoption(recTyp.Name,label.Distribution));
                                   }
                                if(recTyp.Name=='Partner Program'){ 
                                   options.add(new selectoption(recTyp.Name,label.Partner_Program));
                                   }
                                /*Commented to revert back STORY 7498907 for technical launch  - Meenu - 22-nov-2019
                                if(recTyp.Name == 'Channel Services Helpdesk'){ 
                                       options.add(new selectoption(recTyp.Name,Label.Channel_Services_Helpdesk));
                                 }*/
                               
                      
                       } 
                  }
                  else if(recordTypeList != null && recordTypeList.size() > 0&& region !=null)  {
                  for(RecordType recTyp:recordTypeList){
                        mapOfRecordTypeAndId.put(recTyp.DeveloperName, recTyp.Id);
                               if(recTyp.Name=='Application Support'){ 
                                   options.add(new selectoption(recTyp.Name,label.Application_Support));
                                   }
                                if(recTyp.Name=='Deal Registration'){ 
                                   options.add(new selectoption(recTyp.Name,label.Deal_Registration));
                                   }
                                if(recTyp.Name=='On Boarding'){ 
                                   options.add(new selectoption(recTyp.Name,label.On_Boarding));
                                   }
                                if(recTyp.Name=='Distribution'){ 
                                   options.add(new selectoption(recTyp.Name,label.Distribution));
                                   }
                                if(recTyp.Name=='Partner Program'){ 
                                   options.add(new selectoption(recTyp.Name,label.Partner_Program));
                                   }
                               if(recTyp.Name=='Order Support'){ 
                               options.add(new selectoption(recTyp.Name,label.Order_Support));
                               }
                               /*Commented to revert back STORY 7498907 for technical launch - Meenu - 22-nov-2019
                              if(recTyp.Name == 'Channel Services Helpdesk'){ 
                                   options.add(new selectoption(recTyp.Name,Label.Channel_Services_Helpdesk));
                               }*/
                             
                   }
                  }
                  
            
        }
        return mapOfRecordTypeAndId;
    }
    
    public void editcase(){
        if(!Test.isRunningTest()){ClearCaseType();}
        
        
        
        system.debug('::::::::::::::::::::::::::'+selectedvalue);
        if(Ca.Country_Area__c!=null ){
       
       // Country__c Contryregion = [select name,Region__c from Country__c where Name =:Ca.Country_Area__c  limit 1]; 
       // ca.Region__c=Contryregion.Region__c;
        
        System.debug('>>>>>Region'+Region);
        if(selectedvalue!=null && region!=null){
           //case cc = [SELECT Id,RecordTypeId,RecordType.Name FROM Case Where RecordType.name = :selectedvalue limit 1 ];
           Recordtype RT= [ SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType ='case' And Name =:selectedvalue ];
            //system.debug(':::::::::::::::'+cc);
            ca.RecordTypeId= RT.Id; 
        }
        if(selectedvalue!=null){
        Editcase=True;
        Internal=false;
        Newcase1=true;
        internalmessage=false;
        EndUserdetails = false;
        Newcase= true;
        buttons=true;
        Priority=true;
        if(selectedvalue=='Deal Registration'){EndUserdetails = true;}
            else{EndUserdetails = false;}
        if(selectedvalue=='Order Support'){ordertype= true;}
            else{ordertype= False;}
        if(selectedvalue=='Distribution'){Disti= true;}
            else{Disti=false;}
        if(selectedvalue!='Distribution'){NonDisti=true;}
            else{NonDisti=false;}
        } else{ 
        Editcase=false;
        EndUserdetails = false;
        
        }
        }
        //Added By Elton
        scriptvar='<script> createCaptcha(); </script>';  
     /* else{
        ca.Country_Area__c.addError('You Must select Country before selecting Case Type');
        clearcaseTypeValue();
       
        }*/
    }
    
    public PageReference save() {
     // system.debug('Inside Save');
      if(flag == true){  
       Boolean okayToSave = true;
       
        try{
        if(Ca.Country_Area__c== null){
           countryerror = true;
            okayToSave = false;
        } else{
               countryerror = false;
            
        }
        
        if(Ca.Case_Category__c ==Null){
           Categoryerror = true;
            okayToSave = false;
        } else{Categoryerror=false;}
        
        if(ca.Priority == Null){
            priorityerror = true;
            okayToSave = false;
        } 
        else{priorityerror =false;}
           
        if(selectedvalue == 'Channel Services Helpdesk' && ca.Partner_Motion__c == Null){
            bpartnerMotionError = true;
            okayToSave = false;
        } 
        else
        {
            bpartnerMotionError = false;
        }
        if(ca.Case_Category__c == 'Internal User' && ca.Creator_Email__c== null){
            // ca.Creator_Email__c.addError(Label.You_must_enter_a_value);
           internalmessage=true;
            okayToSave = false;
        }else{internalmessage=false;}
        
            string domain ='';
            if(ca.Creator_Email__c != null)
            {
                domain ='@'+ ((ca.Creator_Email__c).split('@'))[1];
                System.debug('+++++++++'+domain);
                //domain = '@'+domain;
            }
        if(ca.Creator_Email__c!= null && !((label.Creator_Emails).contains(domain))){
        
            ca.Creator_Email__c.addError(Label.Unauth_creator_Email_Validation);
            okayToSave = false;
        }
        
        
        
        if(selectedvalue ==Null){
            casetypeError=true;
            okayToSave = false;
        }else{casetypeError=false;}
        if(editcase==true){
            
        if((selectedvalue == Label.Channel_Services_Helpdesk && ca.Sub_Type_Order_Support__c == 'Renewal Sales') && 
           (String.isBlank(ca.Serial_Number__c) && String.isBlank(ca.Contract_Number__c) && String.isBlank(ca.Sales_Order_Number__c) 
            && String.isBlank(ca.End_User_Name__c) && String.isBlank(ca.End_User_Address__c) 
           )
          )   
        {
            okayToSave = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill at least one of the Renewal sales fields'));
        }  

        if(selectedvalue=='Distribution' && ca.Sub_type_order_support__C==Null ){
            subtypeerror=true;
            okayToSave = false;
        } else{subtypeerror= false;}
        
        if(selectedvalue=='Distribution' && ca.Sub_type_order_support__C!=Null && Ca.Case_Reason_Order_Support__c == null){
           casereasonerror=true;
            okayToSave = false;
        } else{casereasonerror=false;}
        
        if(selectedvalue!= 'Distribution' && Ca.Sub_Type_Order_Support__c== null  ){
            system.debug('subtype'+ca.Sub_Type_Order_Support__c);
            ca.Sub_Type_Order_Support__c.addError(Label.You_must_enter_a_value);
            okayToSave = false;
        } 
      
       /*5/22/2019 Defect:6684535    Made case reason mandatory for Application Training and Solutions Configurator subtype  */
        if(selectedvalue== 'Application Support' && Ca.Case_Reason_Order_Support__c==null && (Ca.Sub_Type_Order_Support__c== 'General Query' || Ca.Sub_Type_Order_Support__c== 'MyQuotes' || Ca.Sub_Type_Order_Support__c=='Partner Portal'|| Ca.Sub_Type_Order_Support__c=='Application Training' || Ca.Sub_Type_Order_Support__c=='Solutions Configurator')  ){
        
            Ca.Case_Reason_Order_Support__c.addError(Label.You_must_enter_a_value);
            okayTosave=false;
        }
        
        
        if(selectedvalue== 'Deal Registration' && Ca.Case_Reason_Order_Support__c==null && (Ca.Sub_Type_Order_Support__c== 'Program and process queries' || Ca.Sub_Type_Order_Support__c== 'Technical Queries' )){
        
            Ca.Case_Reason_Order_Support__c.addError(Label.You_must_enter_a_value);
            okayTosave=false;
        }
        
        if(selectedvalue== 'On Boarding' && Ca.Case_Reason_Order_Support__c==null &&  (Ca.Sub_Type_Order_Support__c== 'Company name change' || Ca.Sub_Type_Order_Support__c== 'On-boarding Queries' || Ca.Sub_Type_Order_Support__c== 'Partner Portal')){
            
            Ca.Case_Reason_Order_Support__c.addError(Label.You_must_enter_a_value);
            okayTosave=false;
        }
       
        
        if(selectedvalue== 'Order Support' && Ca.Case_Reason_Order_Support__c==null && (Ca.Sub_Type_Order_Support__c== 'Distribution queries' || Ca.Sub_Type_Order_Support__c== 'Document Requests' || Ca.Sub_Type_Order_Support__c== 'Licenses (Digitally Delivered)'|| Ca.Sub_Type_Order_Support__c=='Order Status' || Ca.Sub_Type_Order_Support__c=='Shipping' || Ca.Sub_Type_Order_Support__c=='Wrong/Damaged')){
            
            Ca.Case_Reason_Order_Support__c.addError(Label.You_must_enter_a_value);
            okayTosave=false;
        }
        
        if(selectedvalue== 'Partner Program' && Ca.Case_Reason_Order_Support__c==null && Ca.Sub_Type_Order_Support__c!=null){
        
            Ca.Case_Reason_Order_Support__c.addError(Label.You_must_enter_a_value);
            okayTosave=false;
        }
           
        if(selectedvalue== 'Channel Services Helpdesk' && Ca.Case_Reason_Order_Support__c==null && (Ca.Sub_Type_Order_Support__c== 'Services Competency Training' || Ca.Sub_Type_Order_Support__c== 'Dell Technologies Services Requirements' || Ca.Sub_Type_Order_Support__c=='Services Entitlement Access'|| Ca.Sub_Type_Order_Support__c=='Partner Process Forms' || Ca.Sub_Type_Order_Support__c=='Field Services (ASP) and Deploy Subcontracting Partners' || Ca.Sub_Type_Order_Support__c=='GS Partner Extranet Access (FOBs)' || Ca.Sub_Type_Order_Support__c=='Program Specialist Engagement and Internal Forms' || Ca.Sub_Type_Order_Support__c == 'Renewal Sales')){
            Ca.Case_Reason_Order_Support__c.addError(Label.You_must_enter_a_value);
            okayTosave=false;
        }   
            
        if(Ca.Unauthenticated_Contact_Email__c== null){
            ca.Unauthenticated_Contact_Email__c.addError(Label.You_must_enter_a_value);
            okayToSave = false;
        } 
        if(Ca.Subject== null){
            ca.Subject.addError(Label.You_must_enter_a_value);
            okayToSave = false;
        } 
        if(Ca.Description== null){
            ca.Description.addError(Label.You_must_enter_a_value);
            okayToSave = false;
        }
        
       
    system.debug('Sub_Type_Orde>>>>'+ca.Sub_Type_Order_Support__c);         
        if(selectedvalue== 'On Boarding' && ca.Sub_Type_Order_Support__c=='Company name change'){            
            
             if(!ca.Business_change_letter_cert_attached__c) {
                ca.Business_change_letter_cert_attached__c.addError(Label.You_must_enter_a_value);               
                okayToSave = false;
            } 
            
            if(Ca.Case_Reason_Order_Support__c == 'Address change' ){                
                if( Ca.Original_Or_Incorrect_Address__c == null ){
                        ca.Original_Or_Incorrect_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                } 
        
                if(  Ca.New_Address__c== null ){
                        ca.New_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                } 
            } 
    
            if( Ca.Case_Reason_Order_Support__c == 'Name & Address change'){
                if(Ca.Original_Or_Incorrect_Address__c == null ){
                        ca.Original_Or_Incorrect_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
    
                if( Ca.New_Address__c== null ){
                        ca.New_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.New_Name__c== null ){
                        ca.New_Name__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                } 
         
                if( Ca.Original_Name__c== null ){
                        ca.Original_Name__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
    
                if( Ca.Current_TaxID__c== null ){
                        ca.Current_TaxID__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.New_TaxID__c== null ){
                        ca.New_TaxID__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
            } 
    
            if( Ca.Case_Reason_Order_Support__c == 'Name & Address change with no tax ID change'){
                if(Ca.Original_Or_Incorrect_Address__c == null ){
                        ca.Original_Or_Incorrect_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
    
                if( Ca.New_Address__c== null ){
                        ca.New_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.New_Name__c== null ){
                        ca.New_Name__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                } 
         
                if( Ca.Original_Name__c== null ){
                        ca.Original_Name__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
            }
    
            if( Ca.Case_Reason_Order_Support__c == 'Tax ID change'){
                if( Ca.Current_TaxID__c== null ){
                        ca.Current_TaxID__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.New_TaxID__c== null ){
                        ca.New_TaxID__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
            }   
        }
        system.debug('Preferred>>>>'+ca.Sub_Type_Order_Support__c); 
        if(selectedvalue== 'On Boarding' && ca.Sub_Type_Order_Support__c=='Preferred Distributor Changes'){
        if(String.isBlank(ca.Current_Distributor_UA__c)&& String.isBlank(ca.Requested_Preferred_Distributor_UA__c)){
            ca.Current_Distributor_UA__c.addError(Label.You_must_enter_a_value);
            ca.Requested_Preferred_Distributor_UA__c.addError(Label.You_must_enter_a_value);
            okayToSave = false;
        }
        if(String.isBlank(ca.Current_Distributor_UA__c)){ 
             ca.Current_Distributor_UA__c.addError(Label.You_must_enter_a_value);
             okayToSave = false; }
        else if(String.isBlank(ca.Requested_Preferred_Distributor_UA__c)){
            ca.Requested_Preferred_Distributor_UA__c.addError(Label.You_must_enter_a_value);
             okayToSave = false; 
            }
            
        }


        
        if(selectedvalue== 'Order Support'){
            if(ca.Sub_Type_Order_Support__c=='Change of Address - Post Shipment' || ca.Sub_Type_Order_Support__c=='Pick up & Re-Delivery'){
                if(Ca.Original_Or_Incorrect_Address__c == null ){
                        ca.Original_Or_Incorrect_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
    
                if( Ca.New_Address__c== null ){
                        ca.New_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.Pickup_Address_Details__c== null ){
                        ca.Pickup_Address_Details__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }  
            }
    
            if(ca.Sub_Type_Order_Support__c=='Missing'){
                if( Ca.Full_or_Partial_order_impacted__c== null ){ 
                        ca.Full_or_Partial_order_impacted__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
                if( Ca.Product_Type__c== null ){ 
                        ca.Product_Type__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.Replacement_order_or_credit__c== null ){
                        ca.Replacement_order_or_credit__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.Delivery_Address__c== null ){
                        ca.Delivery_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
              /*  if( Ca.Item_s_Description__c== null ){
                        ca.Item_s_Description__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }*/
    
            }
    
            if(ca.Sub_Type_Order_Support__c=='Return Request'){
                if( Ca.Full_or_Partial_order_return__c== null ){
                        ca.Full_or_Partial_order_return__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.Reason_for_the_return__c== null ){
                        ca.Reason_for_the_return__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.Pick_Up_Address__c== null ){
                        ca.Pick_Up_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
               /* if( Ca.Item_s_Description__c== null ){
                        ca.Item_s_Description__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }*/
         
            }
    
            if(ca.Sub_Type_Order_Support__c=='Wrong/Damaged'){
                if( Ca.Full_or_Partial_order_impacted__c== null ){
                        ca.Full_or_Partial_order_impacted__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
                
                if( Ca.Product_Type__c== null ){
                        ca.Product_Type__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.Replacement_order_or_credit__c== null ){
                        ca.Replacement_order_or_credit__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.Pick_Up_Address__c== null ){
                        ca.Pick_Up_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
        
                if( Ca.Delivery_Address__c== null ){
                        ca.Delivery_Address__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
                }
            }
     
            if( Ca.Order_Reference_Number_Type__c== null ){
                        ca.Order_Reference_Number_Type__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
            }
        
            if( Ca.Order_Number1__c== null ){
                        ca.Order_Number1__c.addError(Label.You_must_enter_a_value);
                        okayToSave = false;
            }
        }
        }
        if( !okayToSave ) {
            //Added by Elton. This scriptvar may not be required. You may try commenting the below line and see if it still works as expected.
            scriptvar='<script> createCaptcha(); </script>';     
            return null;
        }
        
        if(selectedvalue!= 'Order Support'){ca.Order_Reference_Number_Type__c='';}
        ca.Unauthenticated_Case__c=true;
        //ca.priority='High';
       // system.debug();
       if(region!= null){
        ca.Region__c=region ;}
        If(displayLanguageCode==null || displayLanguageCode==''){
            displayLanguageCode='en_US';
        }
        ca.Unauthenticated_Case_Language__c=displayLanguageCode;
        AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.assignmentRuleId= AR.id;
            ca.setOptions(dmo);
            ca.Status = 'Assigned';            
            //Added skip all triggers
            TriggerExecutionController.setSkipAccountTriggers(true);
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
            database.insert(ca);
            
            //Reset all the skip conditions to false
            TriggerExecutionController.setSkipAccountTriggers(false);
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
            
            /*if(ca.status == 'Assigned' ){
                database.update(ca);
            }*/
 
         // Parse Attachments to listAttachments
            listAttachments = new list<Attachment>();                  
            if(attach1.name != null && attach1.name != '' && attach1.Body != null) {
                attach1.ParentId = ca.Id; 
                listAttachments.add(attach1);
            }
            if(attach2.name != null && attach2.name != '' && attach2.Body != null) {
                attach2.ParentId = ca.Id; 
                listAttachments.add(attach2);
            }
            if(attach3.name != null && attach3.name != '' && attach3.Body != null) {
                attach3.ParentId = ca.Id; 
                listAttachments.add(attach3);
            }
            if(attach4.name != null && attach4.name != '' && attach4.Body != null) {
                attach4.ParentId = ca.Id; 
                listAttachments.add(attach4);
            }
            if(attach5.name != null && attach5.name != '' && attach5.Body != null) {
                attach5.ParentId = ca.Id; 
                listAttachments.add(attach5);
            }
            
            if(listAttachments.size()!=0 ){
                insert listAttachments;
            }    
            
            
        casenum = [select caseNumber from case where id=:ca.id].caseNumber;
        Newcase=False;
        newcase1=false;
        Editcase=false;
        Thankcase=True;
        Cas=new Case();
       // openPopup();
        
        
        }
        Catch(exception e){
       System.debug('---Exception occured in inserting Unauthenicated case---'+e +'line num' + e.getLineNumber());
       }
          finally{
              listAttachments = null;
              attach1 = new Attachment();
              attach2 = new Attachment();
              attach3 = new Attachment();
              attach4 = new Attachment();
              attach5 = new Attachment();
          }
      }
       return null;
    }

    public list<selectoption> getDi_SubTypeList(){
       list<selectoption> Di_SubTypeList=new list<selectoption>();
        Di_SubTypeList.add(new selectoption('',Label.none_for_drop_down));
        Di_SubTypeList.add(new selectoption('SPL Tech query',Label.Disti_ST_SPLTechQuery));
        Di_SubTypeList.add(new selectoption('SPL content query',Label.Disti_ST_SPCcontentQuery));
        if(ca.Region__c=='EMEA' || ca.Region__c=='EC-EMEA'){
            Di_SubTypeList.add(new selectoption('Concessions - Sell Out Claim',Label.Disti_ST_Concessions_SellOutClaim));
            Di_SubTypeList.add(new selectoption('Concessions - Price Protection',Label.Disti_ST_Concessions_PriceProtection));
            Di_SubTypeList.add(new selectoption('Concessions - BFS',Label.Disti_ST_Concessions_BFS));
            Di_SubTypeList.add(new selectoption('Concessions - Volume Grid',Label.Disti_ST_Concessions_Volume_Grid));
            Di_SubTypeList.add(new selectoption('Concessions - Stock Return',Label.Disti_ST_Concessions_Stock_Return));
            Di_SubTypeList.add(new selectoption('Concessions - Wyse',Label.Disti_ST_Concessions_Wyse));
        }else if(ca.Region__c=='APJ'){
            Di_SubTypeList.add(new selectoption('Concessions - Sell Out Claim',Label.Disti_ST_Concessions_SellOutClaim));
            Di_SubTypeList.add(new selectoption('Concessions - Price Protection',Label.Disti_ST_Concessions_PriceProtection));
            Di_SubTypeList.add(new selectoption('Concessions - BFS',Label.Disti_ST_Concessions_BFS));
            Di_SubTypeList.add(new selectoption('Concessions - Stock Return',Label.Disti_ST_Concessions_Stock_Return));
            Di_SubTypeList.add(new selectoption('Concessions - Service Fees Claim',Label.Disti_ST_Concessions_ServiceFeesClaim));
            Di_SubTypeList.add(new selectoption('Concessions - Sell In Claim',Label.Disti_ST_Concessions_SellInClaim));
        }else if(ca.Region__c=='NA'){
            Di_SubTypeList.add(new selectoption('Concessions - Sell Out Claim',Label.Disti_ST_Concessions_SellOutClaim));
            Di_SubTypeList.add(new selectoption('Concessions - Price Protection',Label.Disti_ST_Concessions_PriceProtection));
            Di_SubTypeList.add(new selectoption('Concessions - BFS',Label.Disti_ST_Concessions_BFS));
            Di_SubTypeList.add(new selectoption('Concessions - Stock Return',Label.Disti_ST_Concessions_Stock_Return));
            Di_SubTypeList.add(new selectoption('Concessions - Wyse',Label.Disti_ST_Concessions_Wyse));
            Di_SubTypeList.add(new selectoption('Concessions - Bid Bucket',Label.Disti_ST_Concessions_BidBucket));
        }else if(ca.Region__c=='Latam'){
            Di_SubTypeList.add(new selectoption('Concessions - Sell Out Claim',Label.Disti_ST_Concessions_SellOutClaim));
            Di_SubTypeList.add(new selectoption('Concessions - Price Protection',Label.Disti_ST_Concessions_PriceProtection));
            Di_SubTypeList.add(new selectoption('Concessions - BFS',Label.Disti_ST_Concessions_BFS));
            Di_SubTypeList.add(new selectoption('Concessions - Stock Return',Label.Disti_ST_Concessions_Stock_Return));
            Di_SubTypeList.add(new selectoption('Concessions - Wyse',Label.Disti_ST_Concessions_Wyse));
            Di_SubTypeList.add(new selectoption('Concessions - Bid Bucket',Label.Disti_ST_Concessions_BidBucket));
        }
        return Di_SubTypeList;
        
    }
    
    public List<selectoption> DistiCaseReasons(){
        Di_CaseReasonList=new list<selectoption>();
        Di_CaseReasonList.add(new selectoption('',Label.none_for_drop_down));
        if(ca.Sub_Type_Order_Support__c=='SPL Tech query'){
            Di_CaseReasonList.add(new selectoption('SPL Access issues',Label.Disti_CR_SPLAccessissues));
            Di_CaseReasonList.add(new selectoption('B2B integrated SPL issue',Label.Disti_CR_B2B_integrated_SPLissue));
        }else if(ca.Sub_Type_Order_Support__c=='SPL content query'){
            Di_CaseReasonList.add(new selectoption('Product Description issue',Label.Disti_CR_ProductDescription_issue));
            Di_CaseReasonList.add(new selectoption('Product pricing',Label.Disti_CR_Product_pricing)); 
            Di_CaseReasonList.add(new selectoption('Product availability',Label.Disti_CR_Product_Availability)); 
            Di_CaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));     
        }else if(ca.Sub_Type_Order_Support__c=='Concessions - Stock Return'){
            Di_CaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));
        }else if(ca.Sub_Type_Order_Support__c=='Concessions - Service Fees Claim'){
            Di_CaseReasonList.add(new selectoption('Payment Query',Label.Disti_CR_Payment_Query));
            Di_CaseReasonList.add(new selectoption('Statement Query',Label.Disti_CR_Statement_Query));
            Di_CaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));
        }else if(ca.Sub_Type_Order_Support__c=='Concessions - Sell In Claim'){
            Di_CaseReasonList.add(new selectoption('Payment Query',Label.Disti_CR_Payment_Query));
            Di_CaseReasonList.add(new selectoption('Statement Query',Label.Disti_CR_Statement_Query));
            Di_CaseReasonList.add(new selectoption('Exception Request',Label.Disti_CR_Exception_Request));
            Di_CaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));
        }else {
            Di_CaseReasonList.add(new selectoption('Payment Query',Label.Disti_CR_Payment_Query));
            Di_CaseReasonList.add(new selectoption('Statement Query',Label.Disti_CR_Statement_Query));
            Di_CaseReasonList.add(new selectoption('Exception Request',Label.Disti_CR_Exception_Request));
            Di_CaseReasonList.add(new selectoption('Manual claim submission – Exception ONLY',Label.Disti_CR_ManualClaimSubmission_ExceptionOnly));
            Di_CaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));
        }
        return null;
    }
           
    public void ClearSubtypeOptions() {
        
        ca.Full_or_Partial_order_return__c= null;
        ca.Reason_for_the_return__c = null;
       // ca.Exceeds_30_day_Policy__c = null;
        ca.Pick_Up_Address__c = null;
        ca.Delivery_Address__c = null;
        ca.Original_Or_Incorrect_Address__c = null;
        ca.New_Address__c = null;
        ca.Pickup_Address_Details__c = null;
        ca.Item_s_Description__c = null;
        ca.Replacement_order_or_credit__c= null;
        ca.Full_or_Partial_order_impacted__c= null;
        ca.Product_Type__c= null;
        ca.original_name__c=null;
        ca.new_name__c=null;
        ca.current_taxID__c=null;
        ca.new_taxID__c=null;
       
        
        
    }
    
    public void clearcaseTypeValue(){
    selectedvalue= null;
    
    ClearCaseType();
    ca.Case_Category__c=null;
    
    
    editcase=false;
    EndUserdetails = false;
   
    }
    public void ClearCaseType(){
        ca.Case_Reason_Order_Support__c= null;
        ca.Sub_Type_Order_Support__c = null;
        ca.priority=null;
        Categoryerror=false;
        casetypeError=false;
        subtypeerror=false;
        casereasonerror=false;
        internalmessage=false;
        countryerror=False;
        Disti = false;
        NonDisti = false;
        Buttons = false;
        Priority=false;
        priorityerror =false;
        
        /*if(Ca.Country_Area__c==null && ){
        options.clear();}
        */
    }   

    public PageReference cancel(){
        PageReference pr = new PageReference('/apex/UnAuthenticatedCaseVFPage');

        Editcase= false;
        newcase1=true;
        Thankcase=False;
        EndUserdetails = false;
        ordertype = false;
        Disti = false;
        NonDisti = false;
       clearcaseTypeValue();
        selectedvalue=null;
        Buttons=false;
        Ca.Country_Area__c= null;
        Priority=false;
        return pr;
    }
 
     public list<selectoption> getCategory(){
       list<selectoption> Category=new list<selectoption>();
        Category.add(new selectoption('',Label.none_for_drop_down));
        Category.add(new selectoption('Internal User',label.Internal_User));
        Category.add(new selectoption('Partner User',label.Partner_User));
        
        
        return Category;
        
    }   
    
    public list<selectoption> getpriorityvalues(){
       list<selectoption> priorityvalues=new list<selectoption>();
        priorityvalues.add(new selectoption('',Label.none_for_drop_down));
        priorityvalues.add(new selectoption('High','High'));
        priorityvalues.add(new selectoption('Medium','Medium'));
        priorityvalues.add(new selectoption('Low','Low'));
        
        
        return priorityvalues;
        
    }   
    
    public void spin() {
        long now = datetime.now().gettime();
        while(datetime.now().gettime()-now<5000); // Busy loop for 5000 ms
    }
}