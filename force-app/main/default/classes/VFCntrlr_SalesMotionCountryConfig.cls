public class VFCntrlr_SalesMotionCountryConfig {

    Id salesMotionSectionId; 

    Sales_Motion_Page_Section__c salesMotionPageSection;
     
            
    List<SelectOption> availableCountries = new List<SelectOption>(); 
    List<SelectOption> selectedCountries = new List<SelectOption>();
    List<SelectOption> allAvailableCountries = new List<SelectOption>(); 
    List<SelectOption> availableRegions = new List<SelectOption>(); 
    List<SelectOption> selectedRegions = new List<SelectOption>();
    List<SelectOption> allAvailableRegions = new List<SelectOption>();
    List<SelectOption> availableBusinessUnits = new List<SelectOption>();
    List<SelectOption> availableLanguages = new List<SelectOption>();
    List<SelectOption> selectedBusinessUnits = new List<SelectOption>();
    List<SelectOption> allAvailableBusinessUnits = new List<SelectOption>();
    List<SelectOption> allAvailableLanguages = new List<SelectOption>();
    List<SelectOption> selectedLanguages = new List<SelectOption>();
    string passedpage;
    String[] countriesToRemove = new String[]{}; //Used to capture highlighted countries to be removed
    String[] smCountriesToAdd = new String[]{}; //Used to capture highlighted countries to add
    String[] regionsToRemove = new String[]{}; //Used to capture highlighted regions to be removed
    String[] smRegionsToAdd = new String[]{}; //Used to capture highlighted regions to add
    String[] smBusinessUnitsToAdd = new String[]{}; //Used to capture highlighted businessunit to add
    String[] businessunitsToRemove = new String[]{}; //Used to capture highlighted businessunits to be removed
    String[] smLanguagesToAdd = new String[]{}; //Used to capture highlighted businessunit to add
    String[] LanguagesToRemove = new String[]{}; //Used to capture highlighted businessunits to be removed
    
    public VFCntrlr_SalesMotionCountryConfig ()
    { 
        
    }
    
    public VFCntrlr_SalesMotionCountryConfig (ApexPages.StandardController controller)
    { 
        passedpage=ApexPages.currentPage().getParameters().get('page');
        System.debug('&&&passedpage ' + passedpage);
        //this.salesMotionSectionId = System.currentPageReference().getParameters().get('id');
        //Retrieves Account Plan information. This is initialized first to get information like Account ID
        //initializeAccntPlan();
        salesMotionPageSection = (Sales_Motion_Page_Section__c)controller.getRecord(); 
        if(passedpage=='country'){
            loadCountryDetails();
        }
        else if(passedpage=='region'){
            loadRegionDetails();
        }
        else if(passedpage=='businessunit'){
            loadBusinessUnitDetails();
        }
        else if(passedpage=='language'){
            loadLanguageDetails();
        }
    }    
    
    
   public void loadCountryDetails(){
       try {                
             
             
                //this.accntPlanName = accntPlanName = [SELECT Name FROM SFDC_Acct_Plan__c WHERE Id = :salesMotionSectionId].Name;
            salesMotionSectionId = salesMotionPageSection.Id;
            
            system.debug('Sales Motion Country page with Id   ' + salesMotionSectionId);
            
            initializeCountries();
            
            //Populate availableCountries with full list of available countries
            removeAllCountries();
            
             string countryListString = salesMotionPageSection.Country_List__c;
             if(countryListString != null && countryListString != ''){
                List<string> countryListTmp = countryListString.split(';');
                SelectOption sel;
                 for(string cl : countryListTmp){
                    sel = new SelectOption(cl,cl);
                    selectedCountries.add(sel);
                    smCountriesToAdd.add(cl);
                    system.debug('##################################    ' + sel.getValue() + '    ' + sel.getLabel());
                 }
                 //addCountries(); 
                 availableCountries = removeFromList(availableCountries, smCountriesToAdd );  
                 availableCountries.Sort();
             }
            
        }
        catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }
   }
   
   public void loadRegionDetails(){
       try {                
             
             
                //this.accntPlanName = accntPlanName = [SELECT Name FROM SFDC_Acct_Plan__c WHERE Id = :salesMotionSectionId].Name;
            salesMotionSectionId = salesMotionPageSection.Id;
            
            system.debug('Sales Motion Country page with Id   ' + salesMotionSectionId);
            
            initializeRegions();
            
            //Populate availableCountries with full list of available countries
            removeAllRegions();
            
             string regionListString = salesMotionPageSection.Region_List__c;
             if(regionListString != null && regionListString != ''){
                List<string> regionListTmp = regionListString.split(';');
                SelectOption sel;
                 for(string cl : regionListTmp){
                    sel = new SelectOption(cl,cl);
                    selectedRegions.add(sel);
                    smRegionsToAdd.add(cl);
                    system.debug('##################################    ' + sel.getValue() + '    ' + sel.getLabel());
                 }
                 //addCountries(); 
                 availableRegions = removeFromList(availableRegions, smRegionsToAdd );  
                 availableRegions.Sort();
             }
            
        }
        catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }
   }
    
    public void loadBusinessUnitDetails(){
       try {                
             
             
                //this.accntPlanName = accntPlanName = [SELECT Name FROM SFDC_Acct_Plan__c WHERE Id = :salesMotionSectionId].Name;
            salesMotionSectionId = salesMotionPageSection.Id;
            
            system.debug('Sales Motion Country page with Id   ' + salesMotionSectionId);
            
            initializeBusinessUnits();
            
            //Populate availableBusineeUnits with full list of available Busineess Unit
            removeAllBusinessUnits();
            
             string businessunitListString = salesMotionPageSection.Business_Unit_List__c;
             system.debug('##businessunitListString   ' + businessunitListString);
             if(businessunitListString != null && businessunitListString != ''){
                List<string> businessunitListTmp = businessunitListString.split(';');
                SelectOption sel;
                 for(string cl : businessunitListTmp){
                    sel = new SelectOption(cl,cl);
                    selectedBusinessUnits.add(sel);
                    smBusinessUnitsToAdd.add(cl);
                 }
                 availableBusinessUnits = removeFromList(availableBusinessUnits, smBusinessUnitsToAdd);  
                 availableBusinessUnits.Sort();
             }
            
        }
        catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }
   }
    
    public void loadLanguageDetails(){
       try {                
             
             
                //this.accntPlanName = accntPlanName = [SELECT Name FROM SFDC_Acct_Plan__c WHERE Id = :salesMotionSectionId].Name;
            salesMotionSectionId = salesMotionPageSection.Id;
            
            system.debug('Sales Motion Country page with Id   ' + salesMotionSectionId);
            
            initializeLanguages();
            
            //Populate availableBusineeUnits with full list of available Busineess Unit
            removeAllLanguages();
            
             string languageListString = salesMotionPageSection.Language_List__c;
             
             if(languageListString != null && languageListString != ''){
                List<string> languageListTmp = languageListString.split(';');
                SelectOption sel;
                 for(string cl : languageListTmp){
                    sel = new SelectOption(cl,cl);
                    selectedLanguages.add(sel);
                    smLanguagesToAdd.add(cl);
                 }
                 availableLanguages = removeFromList(availableLanguages, smLanguagesToAdd);  
                 availableLanguages.Sort();
             }
            
        }
        catch(Exception e) {
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }
   }
    
    public List<SelectOption> getallAvailableCountries(){
        return allAvailableCountries;
    }
    
    public List<SelectOption> getallAvailableRegions(){
        return allAvailableRegions;
    }
    public List<SelectOption> getallAvailableBusinessUnits(){
        return allAvailableBusinessUnits;
    }
    public List<SelectOption> getallAvailableLanguages(){
        return allAvailableLanguages;
    }
    
    public String getSalesMotionSectionId(){
        return salesMotionSectionId;
    }
    
    
    public void initializeCountries(){       
        try
        {

            allAvailableCountries.clear();
            List<Sales_Motion_Country__c> lstsmCountry=new List<Sales_Motion_Country__c>();
            lstsmCountry=[Select id,Name from Sales_Motion_Country__c order by Name];
            for(Sales_Motion_Country__c smcountry:lstsmCountry){
                allAvailableCountries.add(new SelectOption(smcountry.Name,smcountry.Name));
            }
            /*Schema.DescribeFieldResult countryField = Sales_Motion_Page_Section__c.Country__c.getDescribe();
            
            List<Schema.PicklistEntry> pickList = countryField .getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailableCountries.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }*/  
        }   
        catch(Exception e)
        {
            System.debug('DEBUG:  Exception while retrieving Countries - ' + e.getMessage()); 
            //throw new dellUtil.DellException('There was a problem initializing Countries. Please contact the administrators.' + ' (' + e.getMessage() + ')'); 
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Countries. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    
    public void initializeRegions()
    {       
        try
        {

            allAvailableRegions.clear();
            
            Schema.DescribeFieldResult regionField = Sales_Motion_Page_Section__c.Region__c.getDescribe();
            
            List<Schema.PicklistEntry> pickList = regionField.getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailableRegions.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }  
        }   
        catch(Exception e)
        {
            System.debug('DEBUG:  Exception while retrieving Countries - ' + e.getMessage()); 
            //throw new dellUtil.DellException('There was a problem initializing Countries. Please contact the administrators.' + ' (' + e.getMessage() + ')'); 
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Countries. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    
    public void initializeBusinessUnits()
    {       
        try
        {

            allAvailableBusinessUnits.clear();
            
            Schema.DescribeFieldResult businessunitField = Sales_Motion_Page_Section__c.Business_Unit__c.getDescribe();
            
            List<Schema.PicklistEntry> pickList = businessunitField.getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailableBusinessUnits.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }  
        }   
        catch(Exception e)
        {
            System.debug('DEBUG:  Exception while retrieving Countries - ' + e.getMessage()); 
            //throw new dellUtil.DellException('There was a problem initializing Countries. Please contact the administrators.' + ' (' + e.getMessage() + ')'); 
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Countries. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    
     public void initializeLanguages()
    {       
        try
        {

            allAvailableLanguages.clear();
            
            Schema.DescribeFieldResult languageField = Sales_Motion_Page_Section__c.Language__c.getDescribe();
            
            List<Schema.PicklistEntry> pickList = languageField.getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                allAvailableLanguages.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }  
        }   
        catch(Exception e)
        {
            System.debug('DEBUG:  Exception while retrieving Countries - ' + e.getMessage()); 
            //throw new dellUtil.DellException('There was a problem initializing Countries. Please contact the administrators.' + ' (' + e.getMessage() + ')'); 
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Countries. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    
    public String[] getSmCountriesToAdd()
    {
        return smCountriesToAdd;
    }

    public String[] getCountriesToRemove() 
    {
        return countriesToRemove;
    }
    
    //On submit, capture the selected countries to add
    public void setsmCountriesToAdd(String[] countriesSelected)
    {
        smCountriesToAdd = countriesSelected;
    }
    
    //On submit, capture the selected countries to remove
    public void  setCountriesToRemove(String[] countriesSelected)
    {
        countriesToRemove = countriesSelected;        
    }  
    
    public String[] getSmRegionsToAdd()
    {
        return SmRegionsToAdd;
    }

    public String[] getRegionsToRemove() 
    {
        return regionsToRemove;
    }
    
    //On submit, capture the selected regions to add
    public void setsmRegionsToAdd(String[] regionsSelected)
    {
        smRegionsToAdd = regionsSelected;
    }
    
    //On submit, capture the selected regions to remove
    public void  setRegionsToRemove(String[] regionsSelected)
    {
        regionsToRemove = regionsSelected;        
    }  
    public String[] getsmBusinessUnitsToAdd()
    {
        return smBusinessUnitsToAdd;
    }
     //On submit, capture the selected businessunits to add
    public void setsmBusinessUnitsToAdd(String[] businessUnitSelected)
    {
        smBusinessUnitsToAdd = businessUnitSelected;
    }
    
    public String[] getBusinessunitsToRemove() 
    {
        return businessunitsToRemove;
    }
    //On submit, capture the selected businessunits to remove
    public void  setBusinessunitsToRemove(String[] businessunitsSelected)
    {
        businessunitsToRemove = businessunitsSelected;        
    }   
    
       public String[] getsmlanguagesToAdd()
    {
        return smLanguagesToAdd;
    }
     //On submit, capture the selected languages to add
    public void setsmLanguagesToAdd(String[] languagesSelected)
    {
        smLanguagesToAdd = languagesSelected;
    }
    
    public String[] getLanguagesToRemove() 
    {
        return languagesToRemove;
    }
    //On submit, capture the selected languages to remove
    public void  setLanguagesToRemove(String[] languagesSelected)
    {
        LanguagesToRemove = languagesSelected;        
    }   
    
    
    //Remove selected countries to add from available countries list, add to selected countries list
    public void addCountries()
    {
        selectedCountries = addToList(selectedCountries, smCountriesToAdd  );
        availableCountries = removeFromList(availableCountries, smCountriesToAdd );  
        availableCountries.Sort();  
    }
    
    //Clear available countries list, reinitialize selected countries list with full list
    public void addAllCountries()
    {
        availableCountries.clear();
        selectedCountries.clear();
        selectedCountries.addAll(allAvailableCountries);
    }

    //Remove selected countries to remove from selected countries list, add to available countries list
    public void removeCountries()
    {
        availableCountries = addToList(availableCountries, countriesToRemove );
        selectedCountries = removeFromList(selectedCountries, countriesToRemove );
        availableCountries.Sort(); 
    }
    
    //Clear selected countries list, reinitialize available countries list with full list
    public void removeAllCountries()
    {
        availableCountries.clear();
        selectedCountries.clear();
        availableCountries.addAll(allAvailableCountries);
    }
    
    
    //Remove selected regions to add from available regions list, add to selected regions list
    public void addRegions()
    {
        selectedRegions = addToList(selectedRegions, smRegionsToAdd  );
        availableRegions = removeFromList(availableRegions, smRegionsToAdd );  
        availableRegions.Sort();  
    }
    
    //Clear available regions list, reinitialize selected regions list with full list
    public void addAllRegions()
    {
        availableRegions.clear();
        selectedRegions.clear();
        selectedRegions.addAll(allAvailableRegions);
    }

    //Remove selected regions to remove from selected regions list, add to available regions list
    public void removeRegions()
    {
        availableRegions = addToList(availableRegions, regionsToRemove );
        selectedRegions = removeFromList(selectedRegions, regionsToRemove );
        availableRegions.Sort(); 
    }
    
    
    //Clear selected regions list, reinitialize available region list with full list
    public void removeAllRegions()
    {
        availableRegions.clear();
        selectedRegions.clear();
        availableRegions.addAll(allAvailableRegions);
    }
    
    //Remove selected Business Units to add from available busines unit list, add to selected business unit list
    public void addBusinessUnits()
    {
        selectedBusinessUnits = addToList(selectedBusinessUnits, smBusinessUnitsToAdd  );
        availableBusinessUnits = removeFromList(availableBusinessUnits, smBusinessUnitsToAdd );  
        availableBusinessUnits.Sort();  
    }
    
    //Clear available businessunit list, reinitialize selected businessunit list with full list
    public void addAllBusinessUnits()
    {
        availableBusinessUnits.clear();
        selectedBusinessUnits.clear();
        selectedBusinessUnits.addAll(allAvailableBusinessUnits);
    }

    //Remove selected businessunits to remove from selected businessunit list, add to available businessunit list
    public void removeBusinessUnits()
    {
        availableBusinessUnits = addToList(availableBusinessUnits, businessunitsToRemove );
        selectedBusinessUnits = removeFromList(selectedBusinessUnits, businessunitsToRemove );
        availableBusinessUnits.Sort(); 
    }
    
    //Clear selected businessunit list, reinitialize available businessunit list with full list
    public void removeAllBusinessUnits()
    {
        availableBusinessUnits.clear();
        selectedBusinessUnits.clear();
        availableBusinessUnits.addAll(allAvailableBusinessUnits);
    }
    
     //Remove selected Languages to add from available languages, add to selected languages list
    public void addLanguages()
    {
        selectedLanguages = addToList(selectedLanguages, smLanguagesToAdd);
        availableLanguages = removeFromList(availableLanguages, smLanguagesToAdd);  
        availableLanguages.Sort();  
    }
    
    //Clear available languages list, reinitialize selected language list with full list
    public void addAllLanguages()
    {
        availableLanguages.clear();
        selectedLanguages.clear();
        selectedLanguages.addAll(allAvailableLanguages);
    }

    //Remove selected languages to remove from selected languages list, add to available languages list
    public void removeLanguages()
    {
        availableLanguages = addToList(availableLanguages, languagesToRemove);
        selectedLanguages = removeFromList(selectedLanguages, languagesToRemove);
        availableLanguages.Sort(); 
    }
    
     //Clear selected language list, reinitialize available language list with full list
    public void removeAllLanguages()
    {
        availableLanguages.clear();
        selectedLanguages.clear();
        availableLanguages.addAll(allAvailableLanguages);
    }
    public string getpassedpage(){
        return passedpage;
    }
    public List<SelectOption> getAvailableCountries() {
        return availableCountries ;
    }

    public List<SelectOption> getAvailableRegions() {
        return availableRegions ;
    } 
    public List<SelectOption> getAvailableBusinessUnits() {
        return availableBusinessUnits ;
    }  
    public List<SelectOption> getAvailableLanguages() {
        return availableLanguages ;
    }     
    public List<SelectOption> getSelectedCountries() {
        return selectedCountries ;
    }
    public List<SelectOption> getSelectedRegions() {
        return selectedRegions ;
    }
    public List<SelectOption> getSelectedBusinessUnits() {
        return selectedBusinessunits ;
    }
    public List<SelectOption> getSelectedLanguages() {
        return selectedLanguages ;
    }
    //Generic function to remove items in <theCountries> from <theList>
    public List<SelectOption> removeFromList(List<SelectOption> theList, String[] theCountries)
    {
        boolean toRemove = false;
        
        Map<String, String> tempTheCountries = new Map<String, String> {};
        
        for (String role : theCountries)
        {
            tempTheCountries.put(role,role);
        }        
       
        List<SelectOption> newList = new List<SelectOption>();
        for(SelectOption listItem: theList)
        {
            if(!tempTheCountries.containsKey(listItem.getValue()))
            {
                newList.add(new SelectOption(listItem.getValue(), listItem.getLabel()));
            }            

        }
        newList.Sort();
        
        return newList;
    }
    
    //Generic function to add items in <theCountries> to <theList>
    public List<SelectOption> addToList(List<SelectOption> theList, String[] theCountries)
    {
        boolean toAdd = true;
        
        List<SelectOption> newList = new List<SelectOption>();
        newList.addAll(theList);
        for(String country_v : theCountries)
        {
            newList.add(new SelectOption(country_v, country_v));   
        }       
        return newList;
    }
     
    public PageReference saveCountries(){
        system.debug('################################# COMES HERE IN SAVE    ' + salesMotionPageSection.Id);
        string countryList = '';
        Integer i = 0;
        
        if(selectedCountries != null && selectedCountries.size() > 0){
            for(SelectOption selCountry : selectedCountries ){
                if(i == 0)
                    countryList = selCountry.getValue() + ';' ;
                else
                    countryList = countryList + selCountry.getValue() +  ';' ;
                    
                i++;        
            }
            salesMotionPageSection.Country_List__c = countryList;
                
        } else { 
            salesMotionPageSection.Country_List__c = null;
        }
        system.debug('#################################       ' + salesMotionPageSection.Country_List__c);
        system.debug('#################################       ' + countryList);
        update salesMotionPageSection;
        
        return PageUtils.redirect('/' + salesMotionPageSection.Id); 
    }
    
    public PageReference saveRegions(){
        string regionList = '';
        Integer i = 0;
        
        if(selectedRegions != null && selectedRegions.size() > 0){
            for(SelectOption selRegion : selectedRegions ){
                if(i == 0)
                    regionList = selRegion.getValue() + ';' ;
                else
                    regionList = regionList + selRegion.getValue() +  ';' ;
                    
                i++;        
            }
            salesMotionPageSection.Region_List__c = regionList;
                
        } else { 
            salesMotionPageSection.Region_List__c = null;
        }
        
        update salesMotionPageSection;
        
        return PageUtils.redirect('/' + salesMotionPageSection.Id); 
    }
    
    public PageReference saveBusinessUnits(){
        string businessunitList = '';
        Integer i = 0;
        
        if(selectedBusinessUnits != null && selectedBusinessUnits.size() > 0){
            for(SelectOption selBusinessUnit : selectedBusinessUnits ){
                if(i == 0)
                    businessunitList = selBusinessUnit.getValue() + ';' ;
                else
                    businessunitList = businessunitList + selBusinessUnit.getValue() +  ';' ;
                    
                i++;        
            }
            salesMotionPageSection.Business_Unit_List__c = businessunitList;
                
        } else { 
            salesMotionPageSection.Business_Unit_List__c = null;
        }
        
        update salesMotionPageSection;
        
        return PageUtils.redirect('/' + salesMotionPageSection.Id); 
    }
    
    public PageReference saveLanguages(){
        string languageList = '';
        Integer i = 0;
        
        if(selectedLanguages != null && selectedLanguages.size() > 0){
            for(SelectOption selLanguages : selectedLanguages ){
                if(i == 0)
                    languageList = selLanguages.getValue() + ';' ;
                else
                    languageList = languageList + selLanguages.getValue() +  ';' ;
                    
                i++;        
            }
            salesMotionPageSection.Language_List__c = languageList;
                
        } else { 
            salesMotionPageSection.Language_List__c = null;
        }
        
        update salesMotionPageSection;
        
        return PageUtils.redirect('/' + salesMotionPageSection.Id); 
    }
    
    public PageReference redirectBack(){
        
        return PageUtils.redirect('/' + salesMotionPageSection.Id);
        
    }
      
     
}