public class UploadSTFPriceController {
    
    public list<Alliance_STF_Price__c> stfPriceResults {get;set;}
    
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    
    public Blob csvFileBodyToDelete{get;set;}
    public string csvAsStringToDelete{get;set;}
    public String[] csvFileLinesToDelete{get;set;}
    
    public UploadSTFPriceController(){
        csvFileLines = new String[]{};
    }
    
    public Pagereference downloadSTFPriceResults(){
        stfPriceResults = getSTFPrices();
        return new Pagereference('/apex/ExportSTFPriceFile');
    }  
    
    public void uploadCSVFile(){
        try{
            csvAsString = csvFileBody.toString();
            csvFileLines = safeSplit(csvAsString,'\r\n'); 
            
            list<Alliance_STF_Price__c> upsertSTFPrices = new list<Alliance_STF_Price__c>();
            
            for(Integer i=1;i<csvFileLines.size() - 1;i++){
                string[] csvRecordData = csvFileLines[i].split(',');
                Alliance_STF_Price__c stfPriceObj = new Alliance_STF_Price__c();
   
                If(csvRecordData[0] != null  && csvRecordData[0].deleteWhitespace() != ''){
                    // Update 
                    stfPriceObj.Name = csvRecordData[1].deleteWhitespace();
                    stfPriceObj.Part__c = csvRecordData[2].deleteWhitespace();
                    stfPriceObj.Net_Price__c = decimal.valueOf(csvRecordData[3].deleteWhitespace());
                    stfPriceObj.Id = csvRecordData[0].deleteWhitespace();
                }else{
                    // New
                    stfPriceObj.Name = csvRecordData[1].deleteWhitespace();
                    stfPriceObj.Part__c = csvRecordData[2].deleteWhitespace();
                    stfPriceObj.Net_Price__c = decimal.valueOf(csvRecordData[3].deleteWhitespace());
                }
                upsertSTFPrices.add(stfPriceObj);
            }
            System.debug('******Upsert Items: '+ upsertSTFPrices);
            
            // Insert & Update STF Prices
            upsert upsertSTFPrices;
            
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.CONFIRM,'STF Prices updated Successfully');
            ApexPages.addMessage(errorMessage);
            
        }catch (Exception e){
            System.debug('Error Msg: '+ e.getMessage());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }
    }
    
    list<Alliance_STF_Price__c> getSTFPrices(){
        return [Select Id, Name, Net_Price__c, Part__c from Alliance_STF_Price__c];
    }
    
    public void deleteUploadedFiles(){
        try{
            csvAsStringToDelete = csvFileBodyToDelete.toString();
            csvFileLinesToDelete = safeSplit(csvAsStringToDelete,'\r\n'); 
            
            list<Alliance_STF_Price__c> deleteSTFPrices = new list<Alliance_STF_Price__c>();
            
            for(Integer i=1;i<csvFileLinesToDelete.size() - 1;i++){
                string[] csvRecordDataToDelete = csvFileLinesToDelete[i].split(',');
                Alliance_STF_Price__c stfPriceObjToDelete = new Alliance_STF_Price__c();
                
                If(csvRecordDataToDelete[0] != null  && csvRecordDataToDelete[0].deleteWhitespace() != ''){
                    stfPriceObjToDelete.Id = csvRecordDataToDelete[0].deleteWhitespace();
                }
                deleteSTFPrices.add(stfPriceObjToDelete);
            }
            System.debug('******Delete Items: '+ deleteSTFPrices);
            
            // Insert & Update STF Prices
            delete deleteSTFPrices;
            
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.CONFIRM,'STF Prices Deleted Successfully');
            ApexPages.addMessage(errorMessage);
            
        }catch (Exception e){
            System.debug('Error Msg Delete Info: '+ e.getMessage());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }
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
}