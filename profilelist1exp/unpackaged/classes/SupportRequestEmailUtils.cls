/***********************************************************
* Name          : SupportRequestEmailUtils
* Description   : Util class for CEM Email population
* ---------------------------------------------------------
* Revision  Name            Date        Description
* 1.0       Krishna/Hanan   18.09.2009  Creation CR #1248
  2.0       Meera           07.12.2009  Updated  CR #1365 Updated to populate Support Owner on Creation
  3.0       MenMee          19.07.2011  REL12.10 CR6493 Sales Role Change (Technical Sales Rep -> Inside Product Specialist)        
* 4.0       Azwanti         29.09.2011  REL12.10 CR6493-0182 Sales Role Change (Cross Domain Sales Engineer -> Customer System Engineer 
                                                 , Inside Product Specialist -> Technical Sales Rep)
* 5.0       Azwanti         17.10.2011  REL12.10 CR6493-0189 Sales Role Change (Customer System Engineer -> System Consultant)
* 6.0       Azwanti         27.10.2011  REL12.10 CR6493-0190 Added Sales Role 'Services System Engineer'.
* 7.0       Azwanti         28.10.2011  REL12.10 CR6493-0191 Sales Role Change(Services System Engineer -> Services Sales Executive Email)
* 8.0       Deepa           06.13.2012  ReL13.7  CR7098 Popultae sales team members for roles Account Executive,Services Sales Executive and Services Account Executive on Support Request Object
* 9.0       Krishnamoorthi  15-Jan-2013 R14.2 CR7804 GPCC - Merging of Contract Support Requests   
* 10.0      Sathish         01-Aug-2013 R14.10 CR8527 send mail to user based on CSSR fields selected in support types   
* 10.1      KP              09-Aug-2014 R15.07 Added a limit check to solve deployment email limit issue.
* 11.0      Kokila          24-Jun-2015 R16.07 CR11633 Sales Role Change for Services Sales Executive and Services Account Executive on Support Request Object  
* 12.0      Krishnamoorthi  23-Dec-2015 R16.12 CR12512 - Pre Sales -  Remove picklist value 'US FED Specialized Support' from Support Request field Custom Service Support        
* 13.0      Krishnakumar    08-Nov-2016 R0103  Resolve single email message error on Support Request  
* 14.0      Syuhada         14-June-2017 Story 3286962:Update for GCCS (Support Request Email Fields)

* 16.0      Jessie          20-June-2017 Story 3291175:Update for GCCS (Custom Service Request)
* 17.0      Yamini          28-June-2017 Story 2742551:Project Seal Code Clean Up Services Email Notification and Profile clean up
* 18.0      Syuhada         01-Oct-2018  Story 5507718: Custom SR automated email
************************************************************/
public class SupportRequestEmailUtils{ 
    
    Static final string RECTYPE_NAME_REQUEST_PROPOSAL_SUPPORT='Request Proposal Support';
    Static final string TEAMROLE_PROPOSALS_MANAGER='Proposals Manager';
    
    //Rev 9.0 change -- Renamed the RecordType
    //Static final string RECTYPE_NAME_REQUEST_CONTRACT_SUPPORT='Request Contract Support';
    Static final string RECTYPE_NAME_REQUEST_CONTRACT_SUPPORT='Request Contracts Support';
    Static final string TEAMROLE_CONTRACTS_MANAGER='Contract Manager';
    Static final string TEAMROLE_SOW_MANAGER='SOW Manager';
    
    Static final string RECTYPE_NAME_REQUEST_CUSTOM_SERVICES_SUPPORT='Request Custom Service Support';      
    Static final string TEAMROLE_SERVICES_INTAKE_MANAGER='Services Intake Manager';
    
    Static final string US_FED_OCONUS_SUPPORT='US FED Specialized Support';
    
    static Map<String,SupportRequestMailBox__c>     srMailBoxMap  =  SupportRequestMailBox__c.getAll();
    static List<SupportRequestMailBox__c>           srMailBoxList =  SupportRequestMailBox__c.getAll().values();
    
    
    //13.0 start
    static Map<String,ID> userIDMap = new Map<String,ID>();
    //R17.0 Starts
    /*public static void getUserIDCust(){
        for(User usr:[select id,email,LastName from user where LastName in ('DGR','Finance','Legal','Proposal')]){
            if(usr.LastName == 'DGR'){
                userIDMap.put('Deal_Governance_Review_Support__c',usr.ID);  
            }else if(usr.LastName == 'Finance'){
                userIDMap.put('Services_Finance_Support__c',usr.ID);  
            }else if(usr.LastName == 'Legal'){
                userIDMap.put('Services_Legal_Support__c',usr.ID);  
            }else if(usr.LastName == 'Proposal'){
                userIDMap.put('Services_Proposal_Support__c',usr.ID);  
            }
        }
           
    
    }*/
    //R17.0 Ends
    
    
    

    public static  void supportReqBlkProcess(List<Support_Request__c> supportRequestList){ 
    
                                                                  
        system.debug('## Inside method');
        //## Variable declarations
        String recordTypeOfTheSupportRequest,acountIdOfTheSupportRequest;
        Set<String> OpportunityIdSet = new set<String>();
        List<Support_Request__c> supportRequestTempList=new  List<Support_Request__c>();
        List<Support_Request__c> supportRequestWithNoEmail=new  List<Support_Request__c>();
        Map<String, List<Support_Request__c>> roleToSupportRequestListMap =new Map<String, List<Support_Request__c>>();
        Map<String, Map<String, List<Support_Request__c>>> roleToAccountIdToSupportRequestListMap =new Map<String, Map<String, List<Support_Request__c>>>();
        
        //## RoleOrType to Support_Request__c Map
        Map<String, List<Support_Request__c>> countrySpecificEmailSupportRequestMap=new Map<String, List<Support_Request__c>> ();
        Map<String, String> OpportunityIdToAccountIdMap = new Map<String, String>();
        

        Map<ID,RecordType> recordTypeMap=new Map<ID,RecordType>([select id,name from RecordType where SobjectType='Support_Request__c']);     

        //## Looping over the inserted Support Request items                                
        for(Support_Request__c supportRequestItem: supportRequestList){ 
            
            //## Takes the RecordType name 
            if(recordTypeMap.get(supportRequestItem.RecordTypeId)==null){
                continue;
            }   
            recordTypeOfTheSupportRequest=recordTypeMap.get(supportRequestItem.RecordTypeId).name; 
            
            system.debug('## Current Record type :'+ recordTypeOfTheSupportRequest);
            
            //## Collects the Opportuniity Ids into a set  
            OpportunityIdSet.add(supportRequestItem.Opportunity__c);
            
            if(recordTypeOfTheSupportRequest.equals(RECTYPE_NAME_REQUEST_PROPOSAL_SUPPORT)){            
                addItemToStringToSupportRequestListMap(roleToSupportRequestListMap,TEAMROLE_PROPOSALS_MANAGER,supportRequestItem);
                system.debug('## Added the Proposal support Type request');
            }
            
            else if(recordTypeOfTheSupportRequest.equals(RECTYPE_NAME_REQUEST_CONTRACT_SUPPORT)){               
                
                system.debug('## Contract support Type request');
                //Rev 9.0 change -- Changed the field to CSMB_Contract_Request_Type__c
                //if(supportRequestItem.Contract_Support__c =='Statement of Work'){
                if(supportRequestItem.CSMB_Contract_Request_Type__c =='Statement of Work'){ 
                    //system.debug('## Contract support - SOW Type request');
                    addItemToStringToSupportRequestListMap(roleToSupportRequestListMap,TEAMROLE_SOW_MANAGER,supportRequestItem);                          
                }
                else{
                    //system.debug('## Contract support - Non SOW Type request');
                    addItemToStringToSupportRequestListMap(roleToSupportRequestListMap,TEAMROLE_CONTRACTS_MANAGER,supportRequestItem);                        
                }
                
            }
            
            else if(recordTypeOfTheSupportRequest.equals(RECTYPE_NAME_REQUEST_CUSTOM_SERVICES_SUPPORT)){
            
                //system.debug('## Custom Services Type request');
                if(supportRequestItem.Custom_Service_Support__c=='Custom Service Solution'){
                    //system.debug('## Custom Service Solution Type request');
                    addItemToStringToSupportRequestListMap(roleToSupportRequestListMap,TEAMROLE_SERVICES_INTAKE_MANAGER,supportRequestItem);                    
                }                 

                //R12.0 - CR 12512- Commenting out the below code as the picklist value 'US FED Specialized Support' is deleted from Custom_Service_Support__c
                /*else if(supportRequestItem.Custom_Service_Support__c==US_FED_OCONUS_SUPPORT){
                    addItemToStringToSupportRequestListMap(countrySpecificEmailSupportRequestMap,'US FED Specialized Support',supportRequestItem);                
                }*/                    
            }

        }//## end of for loop Support_Request__c
        
        for(Opportunity OppItem : [SELECT Id, AccountId,Account.Account_Country__c 
                                   FROM Opportunity 
                                   WHERE Id IN :OpportunityIdSet]){
            OpportunityIdToAccountIdMap.put(OppItem.Id,OppItem.AccountId);                      
        }
        
        
        //## adds roleToSupportRequestListMap values into roleToAccountIdToSupportRequestListMap
        for (string keyRole : roleToSupportRequestListMap.keySet()){
            for (Support_Request__c supportRequestItem : roleToSupportRequestListMap.get(keyRole)){
            
                acountIdOfTheSupportRequest= OpportunityIdToAccountIdMap.get(supportRequestItem.Opportunity__c);
                addItemToRoleToAccountIdToSupportRequestListMap(roleToAccountIdToSupportRequestListMap,keyRole,acountIdOfTheSupportRequest,supportRequestItem);
            }
        
        }
        
        //## method call for email Assignment.
        for (string keyRole : roleToAccountIdToSupportRequestListMap.keySet()){
            if(roleToAccountIdToSupportRequestListMap.get(keyRole).size()>0){
                setAccountTeamMailIdForSupportRequests(roleToAccountIdToSupportRequestListMap,keyRole,countrySpecificEmailSupportRequestMap);
            }
        
        }
        //## adds the contry specific emails
        if(countrySpecificEmailSupportRequestMap.size()>0){
            addCountryspecificEmailId(countrySpecificEmailSupportRequestMap);
        }
        
    }  //end of method

    
 
    
    public static void setAccountTeamMailIdForSupportRequests(Map<String, Map<String, List<Support_Request__c>>> roleToAccountIdToSupportRequestListMap,
                                                   string keyRole,
                                                   Map<String, List<Support_Request__c>> countrySpecificEmailSupportRequestMap){


        Map<String, List<Support_Request__c>> accountIdToSupportRequestListMap= roleToAccountIdToSupportRequestListMap.get(keyRole);
        Map<string,string> processedAccounIdMap = new Map<string,string>();
        
        
        for(AccountTeamMember accountTeamMemberItem: [SELECT  Id, User.email, AccountId, UserId                               
                                                      FROM AccountTeamMember 
                                                      WHERE AccountId in:accountIdToSupportRequestListMap.keySet() 
                                                      AND TeamMemberRole =:keyRole
                                                      ORDER BY AccountId,TeamMemberRole,LastModifiedDate DESC]){

            if(processedAccounIdMap.get(accountTeamMemberItem.AccountId)==null){

               assignEmailIdToSupportRequests(accountIdToSupportRequestListMap.get(accountTeamMemberItem.AccountId),accountTeamMemberItem.User.email,accountTeamMemberItem.UserId, keyRole);
               processedAccounIdMap.put(accountTeamMemberItem.AccountId,'processed');
               
            }
        }//##end of loop
        
        //##if there is no AccTeamMemb for an Account with that role..
        if(processedAccounIdMap.size() < accountIdToSupportRequestListMap.size()){
            for (string key : accountIdToSupportRequestListMap.keySet()){
                if(!processedAccounIdMap.keySet().contains(key)){  //if it doesnt contain
                    //## collects the unprocessed records into a list
                    addItemToStringToSupportRequestListMap(countrySpecificEmailSupportRequestMap,keyRole,accountIdToSupportRequestListMap.get(key));
                    
                }   
            }
        }
                
    }//## end of method
    
    public static void assignEmailIdToSupportRequests(List<Support_Request__c> supportRequestList, string emailId, String userId, String keyRole){
        
        for(Support_Request__c supportRequestItem:supportRequestList){
            
            supportRequestItem.WFEmailStatus__c = 'Support Exists';
            supportRequestItem.WFEMailField__c=emailId;
            if(supportRequestItem.Support_Owner__c == null){
                supportRequestItem.Support_Owner__c = userId;
                supportRequestItem.Support_Owner_Team_Role__c =keyRole;  
            }                    
        }
    }

    public static void addCountryspecificEmailId(Map<String, List<Support_Request__c>> countrySpecificEmailSupportRequestMap){  
    
        Set<string> CountrySet = getCountrySet(countrySpecificEmailSupportRequestMap);
        Map<string,Map<string,string>> CountryNameToEmailsMap =new Map<string,Map<string,string>>();
        string currentEmailId;
        string accountCountry;
        for (Country__c CountryItem : [SELECT Name,Contract_Support_Email__c,Custom_Service_Solution_Email__c,
                                                        Proposal_Support_Email__c,SOW_Support_Email__c,US_Fed_OCONUS_Support__c 
                                                        FROM Country__c
                                                        WHERE Name IN :CountrySet]){
            
            

            accountCountry = CountryItem.Name;
            accountCountry = accountCountry.toLowerCase();
            addItemToStringToString2DMap(CountryNameToEmailsMap,accountCountry,
                                        TEAMROLE_PROPOSALS_MANAGER, CountryItem.Proposal_Support_Email__c);
            addItemToStringToString2DMap(CountryNameToEmailsMap,accountCountry,
                                        TEAMROLE_CONTRACTS_MANAGER, CountryItem.Contract_Support_Email__c);
            addItemToStringToString2DMap(CountryNameToEmailsMap,accountCountry,
                                        TEAMROLE_SOW_MANAGER, CountryItem.SOW_Support_Email__c);
            addItemToStringToString2DMap(CountryNameToEmailsMap,accountCountry,
                                        TEAMROLE_SERVICES_INTAKE_MANAGER, CountryItem.Custom_Service_Solution_EMail__c);
            addItemToStringToString2DMap(CountryNameToEmailsMap,accountCountry,
                                        US_FED_OCONUS_SUPPORT , CountryItem.US_Fed_OCONUS_Support__c);
                                                        
                  
        } //##end of for loop
        
        //## loops over the countrySpecificEmailSupportRequestMap
        
        for(string keyRoleOrType : countrySpecificEmailSupportRequestMap.keySet()){         
            for (Support_Request__c supportRequestItem:countrySpecificEmailSupportRequestMap.get(keyRoleOrType)){
                
                if(supportRequestItem.Account_Country__c!=null){                
                    accountCountry=supportRequestItem.Account_Country__c;
                    accountCountry=accountCountry.toLowerCase();
                    if((CountryNameToEmailsMap.get(accountCountry)!=null)&&
                       (CountryNameToEmailsMap.get(accountCountry).get(keyRoleOrType))!=null){
                       
                        currentEmailId = CountryNameToEmailsMap.get(accountCountry).get(keyRoleOrType); 
                        if(currentEmailId.contains('@')){
                        
                            supportRequestItem.WFEMailField__c = currentEmailId;
                            supportRequestItem.WFEmailStatus__c = 'Support Exists';
                            
                        }
                    }else{
                        supportRequestItem.WFEmailStatus__c = 'No support for this country';
                    }
                    
                }else{
                    supportRequestItem.WFEmailStatus__c ='Blank value';
                }
                
            }//##  end of loop over Support_Request__c list
            
        }//##  end of loop over map keyset.
    
    }//## end of method
                  

    
    public static set<string> getCountrySet(Map<String, List<Support_Request__c>> countrySpecificEmailSupportRequestMap){
        
        Set<string> CountrySet = new Set<string>();
        string accountCountry;
        for(string key : countrySpecificEmailSupportRequestMap.keySet()){
            for (Support_Request__c supportRequestItem:countrySpecificEmailSupportRequestMap.get(key)){
                if(supportRequestItem.Account_Country__c!=null){
                    accountCountry=supportRequestItem.Account_Country__c.toLowerCase();
                    CountrySet.add(accountCountry);
                }    
            }
        }
        return CountrySet;
    }
    
    //## Utility method 1
    public static void addItemToStringToSupportRequestListMap(Map<String, List<Support_Request__c>> stringToSupportRequestListMap,
                                                            string key, Support_Request__c valueSupportRequest){
        
        //system.debug('##stringToSupportRequestListMap : '+ stringToSupportRequestListMap);
        if(stringToSupportRequestListMap.get(key)==null){
            stringToSupportRequestListMap.put(key, new List<Support_Request__c>{valueSupportRequest}); 
        }else{          
            stringToSupportRequestListMap.get(key).add(valueSupportRequest);
        }
    
    }
    //## Utility method 1.5
    public static void addItemToStringToSupportRequestListMap(Map<String, List<Support_Request__c>> stringToSupportRequestListMap,
                                                            string key, List<Support_Request__c> valueSupportRequestList){
        //system.debug('##Inside add list method');
        if(stringToSupportRequestListMap.get(key)==null){
            stringToSupportRequestListMap.put(key, valueSupportRequestList); 
        }else{
            stringToSupportRequestListMap.get(key).addAll(valueSupportRequestList);
        }
    
    }
    
    //## Utility method 2
    public static void addItemToRoleToAccountIdToSupportRequestListMap(Map<String, Map<String, List<Support_Request__c>>> roleToAccountIdToSupportRequestListMap,
                                                        string keyRole, string accountId, Support_Request__c valueSupportRequest){
        
        if(roleToAccountIdToSupportRequestListMap.get(keyRole)==null){
            roleToAccountIdToSupportRequestListMap.put(keyRole, new Map<String, List<Support_Request__c>>{accountId => new List<Support_Request__c>{valueSupportRequest}}); 
        }else{
            roleToAccountIdToSupportRequestListMap.get(keyRole).put(accountId,new List<Support_Request__c>{valueSupportRequest});
        }
        
    }
    //## Utility method 3
    public static void addItemToStringToString2DMap(Map<string,Map<string,string>> stringMap, string primaryKey,string secondaryKey,string value){  
        
        if(stringMap.get(primaryKey)==null){
            stringMap.put(primaryKey, new Map<string,string>{secondaryKey=>value}); 
        }else{
            stringMap.get(primaryKey).put(secondaryKey,value);
        }
    
    }
    
    //## Method which gets SalesTeamMemberEmailIds.
    
    public static void associteSalesTeamMemberEmail(Map<String,List<Support_Request__c>> OppIdToSupportRequetListMap){

        map<string, string> fieldAPInameToSalesTeamRoleMap= new Map<String,String>{
                                                            'Account_Executive_Email__c' => 'Account Executive',
                                                            'Global_Account_Manager_Email__c' => 'Global Account Manager',
                                                            'Inside_Sales_Rep_Email__c' => 'Inside Sales Rep',
                                                            //14.0
                                                             'Client_Compute_Sales_Exec_GCCS_Email__c' => 'Client & Compute Sales Exec',
                                                             'Client_Compute_Sales_Rep_GCCS_Email__c' => 'Client & Compute Inside Sales Rep',
                                                             'Client_Compute_Global_SE_GCCS_Email__c' => 'Client & Compute Global Sales Exec',
                                                            //end of 14.0
                                                            //18.0
                                                            'Services_Principal_Consultant_Email__c' => 'Services Principal Consultant',
                                                            'SSR_Glo_Support_Dep_Email__c' => 'Services Sales Rep Glo Support Dep.',
                                                            'SSE_Glo_Support_Dep_Email__c' => 'Services Sales Exec Glo Support Dep.',
                                                            'Services_RDP_Email__c' => 'Services Residency and Deployment Principal',
                                                            //end of 18.0
                                                            //'Services_Account_Executive_Email__c' => 'Services Account Executive',
                                                            'Services_Account_Executive_Email__c' => 'Services Sales Rep Bus. Solution Svcs', //v11.0 Added - To Replace 'Services Account Executive' 
                                                            'Services_Client_Specialist_Email__c' => 'Services Client Specialist',
                                                            'Services_Enterprise_Specialist_Email__c' => 'Services Enterprise Specialist',
                                                            'Services_Sales_Rep_Email__c' => 'Services Sales Rep',
                                                            'Sys_Eng_Email__c' => 'Sys Eng',
                                                            'System_Consultant_Email__c' => 'System Consultant',//r5.0 'Customer System Engineer'//r4.0 'Cross Domain Sales Engineer'   Rev 3.0
                                                            'Technical_Sales_Rep_Email__c' => 'Technical Sales Rep',//r4.0 'Inside Product Specialist'   //Rev 3.0
                                                            'Technical_Sales_Rep_SME_Email__c' => 'Technical Sales Rep SME', // added this new role as part of Athena to give access to trs sme.   
                                                            //'Services_Sales_Executive_Email__c' => 'Services Sales Executive'//r7.0 replace 'Services System Engineer' r6.0 added           
                                                            'Services_Sales_Executive_Email__c' => 'Services Sales Exec Bus. Solutions Svcs' //v11.0 Added - To Replace 'Services Sales Executive' 
                                                            };                
        String currentOpportunityId;
        Map<String,String> roleToEmailMap=new Map<String,String>();
        Set<String> opportunityIdSet=new Set<String>(); 
                                  
        system.debug('#DMLStatements#: ' + Limits.getDMLStatements());
        system.debug('#DMLStatements Limit#: ' + Limits.getLimitDMLStatements());
        system.debug('#getLimitQueryRows#: ' + Limits.getLimitQueryRows());
        system.debug('#getQueryRows#: ' + Limits.getQueryRows());
        system.debug('###In method');

        for(OpportunityTeamMember oppTeamMember:[SELECT OpportunityId,id,user.email,TeamMemberRole,lastmodifieddate
                                                FROM OpportunityTeamMember 
                                                WHERE opportunityId in :OppIdToSupportRequetListMap.keySet() 
                                                AND TeamMemberRole in :fieldAPInameToSalesTeamRoleMap.values()
                                                AND user.IsActive=true
                                                ORDER BY OpportunityId,lastmodifieddate DESC]){
            System.debug('###oppTeamMember: '+oppTeamMember);
            if(currentOpportunityId==null){
                currentOpportunityId=oppTeamMember.OpportunityId;
            }
            else if(currentOpportunityId!=oppTeamMember.OpportunityId){
                assignSalesTeamEmailIds(currentOpportunityId,roleToEmailMap,OppIdToSupportRequetListMap,fieldAPInameToSalesTeamRoleMap);
                opportunityIdSet.add(currentOpportunityId);
                currentOpportunityId=oppTeamMember.OpportunityId;                    
                roleToEmailMap.clear();
            }
            if(roleToEmailMap.get(oppTeamMember.TeamMemberRole)==null&& oppTeamMember.user.email!=null){
                roleToEmailMap.put(oppTeamMember.TeamMemberRole,oppTeamMember.User.Email);
            }
        }

        if(currentOpportunityId!=null){      
            opportunityIdSet.add(currentOpportunityId);
            assignSalesTeamEmailIds(currentOpportunityId,roleToEmailMap,OppIdToSupportRequetListMap,fieldAPInameToSalesTeamRoleMap);
            roleToEmailMap.clear();
        }
        for(String strItem:OppIdToSupportRequetListMap.keySet()){
            if(!(opportunityIdSet.contains(strItem))){
                assignSalesTeamEmailIds(strItem,roleToEmailMap,OppIdToSupportRequetListMap,fieldAPInameToSalesTeamRoleMap);
            }
        }
    }    
    //## Method which assigns SalesTeamEmailIds to SupportRequest
    
    //CR 2784 : Map the AE and ISR ID to IInside_Sales_Rep__c & Account_Executive__c fields for Global Business Ops PM Support PL
    public static  void associateSalesTeamMember(String paramOpptyId,Support_Request__c paramSupportRequest){
        Map<String,String> salesTeamMemberIdMap = new Map<String,String>();
        
        if(StringUtils.isNotBlank(paramOpptyId) && paramSupportRequest!=null){
            for(OpportunityTeamMember opptyTeamMember : [SELECT user.id,TeamMemberRole
                                                         FROM OpportunityTeamMember 
                                                         WHERE opportunityId =:paramOpptyId
                                                         AND TeamMemberRole in ('Inside Sales Rep','Account Executive')                                                                   
                                                         AND user.IsActive=true
                                                         ORDER BY OpportunityId,lastmodifieddate DESC ] ){ 
                
                    
               salesTeamMemberIdMap.put(opptyTeamMember.TeamMemberRole, opptyTeamMember.user.id);
                  
            }
        }
        System.debug('#####salesTeamMemberIdMap:'+salesTeamMemberIdMap);
        if(salesTeamMemberIdMap.size()>0){
            assignUserIdToSalesTeamMemberRole(salesTeamMemberIdMap, paramSupportRequest);
        }
        
    }
    
    //if sales team member match with related role, then put the user id to AE&ISR field 
    private static void assignUserIdToSalesTeamMemberRole(Map<String,String> salesTeamMemberIdMap, Support_Request__c paramSupportRequest){
        Map<String,String> salesTeamMemberRoleMap = new Map<String,String>{
                                                            'IInside_Sales_Rep__c' => 'Inside Sales Rep',
                                                            'Account_Executive__c' => 'Account Executive'                                                                                                                       
        };
                
        //salesTeamMemberIdMap ==> TeamMemberRole, userid
        //salesTeamMemberRoleMap ==> Field, TeamMemberRole
        for(String teamMemberIdKey : salesTeamMemberIdMap.keyset()){
            for(String teamMemberRoleKey : salesTeamMemberRoleMap.keyset()){
                if(StringUtils.equalsIgnoreCase(teamMemberIdKey,salesTeamMemberRoleMap.get(teamMemberRoleKey))){
                        paramSupportRequest.put(teamMemberRoleKey, salesTeamMemberIdMap.get(teamMemberIdKey));
                }                       
            }
        }
        
    }
    
    //CR 2784 : assign correct email to WFEmail field
    public static void assignDestinationMailBox(String paramRegion, String paramSegment, String paramVisibleSelection,Support_Request__c paramSupportRequest ){

        String builderStr       = doConcatenateBuilderStr(paramRegion, paramSegment, paramVisibleSelection).trim();
        String destinationEmail = doMatchDestinationMailBox(srMailBoxList, builderStr);     
        if(StringUtils.isNotBlank(destinationEmail) && paramSupportRequest !=null){
            paramSupportRequest.put('WFEMailField__c',destinationEmail);
        }
    }
    
    //CR 2784 : find and match input string and custom settings map
    private static String doMatchDestinationMailBox(List<SupportRequestMailBox__c> paramSrMailBoxList, String paramBuilderStr){
         String destinationEmail = '';
         String tempSearchStr    = '';
         for(integer index=0;index<paramSrMailBoxList.size();index++){                      
            tempSearchStr  = StringUtils.defaultIfEmpty(paramSrMailBoxList[index].Region__c+':', '') + StringUtils.defaultIfEmpty(paramSrMailBoxList[index].Segment__c+':', '') + StringUtils.defaultIfEmpty(paramSrMailBoxList[index].VisibleSelection__c, '');
            System.debug('### builderStr='+paramBuilderStr);
            system.debug('### tempSearchStr['+index+']='+tempSearchStr);
            system.debug('### isMatch ='+StringUtils.equalsIgnoreCase(paramBuilderStr, tempSearchStr));
            if(StringUtils.equalsIgnoreCase(paramBuilderStr, tempSearchStr)){
                destinationEmail = paramSrMailBoxList[index].Email__c;
                break;
            }
        }
        System.debug('### destinationEmail='+destinationEmail);
        return destinationEmail;
    }
    
             
    //CR 2784 : generate Input string
    public static String doConcatenateBuilderStr(String paramRegion, String paramSegment, String paramVisibleSelection){
        StringBuffer strBuilder = new StringBuffer();
        if(StringUtils.isNotBlank(paramRegion))             {strBuilder.append(paramRegion).append(':');}
        if(StringUtils.isNotBlank(paramSegment))            {strBuilder.append(paramSegment).append(':');}
        if(StringUtils.isNotBlank(paramVisibleSelection))   {strBuilder.append(paramVisibleSelection);}
        return strBuilder.toStr();
    }
    
    private static void assignSalesTeamEmailIds(String currentOpportunityId,Map<String,String> roleToEmailMap,Map<String,List<Support_Request__c>> OppIdToSupportRequetListMap,map<string, string> fieldAPInameToSalesTeamRoleMap){
        List<Support_Request__c> requestList=OppIdToSupportRequetListMap.get(currentOpportunityId);

        for(Support_Request__c requestObject:requestList){

            for(String fieldAPIname:fieldAPInameToSalesTeamRoleMap.keyset()){
                if(roleToEmailMap.get(fieldAPInameToSalesTeamRoleMap.get(fieldAPIname))!=null){
                    requestObject.put(fieldAPIname,roleToEmailMap.get(fieldAPInameToSalesTeamRoleMap.get(fieldAPIname)));
                }
                else{
                    requestObject.put(fieldAPIname,'');
                }
            }

        }
    }   
    
    //R16.0 - start
    private static Map<Id, Opportunity> querySalesGroupInfo(Map<String,List<Support_Request__c>> OppIdToSupportRequetListMap){
        
        return new Map<ID, Opportunity> ([Select Id, account.Sales_Channel__r.Sales_Method_Name__c, account.Sales_Channel__r.Segment_Business_Unit_Name__c, 
        account.Sales_Channel__r.Segment_Sub_Business_Unit_Name__c from Opportunity where Id = :OppIdToSupportRequetListMap.keySet()]);
        
    }
    //R16.0 - end 
    
    //CR 7098-start
    //## Method to assign SalesTeammemberuserid to SupportRequest role fields
    
    public static void associateSalesTeamMemberUserId(Map<String,List<Support_Request__c>> OppIdToSupportRequetListMap){

        //R16.0 - start
        map<string, string> fieldAPInameToSalesTeamRoleMap= new Map<String,String>{
                                                            'Account_Executive__c' => 'Account Executive,Client & Compute Sales Exec',
                                                            //V11.0 Start - To change the Roles for Services Sales and Services Account Executive
                                                            /*'Services_Account_Executive__c' => 'Services Account Executive',
                                                            'Services_Sales_Executive__c' => 'Services Sales Executive'*/
                                                            'Services_Account_Executive__c' => 'Services Sales Rep Bus. Solution Svcs',
                                                            'Services_Sales_Executive__c' => 'Services Sales Exec Bus. Solutions Svcs' //V11.0 - End
                                                            };                
        String currentOpportunityId;
        Map<String,String> roleToUserIdMap=new Map<String,String>();
        Set<String> opportunityIdSet=new Set<String>(); 
        
        Map<Id, Opportunity> oppMap = querySalesGroupInfo(OppIdToSupportRequetListMap);
                                         
        System.debug('####Inside associteSalesTeamMemberUserId ');
        
        List<String> setSalesTeamRoles = new List<String>();
        
        for (String strRoleName: fieldAPInameToSalesTeamRoleMap.keySet()){
            if (strRoleName.equalsIgnoreCase('Account_Executive__c')){
                setSalesTeamRoles.addAll(fieldAPInameToSalesTeamRoleMap.get(strRoleName).split(','));
                continue;
            }
            setSalesTeamRoles.add(fieldAPInameToSalesTeamRoleMap.get(strRoleName));
        }        
        System.debug('####setSalesTeamRoles : ' + setSalesTeamRoles);
        
        for(OpportunityTeamMember oppTeamMember:[SELECT OpportunityId,id,user.Id,TeamMemberRole,lastmodifieddate
                                                FROM OpportunityTeamMember 
                                                WHERE opportunityId in :OppIdToSupportRequetListMap.keySet() 
                                                AND TeamMemberRole in :setSalesTeamRoles 
                                                AND user.IsActive=true
                                                ORDER BY OpportunityId,TeamMemberRole,lastmodifieddate DESC]){
            System.debug('###oppTeamMember: '+oppTeamMember);
            if(currentOpportunityId==null){
                currentOpportunityId=oppTeamMember.OpportunityId;
            }
            else if(currentOpportunityId!=oppTeamMember.OpportunityId){
                assignSalesTeamUserIds(currentOpportunityId,roleToUserIdMap,OppIdToSupportRequetListMap,fieldAPInameToSalesTeamRoleMap, oppMap);
                opportunityIdSet.add(currentOpportunityId);
                currentOpportunityId=oppTeamMember.OpportunityId;                    
                roleToUserIdMap.clear();
            }
            if(roleToUserIdMap.get(oppTeamMember.TeamMemberRole)==null&& oppTeamMember.user.Id!=null){
                roleToUserIdMap.put(oppTeamMember.TeamMemberRole,oppTeamMember.User.Id);
            }
        }

        if(currentOpportunityId!=null){      
            opportunityIdSet.add(currentOpportunityId);
            assignSalesTeamUserIds(currentOpportunityId,roleToUserIdMap,OppIdToSupportRequetListMap,fieldAPInameToSalesTeamRoleMap, oppMap);
            roleToUserIdMap.clear();
        }
        for(String strItem:OppIdToSupportRequetListMap.keySet()){
            if(!(opportunityIdSet.contains(strItem))){
                assignSalesTeamUserIds(strItem,roleToUserIdMap,OppIdToSupportRequetListMap,fieldAPInameToSalesTeamRoleMap, oppMap);
            }
        }
        
        //R16.0 - end 
        
    }    
    
    //## Method to assign SalesTeammemberuserid to SupportRequest role fields
    //R16.0 - start
    private static void assignSalesTeamUserIds(String currentOpportunityId,Map<String,String> roleToUserIdMap,Map<String,List<Support_Request__c>> OppIdToSupportRequetListMap,map<string, string> fieldAPInameToSalesTeamRoleMap, Map<Id, Opportunity> oppMap){
        List<Support_Request__c> requestList=OppIdToSupportRequetListMap.get(currentOpportunityId);
        for(Support_Request__c requestObject:requestList){
            for(String fieldAPIname:fieldAPInameToSalesTeamRoleMap.keyset()){
                if(fieldAPIname.equalsIgnoreCase('Account_Executive__c')){
                    if(requestObject.get(fieldAPIname)!=Null || oppMap==null || oppMap.get(currentOpportunityId) == null){
                        continue;                       
                    }
                    List<String> strRoleName = fieldAPInameToSalesTeamRoleMap.get(fieldAPIname).split(',');
                    if(
                        oppMap.get(currentOpportunityId).Account.Sales_Channel__r.Sales_Method_Name__c !=null && 
                        oppMap.get(currentOpportunityId).Account.Sales_Channel__r.Sales_Method_Name__c.toUpperCase().equalsIgnoreCase('COMMERCIAL') && 
                        oppMap.get(currentOpportunityId).Account.Sales_Channel__r.Segment_Business_Unit_Name__c!=null &&
                        oppMap.get(currentOpportunityId).Account.Sales_Channel__r.Segment_Business_Unit_Name__c.toUpperCase().contains('COMMERCIAL')){
                        requestObject.put(fieldAPIname, roleToUserIdMap.get(strRoleName.get(0)));            
                        system.debug(
                        '##fieldAPIname-'+ fieldAPIname + 
                        '\nroleName-' + strRoleName.get(0)+ 
                         '\nuserId-' + roleToUserIdMap.get(strRoleName.get(0))
                         );        
                    }else if (
                        oppMap.get(currentOpportunityId).Account.Sales_Channel__r.Sales_Method_Name__c !=null && 
                        !oppMap.get(currentOpportunityId).Account.Sales_Channel__r.Sales_Method_Name__c.toUpperCase().equalsIgnoreCase('COMMERCIAL') && 
                        oppMap.get(currentOpportunityId).Account.Sales_Channel__r.Segment_Sub_Business_Unit_Name__c !=null &&
                        oppMap.get(currentOpportunityId).Account.Sales_Channel__r.Segment_Sub_Business_Unit_Name__c.toUpperCase().equalsIgnoreCase('WW GCCS')){
                        requestObject.put(fieldAPIname, roleToUserIdMap.get(strRoleName.get(1)));     
                        system.debug(
                        '##fieldAPIname-'+ fieldAPIname + 
                        '\nroleName-' + strRoleName.get(1) + 
                         '\nuserId-' + roleToUserIdMap.get(strRoleName.get(1))
                         );            
                    }
                    
                }
                else if(roleToUserIdMap.get(fieldAPInameToSalesTeamRoleMap.get(fieldAPIname))!=Null && requestObject.get(fieldAPIname)==Null){
                    requestObject.put(fieldAPIname,roleToUserIdMap.get(fieldAPInameToSalesTeamRoleMap.get(fieldAPIname)));
                    system.debug(
                        '##fieldAPIname-'+ fieldAPIname + 
                        '\nroleName-' + fieldAPInameToSalesTeamRoleMap.get(fieldAPIname) + 
                         '\nuserId-' + roleToUserIdMap.get(fieldAPInameToSalesTeamRoleMap.get(fieldAPIname))
                        );
                }
            }
        }
    }   
    //R16.0 - end 
    
    //CR 7098-End
    
    //10.0 - Start
    public static void sendHTMLEmail(List<ID> recipients, List<String> CcRecipients, String emailSubject, String htmlBody) { 
        if(Limits.getEmailInvocations() == Limits.getLimitEmailInvocations()){ //10.1 KP. stop and return if the limit is reached
            System.debug('##### Limit is hit!!');
            return;
        }
        try{
        /*
        // Create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
        //the email is not saved as an activity.
        mail.setSaveAsActivity(false);
        // Assign the addresses for the To lists to the mail object.
        mail.setToAddresses(recipients); //13.0
        //mail.setTargetObjectIds(recipients);
        // Assign the addresses for the Cc lists to the mail object.
        mail.setCcAddresses(CcRecipients);          
        // Specify the subject line for your email address.
        mail.setSubject(emailSubject);
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        // The email address of the user executing the Apex Code will be used. 
        mail.setUseSignature(false);
        // Specify the text content of the email. 
        mail.setHtmlBody(htmlBody);
        // Send the email you have created.
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//13.0
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail },false);*/ //13.0
        
        //13.0 Start
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail;
        for(Integer x=0;x<recipients.size();x++){
            mail = new Messaging.SingleEmailMessage();    
            //the email is not saved as an activity.
            mail.setSaveAsActivity(false);
            // Assign the addresses for the To lists to the mail object.
            //mail.setToAddresses(recipients); //13.0
            mail.setTargetObjectId(recipients.get(x));
            // Assign the addresses for the Cc lists to the mail object.
            mail.setCcAddresses(CcRecipients);          
            // Specify the subject line for your email address.
            mail.setSubject(emailSubject);
            // Set to True if you want to BCC yourself on the email.
            mail.setBccSender(false);
            // The email address of the user executing the Apex Code will be used. 
            mail.setUseSignature(false);
            // Specify the text content of the email. 
            mail.setHtmlBody(htmlBody);
            allmsg.add(mail);
        }   
        Messaging.sendEmail(allmsg,false);     
        }catch(Exception ex){
            System.debug('Exception occured--'+ex.getStackTraceString());
        }

    }
    
    public static void notifyCSSRRecipients(Support_Request__c newRequest, Support_Request__c oldRequest, map<Id, User> supNameUsrDtlMap, Boolean isCSSRAssignment, Boolean isCSSRDGRModified, 
                                            Boolean isCSSRLegalModified, Boolean isCSSRProposalModified, Boolean isCSSRFinanceModified, Boolean isInsertCSSR, Boolean isInqCanModified, Boolean isSupportTypeModied) {
            List<ID> eMailAddresslist = new List<ID>();
            List<string> eMailCcAddresslist = new List<string>();
            String eMailSubject = '';
            String eMailSubjectCancel = '';
            String eMailSubjectPursuitSupport = '';
            String eMailSubjectAssignment = '';
            String eMailBodyAssignment = '';
            String eMailBodyAssignment1 = '';
            String eMailBodyAssignment2 = '';
            String eMailBodyAssignment3 = '';
            String eMailBodyAssignment4 = '';
            String eMailBodyPursuitSupport = '';
            String eMailBodyPursuitSupport1 = '';
            String eMailBodyPursuitSupport2 = '';
            String eMailBodyPursuitSupport3 = '';
            String eMailBodyInquiry = '';
            String eMailBodyInquiry1 = '';
            String eMailBodyInquiry2 = '';
            String eMailBodyCancelled = '';
            Map<String, CSSR_Pursuit_Support__c> cssrPurSupportMap = CSSR_Pursuit_Support__c.getAll();
            //getUserIDCust();
            //email Subject and Body message for assigned users
            if(isCSSRAssignment == true && (newRequest.Deal_Governance_Review_Support_Name__c != null || newRequest.Services_Finance_Support_Name__c != null || 
                newRequest.Services_Proposal_Support_Name__c != null || newRequest.Services_Legal_Support_Name__c != null)) {
                
                eMailSubjectAssignment = '';
                eMailSubjectAssignment = 'Assignment Support Request '+ newRequest.Name + ' - ACTION REQUIRED';
                eMailBodyAssignment1 = '';
                eMailBodyAssignment2 = '';
                eMailBodyAssignment3 = '';
                eMailBodyAssignment4 = '';
                
                eMailBodyAssignment1 = '<p align="center">A request for ';
                eMailBodyAssignment2 = ' pursuit support has been assigned to ';
                eMailBodyAssignment3 = ' in SFDC</p>'+
                                       '<b>What Now?</b>'+
                                       '<p align="justify" style="margin-top: -5px;">If you have been assigned to support this request, please review the request and take next steps as quickly as '+
                                       'possible.</p>'+
                                       '<p align="justify" style="margin-top: -5px;">If you are the requestor, please monitor your phone and e-mail for any correspondence from the support '+
                                       'team. They may have questions, need additional information, or need to kick-off their activity in support of '+
                                       'your pursuit. If you need to submit an inquiry to the person who is supporting your request, or if you need to '+
                                       'cancel your request, you may do so by using the Inquire / Cancel options on the support request in SFDC.</p>'+
                                       '<p align="justify" style="margin-top: -5px;">Services pursuit support teams are working to support many active pursuits, so response times could vary '+
                                       'depending upon pursuit activity and volumes. Teams strive to address inquiries within two business days.</p>'+
                                       '<b>Access the Support Request:</b> <a href="'+ URL.getSalesforceBaseUrl().toExternalForm()+'/' + newRequest.Id +'">'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + newRequest.Id +'</a><br/>'+
                                       '<b>Submission Date:</b> ';  
                eMailBodyAssignment4 = '<b>Requestor: </b>' + supNameUsrDtlMap.get(newRequest.CreatedById).Name;                        
            }
            
            //email Subject and Body message for Pursuit team mail box 
                if((newRequest.Deal_Governance_Review_Support__c == 'Yes') || (newRequest.Services_Finance_Support__c == 'Yes')
                    || (newRequest.Services_Proposal_Support__c == 'Yes') || (newRequest.Services_Legal_Support__c == 'Yes')
                    ) {
                    
                    eMailSubjectPursuitSupport = '';
                    eMailSubjectPursuitSupport = 'New Request Received - '+ newRequest.Name + ' - ACTION REQUIRED';
                    eMailBodyPursuitSupport1 = '';
                    eMailBodyPursuitSupport2 = '';
                    eMailBodyPursuitSupport3 = '';
                    eMailBodyPursuitSupport1 = '<p align="center">A new support request for ';
                    eMailBodyPursuitSupport2 = '<Resource Type> pursuit support has been submitted in SFDC</p>'+
                                               '<b>What Now?</b>'+
                                               '<p align="justify" style="margin-top: -5px;">The support team will review the request and take next steps as quickly as possible. Should you '+
                                               'need to cancel your request with this support team or to contact the support team, you may do '+
                                               'so using the Inquire / Cancel options available on the support request in SFDC.</p>'+
                                               '<p align="justify" style="margin-top: -5px;">Services pursuit support teams are working to support many active pursuits, so response times '+
                                               'could vary depending upon pursuit activity and volumes. Teams strive to address inquiries '+
                                               'within two business days.</p>'+
                                               '<b>Access the Support Request:</b> <a href="'+ URL.getSalesforceBaseUrl().toExternalForm()+'/' + newRequest.Id +'">'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + newRequest.Id +'</a><br/>'+
                                               '<b>Submission Date:</b> ';
                    eMailBodyPursuitSupport3 = '<b>Requestor:</b> '+ supNameUsrDtlMap.get(newRequest.CreatedById).Name;
                                                
                }
                
                //email Subject and Body mapping if Submit Inquiry is selected
                if(newRequest.InquireCancel_DGR__c == 'Submit Inquiry' || newRequest.InquireCancel_Finance__c == 'Submit Inquiry' || 
                    newRequest.InquireCancel_Legal__c == 'Submit Inquiry' || newRequest.InquireCancel_Proposal__c == 'Submit Inquiry') {
                    eMailSubject = '';  
                    eMailSubject = 'Inquiry for '+newRequest.Name+' - ACTION REQUIRED';
                    eMailBodyInquiry1 = '';
                    eMailBodyInquiry2 = '';
                    eMailBodyInquiry1 = '<p align="center">An inquiry has been received regarding '+ newRequest.Name + '</p>\n\n' + 
                    '<b>What Now?</b>'+
                    '<p align="justify" style="margin-top: -5px;">If you submitted this inquiry, please <b>Reply All</b> to this message with details of your inquiry. '+
                    'Someone from the support team will reply as quickly as possible. Thank you for submitting '+
                    'your inquiry via SFDC.</p>'+
                    '<p align="justify" style="margin-top: -5px;">If you are responsible for assigning or supporting Support Requests for ';
                     
                    eMailBodyInquiry2 = ', please work with the inquiry requestor, ' + supNameUsrDtlMap.get(newRequest.CreatedById).Name + ', to understand and address the '+
                    'inquiry as quickly as possible.</p>'+
                    '<b>Next Steps</b>'+
                    '<p align="justify" style="margin-top: -5px;">Services pursuit support teams are working to support many active pursuits, so response '+
                    'times could vary depending upon pursuit activity and volumes. Teams strive to address '+
                    'inquires within two business days.</p>'+
                    '<b>Access the Support Request:</b> <a href="'+ URL.getSalesforceBaseUrl().toExternalForm()+'/' + newRequest.Id +'">'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + newRequest.Id +'</a><br/>'+
                    '<b>Inquiry Received:</b> '+ newRequest.CreatedDate.format('MM/dd/yyyy');
               
                }
                
                //email Subject and Body mapping if Cancel Request is selected
                if(newRequest.InquireCancel_DGR__c == 'Cancel Request' || newRequest.InquireCancel_Finance__c == 'Cancel Request' || 
                    newRequest.InquireCancel_Legal__c == 'Cancel Request' || newRequest.InquireCancel_Proposal__c == 'Cancel Request') {
                    eMailSubjectCancel = '';    
                    eMailSubjectCancel = newRequest.Name+' has been canceled';
                    eMailBodyCancelled = '';
                    eMailBodyCancelled = '<p align="center">'+ newRequest.Name + ' has been canceled</p>\n\n' + 
                    '<b>Why was the Support Request canceled?</b>'+
                    '<p align="justify" style="margin-top: -5px;">The support request was canceled via a request made through SFDC.</p>'+
                    '<b>Next Steps</b>'+
                    '<p align="justify" style="margin-top: -5px;">If you believe this support request was canceled in error, please Reply All to this message and provide '+
                    'information on why the request should be re-opened. Services pursuit teams are working to support many '+
                    'active pursuits, so response time could vary depending upon pursuit activity and volumes. Teams strive to '+
                    'address inquiries within two business days.</p>'+
                    '<p align="justify" style="margin-top: -5px;">Otherwise, no further action is needed.</p>'+
                    '<b>Access the Support Request:</b> <a href="'+ URL.getSalesforceBaseUrl().toExternalForm()+'/' + newRequest.Id +'">'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + newRequest.Id +'</a><br/>'+
                    '<b>Cancellation Date:</b> ';
                                    
                }
                
                if((newRequest.Deal_Governance_Review_Support__c == 'Yes' || newRequest.Services_Finance_Support__c == 'Yes' || newRequest.Services_Proposal_Support__c == 'Yes' 
                    || newRequest.Services_Legal_Support__c == 'Yes')
                    ) {
                    
                    eMailCcAddresslist.clear();
                    eMailCcAddresslist.add(supNameUsrDtlMap.get(newRequest.CreatedById).Email);
                    
                    if(newRequest.Deal_Governance_Review_Support__c == 'Yes') {
                        CSSR_Pursuit_Support__c cssrPurSupDtls = cssrPurSupportMap.get('DGR');
                        string dgrRequestedDate = '';
                        string dgrCancelledDate = '';
                        if(newRequest.Deal_Governance_Review_Requested_Date__c != null) {
                            dgrRequestedDate = newRequest.Deal_Governance_Review_Requested_Date__c.format('MM/dd/yyyy');
                        }
                        if(newRequest.Deal_Governance_Review_Req_Cancelled_Dt__c != null) {
                            dgrCancelledDate = newRequest.Deal_Governance_Review_Req_Cancelled_Dt__c.format('MM/dd/yyyy');
                        }
                        
                        if(isCSSRAssignment != true && (isInsertCSSR == true || (isCSSRDGRModified == true && isInqCanModified == true && oldRequest != null && (newRequest.InquireCancel_DGR__c != oldRequest.InquireCancel_DGR__c)))) {
                            eMailAddresslist.clear();
                            if(newRequest.Deal_Governance_Review_Support_Name__c == null) {
                                //eMailAddresslist.add(cssrPurSupDtls.Pursuit_Team_Mailbox__c); //13.0
                                //R17.0 Starts
                                 /* if(userIDMap.containsKey('Deal_Governance_Review_Support_Name__c'))
                                        eMailAddresslist.add(userIDMap.get('Deal_Governance_Review_Support_Name__c'));*/
                                //R17.0 Ends
                            }
                            else {
                                eMailAddresslist.add(supNameUsrDtlMap.get(newRequest.Deal_Governance_Review_Support_Name__c).ID);
                            }
                            if(newRequest.InquireCancel_DGR__c == 'Submit Inquiry') {
                                eMailBodyInquiry = eMailBodyInquiry1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyInquiry2;
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubject, eMailBodyInquiry);
                            }
                            if(newRequest.InquireCancel_DGR__c == 'Cancel Request') {
                                string eMailBodyCancelledConcat = '';
                                eMailBodyCancelledConcat = eMailBodyCancelled + dgrCancelledDate;
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectCancel, eMailBodyCancelledConcat);
                            }
                        }
                        //Send mail to assigned user if the support Name is modified
                        if(isCSSRAssignment == true && newRequest.Deal_Governance_Review_Support_Name__c != null && isCSSRDGRModified == true) {
                            eMailAddresslist.clear();
                            if(newRequest.Deal_Governance_Review_Support_Name__c != null) {
                                eMailAddresslist.add(supNameUsrDtlMap.get(newRequest.Deal_Governance_Review_Support_Name__c).ID);
                            }
                            eMailBodyAssignment = eMailBodyAssignment1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyAssignment2 + supNameUsrDtlMap.get(newRequest.Deal_Governance_Review_Support_Name__c).Name + 
                                                  eMailBodyAssignment3 + dgrRequestedDate + '<br/>' + eMailBodyAssignment4;
                                                  
                            SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectAssignment, eMailBodyAssignment);
                        }
                        
                        if(isInsertCSSR == true || (isCSSRDGRModified == true && isSupportTypeModied == true && oldRequest != null && (newRequest.Deal_Governance_Review_Support__c != oldRequest.Deal_Governance_Review_Support__c))) {
                            if(newRequest.Deal_Governance_Review_Support_Name__c == null) { // Condition to resolve defect#80547, 80549
                                //Mail need to send for pursuit team email box as per CR:8534
                                eMailAddresslist.clear();
                                eMailBodyPursuitSupport = eMailBodyPursuitSupport1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyPursuitSupport2 + dgrRequestedDate + '<br/>' + eMailBodyPursuitSupport3;
                                //13.0
                                //R17.0 Starts
                                /*if(userIDMap.containsKey('Deal_Governance_Review_Support_Name__c'))
                                        eMailAddresslist.add(userIDMap.get('Deal_Governance_Review_Support_Name__c')); */
                                //R17.0 Ends 
                                
                                //if(newRequest.Deal_Governance_Review_Support_Name__c == null) {
                                    //eMailAddresslist.add(cssrPurSupDtls.Pursuit_Team_Mailbox__c); //13.0
                                //}
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectPursuitSupport, eMailBodyPursuitSupport);
                            }
                        }
                        
                    }
                    if(newRequest.Services_Legal_Support__c == 'Yes') {
                        CSSR_Pursuit_Support__c cssrPurSupDtls = cssrPurSupportMap.get('Legal');
                        string legalRequestedDate = '';
                        string legalCancelledDate = '';
                        if(newRequest.Services_Legal_Support_Requested_Date__c != null) {
                            legalRequestedDate = newRequest.Services_Legal_Support_Requested_Date__c.format('MM/dd/yyyy');
                        }
                        if(newRequest.Services_Legal_Support_Req_Cancelled_Dt__c != null) {
                            legalCancelledDate = newRequest.Services_Legal_Support_Req_Cancelled_Dt__c.format('MM/dd/yyyy');
                        }
                        
                        if(isCSSRAssignment != true && (isInsertCSSR == true || (isCSSRLegalModified == true && isInqCanModified == true && oldRequest != null && (newRequest.InquireCancel_Legal__c != oldRequest.InquireCancel_Legal__c)))) {
                            eMailAddresslist.clear();
                            if(newRequest.Services_Legal_Support_Name__c == null) {
                                //13.0
                                //eMailAddresslist.add(cssrPurSupDtls.Pursuit_Team_Mailbox__c);
                                //R17.0 Starts
                                  /*if(userIDMap.containsKey('Services_Legal_Support_Name__c'))
                                        eMailAddresslist.add(userIDMap.get('Services_Legal_Support_Name__c'));*/
                                //R17.0 Ends
                            }
                            else {
                                eMailAddresslist.add(supNameUsrDtlMap.get(newRequest.Services_Legal_Support_Name__c).ID);
                            }
                            if(newRequest.InquireCancel_Legal__c == 'Submit Inquiry') {
                                eMailBodyInquiry = eMailBodyInquiry1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyInquiry2;
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubject, eMailBodyInquiry);
                            }
                            if(newRequest.InquireCancel_Legal__c == 'Cancel Request') {
                                string eMailBodyCancelledConcat = '';
                                eMailBodyCancelledConcat = eMailBodyCancelled + legalCancelledDate;
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectCancel, eMailBodyCancelledConcat);
                            }
                        }
                        //Send mail to assigned user if the support Name is modified
                        if(isCSSRAssignment == true && newRequest.Services_Legal_Support_Name__c != null && isCSSRLegalModified == true) {
                            eMailAddresslist.clear();
                            if(newRequest.Services_Legal_Support_Name__c != null) {
                                eMailAddresslist.add(supNameUsrDtlMap.get(newRequest.Services_Legal_Support_Name__c).ID);
                            }
                            eMailBodyAssignment = eMailBodyAssignment1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyAssignment2 + supNameUsrDtlMap.get(newRequest.Services_Legal_Support_Name__c).Name + 
                                                  eMailBodyAssignment3 + legalRequestedDate + '<br/>' + eMailBodyAssignment4;
                                                  
                            SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectAssignment, eMailBodyAssignment);
                        }
                        
                        if(isInsertCSSR == true || (isCSSRLegalModified == true && isSupportTypeModied == true && oldRequest != null && (newRequest.Services_Legal_Support__c != oldRequest.Services_Legal_Support__c))) {
                            if(newRequest.Services_Legal_Support_Name__c == null) { // Condition to resolve defect#80547, 80549
                                //Mail need to send for pursuit team email box as per CR:8534
                                eMailAddresslist.clear();
                                eMailBodyPursuitSupport = eMailBodyPursuitSupport1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyPursuitSupport2 + legalRequestedDate + '<br/>' +eMailBodyPursuitSupport3;
                                //13.0
                                //R17.0 Starts
                                /*if(userIDMap.containsKey('Services_Legal_Support_Name__c'))
                                        eMailAddresslist.add(userIDMap.get('Services_Legal_Support_Name__c'));*/
                                //R17.0 Ends
                                
                                //if(newRequest.Services_Legal_Support_Name__c == null) {
                                    //eMailAddresslist.add(cssrPurSupDtls.Pursuit_Team_Mailbox__c); //13.0
                                //}
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectPursuitSupport, eMailBodyPursuitSupport);
                            }
                        }
                    }
                    if(newRequest.Services_Finance_Support__c == 'Yes') {
                        CSSR_Pursuit_Support__c cssrPurSupDtls = cssrPurSupportMap.get('Finance');
                        string financeRequestedDate = '';
                        string financeCancelleedDate = '';
                        
                        if(newRequest.Services_Finance_Support_Requested_Date__c != null) {
                            financeRequestedDate = newRequest.Services_Finance_Support_Requested_Date__c.format('MM/dd/yyyy');
                        }
                        if(newRequest.Services_Finance_Sprt_Req_Cancelled_Dt__c != null) {
                            financeCancelleedDate = newRequest.Services_Finance_Sprt_Req_Cancelled_Dt__c.format('MM/dd/yyyy');
                        }
                        
                        if(isCSSRAssignment != true && (isInsertCSSR == true || (isCSSRFinanceModified == true && isInqCanModified == true && oldRequest != null && (newRequest.InquireCancel_Finance__c != oldRequest.InquireCancel_Finance__c)))) {
                            eMailAddresslist.clear();
                            if(newRequest.Services_Finance_Support_Name__c == null) {
                                //13.0
                                //eMailAddresslist.add(cssrPurSupDtls.Pursuit_Team_Mailbox__c);
                                //R17.0 Starts
                                 /*if(userIDMap.containsKey('Services_Finance_Support_Name__c'))
                                        eMailAddresslist.add(userIDMap.get('Services_Finance_Support_Name__c'));*/
                                //R17.0 Ends
                            }
                            else {
                                eMailAddresslist.add(supNameUsrDtlMap.get(newRequest.Services_Finance_Support_Name__c).ID);
                            }
                            if(newRequest.InquireCancel_Finance__c == 'Submit Inquiry') {
                                eMailBodyInquiry = eMailBodyInquiry1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyInquiry2;
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubject, eMailBodyInquiry);
                            }
                            if(newRequest.InquireCancel_Finance__c == 'Cancel Request') {
                                string eMailBodyCancelledConcat = '';
                                eMailBodyCancelledConcat = eMailBodyCancelled + financeCancelleedDate;
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectCancel, eMailBodyCancelledConcat);
                            }
                        }
                        //Send mail to assigned user if the support Name is modified
                        if(isCSSRAssignment == true && newRequest.Services_Finance_Support_Name__c != null && isCSSRFinanceModified == true) {
                            eMailAddresslist.clear();
                            if(newRequest.Services_Finance_Support_Name__c != null) {
                                eMailAddresslist.add(supNameUsrDtlMap.get(newRequest.Services_Finance_Support_Name__c).ID);
                            }
                            eMailBodyAssignment = eMailBodyAssignment1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyAssignment2 + supNameUsrDtlMap.get(newRequest.Services_Finance_Support_Name__c).Name + 
                                                  eMailBodyAssignment3 + financeRequestedDate + '<br/>' + eMailBodyAssignment4;
                                                  
                            SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectAssignment, eMailBodyAssignment);
                        }
                        
                        if(isInsertCSSR == true || (isCSSRFinanceModified == true && isSupportTypeModied == true && oldRequest != null && (newRequest.Services_Finance_Support__c != oldRequest.Services_Finance_Support__c))) {
                            if(newRequest.Services_Finance_Support_Name__c == null) { // Condition to resolve defect#80547, 80549
                                //Mail need to send for pursuit team email box as per CR:8534
                                eMailAddresslist.clear();
                                eMailBodyPursuitSupport = eMailBodyPursuitSupport1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyPursuitSupport2 + financeRequestedDate + '<br/>' +eMailBodyPursuitSupport3;
                                //13.0
                                //R17.0 Starts
                                 /*if(userIDMap.containsKey('Services_Finance_Support_Name__c'))
                                        eMailAddresslist.add(userIDMap.get('Services_Finance_Support_Name__c'));*/
                                //R17.0 Ends
                                //if(newRequest.Services_Finance_Support_Name__c == null) {
                                    //eMailAddresslist.add(cssrPurSupDtls.Pursuit_Team_Mailbox__c); //13.0
                                //}
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectPursuitSupport, eMailBodyPursuitSupport);
                            }
                        }
                    }
                    if(newRequest.Services_Proposal_Support__c == 'Yes') {
                        CSSR_Pursuit_Support__c cssrPurSupDtls = cssrPurSupportMap.get('Proposal');
                        string proposalRequestedDate = '';
                        string proposalCancelledDate = '';
                        
                        if(newRequest.Services_Proposal_Support_Requested_Date__c != null) {
                            proposalRequestedDate = newRequest.Services_Proposal_Support_Requested_Date__c.format('MM/dd/yyyy');
                        }
                        if(newRequest.Services_Proposal_Sprt_Req_Cancelled_Dt__c != null) {
                            proposalCancelledDate = newRequest.Services_Proposal_Sprt_Req_Cancelled_Dt__c.format('MM/dd/yyyy');
                        }
                        
                        if(isCSSRAssignment != true && (isInsertCSSR == true || (isCSSRProposalModified == true && isInqCanModified == true && oldRequest != null && (newRequest.InquireCancel_Proposal__c != oldRequest.InquireCancel_Proposal__c)))) {
                            eMailAddresslist.clear();
                            if(newRequest.Services_Proposal_Support_Name__c == null) {
                                //13.0
                                //eMailAddresslist.add(cssrPurSupDtls.Pursuit_Team_Mailbox__c);
                              //R17.0 Starts
                               /*if(userIDMap.containsKey('Services_Proposal_Support_Name__c'))
                                        eMailAddresslist.add(userIDMap.get('Services_Proposal_Support_Name__c'));*/
                              //R17.0 Ends
                            }
                            else {
                                eMailAddresslist.add(supNameUsrDtlMap.get(newRequest.Services_Proposal_Support_Name__c).ID);
                            }
                            if(newRequest.InquireCancel_Proposal__c == 'Submit Inquiry') {
                                eMailBodyInquiry = eMailBodyInquiry1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyInquiry2;
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubject, eMailBodyInquiry);
                            }
                            if(newRequest.InquireCancel_Proposal__c == 'Cancel Request') {
                                string eMailBodyCancelledConcat = '';
                                eMailBodyCancelledConcat = eMailBodyCancelled + proposalCancelledDate;
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectCancel, eMailBodyCancelledConcat);
                            }

                        }
                        //Send mail to assigned user if the support Name is modified
                        if(isCSSRAssignment == true && newRequest.Services_Proposal_Support_Name__c != null && isCSSRProposalModified == true) {
                            eMailAddresslist.clear();
                            if(newRequest.Services_Proposal_Support_Name__c != null) {
                                eMailAddresslist.add(supNameUsrDtlMap.get(newRequest.Services_Proposal_Support_Name__c).ID);
                            }
                            eMailBodyAssignment = eMailBodyAssignment1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyAssignment2 + supNameUsrDtlMap.get(newRequest.Services_Proposal_Support_Name__c).Name + 
                                                  eMailBodyAssignment3 + proposalRequestedDate + '<br/>' + eMailBodyAssignment4;
                                                  
                            SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectAssignment, eMailBodyAssignment);
                        }
                        
                        if(isInsertCSSR == true || (isCSSRProposalModified == true && isSupportTypeModied == true && oldRequest != null && (newRequest.Services_Proposal_Support__c != oldRequest.Services_Proposal_Support__c))) {
                            if(newRequest.Services_Proposal_Support_Name__c == null) { // Condition to resolve defect#80547, 80549
                                //Mail need to send for pursuit team email box as per CR:8534
                                eMailAddresslist.clear();
                                eMailBodyPursuitSupport = eMailBodyPursuitSupport1 + cssrPurSupDtls.Resource_Type_Name__c + eMailBodyPursuitSupport2 + proposalRequestedDate + '<br/>' +eMailBodyPursuitSupport3;
                                //13.0
                                //R17.0 Starts
                                /*if(userIDMap.containsKey('Services_Proposal_Support_Name__c'))
                                        eMailAddresslist.add(userIDMap.get('Services_Proposal_Support_Name__c')); */
                                //R17.0 Ends
                                //if(newRequest.Services_Proposal_Support_Name__c == null) {
                                    //eMailAddresslist.add(cssrPurSupDtls.Pursuit_Team_Mailbox__c); //13.0
                                //}
                                SupportRequestEmailUtils.sendHTMLEmail(eMailAddresslist, eMailCcAddresslist, eMailSubjectPursuitSupport, eMailBodyPursuitSupport);
                            }
                        }
                    }
                    
              }
    }
    
    //method to reset InquireCancel fields for corresponding support type after email sent
    public static void resetInquireCancelFields(set<Id> idsCSSRset) {
        if(idsCSSRset != null && idsCSSRset.size() > 0) {
            list<Support_Request__c> lstCSSRToReset = new list<Support_Request__c>();
            list<Support_Request__c> CSSRlst;
            if(idsCSSRset != null && idsCSSRset.size() > 0) {
                CSSRlst = [select Id, Deal_Governance_Review_Support__c, InquireCancel_DGR__c, Deal_Governance_Review_Support_Status__c, Services_Finance_Support__c, InquireCancel_Finance__c, 
                                                        Services_Finance_Support_Status__c, Services_Proposal_Support__c, InquireCancel_Proposal__c, Services_Proposal_Support_Status__c, 
                                                        Services_Legal_Support__c, InquireCancel_Legal__c, Services_Legal_Support_Status__c from Support_Request__c where Id in:idsCSSRset];
            }
            if(CSSRlst != null && CSSRlst.size() > 0) {
                for(Support_Request__c objCSSR : CSSRlst) {                                     
                    if(objCSSR.Deal_Governance_Review_Support__c == 'Yes' && objCSSR.InquireCancel_DGR__c != null) {
                        if(objCSSR.InquireCancel_DGR__c == 'Submit Inquiry') {
                            objCSSR.InquireCancel_DGR__c = null;
                        }
                        else if(objCSSR.InquireCancel_DGR__c == 'Cancel Request') {
                            objCSSR.Deal_Governance_Review_Support_Status__c = 'Cancelled';
                        }
                    }
                    if(objCSSR.Services_Finance_Support__c == 'Yes' && objCSSR.InquireCancel_Finance__c != null) {
                        if(objCSSR.InquireCancel_Finance__c == 'Submit Inquiry') {
                            objCSSR.InquireCancel_Finance__c = null;
                        }
                        else if(objCSSR.InquireCancel_Finance__c == 'Cancel Request') {
                            objCSSR.Services_Finance_Support_Status__c = 'Cancelled';
                        }
                    }
                    if(objCSSR.Services_Proposal_Support__c == 'Yes' &&  objCSSR.InquireCancel_Proposal__c != null) {
                        if(objCSSR.InquireCancel_Proposal__c == 'Submit Inquiry') {
                            objCSSR.InquireCancel_Proposal__c = null;
                        }
                        else if(objCSSR.InquireCancel_Proposal__c == 'Cancel Request') {
                            objCSSR.Services_Proposal_Support_Status__c = 'Cancelled';
                        }
                    }
                    if(objCSSR.Services_Legal_Support__c == 'Yes' && objCSSR.InquireCancel_Legal__c != null) {
                        if(objCSSR.InquireCancel_Legal__c == 'Submit Inquiry') {
                            objCSSR.InquireCancel_Legal__c = null;
                        }
                        else if(objCSSR.InquireCancel_Legal__c == 'Cancel Request') {
                            objCSSR.Services_Legal_Support_Status__c = 'Cancelled';
                        }
                    }
                    
                    lstCSSRToReset.add(objCSSR);
                }
                if(lstCSSRToReset != null && lstCSSRToReset.size() > 0) {
                    update lstCSSRToReset; 
                }
            }
        }
    }
    //methods to avoid the recursive call and multiple mails for same functionality
    
    private static boolean alreadyMailSent = false;
    private static boolean alreadyResetFields = false;
    
    public static boolean hasAlreadyMailSent() {
        return alreadyMailSent;
    }
   
    public static void setAlreadyMailSent() {
        alreadyMailSent = true;
    }
    public static boolean hasAlreadyResetFields() {
        return alreadyResetFields;
    }
   
    public static void setAlreadyResetFields() {
        alreadyResetFields = true;
    }
    
    //method to reset Boolean flag as false for test method 
    public static void resetAlreadyMailSentForTestMethod() {
        alreadyMailSent = false;
    }
    
    //10.0 - End
}//end of class