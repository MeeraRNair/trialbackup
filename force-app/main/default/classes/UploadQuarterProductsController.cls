public class UploadQuarterProductsController {
    
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public Rebate_Request_Product__c rebateReqObj {get;set;}
    public list<Rebate_Request_Product__c> produtSearchResults {get;set;}
    public integer prodsSize{get;set;}
    public string search_clientEnter {get;set;}
    public string search_partnerName {get;set;}
    public string search_Region {get;set;}
    
    public UploadQuarterProductsController(){
        csvFileLines = new String[]{};
        rebateReqObj = new Rebate_Request_Product__c();
        prodsSize = 0;
    }
    
    list<String> safeSplit(String inStr, String delim)
    {
        Integer regexFindLimit = 1;
        Integer regexFindCount = 0;
        
        List<String> output = new List<String>();
        
        Matcher m = Pattern.compile(delim).matcher(inStr);
        
        Integer lastEnd = 0;
        boolean firstRun = false;
        while(!m.hitEnd())
        {
            while(regexFindCount < regexFindLimit && !m.hitEnd())
            {
                if (Limits.getLimitCpuTime() - Limits.getCpuTime() <= 100) break;
                if(m.find())
                {
                     string result = firstRun == true ? ('\n' +inStr.substring(lastEnd, m.start())): inStr.substring(lastEnd, m.start());
                     output.add(result);
                     lastEnd = m.end();
                    system.debug('$$$$' +output );
                }
                else
                {
                    string result = firstRun == true ?('\n' +inStr.substring(lastEnd)): inStr.substring(lastEnd);
                    output.add(result);
                    lastEnd = inStr.length();
                }
                
                regexFindCount++;
                firstRun= true;
            }
            m.reset(inStr);        
            m.region(lastEnd, m.regionEnd());
            
            regexFindCount = 0;
        }
        
        system.debug('$$$$' +output );
        return output;
    }   
    
    public void uploadCSVFile(){
       try{
           csvAsString = csvFileBody.toString();
           
           csvFileLines = safeSplit(csvAsString,'\r\n'); 
           list<Rebate_Request_Product__c> updateRebateProducts = new list<Rebate_Request_Product__c>();
           
           Set<Id> allianceRebateIds = new Set<Id>();
           
           for(Integer i=1;i<csvFileLines.size() - 1;i++){
           		string[] csvRecordData = csvFileLines[i].split(',');
           		allianceRebateIds.add(csvRecordData[1].deleteWhitespace());
           }
           
           map<Id, Alliance_Rebate_Request__c> allianceRebateMap = getAllianceRebateReq(allianceRebateIds);
           Set<Id> allianceObjIds = new Set<Id>();
           
           list<Alliance_Rebate_Request__c> updateAllianceRebates = new list<Alliance_Rebate_Request__c>();
           
           for(Integer i=1;i<csvFileLines.size() - 1;i++){
               
               Rebate_Request_Product__c rebateReqProd = new Rebate_Request_Product__c();
               string[] csvRecordData = csvFileLines[i].split(',');
               
               rebateReqProd.Id = csvRecordData[0].deleteWhitespace().remove('\"');
			   
               If( csvRecordData.size() > 9 && csvRecordData[9].deleteWhitespace() != null  && csvRecordData[9].deleteWhitespace() != '' ){
                     rebateReqProd.Quantity_Claimed__c = integer.valueOf(csvRecordData[9].deleteWhitespace());
               }else{
                 rebateReqProd.Quantity_Claimed__c = null;
                }
                
               If( csvRecordData.size() > 10 && csvRecordData[10].deleteWhitespace() != null  && csvRecordData[10].deleteWhitespace() != ''){
                    rebateReqProd.Cost_Per_Unit__c = integer.valueOf(csvRecordData[10].deleteWhitespace());
               }else{
                    rebateReqProd.Cost_Per_Unit__c = null;
               }
               
               If( csvRecordData.size() > 11 && csvRecordData[11].deleteWhitespace() != null  && csvRecordData[11].deleteWhitespace() != ''){
               		String startDate = csvRecordData[11].deleteWhitespace() ;
                    rebateReqProd.Start_Date__c = Date.valueOf(startDate.replace('.','-'));
               }else{
                    rebateReqProd.Start_Date__c = null;
               }
               
               If( csvRecordData.size() > 12 && csvRecordData[12].deleteWhitespace() != null  && csvRecordData[12].deleteWhitespace() != ''){
               		String endDate = csvRecordData[12].deleteWhitespace() ;
                    rebateReqProd.End_Date__c = Date.valueOf(endDate.replace('.','-'));
               }else{
                    rebateReqProd.End_Date__c = null;
               }
               
               If( csvRecordData.size() > 13 && csvRecordData[13].deleteWhitespace() != null  && csvRecordData[13].deleteWhitespace() != ''){
           			allianceRebateMap.get(csvRecordData[1].deleteWhitespace()).Additional_Sales_Person_Email_2__c = csvRecordData[13].deleteWhitespace();
           			If( !allianceObjIds.contains( csvRecordData[1].deleteWhitespace() )){
           				allianceObjIds.add( csvRecordData[1].deleteWhitespace() );
           				updateAllianceRebates.add( allianceRebateMap.get(csvRecordData[1].deleteWhitespace() ));
           			}
               }else{
                    allianceRebateMap.get(csvRecordData[1].deleteWhitespace()).Additional_Sales_Person_Email_2__c = null;
                    If( !allianceObjIds.contains( csvRecordData[1].deleteWhitespace() )){
           				allianceObjIds.add( csvRecordData[1].deleteWhitespace() );
           				updateAllianceRebates.add( allianceRebateMap.get(csvRecordData[1].deleteWhitespace() ));
           			}
               }
               
               updateRebateProducts.add(rebateReqProd);
           }
           System.debug('***updateRebateProducts: '+  updateRebateProducts);
            update updateRebateProducts;
            
            System.debug('***updateAllianceRebates: '+  updateAllianceRebates);
            update updateAllianceRebates;

            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.CONFIRM,'Products updated Successfully');
            ApexPages.addMessage(errorMessage);
        }
        catch (Exception e)
        {
          	System.debug('Error Msg: '+ e.getMessage());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }  
   }
   
   public map<Id, Alliance_Rebate_Request__c> getAllianceRebateReq(Set<Id> rebateIds){
   		map<Id, Alliance_Rebate_Request__c> allianceRebateMap = new map<Id, Alliance_Rebate_Request__c>([Select Id, Additional_Sales_Person_Email_2__c from Alliance_Rebate_Request__c Where Id IN: rebateIds]);
   		return allianceRebateMap;
   }

   public list<Rebate_Request_Product__c> getProducts(){
     
     list<Rebate_Request_Product__c> prodResults = new list<Rebate_Request_Product__c>();
     prodsSize = 0;
     
     If(rebateReqObj.Start_Date__c == null && rebateReqObj.End_Date__c != null){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please choose Start Date'));
        return null;
     }else If(rebateReqObj.Start_Date__c != null && rebateReqObj.End_Date__c == null){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please choose End Date'));
        return null;
     }else If( rebateReqObj.Start_Date__c > rebateReqObj.End_Date__c ){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'End Date should be greater than Start date'));
        return null;
     }else{
    
      String queryString = '';
      
      queryString = 'Start_Date__c, End_Date__c, Cost_Per_Unit__c,CreatedDate,Id,Quantity_Claimed__c, Quantity_Approved__c, Price_Requested__c, Alliance_Rebate_Request__r.Partner_BDM_Name__c, Alliance_Rebate_Request__c, Alliance_Rebate_Request__r.Name, Alliance_Rebate_Request__r.Client_Enterprise__c, Alliance_Rebate_Request__r.System_Partner_Name__c, Alliance_Rebate_Request__r.Region__c, Alliance_Rebate_Request__r.Additional_Sales_Person_Email_2__c';
  
      String rebReqProdQuery = 'Select ' + queryString + ' from Rebate_Request_Product__c WHERE Quantity_Approved__c != null AND Status__c = '+ '\'' + 'Active' + '\'' + ' AND Alliance_Rebate_Request__r.Partner_BDM_Name__c != null ';
      
      List<string> conditions = new List<string>();
      
      if(rebateReqObj.Start_Date__c != null){      
        String fromDate = rebateReqObj.Start_Date__c+'';      
        fromDate = fromDate.split(' ',0)[0];        // +'T00:00:00.000Z'
        conditions.add('Start_Date__c >=' + fromDate);     
      }
      
      if(rebateReqObj.End_Date__c != null){     
        String toDate = rebateReqObj.End_Date__c+'';      
        toDate = toDate.split(' ',0)[0];        // +'T23:59:59.000Z'
        conditions.add('End_Date__c <= ' + toDate);     
      }
      
      if( search_clientEnter != 'None' ){       
        conditions.add('Alliance_Rebate_Request__r.Client_Enterprise__c = \'' + search_clientEnter +'\' ');     
      }
      
      if( search_partnerName != 'None' ){       
        conditions.add('Alliance_Rebate_Request__r.System_Partner_Name__c = \'' + search_partnerName +'\' ');     
      }
      
      if( search_Region != 'None' ){       
        conditions.add('Alliance_Rebate_Request__r.Region__c = \'' + search_Region +'\' ');     
      }
      
      if (conditions.size() > 0) {              
        for (Integer i = 0; i < conditions.size(); i++)                
          rebReqProdQuery += ' AND ' + conditions[i];      
      }
      
      rebReqProdQuery += ' Order By CreatedDate';
      
      rebReqProdQuery += ' LIMIT 3000';
      
      System.debug('rebReqProdQuery String: '+ rebReqProdQuery);
      
      prodResults = Database.query(rebReqProdQuery);
      
      prodsSize = prodResults.size();
      
      If(prodsSize == 0){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'No Records'));
          return null;
      }
     
     }

    return prodResults;

   }

   public void searchProducts(){
      produtSearchResults = getProducts();
   }
   
    public Pagereference exportAll(){
        return new Pagereference('/apex/ExportProductCSVFile');
    }
}