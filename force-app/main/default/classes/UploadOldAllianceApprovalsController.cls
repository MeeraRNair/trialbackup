/*
* Block comments with details of changes
*/
public class UploadOldAllianceApprovalsController{
    public Blob blbcsvFileBody{get;set;}
    public string strcsvAs{get;set;}
    public String[] listcsvFileLines{get;set;}
    public list<Rebate_Request_Product__c> listrebateReqProds {get;set;}
    //public integer uploadedCount {get;set;}
    
    public UploadOldAllianceApprovalsController(){
        listcsvFileLines = new String[]{};
            // uploadedCount = 0;
    }
    public void uploadCSVFile(){
        Savepoint sp;
        string strdealid='';
        boolean baddchild= false;//to avoid first CSV row with out DEal ID
        Map<string, List<string>> mapstringchilds= new Map<string, List<string>>();//Unique Value with list of Child Data 
        string strparentuniquev=''; //Unique Reference to find Child(Rebate_Request_Product__c)records of Alliance_Rebate_Request__c Obj
        try{
            sp = Database.setSavepoint();
            Opportunity opp = [Select Id from Opportunity limit 1];
            strcsvAs = blbcsvFileBody.toString();
            listcsvFileLines = safeSplit(strcsvAs,'\r\n'); 
            list<Alliance_Rebate_Request__c> listexistingAllianceApprovals = new list<Alliance_Rebate_Request__c>();
            Set<string> setdealId= new Set<string>();
            //  Set<string> oppNames = new Set<string>();
            Set<string> setuserEmails = new Set<string>();
            for(Integer inti=1;inti<listcsvFileLines.size() - 1;inti++){
                string[] listcsvRecordData = listcsvFileLines[inti].split(',');
                setdealId.add(listcsvRecordData[0].deleteWhitespace());
                //    oppNames.add(csvRecordData[6]);
                /* userEmails.add(csvRecordData[15].deleteWhitespace());
If( csvRecordData.size() > 16 ){
userEmails.add(csvRecordData[16].deleteWhitespace());
}*/
                If( listcsvRecordData.size() > 14 ){
                    setuserEmails.add(listcsvRecordData[14].deleteWhitespace());
                }
            }
            map<String, Id> mapoppDeal= getOpportunityFromDealIds(setdealId);
            //  map<String, Id> oppNamesMap = getOpportunityFromNames(oppNames);
            map<String, Id> mapuserEmail = getUserIdsFromEmails(setuserEmails);
            Id devRecordTypeId = system.Label.OldApprovalsRecordType;
            /* If(!Test.isRunningTest()){
devRecordTypeId = Schema.SObjectType.Alliance_Rebate_Request__c.getRecordTypeInfosByName().get('Old Approvals RT').getRecordTypeId();     
}else{
devRecordTypeId = Schema.SObjectType.Alliance_Rebate_Request__c.getRecordTypeInfosByName().get('Rebate Request Submission').getRecordTypeId();
}*/
            for(Integer inti=1;inti<listcsvFileLines.size() - 1;inti++){
                Alliance_Rebate_Request__c allianceObj = new Alliance_Rebate_Request__c();
                string[] listcsvRecordData = listcsvFileLines[inti].split(',');
                system.debug('***csvRecordData: '+ listcsvRecordData);
                system.debug('***csvRecordData: '+ listcsvRecordData.size());
                //Add Parent data
                system.debug('@@@ Deal ID'+listcsvRecordData[0].deleteWhitespace());
                strdealid=listcsvRecordData[0].deleteWhitespace();
                system.debug('@@@strdealid '+strdealid);
                if(strdealid!=null && strdealid!=''){
                    baddchild=true;
                    allianceObj.Client_Enterprise__c = listcsvRecordData[2].deleteWhitespace();//'Enterprise';
                    allianceObj.System_Partner_Name__c = listcsvRecordData[6].deleteWhitespace();//'Brocade';
                    allianceObj.Partner_BDM_Name__c = 'Unknown';
                    allianceObj.Finance_Contact__c = 'Unknown@dell.com';
                    allianceObj.Status__c = 'Approved';
                    allianceObj.RecordTypeId = devRecordTypeId;
                    allianceObj.Part_Requested__c = listcsvRecordData[15].deleteWhitespace();  
                    if(!Test.isRunningTest()){
                        if(mapoppDeal.containsKey(strdealid)){
                            system.debug('@@@Assign Deal id'+mapoppDeal.get(strdealid));
                            //allianceObj.Sales_Force_Deal_ID__c = oppDealMap.get(csvRecordData[0].deleteWhitespace());
                            allianceObj.Sales_Force_Deal_ID__c = mapoppDeal.get(strdealid);                            
                        }else{
                            //allianceObj.Sales_Force_Deal_ID__c = oppDealMap.get(strdealid);
                        }
                    }else{
                        allianceObj.Sales_Force_Deal_ID__c = opp.Id;
                    }
                    if( listcsvRecordData[1].deleteWhitespace() != null  && listcsvRecordData[1].deleteWhitespace() != '' ){
                        if(listcsvRecordData[1].deleteWhitespace() == 'ABU'){
                            allianceObj.Region__c = 'NA';
                        }else{
                            allianceObj.Region__c = listcsvRecordData[1].deleteWhitespace();
                        }
                    }
                    if( listcsvRecordData.size() > 3 && listcsvRecordData[3].deleteWhitespace() != null  && listcsvRecordData[3].deleteWhitespace() != '' ){
                        allianceObj.Created_Date__c = date.parse(listcsvRecordData[3].deleteWhitespace());
                    }
                    if( listcsvRecordData.size() > 14 && listcsvRecordData[14].deleteWhitespace() != null  && listcsvRecordData[14].deleteWhitespace() != '' ){
                        allianceObj.OwnerId = mapuserEmail.get(listcsvRecordData[14].deleteWhitespace());
                    }
                    if( listcsvRecordData[7].deleteWhitespace() != null  && listcsvRecordData[7].deleteWhitespace() != '' ){
                        allianceObj.RRP_PartName__c = listcsvRecordData[7].deleteWhitespace();
                    }
                    allianceObj.RRP_ChildData_IT__c = Datetime.now().format('yyyyMMddHHmmss')+'UV'+inti;
                    strparentuniquev =allianceObj.RRP_ChildData_IT__c ;//Unique Reference  
                    //allianceObj.RRP_ChildData_IT__c = strchildData ;
                    /*  if( csvRecordData.size() > 15 && csvRecordData[15].deleteWhitespace() != null  && csvRecordData[15].deleteWhitespace() != '' ){
allianceObj.Team_Member1__c = userEmailMap.get(csvRecordData[15].deleteWhitespace());
}
if( csvRecordData.size() > 16 && csvRecordData[16].deleteWhitespace() != null  && csvRecordData[16].deleteWhitespace() != '' ){
allianceObj.Team_Member2__c = userEmailMap.get(csvRecordData[16].deleteWhitespace());
}*/
                    if( listcsvRecordData.size() > 16 && listcsvRecordData[16].deleteWhitespace() != null  && listcsvRecordData[16].deleteWhitespace() != '' ){
                        allianceObj.Discount_percentage__c = Decimal.valueOf(listcsvRecordData[16].deleteWhitespace());
                    }
                    if( listcsvRecordData.size() > 17 && listcsvRecordData[17].deleteWhitespace() != null  && listcsvRecordData[17].deleteWhitespace() != '' ){
                        allianceObj.Total_Rebate_Amount__c = Decimal.valueOf(listcsvRecordData[17].deleteWhitespace());
                    }
                    if( listcsvRecordData.size() > 18 && listcsvRecordData[18].deleteWhitespace() != null  && listcsvRecordData[18].deleteWhitespace() != '' ){
                        allianceObj.Business_Case_Information__c = listcsvRecordData[18].deleteWhitespace();
                    }else{
                        allianceObj.Business_Case_Information__c = 'Sample Business Comments';
                    }
                    // STF Prices
                    if( listcsvRecordData.size() > 10 && listcsvRecordData[10].deleteWhitespace() != null  && listcsvRecordData[10].deleteWhitespace() != '' ){
                        allianceObj.Dell_Standard_CPU_text__c = listcsvRecordData[10].deleteWhitespace();
                    }
                    if( listcsvRecordData.size() > 9 && listcsvRecordData[9].deleteWhitespace() != null  && listcsvRecordData[9].deleteWhitespace() != '' ){
                        allianceObj.Dell_Standard_CPU_Currency__c = Decimal.valueOf(listcsvRecordData[9].deleteWhitespace());
                    }
                    listexistingAllianceApprovals.add(allianceObj);                                     
                }
                //Add child data
                System.debug('***baddchild : '+ baddchild);
                if(baddchild && strparentuniquev!=''){
                    System.debug('***added child---');
                    String strchildData = '';
                    If( listcsvRecordData[4].deleteWhitespace() != null  && listcsvRecordData[4].deleteWhitespace() != '' ){
                        strchildData = listcsvRecordData[4].deleteWhitespace() ;
                    }
                  If( listcsvRecordData[5].deleteWhitespace() != null  && listcsvRecordData[5].deleteWhitespace() != '' ){
                        strchildData += '&&' + listcsvRecordData[5].deleteWhitespace() ;
                    }
                    If( listcsvRecordData[7].deleteWhitespace() != null  && listcsvRecordData[7].deleteWhitespace() != '' ){
                        strchildData += '&&' + listcsvRecordData[7].deleteWhitespace() ;
                    }
                    If( listcsvRecordData[8].deleteWhitespace() != null  && listcsvRecordData[8].deleteWhitespace() != '' ){
                        strchildData += '&&' + listcsvRecordData[8].deleteWhitespace() ;
                    }
                    If( listcsvRecordData[9].deleteWhitespace() != null  && listcsvRecordData[9].deleteWhitespace() != '' ){
                        strchildData += '&&' + listcsvRecordData[9].deleteWhitespace() ;
                    }
                    If( listcsvRecordData[10].deleteWhitespace() != null  && listcsvRecordData[10].deleteWhitespace() != '' ){
                        strchildData += '&&' + listcsvRecordData[10].deleteWhitespace() ;
                    }
                    If( listcsvRecordData[11].deleteWhitespace() != null  && listcsvRecordData[11].deleteWhitespace() != '' ){
                        strchildData += '&&' + listcsvRecordData[11].deleteWhitespace() ;
                    }
                   If( listcsvRecordData[12].deleteWhitespace() != null  && listcsvRecordData[12].deleteWhitespace() != '' ){
                        strchildData += '&&' + listcsvRecordData[12].deleteWhitespace() ;
                    }
                   If( listcsvRecordData[13].deleteWhitespace() != null  && listcsvRecordData[13].deleteWhitespace() != '' ){
                        strchildData += '&&' + listcsvRecordData[13].deleteWhitespace() ;
                    }
                    If( listcsvRecordData[15].deleteWhitespace() != null  && listcsvRecordData[15].deleteWhitespace() != '' ){
                        strchildData += '&&' + listcsvRecordData[15].deleteWhitespace() ;
                    }
                    //Add unique value and strchildData to Map 
                    if(mapstringchilds.containsKey(strparentuniquev)) {
                        mapstringchilds.get(strparentuniquev).add(strchildData);
                    }else {
                        mapstringchilds.put(strparentuniquev, new List<string> {strchildData});
                    }   
                    System.debug('***added childData---'+strchildData);
                }else{
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct');
                    ApexPages.addMessage(errorMessage);
                }
            }
            // TriggerExecutionController.setSkipAllTriggers(true);
            System.debug('***Exsiting Allinces: '+  listexistingAllianceApprovals);
            if( listexistingAllianceApprovals.size() > 0 ){
                insert listexistingAllianceApprovals;
                // uploadedCount = existingAllianceApprovals.size();
            }
            list<Rebate_Request_Product__c> listrebateReqProds = new list<Rebate_Request_Product__c>();
            system.debug('***mapstringchilds: '+ mapstringchilds);
            for(Alliance_Rebate_Request__c arrObj: listexistingAllianceApprovals){  if(mapstringchilds.containsKey(arrObj.RRP_ChildData_IT__c)){ list<string> listchilds = mapstringchilds.get(arrObj.RRP_ChildData_IT__c);
                    system.debug('***childs: '+ listchilds);
                    integer inttemp=1;
                    for(string strc:listchilds){list<String> listrebateProds = new list<string>();listrebateProds = strc.split('&&');
                        Rebate_Request_Product__c rrpObj = new Rebate_Request_Product__c();
                        rrpObj.Alliance_Rebate_Request__c = arrObj.Id;
                        rrpObj.Sl_No__c = inttemp;  
                        rrpObj.Status__c = 'Active';
                        rrpObj.Start_Date__c = date.parse(listrebateProds[0].deleteWhitespace());
                        rrpObj.End_Date__c = date.parse(listrebateProds[1].deleteWhitespace());
                        rrpObj.Part_Name_Part_Number__c = listrebateProds[2].deleteWhitespace();
                        //rrpObj.Part_Name_Part_Number__c = arrObj.RRP_PartName__c;
                        rrpObj.Approved_Price_per_unit__c = Decimal.valueOf(listrebateProds[3].replace('-',''));                        
                        rrpObj.Cost_Per_Unit__c = Decimal.valueof(listrebateProds[4].deleteWhitespace());//column 9
                        rrpObj.Rebate_per_unit__c = listrebateProds[5].deleteWhitespace();//column 10 
                        if( listrebateProds[6].deleteWhitespace() != null  && listrebateProds[6].deleteWhitespace() != '' && listrebateProds[6].deleteWhitespace() != '-' ){
                            rrpObj.Quantity_Claimed__c = integer.valueOf(listrebateProds[6].deleteWhitespace());
                        }                       
                        if( listrebateProds[6].deleteWhitespace() != null  && listrebateProds[6].deleteWhitespace() != '' && listrebateProds[6].deleteWhitespace() != '-'){ rrpObj.Quantity_Approved__c = integer.valueOf(listrebateProds[8].deleteWhitespace().replace('-','')); }
                        rrpObj.Part_Requested__c = listrebateProds[9].deleteWhitespace();
                        listrebateReqProds.add(rrpObj);
                        inttemp++;
                    }
                }
            }
            System.debug('***Exsiting listrebateReqProds: '+  listrebateReqProds);
            if( listrebateReqProds.size() > 0 ){   insert listrebateReqProds;
                                            //  uploadedCount = rebateReqProds.size();
                                           }
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.CONFIRM,'Existing Alliance Approvals Created Successfully');
            ApexPages.addMessage(errorMessage);
        }
        catch (Exception e){
            Database.rollback( sp );
            
            System.debug('Error Msg: '+ e.getMessage() +' at: '+ e.getLineNumber());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }  
    }
    
    map<String, Id> getOpportunityFromDealIds(Set<String> setdeals){
        map<String, Id> mapoppDeals= new map<String, Id>();
        for(Opportunity opp: [Select Id, Name, Deal_ID__c from Opportunity Where Deal_ID__c IN: setdeals]){
            mapoppDeals.put(opp.Deal_ID__c, opp.Id);
        }
        return mapoppDeals;
    }
    
    map<String, Id> getOpportunityFromNames(Set<String> setoppNames){
        map<String, Id> mapoppName = new map<String, Id>();
        for(Opportunity opp: [Select Id, Name, Deal_ID__c from Opportunity Where Name IN: setoppNames]){
            mapoppName.put(opp.Name, opp.Id);
        }
        return mapoppName ;
    }
    
    map<String, Id> getUserIdsFromEmails(Set<String> setuserEmails){
        map<String, Id> mapuserEmails = new map<String, Id>();
        for(User usr: [Select Id, Name, Email from User Where Email IN: setuserEmails]){
            mapuserEmails .put(usr.Email, usr.Id);
        }
        return mapuserEmails ;
    }
    
    list<String> safeSplit(String strin, String strdelim){
        Integer intregexFindLimit = 1;
        Integer intregexFindCount = 0;
        List<String> listoutput = new List<String>();
        Matcher m = Pattern.compile(strdelim).matcher(strin);
        Integer intlastEnd = 0;
        boolean bfirstRun = false;
        while(!m.hitEnd()){
            while(intregexFindCount < intregexFindLimit && !m.hitEnd()){
                if (Limits.getLimitCpuTime() - Limits.getCpuTime() <= 100){break;}
                if(m.find()){
                    string strresult = bfirstRun == true ? ('\n' +strin.substring(intlastEnd, m.start())): strin.substring(intlastEnd, m.start());
                    listoutput.add(strresult);
                    intlastEnd = m.end();
                    system.debug('$$$$' +listoutput );
                }
                else{
                    string strresult = bfirstRun == true ?('\n' +strin.substring(intlastEnd)): strin.substring(intlastEnd);
                    listoutput.add(strresult);
                    intlastEnd = strin.length();
                }
                intregexFindCount++;
                bfirstRun= true;
            }
            m.reset(strin);        
            m.region(intlastEnd, m.regionEnd());
            intregexFindCount = 0;
        }
        system.debug('$$$$' +listoutput );
        return listoutput;
    }
}