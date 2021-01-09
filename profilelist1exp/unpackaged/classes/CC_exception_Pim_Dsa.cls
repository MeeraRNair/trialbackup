public class CC_exception_Pim_Dsa {
        //For validation
        //Change from CC_pim to ccpim and CC_pimex to ccpimex , change CC_pim_dsa to ccpimdsa
     public static void ccpim(System.RestResponse response,string responsejson,string jSONRequestBody,string action ){
               response.statusCode = 500;
               response.responseBody  = Blob.valueOf(responsejson);
               String reqresponse = 'Request Body --->>'+jSONRequestBody +'\n'+'\n'+'Response Body --->> '+responsejson;
               if(action=='BaseMerge'){
               ExceptionHelper.logException('Product2','Something went wrong in BaseMerge if Condition',reqresponse, 'IF Condition BaseMerge','BaseMerge');
              } 
              else if(action=='MonarchMerge'){
              ExceptionHelper.logException('Product2','Something went wrong in MonarchMerge if Condition',reqresponse, 'IF Condition MonarchMerge','MonarchMerge');
              }
             else if(action=='MonarchDelete'){
              ExceptionHelper.logException('Product2','Something went wrong in MonarchDelete if Condition',reqresponse, 'IF Condition MonarchDelete','MonarchDelete');
             }
             else if(action=='BaseDelete'){
            ExceptionHelper.logException('Product2','Something went wrong in BaseDelete if Condition',reqresponse, 'IF Condition BaseDelete','BaseDelete');
              }
        // For Exception
             else if(action=='ProductValidate'){
             ExceptionHelper.logException('Product2','Product Does not exists in SFDC',reqresponse,'Check the product in SFDC or Null pointer','ProductValidate');
         }
       
     }
    public static void ccpimex(System.RestResponse response,Exception ex,string responsejson,string jSONRequestBody,string action ){
               response.statusCode = 500;
               response.responseBody  = Blob.valueOf(responsejson);
               String reqresponse = 'Request Body --->>'+jSONRequestBody +'\n'+'\n'+'Response Body --->> '+responsejson;  
    
              if(action=='InsertPIM'){
              ExceptionHelper.logException('Product2_PIM_Mapping__c', ex,reqresponse, 'CC_PIM_ProductUpdates -> InsertPIM','Insert');
                  }
              else if(action=='BaseDeletePIMProd'){
             ExceptionHelper.logException('Product2_PIM_Mapping__c & Product2', ex, reqresponse,'CC_PIM_ProductUpdates -> deletemethod','Delete');
               }
              else if(action=='MonarchDeletePIMProd'){
            ExceptionHelper.logException('Product2_PIM_Mapping__c & Product2', ex,reqresponse, 'CC_PIM_ProductUpdates -> deletemethodMon','Delete');
               }
             else if(action=='updatePIM'){
                 ExceptionHelper.logException('Product2_PIM_Mapping__c', ex,reqresponse, 'CC_PIM_ProductUpdates -> updatePIM', 'Update'); 
            
               }
             else if(action=='updatePRD'){
                  ExceptionHelper.logException('Product2',ex,reqresponse, 'CC_PIM_ProductUpdates -> updatePRD', 'Update');
                }
             else if(action=='insertPRD'){
             ExceptionHelper.logException('Product2', ex,reqresponse, 'CC_PIM_ProductUpdates -> insertPRD','Insert');
            }
          }
    
    public static void ccpimdsa(CC_ProductDetails proddetail){
        String reqresponse = 'DSA Request Body --->>'+proddetail;
        ExceptionHelper.logException('DSA','DSA Exception',reqresponse, 'DSA insertPRD','DSA Exception');
    }
}