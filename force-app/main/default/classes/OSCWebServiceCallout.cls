/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#              Description
-------     ------      ----            --------    ---             -----------
1.0         
2.0         Annie        13-Oct-2014     15.10      10483 FR 9.4.1    
3.0         Annie        15-Oct-2014     15.10      Added Custom Setting
4.0         Nisha        15-June-2015    16.07      Changed from xml to Json in serialization and de-serialization. Added additional fields to the callout - Deal Registration Status, Deal Type, Deal Expiration Date, StageName. Creating exception records from the error response we get from the callout.
*/

public class OSCWebServiceCallout 
{                
    public static Boolean isRefreshBtnClicked=false;
    
    /*Objects to hold the response values*/
    public class Messages {
    }

    public class Messages_Z {
        public String Id{get;set;}
        public String Description{get;set;}
        public String ApplicationSource{get;set;}
        public String Source{get;set;}
        public String Type{get;set;}
    }

    public class Error {
        public String Region{get;set;}
        public String DealId{get;set;}
        public String IsSuccess{get;set;}
        public List<Messages_z> Messages{get;set;}
        public List<String> InvalidSolutionIdList{get;set;}
    }
    
    public Error e;
    
    /*Method to parse the response from callout*/
    public static List<Error> parse(String jsonstring) {
        
    list<exception__c> exceptionlist1 = new list<exception__c>();
    List<Error> ErrorList = new list<Error>();
    //jsonstring = '{"Error":[{"Region": "AMER","DealId": "12345","IsSuccess": "true","Messages": [{"Id": "NULL_DEAL_ID","Description": "A null Deal ID can not be assigned to Solution: AMER:225.1","ApplicationSource": "MessageApplicationSource.SCS","Source": "SCS.Saga.Solution.UpdateSolutionWithDealInfoSaga.Execute()","Type": "MessageType.Error"}],"InvalidSolutionIdList":["AMER:225.1"]},{"Region": "AMER","DealId" : "1234", "IsSuccess": "false","Messages": [{"Id": "NULL_DEAL_ID","Description": "A null Deal ID can not be assigned to Solution: {SolutionId}","ApplicationSource": "MessageApplicationSource.SCS","Source": "SCS.Saga.Solution.UpdateSolutionWithDealInfoSaga.Execute()","Type": "MessageType.Error"}],"InvalidSolutionIdList": ["12903.1"]}]}';        
        
    JSONParser parser = JSON.createParser(jsonstring);

    while (parser.nextToken() != null) 
    {
        if (parser.getCurrentToken() == JSONToken.START_ARRAY)
        {
            while(parser.nextToken() != null)
            {
                if(parser.getCurrentToken() == JSONToken.START_OBJECT)
                {
                    error e = (error)parser.readValueAs(error.class);
                    ErrorList.add(e);
                }
            }
        }
    }
        
    list<Messages_z> msglist = new list<Messages_z>();
    if(ErrorList.size() > 0){
        for(Error e: ErrorList){
            if(e.Messages != null || e.Messages.size() >0){
                for(Messages_z m: e.Messages){
                    Exception__c erec = new Exception__c();
                    erec.Object_type__c = 'Solution__c';
                    erec.Operation__c = 'Webservice Callout to OSC';
                    erec.Process_Name__c = 'OSCWebservice Callout';
                    erec.Email__c = 'no_reply@dell.com';
                    string id1 = m.Id;
                    string description1 = m.Description;
                    string type1 = m.Type;
                    String errormessage = id1+''+ description1 +''+type1;
                    erec.Error_Messages__c = errormessage;
                    string solid = string.valueof(e.InvalidSolutionIdList);
                    erec.Object_ID__c = solid;
                    
                    if(erec != null){
                        exceptionlist1.add(erec);
                    }                      
                }
            } 
        }
        
    }
        
        if(exceptionlist1.size() > 0 && isRefreshBtnClicked == false){
            insert exceptionlist1;
        }
        return ErrorList;  
    }
    
    /*Method to generate the json request*/
    public static list<error> processRequest(Map<id,Opportunity> oppMap, Map<Id,List<String>> oppIdSlnIdMap, String OSCActionIdentifier, Map<Id,List<Opportunitylineitem>> opptylineitem,boolean bolTagged){   
        System.Debug('oppIdSlnIdMap###'+oppIdSlnIdMap);
        list<error> result = new list<error>();
        list<string> sollist = new list<string>();
        map<Id,String> accountnamemap = new map<id,string>();
        List<String> jsonList = new List<String>();
        map<id,list<string>> oscidsplit = new map<id,list<string>>();
        list<solution__c> solutions = new list<solution__c>();
        HttpResponse res;
        for(Opportunity opp: oppMap.values()){
            if(oppIdSlnIdMap != null){
                if(oppIdSlnIdMap.containsKey(opp.Id)){
                   sollist.addall(oppIdSlnIdMap.get(opp.Id));
                }else {
                    oscidsplit.put(opp.id, new list<string>{opp.OSC_solution_Id__c.split(':')[1]});
                }
            }
        }
    
        if(sollist.size() > 0 || sollist != null){
            solutions = [select id, Opportunity__c, Opportunity__r.end_user_account_name__c, Opportunity__r.Account.Name, OSC_Regional_Id__c, lastmodifiedby.Profile.Name from solution__c where OSC_Regional_Id__c IN : sollist];
        }
    
        if(solutions.size() > 0){   
            for(solution__c sl: solutions){
                             
                string oscid = sl.OSC_Regional_Id__c.split(':')[1];
                oscidsplit.put(sl.Opportunity__c, new list<string>{oscid});
                
            }
        } else{
            for(Opportunity op: oppMap.values()){
                if(!oppIdSlnIdMap.values().isEmpty()){
                    String s = string.join(oppIdSlnIdMap.get(op.id), ',');
                    string p = s.split(':')[1];
                    list<string> oscidlist = p.split(',');
                    oscidsplit.put(op.id, oscidlist);
                }
            }
        }
        
        
        
        
        if(oppMap.size()>0){
            
            
            for(Opportunity opp: oppMap.values() ){
                JSONGenerator gen = JSON.createGenerator(true);
                
                gen.writeStartObject();
               
                if(oppIdSlnIdMap.containsKey(opp.Id)){
                    string region = oppIdSlnIdMap.get(opp.Id)[0].split(':')[0];
                    gen.writeStringField('Region',(region != null ? region: 'None'));
                }
                
                gen.writeStringField('Id',(opp.deal_id__c != null ? opp.deal_id__c: 'None'));
                if(OSCActionIdentifier == 'Association' || OSCActionIdentifier == 'DealSync'){
                    gen.writeStringField('Status',(opp.Deal_Registration_Status__c != null? opp.Deal_Registration_Status__c: 'None'));
                    gen.writeStringField('Stage',(opp.StageName != null ? opp.StageName: 'None'));
                    gen.writeStringField('Type',(opp.Deal_Type__c != null ? opp.Deal_Type__c: 'None' ));
                }
                gen.writeStringField('SFDCId', (opp.Id != null ? opp.Id : 'None'));
                
                if(OSCActionIdentifier == 'Association' || OSCActionIdentifier == 'DealSync'){
                    gen.writeStringField('Name',(opp.Name != null ? opp.Name : 'None'));
               
                    gen.writeStringField('AccountName', (opp.Account.Name != null? opp.Account.Name:(opp.end_user_account_name__c != null ? opp.end_user_account_name__c : 'None')));
              
                    gen.writeStringField('ExpiryDate',(String.valueof(opp.Deal_Expiration_Date__c) != null ? String.valueof(opp.Deal_Expiration_Date__c) : 'None'));
                
                ////Anamika- send Opportunity_Customer_Number__c & End_User_Account_ID__c info to OSC
                    gen.writeStringField('CustomerNumber', (opp.Opportunity_Customer_Number__r.Name != null ? opp.Opportunity_Customer_Number__r.Name: 'None'));
                    gen.writeStringField('EndUserAffinityID', (opp.Affinity_ID__c != null ? opp.Affinity_ID__c: 'None'));
                 if(opp.Unassigned_End_User__c != null){
                    gen.writeStringField('UnassignedEndUser', opp.Unassigned_End_User__c);
                    }
                }
                
                 if(opp.Unweighted_Rev_USD__c != null && (OSCActionIdentifier == 'Association' || OSCActionIdentifier == 'ProductSync')){
                    gen.writeNumberField('DealSize', opp.Unweighted_Rev_USD__c);
                   }
                  
                                 
                if(OSCActionIdentifier == 'Association' && opp.PartnerAccount != null && opp.PartnerAccount.Partner_Track__c != null){
                    gen.writeStringField('Track_Account_Id', opp.PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c);
                    gen.writeStringField('Track_Name', opp.PartnerAccount.Partner_Track__r.name);
                    gen.writeStringField('Sales_Motion_Id', opp.partnerAccount.Account_id__c);
                    gen.writeStringField('Sales_Motion_Name', opp.PartnerAccount.name);
                   gen.writeBooleanField('IsTaggedDeal',bolTagged);

                   
                 }
                              
                if(oscidsplit.containsKey(opp.Id) && OSCActionIdentifier == 'Association'){
                      gen.writeObjectField('SolutionIdList',oscidsplit.get(opp.Id));
                }
                
                if(opptylineitem != null){
                    if(opptylineitem.containskey(opp.Id) && (OSCActionIdentifier == 'Association' || OSCActionIdentifier == 'ProductSync')){
                        gen.writeFieldName('ProductList');
                        gen.writeStartArray();
                        if(opptylineitem.get(opp.Id) != null){
                            for(Opportunitylineitem oli: opptylineitem.get(opp.Id)){
                                gen.writeStartObject();
                                gen.writeStringField('Name',oli.PricebookEntry.Product2.Name);
                                gen.writeStringField('Type',(oli.Product_Type__c!= null?oli.Product_Type__c:'None'));
                                gen.writeStringField('Group',(oli.PricebookEntry.ProductCode !=null?oli.PricebookEntry.ProductCode:'None'));
                                gen.writeEndObject();
                            }
                        } else if(opptylineitem.get(opp.Id) == null){
                            gen.writeStartObject();
                            gen.writeNullField('Name');
                            gen.writeNullField('Type');
                            gen.writeNullField('Group');
                            gen.writeEndObject();
                        }                        
                        gen.writeEndArray();            
                    } 
            }
                gen.writeEndObject();    
                system.debug('$$$$$JSON Request string' + gen.getAsString());
                
                jsonList.add(gen.getAsString());      
                system.debug('$$$$$$$$$$ Json List' + jsonList);
            }    
        }
        
            
        
        
        if(jsonList.size()>0){
            res = sendSolutionWithDealInfoHttpResponse(jsonList); 
            system.debug('%%%%%%%%%%%%%%% res' + res);
        } 
       
        if(res != null){
          //string responsestring = '{"Error":[{"Region": "AMER","DealId": "12345","IsSuccess": "true","Messages": [],"InvalidSolutionIdList":[]},{"Region": "AMER","DealId" : "1234", "IsSuccess": "false","Messages": [{"Id": "NULL_DEAL_ID","Description": "A null Deal ID can not be assigned to Solution: {SolutionId}","ApplicationSource": "MessageApplicationSource.SCS","Source": "SCS.Saga.Solution.UpdateSolutionWithDealInfoSaga.Execute()","Type": "MessageType.Error"}],"InvalidSolutionIdList": ["12903.1"]}]}';     

            result = parse(res.getBody());
            system.debug('^^^^^^^^^ parsed response' + result);
         }  
         return result;
   }

    /*Method to send and receive the http callout*/
    public static httpresponse sendSolutionWithDealInfoHttpResponse(list<string> requestjsonstring) 
    {
        String JSONReqestBody = '['+String.join(requestjsonstring, ',')+']';
        system.debug('!!!!!!!!!!!!!!!!!!!!! JSONReqestBody ' + JSONReqestBody );
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setHeader('Content-Type','application/json');
        req.setTimeout(120000);
        if(Environment.isProduction()){
            req.setEndpoint(system.label.OSC_Update_Solution_With_Deal_Endpoint_for_production);
            
        }else{
            //req.setEndpoint('https://sit2.api.dell.com:9002/integrationservices/scs/v2/updatesolutionswithdealinfo?apikey=6ea2648a258fc9fe2181af813a8755a6');
            req.setEndpoint(system.label.OSC_Update_Solution_With_Deal_Endpoint_for_sandbox);
        }
        
        req.setMethod('POST');

                req.setBody(JSONReqestBody); 
        try 
        {
            if(!Test.isRunningTest())
            {
              System.debug('_____________________________________________________________________Req:'+req);
              res = http.send(req);
              //res.setBody('[{"Region": "AMER","DealId": "12345","IsSuccess": "true","Messages": [],"InvalidSolutionIdList":[]},{"Region": "AMER","IsSuccess": "false","Messages": [{"Id": "NULL_DEAL_ID","Description": "A null Deal ID can not be assigned to Solution: {SolutionId}","ApplicationSource": "MessageApplicationSource.SCS","Source": "SCS.Saga.Solution.UpdateSolutionWithDealInfoSaga.Execute()","Type": "MessageType.Error"}],"InvalidSolutionIdList": []},{"Region": "AMER","DealId": "12346","IsSuccess": "false","Messages": [{"Id": "SOLUTION_HAS_DEAL_ID","Description": "Different deal Id: {existingDealId} is already assigned to Solution: {SolutionId}","ApplicationSource": "MessageApplicationSource.SCS","Source": "SCS.Saga.Solution.UpdateSolutionWithDealInfoSaga.Execute()","Type": "MessageType.Error"},{"Id : "SOLUTION_NOT_FOUND","Description : "Failed to retrieve Solution: {SolutionId}","ApplicationSource : "MessageApplicationSource.SCS","Source : "SCS.Saga.Solution.UpdateSolutionWithDealInfoSaga.Execute()","Type": "MessageType.Info"}],"InvalidSolutionIdList": ["12903.1", "12904.1"]}]'); 
              System.debug('_____________________________________________________________________Res:'+res );
            }
            else
            {
                //res.setbody('<UpdateSolutionsWithDealInfoResponse><TransactionID>b8c1242b-7b16-456e-a463-6b3620a0cb7c</TransactionID><UpdateSolutionsWithDealInfoResult><ResponseErrorCode/><ResponseMessages/><ResponseStatus>Successful</ResponseStatus><InvalidSolutionIdList nil="true"/></UpdateSolutionsWithDealInfoResult></UpdateSolutionsWithDealInfoResponse>');
                //res.setBody('[{"DealId":"10244491","InvalidSolutionIdList":[],"IsSuccess":true,"Messages":[],"Region":"AMER"}]'); 
                res.setBody('{"Error":[{"Region": "AMER","DealId": "12345","IsSuccess": "true","Messages": [{"Id": "NULL_DEAL_ID","Description": "A null Deal ID can not be assigned to Solution: AMER:225.1","ApplicationSource": "MessageApplicationSource.SCS","Source": "SCS.Saga.Solution.UpdateSolutionWithDealInfoSaga.Execute()","Type": "MessageType.Error"}],"InvalidSolutionIdList":["AMER:225.1"]},{"Region": "AMER","DealId" : "1234", "IsSuccess": "false","Messages": [{"Id": "NULL_DEAL_ID","Description": "A null Deal ID can not be assigned to Solution: {SolutionId}","ApplicationSource": "MessageApplicationSource.SCS","Source": "SCS.Saga.Solution.UpdateSolutionWithDealInfoSaga.Execute()","Type": "MessageType.Error"}],"InvalidSolutionIdList": ["12903.1"]}]}');
                res.setStatusCode(200);
                res.setStatus('OK');
            }
            System.debug('###### Response: '+res.getBody());
        } 
        catch(System.CalloutException e) 
        {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());            
            Exception__c exceptionrec = new Exception__c();
            exceptionrec.Object_type__c = 'Opportunity';
            exceptionrec.Operation__c = 'Webservice Request';
            exceptionrec.Process_Name__c = 'OSCWebservice Callout';
            exceptionrec.Email__c = 'no_reply@dell.com';
            exceptionrec.Error_Messages__c = e.getMessage();
            
            system.debug('############## exception list' + exceptionrec);
            if(isRefreshBtnClicked == false){
                insert exceptionrec;
                
            }
            
            
        }      
           
       return res;  
    }
    
    /*Future method to make a http callout from triggers*/
    @future(callout = true)
    public static void sendNotification(list<ID> oppid, String OSCActionIdentifier)  
    {    
        
        Map<id,Opportunity> oppMap = new Map<id,Opportunity>();
        Map<Id,List<String>> oppIsSlnIdMap = new Map<Id,List<String>>();
        Map<id,String> oppActionUserMap = new Map<id,String>(); 
        set<ID> oppidwithoutoscsolid = new set<id>();
        list<solution__c> sollist = new list<solution__c>();
        Map<id,list<opportunitylineitem>> opptylineitem = new map<id,list<Opportunitylineitem>>();
        list<opportunitylineitem> opptylineitemlist = new list<opportunitylineitem>();

        list<Opportunity> opplist = [select id, name,Account.Name,End_User_Account_Name__c,deal_id__c,deal_type__c,Deal_Expiration_Date__c, StageName, Deal_Registration_Status__c, OSC_Solution_Id__c,Opportunity_Customer_Number__r.Name, Affinity_ID__c,Unassigned_End_User__c,Unweighted_Rev_USD__c,partnerAccount.Account_id__c,PartnerAccount.name,PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c,PartnerAccount.Partner_Track__r.name from opportunity where id IN : oppid]; //Anamika- send Opportunity Customer Number & End User Affinity ID info to OSC
       
        if(OSCActionIdentifier == 'Association' || OSCActionIdentifier == 'ProductSync'){
            opptylineitemlist = [select Opportunity.Id, PricebookEntry.product2.name, PricebookEntry.productcode, product_type__c from opportunitylineitem where opportunity.id IN : oppid];
        }
        
        set<id> set2 = new set<id>();
        set<id> set1 = new set<id>(oppid);
        if(opptylineitemlist.size() > 0 && OSCActionIdentifier == 'ProductSync') {
            for(Opportunitylineitem oli: opptylineitemlist){
                set2.add(oli.opportunity.id);
            }
        }
        
        if(OSCActionIdentifier == 'ProductSync' ) {
            if(!set2.equals(set1)){
                for(Id ids : set1){
                    if(!set2.contains(ids) ){
                          opptylineitem.put(ids,null);
                     }
                }
            }
        }
        
        if(opptylineitemlist.size() > 0){
            for(opportunitylineitem oli: opptylineitemlist){
                if(!opptylineitem.containskey(oli.opportunity.id)){
                    opptylineitem.put(oli.opportunity.id,new list<opportunitylineitem>{oli});
                }
                else{
                    Map<id,list<opportunitylineitem>> opptylineitem2 = new Map<id,list<opportunitylineitem>>();
                    opptylineitem2.putAll(opptylineitem);
                    list<opportunitylineitem> olilist2 = new list<opportunitylineitem>();
                    olilist2 = opptylineitem2.get(oli.opportunity.id);
                    olilist2.add(oli);
                    opptylineitem.put(oli.opportunity.id,olilist2);
                }
            }
        }
        
        for(Opportunity op: opplist){
            oppMap.put(op.Id,op);
            //if(op.OSC_Solution_Id__c != null && op.OSC_Solution_Id__c != ''){
                //oppIsSlnIdMap.put(op.Id, new list<string>{op.OSC_Solution_Id__c});
            //}
            //else{
                oppidwithoutoscsolid.add(op.Id);
            //}
        }
        System.Debug('oppidwithoutoscsolid####'+oppidwithoutoscsolid);
        
        if(oppidwithoutoscsolid.size() > 0) {
            sollist = [select id, name, OSC_Regional_Id__c, OSC_Solution_Id__c, Opportunity__c from solution__c where Opportunity__c IN :  oppidwithoutoscsolid Order by Createddate DESC,Opportunity__c];
        }
        System.Debug('sollist ####'+sollist );
        
        if(sollist.size() > 0){
            for(Solution__c s: sollist){
                if(!oppIsSlnIdMap.containsKey(s.Opportunity__c)){
                   oppIsSlnIdMap.put(s.Opportunity__c,new list<string>{s.OSC_Regional_Id__c});
                }
            }
        }
        System.Debug('oppIsSlnIdMap####'+oppIsSlnIdMap);
        processRequest(oppMap,oppIsSlnIdMap,OSCActionIdentifier,opptylineitem,false);
        
    }
    
     //commenting this as we will deploy this next release
    /*   public static void sendNotificationFromBatch(list<ID> oppid, String OSCActionIdentifier)  
    {    
        system.debug('------------------------------ oppty ids' + oppid);
        
        Map<id,Opportunity> oppMap = new Map<id,Opportunity>();
        Map<Id,List<String>> oppIsSlnIdMap = new Map<Id,List<String>>();
        Map<id,String> oppActionUserMap = new Map<id,String>(); 
        set<ID> oppidwithoutoscsolid = new set<id>();
        list<solution__c> sollist = new list<solution__c>();
        Map<id,list<opportunitylineitem>> opptylineitem = new map<id,list<Opportunitylineitem>>();
        //Map<id,opportunitylineitem> opptylineitem2 = new map<id,Opportunitylineitem>();
        list<opportunitylineitem> opptylineitemlist = new list<opportunitylineitem>();

        list<Opportunity> opplist = [select id, name,Account.Name,End_User_Account_Name__c,deal_id__c,deal_type__c,Deal_Expiration_Date__c, StageName, Deal_Registration_Status__c, OSC_Solution_Id__c,Opportunity_Customer_Number__r.Name, Affinity_ID__c,Unassigned_End_User__c from opportunity where id IN : oppid]; //Anamika- send Opportunity Customer Number & End User Affinity ID info to OSC
       
        if(OSCActionIdentifier == 'Association' || OSCActionIdentifier == 'ProductSync'){
            opptylineitemlist = [select Opportunity.Id, PricebookEntry.product2.name, PricebookEntry.productcode, product_type__c from opportunitylineitem where opportunity.id IN : oppid];
        }
        
        set<id> set2 = new set<id>();
        set<id> set1 = new set<id>(oppid);
        if(opptylineitemlist.size() > 0 && OSCActionIdentifier == 'ProductSync') {
            for(Opportunitylineitem oli: opptylineitemlist){
                set2.add(oli.opportunity.id);
            }
        }
        
        if(OSCActionIdentifier == 'ProductSync' ) {
            if(!set2.equals(set1)){
                system.debug('-------------------- opptyid where last product is deleted');
                for(Id ids : set1){
                    if(!set2.contains(ids) ){
                          opptylineitem.put(ids,null);
                          system.debug('--------------------- checking for map when product is deleted' + opptylineitem);
                     }
                }
            }
        }
        
        if(opptylineitemlist.size() > 0){
            for(opportunitylineitem oli: opptylineitemlist){
                if(!opptylineitem.containskey(oli.opportunity.id)){
                    //list<opportunitylineitem> olilist1 = new list<opportunitylineitem>();
                    //olilist1.add(oli);
                    opptylineitem.put(oli.opportunity.id,new list<opportunitylineitem>{oli});
                }
                else{
                    Map<id,list<opportunitylineitem>> opptylineitem2 = new Map<id,list<opportunitylineitem>>();
                    opptylineitem2.putAll(opptylineitem);
                    list<opportunitylineitem> olilist2 = new list<opportunitylineitem>();
                    olilist2 = opptylineitem2.get(oli.opportunity.id);
                    olilist2.add(oli);
                    opptylineitem.put(oli.opportunity.id,olilist2);
                }
                system.debug('--------------------- opptylineitem' + opptylineitem);
            }
        }
        
        for(Opportunity op: opplist){
            oppMap.put(op.Id,op);
            if(op.OSC_Solution_Id__c != null && op.OSC_Solution_Id__c != ''){
                oppIsSlnIdMap.put(op.Id, new list<string>{op.OSC_Solution_Id__c});
            }
            else{
                oppidwithoutoscsolid.add(op.Id);
            }
        }
        
        if(oppidwithoutoscsolid.size() > 0) {
            sollist = [select id, name, OSC_Regional_Id__c, OSC_Solution_Id__c, Opportunity__c from solution__c where Opportunity__c IN :  oppidwithoutoscsolid];
        }
        
        if(sollist.size() > 0){
            for(Solution__c s: sollist){
                oppIsSlnIdMap.put(s.Opportunity__c,new list<string>{s.OSC_Regional_Id__c});
            }
        }
        
        system.debug('################ pinku oppMap' + oppMap);
        system.debug('################ pinku oppIsSlnIdMap' + oppIsSlnIdMap);
        processRequest(oppMap,oppIsSlnIdMap,OSCActionIdentifier,opptylineitem);
        
    } */
    
}