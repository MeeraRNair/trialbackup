/*
 * Author   : Mahesh  
 * Purpose  : Created for fetching GU DUNS details for Site duns that is present in Partner Request
 * 
 * Revision CR Number       Date            Modified By     Description
 * -------- ---------   ----------      	-----------     ------------    
 * 1.0             		14-Jan-2019    		Mahesh          Created for fetching GU DUNS details for Site duns that is present in Partner Request
*/

global class Vfcntrl_FetchGUDUNS {    
    global static String getGUDUNS(string strpartnerRequestId,string strDUNSupdate){ 
        system.debug('********' +strpartnerRequestId);
        system.debug('########' +strDUNSupdate);
        string strrequestXMLString;
        string strCILresponseBody;
        string strrequestBody;
        string strresponseBody;
        string strCILResError;
        String strUSERNAME;
        String strPASSWORD;
        Integer inttotalRun;
        string strGUDunsId;
        string strGuAddress1;
        string strGuAddress2;
        string strGuCity;
        string strGuCompanyName;
        string strGuCountry;
        string strGuPostalCode;
        string strGuState;
        string strresult;
        try{
      
        Map<String, String> mapsfdcCountry = new map<string,string>();
        List<Country__c>  listcountries = new List<Country__c>();
        
        listcountries = [SELECT id,Name,Code__c FROM Country__c];
        
        for(country__c temp : listcountries ){
            mapsfdcCountry.put(temp.Code__c,temp.Name );
        }
        
        strrequestXMLString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cil="CIL" xmlns:dell="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Response">'
            +'<soapenv:Header/>'
            +'<soapenv:Body>'
            +'<cil:GetEnglishAndLocalAddreses>'
            +'<cil:address>'  
            +' <dell:ApplicationName>SFDC</dell:ApplicationName>'         
            +'<dell:DunsId>'+strDUNSupdate+'</dell:DunsId>'
            +'<dell:IsAcctObjRequire>N</dell:IsAcctObjRequire>'
            +'</cil:address>'
            +'</cil:GetEnglishAndLocalAddreses>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>'; 
        
        // Creating request       
        Httprequest request = new Httprequest(); //header
        request.setMethod('POST');
        request.setHeader('Content-Type','text/xml;charset=UTF-8');
        request.setHeader('SOAPAction','CIL/IExploreAffinity/GetEnglishAndLocalAddreses');          
        request.setEndpoint(System.Label.Affinity_SandBox_Endpoint);
        strUSERNAME =System.Label.Affinity_SandBox_UserName;
        strPASSWORD = System.Label.Affinity_SandBox_Pwd;                      
        Blob blbheaderValue = Blob.valueOf(strUSERNAME + ':' + strPASSWORD);
        String strauthorizationHeader = 'Basic ' + EncodingUtil.base64Encode(blbheaderValue);
        request.setHeader('Authorization', strauthorizationHeader);
        request.setBody(strrequestXMLString);
        request.setTimeout(integer.valueOf(System.Label.Deal_Reg_timeout_variable)); //100000
        httpresponse responseXML;
        Http http = new Http();
        //retrying in case of failure 
        for(Integer inta = 0; inta <= integer.valueOf(System.Label.Deal_Reg_retry_count_variable); inta++){
            System.debug('Before Send:'+DateTime.now());
            responseXML = http.send(request);  
            system.debug('**Response '+responseXML);
            System.debug('After Send:'+DateTime.now());             
            if(responseXML.getstatuscode() == 200){
                strCILresponseBody = responseXML.getBody();
                system.debug('strCILresponseBody*****'+strCILresponseBody);
                inttotalRun = inta+1;
                break;
            }
        }                                   
        strCILResError = responseXML.getStatus();
            
         System.debug('Cilere*****6666:'+strCILResError);
        strrequestBody = request.getBody();
        strresponseBody = responseXML.getBody();
        
        if(!strCILResError.contains('OK')){
            
           // insert exception record                  
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'Fetch GU Details';
            exceptionRecord.Object_type__c = 'Parnter Request';
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c =  responseXML.getStatus() +' '+responseXML.getStatusCode() ;
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
            
            if(resultStatus.isSuccess()){
                attachment reqattachment = new attachment();
                reqattachment.Body = Blob.valueOf(request.getBody());
                reqattachment.Name = 'Request.txt';
                reqattachment.ParentId=  exceptionRecord.Id;
                database.insert(reqattachment);
            }
                strresult = 'Failed';            
        }else if(strresponseBody.contains('faultcode')){
            string strfaultString;            
            Dom.Document doc = new Dom.Document();
            doc.load(strCILresponseBody);
            Dom.XMLNode rootElement = doc.getRootElement();//envelope
            Dom.XMLNode body = rootElement.getChildElements()[0];//body
            for(Dom.XMLNode faultChildElements : body.getChildElements()){
             If(faultChildElements.getName() == 'faultstring'){
                    strfaultString = faultChildElements.getText();
                }        
            }
           
            // insert exception record                  
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'Fetch GU Details';
            exceptionRecord.Object_type__c = 'Parnter Request';
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c = strfaultString;
            if(Test.isRunningTest()){ 
            exceptionRecord.Error_Messages__c = 'strfaultString';
            }
            //system.debug('****userinfo.getUserId()******' +database.insert(exceptionRecord));
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
            system.debug('****strresult status******' +resultStatus);
            if(resultStatus.isSuccess()){
                list<attachment> listattach = new list<attachment>();
                attachment reqattachment = new attachment();
                reqattachment.Body = Blob.valueOf(request.getBody());
                reqattachment.Name = 'Request.txt';
                reqattachment.ParentId=  exceptionRecord.Id;
                listattach.add(reqattachment);
                
                attachment responseattachment = new attachment();
                responseattachment.Body = Blob.valueOf(responseXML.getBody());
                responseattachment.Name = 'Response.txt';
                responseattachment.ParentId=  exceptionRecord.Id;
                listattach.add(responseattachment);
                
                database.insert(listattach);
            }  
                strresult = 'Failed';

        }else{
            Dom.Document doc = new Dom.Document();
            doc.load(strCILresponseBody);
            system.debug('strCILresponseBody '+strCILresponseBody);
            Dom.XMLNode rootElement = doc.getRootElement();//envelope
            Dom.XMLNode body = rootElement.getChildElements()[0];//body
            Dom.XMLNode getEnglishAndLocalAddresesResponse = body.getChildElements()[0];//GetEnglishAndLocalAddresesResponse
            Dom.XMLNode getEnglishAndLocalAddresesResult = getEnglishAndLocalAddresesResponse.getChildElements()[0];//GetEnglishAndLocalAddresesResult
            Dom.XMLNode commonSearchResponse = getEnglishAndLocalAddresesResult.getChildElements()[0];//CommonSearchResponse
            Dom.XMLNode commonSearchResponseBObj = commonSearchResponse.getChildElements()[0];//CommonSearchResponseBObj
            for(Dom.XMLNode commonSearchResponseBObjChildElements : commonSearchResponseBObj.getChildElements()){
                If(commonSearchResponseBObjChildElements.getName() == 'GUDunsId'){
                    system.debug('****' +commonSearchResponseBObjChildElements.getText());
                    strGUDunsId = commonSearchResponseBObjChildElements.getText();
                    system.debug('GUDunsId' +strGUDunsId);
                }      
                if(strGUDunsId != '-1'){
                    If(commonSearchResponseBObjChildElements.getName() == 'GuAddress1'){
                        strGuAddress1 = commonSearchResponseBObjChildElements.getText();
                    }
                    If(commonSearchResponseBObjChildElements.getName() == 'GuAddress2'){
                        strGuAddress2 = commonSearchResponseBObjChildElements.getText();
                    }
                    If(commonSearchResponseBObjChildElements.getName() == 'GuCity'){
                        strGuCity = commonSearchResponseBObjChildElements.getText();
                    }
                    If(commonSearchResponseBObjChildElements.getName() == 'GuCompanyName'){
                        strGuCompanyName = commonSearchResponseBObjChildElements.getText();
                    }
                    If(commonSearchResponseBObjChildElements.getName() == 'GuCountryCode'){
                        strGuCountry = mapsfdcCountry.get(commonSearchResponseBObjChildElements.getText());                               
                    }
                    If(commonSearchResponseBObjChildElements.getName() == 'GuPostalCode'){
                        strGuPostalCode = commonSearchResponseBObjChildElements.getText();
                    }
                    If(commonSearchResponseBObjChildElements.getName() == 'GuState'){
                        strGuState = commonSearchResponseBObjChildElements.getText();
                    }
                }
            }
            if(strGUDunsId != '-1' ){
                system.debug('GUDunsId' +strGUDunsId);
                Partner_Request__c partnerRequest = new Partner_Request__c();
                partnerRequest.id = strpartnerRequestId;
                if((strGuAddress1 + strGuAddress2).length() > 255){
                    partnerRequest.GU_HQ_DUNSAddress__c = strGuAddress1; 
                }else{
                    partnerRequest.GU_HQ_DUNSAddress__c = strGuAddress1 +' '+strGuAddress2;
                }
                partnerRequest.GU_HQ_DUNSAddress__c = strGuAddress1;
                partnerRequest.GU_HQ_DUNSBusinessName__c = strGuCompanyName;
                partnerRequest.GU_HQ_DUNSCity__c = strGuCity;
                partnerRequest.GU_HQ_DUNSCountry__c = strGuCountry;
                partnerRequest.GU_HQ_DUNSID__c = strGUDunsId;
                partnerRequest.GU_HQ_DUNSPostalCode__c = strGuPostalCode;
                partnerRequest.GU_HQ_DUNSState__c = strGuState;
                update partnerRequest;
                strresult = 'Success';
             }
            else{
                strresult = 'Success';
                system.debug('*** NO GU DETAILS FOUND****');
            }
        }
        
    }catch(exception ex){
         system.debug('Exception Occured in getGUDUNS Method' +ex.getMessage());  
    }
        return strresult;//new PageReference(returnURL); 
    }
}