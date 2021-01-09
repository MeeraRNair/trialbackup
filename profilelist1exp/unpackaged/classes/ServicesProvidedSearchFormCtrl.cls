/*
* Author   : Krishnamoorthi
* Purpose  : Controller extension for the VF page ServicesProvidedSearchForm.
*        
* Revision  Ref Number  Release No  Date            Modified By     Description
* --------  ----------  ----------  -----------     ------------    -----------
* 1.0       CR 12482    R16.12      16-Dec-2015     Krishnamoorthi  Created.
* 1.1       CR 16043    FY19-0802   27-June-2018    Naga            Code cleanup for reducing the usage of Apex code.
*/
 public class ServicesProvidedSearchFormCtrl {

    //Page field variables
    public String strBrandDesc {get; set;}
    public String strProductGroup {get; set;}
    public String strProductDesc {get; set;}
    public String strProductLineDesc {get; set;}   

    //Pagination variables
    public Boolean hasNext {get; private set;}
    public Boolean hasPrevious {get; private set;}
    public integer currentPage {get; private set;}
    public integer lastPage {get; private set;}
        
    public Boolean colCheck {get; set;}
    public Boolean displaySearch {get; set;}

    //Class variables
    public string acctId;
    public List<productWrapper> productListWrap = new List<productWrapper>();
    public Set<String> checkedProducts = new Set<String>();
    public String productQuery {get;set;}
    public List<Product2> prodList;
    public Integer PAGE_SIZE = 10; 
    public List <Services_Provided__c> spInsertList = new List <Services_Provided__c>();
    public Set<Id> existingProductIdSet = new Set<Id>();

    Public ApexPages.StandardSetController setCon{get;set;}

    public ServicesProvidedSearchFormCtrl(ApexPages.StandardSetController stdSetController) {
        colCheck = false;
        displaySearch = false;
        acctId = ApexPages.currentPage().getParameters().get('id');
    }

    //Save function
    public PageReference Save(){
        PageReference retUrl = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + acctId);
        for(productWrapper p : productListWrap){
            if(p.prodCheck == TRUE)
                checkedProducts.add(p.custProd.Id);
            if(p.prodCheck == FALSE)
                checkedProducts.remove(p.custProd.Id);
        }
            spInsertList.clear();     
        for(String prodId : checkedProducts){
            spInsertList.add(new Services_Provided__c(Account__c = acctId,  Services_Product__c = prodId));
        }
        try{
            if(spInsertList == null || spInsertList.isEmpty()){
                //Display page message if user not select any Product and hit Save
                PageUtils.addInfo('No Services Product have been selected. To continue, please select one or more Services Product and click the "Save" button, or click "Cancel" to return to the Account detail page.');
                return null;    
            } else {
                //Insert Services Provided Object
                insert spInsertList;
            }
        }
        catch(DMLException e){
            PageUtils.addError('Line ' + e.getLineNumber() + ': ' + e.getMessage()); 
            return null;
        }
        return retUrl;
    }

    //Search method
    public PageReference doSearch(){
        displaySearch = true;
        if(productListWrap != null)
            productListWrap.clear();
        if(checkedProducts != null)
            checkedProducts.clear();
        //To exclude already selected Products and to avoid duplicate Product record selection
        for(Services_Provided__c SP : [SELECT Id, Account__c, Services_Product__c, Services_Product__r.Id FROM Services_Provided__c WHERE Account__c =: acctId]) {
            if(SP.Services_Product__c != null) {
                existingProductIdSet.add(SP.Services_Product__r.Id);
            }
        }    
        if(strBrandDesc == '' && strProductGroup == '' && strProductDesc == '' && strProductLineDesc == ''){
            displaySearch = false;
            //Prompt user to enter the field value for search
            PageUtils.addError('Please enter any of the fields and search again.');
        }
        else{
            productQuery = 'SELECT Id, Name, ProductCode, Description, Product_Line_Desc__c, Family FROM Product2 WHERE IsActive = True AND Family = \'Services\' AND Id NOT IN :existingProductIdSet';       
            if(strBrandDesc != ''){
                productQuery += ' AND Name LIKE \'%' + strBrandDesc + '%\''; 
            }    
            if(strProductGroup != ''){
                productQuery += ' AND ProductCode LIKE \'%' + strProductGroup + '%\'';
            }    
            if(strProductDesc != ''){
                productQuery += ' AND Description LIKE \'%' + strProductDesc + '%\'';
            }
            if(strProductLineDesc != ''){
                productQuery += ' AND Product_Line_Desc__c LIKE \'%' + strProductLineDesc + '%\'';
            }
            if(productQuery != null){
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(productQuery));
                if(setCon.getResultSize()>0){
                    setCon.setPageSize(PAGE_SIZE);
                    setCon.last();                                     
                    lastPage =  setCon.getPageNumber(); 
                    setCon.first();    
                    currentPage = setCon.getPageNumber();
                    setNextPrevious();                                       
                }
                else{
                    displaySearch = false;
                    PageUtils.addInfo('No records to display. Please widen your search.');
                }
            }
        }
        return null;
    }

    public List<productWrapper> getproductListWrap(){
        if(productListWrap == null || productListWrap.isEmpty()){
          productListWrap = new List<productWrapper>();
          prodList = (List<Product2>) setCon.getRecords();
            for(Product2 p : prodList){
              productWrapper pw = new productWrapper(p);         
                if(checkedProducts.contains(pw.custProd.Id))
                    pw.prodCheck = TRUE;    
                    productListWrap.add(pw);
            }
        }
        return productListWrap;
    }

    //Product Wrapper class
    public class productWrapper{
        public Boolean prodCheck {get; set;}
        public Product2 custProd{get; set;}
        public string prodName { get; private set; }
        public string prodCode { get; private set; }
        public string prodDescription { get; private set; }
        public string prodLineDescription { get; private set; }

        public productWrapper(Product2 p){
            prodCheck = FALSE;
            custProd= p;
            prodName = p.Name;
            prodCode = p.ProductCode;
            prodDescription = p.Description;
            prodLineDescription = p.Product_Line_Desc__c;
        }    
    }

     public boolean getHasPreviousAndNext(){
        return (hasPrevious && hasNext);
    }

    //V1.1 removed duplicate code from next and previous methods and placed here
    public void prodChecked(){
        colCheck = FALSE;
            for(productWrapper prod : productListWrap){
                if(prod.prodCheck == TRUE)
                    checkedProducts.add(prod.custProd.Id);
                if(prod.prodCheck == FALSE)
                    checkedProducts.remove(prod.custProd.Id);
            }
        productListWrap=null;
    }
    //Next page method
    public PageReference next() {

        if (hasNext){   
            prodChecked();
            setCon.next();
            currentPage = setCon.getPageNumber();                   
        }
        setNextPrevious();
        return null;
    }

    //Previous page method
    public PageReference previous() {
        if (hasPrevious){
            prodChecked();
            setCon.previous();
            currentPage = setCon.getPageNumber();
        }
        setNextPrevious();
        return null;
    }

    //Next Previous method
    private void setNextPrevious() {
        if (setCon.getHasNext()) {
            hasNext = true;
        }
        else {
            hasNext = false;
        }
        if (setCon.getHasPrevious()) {
            hasPrevious = true;
        }
        else {
            hasPrevious = false;
        }
    }

    //To  select all the Product records in the page
    public pageReference selectAllProducts(){
        if(colCheck == FALSE){
            for(productWrapper fal : productListWrap){
                fal.prodCheck = FALSE;            
            }
        }  
        if(colCheck == TRUE){
            for(productWrapper tru : productListWrap){
                tru.prodCheck = TRUE;
            }
        }
        return null;
    }   
 }