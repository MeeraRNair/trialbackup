/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         16136       FY19-DCE-0802   12-July-2018    Venkat Sharan   Removed debug statements as part of code Reduce for the story 5240538
*/
public class VFCntrlr_CSEPlatform{

    Id supportRequestId;
    string passedpage;
    public static Boolean SKIP_CSE_CUSTOM_VALIDATION  = false;
    Static List<Sales_Motion_User_Role__c> SMUserRole=new List<Sales_Motion_User_Role__c>();
    Static List<String> roleList=new List<String>();
    Static List<Support_Request__c> SRRecList=new List<Support_Request__c>();
    public String smErrMsg {get; set;}  
    public boolean isCustomError {get; set;}
    Support_Request__c supportRequest;
    public string strSuppRecordId {get;set;}
                 
    List<SelectOption> availablePlatforms = new List<SelectOption>(); 
    List<SelectOption> selectedPlatforms = new List<SelectOption>();
    List<SelectOption> allavailablePlatforms  = new List<SelectOption>();
    List<SelectOption> availableStorages = new List<SelectOption>(); 
    List<SelectOption> selectedStorages = new List<SelectOption>();
    List<SelectOption> allavailableStorages = new List<SelectOption>(); 
    List<SelectOption> availablePeripherals = new List<SelectOption>(); 
    List<SelectOption> selectedPeripherals = new List<SelectOption>();
    List<SelectOption> allavailablePeripherals  = new List<SelectOption>(); 
    List<SelectOption> availableOperatingsystems = new List<SelectOption>(); 
    List<SelectOption> selectedOperatingsystems = new List<SelectOption>();
    List<SelectOption> allavailableOperatingsystems = new List<SelectOption>(); 
    List<SelectOption> availableNetwork = new List<SelectOption>(); 
    List<SelectOption> selectedNetwork = new List<SelectOption>();
    List<SelectOption> allavailableNetwork = new List<SelectOption>(); 
    List<SelectOption> availableHba = new List<SelectOption>(); 
    List<SelectOption> selectedHba = new List<SelectOption>();
    List<SelectOption> allavailableHba = new List<SelectOption>(); 
    
    String[] platformsToRemove = new String[]{}; //Used to capture highlighted platform to be removed
    String[] smPlatformsToAdd = new String[]{}; //Used to capture highlighted platform to add
    String[] storagesToRemove = new String[]{}; //Used to capture highlighted storage to be removed
    String[] smStoragesToAdd = new String[]{}; //Used to capture highlighted storage to add
    String[] peripheralsToRemove = new String[]{}; //Used to capture highlighted peripherals to be removed
    String[] smPeripheralsToAdd = new String[]{}; //Used to capture highlighted peripherals to add
    String[] operatingsystemsToRemove = new String[]{}; //Used to capture highlighted Operating systems to be removed
    String[] smOperatingsystemsToAdd = new String[]{}; //Used to capture highlighted Operating systems to add
    String[] networkToRemove = new String[]{}; //Used to capture highlighted network to be removed
    String[] smNetworkToAdd = new String[]{}; //Used to capture highlighted network to add
    String[] hbaToRemove = new String[]{}; //Used to capture highlighted hba to be removed
    String[] smHbaToAdd = new String[]{}; //Used to capture highlighted hba to add
    
    
    
    public VFCntrlr_CSEPlatform(ApexPages.StandardController controller)
    {                       
             passedpage=ApexPages.currentPage().getParameters().get('page');
             strSuppRecordId = ApexPages.currentPage().getParameters().get('Id');
             supportRequest = (Support_Request__c )controller.getRecord(); 
			 
			 switch on passedpage{
				when 'Platforms'{
					loadPlatforms();
				}
				when 'storage'{
					loadstorages();
				}
				when 'peripherals'{
					loadperipherals();
				}
				when 'operatingsystems'{
					loadoperatingsystems();
				}
				when 'networkswitches'{
					loadnetworkswitches();
				}
				when 'HBA'{
					loadHBA();
				}
			 }            
    }
    public void loadPlatforms(){
        try {  
            supportRequestId = supportRequest.Id; 
            initializePlatforms();
            
            //Populate availablePlatforms with full list of available Platforms
            removeAllPlatforms();
            
             string platformsListString = supportRequest.Platform_List__c;
             if(platformsListString != null && platformsListString != ''){
               List<string> platformsListTmp = platformsListString.split(';');
               SelectOption sel;
               for(string cl : platformsListTmp){
                 sel = new SelectOption(cl,cl);
                 selectedPlatforms.add(sel);
                 smPlatformsToAdd.add(cl);                 
               }
               availablePlatforms = removeFromList(availablePlatforms, smPlatformsToAdd );  
               availablePlatforms.Sort();
             }
        }
        catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }
    
    }
    
   public void loadstorages(){
       try{
            supportRequestId = supportRequest.Id;            
            initializeStorages();
            
            //Populate availablePlatforms with full list of available Platforms
            removeAllStorages();
            
            string storagesListString = supportRequest.Storage_List__c;
             if(storagesListString != null && storagesListString != ''){
               List<string> storagesListTmp = storagesListString.split(';');
               SelectOption sel;
               for(string cl : storagesListTmp){
                 sel = new SelectOption(cl,cl);
                 selectedStorages.add(sel);
                 smStoragesToAdd.add(cl);                 
               }
               availableStorages = removeFromList(availableStorages, smStoragesToAdd );  
               availableStorages.Sort();
             }
       }
       catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }
   }
   public void loadperipherals(){
       try {                            
            supportRequestId = supportRequest.Id;            
            initializePeripherals();
            
            //Populate availablePeripherals with full list of available Platforms
            removeAllPeripherals();
            
             string peripheralsListString = supportRequest.Peripherals_List__c;
             if(peripheralsListString != null && peripheralsListString != ''){
               List<string> peripheralsListTmp = peripheralsListString.split(';');
               SelectOption sel;
               for(string cl : peripheralsListTmp){
                 sel = new SelectOption(cl,cl);
                 selectedPeripherals.add(sel);
                 smPeripheralsToAdd.add(cl);                 
               }
               availablePeripherals = removeFromList(availablePeripherals, smPeripheralsToAdd );  
               availablePeripherals.Sort();
             }
            
        }
        catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }
   }
   public void loadoperatingsystems(){
   try {                
            supportRequestId = supportRequest.Id;                        
            initializeOperatingsystems();
            
            //Populate availableOperatingsystems with full list of available Operatingsystems
            removeAllOperatingsystems();
            
             string operatingsystemsListString = supportRequest.Operating_Systems_List__c;
             if(operatingsystemsListString != null && operatingsystemsListString != ''){
               List<string> operatingsystemsListTmp = operatingsystemsListString.split(';');
               SelectOption sel;
               for(string cl : operatingsystemsListTmp){
                 sel = new SelectOption(cl,cl);
                 selectedOperatingsystems.add(sel);
                 smOperatingsystemsToAdd.add(cl);                 
               } 
               availableOperatingsystems = removeFromList(availableOperatingsystems, smOperatingsystemsToAdd );  
               availableOperatingsystems.Sort();
             }            
        }
        catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }    
   }
   public void loadnetworkswitches(){
    try {                
            supportRequestId = supportRequest.Id;
            initializeNetwork();
            
            //Populate availablePlatforms with full list of available Platforms
            removeAllNetwork();
            
             string networkListString = supportRequest.Network_Switches_List__c;
             if(networkListString != null && networkListString != ''){
               List<string> networkListTmp = networkListString.split(';');
               SelectOption sel;
               for(string cl : networkListTmp){
                 sel = new SelectOption(cl,cl);
                 selectedNetwork.add(sel);
                 smNetworkToAdd.add(cl);                 
               }
               availableNetwork = removeFromList(availableNetwork, smNetworkToAdd );  
               availableNetwork.Sort();
             }            
        }
        catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }    
   }
   public void loadHBA(){
   try {                
            supportRequestId = supportRequest.Id;            
            initializeHba();
            
            //Populate availablePlatforms with full list of available Platforms
            removeAllHba();
            
             string hbaListString = supportRequest.HBA_List__c;
             if(hbaListString != null && hbaListString != ''){
               List<string> hbaListTmp = hbaListString.split(';');
               SelectOption sel;
               for(string cl : hbaListTmp){
                 sel = new SelectOption(cl,cl);
                 selectedHba.add(sel);
                 smHbaToAdd.add(cl);         
               }
              availableHba = removeFromList(availableHba, smHbaToAdd );  
              availableHba.Sort();  
             }            
        }
        catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }
   }
   
   public List<SelectOption> getallAvailablePlatforms(){
     return allAvailablePlatforms;
   }
   public List<SelectOption> getallAvailableStorages(){
     return allAvailableStorages;
   }
   public List<SelectOption> getallAvailablePeripherals(){
     return allAvailablePeripherals;
   }
    public List<SelectOption> getallAvailableOperatingsystems(){
     return allAvailableOperatingsystems;
   }
   public List<SelectOption> getallAvailableNetwork(){
     return allAvailableNetwork;
   } 
   public List<SelectOption> getallAvailableHba(){
     return allAvailableHba;
   }
    public String getSupportRequestId()
    {
        return supportRequestId;
    }  
    
    public void initializePlatforms()
    {       
        try
        {
            allAvailablePlatforms.clear();            
            Schema.DescribeFieldResult platforms = Support_Request__c.Platforms__c.getDescribe();            
            List<Schema.PicklistEntry> pickList = platforms.getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailablePlatforms.add(new SelectOption(entry .getValue(),entry .getLabel()));         
            }  
        }   
        catch(Exception e)
        {              
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Platforms. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    public void initializeStorages()
    {       
        try
        {
            allAvailableStorages.clear();            
            Schema.DescribeFieldResult storages = Support_Request__c.Storage__c.getDescribe();            
            List<Schema.PicklistEntry> pickList = storages.getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailableStorages.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }  
        }   
        catch(Exception e)
        {            
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Storage. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
     public void initializePeripherals()
    {       
        try
        {
            allAvailablePeripherals.clear();            
            Schema.DescribeFieldResult peripherals = Support_Request__c.Peripherals__c.getDescribe();            
            List<Schema.PicklistEntry> pickList = peripherals.getPicklistValues();            
			
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailablePeripherals.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }  
        }   
        catch(Exception e)
        {            
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Peripherals. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    public void initializeOperatingsystems()
    {       
        try
        {
            allAvailableOperatingsystems.clear();            
            Schema.DescribeFieldResult operatingsystems = Support_Request__c.Operating_Systems__c.getDescribe();            
            List<Schema.PicklistEntry> pickList = operatingsystems.getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailableOperatingsystems.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }  
        }   
        catch(Exception e)
        {            
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Operating systems. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    public void initializeNetwork()
    {       
        try
        {
            allAvailableNetwork.clear();            
            Schema.DescribeFieldResult network = Support_Request__c.Network_Switches__c.getDescribe();            
            List<Schema.PicklistEntry> pickList = network.getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailableNetwork.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }  
        }   
        catch(Exception e)
        {            
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Storage. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    public void initializeHba()
    {       
        try
        {
            allAvailableHba.clear();            
            Schema.DescribeFieldResult hba = Support_Request__c.HBA__c.getDescribe();            
            List<Schema.PicklistEntry> pickList = hba.getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailableHba.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }  
        }   
        catch(Exception e)
        {            
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing HBA. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    public String[] getSmPlatformsToAdd()
    {
        return smPlatformsToAdd;
    }

    public String[] getPlatformsToRemove() 
    {
        return platformsToRemove;
    }
    
    //On submit, capture the selected countries to add
    public void setsmPlatformsToAdd(String[] platformsSelected)
    {
        smPlatformsToAdd = platformsSelected;        
    }
    
    //On submit, capture the selected countries to remove
    public void  setPlatformsToRemove(String[] platformsSelected)
    {
        platformsToRemove = platformsSelected;        
    } 
    public String[] getSmStoragesToAdd()
    {
        return smStoragesToAdd;
    }

    public String[] getStoragesToRemove() 
    {
        return StoragesToRemove;
    }
    
    //On submit, capture the selected countries to add
    public void setsmStoragesToAdd(String[] storagesSelected)
    {
        smStoragesToAdd = storagesSelected;
    }
    
    //On submit, capture the selected countries to remove
    public void  setStoragesToRemove(String[] storagesSelected)
    {
        storagesToRemove = storagesSelected;        
    }     
    public String[] getSmPeripheralsToAdd()
    {
        return smPeripheralsToAdd;
    }

    public String[] getPeripheralsToRemove() 
    {
        return peripheralsToRemove;
    }
    
    //On submit, capture the selected countries to add
    public void setsmPeripheralsToAdd(String[] peripheralsSelected)
    {
        smPeripheralsToAdd = peripheralsSelected;
    }
    
    //On submit, capture the selected countries to remove
    public void  setPeripheralsToRemove(String[] peripheralsSelected)
    {
        peripheralsToRemove = peripheralsSelected;        
    } 
    public String[] getSmOperatingsystemsToAdd()
    {
        return smOperatingsystemsToAdd;
    }

    public String[] getOperatingsystemsToRemove() 
    {
        return operatingsystemsToRemove;
    }
    
    //On submit, capture the selected countries to add
    public void setsmOperatingsystemsToAdd(String[] operatingsystemsSelected)
    {
        smOperatingsystemsToAdd = operatingsystemsSelected;
    }
    
    //On submit, capture the selected countries to remove
    public void  setOperatingsystemsToRemove(String[] operatingsystemsSelected)
    {
        operatingsystemsToRemove = operatingsystemsSelected;        
    } 
    
    public String[] getSmNetworkToAdd()
    {
        return smNetworkToAdd;
    }

    public String[] getNetworkToRemove() 
    {
        return NetworkToRemove;
    }
    
    //On submit, capture the selected countries to add
    public void setsmNetworkToAdd(String[] networkSelected)
    {
        smNetworkToAdd = networkSelected;
    }
    
    //On submit, capture the selected countries to remove
    public void  setNetworkToRemove(String[] networkSelected)
    {
        networkToRemove = networkSelected;        
    }  
     public String[] getSmHbaToAdd()
    {
        return smHbaToAdd;
    }

    public String[] getHbaToRemove() 
    {
        return HbaToRemove;
    }
    
    //On submit, capture the selected countries to add
    public void setsmHbaToAdd(String[] hbaSelected)
    {
        smHbaToAdd = hbaSelected;
    }
    
    //On submit, capture the selected countries to remove
    public void  setHbaToRemove(String[] hbaSelected)
    {
        hbaToRemove = hbaSelected;        
    }        
    //Remove selected platforms to add from available Platforms list, add to selected Platforms list
    public void addPlatforms()
    {
        selectedPlatforms = addToList(selectedPlatforms, smPlatformsToAdd  );
        availablePlatforms = removeFromList(availablePlatforms, smPlatformsToAdd );
        selectedPlatforms.Sort(); 
        availablePlatforms.Sort();    
    }
    
    //Clear available countries list, reinitialize selected countries list with full list
    public void addAllPlatforms()
    {
        availablePlatforms.clear();
        selectedPlatforms.clear();
        selectedPlatforms.addAll(allAvailablePlatforms);
    }

    //Remove selected countries to remove from selected countries list, add to available countries list
    public void removePlatforms()
    {
        availablePlatforms = addToList(availablePlatforms, platformsToRemove );
        selectedPlatforms = removeFromList(selectedPlatforms, platformsToRemove );
        availablePlatforms.Sort();
        selectedPlatforms.Sort(); 
    }
    
    //Clear selected countries list, reinitialize available countries list with full list
    public void removeAllPlatforms()
    {
        availablePlatforms.clear();
        selectedPlatforms.clear();
        availablePlatforms.addAll(allAvailablePlatforms);
    }
    //Remove selected Storages to add from available Storages list, add to selected Storages list
    public void addStorages()
    {
        selectedStorages = addToList(selectedStorages, smStoragesToAdd  );
        availableStorages = removeFromList(availableStorages, smStoragesToAdd );  
        selectedStorages.Sort(); 
        availableStorages.Sort();  
    }
    
    //Clear available Storages list, reinitialize selected Storages list with full list
    public void addAllStorages()
    {
        availableStorages.clear();
        selectedStorages.clear();
        selectedStorages.addAll(allAvailableStorages);
    }

    //Remove selected Storages to remove from selected storages list, add to available storages list
    public void removeStorages()
    {
        availableStorages = addToList(availableStorages, storagesToRemove );
        selectedStorages = removeFromList(selectedStorages, storagesToRemove );
        availableStorages.Sort();
        selectedStorages.Sort(); 
    }
    
    //Clear selected Storages list, reinitialize available Storages list with full list
    public void removeAllStorages()
    {
        availableStorages.clear();
        selectedStorages.clear();
        availableStorages.addAll(allAvailableStorages);
    }
    //Remove selected peripherals to add from available Peripherals list, add to selected Peripherals list
    public void addPeripherals()
    {
        selectedPeripherals = addToList(selectedPeripherals, smPeripheralsToAdd  );
        availablePeripherals = removeFromList(availablePeripherals, smPeripheralsToAdd );  
        selectedPeripherals.Sort();  
        availablePeripherals.Sort();
    }
    
    //Clear available countries list, reinitialize selected countries list with full list
    public void addAllPeripherals()
    {
        availablePeripherals.clear();
        selectedPeripherals.clear();
        selectedPeripherals.addAll(allAvailablePeripherals);
    }

    //Remove selected peripherals to remove from selected peripherals list, add to available peripherals list
    public void removePeripherals()
    {
        availablePeripherals = addToList(availablePeripherals, peripheralsToRemove );
        selectedPeripherals = removeFromList(selectedPeripherals, peripheralsToRemove );
        availablePeripherals.Sort();
        selectedPeripherals.Sort();
    }
    
    //Clear selected peripherals list, reinitialize available peripherals list with full list
    public void removeAllPeripherals()
    {
        availablePeripherals.clear();
        selectedPeripherals.clear();
        availablePeripherals.addAll(allAvailablePeripherals);
    }
    //Remove selected Operating systems to add from available Operating systems list, add to selected Operating systems list
    public void addOperatingsystems()
    {
        selectedOperatingsystems = addToList(selectedOperatingsystems, smOperatingsystemsToAdd  );
        availableOperatingsystems = removeFromList(availableOperatingsystems, smOperatingsystemsToAdd );    
        selectedOperatingsystems.Sort();
        availableOperatingsystems.Sort();
    }
    
    //Clear available Operating systems list, reinitialize selected Operating systems list with full list
    public void addAllOperatingsystems()
    {
        availableOperatingsystems.clear();
        selectedOperatingsystems.clear();
        selectedOperatingsystems.addAll(allAvailableOperatingsystems);
    }

    //Remove selected Operatingsystems to remove from selected Operatingsystems list, add to available Operatingsystems list
    public void removeOperatingsystems()
    {
        availableOperatingsystems = addToList(availableOperatingsystems, operatingsystemsToRemove );
        selectedOperatingsystems = removeFromList(selectedOperatingsystems, operatingsystemsToRemove );
        availableOperatingsystems.Sort();
        selectedOperatingsystems.Sort();
    }
    
    //Clear selected Operatingsystems list, reinitialize available Operatingsystems list with full list
    public void removeAllOperatingsystems()
    {
        availableOperatingsystems.clear();
        selectedOperatingsystems.clear();
        availableOperatingsystems.addAll(allAvailableOperatingsystems);
    }
    //Remove selected Network to add from available Network list, add to selected Network list
    public void addNetwork()
    {
        selectedNetwork = addToList(selectedNetwork, smNetworkToAdd  );
        availableNetwork = removeFromList(availableNetwork, smNetworkToAdd ); 
        selectedNetwork.Sort();   
        availableNetwork.Sort();
    }
    
    //Clear available Network list, reinitialize selected Network list with full list
    public void addAllNetwork()
    {
        availableNetwork.clear();
        selectedNetwork.clear();
        selectedNetwork.addAll(allAvailableNetwork);
    }

    //Remove selected Network to remove from selected network list, add to available network list
    public void removeNetwork()
    {
        availableNetwork = addToList(availableNetwork, networkToRemove );
        selectedNetwork = removeFromList(selectedNetwork, networkToRemove );
        availableNetwork.Sort();
        selectedNetwork.Sort();
    }
    
    //Clear selected Network list, reinitialize available Network list with full list
    public void removeAllNetwork()
    {
        availableNetwork.clear();
        selectedNetwork.clear();
        availableNetwork.addAll(allAvailableNetwork);
    }
    //Remove selected Hba to add from available Hba list, add to selected Hba list
    public void addHba()
    {
        selectedHba = addToList(selectedHba, smHbaToAdd  );
        availableHba = removeFromList(availableHba, smHbaToAdd );
        selectedHba.Sort();
        availableHba.Sort(); 
    }
    
    //Clear available Hba list, reinitialize selected Hba list with full list
    public void addAllHba()
    {
        availableHba.clear();
        selectedHba.clear();
        selectedHba.addAll(allAvailableHba);
    }

    //Remove selected Hba to remove from selected hba list, add to available hba list
    public void removeHba()
    {
        availableHba = addToList(availableHba, hbaToRemove );
        selectedHba = removeFromList(selectedHba, hbaToRemove );
        availableHba.Sort();
        selectedHba.Sort();
    }
    
    //Clear selected Hba list, reinitialize available Hba list with full list
    public void removeAllHba()
    {
        availableHba.clear();
        selectedHba.clear();
        availableHba.addAll(allAvailableHba);
    }
    
    public string getpassedpage(){
        return passedpage;
    }
    public List<SelectOption> getAvailablePlatforms() {
        return availablePlatforms ;
    }  
       
    public List<SelectOption> getSelectedPlatforms() {
        return selectedPlatforms ;
    }
    public List<SelectOption> getAvailableStorages() {
        return availableStorages ;
    }  
       
    public List<SelectOption> getSelectedStorages() {
        return selectedStorages ;
    }
    public List<SelectOption> getAvailablePeripherals() {
        return availablePeripherals ;
    }  
       
    public List<SelectOption> getSelectedPeripherals() {
        return selectedPeripherals ;
    }
    public List<SelectOption> getAvailableOperatingsystems() {
        return availableOperatingsystems ;
    }  
       
    public List<SelectOption> getSelectedOperatingsystems() {
        return selectedOperatingsystems ;
    }
    public List<SelectOption> getAvailableNetwork() {
        return availableNetwork ;
    }  
       
    public List<SelectOption> getSelectedNetwork() {
        return selectedNetwork ;
    }
     public List<SelectOption> getAvailableHba() {
        return availableHba ;
    }  
       
    public List<SelectOption> getSelectedHba() {
        return selectedHba ;
    }
    //Generic function to remove items in <theCountries> from <theList>
    public List<SelectOption> removeFromList(List<SelectOption> theList, String[] thePlatforms)
    {
        boolean toRemove = false;        
        Map<String, String> tempThePlatforms = new Map<String, String> {};
        
        for (String role : thePlatforms)
        {
            tempThePlatforms.put(role,role);
        }        
       
        List<SelectOption> newList = new List<SelectOption>();
        for(SelectOption listItem: theList)
        {
            if(!tempThePlatforms.containsKey(listItem.getValue()))
            {
                newList.add(new SelectOption(listItem.getValue(), listItem.getLabel()));
            }            

        }
        newList.Sort();
        return newList;
    }
    
    //Generic function to add items in <theCountries> to <theList>
    public List<SelectOption> addToList(List<SelectOption> theList, String[] thePlatforms)
    {
        boolean toAdd = true;
        
        List<SelectOption> newList = new List<SelectOption>();
        newList.addAll(theList);
        for(String platform_v : thePlatforms)
        {
            newList.add(new SelectOption(platform_v , platform_v ));   
        }       
        return newList;
    }
     
    public void savePlatforms(){    
    system.debug('savePlatforms Method Called');
    Set<String> roleSet=new Set<String>();
    List<Id> userId=new List<Id>(); 
    userId.add(UserInfo.getUserId());
    try{
      for(Sales_Motion_User_Role__c roleVar:[Select Id,Role__c,Username__c from Sales_Motion_User_Role__c where Username__c in:userId]){
            SMUserRole.add(roleVar);
            roleList.add(roleVar.Role__c);
            roleSet.add(roleVar.Role__c);
      } 

      string platformList = '';
      Integer i = 0;
      
      if(selectedPlatforms != null && selectedPlatforms.size() > 0){
        for(SelectOption selPlatform : selectedPlatforms ){
          if(i == 0)
            platformList = selPlatform .getValue() + ';' ;
          else
            platformList = platformList + selPlatform .getValue() +  ';' ;
            
          i++;    
        }
        supportRequest.Platform_List__c = platformList ;
          
      } else { 
        supportRequest.Platform_List__c = null;
      }
      
      if((roleSet.size() > 0) && supportRequest.Platform_List__c == null ){
          throw new PlatformInvalidException();          
      }
      //to bypass managecsesupportrequest custom validaion
      SKIP_CSE_CUSTOM_VALIDATION = True;       
      update supportRequest;
      SKIP_CSE_CUSTOM_VALIDATION = False;
      
      //return PageUtils.redirect('/' + supportRequest.Id); 
   }
   
    Catch(PlatformInvalidException e){
       handleError(e);                           
   }
   //return null; 
} 
   public void  saveStorages(){      
      string storagesList = '';
      Integer i = 0;
      
      if(selectedStorages != null && selectedStorages.size() > 0){
        for(SelectOption selStorages : selectedStorages ){
          if(i == 0)
            storagesList = selStorages .getValue() + ';' ;
          else
            storagesList = storagesList + selStorages .getValue() +  ';' ;
            
          i++;    
        }
        supportRequest.Storage_List__c = storagesList ;
          
      } else { 
        supportRequest.Storage_List__c = null;
      }
	  
      SKIP_CSE_CUSTOM_VALIDATION = True;
      update supportRequest;      
      SKIP_CSE_CUSTOM_VALIDATION = False;
     // return PageUtils.redirect('/' + supportRequest.Id);    
 } 
   public void savePeripherals(){      
      string peripheralsList = '';
      Integer i = 0;
      
      if(selectedPeripherals != null && selectedPeripherals.size() > 0){
        for(SelectOption selPeripherals : selectedPeripherals ){
          if(i == 0)
            peripheralsList = selPeripherals .getValue() + ';' ;
          else
            peripheralsList = peripheralsList + selPeripherals .getValue() +  ';' ;
            
          i++;    
        }
        supportRequest.Peripherals_List__c = peripheralsList ;
          
      } else { 
        supportRequest.Peripherals_List__c = null;
      }
      
      SKIP_CSE_CUSTOM_VALIDATION = True;      
      update supportRequest;      
      SKIP_CSE_CUSTOM_VALIDATION = False;
    //  return PageUtils.redirect('/' + supportRequest.Id); 
   }
   public void saveOperatingsystems(){
  
    Set<String> roleSet=new Set<String>();
    List<Id> userId=new List<Id>(); 
    userId.add(UserInfo.getUserId());
    try{
      for(Sales_Motion_User_Role__c roleVar:[Select Id,Role__c,Username__c from Sales_Motion_User_Role__c where Username__c in:userId]){
            SMUserRole.add(roleVar);
            roleList.add(roleVar.Role__c);
            roleSet.add(roleVar.Role__c);
      } 
      
      string operatingsystemsList = '';
      Integer i = 0;
      
      if(selectedOperatingsystems != null && selectedOperatingsystems.size() > 0){
        for(SelectOption selOperatingsystems : selectedOperatingsystems ){
          if(i == 0)
            operatingsystemsList = selOperatingsystems .getValue() + ';' ;
          else
            operatingsystemsList = operatingsystemsList + selOperatingsystems .getValue() +  ';' ;
            
          i++;    
        }
        supportRequest.Operating_Systems_List__c = operatingsystemsList ;
          
      } else { 
        supportRequest.Operating_Systems_List__c = null;
      }
           
      if((roleSet.size() > 0) && supportRequest.Operating_Systems_List__c == null ){
          throw new OSInvalidException();          
      }
      SKIP_CSE_CUSTOM_VALIDATION = True;      
      update supportRequest;      
      SKIP_CSE_CUSTOM_VALIDATION = False;
     // return PageUtils.redirect('/' + supportRequest.Id);        
    }
   Catch(OSInvalidException e){
       handleError(e);
  
 //  return null; 
   }
  } 
   public void saveNetwork(){      
      string networkList = '';
      Integer i = 0;
      
      if(selectedNetwork != null && selectedNetwork.size() > 0){
        for(SelectOption selNetwork : selectedNetwork ){
          if(i == 0)
            networkList = selNetwork .getValue() + ';' ;
          else
            networkList = networkList + selNetwork .getValue() +  ';' ;
            
          i++;    
        }
        supportRequest.Network_Switches_List__c = networkList ;
          
      } else { 
        supportRequest.Network_Switches_List__c = null;
      }
      SKIP_CSE_CUSTOM_VALIDATION = True;      
      update supportRequest;      
      SKIP_CSE_CUSTOM_VALIDATION = False;
     // return PageUtils.redirect('/' + supportRequest.Id); 
   } 
   public void saveHba(){      
      string hbaList = '';
      Integer i = 0;
      
      if(selectedHba != null && selectedHba.size() > 0){
        for(SelectOption selHba : selectedHba ){
          if(i == 0)
            hbaList = selHba .getValue() + ';' ;
          else
            hbaList = hbaList + selHba .getValue() +  ';' ;
            
          i++;    
        }
        supportRequest.HBA_List__c = hbaList ;
          
      } else { 
        supportRequest.HBA_List__c = null;
      }
      SKIP_CSE_CUSTOM_VALIDATION = True;      
      update supportRequest;      
      SKIP_CSE_CUSTOM_VALIDATION = False;
    //  return PageUtils.redirect('/' + supportRequest.Id); 
   } 
    public PageReference redirectBack(){      
      return PageUtils.redirect('/' + supportRequest.Id);     
    }
   
     private void handleError(Exception e){  
      
      if (e instanceOf PlatformInvalidException){
            isCustomError=false;
            smErrMsg = 'Please enter value for Platforms';
      }
      if (e instanceOf OSInvalidException){
            isCustomError=false;
            smErrMsg = 'Please enter value for Operating Systems';
      }
     }  
 
 public class PlatformInvalidException extends Exception {} 
 public class OSInvalidException extends Exception {} 
}