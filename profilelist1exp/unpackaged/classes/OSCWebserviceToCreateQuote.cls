/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#              Description
-------     ------      ----            --------    ---             -----------
1.0         
2.0         kishore        22-Sep-2014     15.10    CR 11969       webservice class is used to getting the QuoteID from OSC and creates new records in SFDC Quote Object which is ossicated to SolutionID
            
*/       
global class OSCWebserviceToCreateQuote{
    
    //Objects to hold the request values
    global class QuoteDetails {
      webservice String oscQuoteId;
      webservice String oscSolutionId; 
    }
    
    //Objects to hold the response values
    global class Response {
        //webservice String solutionId{get;set;}
        webservice String message{get; set;}
        webservice boolean isSuccess{get;set;}
    }
    
    /*Method to parse the response from callout*/
    webservice static list<Response>  QuoteParameters(List<QuoteDetails> quoteList){
        
        Map<string,Solution__c> solnMap = new Map<string,Solution__c>();
        set<string> solnIdSet = new set<string>();
        set<string> quotenull = new set<string>();
        set<string> solnIDnotinSFDC = new set<string>();
        list<solution__c> solutionlist = new List<solution__c>();
        List<Response> reslist = new List<Response>();
        Map<String,string> oscmap= new Map<string,string>();
        map<string,list<string>> multiplequotelist = new map<string,list<string>>();
        for(QuoteDetails quo: quoteList){
            system.debug('################ ' + quo);
            if(quo.oscQuoteId!=null){
                solnIdSet.add(quo.oscSolutionId);
                if(!multiplequotelist.containskey(quo.oscSolutionId)){
                    multiplequotelist.put(quo.oscSolutionId,new list<string>{quo.oscQuoteId});
                } else{
                    //solnIdSet.add(quo.oscSolutionId);
                    map<string,list<string>> map2 = new map<string,list<string>>();
                    map2.putall(multiplequotelist);
                    list<string> qdlist = new list<string>();
                    qdlist = map2.get(quo.oscSolutionId);
                    qdlist.add(quo.oscQuoteId);
                    multiplequotelist.put(quo.oscSolutionId,qdlist);
                    system.debug('!!!!!!!!!!!!!!!!!!!!!!! multiplequotelist' + multiplequotelist);
                }
            }else {
                //sending the response if Quote is null
                quotenull.add(quo.oscQuoteId);   
                Response res = new Response();
                //res.solutionID=quo.oscSolutionId;
                res.message= label.OSCQuote_Res; 
                res.isSuccess = false;
                reslist.add(res);
            }  
        }
        //comparing the solution
        if(multiplequotelist.keySet() != null){
            solutionlist = [SELECT OSC_Regional_ID__c,id,Opportunity__c FROM Solution__c WHERE OSC_Regional_ID__c IN:multiplequotelist.keySet()];
            system.debug('$$$solutionlist'+solutionlist);
        }
        
        if(solutionlist.size()>0){
            for(Solution__c sol:solutionlist){
                solnMap.put(sol.OSC_Regional_ID__c,sol);  
                solnIDnotinSFDC.add(sol.OSC_Regional_ID__c); 
                system.debug('$$$solnMap'+solnMap);
                system.debug('$$$solnIDnotinSFDC'+solnIDnotinSFDC);
           }
        } 
        /*sending the response to Osc if SolutionId is not valid*/
        if(!solnIDnotinSFDC.equals(multiplequotelist.keySet())){    
                for(string ids : multiplequotelist.keySet()){
                    if(!solnIDnotinSFDC.contains(ids) ){
                        multiplequotelist.remove(ids); 
                        Response res = new Response();
                        //res.solutionId= ids;
                        res.message= Label.OSC_Quote_valid_SoluitonID; 
                        res.isSuccess = false;
                        reslist.add(res);
                     }
                }
            }
        //Multiple new quotes will be creation in SFDC from OSC QuoteID
        List<Quote__c> quoteListToCreate = new List<Quote__c>();
        if(multiplequotelist.size()>0){
            for(String s: multiplequotelist.keyset()){
                system.debug('--------------- solution id' + s);
                for(String q: multiplequotelist.get(s)){
                    system.debug('@@@@@@@@@@@@@@ quote ids' + q);
                    Quote__c qu = new Quote__c();
                    qu.QuoteId__c = q;
                    qu.Solution__c = solnMap.get(s).id;
                    qu.Opportunity__c= solnMap.get(s).opportunity__c;
                    quoteListToCreate.add(qu);  
                    system.debug('$$$quoteListToCreate'+quoteListToCreate);  
                }
            }    
        }
        //inserting the quote records and sending the success response to OSC
        if(quoteListToCreate.size()>0){   
                 Database.SaveResult[] srList = Database.insert(quoteListToCreate, false);
                  for (Database.SaveResult sr : srList) {
                       if (sr.isSuccess()) {
                           Response res = new Response();
                            //res.solutionId= sr.Id;
                            res.message= Label.OSC_Quote_Success;
                            res.isSuccess = true;
                            reslist.add(res);
                        System.debug('Successfully inserted Quote. Quote ID: *********************' + sr.getId());
                        
                     }else{
                          for(Database.Error err : sr.getErrors()) {
                              System.debug(err.getStatusCode() + ': ' + err.getMessage());
                               Response res = new Response();
                                //res.solutionId= 'test';
                                res.message= err.getStatusCode() + ': ' + err.getMessage();
                                res.isSuccess = false;
                                reslist.add(res);
                         }
                     }
                  }
        }
        return reslist;
    }
}