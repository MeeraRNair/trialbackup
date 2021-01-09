/* 
REVISION HISTORY
======================================================================================================================
Version    Author    Date           Release#                CR#         Description
-------   ------     ----           --------                ---         -----------
1.0        Naga     14-Aug-2017     10.01                   14780       updated POPV creation process and updated "view existing" button functionality to checkbox selection and removed "view existing" button.
*/

Public class newPOPCreationProcess 
{
    Public class WrapperContactWrapper 
    { 
        Public Associated_Programs_Vendors__c con{get;set;} 
        Public boolean bool{get;set;} 
        public WrapperContactWrapper(Associated_Programs_Vendors__c c,boolean bool) 
        { 
            this.con = c; 
            this.bool = bool; 
        } 
    }   
    public Integer size { get; set; } 
    public Long NumberOfPages {get; set;}
    Public List<WrapperContactWrapper> wrapperlist{get;set;}
    Public Integer noOfRecords{get; set;}
    public Map <id,Associated_Programs_Vendors__c> SelectedcontactMap{get;set;}
    public boolean display{get;set;}
    public list<POP_Line_Item__c> selectedList {get;set;}
    public Boolean panelShow {get;set;}
    public Headcount__c adsetting{ get; set; }
    public MDF_Program__c mdfPrgram {get;set;}
    public boolean firstPanel{get;set;}
    public boolean secondPanel{get;set;}
    public boolean allorNone{get;set;}
    public ApexPages.StandardSetController Setcon{get;set;}
    public Map<Id,List<Id>> mapAPVToMDF{get;set;}
    
    public newPOPCreationProcess(){
        adsetting = new Headcount__c();  
        mdfPrgram = new MDF_Program__c ();
        noOfRecords = 0;         
        size = 10; 
        wrapperlist = new List <WrapperContactWrapper>();
        selectedList  = new list<POP_Line_Item__c>();
        SelectedcontactMap = new Map <id,Associated_Programs_Vendors__c>();
        Setcon = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id,Name,POP_Status__c,MDF_Program__c,MDF_Program__r.Name,Program_Name__c,Manager_Name__c,Employee_Name__c,Region__c,Sub_Region__c,Vendor__c,Business_Segment__c,Country__c,Headcount__c,Headcount__r.Manager_s_Name__c from Associated_Programs_Vendors__c Where Headcount__r.Manager_s_Name__c=:adsetting.Manager_s_Name__c and Fiscal_Quarter_New__c=:mdfPrgram.Fiscal_Quarter__c order by Headcount__c,MDF_Program__c,vendor__c limit 10])); 
        Setcon.setpagesize(10);
        noOfRecords = Setcon.getResultSize();
        NumberOfPages = (noOfRecords/(Decimal)size).round(System.RoundingMode.CEILING);
             
    } 
    
    public void initLoad(){
      size = 10;    
      wrapperlist = new List <WrapperContactWrapper>();
      selectedList = new list<POP_Line_Item__c>();
      SelectedcontactMap = new Map <id,Associated_Programs_Vendors__c>();
      Setcon = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id,Name,POP_Status__c,MDF_Program__c,MDF_Program__r.Name,Program_Name__c,Manager_Name__c,Employee_Name__c,Region__c,Sub_Region__c,Vendor__c,Business_Segment__c,Country__c,Headcount__c,Headcount__r.Manager_s_Name__c from Associated_Programs_Vendors__c Where Headcount__r.Manager_s_Name__c=:adsetting.Manager_s_Name__c and Fiscal_Quarter_New__c=:mdfPrgram.Fiscal_Quarter__c order by Headcount__c,MDF_Program__c,vendor__c limit 10000])); 
      Setcon.setpagesize(10);
      noOfRecords = Setcon.getResultSize();
      firstPanel = true;
      allorNone = false;
      secondPanel = false;
      panelShow = false;
      NumberOfPages = (noOfRecords/(Decimal)size).round(System.RoundingMode.CEILING);
    }
    

    Public List<WrapperContactWrapper> getContact(){        
            allorNone = false;
            getSelectedContact();
            wrapperlist = new List <WrapperContactWrapper>();
            for(Associated_Programs_Vendors__c cc : (List<Associated_Programs_Vendors__c>)Setcon.getRecords()){
                if( SelectedcontactMap.ContainsKey(cc.id)){
                    wrapperlist.add (new WrapperContactWrapper(cc,true)); 
                }
                else{
                    wrapperlist.add(new WrapperContactWrapper(cc,false)); 
                }
            }
            return wrapperlist;
    }
    
    public void getSelectedContact(){
        if(wrapperlist!=null){
            for(WrapperContactWrapper wr:wrapperlist){
                if(wr.bool == true){
                    SelectedcontactMap.put(wr.con.id,wr.con);
                }
                else{
                    SelectedcontactMap.remove(wr.con.id);
                }
            }
        } 
    }
    
    public void mapMdfIds(){
        display = true;
        panelShow = false;
        secondPanel = true;
        getSelectedContact();
        mapAPVToMDF = new Map<Id,List<Id>>();
        for(Associated_Programs_Vendors__c obj:SelectedcontactMap.values()){
            if(mapAPVToMDF.containsKey(obj.MDF_Program__c)) {
                List<Id> listid = mapAPVToMDF.get(obj.MDF_Program__c);
                listid.add(obj.Vendor__c);
                mapAPVToMDF.put(obj.MDF_Program__c, listid);
            } else {
                mapAPVToMDF.put(obj.MDF_Program__c, new List<Id> {obj.Vendor__c});
            }
            
        }        
    }

    public void createPOPRecord(){
        selectedList = new list<POP_Line_Item__c>();       
        mapMdfIds();
        Map<Id,Id> mapMDFToPOP = new Map<Id,Id>();
        Map<Id,Id> mapPOPToMDF = new Map<Id,Id>();
        for(Proof_of_Performance_POP__c objPOP:[Select Id,mdf_program__c from Proof_of_Performance_POP__c Where mdf_program__c IN:mapAPVToMDF.keyset()]){
            mapMDFToPOP.put(objPOP.mdf_program__c,objPOP.Id);
            mapPOPToMDF.put(objPOP.Id,objPOP.mdf_program__c);
        }
        List<Proof_of_Performance_POP__c> popToInsert = new List<Proof_of_Performance_POP__c>();
        Map<Id,Id> mapToChkMDF = new Map<Id,Id>();
        for(Associated_Programs_Vendors__c objLoop:SelectedcontactMap.values()){            
            if(!mapMDFToPOP.containsKey(objLoop.MDF_Program__c) && !mapToChkMDF.containsKey(objLoop.MDF_Program__c)){
                popToInsert.add(new Proof_of_Performance_POP__c(Name = objLoop.MDF_Program__r.Name,MDF_Program__c = objLoop.MDF_Program__c,Headcount__c =  objLoop.Headcount__c));
                mapToChkMDF.Put(objLoop.MDF_Program__c,objLoop.Id);
            }
          
        }
        Set<Id> popIds = new Set<Id>();
        if(popToInsert.size()>0){
            List<Database.SaveResult> updateResults = Database.insert(popToInsert, false);    
            for(Database.SaveResult sv:updateResults){
                popIds.add(sv.getId());
            } 
        } 
        popIds.addAll(mapMDFToPOP.values());
        Map<Id,Id> AllPOPIds = new Map<Id,Id>();
        for(Proof_of_Performance_POP__c allPOP:[Select Id,mdf_program__c,Headcount__r.Employee_Name__c from Proof_of_Performance_POP__c Where Id IN:popIds]){
            AllPOPIds.put(allPOP.mdf_program__c,allPOP.Id);
        }
        Map<Id,List<Id>> mapPOPToPOPLI = new Map<Id,List<Id>>();
        for(POP_Line_Item__c objLi:[Select Id,Proof_of_Performance_POP__c,Proof_of_Performance_POP__r.mdf_program__c,Vendor__c from POP_Line_Item__c Where Proof_of_Performance_POP__c IN:popIds]){         
            if(mapPOPToPOPLI.containsKey(objLi.Proof_of_Performance_POP__r.mdf_program__c)) {
                List<Id> listid = mapPOPToPOPLI.get(objLi.Proof_of_Performance_POP__r.mdf_program__c);
                listid.add(objLi.Vendor__c);
                mapPOPToPOPLI.put(objLi.Proof_of_Performance_POP__r.mdf_program__c, listid);
            } else {
                mapPOPToPOPLI.put(objLi.Proof_of_Performance_POP__r.mdf_program__c, new List<Id> {objLi.Vendor__c});
            }
        }
        List<POP_Line_Item__c> popLineItemToInsert = new List<POP_Line_Item__c>();
        for(Associated_Programs_Vendors__c objLoop:SelectedcontactMap.values()){
            if(mapPOPToPOPLI.containsKey(objLoop.mdf_program__c)){
                set<Id> listId = new set<Id>(mapPOPToPOPLI.get(objLoop.mdf_program__c));                
                if(mapPOPToPOPLI.containsKey(objLoop.mdf_program__c) && !listId.contains(objLoop.Vendor__c)){   
                    popLineItemToInsert.add(new POP_Line_Item__c(Proof_of_Performance_POP__c = AllPOPIds.get(objLoop.mdf_program__c),Vendor__c = objLoop.Vendor__c,POP_Status__c = objLoop.POP_Status__c));
                }
            }
            else if(!mapPOPToPOPLI.containsKey(objLoop.mdf_program__c)){
                popLineItemToInsert.add(new POP_Line_Item__c(Proof_of_Performance_POP__c = AllPOPIds.get(objLoop.mdf_program__c),Vendor__c = objLoop.Vendor__c,POP_Status__c = objLoop.POP_Status__c));
            }
        }
        Set<Id> popLiIds = new Set<Id>();       
        if(popLineItemToInsert.size()>0){
            List<Database.SaveResult> updateResults = Database.insert(popLineItemToInsert, false);  
            for(Database.SaveResult sv:updateResults){
                popLiIds.add(sv.getId());
            }          
        }

        List<POP_Line_Item__c> lstPOPLineItems = new List<POP_Line_Item__c>();      
        for(POP_Line_Item__c objLi:[Select Id,POP_Submission_Status__c,Name,Program__c,Business_Segment__c,Proof_of_Performance_POP__r.mdf_program__r.HCID__r.Employee_Name__c,Proof_of_Performance_POP__r.Sub_Region__c,Vendor__c,Proof_of_Performance_POP__r.Region__c,Proof_of_Performance_POP__r.Name,Country__c,Proof_of_Performance_POP__r.mdf_program__c,Proof_of_Performance_POP__r.mdf_program__r.HCID__c from POP_Line_Item__c Where Proof_of_Performance_POP__c IN:popIds order by Proof_of_Performance_POP__r.mdf_program__r.HCID__c,Proof_of_Performance_POP__r.mdf_program__c,vendor__c]){
            if(mapAPVToMDF.containsKey(objLi.Proof_of_Performance_POP__r.mdf_program__c)){
                set<Id> listId = new set<Id>(mapAPVToMDF.get(objLi.Proof_of_Performance_POP__r.mdf_program__c));                
                if(mapAPVToMDF.containsKey(objLi.Proof_of_Performance_POP__r.mdf_program__c) && listId.contains(objLi.Vendor__c)){   
                lstPOPLineItems.add(objLi);
                }
            }    
            
        } 
        selectedList = lstPOPLineItems;     
    }
    
    
    public void View_Existing(){        
        selectedList = new list<POP_Line_Item__c>();
        mapMdfIds();              
        Map<Id,Id> mapPOPToMDF = new Map<Id,Id>();
        for(Proof_of_Performance_POP__c objPOP:[Select Id,mdf_program__c from Proof_of_Performance_POP__c Where mdf_program__c IN:mapAPVToMDF.keyset()]){
            mapPOPToMDF.put(objPOP.Id,objPOP.mdf_program__c);
        }
        List<POP_Line_Item__c> lstPOPLineItems = new List<POP_Line_Item__c>();      
        for(POP_Line_Item__c objLi:[Select Id,POP_Submission_Status__c,Name,Program__c,Business_Segment__c,Proof_of_Performance_POP__r.POP_Submission_Status__c,Proof_of_Performance_POP__r.mdf_program__r.HCID__r.Employee_Name__c,Proof_of_Performance_POP__r.Sub_Region__c,Vendor__c,Proof_of_Performance_POP__r.Region__c,Proof_of_Performance_POP__r.Name,Country__c,Proof_of_Performance_POP__r.mdf_program__c,Proof_of_Performance_POP__r.mdf_program__r.HCID__c from POP_Line_Item__c Where Proof_of_Performance_POP__c IN:mapPOPToMDF.keyset() order by Proof_of_Performance_POP__r.mdf_program__r.HCID__c,Proof_of_Performance_POP__r.mdf_program__c,vendor__c]){
            if(mapAPVToMDF.containsKey(objLi.Proof_of_Performance_POP__r.mdf_program__c)){
                set<Id> listId = new set<Id>(mapAPVToMDF.get(objLi.Proof_of_Performance_POP__r.mdf_program__c));                
                if(mapAPVToMDF.containsKey(objLi.Proof_of_Performance_POP__r.mdf_program__c) && listId.contains(objLi.Vendor__c)){   
                    lstPOPLineItems.add(objLi);
                    
                }                
            }           
        }          
        selectedList = lstPOPLineItems;
        if(selectedList.size()==0 && mapAPVToMDF.size() != 0){            
            panelShow = true;                     
        }
        if(selectedList.size()==0){            
            secondPanel = false;                       
        }               
    }

    public integer pageNumber {
        get {
            return Setcon.getPageNumber();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
}