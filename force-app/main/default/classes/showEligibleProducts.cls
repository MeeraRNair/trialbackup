/*****************************************
 Vf Page Name : showEligibleProducts
 Class Name : showEligibleProducts
 *****************************************/
public without sharing class showEligibleProducts{

 //Variable Declaration
 public Map<string,string> mapforedit = new map<string,string>();
 public transient List<Product2> EligibleProducts {get; set;}
 public List<Custom_Products__c> CPlist;
 public Set<ID> ProductIDset = new Set<ID>();
 public List<String> fields {get; set;}
 public List<String> fieldLabels {get; set;}
 public ID Did {get;set;} 
 public boolean Errmsg {get; set;}
 public boolean ProductsIncluded;
 public Map<String, Schema.SObjectField> objectFields = new Map<String, Schema.SObjectField>();

 //Constuctor
 public showEligibleProducts(ApexPages.StandardController controller) {      
   onloadMethod();
 }

 //Methods used in VisualForce Page 
 public Pagereference back() {
   return new Pagereference('/'+Did);
 }
 public Pagereference ToExcel() {
  // return new Pagereference('/apex/ProductExport?Did='+Did);
 
 PageReference pf1 = new Pagereference('/apex/ProductExport?Did='+Did);
 pf1.setRedirect(true);
 return pf1;

   
 }
 

    
 /*********Logic to Evaluate Products***********/
 public pageReference onloadMethod() {      
    Errmsg = false;
    ProductsIncluded = false;
    System.debug(errmsg);
    Did = ApexPages.currentPage().getParameters().get('Did');
    fields = new List<String>();
    fieldLabels = new List<String>();
    List<String> tempstr = (Label.DealProgram_ProductFields).split('##');
    for(String ts: tempstr)
    {
        List<String> tslist= ts.split('#');
        fields.add(tslist[0]);
        fieldLabels.add(tslist[1]);
    }
    String fieldString = 'id';
    for(String str: fields)
        fieldString = fieldString + ', ' + str;

    //Getting Map of All Product fields with APINames
     objectFields = Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap();
     for(String field: objectFields.keySet()) 
     {
       if(field != 'Detailed_Description__c' && field != 'IsActive' && field != 'dbm__c')
       {
       mapforedit.put(objectFields.get(field).getDescribe().getLabel(), field); 
       }            
     }

   /******Getting Eligible Products For Deal Program********/
     try
      {
        //Include Product Criteria: Verify the Criteria and Add Products to set         

        System.debug(ProductIDset.size());
        IncludeProductCriteria();
        System.debug(ProductIDset.size());
        //Exclude Product Criteria: Verify the Criteria and Removing Excluded Products from set
        ExcludeProductCriteria();
        System.debug(ProductIDset.size());
        //Include Individual Product: Add Products from set
          IncludeIndividualProduct();
          System.debug(ProductIDset.size());
        //Exclude Individual Product: Remove Products from set
          ExcludeIndividualProduct();
          System.debug(ProductIDset.size());
          CPlist = [select id, Filter_Type__c, Criteria__c From Custom_Products__c where (Include__c = true or Exclude__c = true) and Deal_Program__c =: Did];        
          if((ProductIDset == null  || ProductIDset.size() == 0) && CPlist.size() == 0)
              FrameFinal();

            /**Getting Required fieds for UI purpose**/
            String productquery = 'Select '+ fieldString+' from Product2 where IsActive = true and id in: ProductIDset';
            EligibleProducts = Database.query(productquery);
            
            if(EligibleProducts.size() > 10000)
                {
                Errmsg = true;
                productquery = 'Select '+ fieldString+' from Product2 where IsActive = true and id in: ProductIDset limit 10000';
                EligibleProducts = Database.query(productquery);
                }
        //    EligibleProducts = Database.query(productquery);
      }catch(exception ex){
       system.debug(ex.getMessage() +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
      }
      return new Pagereference('/apex/showEligibleProducts?Did='+Did);
 }
  
  /*****Helper Methods******/
 public void IncludeProductCriteria() { 
    CPlist = [select id, Filter_Type__c, Criteria__c From Custom_Products__c where Include__c = true and Filter_Type__c != null and Product__c = null and Deal_Program__c =: Did];        
    try{       
       if(CPlist != null && CPlist.size() > 0)
       {
       String TempQuery = 'Select id from Product2 where (';
       for(Custom_Products__c cp1: CPlist)
       {
         String field = mapforedit.get(cp1.Filter_Type__c);

        string strType = String.valueOf(objectFields.get(field).getDescribe().getType()) ;
        System.debug(strType);

         if(field != null && cp1.Filter_Type__c != null && cp1.Criteria__c != null && cp1.Filter_Type__c != '' && cp1.Criteria__c != '')
         {       
          List<String> Values = (cp1.Criteria__c).split(' ;');
         if(strType == 'BOOLEAN')
          {
          TempQuery = TempQuery + field + ' IN (';
          for(String v: Values)
                TempQuery = TempQuery + v + ', '; 
          if(TempQuery.endsWith(', '))
                TempQuery = TempQuery.substring(0,TempQuery.lastIndexOf(', '));
          TempQuery = TempQuery + ') OR ';            
          }
         else if(strType == 'MULTIPICKLIST')
          {
          TempQuery = TempQuery + field + ' INCLUDES (';
          for(String v: Values)
                TempQuery = TempQuery + '\'' + v + '\', '; 
          if(TempQuery.endsWith(', '))
                TempQuery = TempQuery.substring(0,TempQuery.lastIndexOf(', '));
          TempQuery = TempQuery + ') OR ';
          }
          else
          {
          TempQuery = TempQuery + field + ' IN (';
          for(String v: Values)
                TempQuery = TempQuery + '\'' + v + '\', '; 
          if(TempQuery.endsWith(', '))
                TempQuery = TempQuery.substring(0,TempQuery.lastIndexOf(', '));
          TempQuery = TempQuery + ') OR ';
          }
         }
       }
          if(TempQuery.endsWith(' OR '))
                TempQuery = TempQuery.substring(0,TempQuery.lastIndexOf(' OR '));
          TempQuery = TempQuery + ')';
          System.debug(TempQuery);
          Map<id, Product2> TempMap = new Map<id, Product2>((List<Product2>)Database.Query(TempQuery)); 
          ProductIDset.addAll(Tempmap.keyset());  
          ProductsIncluded = true;
       }
       else if(CPlist != null && CPlist.size() == 0)
       {
          
       }
    }catch(exception ex){
        system.debug(ex.getMessage() +ex.getLineNumber());
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
    }
 }
 
 public void ExcludeProductCriteria() { 
 
  /************************
   Map<id, Product2> TempMap1 = new Map<id, Product2>((List<Product2>)Database.Query('select Id,Name from product2 where isActive = True')); 
   ProductIDset.addAll(Tempmap1.keyset());  
   *******************/
         
   CPlist = [select id, Filter_Type__c, Criteria__c From Custom_Products__c where Exclude__c = true and Filter_Type__c != null and Product__c = null and Deal_Program__c =: Did];
   try{
      if(CPlist != null && CPlist.size() > 0)
      {
      String TempQuery = 'Select id from Product2 where (';
      for(Custom_Products__c cp1: CPlist)
       {
         String field = mapforedit.get(cp1.Filter_Type__c);

        string strType = String.valueOf(objectFields.get(field).getDescribe().getType()) ;
        System.debug(strType);

        if(field != null && cp1.Filter_Type__c != null && cp1.Criteria__c != null && cp1.Filter_Type__c != '' && cp1.Criteria__c != '')
         {      
          List<String> Values = (cp1.Criteria__c).split(' ;');
         if(strType == 'BOOLEAN')
          {
          TempQuery = TempQuery + field + ' IN (';
          for(String v: Values)
                TempQuery = TempQuery + v + ', '; 
          if(TempQuery.endsWith(', '))
                TempQuery = TempQuery.substring(0,TempQuery.lastIndexOf(', '));
          TempQuery = TempQuery + ') OR ';            
          }
         else if(strType == 'MULTIPICKLIST')
          {
          TempQuery = TempQuery + field + ' INCLUDES (';
          for(String v: Values)
                TempQuery = TempQuery + '\'' + v + '\', '; 
          if(TempQuery.endsWith(', '))
                TempQuery = TempQuery.substring(0,TempQuery.lastIndexOf(', '));
          TempQuery = TempQuery + ') OR ';
          }
          else
          {
          TempQuery = TempQuery + field + ' IN (';
          for(String v: Values)
                TempQuery = TempQuery + '\'' + v + '\', '; 
          if(TempQuery.endsWith(', '))
                TempQuery = TempQuery.substring(0,TempQuery.lastIndexOf(', '));
          TempQuery = TempQuery + ') OR ';
          }
         }
       }

         if(TempQuery.endsWith(' OR '))
               TempQuery = TempQuery.substring(0,TempQuery.lastIndexOf(' OR '));
         TempQuery = TempQuery + ')';
         System.debug(TempQuery);
         Map<id, Product2> TempMap = new Map<id, Product2>((List<Product2>)Database.Query(TempQuery)); 
         if(ProductIDset != null && ProductIDset.size() > 0)
           ProductIDset.RemoveAll(Tempmap.keyset()); 
         else {
            FrameFinal();
            ProductIDset.RemoveAll(Tempmap.keyset()); 
            ProductsIncluded = true;
         }         
      }
    }catch(exception ex){
     system.debug(ex.getMessage() +ex.getLineNumber());
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
    }
 }

 public void IncludeIndividualProduct() {   
    CPlist = [select id, Product__c, Include__c, Exclude__c From Custom_Products__c where Filter_Type__c = null and Include__c = true and Exclude__c = false and Product__c != null and Deal_Program__c =: Did];
    for(Custom_Products__c cp1: CPlist)
            ProductIDset.add(cp1.Product__c);
        if(CPlist.size() != 0)
            ProductsIncluded = true;
 }
 
 public void ExcludeIndividualProduct() {   
    CPlist = [select id, Product__c, Include__c, Exclude__c From Custom_Products__c where Filter_Type__c = null and Exclude__c = true and Product__c != null and Deal_Program__c =: Did];
    set<ID> setExcludeIndividualProd = new set<Id>();
    for(Custom_Products__c cp1: CPlist){
        setExcludeIndividualProd.add(cp1.Product__c);
    }
      if(ProductIDset != null && ProductIDset.size() > 0){
           ProductIDset.RemoveAll(setExcludeIndividualProd); 
        }
         else {
            if(!ProductsIncluded)
            {
            FrameFinal();
            ProductIDset.RemoveAll(setExcludeIndividualProd); 
            }
         } 
 }
 
 public void FrameFinal() {
     Map<id, Product2> TempMap = new Map<id, Product2>([select id from Product2 where isActive = true]); 
           ProductIDset.addAll(Tempmap.keyset());
   }
}