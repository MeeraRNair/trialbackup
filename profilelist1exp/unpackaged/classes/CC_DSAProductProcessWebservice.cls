/*===========================================================================+
|  HISTORY                                                                  
|                                                                           
|  DATE(DD.MM.YYYY)            DEVELOPER               CR#                  DESCRIPTION                               
|  ====                        =========               ==                  =========== 
|   09/Oct/2018                  Meera                                       Initial Creation.SOAP API for DSA to add lineitem
|   22/Jan/2019					 Meera										Changes based on DSA Discussion
|   05/Aug/2019					 Meera										Create PIM Details section And put PIM Details for Quoted 		Item                                                                    
===========================================================================*/

global with sharing class CC_DSAProductProcessWebservice {
    
    //Request Structure
    global class DSARequest{
        webservice String Operation;        
        webservice Decimal Quantity;
        webservice Decimal Listprice;
        webservice Decimal Margin;
        webservice Decimal Discount_off ;
        webservice String Quotenumber;
        webservice String Ordercode_SKU;
        webservice String BaseSKUNumber;
        webservice String BaseSKUClass;
        webservice String ProductType;
        webservice String ProductDescription;
        webservice String SfdclineItemId;
        webservice String dealId;
        webservice String Base_SKU_Description;
        
    }
    
    //Response Strucutre
    global class DSAResponse{
        webservice String SfdclineItemId;
        webservice String ProductDescription;
        webservice String Status;
        webservice String Message;
        webservice String StatusCode;
		webservice boolean overide;
    }
    
    webservice static DSAResponse addOppLineItem(DSARequest request) {
        system.debug('Msg DSA request'+request);
        DSAResponse resp = new DSAResponse();
		resp.overide = false;
        // Check operation type
        
        try{
			//System.debug('###Inside try'+system.now());
			//query PIM mapping and check if we have that product available there
			List<Product2_PIM_Mapping__c> listPIM = [Select id,Brand_Category_Code__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c=:request.BaseSKUClass and IsActive__c =true limit 1];
			system.debug('listPIM inside ordercode '+listPIM);
			//add validation
            if(request.Operation == 'Addlineitem' && (request.Quantity == null || request.Listprice == null ||  request.Ordercode_SKU == null|| request.BaseSKUNumber == null || request.BaseSKUClass == null || request.ProductType == null || request.ProductDescription == null ||request.dealId==null||  request.Ordercode_SKU == ''|| request.BaseSKUNumber == '' || request.BaseSKUClass == '' || request.ProductType == '' || request.ProductDescription == ''||request.dealId=='')){  //1             
                
				System.debug('###Inside validation');
				//Log Exception
				logException(resp,'Any one or more of the required fields are missing in the request:Quantity,Listprice,Ordercode_SKU,BaseSKUNumber,BaseSKUClass,ProductType,ProductDescription.','Failure','OpportunityLineItem',request,'Addlineitem','422',null);                
				return resp;
            }
			
			
			//product exists
			else if(request.Operation == 'Addlineitem' && validatecatalog(resp,request,'Addlineitem') && request.ProductType=='Ordercode' && listPIM.size()>0){//2 change that as else if 
				insertOpportunityLineItem(request,listPIM[0].SFDC_Prod_ID__C,resp,listPIM[0].id);
				system.debug('--->>>>'+resp);
				return resp;
			}       
                            
			else if(request.Operation == 'Addlineitem' && validatecatalog(resp,request,'Addlineitem') && request.ProductType=='Ordercode' && listPIM.size()==0){//1
				system.debug('snpinside'+request.ProductType);
				//Query PIM and see if this product exists in PIM
				String strjSONResponseBody = httpcall('Ordercode',request.BaseSKUNumber);
				system.debug('insideelse'+strjSONResponseBody);
				CC_PIMBaseProdHierarchy proddetailbase = (CC_PIMBaseProdHierarchy)JSON.deserialize(strjSONResponseBody,CC_PIMBaseProdHierarchy.class);
				system.debug('itembase'+proddetailbase);
				system.debug('proddetailbase'+proddetailbase.ITEM_LIST[0].ERROR_INFO);
				
				if(proddetailbase.ITEM_LIST[0].ERROR_INFO == null && proddetailbase.ITEM_LIST[0].ITEM_CLASS_ID !=null){//2
					system.debug('proddetailbase'+proddetailbase);
					//Create CC_ProductDetails for product insert
					//CC_ProductDetails.Data datdetail = new CC_ProductDetails.Data('test');
					CC_ProductDetails.Data datdetail = new CC_ProductDetails.Data(proddetailbase.ITEM_LIST[0].TYPE_CODE,proddetailbase.ITEM_LIST[0].TYPE_DESC,proddetailbase.ITEM_LIST[0].GROUP_CODE,proddetailbase.ITEM_LIST[0].GROUP_DESC,proddetailbase.ITEM_LIST[0].LOB_CODE,proddetailbase.ITEM_LIST[0].LOB_DESC,null,null,proddetailbase.ITEM_LIST[0].PRODUCT_LINE,proddetailbase.ITEM_LIST[0].PRODUCT_LINE_DESC,null,null,proddetailbase.ITEM_LIST[0].FAMILY_PARENT,proddetailbase.ITEM_LIST[0].FAMILY_PARENT_DESC,null,null,proddetailbase.ITEM_LIST[0].FAMILY,proddetailbase.ITEM_LIST[0].FAMILY_DESC,null,null,proddetailbase.ITEM_LIST[0].BASE_CODE,proddetailbase.ITEM_LIST[0].BASE_CODE_DESC,null,null,proddetailbase.ITEM_LIST[0].ITEM_CLASS_ID,proddetailbase.ITEM_LIST[0].ITEM_CLASS_DESC);
					System.debug('##datdetail:'+datdetail);
					
					CC_ProductDetails det = new CC_ProductDetails();
					det.Action = 'BaseMerge';
					det.Attempt = 1;                            
					det.Data = new List<CC_ProductDetails.Data>();
					det.Data.add(datdetail); 
					System.debug('##det:'+det);
					//call Product insert
					String strprodId = CC_PIM_ProductUpdates.ccpimprod(det);
					system.debug('--->>>>prodId'+strprodId);
					if(strprodId!=null){//3
						insertOpportunityLineItem(request,strprodId,resp,null);
					}
					else{
						logException(resp,'Product cannot be added since this is not a valid product in  SFDC','Failure','OpportunityLineItem',request,'Addlineitem','404',null);
					}
					
				}
				//Log Exception
				if(proddetailbase.ITEM_LIST[0].ERROR_INFO != null){//2
					logException(resp,'Product cannot be added since this is not a valid product in  SFDC','Failure','OpportunityLineItem',request,'Addlineitem','404',null);
				}
				system.debug('--->>>>'+resp);                           
				return resp;
			}
                        //}
                        
			else if(request.Operation == 'Addlineitem' && validatecatalog(resp,request,'Addlineitem') && request.ProductType=='Snp' ){//1
				system.debug('Inside else SNP : '+request.ProductType);
				//Call PIM and try to retrieve details
				String strjSONResponseBody = httpcall('Snp',request.BaseSKUNumber);
				system.debug('inside snp'+strjSONResponseBody);
				//deserialize the request body to list of wrapper
				CC_PIMProdHierarchy proddetail = (CC_PIMProdHierarchy)JSON.deserialize(strjSONResponseBody,CC_PIMProdHierarchy.class);
				system.debug('proddetail ==='+proddetail.ITEM_LIST[0].PRODUCT_OFFERING_CODE); 
				//Identiy the corresponding SFDC Product2
				if(proddetail.ITEM_LIST[0].ERROR_INFO =='' && proddetail.ITEM_LIST[0].PRODUCT_OFFERING_CODE !=''){//2
					//query PIM mapping and check if we have that product available there
					List<Product2_PIM_Mapping__c> listPIM1 = [Select id,Brand_Category_Code__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c=:proddetail.ITEM_LIST[0].PRODUCT_OFFERING_CODE limit 1];
					if(listPIM1.size()>0){
						insertOpportunityLineItem(request,listPIM1[0].SFDC_Prod_ID__C,resp,listPIM1[0].id);
						return resp;
					}
					else{//3
						//product does not exist in SFDC so insert item
						//Create CC_ProductDetails for product insert
						//CC_ProductDetails prddet = new CC_ProductDetails();
						//CC_ProductDetails.Data datdetail1 = new CC_ProductDetails.Data('test');
						CC_ProductDetails.Data datdetail1 = new CC_ProductDetails.Data(proddetail.ITEM_LIST[0].TYPE_CODE,proddetail.ITEM_LIST[0].TYPE_DESC,proddetail.ITEM_LIST[0].GROUP_CODE,proddetail.ITEM_LIST[0].GROUP_DESC,proddetail.ITEM_LIST[0].LOB_CODE,proddetail.ITEM_LIST[0].LOB_DESC,proddetail.ITEM_LIST[0].CATEGORY,proddetail.ITEM_LIST[0].CATEGORY_DESC,null,null,proddetail.ITEM_LIST[0].PRODUCT_TYPE,proddetail.ITEM_LIST[0].PRODUCT_TYPE_DESC,null,null,proddetail.ITEM_LIST[0].PORTFOLIO,proddetail.ITEM_LIST[0].PORTFOLIO_DESC,null,null,proddetail.ITEM_LIST[0].OFFERING_GROUP,proddetail.ITEM_LIST[0].OFFERING_GROUP_DESC,null,null,proddetail.ITEM_LIST[0].PRODUCT_OFFERING_CODE,proddetail.ITEM_LIST[0].PRODUCT_OFFERING_CODE_DESC,null,null);
						
						System.debug('##datdetail1:'+datdetail1);
						CC_ProductDetails det1 = new CC_ProductDetails();
						System.debug('##det1:'+det1);
						det1.Action = 'MonarchMerge';
						det1.Attempt = 1;
						det1.Data = new List<CC_ProductDetails.Data>();
						det1.Data.add(datdetail1); 
						System.debug('det1:'+det1);
						//call Product insert
						String strprodId = CC_PIM_ProductUpdates.ccpimprod(det1);
						if(strprodId!=null){//4
							insertOpportunityLineItem(request,strprodId,resp,null);
						}
						else{
							logException(resp,'Product cannot be added since this is not a valid product in  SFDC','Failure','OpportunityLineItem',request,'Addlineitem','404',null);
						}
					}
				}
				
				
				else{
					//Log Exception
					logException(resp,'Product cannot be added since this is not a valid product in  SFDC','Failure','OpportunityLineItem',request,'Addlineitem','404',null);         
					return resp;
				}
			}

            
        }catch(Exception e){
            System.debug('Exception Occured');            
            logException(resp,'Request could not be processed by Salesforce. If problem persists please raise trouble ticket.','Failure','OpportunityLineItem',request,'Addlineitem','500',e);    
            system.debug('--->>>>'+resp);
            return resp;
        }
        
        
        //resp = new DSAResponse();
        //resp.
        return resp;
        
    }
    
    public static void insertOpportunityLineItem(DSARequest request, String strprdId, DSAResponse resp, String strpimId){
        //get Pricebook of OpportunityLineItem
        List<Opportunity> listopp = [SELECT ID,pricebook2Id,CurrencyIsoCode FROM Opportunity WHERE Deal_ID__c = :request.dealId];
        if(listopp.size()>0){
            //Get Pricebook Entry for product2 related to related opportunity CurrencyIsoCode/PriceBook2Id
            List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :strprdId AND PriceBook2Id = :listopp[0].pricebook2Id  AND CurrencyIsoCode = :listopp[0].CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true];
            if(listpbe.size()>0){
				//Query PIM details
				List<Product2_PIM_Mapping__c> listPIM;
				if(strpimId == null){
					listPIM = [Select id,Brand_Category_Code__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c=:request.BaseSKUClass and IsActive__c =true and SFDC_Prod_ID__C = :strprdId limit 1];
					strpimId = listPIM[0].id;
				}
                system.debug('listpbe'+listpbe);
                //Create opportunity line item
                OpportunityLineItem opplineit = new OpportunityLineItem();
                opplineit.OpportunityId = listopp[0].id ;
                opplineit.Product2Id = strprdId;
                opplineit.PricebookEntryId = listpbe[0].id;
                opplineit.Order_Code__c = request.Ordercode_SKU;
                //opplineit.Item_Class_Code__c = request.;
                opplineit.Quote__c = request.Quotenumber;
                opplineit.Quantity = request.Quantity;
                opplineit.Mrgn__c = request.Margin;
                opplineit.UnitPrice = request.Listprice;
                opplineit.Product_SKU__c = request.BaseSKUNumber;
                opplineit.Discount_off__c = request.Discount_off;
                opplineit.Product_Description_Opportunitylineitem__c = request.ProductDescription;
				opplineit.DSA_Base_SKU_Description__c = request.Base_SKU_Description;
				opplineit.Product2_PIM_Mapping__c = strpimId;
                insert opplineit;
                //Get lineitem uniqueid
                List<OpportunityLineItem> listoli = [Select Product_Line_ID__c,product2.name, id from OpportunityLineItem where id=:opplineit.id];
                
                resp.Status='Success';
                resp.Statuscode = '200';
                resp.SfdclineItemId = listoli[0].Product_Line_ID__c;
                resp.ProductDescription = listoli[0].product2.name;
                
            }
            else{
                //Log Exception
                logException(resp,'Opportunity is not associated with any Catalog','Failure','OpportunityLineItem',request,'Addlineitem','500',null);
                
            }
        }
        
        else{
            //Log Exception
            logException(resp,'Deal does not exists in salesforce','Failure','OpportunityLineItem',request,'Addlineitem','404',null);                
        }
        system.debug('END TIME ---'+SYSTEM.now());
    }
    
    public static void logException(DSAResponse resp,String strmessage, String strstatus,String strobj,DSARequest req, String stroperation, String strstatuscode, Exception ex){
        resp.Status = strstatus;
        resp.Message = strmessage;
        resp.statuscode = strstatuscode;
        String strreqresponse = 'Request Body --->>'+String.valueof(req) +'\n'+'\n'+'Response Body --->> '+String.valueof(resp);
        ExceptionHelper.strexceptiontypelist ='SFDC_DSA_Integration';
		if(ex == null){
			ExceptionHelper.logException(strobj,resp.Message,strreqresponse, stroperation,stroperation);
		}
        else{
			ExceptionHelper.logException(strobj,ex,strreqresponse,'CC_DSAProductProcessWebservice',stroperation);
		}
        
    }
    
    public static String httpcall(String strprodType, String strprodsku){
        Http h = new Http();
        String strendpoint;
        String strapikey;
        Map<String,CC_PIM_Integration__mdt> mapint = new Map<String,CC_PIM_Integration__mdt>();
        List<CC_PIM_Integration__mdt> listing = [SELECT API_Key__c,DeveloperName,Endpoint__c,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM CC_PIM_Integration__mdt];
        for(CC_PIM_Integration__mdt pim : listing){
            mapint.put(pim.DeveloperName,pim);
        }
        
        //check type of enviornment
        if (StaticFactory.getEnvironment() == 'Sandbox') {
            if(strprodType == 'Ordercode'){
                strendpoint = mapint.get('Base_Product_Sandbox').Endpoint__c;
                strapikey = mapint.get('Base_Product_Sandbox').API_Key__c;
            }
            
            else{
                strendpoint = mapint.get('MonarchProduct_Sandbox').Endpoint__c; 
                strapikey = mapint.get('MonarchProduct_Sandbox').API_Key__c;
            }
        }
        else{
            if(strprodType == 'Ordercode'){
                strendpoint = mapint.get('Base_Product_Production').Endpoint__c;
                strapikey = mapint.get('Base_Product_Production').API_Key__c;
            }
            
            else{
                strendpoint = mapint.get('MonarchProduct_Production').Endpoint__c;
                strapikey = mapint.get('MonarchProduct_Production').API_Key__c;
            }
            
        }
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        //String url = 'https://sit.apidp.dell.com/product/pimapi/v1/getMonarchHierarchy?strapikey=c0023042-692c-4cfe-9958-99828c74809b&itemName='+request.BaseSKUNumber; 
        String strurl = strendpoint+strapikey+'&itemName='+strprodsku;
		System.debug('endpoint:'+strurl);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(strurl);
        req.setMethod('GET');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        System.debug('res.getBody()'+res.getBody());
        String strjSONResponseBody=res.getBody();
        // response body request
        system.debug('strjSONResponseBody=='+strjSONResponseBody);
        return strjSONResponseBody;
    }
    webservice static DSAResponse validate(DSARequest request) {
        DSAResponse resp = new DSAResponse() ;
		resp.overide = false;
        try{
            //Add field validation
            system.debug(request); 
            system.debug('Inside Validate');
            if( request.BaseSKUNumber == null || request.BaseSKUClass == null || request.ProductType == null || request.ProductDescription == null || request.SfdclineItemId==null || request.dealId==null||request.Ordercode_SKU == null||request.BaseSKUNumber == '' || request.BaseSKUClass == '' || request.ProductType == '' || request.ProductDescription == '' ||request.SfdclineItemId=='' || request.dealId==''||request.Ordercode_SKU == ''){//1
                system.debug('Inside Exception');                
                logException(resp,'Any one or more of the required fields are missing in the request:Quantity,Listprice,Quotenumber,Ordercode_SKU,BaseSKUNumber,BaseSKUClass,ProductType,ProductDescription,Opportunilylineitemid,Deal id.','Failure','OpportunityLineItem',request,'Validate','422',null);                
                return resp;
            }
            
            else if(validatecatalog(resp,request,'validate')){//1
                //if(){//2
                    system.debug('Inside else'); 
					String strerror = request.ProductDescription + ' is not associated with Opportunity. You can Add item to Deal or Replace existing item below on Deal.';
                    //check product type
                    //Get OpportunityLineItem details
                    List<OpportunityLineItem> listoli = [Select Product_Line_ID__c,product2.name,product2id, id from OpportunityLineItem where Product_Line_ID__c =:request.SfdclineItemId];
                    if(listoli.size()>0 && request.ProductType=='Ordercode'){//2
                       
                            //get corresponding product ID
                            List<Product2_PIM_Mapping__c> listPIM = [Select id,Brand_Category_Code__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c=:request.BaseSKUClass and IsActive__c =true limit 1];
                            if(listPIM.size()>0 && listPIM[0].SFDC_Prod_ID__C ==listoli[0].product2id ){//5
                                System.debug(listPIM);
								listoli[0].Product2_PIM_Mapping__c = listPIM[0].id;
								update listoli[0];
                                //Product matches                        
                                resp.status = 'Success';
                                resp.statuscode = '200';
                                resp.Message = 'Selected Salesforce Product is Matching with Request';
                            }
                            else{                         
                                logException(resp,strerror,'Failure','OpportunityLineItem',request,'Validate','200',null);
                            }
					}
                        
					else if(listoli.size()>0 && request.ProductType=='Snp'){//2
						system.debug('Request pro : '+request.ProductType);
						//Get product corresponding to SKU
						String strjSONResponseBody = httpcall('https://sit.apidp.dell.com/product/pimapi/v1/getMonarchHierarchy?apikey=c0023042-692c-4cfe-9958-99828c74809b&itemName=',request.BaseSKUNumber);
						//deserialize the request body to list of wrapper
						system.debug('strjSONResponseBody12'+strjSONResponseBody);
						CC_PIMProdHierarchy proddetail = (CC_PIMProdHierarchy)JSON.deserialize(strjSONResponseBody,CC_PIMProdHierarchy.class);
						system.debug('proddetail ==='+proddetail); 
						//Identiy the corresponding SFDC Product2
						//query PIM mapping and check if we have that product available there
						List<Product2_PIM_Mapping__c> listPIM1 = [Select id,Brand_Category_Code__c,SFDC_Prod_ID__C,Classcode_Prod_Offer_Code__c,ProdType__c,Product_Offering_Description__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c=:proddetail.ITEM_LIST[0].PRODUCT_OFFERING_CODE limit 1];
						
						if(proddetail.ITEM_LIST[0].ERROR_INFO == '' && proddetail.ITEM_LIST[0].PRODUCT_OFFERING_CODE !='' && listPIM1.size()>0 && listPIM1[0].SFDC_Prod_ID__C == listoli[0].product2id){//3						
							
							//Product matches 
							listoli[0].Product2_PIM_Mapping__c = listPIM1[0].id;
							update listoli[0];
							resp.status = 'Success'; 
							resp.statuscode = '200';
							resp.Message = 'Selected Salesforce Product is Matching with Request';
							
						}
						else{
							logException(resp,strerror,'Failure','OpportunityLineItem',request,'Validate','200',null);
						}
					}                    
                    else{                
                        logException(resp,'Not a valid Line Item Id in salesforce','Failure','OpportunityLineItem',request,'Validate','404',null);
                    }               
            }
            System.debug(resp);
            return resp;
            
        }catch(Exception e){
            System.debug('Exception Occured');            
            logException(resp,'Request could not be processed by Salesforce','Failure','OpportunityLineItem',request,'Validate','500',e);
            return resp;
        }
    }
    
    webservice static DSAResponse replace(DSARequest request) {
        //validate request
        DSAResponse resp = new DSAResponse();
		resp.overide = false;
        try{
            //Add field validation
            system.debug(request); 
            system.debug('Inside Replace');
            if( request.BaseSKUNumber == null || request.BaseSKUClass == null || request.ProductType == null || request.ProductDescription == null || request.SfdclineItemId==null || request.dealId==null||request.Quantity == null || request.Listprice == null ||request.Ordercode_SKU == null||request.BaseSKUNumber == '' || request.BaseSKUClass == '' || request.ProductType == '' || request.ProductDescription == '' ||request.SfdclineItemId=='' || request.dealId==''||request.Ordercode_SKU == '' ){
                system.debug('Inside Exception');               
                logException(resp,'Any one or more of the required fields are missing in the request:Quantity,Listprice,Quotenumber,Ordercode_SKU,BaseSKUNumber,BaseSKUClass,ProductType,ProductDescription,Opportunilylineitemid,Deal id.','Failure','OpportunityLineItem',request,'replace','422',null);                
                return resp;
            }
            
            else{
                if(validatecatalog(resp,request,'replace')){
                    system.debug('Inside else'); 
                    //check product type
                    //Get OpportunityLineItem details
                    List<OpportunityLineItem> listoli = [Select Product_Line_ID__c,product2.name,product2id, id from OpportunityLineItem where Product_Line_ID__c =:request.SfdclineItemId];
                    System.debug('listoli:'+listoli);
                    
                    request.Operation = 'addlineitem';
                    resp = addOppLineItem(request);
                    System.debug('###resp:'+resp);
                    if(listoli.size()>0 && resp.statuscode=='200'){
                        delete listoli;
                    }
                    else if(listoli.size()== 0){
                        
                        logException(resp,'Product to be deleted is not valid. If problem persists please raise trouble ticket','Failure','OpportunityLineItem',request,'replace','404',null);    
                        return resp;
                    }
                }
                
            }
            
            return resp;
            
        }catch(Exception e){
            System.debug('Exception Occured');            
            logException(resp,'Request could not be processed by Salesforce','Failure','OpportunityLineItem',request,'replace','500',e);    
            
            return resp;
        }
    }
    
    //validate opportunity catalog
    public static boolean validatecatalog(DSAResponse resp,DSARequest req, String stroperation){
        boolean bvalid = false;
        
        //query opportunity
        List<Opportunity> listopp = [Select id,New_Catalog__c,Pricebook2Id from opportunity where deal_id__c=:req.dealId];
        System.debug('listopp:'+listopp);
        if(listopp.size()>0){
			if(listopp[0].pricebook2id == null){
				//Log Exception
                logException(resp,'Opportunity is not associated with any Catalog','Failure','OpportunityLineItem',req,stroperation,'500',null);
			}
            else if(listopp[0].New_Catalog__c == true){
                bvalid = true;                
            }
            else{
				resp.overide = false;
                logException(resp,'Opportunity belongs to old catalog','Failure','OpportunityLineItem',req,stroperation,'404',null);              
            }
        }
        else{
            logException(resp,'Deal does not exists in salesforce','Failure','OpportunityLineItem',req,stroperation,'404',null);
        }	
        return bvalid;        
    }
}