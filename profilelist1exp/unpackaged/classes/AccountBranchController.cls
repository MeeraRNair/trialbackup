/*-------------------------------------------------------------------------
Name            : AccountBranchController
Description     : Class  for creating Account Branch and its LOB records
* Revision  Name            Date            Description
----------------------------------------------------------------------------
* 1.0       Manju                           CR #2573
* 2.0       Azwanti         31.10.2011      REL13.1 CR5786
* 3.0       mayank          10.08.2013      REL14.10 CR 8031
* 4.0       Kokila          24.10.2013      CR 8031-Defect 84222 List of LOBs should be displayed with LOBs grouped  
--------------------------------------------------------------------------*/
public class AccountBranchController {
        //Global Variables
        public List<LOB_Administration__c> listLOBRegStatus=new List<LOB_Administration__c>();
        public List<LOB_Administration__c> LOBList {get; set;} 
        public Map<String,LOB_Administration__c> lstLOBRegMap=new Map<String,LOB_Administration__c>();
        public Map<String,String> lstStatusMap=new Map<String,String>();
        Public String strStatus;  
        Public String strIndexVal{get;set;}
        public String valueOne { get; set; }
        public String valueTwo { get; set; }
        public String endUserAccountId;
        public Account_Branch__c accBranchObj {get; set;}
        public Account accountObj;
        public String strAccBrnchNm{get;set;}
        public boolean showPage {get; set;}
        public boolean showLOBReg{get;set;}
        
        public List<lobWrapper> lobListWrap {get;set;}
        public List<LOB_Administration__c > selectedLOB{get; set;}
        
        public List<Account_Branch__c> lstAccBr;
        
        //Constructor being called 
        public AccountBranchController(ApexPages.StandardController controller) 
        {
            String createAccountBranch = System.Label.CR_2573_Create_Account_Branch;
            String ownerPrivToCreateAccBr = System.Label.CR_2573_Owner_Privilege_To_Create_AccBr;
            accountObj = (Account)controller.getRecord();
            endUserAccountId = accountObj.Id;
            User user = [SELECT Id, Title FROM User WHERE Id =: UserInfo.getUserId()];
            String title = user.Title;
            if(accountObj.OwnerId == Userinfo.getUserId() || title == 'GCC Program Manager'){
                    if(accountObj.Participating_in_LOB_Program__c == true){
                    showPage = true;
                    }else{
                        showPage = false;
                        PageUtils.addError(createAccountBranch);
                        return;
                    }
            }else{
                    showPage = false;
                PageUtils.addError(ownerPrivToCreateAccBr);
                return;
            }
            if(accBranchObj == null){
                
                accBranchObj = new Account_Branch__c();
            }
            
            fetchingLOB();
        }
        

        public PageReference test() 
        {
           valueOne = Apexpages.currentPage().getParameters().get('one');
           valueTwo = Apexpages.currentPage().getParameters().get('two');
           System.Debug('valueOne '+valueOne);
           System.Debug('valueTwo '+valueTwo);
           lstStatusMap.put(valueOne,valueTwo);
           System.Debug('lstStatusMap'+lstStatusMap);
           return null;
        }
        
        //Method to get LOB Reg Values 
        Public List<LOB_Administration__c> getLOBRegStatus()
        {
           listLOBRegStatus=lstLOBRegMap.values();
           if(listLOBRegStatus.size()>0){
             showLOBReg=true; 
           }
           else{
             showLOBReg=false; 
           }
           return listLOBRegStatus;
        }
        
       
        //------------------------------------------------------------------------ UPDATING ------------------------------------------------
        // Retreiving all Active LOBs from the LOB Admin object and bind it to the wrapper class  REL14.10 CR 8031
        public void fetchingLOB()
        {
            lobListWrap = new list<lobWrapper>();
            for(LOB_Administration__c lob : [Select Id,Name from LOB_Administration__c where Active__c = true ORDER BY Name]){
            lobListWrap.add(new lobWrapper(lob));
            }
        }
       
        
        
      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
        //Method to populate LOB Values
        public PageReference getActiveLOBRegStatusValues()
        {
            try
            {
                System.Debug('listLOBRegStatus.size()'+listLOBRegStatus.size());
                if(listLOBRegStatus.size()==0){
                    for(LOB_Administration__c lobAdm:[Select Id,Name from LOB_Administration__c where Active__c = true]){
                         lstLOBRegMap.put(lobAdm.Name,lobAdm);
                    }
                }
                listLOBRegStatus=lstLOBRegMap.values();
                System.Debug('listLOBRegStatus'+listLOBRegStatus);
                if(listLOBRegStatus.size()>0){
                 showLOBReg=true; 
                }
                else{
                 showLOBReg=false; 
                }
            
            }
            catch(Exception excptn){
                PageUtils.addError(excptn.getMessage());
            }
            return null;
        }
        //method to create new account branch as well the inserted selected  LOB's list in the LOB object 
        public pagereference createAccountBranch(){
        
            list<LOB_Registration__c> lstToCreateLobReg = new list<LOB_Registration__c>();
            if(strAccBrnchNm!=null && !(strAccBrnchNm.equals('')))
            {
            accBranchObj = new Account_Branch__c();
            lstAccBr = new List<Account_Branch__c>();
            if(endUserAccountId!=null)
            accBranchObj.Account__c = endUserAccountId;
            accBranchObj.Name=strAccBrnchNm;
            lstAccBr.add(accBranchObj);
            try{
                insert lstAccBr;
            }catch(Exception e){
                return null;
            }
                
           
                for(lobWrapper wrp : lobListWrap )
                {
                        if(wrp.Selected== true)
                        {
                            LOB_Registration__c  newLob = new LOB_Registration__c ();
                            newLob.LOB_Name__c = wrp.lobadmin.Name;
                               //if(lstStatusMap.get(wrp.lobadmin.Name)!=null){
                                    newLob.LOB_registration_status__c=lstStatusMap.get(wrp.lobadmin.Name);
                                    newLob.LOB_registration_status__c=wrp.selectedLobVal;
                                 //}
                                 //else{
                                    //newLob.LOB_registration_status__c='Open';
                                 //}
                           newLob.Registered_End_User__c  = accountObj.Id;
                           newLob.Location__c = lstAccBr[0].Id;
                           
                          lstToCreateLobReg.add(newLob);
                        }   
                    
                }
                insert lstToCreateLobReg; 
                return PageUtils.redirect('/' + accountObj.Id);       
            }
            else
            {
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Account Branch Name');
              ApexPages.addMessage(msg);
              return null;
            } 
        } 
        
        
        //Method to populate the LOB Status Values    
        public List<SelectOption> getItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Open','Open'));
            options.add(new SelectOption('Closed','Closed'));
            return options;
        }
            
        public String getStrStatus() {
            return strStatus;
        }
            
        public void setStrStatus(String strStatus) {
            this.strStatus= strStatus;
        }
        
                
         //wraper class for new lobs
        public class lobWrapper
        {
            public LOB_Administration__c lobadmin {get; set;}
            public Boolean selected {get; set;}
            public string selectedLobVal {get; set;}
            public lobWrapper(LOB_Administration__c lob)
            {
                lobadmin = lob;
                selected = false;
            }  
        }
    
}//End of Class