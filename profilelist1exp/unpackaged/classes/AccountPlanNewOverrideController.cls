/***********************************************************
* Name          : CallPlanOverridePageController
* Description   : Controller Class for CallPlanEditOverride And CallPlanViewOverride Page
* ---------------------------------------------------------
* Revision      Release     Name            Date            Description
* 1.0           12.10                                       Created          
* 2.0           13.1        Raymond Yip     10-Nov-2011     Default Account Owner with Account Executive
* 3.0           15.07       Emily           09-Jul-2014     Defect 111228
* 4.0           16.07       Emily           27-Apr-2015     CR 11418
* 5.0           16.10       Shahiruni       17-Sept-2015    CR 11956 (PDM, CAM)
* 6.0           FY19-0203   Harsha          29-Dec-2017     CR 15354 (plan owner lite), removed testMethod
* 7.0           FY19-0602   Meera           20-April-2018   CR 15665 Fixing issue in lightning And SF1
* 8.0           FY19-0703   Harsha          25-May-2018     CR 15885 
* 9.0           FY19-0102   Harsha          12-Nov-2018     CR 16801 AutoPopulate SC And TSR
* 9.1           FY20-0204   Harsha          18-Feb-2019     CR 17136 Fixing issue for special characters in Username
* 10.0          FY20-1002   Kenny/Sazleen   29-Aug-2019     CR 18031 AutoPopulate DCSS And ASE
************************************************************/
Public With Sharing Class AccountPlanNewOverrideController {
    
    Account targetAccount;
    Public String teamMemberJSON{Get;Set;}
    Public String managerJSON{Get;Set;}
    Public Map<String, AccountTeamMember> teamMemberMap;
    Public Map<String, User> userMap;
    Public id currentUserId;
    
    Public AccountPlanNewOverrideController(ApexPages.StandardController controller) {

        Account temp = (Account)controller.getRecord();
        
        If (temp.Id!= null) {        
            targetAccount = [SELECT Name, Description, Id, Fiscal_Year_End__c FROM Account WHERE ID = :temp.Id];
            populateAccountTeamMembers();
        } else {
            ApexPages.Message msg = New ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid/Missing Account Id');
            ApexPages.addMessage(msg );
        }
        //if targetAccount null
    }


        
    Public Boolean getHasMessage() {
        Return ApexPages.hasMessages();
    }
    
    Public PageReference constructNewAPURL(Account acc, Map<String, AccountTeamMember> teamMemberMap) {
        String base_url; 
        String save_new_url;
        
        Map<string,string> params = New Map<string,string>();
        //Construct baseURL to Record Type Selection page
        base_url= '/setup/ui/recordtypeselect.jsp?ent=01I7000000033VF';
        base_url+= '&retURL=/' + targetAccount.Id;
        
        
        //Construct URL to be redirected after selecting RT
        save_new_url = '&save_new_url=/a0D/e?';
        params.put('CF00N70000002Meyf',(targetAccount.Name));
        system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          ' + save_new_url);
        save_new_url += '&CF00N70000002Meyf_lkid=' + targetAccount.Id;
        
        //v3.0 Defect 111228
        If (targetAccount.Description != null && !StringUtils.isBlank(targetAccount.Description))
            params.put('00NA0000008qkri',(StringUtils.defaultString(targetAccount.Description)));
        
        If (teamMemberMap.get('AE') != null) {
            params.put('CF00NA0000008qkrZ',(teamMemberMap.get('AE').User.Name));
            save_new_url += '&CF00NA0000008qkrZ_lkid='+teamMemberMap.get('AE').UserId;
            
            params.put('CF00NA00000063VIw',(teamMemberMap.get('AE').User.Name));
            save_new_url += '&CF00NA00000063VIw_lkid='+teamMemberMap.get('AE').UserId;
            
            //v4.0
            List<User> AEManagerList = [SELECT Manager__c, ManagerId, Manager.Name
                                        FROM User
                                        WHERE Id = : teamMemberMap.get('AE').UserId];
            
            If (AEManagerList!= null){
                system.debug('###DEBUG### AEManagerList - ' + AEManagerList );     
                If (AEManagerList.size() > 0) {
                    params.put('CF00NA0000008qkrw',(AEManagerList[0].Manager.Name));
                    save_new_url += '&CF00NA0000008qkrw_lkid='+AEManagerList[0].ManagerId;
                }
            }
        }
        
        If (teamMemberMap.get('ISR') != null) {
           params.put('CF00NA0000008qkrp',(teamMemberMap.get('ISR').User.Name));
            save_new_url += '&CF00NA0000008qkrp_lkid='+teamMemberMap.get('ISR').UserId;
        } 
        
        //v9.0 Start
        Map<String, Account_Plan_Fields__c> accPlanFields = Account_Plan_Fields__c.getAll();

        If (teamMemberMap.get('SC') != null) {
            String scFieldId = accPlanFields.get('System_Consultant__c').Field_Id__c;
           params.put('CF'+scFieldId,(teamMemberMap.get('SC').User.Name));
            save_new_url += '&CF'+scFieldId+'_lkid='+teamMemberMap.get('SC').UserId;
        } 
        If (teamMemberMap.get('TSR') != null) {
            String tsrFieldId = accPlanFields.get('Technical_Sales_Rep__c').Field_Id__c;
           params.put('CF'+tsrFieldId,(teamMemberMap.get('TSR').User.Name));
            save_new_url += '&CF'+tsrFieldId+'_lkid='+teamMemberMap.get('TSR').UserId;
        } 
        //v9.0 end
		
		//v10.0 start
        If (teamMemberMap.get('DCSS') != null) {
            String strdcssFieldId = accPlanFields.get('Data_Center_Sales_Executive__c').Field_Id__c;
           params.put('CF'+strdcssFieldId,(teamMemberMap.get('DCSS').User.Name));
            save_new_url += '&CF'+strdcssFieldId+'_lkid='+teamMemberMap.get('DCSS').UserId;
        } 
        If (teamMemberMap.get('ASE') != null) {
            String straseFieldId = accPlanFields.get('Account_Systems_Engineer__c').Field_Id__c;
           params.put('CF'+straseFieldId,(teamMemberMap.get('ASE').User.Name));
            save_new_url += '&CF'+straseFieldId+'_lkid='+teamMemberMap.get('ASE').UserId;
        } 
        //v10.0 end
        
        
        //5.0 start
        If (teamMemberMap.get('PDM') != null) {
            // params.put('CF00NZ0000001jdxa',(teamMemberMap.get('PDM').User.Name));
            // save_new_url += '&CF00NZ0000001jdxa_lkid='+teamMemberMap.get('PDM').UserId;
            params.put('CF00NA000000Asyd2',(teamMemberMap.get('PDM').User.Name));
            save_new_url += '&CF00NA000000Asyd2_lkid='+teamMemberMap.get('PDM').UserId;
            
            //Put RSD/RSM value from PDM's manager
            List<User> RSDRSMManagerList = [SELECT Manager__c, ManagerId, Manager.Name
                                        FROM User WHERE Id = :teamMemberMap.get('PDM').UserId];
            
            If (RSDRSMManagerList!= null){
                system.debug('###DEBUG### RSDRSMManagerList - ' + RSDRSMManagerList );     
                If (RSDRSMManagerList.size() > 0) {
                    //params.put('CF00NZ0000001jfzd',(RSDRSMManagerList[0].Manager.Name));
                    //save_new_url += '&CF00NZ0000001jfzd_lkid='+RSDRSMManagerList[0].ManagerId;
                    params.put('CF00NA000000AsydC',(RSDRSMManagerList[0].Manager.Name));
                    save_new_url += '&CF00NA000000AsydC_lkid='+RSDRSMManagerList[0].ManagerId;
                }
            }
        }
        
        If (teamMemberMap.get('CAM') != null) {
            // params.put('CF00NZ0000001jdzM',(teamMemberMap.get('CAM').User.Name));
            // save_new_url += '&CF00NZ0000001jdzM_lkid='+teamMemberMap.get('CAM').UserId;
            params.put('CF00NA000000Asyd7',(teamMemberMap.get('CAM').User.Name));
            save_new_url += '&CF00NA000000Asyd7_lkid='+teamMemberMap.get('CAM').UserId;
        }
        //5.0 ends
        
        /* v4.0
        If (teamMemberMap.get('RSM') != null) {
             params.put('CF00NA0000008qkrw',(teamMemberMap.get('RSM').User.Name));
            save_new_url += '&CF00NA0000008qkrw_lkid='+teamMemberMap.get('RSM').UserId;
        }
        */ 
        
        //v6.0 start
        If (currentUserId!= null){
            //Account_Plan_Fields__c apfo = Account_Plan_Fields__c.getvalues('Account_Plan_Lite_Owner__c');
            String accountPlanLiteOwnerFieldId = accPlanFields.get('Account_Plan_Lite_Owner__c').Field_Id__c;
            params.put('CF'+accountPlanLiteOwnerFieldId,(UserInfo.getname()));
            save_new_url += '&CF'+accountPlanLiteOwnerFieldId+'_lkid='+currentUserId;
        }
        //v6.0 end
        
        //v8.0 starts
        If (userMap.get('APLM') != null) {
            // Account_Plan_Fields__c apfm = Account_Plan_Fields__c.getvalues('AP_Lite_Manager__c');
            String apLiteManagerFieldId = accPlanFields.get('AP_Lite_Manager__c').Field_Id__c;
            params.put('CF'+apLiteManagerFieldId,(userMap.get('APLM').manager.Name));
            save_new_url += '&CF'+apLiteManagerFieldId+'_lkid='+userMap.get('APLM').managerId;
        }
        //v8.0 ends
        system.debug('###DEBUG### URL = ' + base_url + save_new_url);
        PageReference pr = New PageReference(base_url + save_new_url);        
        // To avoid double encoding
        For (String key :  params.KeySet()){
            pr.getParameters().put(key, params.get(key));
        }
        system.debug('###DEBUG### URL save_new_url = '  +  pr.getUrl());
        
        Return pr;
             
    }
        
    Public PageReference createNewAccountPlan(){
        
        
        If (targetAccount == null) {
            ApexPages.Message msg = New ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid/Missing Account Id');
            ApexPages.addMessage(msg );
            Return null;
        }
        
        
        Return constructNewAPURL(targetAccount, teamMemberMap);     
    }
    
    Public void populateAccountTeamMembers(){
        Map<String,String> managerMap = New Map<String,String>();
        managerMap.put('AEM',null);
        managerMap.put('PDMM',null);
        managerMap.put('APLM',null); //v8.0
        teamMemberMap = New Map<String, AccountTeamMember>();  
        userMap = New Map<String, User>(); 
        teamMemberMap.put('RSM',null); 
        teamMemberMap.put('ISR',null);  
        teamMemberMap.put('AE',null);  
        //5.0
        teamMemberMap.put('PDM',null);
        teamMemberMap.put('CAM',null);
        //v9.0
        teamMemberMap.put('SC',null);
        teamMemberMap.put('TSR',null);
		//v10.0
        teamMemberMap.put('DCSS',null);
        teamMemberMap.put('ASE',null);
        
        //Retrieve RSM
        List <AccountTeamMember> RSMTeamMemberList = [SELECT UserId, User.Name, TeamMemberRole, LastModifiedDate From AccountTeamMember             
                                                        WHERE AccountId = : targetAccount.Id 
                                                        And TeamMemberRole = 'Regional Sales Manager'
                                                        ORDER BY LastModifiedDate DESC];
                                                        
        
        
        If (RSMTeamMemberList!= null) {
            system.debug('###DEBUG### RSMTeamMemberList - ' + RSMTeamMemberList);
            If (RSMTeamMemberList.size() > 0) {
                teamMemberMap.put('RSM',RSMTeamMemberList[0]); 
            }
        }
        //Retrieve ISR                                                    
        List <AccountTeamMember> ISRTeamMemberList = [SELECT UserId, User.Name, TeamMemberRole, LastModifiedDate From AccountTeamMember             
                                                            WHERE AccountId = : targetAccount.Id 
                                                            And TeamMemberRole = 'Inside Sales Rep'
                                                            ORDER BY LastModifiedDate DESC];
        
        If (ISRTeamMemberList!= null) {                                                    
            system.debug('###DEBUG### ISRTeamMemberList - ' + ISRTeamMemberList );      
            If (ISRTeamMemberList.size() > 0) {
                teamMemberMap.put('ISR',ISRTeamMemberList [0]); 
            }
        }
        //Retrieve AE
        List <AccountTeamMember> AETeamMemberList = [SELECT UserId, User.Name,User.ManagerId,  TeamMemberRole, LastModifiedDate From AccountTeamMember             
                                                            WHERE AccountId = : targetAccount.Id 
                                                            And TeamMemberRole = 'Account Executive'
                                                            ORDER BY LastModifiedDate DESC];
        
        If (AETeamMemberList!= null) {                                                         
            system.debug('###DEBUG### AETeamMemberList - ' + AETeamMemberList );     
            If (AETeamMemberList.size() > 0) {
                teamMemberMap.put('AE',AETeamMemberList [0]); 
                If (AETeamMemberList [0].User.ManagerId !=null){
                    managerMap.put('AEM',AETeamMemberList[0].User.ManagerId);
                }
            }
        }
        //constructNewAPURL(targetAccount, teamMemberMap);
        
        //5.0 starts
        //Retrieve PDM
        List <AccountTeamMember> PDMTeamMemberList = [SELECT UserId, User.Name,User.ManagerId, TeamMemberRole, LastModifiedDate From AccountTeamMember             
                                                            WHERE AccountId = : targetAccount.Id 
                                                            And TeamMemberRole = 'Partner Development Manager'
                                                            ORDER BY LastModifiedDate DESC];
        
        If (PDMTeamMemberList!= null) {                                                    
            If (PDMTeamMemberList.size() > 0) {
                teamMemberMap.put('PDM',PDMTeamMemberList [0]); 
                If (PDMTeamMemberList [0].User.ManagerId !=null){
                    managerMap.put('PDMM',PDMTeamMemberList[0].User.ManagerId);
                }
            }
        }
        
        //Retrieve CAM
        List <AccountTeamMember> CAMTeamMemberList = [SELECT UserId, User.Name, TeamMemberRole, LastModifiedDate From AccountTeamMember             
                                                            WHERE AccountId = : targetAccount.Id 
                                                            And TeamMemberRole = 'Inside Channel Account Manager'
                                                            ORDER BY LastModifiedDate DESC];
        
        If (CAMTeamMemberList!= null) {                                                    
            If (CAMTeamMemberList.size() > 0) {
                teamMemberMap.put('CAM',CAMTeamMemberList [0]); 
            }
        }
        //5.0 Ends
       
        //v9.0 start
        //Retrieve SC
        List <AccountTeamMember> SCTeamMemberList = [SELECT UserId, User.Name, TeamMemberRole, LastModifiedDate From AccountTeamMember             
                                                            WHERE AccountId = : targetAccount.Id 
                                                            And TeamMemberRole = 'System Consultant'
                                                            ORDER BY LastModifiedDate DESC];
        
        If (SCTeamMemberList!= null) {                                                    
            If (SCTeamMemberList.size() > 0) {
                teamMemberMap.put('SC',SCTeamMemberList [0]); 
            }
        }
        
        //Retrieve TSR
        List <AccountTeamMember> TSRTeamMemberList = [SELECT UserId, User.Name, TeamMemberRole, LastModifiedDate From AccountTeamMember             
                                                            WHERE AccountId = : targetAccount.Id 
                                                            And TeamMemberRole = 'Technical Sales Rep'
                                                            ORDER BY LastModifiedDate DESC];
        
        If (TSRTeamMemberList!= null) {                                                    
            If (TSRTeamMemberList.size() > 0) {
                teamMemberMap.put('TSR',TSRTeamMemberList [0]); 
            }
        }
        //v9.0 end
		
		//v10.0 Start
		//Retrieve DCSS
        List <AccountTeamMember> listDCSSTeamMember = [SELECT UserId, User.Name, TeamMemberRole, LastModifiedDate From AccountTeamMember             
                                                            WHERE AccountId =:   targetAccount.Id 
                                                            And TeamMemberRole = 'DC Sales Specialist'
                                                            ORDER BY LastModifiedDate DESC];
        
        If (listDCSSTeamMember!= null) {                                                    
            If (listDCSSTeamMember.size() > 0) {
                teamMemberMap.put('DCSS',listDCSSTeamMember[0]); 
            }
        }

		//Retrieve ASE
        List <AccountTeamMember> listASETeamMemberList = [SELECT UserId, User.Name, TeamMemberRole, LastModifiedDate From AccountTeamMember             
                                                            WHERE AccountId =:   targetAccount.Id 
                                                            And TeamMemberRole = 'Account System Engineer'
                                                            ORDER BY LastModifiedDate DESC];
        
        If (listASETeamMemberList!= null) {                                                    
            If (listASETeamMemberList.size() > 0) {
                teamMemberMap.put('ASE',listASETeamMemberList[0]); 
            }
        }

		//v10.0 End            
                
        //v8.0 starts
        // Retrieve AP Lite Manager
        currentUserId = UserInfo.getUserId();
        List<user> APLiteManagerList = [select id, name, managerid, manager.name from user where id =:currentUserId];
        userMap.put('APLM', APLiteManagerList[0]);
        
        If (APLiteManagerList[0].ManagerId !=null){
            managerMap.put('APLM',APLiteManagerList[0].ManagerId);
        }
        //v8.0 ends
        //v9.1 start
        // teamMemberJSON = JSON.serialize(teamMemberMap);
        teamMemberJSON = string.escapeSingleQuotes(JSON.serialize(teamMemberMap)); //v9.1 end
        managerJSON = JSON.serialize(managerMap);
        system.debug('managerJSON:'+managerJSON);
    }
        
    Public PageReference redirectBack() {
        If (targetAccount!= null) {
            Return PageUtils.redirect('/' + targetAccount .Id);    
        } else {
            Return PageUtils.redirect('/a0D');
        }
            
    }


}