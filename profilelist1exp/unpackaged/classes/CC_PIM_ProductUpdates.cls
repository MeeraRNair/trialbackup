/*===========================================================================+
|  HISTORY                                                                  
|                                                                           
|  DATE(DD.MM.YYYY)            DEVELOPER               CR#                  DESCRIPTION                               
|  ====                        =========               ==                  =========== 
|   09/07/2018                 Meera                                       Initial Creation.Rest Api POST request from PIM to SFDC.
|   10/08/2018                 Meera/Ershad                                Based on action 'BaseMerge','MonarchMerge','BaseDelete' && 'MonarchDelete', Perform Insert,Update and delete Product2 and Product2pimMapping.
|                                                                          
|   10/10/2018                 Ershad                Story 5680317         New products, populate EMC Prooduct ID And Business Family   
|   30/05/2019                 Meera                 Story 6726685         Create shadow hierarchy fields with a mechanism to copy the shadow values to the standard fields          
|   04/07/2019				   Meera				 Strory 6748892		   Common Catalog: Brand Desc(API: NAME) being created with double 'AIO' in Name	                                                                    
===========================================================================*/
   /*****************************************
    * Gloabl Constants & Variables
    * prodBrandName : This will get the Name of the Product
    *****************************************/

@RestResource(urlMapping='/ProductUpdate/*')
global with sharing class CC_PIM_ProductUpdates {
    Public static string prodBrandName;
    Public static id productid; // Change to lower case
    public static boolean isPIM = false;
  
   @HttpPost
    global static void doPost() {
        isPIM = true;
        RestRequest request=RestContext.request;
        RestResponse response=RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        system.debug('@@@@@response '+response );   
        //Access the request body with input data coming in the JSON format
        system.debug('@@@@@response '+request.requestBody.toString().trim()); 
        String jSONRequestBody=request.requestBody.toString().trim();
        // response body request
        system.debug('jSONRequestBody=='+jSONRequestBody);
        //deserialize the request body to list of wrapper
        CC_ProductDetails proddetail = (CC_ProductDetails)JSON.deserialize(jSONRequestBody,CC_ProductDetails.class);
        system.debug('proddetail ==='+proddetail); 
        ccpimprod(proddetail);
    }
    
    Public static id ccpimprod(CC_ProductDetails proddetail){
        System.RestRequest request;
        System.RestResponse response; 
        String jSONRequestBody;
        if(isPIM){
            request=RestContext.request;
            response=RestContext.response; 
            jSONRequestBody=request.requestBody.toString().trim();
        }
        
         if(proddetail.Action == 'BaseMerge'){
             prodBrandName = getName(proddetail);
            System.debug('##prodBrandName:'+prodBrandName);
            System.debug('Inside BaseMerge');
            string itemClass = proddetail.Data[0].item_class; // Change the item class from upper to lower
            if(itemClass != null && itemClass != ''&& proddetail.Data[0].lob_desc!=null && proddetail.Data[0].lob_desc!='' && proddetail.Data[0].family_desc!=null &&
               proddetail.Data[0].family_desc!='' && proddetail.Data[0].type_desc!=null && proddetail.Data[0].type_desc!=''&& proddetail.Data[0].product_line_desc!=null &&
               proddetail.Data[0].product_line_desc!='' && proddetail.Data[0].group_desc!=null && proddetail.Data[0].group_desc!=''&&
              proddetail.Data[0].product_line_desc!=null && proddetail.Data[0].product_line_desc!=''){
                List<Product2_PIM_Mapping__c> pIMList = [Select id,Brand_Category_Code__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c=:itemClass limit 1];
                if(pIMList.size() > 0){
                    productid=updatePIMandPrd(pIMList[0],proddetail,'Dell Base',response,jSONRequestBody);// Change PIMList to pIMList
                    system.debug('>>>????Productid'+productid);
                }else{
                    System.debug('##prodBrandName:'+prodBrandName);
                    List<Product2> prdList = [Select id,Product_ID__c,PIM_Product__c ,Name,Description,Brand_Category_code__c,Product_Line_Desc__c,Product_Offering_Description__c,Family,Detailed_Description__c,Family_Code__c from Product2 where Name=:prodBrandName and Pim_product__c =true Limit 1];
                     System.debug('>>>????'+prdList);
                    if(prdList.size() > 0){
                     productid=updatePrdInsertPIM(proddetail,'Dell Base',prdList[0],response,jSONRequestBody);
                      system.debug('>>>????'+productid);  
                    } else{
                        productid=insertPIMandProductnew(proddetail,'Dell Base',response,jSONRequestBody);
                        system.debug('Productid------->>>>'+productid);
                    }
                }
             }
                      
            else{
                if(isPIM){
                   CC_exception_Pim_Dsa.ccpim(response ,JSON.serialize(new SFDCResponse('Failure','Any one or more filed values are missing in Post request,Field Names are - item_class,lob_desc,family_desc,type_desc,product_line_desc,group_desc or product_line_desc')),jSONRequestBody,'BaseMerge'); 
                         }
                else{
                  CC_exception_Pim_Dsa.ccpimdsa(proddetail);
                }
               }
             }
        
      
        if(proddetail.Action == 'MonarchMerge'){
            System.debug('Inside MonarchMerge');
            string productofferingcode = proddetail.Data[0].product_offering_code; // Change from upper to lower
            if(productofferingcode != null && productofferingcode != ''&& proddetail.Data[0].product_type_desc!=null && proddetail.Data[0].product_type_desc!='' && proddetail.Data[0].lob_desc!=null &&
               proddetail.Data[0].lob_desc!=''&& proddetail.Data[0].type_desc!=null && proddetail.Data[0].type_desc!=''&& proddetail.Data[0].product_offering_code_desc!=null && proddetail.Data[0].product_offering_code_desc!='' &&
              proddetail.Data[0].group_desc!=null && proddetail.Data[0].group_desc!=''){
                List<Product2_PIM_Mapping__c> pIMList = [Select id,Brand_Category_Code__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c=:productofferingcode  limit 1];
                if(pIMList.size() > 0){
                    //Change from PIMList to pIMList
                    productid=updatePIMandPrd(pIMList[0],proddetail,'Dell Snp',response,jSONRequestBody);// Change PIMList to pIMList
                    system.debug('>>>>>>---->>>'+productid);
                }else{
                    String prodOfferCodeDesc = proddetail.Data[0].product_offering_code_desc; // Change from Upper to lower 
                       //Remove the if condition as , We already validate it.
                        List<Product2> prdList = [Select id,PIM_Product__c,Product_ID__c,Name,Description,Product_Offering_Description__c from Product2 where Product_Offering_Description__c=:prodOfferCodeDesc and Pim_product__c =true Limit 1];
                        System.debug('##prdList:'+prdList);
                        if(prdList.size() > 0){
                            insertPIM(proddetail,'Dell Snp',prdList[0].Id,response,jSONRequestBody);
                        }else{                                                 
                           productid=insertPIMandProduct(proddetail,'Dell Snp',response,jSONRequestBody);
                        }
                }
            }
            else{
                if(isPIM){
                  CC_exception_Pim_Dsa.ccpim(response ,JSON.serialize(new SFDCResponse('Failure','Any one or more filed values are missing in Post request,Field Names are - product_offering_code,product_type_desc,lob_desc,type_desc,product_offering_code_desc or group_desc ')),jSONRequestBody,'MonarchMerge'); 
                         }
                else{
                    CC_exception_Pim_Dsa.ccpimdsa(proddetail);
                }

              }
            }
        
      if(proddetail.Action == 'BaseDelete'){
          system.debug('>>> Inside Base Delete :'+proddetail.Data[0].item_class);
            if(proddetail.Data[0].item_class==null || proddetail.Data[0].item_class==''){
                if(isPIM){
                 CC_exception_Pim_Dsa.ccpim(response ,JSON.serialize(new SFDCResponse('Failure','Item class is missing')),jSONRequestBody,'BaseDelete'); 
                         }
                else{
                CC_exception_Pim_Dsa.ccpimdsa(proddetail);
                }
               }
            else{       
                system.debug('>>> Inside BaseDelete else condition');
                deletemethod(proddetail,response,jSONRequestBody);
            }
        }
        if(proddetail.Action == 'MonarchDelete'){
            if(proddetail.Data[0].product_offering_code == null || proddetail.Data[0].product_offering_code== ''){
                if(isPIM){
                 CC_exception_Pim_Dsa.ccpim(response ,JSON.serialize(new SFDCResponse('Failure','Product offering code is empty')),jSONRequestBody,'MonarchDelete'); 
                         }
                else{
                CC_exception_Pim_Dsa.ccpimdsa(proddetail); 
                }

              }
          
            else {
                deletemethodMon(proddetail,response,jSONRequestBody);
            }
            
        }
  
        system.debug('productid>>>>----'+productid);
        
        return productid;
        
        
      }
    /*****************************************************************************************************************
    *    Method Name   :    updatePIMandPrd
    *    Description   :    This method will call another method updatePIM and updatePRD.
    *    Params        :    Passing Product2_PIM_Mapping PIM, post CC_ProductDetails,ProdType('Dell Base' or 'Dell Snp') and response as a paramater
    *    Return Type   :    Null
    ******************************************************************************************************************/ 

    Public static id updatePIMandPrd(Product2_PIM_Mapping__c pim,CC_ProductDetails proddetail,String prodType,RestResponse response,string jSONRequestBody){
       
        Id prdid;
        // Need this Product List to find the related product from Product2PimMapping
        List<Product2> prdList = [Select id,Product_ID__c,PIM_Product__c ,Name,Description,Brand_Category_code__c,Detailed_Description__c,Family,ProductCode,Product_Line_Desc__c,Product_Offering_Description__c,Family_Code__c from Product2 where Id=:pim.SFDC_Prod_ID__C and Pim_product__c=True Limit 1];
        if(prdList.size()>0){   
            Product2 prd = prdList[0];
            prdid=updatePRD(prd,proddetail,prodType,response,jSONRequestBody);
            if(prdid!=Null){
            updatePIM(pim,proddetail,prodType,response,jSONRequestBody);
            }
           }
            else{
                response.statusCode = 500;
                response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Failure','Product Does not exists in SFDC')));
                CC_exception_Pim_Dsa.ccpim(response ,JSON.serialize(new SFDCResponse('Failure','Product Does not exists in SFDC')),jSONRequestBody,'ProductValidate'); 
            }
        return prdid;
      }
   /*************************************************************************************************************************************
    *    Method Name   :    insertPIM
    *    Description   :    This method will insert a record in Prduct2_PIM_mapping
    *    Params        :    Passing post CC_ProductDetails,prodType('Dell Base' or 'Dell Snp'),Product Id and response as a paramater
    *    Return Type   :    Null
    ***************************************************************************************************************************************/ 
   
    Public static void insertPIM(CC_ProductDetails proddetail,String prodType,Id prdId,RestResponse response,string jSONRequestBody){
        try{
           
        Product2_PIM_Mapping__c pimMapObj = new Product2_PIM_Mapping__c();
        pimMapObj.ProdType__c = prodType;
        pimMapObj.Product_Offering_Description__c = proddetail.Data[0].product_offering_code_desc;
        if(prodType=='Dell Base'){
        pimMapObj.Classcode_Prod_Offer_Code__c = proddetail.Data[0].Item_Class;
        }else{
         pimMapObj.Classcode_Prod_Offer_Code__c = proddetail.Data[0].product_offering_code;   
        }
        pimMapObj.Brand_Category_Code__c = proddetail.Data[0].product_line;
        pimMapObj.SFDC_Prod_ID__C = prdId;
        pimMapObj.Base_Code__c=proddetail.Data[0].base_code; // New fields are added in Product2PIM Mapping object
        pimMapObj.Base_Description__c =proddetail.Data[0].base_code_desc;
        pimMapObj.Family_Code__c=proddetail.Data[0].family;
        pimMapObj.Family_Description__c=proddetail.Data[0].family_desc;
        pimMapObj.Item_Class_code_description__c=proddetail.Data[0].item_class_desc;
        pimMapObj.IsActive__c=true;
        // Null pointer exeption also handle//
        
        Insert pimMapObj;
        if(isPIM){
        response.statusCode = 200;
        response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Success','')));
        System.debug('response:'+response);
        }
        
        }catch(Exception ex){
            if(isPIM){
                CC_exception_Pim_Dsa.ccpimex(response ,ex,JSON.serialize(new SFDCResponse('Failure',ex.getMessage())),jSONRequestBody,'InsertPIM'); 
                 }
                else{
                CC_exception_Pim_Dsa.ccpimdsa(proddetail);    
                }
               }
            }
            
    /*************************************************************************************************************************************
    *    Method Name   :    UpdatePrdInsertPIM
    *    Description   :    This method will call another method updatePRD and InsertPIM.
    *    Params        :    Passing post CC_ProductDetails,ProdType('Dell Base' or 'Dell Snp'),Product and response as a paramater
    *    Return Type   :    Product id
    ***************************************************************************************************************************************/ 
   
    
    Public static id updatePrdInsertPIM(CC_ProductDetails proddetail,String prodType,Product2 prd,RestResponse response,string jSONRequestBody){
        //Insert in PIM, will perform only after the update in Product
        
        Id prdid=updatePRD(prd,proddetail,prodType,response,jSONRequestBody);
        if(prdid!=NULL){
        InsertPIM(proddetail,prodType,prd.id,response,jSONRequestBody);  
        
       }
        
        return prdid;
    }
    /*************************************************************************************************************************************
    *    Method Name   :    InsertPIMandProductnew
    *    Description   :    This method will call another method insertPRD,InsertPIM and insertPB method.
    *    Params        :    Passing post CC_ProductDetails,ProdType('Dell Base' or 'Dell Snp'),response as a paramater
    *    Return Type   :    Null
    ***************************************************************************************************************************************/ 
   
    Public static id insertPIMandProductnew(CC_ProductDetails proddetail,String prodType,RestResponse response,string jSONRequestBody){
        
        Id prdid = insertPRD(proddetail,prodType,response,jSONRequestBody);
        if(prdid!=Null)
        {
        InsertPIM(proddetail,prodType,prdid,response,jSONRequestBody);
        insertPB(prdid,response,proddetail);
        
        }
       
        return prdid;
       
    }
    /*************************************************************************************************************************************
    *    Method Name   :    insertPIMandProduct
    *    Description   :    This method will call another method insertPRD,InsertPIM and insertPB method.
    *    Params        :    Passing post CC_ProductDetails,ProdType('Dell Base' or 'Dell Snp'),response as a paramater
    *    Return Type   :    Product Id
    ***************************************************************************************************************************************/ 
   
    Public static id insertPIMandProduct(CC_ProductDetails proddetail,String prodType,RestResponse response,string jSONRequestBody){
        
        id prdid = insertPRD(proddetail,prodType,response,jSONRequestBody);
        
        if(prdid!=Null){
        InsertPIM(proddetail,prodType,prdId,response,jSONRequestBody);
        insertPB(prdid,response,proddetail);
         }
        
     return prdid ;       
          
    }
    public class SFDCResponse{
        String response;
        String message;
        public SFDCResponse(String resp, String msg){
            response = resp;
            message = msg;          
        }
    }
    
    
   /*************************************************************************************************************************************
    *    Method Name   :    deletemethod
    *    Description   :    This method delete the record from Product2_PIM_Mapping and make inactive in Product for action BaseDelete .
    *    Params        :    Passing post CC_ProductDetails,response as a paramater
    *    Return Type   :    Null
    ***************************************************************************************************************************************/ 
   
public static void deletemethod(CC_ProductDetails proddetail,RestResponse response,string jSONRequestBody){
   
        string itemClass = proddetail.Data[0].item_class;
     system.debug('--->>>--->>'+itemClass);
        if(itemClass != null && itemClass != ''){
            List<Product2_PIM_Mapping__c> pIMList = [Select id,Brand_Category_Code__c,IsActive__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c=:itemClass limit 1];
            if(pIMList.size() > 0){
                try{
                     pIMList[0].IsActive__c=False;
                     Update pIMList;
                     
                List<Product2_PIM_Mapping__c> pIMList1 = [Select id,Brand_Category_Code__c,IsActive__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where SFDC_Prod_ID__C=:pIMList[0].SFDC_Prod_ID__C and IsActive__c =True limit 1];
                   if(pIMList1.size() == 0) {
                       System.debug('>>>>>>PIMList1'+PIMList1);
                   Product2 prod = new Product2(id=PIMList[0].SFDC_Prod_ID__C );
                   prod.IsActive =False;
                   Update prod;
                    
                   }
                   if(isPIM){    
                response.statusCode = 200;
                response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Success','')));
                System.debug('response:'+response);    
                   }
                }catch(Exception ex){
                    if(isPIM){
                 CC_exception_Pim_Dsa.ccpimex(response ,ex,JSON.serialize(new SFDCResponse('Failure',ex.getMessage())),jSONRequestBody,'BaseDeletePIMProd'); 
                 }
                else{
                 CC_exception_Pim_Dsa.ccpimdsa(proddetail);  
                }
               }
             }
             else{
                response.statusCode = 500;
                response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Failure','Product Does not exists in SFDC')));
                CC_exception_Pim_Dsa.ccpim(response ,JSON.serialize(new SFDCResponse('Failure','Product Does not exists in SFDC')),jSONRequestBody,'ProductValidate'); 
            }
            }
          }   
    
    
    
   /*************************************************************************************************************************************
    *    Method Name   :    deletemethodMon
    *    Description   :    This method delete the record from Product2_PIM_Mapping and make inactive in Product for action MonarchDelete .
    *    Params        :    Passing post CC_ProductDetails,response as a paramater
    *    Return Type   :    Null
    ***************************************************************************************************************************************/ 
   
    public static void deletemethodMon(CC_ProductDetails proddetail,RestResponse response,string jSONRequestBody){
        
        string productofferingcode = proddetail.Data[0].product_offering_code;
        system.debug('--->>'+productofferingcode);
        if(productofferingcode != null && productofferingcode != ''){
            system.debug('---->>>inside if');
            List<Product2_PIM_Mapping__c> pIMList = [Select id,Brand_Category_Code__c,IsActive__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c=:productofferingcode limit 1];
            if(pIMList.size() > 0){
                
                try{
                     pIMList[0].IsActive__c=False;
                     update pIMList;
                    
                  List<Product2_PIM_Mapping__c> pIMList1 = [Select id,Brand_Category_Code__c,IsActive__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where SFDC_Prod_ID__C=:PIMList[0].SFDC_Prod_ID__C and IsActive__c =True limit 1];
                   if(pIMList1.size() == 0) {
                   Product2 prod = new Product2(id=PIMList[0].SFDC_Prod_ID__C );
                   prod.IsActive =False;
                   Update prod;
                        
                   }
                    if(isPIM){
                   response.statusCode = 200;
                   response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Success','')));
                   System.debug('response:'+response);    
                   }
                }catch(Exception ex){
                     if(isPIM){
                CC_exception_Pim_Dsa.ccpimex(response ,ex,JSON.serialize(new SFDCResponse('Failure',ex.getMessage())),jSONRequestBody,'MonarchDeletePIMProd'); 
                 }
                else{
                CC_exception_Pim_Dsa.ccpimdsa(proddetail); 
                       }
                     }
                
                  }
                  else{
                response.statusCode = 500;
                response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Failure','Product Does not exists in SFDC')));
                CC_exception_Pim_Dsa.ccpim(response ,JSON.serialize(new SFDCResponse('Failure','Product Does not exists in SFDC')),jSONRequestBody,'ProductValidate');          
                  }
               } 
                
           }
              
    
    /*****************************************************************************************************************
    *    Method Name   :    getName
    *    Description   :    This method get the Product Name based on the below logic.
    *    Params        :    Passing post CC_ProductDetails as a paramater
    *    Return Type   :    Product Name
	*    version 5	   :    added new form factors
    ******************************************************************************************************************/ 
   
    
    public static string getName(CC_ProductDetails proddetail){
        
        String strbranddes = proddetail.Data[0].product_line_desc;
        //Custom metadata to get the Name CC_Getname_Prod__mdt
        CC_Getname_Prod__mdt[] listProdName = [SELECT Type__c,notoEMTAA__c,MasterLabel,DeveloperName,Description__c,Similar_Values__c FROM CC_Getname_Prod__mdt where Type__c ='form'];
        String strform ='';
        string stroEMTAA='';
		//base_code_desc
		//base_code
        for(CC_Getname_Prod__mdt prodName: listProdName){
			System.debug(proddetail.Data[0].lob_desc);
			System.debug('strform:'+prodName.MasterLabel);
			System.debug('strform:'+prodName.Description__c);
			System.debug('strform:'+prodName.Description__c);
            if(((proddetail.Data[0].family_desc!=null && proddetail.Data[0].family_desc.containsIgnoreCase(prodName.MasterLabel))|| (proddetail.Data[0].base_code_desc!=null && proddetail.Data[0].base_code_desc.containsIgnoreCase(prodName.MasterLabel)) 
				|| (proddetail.Data[0].base_code != null && proddetail.Data[0].base_code.containsIgnoreCase(prodName.MasterLabel)) ) 
				&& !strbranddes.containsIgnoreCase(prodName.MasterLabel)){
					
					//Check for OEM
					Boolean buniq = true;
					if(prodName.MasterLabel == 'OEM'){
						buniq = true;
					}
					
					else if(prodName.MasterLabel == 'TAA' && prodName.Description__c!=null && prodName.Description__c.containsIgnoreCase(proddetail.Data[0].lob_desc)){
						buniq = false;
					}
					
					else if(prodName.MasterLabel != 'OEM' && prodName.MasterLabel != 'TAA'&& prodName.Description__c!= null && !prodName.Description__c.containsIgnoreCase(proddetail.Data[0].lob_desc) ){
						buniq = false;
					}
					
					if(prodName.MasterLabel != 'TAA' && buniq == true && prodName.Similar_Values__c != null){
						//check for similar values
						List<String> listsimval = prodName.Similar_Values__c.split(';');
						for(String val: listsimval){
							if((proddetail.Data[0].family_desc!=null && proddetail.Data[0].family_desc.containsIgnoreCase(val))|| (proddetail.Data[0].base_code_desc!=null && proddetail.Data[0].base_code_desc.containsIgnoreCase(val) )
							||(proddetail.Data[0].base_code!=null && proddetail.Data[0].base_code.containsIgnoreCase(val))){
								buniq = false;
							}
						}
					}
					if(buniq == true && prodName.notoEMTAA__c==true){
						strform = strform==''?prodName.MasterLabel:strform+' '+prodName.MasterLabel;
					}
					
					if(buniq == true && prodName.notoEMTAA__c==false){
						stroEMTAA = stroEMTAA==''?prodName.MasterLabel:stroEMTAA+' '+prodName.MasterLabel;
					}
					
                    
                }
                
        }
  
            if(strform!='' || stroEMTAA!=''){
                strbranddes+=' '+strform+' '+stroEMTAA;
            }
         system.debug('>>>>>>strbranddes'+strbranddes);
         return formatName(strbranddes.normalizeSpace());
        }
/*****************************************************************************************************************
    *    Method Name   :    formatName
    *    Description   :    This method is to format product name based on business logic.
    *    Params        :    Passing name as param
    *    Return Type   :    Product Name
    ******************************************************************************************************************/ 
    
    public static string formatName(String strprodname){
        
        
        Map<String,String> mapbrandnam = new Map<String,String>();
        Map<String,String> maparticles = new Map<String,String>();
        Map<String,String> mapkeys = new Map<String,String>();
        
        //Get brand names from custom metadata and put inside set
        List<CC_Brand_Names__mdt> listbrand = [SELECT DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM CC_Brand_Names__mdt];
        for(CC_Brand_Names__mdt br: listbrand){
            mapbrandnam.put(br.MasterLabel,br.DeveloperName);
        }
        //Get Articles      
        List<CC_Articles__mdt> listarticle = [SELECT DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM CC_Articles__mdt];
        for(CC_Articles__mdt ar: listarticle){
            maparticles.put(ar.MasterLabel,ar.MasterLabel);
        }
        
        //get reserved words
        List<CC_Name_Keywords__mdt> listkeyword = [SELECT DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM CC_Name_Keywords__mdt];
        for(CC_Name_Keywords__mdt ky: listkeyword){
            mapkeys.put(ky.MasterLabel,ky.MasterLabel);
        }
        //Split the brand name 
        List<String> listnam = strprodname.split(' ');
        //List<String> listnam = strprodname.splitByCharacterTypeCamelCase();
        
        //Iterate through each string and compare for special scenarios
        
        for(Integer inti=0;inti<listnam.size();inti++){
            System.debug('##Articles:'+maparticles);
            if(listnam[inti].isalpha() || listnam[inti].isalphanumeric()){
                //check for brand names
                if(mapbrandnam.keyset().contains(listnam[inti].tolowerCase())){
                    listnam[inti] = mapbrandnam.get(listnam[inti].tolowerCase());
                }
                
                else if(mapkeys.keyset().contains(listnam[inti].toUpperCase())){
                    listnam[inti] = mapkeys.get(listnam[inti].toUpperCase());
                }
                
                else if(maparticles.keyset().contains(listnam[inti].toLowerCase())){
                    listnam[inti] = maparticles.get(listnam[inti].toLowerCase());
                    System.debug('Inside articles:'+listnam[inti]);
                }
                
                else if(listnam[inti].isalpha()&& listnam[inti].isAllUpperCase()){
                    listnam[inti] = listnam[inti].toLowerCase().capitalize();
                    //System.debug(listnam[i].toLowerCase().capitalize());
                }
            }
            else{
            System.debug('Inside else');
                List<String> listnew = listnam[inti].splitByCharacterTypeCamelCase();
                for(Integer inti1=0;inti1<listnew.size();inti1++){
                    //System.debug('##Articles:'+articles);
                    
                    if(listnew[inti1].isalpha() || listnew[inti1].isalphanumeric()){
                        //check for brand names
                        if(mapbrandnam.keyset().contains(listnew[inti1].tolowerCase())){
                            listnew[inti1] = mapbrandnam.get(listnew[inti1].tolowerCase());
                        }
                        
                        else if(mapkeys.keyset().contains(listnew[inti1].toUpperCase())){
                            listnew[inti1] = mapkeys.get(listnew[inti1].toUpperCase());
                        }
                        
                        else if(maparticles.keyset().contains(listnew[inti1].toLowerCase())){
                            listnew[inti1] = maparticles.get(listnew[inti1].toLowerCase());
                            System.debug('Inside articles:'+listnew[inti1]);
                        }
                        
                        else if(listnew[inti1].isalpha()&& listnew[inti1].isAllUpperCase()){
                            listnew[inti1] = listnew[inti1].toLowerCase().capitalize();
                            //System.debug(namlist[i].toLowerCase().capitalize());
                        }
                    }
                }
                String strnewname1='';
                for(String strnew1 : listnew){
                    strnewname1+=strnew1;
                }
                listnam[inti] = strnewname1;
            }
            
        }
        
        String strnewname = String.join(listnam,' ');
        /*String strnewnamec;
		System.debug('strnewname:'+strnewname);
        if(strnewname.contains('2-In-1')){
			System.debug('Inside 2 in one');
			strnewnamec = strnewname.replace('2-In-1','2-IN-1');
			System.debug('strnewnamec:'+strnewnamec);
		}			
        return strnewnamec;*/
		return strnewname;
    }
    
    

    
 /*****************************************************************************************************************
    *    Method Name   :    updatePIM
    *    Description   :    This method will update Product2PIMMapping.
    *    Params        :    Passing Product2PIMMapping value from method UpdatePrdInsertPIM,post CC_ProductDetails,ProdType('Dell Base' or 'Dell Snp') and response as a paramater
    *    Return Type   :    Null
    ******************************************************************************************************************/ 
   
    
    public static void updatePIM(Product2_PIM_Mapping__c pim,CC_ProductDetails proddetail,String prodType,RestResponse response,string jSONRequestBody){
        
         try{
        pim.ProdType__c = prodType;
        pim.Product_Offering_Description__c = proddetail.Data[0].product_offering_code_desc;
        pim.Brand_Category_Code__c = proddetail.Data[0].product_line;
        pim.Base_Code__c=proddetail.Data[0].base_code; // New fields are added in Product2PIM Mapping object
        pim.Base_Description__c =proddetail.Data[0].base_code_desc;
        pim.Family_Code__c=proddetail.Data[0].family;
        pim.Family_Description__c=proddetail.Data[0].family_desc;
        pim.Item_Class_code_description__c=proddetail.Data[0].item_class_desc;
        pim.IsActive__c=true;
       
            Update pim; 
            if(isPIM){
           response.statusCode = 200;
           response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Success','')));
            }
            System.debug(response);
        } catch(Exception ex){
             if(isPIM){
                response.statusCode = 500;
                response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Failure',ex.getMessage()))); 
                CC_exception_Pim_Dsa.ccpimex(response ,ex,JSON.serialize(new SFDCResponse('Failure',ex.getMessage())),jSONRequestBody,'updatePIM'); 
                 }
                else{
                CC_exception_Pim_Dsa.ccpimdsa(proddetail);  
                       }
             }
    }
    /*****************************************************************************************************************
    *    Method Name   :    updatePRD
    *    Description   :    This method will update Product2.
    *    Params        :    Passing Product2 from method UpdatePrdInsertPIM,post CC_ProductDetails,ProdType('Dell Base' or 'Dell Snp') and response as a paramater
    *    Return Type   :    Null
    ******************************************************************************************************************/ 

    public static Id updatePRD(Product2 prd,CC_ProductDetails proddetail,string prodType,RestResponse response,string jSONRequestBody){
       
        try{
        //Copy values to shadow fields    
        String branddes = proddetail.Data[0].product_line_desc;
        prd.Product_ID__c = prd.Product_ID__c;   // Required field to be a part of update
		//Update flag only if there is change
		if(prd.Description != proddetail.Data[0].lob_desc || prd.ProductCode!=proddetail.Data[0].group_desc || prd.Name!=prodBrandName ||
		(prodType =='Dell Snp'&&(prd.Product_Line_Desc__c!=proddetail.Data[0].offering_group_desc 
		   ||prd.Product_Offering_Description__c!=proddetail.Data[0].product_offering_code_desc || prd.Detailed_Description__c!=proddetail.Data[0].product_offering_code_desc
		   || prd.Family!=formatFamily(proddetail.Data[0].type_desc) ||prd.Brand_Category_code__c!=proddetail.Data[0].product_line)) || 
		  (prodType =='Dell Base'&&(prd.Product_Line_Desc__c!=proddetail.Data[0].product_line_desc || prd.Brand_Category_code__c!=proddetail.Data[0].product_line)) ){
			prd.Product_Updated_from_PIM__c = true;
		 }
        prd.Description_PIM__c = prd.Description != proddetail.Data[0].lob_desc?proddetail.Data[0].lob_desc:prd.Description_PIM__c;
        prd.ProductCode_PIM__c= prd.ProductCode!=proddetail.Data[0].group_desc?proddetail.Data[0].group_desc:prd.ProductCode_PIM__c;
        prd.Name_PIM__c = prd.Name!=prodBrandName?prodBrandName:prd.Name_PIM__c;
        prd.PIM_Product__c = true;
        prd.IsActive=true;
        prd.CANUSEQUANTITYSCHEDULE =true;
        prd.CANUSEREVENUESCHEDULE =true;
        if(prodType =='Dell Snp'){
        // Temporary fix to start testing in sit3 ..now removed   
            prd.Product_Line_Desc_PIM__c = prd.Product_Line_Desc__c!=proddetail.Data[0].offering_group_desc?proddetail.Data[0].offering_group_desc:prd.Product_Line_Desc_PIM__c; //New Dell Snp Mapping
            prd.Product_Offering_Description_PIM__c = prd.Product_Offering_Description__c!=proddetail.Data[0].product_offering_code_desc?proddetail.Data[0].product_offering_code_desc:prd.Product_Offering_Description_PIM__c;
            prd.Detailed_Description_PIM__c = prd.Detailed_Description__c!=proddetail.Data[0].product_offering_code_desc?proddetail.Data[0].product_offering_code_desc:prd.Detailed_Description_PIM__c; // As per Dell Snp Mapping
            prd.ProductFamily_PIM__c= prd.Family!=formatFamily(proddetail.Data[0].type_desc)?formatFamily(proddetail.Data[0].type_desc):prd.ProductFamily_PIM__c;
            prd.Brand_Category_code_PIM__c = prd.Brand_Category_code__c!=proddetail.Data[0].product_line?proddetail.Data[0].product_line:prd.Brand_Category_code_PIM__c;
        }                
        else{
            //  Map<String,Product2> uniqprodmap = new Map<String,Product2>();
            prd.Product_Line_Desc_PIM__c=prd.Product_Line_Desc__c!=proddetail.Data[0].product_line_desc?proddetail.Data[0].product_line_desc:prd.Product_Line_Desc_PIM__c; //As per Dell Base Mapping 
            prd.Brand_Category_code_PIM__c = prd.Brand_Category_code__c!=proddetail.Data[0].product_line?proddetail.Data[0].product_line:prd.Brand_Category_code_PIM__c;
            //prd.Product_Offering_Description__c = proddetail.Data[0].product_offering_code_desc;
            // uniqprodmap.put(branddes,prd);
            
            String currdesc = prd.Detailed_Description__c;
            String currdescode = prd.Family_Code__c;
            Integer current=0;
            Integer newcode=0;
            system.debug('currdesc=='+currdesc);
            if(currdescode!=null && currdescode.isNumeric()){
                current = Integer.valueof(currdescode);
            }
            
            String newdes = proddetail.Data[0].family_desc;
            String newfam = proddetail.Data[0].family;
            if(newfam!=null && newfam.isNumeric()){
                newcode = Integer.valueof(newfam);
            }
            if(currdesc!=null && newdes!=null ){
            if((currdesc.contains('CTO') && newdes.contains('CTO')) || (currdesc.contains('BTX') && newdes.contains('BTX'))){
                if(newcode>current || newfam.compareTo(currdescode)>0){
                    prd.Detailed_Description_PIM__c = proddetail.Data[0].family_desc;
                    prd.Family_Code_PIM__c = newfam;
					prd.Product_Updated_from_PIM__c = true;
                }
             }
             
            else if((currdesc.contains('BTX') && newdes.contains('CTO'))){
                prd.Detailed_Description_PIM__c = proddetail.Data[0].family_desc;
                prd.Family_Code_PIM__c = newfam;
				prd.Product_Updated_from_PIM__c = true;
            }
            
            else if(!currdesc.contains('BTX') && !currdesc.contains('CTO')){
                prd.Detailed_Description_PIM__c = proddetail.Data[0].family_desc;
                prd.Family_Code_PIM__c = newfam;
				prd.Product_Updated_from_PIM__c = true;
            }
         }           
       }
            
            Update prd;
            
            if(isPIM){
           response.statusCode = 200;
           response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Success','')));
            }
           
             
            }catch(Exception ex){
           if(isPIM){
                 response.statusCode = 500;
                 response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Failure',ex.getMessage())));
                 CC_exception_Pim_Dsa.ccpimex(response ,ex,JSON.serialize(new SFDCResponse('Failure',ex.getMessage())),jSONRequestBody,'updatePRD'); 
                 }
                else{
                CC_exception_Pim_Dsa.ccpimdsa(proddetail);
                       }
               }
        
       return prd.Id; 
    }
          
    /*****************************************************************************************************************
    *    Method Name   :    insertPRD
    *    Description   :    This method will create or insert Product2 bases on prodType 'Dell Base' or 'Dell Snp'
    *    Params        :    Passing post CC_ProductDetails,prodType('Dell Base' or 'Dell Snp') and response as a paramater
    *    Return Type   :    Product Id
    ******************************************************************************************************************/ 

    
    public static id insertPRD(CC_ProductDetails proddetail,string prodType,RestResponse response,string jSONRequestBody){
        
        Product_ID__c prdid = Product_ID__c.getInstance('default');
        Product2 prdnew = new Product2();
        try{
            Integer slength = 0;
        System.debug(prdid.id__c);
         if(prdid!= null){
         slength = prdid.id__c.length();
             if(slength==1){
            prdnew.Product_ID__c ='PIM'+'000'+prdid.id__c;
             }
             else if(slength==2){
            prdnew.Product_ID__c ='PIM'+'00'+prdid.id__c;
             }
             else if(slength==3){
            prdnew.Product_ID__c ='PIM'+'0'+prdid.id__c;
             }
             else{
            prdnew.Product_ID__c ='PIM'+prdid.id__c;
             }
         }
        prdid.id__c =string.valueof(Integer.valueOf(prdid.id__c)+1);
        update prdid;
        prdnew.PIM_Product__c = true;
        prdnew.IsActive = true;
        prdnew.CANUSEQUANTITYSCHEDULE =true;
        prdnew.CANUSEREVENUESCHEDULE =true; 
        prdnew.Family_Code__c = proddetail.Data[0].family; // need to be updated with 
        prdnew.Family = formatFamily(proddetail.Data[0].type_desc);
        prdnew.ProductCode = proddetail.Data[0].group_desc;
        prdnew.Description = proddetail.Data[0].lob_desc;
        if(prodType=='Dell Base'){
        prdnew.Name = prodBrandName;
        prdnew.Product_Line_Desc__c=proddetail.Data[0].product_line_desc;
        prdnew.Product_Offering_Description__c = proddetail.Data[0].product_offering_code_desc;    
        prdnew.Brand_Category_Code__c = proddetail.Data[0].product_line;
        prdnew.Detailed_Description__c = proddetail.Data[0].family_desc;// Dell Base mapping
        system.debug('--->>>>--->>>'+prdnew.Detailed_Description__c);    
        }
       else{
        prdnew.Name = proddetail.Data[0].product_offering_code_desc;
        prdnew.Product_Line_Desc__c=proddetail.Data[0].offering_group_desc; 
        prdnew.Product_Offering_Description__c = proddetail.Data[0].product_offering_code_desc;    
        prdnew.Brand_Category_Code__c = proddetail.Data[0].product_line;
        prdnew.Detailed_Description__c = proddetail.Data[0].product_offering_code_desc; // Snp Mapping
        } 
        List<Product2> prd=[Select EMC_Product_ID__c,Business_Family__c FROM Product2 where Description=:prdnew.Description and Productcode=:prdnew.ProductCode and Family=:prdnew.Family AND EMC_Product_ID__c Like '01t%' and EMC_Product_ID__c!=Null and PIM_Product__c=True ORDER BY Business_Family__c DESC LIMIT 1 ]; 
            if(Prd.size()>0){
            prdnew.EMC_Product_ID__c =prd[0].EMC_Product_ID__c;
            prdnew.Business_Family__c=prd[0].Business_Family__c;
                } 
        insert prdnew;
            System.debug('$$$$prdnew.id:'+prdnew);
            if(isPIM){
                response.statusCode = 200;
                response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Success','')));
                System.debug('response:'+response);
            }
       
            } catch(Exception ex){
                 if(isPIM){
                  response.statusCode = 500;
                 response.responseBody  = Blob.valueOf(JSON.serialize(new SFDCResponse('Failure',ex.getMessage())));  
                 CC_exception_Pim_Dsa.ccpimex(response ,ex,JSON.serialize(new SFDCResponse('Failure',ex.getMessage())),jSONRequestBody,'insertPRD'); 
                 }
                else{
                 CC_exception_Pim_Dsa.ccpimdsa(proddetail);  
              }
             }
        system.debug('--->>>>---prdnew.id'+prdnew.id);
        System.debug(response);
        return  prdnew.id;
    }
  /*****************************************************************************************************************
    *    Method Name   :    insertPB
    *    Description   :    This method will create a Common Catalog using product id came from insertPRD medthod.
    *    Params        :    Passing product id as a paramater
    *    Return Type   :    Null
    ******************************************************************************************************************/ 

    
    public static void insertPB(id prdid,RestResponse response,CC_ProductDetails proddetail){
        //add products to pricebook
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        List<PricebookEntry> pbeList1 = new List<PricebookEntry>();
        //select price book
        Pricebook2 pb1 = [SELECT CurrencyIsoCode,Description,Id,IsActive,Name FROM Pricebook2  where name='Standard Price Book'];
        Pricebook2 pb = [SELECT CurrencyIsoCode,Description,Id,IsActive,Name FROM Pricebook2 where name='Common Catalog'];
        
        List<CC_Currency__mdt> currencies = [Select MasterLabel from CC_Currency__mdt];
            //  System.debug('prdlist1:'+prdlist1);
            //for(Product2 pd2 : prdlist1){
            for(CC_Currency__mdt cur:currencies){
                //add to std pricebook
                PricebookEntry  pbe1 = new PricebookEntry();
                pbe1.Pricebook2Id = pb1.id;
                pbe1.Product2Id = prdid;
                pbe1.CurrencyIsoCode = cur.MasterLabel;
                //pbe.ProductCode = pd2.ProductCode;
                //pbe.name = pd2.name;
                pbe1.unitPrice = 0.00;
                pbe1.UseStandardPrice = false;
               // pbe1.StandardPrice = 0;
                pbe1.isactive = true;
                pbeList1.add(pbe1);
                
                PricebookEntry  pbe = new PricebookEntry();
                pbe.Pricebook2Id = pb.id;
                pbe.Product2Id = prdid;
                pbe.CurrencyIsoCode = cur.MasterLabel;
                //pbe.ProductCode = pd2.ProductCode;
                //pbe.name = pd2.name;
                pbe.unitPrice = 0.00;
                pbe.UseStandardPrice = false;
               // pbe.StandardPrice = 0;
                pbe.isactive = true;
                pbeList.add(pbe);
            }
        System.debug('pbeList1:'+pbeList1);
        System.debug('pbeList:'+pbeList);
        if(pbeList1.size()>0){
            try{
                
            insert pbeList1;
                system.debug('pbeList1'+pbeList1);
            }catch(exception ex)  {
                 if(isPIM){
                string responsejson=JSON.serialize(new SFDCResponse('Failure',ex.getMessage()));
                response.responseBody  = Blob.valueOf(responsejson);    
                String reqresponse = 'Request Body Product Id --->>'+String.valueof(prdid) +'\n'+'\n'+'Response Body --->> '+responsejson;
                system.debug('reqresponse'+reqresponse);     
                ExceptionHelper.logException('PricebookEntry', ex,reqresponse, 'CC_PIM_ProductUpdates -> insertPB','Insert');
                 }
                else{
                 CC_exception_Pim_Dsa.ccpimdsa(proddetail);
              }
        
            } 
        
        if(pbeList.size()>0){
            try{
                insert pbeList;
            }catch(exception ex){
                if(isPIM){
                string responsejson=JSON.serialize(new SFDCResponse('Failure',ex.getMessage()));
                response.responseBody  = Blob.valueOf(responsejson);    
                String reqresponse = 'Request Body Product Id --->>'+String.valueof(prdid) +'\n'+'\n'+'Response Body --->> '+responsejson;
                ExceptionHelper.logException('PricebookEntry', ex,reqresponse, 'CC_PIM_ProductUpdates -> insertPB','Insert');
                 }
                else{
                 CC_exception_Pim_Dsa.ccpimdsa(proddetail);
              }
        
            } 
          }
      
       }
    }
    
    //Method to remove PBU from family name
    public static String formatFamily(String strfam){ 
        return strfam.remove('PBU').remove('pbu').normalizeSpace();
    }
}