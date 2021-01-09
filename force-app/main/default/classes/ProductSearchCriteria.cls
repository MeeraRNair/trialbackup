/*****************************************
 Vf Page Name : ProductSearchCriteria
 Class Name : ProductSearchCriteria
 *****************************************/
public without sharing class ProductSearchCriteria{
     /****************************  
     Constuctor
    ******************************/
    public ProductSearchCriteria(ApexPages.StandardController controller) {
         Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        ProductCriteriaId = ApexPages.currentPage().getParameters().get('pid'); 
        CPRid = ApexPages.currentPage().getParameters().get('id');
        system.debug('kkkkkkkkkkkkkkkkkkkkkkkkkk'+CPRid );
        type = ApexPages.currentPage().getParameters().get('type');
        
    }
    public id  ProductCriteriaId {get;set;}
    public boolean showKeyword {get;set;}
    public boolean errorbool {get ; set ;}
    public string CPRid {get ; set ;}
    public boolean show{get;set;}
    public string type{get;set;}
    public boolean datetest{get;set;}
    public Deal_Program__c dpg{get;set;}
    public list<String> prodList { get; set; }
    public boolean showSearchResults{get;set;}
    public string SelectedProduct{get;set;}
    public List<SelectOption> options {get;set;}
    public List<String> listStrings{get;set;} 
    public string searchString { get; set; }
    public date datesearch{get;set;}
    public Date datacopertina {get;set;} 
    public string optionsSelected {get;set;} 
    public string optionsSelectedSearch {get;set;}
    public set<String> ProdFamily  { get; set; }
    public List<SelectOption> optionsPicklist  {get;set;}
    Map<String, Schema.SObjectField> objectFields{get;set;}
    public Custom_Products__c Custprod {get ; set ;}
    public boolean editopt {get ; set ;}
    public boolean editkeyopt {get ; set ;}
    public List<selectoption> optionschecked {get ; set ;}
    public list<string> prodList1 {get ; set ;}
    public boolean addmorebutton {get ; set ;}
    public Set<String> distinctSet {get ; set ;}
    public List<Custom_Products__c>  custprodts {get ; set ;}
    
    /*********************************
    // Method execute on page load
    **********************************/
    public pagereference onPageLoad()         
    {   
        showSearchResults = false;
        editopt = false;
        editkeyopt = false;
        addmore = false;
        addmorebutton = false;
        showKeyword = false;
        datetest = false;
        options = new List<SelectOption>();
        prodList1 = new List<string>();
        prodList =new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        objectFields = SchemaMap.get('Product2').getDescribe().fields.getMap();
        Map<string,string> mapforedit = new map<string,string>();
        optionsPicklist = new List<SelectOption>();
        List<SelectOption> optionsPicklist_sort = new List<SelectOption>();
        List<String> aList = new List<String>();
        
        

        for(String field: objectFields.keySet()) 
        {
            if(field != 'Detailed_Description__c' &&  field != 'DBM__c' && field != 'Prod_ID__c')
            {
               aList.add(objectFields.get(field).getDescribe().getLabel());
               mapforedit.put(objectFields.get(field).getDescribe().getLabel(),field); 
            }
        }
        
        // To display the picklist values in sorting order.
        aList.sort();
        for(String st : aList){
           //optionsPicklist.add(new SelectOption(mapforedit.get(st),st));
           optionsPicklist.add(new SelectOption(mapforedit.get(st),st));
        }
        
        //For edit 
       if(null != CPRid && CPRid != '')
        {
            Custprod = new Custom_Products__c();
            Custprod = [select id,Include__c,Exclude__c,Filter_Type__c,Criteria__c,Deal_Program__c From Custom_Products__c Where id =: CPRid];
            
            if(Custprod.Include__c)   {    type = 'Include';    }
            if(Custprod.Exclude__c)   {    type = 'Exclude';    }

            if(Custprod.Criteria__c == null && Custprod.Filter_Type__c == null){ //Redirecting to standard Edit page 
                PageReference editpage = new PageReference('/'+CPRid+'/e?nooverride=1&retURL=/'+Custprod.Deal_Program__c);              
                return editpage;                

            }else{
            
            
            ProductCriteriaId = Custprod.Deal_Program__c;
            optionsSelected ='';
            editopt = true;
            editkeyopt = true;
            addmore = false;
            addmorebutton = true;                       
            optionsSelected = mapforedit.get(Custprod.Filter_Type__c);
            
            if(Custprod.Criteria__c == null && Custprod.Filter_Type__c != null){
                   delete Custprod;
                return null;
            }
            Set<string> optionsforedit = new Set<string>();
            system.debug(':::::::::::::::::::'+optionsSelected);
            searchString ='';
            optionschecked = new List<selectoption>();
            fetchResults();  
            String st= Custprod.Criteria__c ;
            st = st.replace(' ','&nbsp;').trim();
            prodList1.addAll(st.split('&nbsp;;')); 

            system.debug('kkkkkkkkkkkkkkkkkkkkkkkkkk'+options);
             for(string s: prodList1){
                 for(integer i=0;i<options.Size();i++)
                    {      //s =  s.replace('&nbsp;',' ').trim();
                           if(options[i].getValue() == s)
                           {
                                   options.remove(i);
                                   
                           }
                                   
                    }
                    SelectOption sel = new SelectOption(s.replace(' ','&nbsp;').trim(),s.replace(' ','&nbsp;').trim());
                            sel.setEscapeItem(false) ;
                            optionschecked.add(sel);
                   // optionschecked.add(new SelectOption(s,s));                   
                }
             
            //keywordNull();
            showSearchResults = false;
            errorbool = false;
         system.debug('kkkkkkkkkkkkkkkkkkkkkkkkkk'+optionschecked);
         }
        
       }
       return null;
    }
    /******************************************
         Retrieving records by dynamic query 
    *******************************************/
    
    public Set<String> getDistinct(string optionsSelected) 
    {    
         distinctSet = new Set<String>();
        try{
            errorbool = true;
            distinctSet.clear();
            string searchquery ;
            string strType = String.valueOf(objectFields.get(optionsSelected).getDescribe().getType()) ;
            system.debug('strType****'+strType);
            if(optionsSelected != '')
            { 
                if(strType == 'BOOLEAN')
                {
                    //setEscapeItem(options.add(new SelectOption('Tr  ue','Tr  ue')));
                    SelectOption sel = new SelectOption('true','true');
                    sel.setEscapeItem(false) ;
                    options.add(sel);
                    options.add(new SelectOption('false','false'));
                    distinctSet.add('true');
                    distinctSet.add('false');
                     removedups();
                    return distinctSet;
                }
                if((strType == 'MULTIPICKLIST' || strType == 'PICKLIST') && (searchString =='' || searchString == null))
                {
                    Schema.DescribeFieldResult fieldResult = objectFields.get(optionsSelected).getDescribe();
                    system.debug('fieldResult'+fieldResult);
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
                    for(Schema.PicklistEntry f : ple)
                    {
                      options.add(new SelectOption(f.getLabel(), f.getValue()));
                      distinctSet.add(f.getValue());
                    }                
                  
                     removedups();                          
                       
                    return distinctSet;
                }
                if(searchString != null && searchString != '' && !searchString.ISNUMERIC() && (strType == 'ID' || strType == 'NUMBER' || strType == 'RecordType')){
                   showSearchResults = false;
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please enter only numbers for keyword search on ' + objectFields.get(optionsSelected ).getDescribe().getLabel()));
                   return null;
                }
                    
                   
                searchquery = 'Select '+ optionsSelected +' from product2 where IsActive = true and ' + optionsSelected +' != null ';
                if(searchString != '' && strType != ''  && (strType == 'STRING' || strType == 'TEXTAREA' || strType == 'PICKLIST'))
                {searchquery  = searchquery  + ' and ' + optionsSelected + ' like \'%'+searchString+'%\'';
                 system.debug('searchquery'+searchquery);}
                else if(searchString != '' && strType != ''  && (strType == 'ID' ))
                    searchquery  = searchquery  + ' and ' + optionsSelected + ' = \''+ searchString + '\'';               
                else if(String.valueOf(datesearch) != '' &&  String.valueOf(datesearch) != null  && strType != ''  && (strType == 'DATE' || strType == 'DATETIME'))
                {  
                    searchquery  = searchquery  + ' and ' + optionsSelected + ' >= '+ String.valueOf(datesearch) + 'T00:00:00Z' + ' and ' + optionsSelected + ' <= ' + String.valueOf(datesearch) + 'T23:59:00Z';
                    system.debug('*****searchdate'+searchquery); 
                }
                else if(searchString != '' && strType != ''  && (strType == 'MULTIPICKLIST'))
                    searchquery  = searchquery  + ' and ' + optionsSelected + ' includes (\''+ searchString + '\')'; 
                
                //else if(searchString != '' && strType != ''  && (strType == 'MULTIPICKLIST'))
                //    searchquery  = searchquery  + ' and ' + optionsSelected + ' includes (\''+ searchString + '\')';     
                        
                else if (searchString != '')
                    searchquery  = searchquery  + ' and ' + optionsSelected + ' = '+ searchString ;
                
                if(strType != 'MULTIPICKLIST' ) 
                    searchquery = searchquery + ' order by ' + optionsSelected ;     
                
                
                List<Product2> prd= Database.query(searchquery);
               
                Integer i = 1;
                if(prd != null && prd.size()>0){
                    for (Product2 pr : prd)  
                    {
                        if(distinctSet.add(String.valueOf(pr.get(optionsSelected))) && distinctSet.size()<1000){
                            String n = String.valueOf(pr.get(optionsSelected));
                            n = n.replace(' ','&nbsp;').trim();
                            
                            SelectOption sel = new SelectOption(n,n);
                            sel.setEscapeItem(false) ;
                            options.add(sel);
                         }  
                        if( distinctSet.size() > 1000)
                        {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The search returned more than the maximum number of rows (1000). Please refine your search criteria using Keyword.'));
                        }
                    }    
                }
             else
            {
                showSearchResults = false;    
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'No search results.'));
            }
              if(options.size() == 0 ){
                showSearchResults = false;    
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'No search results.'));
            }
                
          }
        }
        catch(Exception ex)
        {
           String st = ex.getMessage();
           if(st.contains('expecting a colon,') ||  st.contains('unexpected token:')){
                   showSearchResults = false;
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please enter only numbers for keyword search on ' + objectFields.get(optionsSelected ).getDescribe().getLabel()));

           }   
           else {   
                system.debug('exception message'+ex.getMessage());
                ApexPages.addMessages(ex);
            }
        }
         
         if(options.size() > 0){
        for(string s: prodList1){
                 for(integer i=0;i<options.Size();i++)
                    {
                          s =  s.replace('&nbsp;',' ').trim();
                           if(options[i].getValue() == s)
                           {
                                   options.remove(i);
                                   
                           }
                                   
                    }
                                     
                }
            showSearchResults = true;
            } 
        else
            showSearchResults = false;  
        return distinctSet;
    }
    
    public void removedups(){
    if(options.size() > 0){
            for(string s: prodList1){
                 for(integer i=0;i<options.Size();i++)
                    {
                          s =  s.replace('&nbsp;',' ').trim();
                           if(options[i].getValue() == s)
                           {
                                   options.remove(i);
                                   
                           }
                                   
                    }
                                     
                }
            showSearchResults = true;
            } 
        else
            showSearchResults = false; 
    
    }
    /************************************************
      Assign null to keywod on change of  Picklist
    *************************************************/
    public void keywordNull()
    {
          string strType = String.valueOf(objectFields.get(optionsSelected).getDescribe().getType()) ;
         if(strType == 'BOOLEAN')
                showKeyword = true;
         else
            showKeyword = false;       
               
         if(strType == 'DATE' || strType == 'DATETIME')
             datetest = true;           
            else  datetest = false;
            
       searchString = '';
                   
    }
    /************************************************
        Search functionality
    *************************************************/
    
    Public pagereference fetchResults()
    {
        try{
            
              
            options = new List<SelectOption>();
            prodFamily = new Set<String>();
            prodFamily.clear();
            prodFamily = getDistinct(optionsSelected) ;
            system.debug(':::::::::::::id:::::;'+cprid );
             system.debug(':::::::::::::id:::::;'+optionsSelected );
            optionsSelectedSearch = optionsSelected;    //To disable save button when the Filter Type is changed.
            boolean excludebool = false;
            boolean includebool = false;
            if(null == Custprod)
                 addmore = true;
            //showing existing values of the selected type 
            custprodts = new List<Custom_Products__c>();
            if(cprid == null){
            
                if(type == 'Include')
                    includebool = true;
                if(type == 'Exclude')
                    excludebool = true;
                    
                 custprodts = [select id,Filter_Type__c,Criteria__c,Exclude__c,Include__c from Custom_Products__c WHERE Deal_Program__c =: ProductCriteriaId AND Exclude__c =: excludebool AND Include__c=: includebool AND Filter_Type__c =: String.valueOf(objectFields.get(optionsSelected).getDescribe().getLabel())];
                system.debug('****'+custprodts);     
                prodList1 = new list<string>();
                 optionschecked = new list<selectoption>();
                 
                 if(custprodts.size() != 0){
                 
                     //prodList1.addAll(custprodts[0].Criteria__c.split(',').replace('&nbsp;',' ')); 
                      String st= custprodts[0].Criteria__c ;
                      st=st.replace(' ','&nbsp;').trim();
                      prodList1.addAll(st.split('&nbsp;;'));
                        system.debug('****prodList1'+prodList1);                 
                 for(string s: prodList1)
                 {
                     for(integer i=0;i<options.Size();i++)
                        {
                             system.debug('options[i].getValue() ' + options[i].getValue()  +'==' +   s);
                               //s =  s.replace('&nbsp;',' ').trim();
                               if(options[i].getValue() == s)
                               {
                                       options.remove(i);
                                       
                               }
                                       
                        }
                        SelectOption sel = new SelectOption(s.replace(' ','&nbsp;'),s.replace(' ','&nbsp;'));
                            sel.setEscapeItem(false) ;
                            optionschecked.add(sel);
                    }  
                 }
            }
            
          if(options.size() > 0)
         
              showSearchResults = true; 
          else
            showSearchResults = false;  
            
        }
        catch(Exception ex) 
        {
            system.debug('exception message'+ex.getMessage());
            ApexPages.addMessages(ex); 
            
        }
        
        
        return null;
    }
    /******************************************
      Close functionality
    *******************************************/
    public pagereference close()
    {
        PageReference parentPage = new PageReference('/' + ProductCriteriaId);
        parentPage.setRedirect(true);
        return parentPage;
    }
    /*******************************
       Save functionality 
    ********************************/
    public PageReference saveFunction() 
    {
            errorbool = true;
            searchString = '';
            if(null == Custprod)//This line is to check saving is for new record or to update existing
            {        
                String strProdCriteria = '';
                Savepoint sp = Database.setSavepoint();
            try
           {
           
               if(custprodts.size() != 0){   //This if combines the existing and new options if record is exist with the selected filter type
                   prodList.addall(prodList1);
                   if(prodList.size() == 0){
                     delete custprodts;
                     fetchResults();  
                     return null;
                    } 
               }
                if(prodList.size()>0 ){//This will validate atlease one option should be checked 
                    if(custprodts.size() == 0){
                        system.debug('prodList value111'+prodList.size());
                        for(String pr: prodList)
                        {
                            strProdCriteria = strProdCriteria  + pr.replace('&nbsp;',' ').trim() + ' ;';
                        }
                        strProdCriteria = strProdCriteria.removeEnd(' ;');
                        List<Custom_Products__c > dealPrd = new List<Custom_Products__c >();
                        system.debug('::::::::::::insert'+strProdCriteria );
                        Custom_Products__c  dealPrd1 = new Custom_Products__c ();
                        {
                            system.debug('**ProductCriteriaId  ***'+ProductCriteriaId  );
                            dealPrd1.Deal_Program__c = ProductCriteriaId  ;
                            dealPrd1.Filter_Type__c = String.valueOf(objectFields.get(optionsSelected).getDescribe().getLabel()) ;
                            system.debug('****'+dealPrd1.Filter_Type__c);
                            dealPrd1.Criteria__c = strProdCriteria ;
                            if(type=='Include'){
                                dealPrd1.Include__c = true; 
                            }
                            else
                            {
                                dealPrd1.Exclude__c= true;
                            }
                            dealPrd.add(dealPrd1);   
                        }
                        insert dealPrd;
                        system.debug('::::::::::::insert'+dealPrd);
                       
                        showSearchResults = false;
                        onPageLoad();
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Criteria saved successfully'));
                        return null;
                    }else{    //This else block will excute for update 
                        system.debug('hiiiiii I am in update');
                        custprodts[0].Criteria__c = '';                   
                        for(string st : prodList)
                        {
                            custprodts[0].Criteria__c +=  st.replace('&nbsp;',' ').trim() +' ;';
                        }
                        custprodts[0].Criteria__c = custprodts[0].Criteria__c.removeEnd(' ;');
                        update custprodts[0];
                        
                        showSearchResults = false;
                        onPageLoad();
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Criteria saved successfully'));
                       return null;
                    }
                }
                else 
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Kindly select critria and save'));
                    return null;
                } 
            }   
            catch(Exception ex)
            {
                system.debug('exception message'+ex.getMessage());
                ApexPages.addMessages(ex);
                Database.rollback( sp );
            }
                return null;
            } 
            //Update record in Edit functionality
            else{
            
                system.debug('cccccccccccc'+prodList);
                Custprod.Criteria__c = '';
                    prodList.addall(prodList1);                                    
                    for(string st : prodList)
                    {
                        Custprod.Criteria__c += st.replace('&nbsp;',' ').trim() +' ;';
                    }
                    Custprod.Criteria__c = Custprod.Criteria__c.removeend(' ;');
                    update Custprod;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Criteria saved successfully'));
                    System.debug('hellooooo');
                    
                    
                    showSearchResults = false; 
                                              
                    onPageLoad();
                    errorbool = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Criteria saved successfully'));
                    system.debug('byyy');
                    return null;
                
            }
       
        //return null;
     } 
     
/****ADD MORE ***/

    public boolean addmore {get ; set ;}
    public void addmoreoption(){
    errorbool = true;
    if( distinctSet.size() > 1000)
     {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The search returned more than the maximum number of rows (1000). Please refine your search criteria using Keyword.'));
     }
        showSearchResults = true;
        addmore = true;
       editkeyopt = false;
       //editkeyopt = true;
        addmorebutton = false;
    }
     
     
     
}