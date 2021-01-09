/**
* Name          : VFCntrlr_CreateNewOrReassignTaskAssignee
* Description   : System to default the Account/Sales team members on Task's 'Assigned To' lookup field
* -------------------------------------------------------------------------------
* Revision  Name         Date         Description
* 1.0       Josipinna    30-Jun-2011  Creation (CR6220 & 6222)
* 2.0       Sakshi                    Fixing 'continue' button issue
* -------------------------------------------------------------------------------
**/

public class VFCntrlr_CreateNewOrReassignTaskAssignee {
    
        /*Refresh Page*/
        public PageReference refresh() {
            return null;
        }

        /*Variable Declaration*/
        public string AssignOptions{get; set;}
        public string AccountOROpportunityName{get; set;}
        public String isDefaultOwner{get; set;} 
        public String SelectedAccOrSalesTeamMember{get;set;}
        public String ListOfAccountTeamMember{get;set;}
        Public String aTaskId {get; set;}
        Public String recordId {get; set;}
        public String ReassignTask {get; set;}
        public Boolean showSaveNClosebutton {get;set;}
        public String recordIdPrefix {get; set;}
        public String tasksJSON {get; set;}
        public String strURL {get; set;}

        public String sObjectType {get; set;}
        public List<sObject> ListofSalesOrAccountTeamMember {get; set;}
        public String taskId {get; set;}
        public String SelectedRecordName {get;set;}
        public String SelectedRecordId {get;set;}
        public String SelectedATMorSTMMapKeySet {get;set;}
        public PageReference URL {get;set;}
        public String OwnerId {get;set;}
        public String parentWhatId {get;set;}
      
        Private Task TaskRecord {get; set;}
        Public List<User> User {get; set;}
        
        string strAHName = ApexPages.currentPage().getParameters().get('AHName');
        string strAHId = ApexPages.currentPage().getParameters().get('AHId');

        Private List<Account> AccountRecord {get; set;}
        Private List<Opportunity> OpportunityRecord {get; set;}
        Private List<OpportunityTeamMember> SalesTeamMember {get; set;}
        Private List<AccountTeamMember> AccountTeamMember {get; set;}
        Map<String, String> SelectedAccOrSalesTeamMemberMap = new Map<String, String>();

/*****************************Radio Button Options*********************************************************/
        
        /* SelectList Menu dropdownbox*/
        public List<SelectOption> getAssignmentOptions() {
                List<SelectOption> options = new List<SelectOption>();
               
                options.add(new SelectOption('Default Owner','Default Owner'));                
               
                if(sObjectType== 'OpportunityTeamMember') {
                    options.add(new SelectOption('Sales Team Members','Sales Team Members'));
                } else if (sObjectType== 'AccountTeamMember') {
                    options.add(new SelectOption('Account Team Members','Account Team Members'));
                }
                   
                options.add(new SelectOption('Others','Others'));
        return options;
        }  
        
                  
        /* Show Radio button for Default Owner*/
        public List<SelectOption> getItemsCurrentUser() {
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption(UserInfo.getUserId(),UserInfo.getName()+'  (Current User)'));
                
        return options;
        }

        /* Show List of Radio button for Sales Team Member*/        
        public List<SelectOption> getSalesTeamMember() {
                List<SelectOption> options = new List<SelectOption>();
                for (OpportunityTeamMember OppTeam : SalesTeamMember) {
                    options.add(new SelectOption(OppTeam.User.Id,OppTeam.User.Name + ' (' + OppTeam.TeamMemberRole + ') '));
                    SelectedAccOrSalesTeamMemberMap.put(OppTeam.User.Id,OppTeam.User.Name);
                }
                system.debug('SelectedAccOrSalesTeamMemberMap' +SelectedAccOrSalesTeamMemberMap);
        return options;   
        }
        

        /* Show List of Radio button for Account Team Member*/  
        public List<SelectOption> getAccountTeamMember() {
                List<SelectOption> options = new List<SelectOption>();
                for (AccountTeamMember AccTeam : AccountTeamMember) {
                     options.add(new SelectOption(AccTeam.User.Id,AccTeam.User.Name + ' (' + AccTeam.TeamMemberRole + ') ' ));
                     SelectedAccOrSalesTeamMemberMap.put(AccTeam.User.Id,AccTeam.User.Name);
                }
        return options;   
        }

/*****************************End of Radio Button Options*********************************************************/


        /* Constructor */
        public VFCntrlr_CreateNewOrReassignTaskAssignee(ApexPages.StandardController controller){
            
            System.debug('***************** In the Class Constructor *****************');
            System.debug('#####SelectedAccOrSalesTeamMember' +SelectedAccOrSalesTeamMember);
            
            this.TaskRecord = (Task)controller.getRecord(); 
            
            /*Assigning default value*/
            this.TaskRecord.OwnerId = UserInfo.getUserId();
            isDefaultOwner = UserInfo.getUserId();
            tasksJSON = '';
           
            
            /*Getting the parameters value*/
            aTaskId = ApexPages.currentPage().getParameters().get('TaskId');
            recordId = ApexPages.currentPage().getParameters().get('what_id');
            ReassignTask = ApexPages.currentPage().getParameters().get('ReassignTask');
            

            /*getting the first 3 recordId prefix (006 - Opportunity, 001 - Account)*/
            recordIdPrefix = StringUtils.defaultString(StringUtils.substring(recordId, 0, 3));
            System.debug('recordIdPrefix.....'+recordIdPrefix);
  
            
            /*Determine if the Task is created from Account Page or Opportunity Page*/
            if(recordIdPrefix.equals(Opportunity.sObjectType.getDescribe().getKeyPrefix())){ //006

                AssignOptions = 'Sales Team Members';
                sObjectType = 'OpportunityTeamMember'; 

                System.debug('sObjectType ' +sObjectType );   
            }
            else if(recordIdPrefix.equals(Account.sObjectType.getDescribe().getKeyPrefix())){ //001  

                AssignOptions = 'Account Team Members';
                sObjectType = 'AccountTeamMember';

                System.debug('sObjectType ' +sObjectType ); 
            }     

            /* Query List of Sales Team Member or Account Team Member based on sObjectType*/
            if (sObjectType == 'OpportunityTeamMember'){

                SalesTeamMember = new List<OpportunityTeamMember>();           
                SalesTeamMember =[SELECT TeamMemberRole, user.Name, user.Id FROM OpportunityTeamMember WHERE OpportunityId =: recordId];

                if (SalesTeamMember.size() > 0)
                SelectedAccOrSalesTeamMember = SalesTeamMember[0].user.Id;
            }  
            else if (sObjectType == 'AccountTeamMember'){
                
                AccountTeamMember = new List<AccountTeamMember>(); 
                AccountTeamMember =[SELECT TeamMemberRole, user.Name, user.Id FROM AccountTeamMember WHERE AccountId =: recordId];
                
                if (AccountTeamMember.size() > 0)
                SelectedAccOrSalesTeamMember = AccountTeamMember[0].user.Id;
            }
                        
            /*rendered Save & Close Button*/
            If (ReassignTask == 'True') {         
                showSaveNClosebutton = True;
            }
            else if (ReassignTask == 'False'){
                showSaveNClosebutton = False;
            }
            
            
            /*get Account or Opportunity name*/
            if (sObjectType == 'AccountTeamMember'){
                AccountRecord = [SELECT Id, Name FROM Account WHERE Id =:recordId];
                AccountOROpportunityName = AccountRecord[0].Name;
            }
            else if (sObjectType == 'OpportunityTeamMember'){
                OpportunityRecord = [SELECT Id, Name FROM Opportunity WHERE Id =:recordId];
                AccountOROpportunityName = OpportunityRecord[0].Name;
            }
    }//End of Constructor 
       
    public void setReturnURL()
    {
        
            taskId = aTaskId;  
            
            /*Getting the 'Assigned To' field's value*/
            if (AssignOptions == 'Default Owner') {
                
                System.debug('AssignOptions' +AssignOptions );  
                SelectedRecordName = UserInfo.getName();
                SelectedRecordId = UserInfo.getUserId();
            }
            else if (AssignOptions == 'Account Team Members' || AssignOptions == 'Sales Team Members') {
               
                System.debug('AssignOptions' +AssignOptions );  
                Set<String> SelectedATMorSTMMapKeySet = new Set<String>();
                SelectedATMorSTMMapKeySet = SelectedAccOrSalesTeamMemberMap.keySet();

                for (string SelectedATMorSTM: SelectedATMorSTMMapKeySet)
                {
                        SelectedRecordId = SelectedAccOrSalesTeamMember;
                        SelectedRecordName = SelectedAccOrSalesTeamMemberMap.get(SelectedAccOrSalesTeamMember);
       
                }  
                
                System.debug('###SelectedRecordId ' +SelectedRecordId );  
                System.debug('###SelectedRecordName ' +SelectedRecordName );               
            }
            
            if (AssignOptions == 'Others') {
            
                System.debug('AssignOptions' +AssignOptions );  
                OwnerId = this.TaskRecord.OwnerId;
                
                User = new List<User>(); 
                User = [SELECT LastName, FirstName FROM User WHERE Id=: OwnerId];
                
                SelectedRecordName = User[0].FirstName +' '+ User[0].LastName ;
                SelectedRecordId = OwnerId;
            }            
 
    }//End of setReturnURL()


     public void doContinue()
     {
       parentWhatId = apexpages.currentpage().getparameters().get('what_id');
        System.debug('##Inside doContinue1'); 
        setReturnURL();
        System.debug('##Inside doContinue2');
              
            if (ReassignTask == 'True')
            {
                System.debug('##Inside doContinue3');
                //URL = new PageReference('/' + aTaskId +'/e?RecordType=012300000004ze9&ent=Task&tsk1='+SelectedRecordName+'&tsk1_lkid='+ SelectedRecordId + '&retURL='+ recordId);
            
                Map<String, Schema.SObjectField> mapFieldName = Schema.SObjectType.Task.fields.getMap();
                
                String strQuery = 'SELECT ';
                
                for(String strField : mapFieldName.keyset()){
                    
                    if(strField != 'isvisibleinselfservice' && mapFieldName.get(strField).getDescribe().isUpdateable())
                        strQuery += strField +',';
                }
                
                strQuery = strQuery.removeEnd(',');
                strQuery = strQuery+' From Task Where Id= \''+aTaskId+'\'';
                
                Task objTask = Database.query(strQuery);
                
                objTask.OwnerId = SelectedRecordId;
                
                Map<String,Object> taskMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objTask));

                for(String key : taskMap.keySet()) {
                    if(key == 'attributes') {
                        taskMap.remove(key);
                    }
                }  
                tasksJSON = JSON.serializePretty(taskMap);
                
            }
            else {
                System.debug('##Inside doContinue4');
                String strName = (SelectedRecordName == null)? '':SelectedRecordName;
                String strId = (SelectedRecordId == null)? '': SelectedRecordId;
                if (sObjectType == 'OpportunityTeamMember')
                {
                    System.debug('##Inside doContinue5');
                     System.debug('##Inside if sObjectType == OpportunityTeamMember' );  
                     String OpportunityStr = '/00T/e?' +'RecordType=012300000004ze9&ent=Task&tsk1='+strName+'&tsk3='+ EncodingUtil.URLEncode(AccountOROpportunityName,'UTF-8')+'&tsk3_lkid='+recordId+'&tsk3_mlktp=006&tsk1_lkid='+ strId + '&retURL='+ recordId;
                     System.debug('##OpportunityStr : ' + OpportunityStr ); 
                     strURL =  OpportunityStr;
                     URL = new PageReference(OpportunityStr);
                     System.debug('##URL : ' +URL);
                
                }
                else if (strAHId != null)
                {
                    System.debug('##Inside doContinue6');
                     System.debug('##Inside if sObjectType == AccountTeamMember' );
                     
                     String AccountStr = '/00T/e?' +'RecordType=012300000004ze9&ent=Task&tsk1='+strName+'&tsk3='+ strAHName +'&tsk3_lkid='+ strAHId +'&tsk3_mlktp=a0d&tsk1_lkid='+ strId + '&retURL='+ strAHId;
                     System.debug('##AccountStr : ' + AccountStr ); 
                     strURL = AccountStr;
                     URL = new PageReference(AccountStr);
                     System.debug('##URL : ' +URL);   
                }
                else if (sObjectType == 'AccountTeamMember')
                {
                     System.debug('##Inside doContinue7');
                     System.debug('##Inside if sObjectType == AccountTeamMember' );
                     
                     String AccountStr = '/00T/e?' +'RecordType=012300000004ze9&ent=Task&tsk1='+strName+'&tsk3='+ EncodingUtil.URLEncode(AccountOROpportunityName,'UTF-8')+'&tsk3_lkid='+recordId+'&tsk3_mlktp=001&tsk1_lkid='+ strId + '&retURL='+ recordId;
                     System.debug('##AccountStr : ' + AccountStr ); 
                     strURL = AccountStr;
                     URL = new PageReference(AccountStr);
                     System.debug('##URL : ' +URL);   
                }
            }    
      // return URL;    
     }//End of doContinue()     


     public PageReference doSaveClose() 
    {  
        setReturnURL();
        
        if (SelectedRecordId != null && SelectedRecordName != null) {
                    
            Task updTask = new Task(Id = taskId);
                      
            updTask.OwnerId = SelectedRecordId;
                      
            update updTask ;                
        }
        return new PageReference('/'+aTaskId);   
    }//End of doSaveClose()


    public PageReference doCancel(){
        
        if (ReassignTask == 'True')
        {      
            URL = new PageReference('/'+aTaskId);
        }
        else if (ReassignTask == 'False')
        {
            URL = new PageReference('/'+RecordId);        
        }
        
        return URL;
    }//End of doCancel()

}//End of Class VFCntrlr_CreateNewOrReassignTaskAssignee