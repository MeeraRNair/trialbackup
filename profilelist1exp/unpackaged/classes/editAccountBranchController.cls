/*
 * Author : 
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR            R16.07    23-Jun-2015     Devika          Update the logic in the class to include multi LOB functionality
 *
 */
public class editAccountBranchController{
    
    public Id accBranchId{get;set;}
    private ApexPages.StandardController con;
    public Account_Branch__c objAccBranch {get;set;}
    public List<lobWrapper> lobList {get;set;}
    public List<existingLobsWrapper> existinglobList{get;set;}
    //public List<LOB_Administration__c > selectedLOB{get; set;}
    public map<id,opportunity> mapLobIdAndOptyObject{get; set;}
    Public String strStatus;
    Public String statusExitingLob;
    set<string> setOfLobRegName = new set<string>(); 
    public Map<String,String> lstStatusMap=new Map<String,String>();
    public String valueOne { get; set; }
    public String valueTwo { get; set; } 
    //public Boolean Bool {get;set;}
    
    public Map<String,String> mapLobAndStatus = new Map<String,String>();
    public String valueFirst{ get; set; }
    public String valueSecond { get; set; }
    
    
    public List<selectOption> existingLobCustomList{get;set;}
    
    public editAccountBranchController(ApexPages.StandardController controller)
    {
        con = controller;
        mapLobIdAndOptyObject = new map<id,opportunity>();
        existingLobsWrapper wrap = new existingLobsWrapper();
        accBranchId = Apexpages.currentPage().getParameters().get('id');
        objAccBranch = (Account_Branch__c)con.getRecord();
        //Bool = true;
        //newLOBs();
        
        //list<opportunity> lstOfClosedWonDeal = [ select id,LOB_Registration_ID__c from opportunity where stageName !='Lost, Cancelled - 0%' and LOB_Registration_ID__c !=Null];
        string accountId = objAccBranch.Account__c; 
        string acctBranchName = objAccBranch.Name;
        list<opportunity> lstOfClosedWonDeal = [select id from opportunity where (stageName !='Lost, Cancelled - 0%'  
                                                 and End_User_Account_Department__c =:acctBranchName)];
        
        if(lstOfClosedWonDeal!=Null && lstOfClosedWonDeal.Size()>0)
        {
            for(opportunity opty : lstOfClosedWonDeal)
            {    
                /****** v1.0 Starts *********/
                //mapLobIdAndOptyObject.put(opty.LOB_Registration_ID__c,opty);
              /*  if(!opty.LOB_Registration_ID__c.contains(';')){
                    mapLobIdAndOptyObject.put(opty.LOB_Registration_ID__c,opty);
                }else{
                    List<String> opptylobList = opty.LOB_Registration_ID__c.split(';');                    
                    for(String lobId :opptylobList){
                        mapLobIdAndOptyObject.put(lobId,opty);                      
                    }
                }*/
                /****** v1.0 Ends *********/
                
            }
        }
        system.debug('map VALUE....'+mapLobIdAndOptyObject);
        processLobList();
    }
    
    
    //building existing and new LOB's list from there respective wrapper class
    public void processLobList()
    {
        lobList = new List<lobWrapper>(); 
        existinglobList = new List<existingLobsWrapper>();
        string accountId = objAccBranch.Account__c; 
        existingLobCustomList = new List<selectOption>();
       
        //existing lobs
        for(LOB_Registration__c lobR : [select id,Registered_End_User__c,LOB_Name__c,LOB_registration_status__c, Name,Preferred_GTM_Partner_Account__c 
                                        from LOB_Registration__c where Registered_End_User__c =:accountId and Location__c =:objAccBranch.Id ORDER BY LOB_Name__c]) 
        {
            
            
            existingLobsWrapper wrap= new existingLobsWrapper();
            wrap.hideCheck = true;
 
            if(mapLobIdAndOptyObject.get(lobR.Id)!=Null && lobR.Preferred_GTM_Partner_Account__c != Null)
            {
                wrap.hideCheck = false;
            }
            else
            {
                wrap.hideCheck = true;
            }
           
            wrap.lobReg =  lobR;
            wrap.Selected = true;
            wrap.leftSelectOptionList  = new list<SelectOption>(); 
          
           
            if(lobR.LOB_registration_status__c == 'Partner(approved)')
            {
                 wrap.leftSelectOptionList.add(new SelectOption('Partner(approved)','Partner(approved)'));
                 if(wrap.hideCheck == true)
                 {
                     wrap.leftSelectOptionList.add(new SelectOption('Open','Open'));
                      // wrap.leftSelectOptionList.add(new SelectOption('Closed','Closed'));
                 }
                 
                 
            }
            if(lobR.LOB_registration_status__c == 'Partner(submit for approval)')
            {
                 wrap.leftSelectOptionList.add(new SelectOption('Partner(submit for approval)','Partner(submit for approval)'));
            }
            if(lobR.LOB_registration_status__c == 'Dell(approved)')
            {
                wrap.leftSelectOptionList.add(new SelectOption('Dell(approved)','Dell(approved)'));
            }
           
            if(lobR.LOB_registration_status__c == 'Pre-Qualified')
            {
                wrap.leftSelectOptionList.add(new SelectOption('Pre-Qualified','Pre-Qualified'));
            }
           
           if(lobR.LOB_registration_status__c == 'Inactive')
           {
                wrap.leftSelectOptionList.add(new SelectOption('Inactive','Inactive'));
           }
           if(lobR.LOB_registration_status__c == 'Open' || lobR.LOB_registration_status__c == 'Closed')
           {
               wrap.leftSelectOptionList.add(new SelectOption('Open','Open'));
               wrap.leftSelectOptionList.add(new SelectOption('Closed','Closed'));
           }
          
           wrap.selectedValLob = lobR.LOB_registration_status__c;
           existinglobList.add(wrap);  
           setOfLobRegName.add(lobR.LOB_Name__c);    
          }
        
          //new lobs
          for(LOB_Administration__c lob : [Select Id,Name from LOB_Administration__c where Active__c = true and name NOT IN :setOfLobRegName ORDER BY Name]){
          lobList.add(new lobWrapper(lob));
        }      
    
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
    public PageReference valueGet() 
    {
       valueFirst = Apexpages.currentPage().getParameters().get('first');
       valueSecond = Apexpages.currentPage().getParameters().get('second');
       System.Debug('valueFirst ...'+valueFirst );
       System.Debug('valueSecond ...'+valueSecond );
       mapLobAndStatus.put(valueFirst,valueSecond);
       System.Debug('mapLobAndStatus...'+mapLobAndStatus);
       return null;
    }
    
    //saving or updating the existing and new lobs in the Lob_registration object
    public PageReference save(){
        list<LOB_Registration__c> lstToUpdateLobReg = new list<LOB_Registration__c>();
         list<LOB_Registration__c> lstToCreateLobReg = new list<LOB_Registration__c>();
         list<LOB_Registration__c> lstToDeleteLobReg = new list<LOB_Registration__c>();
         map<String,String> mapLobNameAndItsId = new map<String,String>();
         
         //-----------------------------------------------
         list<LOB_Registration__c > lstOfSeletedLob = [select id,Registered_End_User__c,LOB_Name__c,LOB_registration_status__c, Name,Preferred_GTM_Partner_Account__c 
                                        from LOB_Registration__c where Registered_End_User__c =:objAccBranch.Account__c and Location__c =:objAccBranch.Id];
         
          for(LOB_Registration__c  lo:lstOfSeletedLob)
            { 
                //lstToDeleteLobReg.add(lo);
                mapLobNameAndItsId.put(lo.LOB_Name__c,lo.Id);
            
            }
         
        for(existingLobsWrapper wr:existinglobList)
        {
            
            if((wr.selected == true) && (wr.selectedValLob  == 'Open' || wr.selectedValLob  == 'Closed'))
            {
                 LOB_Registration__c  updatelob = new LOB_Registration__c (id=wr.lobReg.id );
                 
                 updatelob.LOB_registration_status__c = wr.selectedValLob;
                 updatelob.Preferred_GTM_Partner_Account__c = null;
                 lstToUpdateLobReg.add(updateLob);
                 system.debug('lstToUpdateLobReg.........'+lstToUpdateLobReg);
                 
            }
            if(wr.selected == False)
            {
                string lobId = mapLobNameAndItsId.get(wr.lobReg.LOB_Name__c);
                LOB_Registration__c  deleteLob = new LOB_Registration__c(id=lobId);
                lstToDeleteLobReg.add(deleteLob);
                
            }
   
        }
        
        for(lobWrapper wrp : lobList)
        {
            if(wrp.Selected== true)
            {
                LOB_Registration__c  newLob = new LOB_Registration__c ();
                newLob.LOB_Name__c = wrp.lobadmin.Name;
                   //if(lstStatusMap.get(wrp.lobadmin.Name)!=null){
                        newLob.LOB_registration_status__c=wrp.selectedLobVal ;
                     //}
                     //else{
                        //newLob.LOB_registration_status__c='Open';
                     //}
               newLob.Registered_End_User__c  = objAccBranch.Account__c;
               newLob.Location__c = objAccBranch.Id;
               
                     lstToCreateLobReg.add(newLob);
            }          
        }
        insert lstToCreateLobReg; 
        update lstToUpdateLobReg;
        delete lstToDeleteLobReg;
        
        return PageUtils.redirect('/' + objAccBranch.Account__c);
    } 

    public List<SelectOption> getItems() {
         
         List<SelectOption> options = new List<SelectOption>();
         options.add(new SelectOption('Open','Open'));
         options.add(new SelectOption('Closed','Closed'));
         return options;
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
    //wraper class for existing lobs
    public class existingLobsWrapper
    {
        public LOB_Registration__c lobReg {get; set;}
        public Boolean selected {get; set;}
        public Boolean hideCheck {get; set;}
        public list<selectOption> leftSelectOptionList {get;set;}
        public string selectedValLob {get; set;}
        /*public existingLobsWrapper(LOB_Registration__c lob)
        {
            lobReg = lob;
            selected = true;
            //hideCheck = true;
        }*/  
    }
    
     public String getStrStatus() {
        return strStatus;
     }
        
     public void setStrStatus(String strStatus) {
        this.strStatus= strStatus;
     }
     
      public String getstatusExitingLob() {
        return statusExitingLob;
     }
        
     public void setstatusExitingLob(String statusExitingLob) {
        this.statusExitingLob= statusExitingLob;
     }
     
}