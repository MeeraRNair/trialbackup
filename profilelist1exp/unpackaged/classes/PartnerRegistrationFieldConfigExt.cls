/*--------------------------------------------------------------------------
    Revision  Developer          Date        Description

    1.0       Alvin             23.05.2011  CR6243  :   SFDC should allow configuration of partner type without having to create a CR 
                                            business. Designated users with specific profile should be able to create new 
                                            Partner Types.  
    2.0       Carmen            04.10.2011  Fixed defect 15670 
    3.0       Fenny             05.10.2011  Fixed defect 15701
    4.0       Vikas             21.08.2013  R14.10 CR8435: Need field Financing Options has added in Contact tab
    5.0       Patrick           16.01.2013  R15.03 CR9230 Changes in Partner Registration form under company tab (Radio Options)
    6.0       Bikram            24.11.2015  R16.12 Changes in Partner Registration form under Segment Tab 
    7.0       Bikram            24.05.2016  CSM0602| CR 13135 Changes in Partner Registration form under Partner Selection Tab 
    --------------------------------------------------------------------------*/
    public class PartnerRegistrationFieldConfigExt {

        public String partnerTypeName                                                   {set;get;}
        public String partnerTypecountry                                                {set;get;}
        public String partnerTypeId                                                     {set;get;}
        public Boolean isNewPartnerTypeFlag                                             {set;get;}  //used to determine whether it is new partner type
        public List<Partner_Type_Field_Configuration__c> tempFieldConfigList            {set;get;}  //used to temp hold all fields
        
        public List<PartnerRegistrationFieldConfig> fieldConfigOutputList               {set;get;} //used to hold all fields    
        
        //START R14.2
        public List<PartnerRegistrationFieldConfig> fieldConfigSmartEntryOutputList        {set;get;} //used to capture smartentry fields
        //END R14.2
        public List<PartnerRegistrationFieldConfig> fieldConfigContactOutputList        {set;get;} //used to capture contect fields
        public List<PartnerRegistrationFieldConfig> fieldConfigCompanyOutputList        {set;get;} //used to capture company fields
        public List<PartnerRegistrationFieldConfig> fieldConfigFocusOutputList          {set;get;} //used to capture Focus fields
        public List<PartnerRegistrationFieldConfig> fieldConfigSegmentOutputList        {set;get;} //used to capture Segment fields
        public List<PartnerRegistrationFieldConfig> fieldConfigServiceOutputList        {set;get;} //used to capture Service fields R16.03 changes
        
        public Boolean showErrorMsg                                                     {set;get;}
        public Boolean ptIdNotFound                                                     {set;get;}
        
        //new contructure
        
        public PartnerRegistrationFieldConfigExt(String ptid){
            partnerTypeId = ptid;
                            
            if(StringUtils.isBlank(partnerTypeId)){
                // Fenny - 05.10.2011 - Fixed defect 15701
                isNewPartnerTypeFlag = false; 
                ptIdNotFound = true;
                showErrorMsg = true;
                PageUtils.addError('Partner type id not found.');                                                         
                return;
            }else{
                tempFieldConfigList = new  List<Partner_Type_Field_Configuration__c>();
                
                tempFieldConfigList = doReturnQueryExistingPTRecords(partnerTypeId);
                
                if(tempFieldConfigList.size()>0){   
                    doSetPartnerTypeInfo(partnerTypeId);
                }                               
                                                
            }
            
            if(isNewPartnerType(tempFieldConfigList)){
                doSetPartnerTypeInfo(partnerTypeId);
                fieldConfigOutputList = initialNewFieldConfigRecords();
                initializeRespectiveTabField(fieldConfigOutputList);            
                isNewPartnerTypeFlag=true;
                        
            }else{
                fieldConfigOutputList = initialExistingFieldConfigRecords(tempFieldConfigList);
                initializeRespectiveTabField(fieldConfigOutputList);
                isNewPartnerTypeFlag=false;
                
            }
        }
        
        
        //end of new constructure
        
        public PartnerRegistrationFieldConfigExt(ApexPages.StandardController c){
            partnerTypeId = pageUtils.get('ptid');
                            
            if(StringUtils.isBlank(partnerTypeId)){
                // Fenny - 05.10.2011 - Fixed defect 15701
                isNewPartnerTypeFlag = false; 
                ptIdNotFound = true;
                showErrorMsg = true;
                PageUtils.addError('Partner type id not found.');                                                         
                return;
            }else{
                tempFieldConfigList = new  List<Partner_Type_Field_Configuration__c>();
                
                tempFieldConfigList = doReturnQueryExistingPTRecords(partnerTypeId);
                
                if(tempFieldConfigList.size()>0){   
                    doSetPartnerTypeInfo(partnerTypeId);
                }                               
                                                
            }
            
            if(isNewPartnerType(tempFieldConfigList)){
                doSetPartnerTypeInfo(partnerTypeId);
                fieldConfigOutputList = initialNewFieldConfigRecords();
                initializeRespectiveTabField(fieldConfigOutputList);            
                isNewPartnerTypeFlag=true;
                        
            }else{
                fieldConfigOutputList = initialExistingFieldConfigRecords(tempFieldConfigList);
                initializeRespectiveTabField(fieldConfigOutputList);
                isNewPartnerTypeFlag=false;
                
            }
        }

        //query and return existing PT records
        private List<Partner_Type_Field_Configuration__c> doReturnQueryExistingPTRecords(String tempPartnerTypeId){
            List<Partner_Type_Field_Configuration__c>   tempFieldConfigList = new  List<Partner_Type_Field_Configuration__c>();
            
            if(StringUtils.isNotBlank(tempPartnerTypeId)){                      
                tempFieldConfigList = [ SELECT  id, Name,Field_Name__c, Tab_Name__c, Is_Enabled__c, Is_Required__c,partner_type__r.name,partner_type__r.country__r.name   
                                    FROM    Partner_Type_Field_Configuration__c
                                    WHERE   partner_type__c =:tempPartnerTypeId ORDER BY Tab_Name__c
                                   ];
            }
            
            return tempFieldConfigList;
        }

        //check whether it is calling new or existing field config records
        private Boolean isNewPartnerType(List<Partner_Type_Field_Configuration__c> tempConfigFieldList){
            Boolean isNewPartnerType = false;
            if(tempConfigFieldList!=null && tempConfigFieldList.size()==0){
                isNewPartnerType = true;
            }
            return isNewPartnerType;
        }
        
        
        
        //used to pulled existing records belongs to current partner type
        public List<PartnerRegistrationFieldConfig> initialExistingFieldConfigRecords(List<Partner_Type_Field_Configuration__c> tempConfigFieldList){
            List<PartnerRegistrationFieldConfig> tempFieldConfigOutputList = new List<PartnerRegistrationFieldConfig>();
            if(tempConfigFieldList!=null){          
                PartnerRegistrationFieldConfig fieldConfigWrappedObj = null;
                    for(Partner_Type_Field_Configuration__c fieldConfigRecord:tempConfigFieldList){
                         fieldConfigWrappedObj = new PartnerRegistrationFieldConfig( fieldConfigRecord.Field_Name__c, fieldConfigRecord.Tab_Name__c, fieldConfigRecord.Is_Enabled__c, fieldConfigRecord.Is_Required__c);
                         tempFieldConfigOutputList.add(fieldConfigWrappedObj); 
                    }
            }
            return tempFieldConfigOutputList;
        }
        
        //initialized different tab fields
        public void initializeRespectiveTabField(List<PartnerRegistrationFieldConfig> tempFieldConfigOutputList){
            
            if(tempFieldConfigOutputList.size()>0){
                
                //START R14.2
                fieldConfigSmartEntryOutputList    = new List<PartnerRegistrationFieldConfig>();
                //END R14.2         
                fieldConfigContactOutputList    = new List<PartnerRegistrationFieldConfig>(); 
                fieldConfigCompanyOutputList    = new List<PartnerRegistrationFieldConfig>(); 
                fieldConfigFocusOutputList      = new List<PartnerRegistrationFieldConfig>(); 
                fieldConfigSegmentOutputList    = new List<PartnerRegistrationFieldConfig>(); 
                fieldConfigServiceOutputList    = new List<PartnerRegistrationFieldConfig>();    
        
                for(PartnerRegistrationFieldConfig fieldConfig : tempFieldConfigOutputList){
                    //START R14.2
                    if(StringUtils.equalsIgnoreCase(fieldConfig.tabName, 'Partner Selection')){   fieldConfigSmartEntryOutputList.add(fieldConfig);}
                    //END R14.2 
                    if(StringUtils.equalsIgnoreCase(fieldConfig.tabName, 'Contact')){   fieldConfigContactOutputList.add(fieldConfig);}
                    if(StringUtils.equalsIgnoreCase(fieldConfig.tabName, 'Company')){   fieldConfigCompanyOutputList.add(fieldConfig);}
                    if(StringUtils.equalsIgnoreCase(fieldConfig.tabName, 'Focus'))  {   fieldConfigFocusOutputList.add(fieldConfig);}
                    if(StringUtils.equalsIgnoreCase(fieldConfig.tabName, 'Segment')){   fieldConfigSegmentOutputList.add(fieldConfig);}
                    /* R16.03 Partner Profiling II */
                    if(StringUtils.equalsIgnoreCase(fieldConfig.tabName, 'Service')){   fieldConfigServiceOutputList.add(fieldConfig);}                 
                }
            }
        }
        
        public void doPageLoad(){
            if(isNewPartnerTypeFlag){
                doSave();
                tempFieldConfigList = new  List<Partner_Type_Field_Configuration__c>();         
                tempFieldConfigList = doReturnQueryExistingPTRecords(partnerTypeId);
                fieldConfigOutputList = initialExistingFieldConfigRecords(tempFieldConfigList);
                initializeRespectiveTabField(fieldConfigOutputList);
                isNewPartnerTypeFlag=false;
            }
        }
        
        public PageReference doSave(){
            List<PartnerRegistrationFieldConfig> fieldConfigMergeList = new List<PartnerRegistrationFieldConfig>();
            //START R14.2
             fieldConfigMergeList.addAll(fieldConfigSmartEntryOutputList);
            //END R14.2
            fieldConfigMergeList.addAll(fieldConfigContactOutputList);
            fieldConfigMergeList.addAll(fieldConfigCompanyOutputList);
            fieldConfigMergeList.addAll(fieldConfigFocusOutputList);
            fieldConfigMergeList.addAll(fieldConfigSegmentOutputList);
            /* R16.03 Partner Profiling II */
            fieldConfigMergeList.addAll(fieldConfigServiceOutputList);
            system.debug('fieldConfigMergeList=='+fieldConfigMergeList);
            system.debug('isNewPartnerTypeFlag=='+isNewPartnerTypeFlag);
            system.debug('---fieldConfigServiceOutputList---'+fieldConfigServiceOutputList);
            if(isAtLeastOneAgreementSelected(fieldConfigSegmentOutputList)){                
                Savepoint sp = Database.setSavepoint();
                try{
                    List<Partner_Type_Field_Configuration__c> saveList = new List<Partner_Type_Field_Configuration__c>();
                    if(isNewPartnerTypeFlag){               
                        saveList = doInitializeFieldConfigSaveList(fieldConfigMergeList);   
                        system.debug('insert saveList=='+saveList);                     
                        insert saveList;                    
                        return null;
                        
                        
                    }else{                                      
                        saveList = doInitializeFieldConfigUpdateList(fieldConfigMergeList, tempFieldConfigList);    
                        system.debug('update saveList=='+saveList);                     
                        update saveList;
                        return doRetSaveOrUpdateURL();
                    }
                
                }catch(Exception e) {
                    Database.rollback(sp);
                    ApexPages.addMessages(e);
                    return null;
                }
         }else{
                ShowErrorMsg = true;
                PageUtils.addError('Please select at least one I agree field, the field expecting is enabled and required');    
         }
            
            return null;
        }
            
        
        public PageReference doCancel(){
            return PageUtils.redirect('/'+partnerTypeId);
        }
        
        // Fenny - 05.10.20111 - Fixed defect 15701
        public PageReference doBackToPartnerTypeList(){
            string ptPrefix = Partner_Type__c.sObjectType.getDescribe().getKeyPrefix();
            return PageUtils.redirect('/' + ptPrefix + '/o');
        }
        
        public PageReference doRetSaveOrUpdateURL(){
            return PageUtils.redirect('/'+partnerTypeId);
        }
        
        //SObject List conversion
        public List<Partner_Type_Field_Configuration__c> doInitializeFieldConfigSaveList(List<PartnerRegistrationFieldConfig> tempFieldConfigOutputList){
            List<Partner_Type_Field_Configuration__c> tempRetFieldConfigList    = new List<Partner_Type_Field_Configuration__c>();
            Partner_Type_Field_Configuration__c tempPartnerTypeObj              = null;
            
            if(tempFieldConfigOutputList.size()>0)
            {
                for(PartnerRegistrationFieldConfig fieldConfig : tempFieldConfigOutputList){
                    tempPartnerTypeObj                  = new Partner_Type_Field_Configuration__c();                
                    tempPartnerTypeObj.partner_type__c  = partnerTypeId;
                    tempPartnerTypeObj.Name             = fieldConfig.fieldName;
                    tempPartnerTypeObj.Field_Name__c    = fieldConfig.fieldName;
                    tempPartnerTypeObj.Tab_Name__c      = fieldConfig.tabName;
                    tempPartnerTypeObj.Is_Enabled__c    = fieldConfig.isEnabled;
                    tempPartnerTypeObj.Is_Required__c   = fieldConfig.isRequired;
                    tempRetFieldConfigList.add(tempPartnerTypeObj);
                }
            }
            
            return tempRetFieldConfigList;
        }
        
        
        
        //Sobject list generation on update process
        public List<Partner_Type_Field_Configuration__c> doInitializeFieldConfigUpdateList(List<PartnerRegistrationFieldConfig> tempFieldConfigOutputList, List<Partner_Type_Field_Configuration__c> tempFieldConfigList){
            List<Partner_Type_Field_Configuration__c> tempRetFieldConfigList    = new List<Partner_Type_Field_Configuration__c>();      
            
            if(tempFieldConfigOutputList.size()>0 && tempFieldConfigList.size()>0)
            {   
                for(Partner_Type_Field_Configuration__c fieldConfigDBRecord : tempFieldConfigList){
                     
                     for(PartnerRegistrationFieldConfig fieldConfigOutputObj : tempFieldConfigOutputList){
                        //Ver 2.0
                        if(StringUtils.equalsIgnoreCase(fieldConfigDBRecord.Tab_Name__c,fieldConfigOutputObj.tabName)){
                            if( StringUtils.containsIgnoreCase(fieldConfigDBRecord.partner_type__c,partnerTypeId) &&
                                StringUtils.equalsIgnoreCase(fieldConfigDBRecord.Field_Name__c,fieldConfigOutputObj.fieldName)){                            
                                    fieldConfigDBRecord.Is_Enabled__c   = fieldConfigOutputObj.isEnabled;
                                    fieldConfigDBRecord.Is_Required__c  = fieldConfigOutputObj.isRequired;
                                    tempRetFieldConfigList.add(fieldConfigDBRecord);
                                    break;
                            }
                        }
                     
                     }
            
            }
            
            
        }
            return tempRetFieldConfigList;
        }
        
        //used to check if at least one agreement was selected
        public Boolean isAtLeastOneAgreementSelected(List<PartnerRegistrationFieldConfig> tempCheckList){
            Boolean isAgreementSelected = false;
            if(tempCheckList.size()>0){
                for(PartnerRegistrationFieldConfig fieldConfigRecord: tempCheckList){
                    if((StringUtils.equalsIgnoreCase(fieldConfigRecord.fieldName,'Agree dell reseller') && fieldConfigRecord.isEnabled==true && fieldConfigRecord.isRequired==true)||
                       (StringUtils.equalsIgnoreCase(fieldConfigRecord.fieldName,'Agree technology partner program') && fieldConfigRecord.isEnabled==true && fieldConfigRecord.isRequired==true)||
                       (StringUtils.equalsIgnoreCase(fieldConfigRecord.fieldName,'AGREE to Dell MFT Partner Program') && fieldConfigRecord.isEnabled==true && fieldConfigRecord.isRequired==true)||
                       (StringUtils.equalsIgnoreCase(fieldConfigRecord.fieldName,'Agree both dell resellertechpart') && fieldConfigRecord.isEnabled==true && fieldConfigRecord.isRequired==true)||
                       (StringUtils.equalsIgnoreCase(fieldConfigRecord.fieldName,'Agree dell partner dist pro') && fieldConfigRecord.isEnabled==true && fieldConfigRecord.isRequired==true)||
                       (StringUtils.equalsIgnoreCase(fieldConfigRecord.fieldName,'Agree dell partner dist sup') && fieldConfigRecord.isEnabled==true && fieldConfigRecord.isRequired==true))
                    {
                        isAgreementSelected = true;
                    }
                }   
            }
            
            return isAgreementSelected;     
        }
        
        //Grasp the Partner type info
        public void doSetPartnerTypeInfo(String tempPartnerTypeId){
                if(StringUtils.isNotBlank(tempPartnerTypeId)){
                    List<Partner_Type__c> partnerTypeList = [SELECT Name, Country__r.name FROM Partner_Type__c WHERE id=:tempPartnerTypeId limit 1];
                    partnerTypeName     = partnerTypeList[0].Name;
                    partnerTypecountry  = partnerTypeList[0].Country__r.name;
                }
                
        }
        
        //used to cater when initialNewRecords needed
        public List<PartnerRegistrationFieldConfig> initialNewFieldConfigRecords(){
            List<PartnerRegistrationFieldConfig> tempPartnerRegFieldconfigList = new PartnerRegistrationFieldConfig[]{
            
                //PartnerSelection //START R14.2
              // new PartnerRegistrationFieldConfig('Region', 'Partner Selection', true,true),
               new PartnerRegistrationFieldConfig('Join Dell PartnerDirect Program', 'Partner Selection', false,false), //END R14.2
               //CR 13374 Subramanyam
              // new PartnerRegistrationFieldConfig('Country to select dell', 'Partner Selection', true,true),
                 new PartnerRegistrationFieldConfig('Select your preferred Dell Distributor', 'Partner Selection', false,false),
                  new PartnerRegistrationFieldConfig('Sponsoring Distributor', 'Partner Selection', true,false),
               
               /*CR 13135 code comment
               new PartnerRegistrationFieldConfig('Do you want to join the PartnerDirect', 'Partner Selection', true,true),
               new PartnerRegistrationFieldConfig('Requires selection from below options', 'Partner Selection', true,true),
               new PartnerRegistrationFieldConfig('I would like access to', 'Partner Selection', true,true),
               CR 13135 code ends*/  
               
                //Contact
                //new PartnerRegistrationFieldConfig('Select your country to get started', 'Contact', true,true),
                new PartnerRegistrationFieldConfig('Salutation', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('First Name', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Last Name', 'Contact', true,false),
                 new PartnerRegistrationFieldConfig('Job Category', 'Contact', false,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Job Category Non GC', 'Contact', true,false),

                //End of EMC change
                //new PartnerRegistrationFieldConfig('Job Title', 'Contact', true,true),
                //new PartnerRegistrationFieldConfig('Other Job Category', 'Contact', true,true),
                new PartnerRegistrationFieldConfig('Contact Physical Address Message', 'Contact', true,true),
                new PartnerRegistrationFieldConfig('Address 1', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Address 2', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Address 3', 'Contact', true,false),
                
                new PartnerRegistrationFieldConfig('City', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('State / Province', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Postal Code', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Phone Number', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Mobile Phone', 'Contact', true,false),
                
                new PartnerRegistrationFieldConfig('Fax Number', 'Contact', false,false),
                new PartnerRegistrationFieldConfig('Email', 'Contact', true,false),
                
                //START R14.2
                new PartnerRegistrationFieldConfig('Primary Contact Aligned', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact First Name', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact Last Name', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact Job Category', 'Contact', false,false),
                new PartnerRegistrationFieldConfig('Primary Contact Phone Number', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact Mobile Number', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact Email', 'Contact', true,false),
                //END R14.2
                //START R14.5
                new PartnerRegistrationFieldConfig('Primary Contact Address 1', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact Address 2', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact Address 3', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact City', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact State Province', 'Contact', true,false),
                new PartnerRegistrationFieldConfig('Primary Contact Postal Code', 'Contact', true,false),
                //END R14.5
                
                
                new PartnerRegistrationFieldConfig('Would you like to receive our newsletter?', 'Contact', true,false),
                //CR 9418 starts
                new PartnerRegistrationFieldConfig('Yes,I agree to receive electronic messages from Dell','Contact',true,false),
                // CR 9418 ends
                //START 14.10 CR8435 Added by Vikas: Need field Financing Options has added in Contact tab
                new PartnerRegistrationFieldConfig('Financing Options', 'Contact', false,false),  
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Financing Options Non GC', 'Contact', true,false),
                //End of EMC change
                //END 14.10 CR8435 Added by Vikas
                //End of contact
                
                //Company //START R14.2
                new PartnerRegistrationFieldConfig('Latin Character Message', 'Company', true,true), //END R14.2
                new PartnerRegistrationFieldConfig('Full Legal Name of Your Organization', 'Company', true,false), 
                new PartnerRegistrationFieldConfig('Doing Business As / Alternative Company Name', 'Company', true,false),
                //new PartnerRegistrationFieldConfig('States Provinces doing business', 'Company', true,false),
                //START R14.2
                new PartnerRegistrationFieldConfig('Number of Branches Subsidiaries', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Principal Name', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Principal Title', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Dun and Bradstreet DUNS Number', 'Company', true,false),
                //END R14.2
                new PartnerRegistrationFieldConfig('Company Physical Address Message', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Organization Address 1', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Organization Address 2', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Organization Address 3', 'Company', true,false),
                
                new PartnerRegistrationFieldConfig('Organization City', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Organization State / Province', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Organization Postal Code', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Organization Country', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Organization Phone Number', 'Company', true,false),
                
                new PartnerRegistrationFieldConfig('Organization Fax', 'Company', false,false),
                //new PartnerRegistrationFieldConfig('Email', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Company Website / URL', 'Company', true,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Power of Attorney', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Legal representative/Proxy Holder Name', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Legal representative/Proxy Holder Email', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Bylaws', 'Company', true,false),
                //End of EMC change
                new PartnerRegistrationFieldConfig('Form of Organization', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Number of years in business?', 'Company', true,false),
                //START R14.2
                new PartnerRegistrationFieldConfig('Dell Primary Customer Number', 'Company', false,false),
                new PartnerRegistrationFieldConfig('Best Describe Your Company Message', 'Company', true,false),
                
                // 5.0 END
                /*new PartnerRegistrationFieldConfig('Hardware Reseller', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Software Reseller', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Referral Partner', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Distributor', 'Company', true,false),
                new PartnerRegistrationFieldConfig('System Integrator (GSI)', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Service Provider (MSP)', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Technology Partner', 'Company', true,false),
                new PartnerRegistrationFieldConfig('OEM', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Telco', 'Company', true,false),
                new PartnerRegistrationFieldConfig('ISV', 'Company', true,false),
                new PartnerRegistrationFieldConfig('Other', 'Company', true,false),
                // 5.0 END     
                 */         
                //END R14.2
                //End of company
                
                //Focus
                new PartnerRegistrationFieldConfig('Reseller Tax ID', 'Focus', true,false), 
                //new PartnerRegistrationFieldConfig('States Provinces doing business', 'Focus', true,false),
                new PartnerRegistrationFieldConfig('States Provinces doing bus', 'Focus', true,false),
                new PartnerRegistrationFieldConfig('Total Employees', 'Focus', true,false),
                new PartnerRegistrationFieldConfig('Percent Technical Prof', 'Focus', true,false),
                new PartnerRegistrationFieldConfig('Percent Sales Force', 'Focus', true,false),
                    
                //START R14.2
                new PartnerRegistrationFieldConfig('Percentage Marketing Professional Employees', 'Focus', true,false),
                //END R14.2
                new PartnerRegistrationFieldConfig('Annual Revenue', 'Focus', true,false),
                //START R14.2
                //new PartnerRegistrationFieldConfig('Hardware Revenue Percent', 'Focus', true,false),
                //END R14.2
                new PartnerRegistrationFieldConfig('Software Revenue Percent', 'Focus', true,false),
                new PartnerRegistrationFieldConfig('Service Revenue Percent', 'Focus', true,false),
                //START R14.2
                new PartnerRegistrationFieldConfig('Hardware Laptop Desktop Tablet Revenue', 'Focus', true,false),
                new PartnerRegistrationFieldConfig('Hardware Server Storage Networking Revenue', 'Focus', true,false),
                new PartnerRegistrationFieldConfig('Cloud Services Revenue', 'Focus', true,false),
                //adding of EMC change
                new PartnerRegistrationFieldConfig('Sell VCE Products & Services', 'Focus', true,false),
                //end of EMC change
                //END R14.2
                //START R14.2
                //new PartnerRegistrationFieldConfig('Product Revenue', 'Focus', true,false),
                //new PartnerRegistrationFieldConfig('Total marketing professionals', 'Focus', true,false),
                //END R14.2
                new PartnerRegistrationFieldConfig('Currently Selling Dell', 'Focus', true,false),
                //new PartnerRegistrationFieldConfig('Email', 'Focus', true,true),
                new PartnerRegistrationFieldConfig('Primary Routes to Market', 'Focus', true,false), 
                new PartnerRegistrationFieldConfig('Upload Tool Reseller Cert Message', 'Focus', true,false),               
                new PartnerRegistrationFieldConfig('Upload Tool', 'Focus', true,false),                 
                //End of Focus 
                
                //Segment
                
                 new PartnerRegistrationFieldConfig('Area of interest', 'Segment', false,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Area of Interest Non GC', 'Segment', true,false),
                //End of EMC change
                new PartnerRegistrationFieldConfig('Product focus', 'Segment', false,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Product Focus Non GC', 'Segment', true,false),
                //End of EMC change
                //START R14.5
                new PartnerRegistrationFieldConfig('Size of Customer Base', 'Segment', true,false),
                //END R14.5

                new PartnerRegistrationFieldConfig('Primary customer', 'Segment', false,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Primary Customer Non GC', 'Segment', true,false),
                //End of EMC change                
                //START R14.2
                new PartnerRegistrationFieldConfig('Secondary customer segment', 'Segment', false,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Secondary Customer Segment Non GC', 'Segment', true,false),
                //End of EMC change
                new PartnerRegistrationFieldConfig('Primary Vertical Market Segment', 'Segment', false,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Primary Vertical Market Segment Non GC', 'Segment', true,false),
                //End of EMC change
                new PartnerRegistrationFieldConfig('Secondary Vertical Market Segment', 'Segment', false,false),

                //END R14.2    
                //Adding EMC change 
                new PartnerRegistrationFieldConfig('Secondary Vertical Market Segment Non GC', 'Segment', true,false),
                //End of EMC change            
                new PartnerRegistrationFieldConfig('Tertiary customer', 'Segment', false,false),
                //Adding EMC change 
                new PartnerRegistrationFieldConfig('Tertiary customer segment Non GC', 'Segment', true,false),
                //End of EMC change
                new PartnerRegistrationFieldConfig('Tertiary practice area', 'Segment', false,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Tertiary Practice Area Non GC', 'Segment', true,false),
                //End of EMC change
                new PartnerRegistrationFieldConfig('Other customers', 'Segment', false,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Other Customers Non GC', 'Segment', true,false),
                //End of EMC change
                //new PartnerRegistrationFieldConfig('Primary Channel Model', 'Segment', true,false),
                new PartnerRegistrationFieldConfig('Have read partner program guide', 'Segment', true,false),
                new PartnerRegistrationFieldConfig('Preferred dell distr partner', 'Segment', false,false),
                new PartnerRegistrationFieldConfig('Resale revenue', 'Segment', true,false),
                //START R14.2
                new PartnerRegistrationFieldConfig('Top 3 Vendors', 'Segment', false,false),
                //Adding EMC change
                new PartnerRegistrationFieldConfig('Top 3 Vendors Non GC', 'Segment', true,false),
                //End of EMC change
                new PartnerRegistrationFieldConfig('Application Environments', 'Segment', true,false),
                new PartnerRegistrationFieldConfig('Organization Industry Certificate', 'Segment', false,false),
                //END R14.2
                //Adding EMC change
                 new PartnerRegistrationFieldConfig('Organization Industry Certificate Non GC', 'Segment', true,false),
                 //End of EMC change
                new PartnerRegistrationFieldConfig('Export compliance agreed', 'Segment', true,false),
                new PartnerRegistrationFieldConfig('Requesting To Support Letters in LATAM', 'Segment', true,false),
                
                new PartnerRegistrationFieldConfig('Deal Registration & Lead Management Enabled', 'Segment', false,false),
                new PartnerRegistrationFieldConfig('Training enabled', 'Segment', false,false),
                new PartnerRegistrationFieldConfig('Partner finder enabled', 'Segment', false,false),
                new PartnerRegistrationFieldConfig('Agree dell reseller', 'Segment', true,true),
                new PartnerRegistrationFieldConfig('Agree technology partner program', 'Segment', false,false),
                //CR13300
                new PartnerRegistrationFieldConfig('AGREE to Dell MFT Partner Program', 'Segment', false,false),
                //6.0 starts 
                new PartnerRegistrationFieldConfig('Agree OEM Terms and Conditions', 'Segment', false,false),
                //6.0 end
                //new PartnerRegistrationFieldConfig('Authorised representative', 'Segment', true,false),
                //new PartnerRegistrationFieldConfig('Agree both dell resellertechpart', 'Segment', true,false),
                new PartnerRegistrationFieldConfig('Agree dell partner dist pro', 'Segment', false,false),            
                new PartnerRegistrationFieldConfig('Agree dell partner dist sup', 'Segment', false,false),
                //Bikram D&B Changes
                new PartnerRegistrationFieldConfig('Currently under investigation?', 'Segment', true,false),
                new PartnerRegistrationFieldConfig('Individual Principals', 'Segment', true,false),
                new PartnerRegistrationFieldConfig('Position of influence or power?', 'Segment', true,false),
                //new PartnerRegistrationFieldConfig('Employed by a government organization?', 'Segment', true,false),
                //START R14.2
                new PartnerRegistrationFieldConfig('Comments', 'Segment', true,false),            
                //END R14.2
                //START R14.5              
                new PartnerRegistrationFieldConfig('Active Buying Relationship Agreement', 'Segment', true,false),
                //END R14.5
                //End of Segment
                /* R16.03 Partner Profiling II Service Tab starts */
                new PartnerRegistrationFieldConfig('Service Type','Service',true,false),
                new PartnerRegistrationFieldConfig('Service Model','Service',true,false),
                new PartnerRegistrationFieldConfig('Service Coverage','Service',true,false),
                new PartnerRegistrationFieldConfig('Mode of Service','Service',true,false),
                new PartnerRegistrationFieldConfig('Hardware warranty(Break/fix support)','Service',false,false),
                new PartnerRegistrationFieldConfig('Software Technical Support','Service',false,false),
                new PartnerRegistrationFieldConfig('Installation/Deployment Services','Service',false,false),
                new PartnerRegistrationFieldConfig('Installation/Deployment Services Market','Service',false,false),
                new PartnerRegistrationFieldConfig('Custom Configuration/Imaging','Service',false,false),
                new PartnerRegistrationFieldConfig('Data Migration','Service',false,false),
                new PartnerRegistrationFieldConfig('Asset recovery/resale/recycling','Service',false,false),
                new PartnerRegistrationFieldConfig('Consulting','Service',false,false),
                new PartnerRegistrationFieldConfig('Consulting Market','Service',false,false),
                new PartnerRegistrationFieldConfig('Education/Training','Service',false,false),
                new PartnerRegistrationFieldConfig('Managed Deployment','Service',false,false),
                new PartnerRegistrationFieldConfig('Custom enterprise/data center services','Service',false,false),
                new PartnerRegistrationFieldConfig('Deliver to your Customer','Service',true,false),
                new PartnerRegistrationFieldConfig('Resell to your Customer','Service',true,false),
                new PartnerRegistrationFieldConfig('Dell Service Tools Used','Service',false,false),
                new PartnerRegistrationFieldConfig('Sales Sponser Name','Service',true,false),
                new PartnerRegistrationFieldConfig('Sales Sponsor Email','Service',true,false),
                new PartnerRegistrationFieldConfig('Sales Sponsor Telephone','Service',true,false),
                
                new PartnerRegistrationFieldConfig('Marketing Contact Email','Service',true,false),
                new PartnerRegistrationFieldConfig('Marketing Contact Name','Service',true,false),
                new PartnerRegistrationFieldConfig('Marketing Contact Telephone','Service',true,false),
                new PartnerRegistrationFieldConfig('Marketing Contact Title','Service',true,false),
                
                new PartnerRegistrationFieldConfig('Sale Report Provider Contact Email','Service',true,false),
                new PartnerRegistrationFieldConfig('Sale Report Provider Contact Name','Service',true,false),
                new PartnerRegistrationFieldConfig('Sale Report Provider Contact Telephone','Service',true,false),
                new PartnerRegistrationFieldConfig('Sale Report Provider Contact Title','Service',true,false),
                
                new PartnerRegistrationFieldConfig('Service Offering Contact Email','Service',true,false),
                new PartnerRegistrationFieldConfig('Service Offering Contact Name','Service',true,false),
                new PartnerRegistrationFieldConfig('Service Offering Contact Telephone','Service',true,false),
                new PartnerRegistrationFieldConfig('Service Offering Contact Title','Service',true,false),
                
                new PartnerRegistrationFieldConfig('CSP/MSP Organization require EMC Storage','Service',true,false),
                new PartnerRegistrationFieldConfig('existing contractual relationship','Service',true,false),
                new PartnerRegistrationFieldConfig('Dell Services Portfolio','Service',true,false),
                new PartnerRegistrationFieldConfig('Intrested in learning Dell Services?','Service',true,false),
                new PartnerRegistrationFieldConfig('Services lead First Name','Service',true,false),
                new PartnerRegistrationFieldConfig('services lead last name','Service',true,false),
                new PartnerRegistrationFieldConfig('Services lead Job Title','Service',true,false),
                new PartnerRegistrationFieldConfig('Services lead Phone Number','Service',true,false),
                new PartnerRegistrationFieldConfig('Services lead Email','Service',true,false)
                
                /* R16.03 Partner Profiling Service Tab End */
                
                
            };      
            
            return tempPartnerRegFieldconfigList;           
        }

    public class PartnerRegistrationFieldConfig{
        public String id            {set;get;}
        public String fieldName     {set;get;}
        public String tabName       {set;get;}  
        public Boolean isEnabled    {set;get;}
        public Boolean isRequired   {set;get;}
        
            
        
        public PartnerRegistrationFieldConfig(String tempFieldName, String tempTabName, Boolean tempIsEnabled, Boolean tempIsRequired){
            this.fieldName  = tempFieldName;
            this.tabName    = tempTabName;
            this.isEnabled  = tempIsEnabled;
            this.isRequired = tempIsRequired;   
        }
        
        //used for updating records
        public PartnerRegistrationFieldConfig(String tempId,String tempFieldName, String tempTabName, Boolean tempIsEnabled, Boolean tempIsRequired){
            this.id         = tempId;
            this.fieldName  = tempFieldName;
            this.tabName    = tempTabName;
            this.isEnabled  = tempIsEnabled;
            this.isRequired = tempIsRequired;
        }
            
    }

    }