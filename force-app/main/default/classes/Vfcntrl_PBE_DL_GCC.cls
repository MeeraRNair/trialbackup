/*
* Revision  CR Number   Release No    Date            Modified By     Description
* --------- ---------   -----------   -------         ------------    ---------
  1.0       CR16118     FY19-DCS-0802 10-Jul-2018     Pallavi         Removed commented parts and debug statements as part of code reduce story 5240537

*/

public class Vfcntrl_PBE_DL_GCC {
  
    public list<Wrap_PBE_Export> wrapList {get;set;}
    public integer wrapCount {get;set;}
    String csvFileString = ''; 
    String catalogLabel = System.Label.PBE_CatalogName;
    String emailVar = System.Label.PBE_EmailId;
    String currenciesVar = System.Label.PBE_Currencies_Gcc;
    
    public void constructorMethod(){
        List<Product2> prodList = [SELECT Business_Family__c,Id,IsActive,Name FROM Product2 WHERE Business_Family__c != 'EMC'];
        wrapList = new list<Wrap_PBE_Export>();
        
        String catalg = catalogLabel;
        List<String> currencyList = new List<String>();
        currencyList = currenciesVar.split(',');

         for(Product2 prod: prodList){
                for(String currncy: currencyList){
                    Wrap_PBE_Export wrapObj = new Wrap_PBE_Export();
                    If( prod.IsActive == True ){
                        wrapObj.isActiveVar = 'TRUE';
                    }else{
                        wrapObj.isActiveVar = 'FALSE';
                    }
                    wrapObj.nameVar = prod.Name;
                    wrapObj.priceBook2IdVar = catalg ;
                    wrapObj.product2IdVar = string.valueOf(prod.Id);
                    wrapObj.unitPriceVar = string.valueOf('0');
                    wrapObj.currencyIsoCodeVar = currncy;
                    wrapList.add(wrapObj);
                }
        }
        wrapCount = wrapList.size();
        
        List<String> queryFields = new List<String>{'ISACTIVE','PRICEBOOK2ID','PRODUCT2ID', 'UnitPrice', 'CurrencyIsoCode'} ;
            
        for(String fieldName : queryFields)
        {
            csvFileString = csvFileString + ',' + fieldName.replace(',','');
        } 
        csvFileString = csvFileString.replaceFirst(',','') + '\n'; 
        
        String fileRow = '';
        String fieldValue = '';
        for(Wrap_PBE_Export obj : wrapList)
        {
            fileRow = '';
            System.debug('===>' + obj); 
        
            fieldValue = '' + obj.isActiveVar;
            fileRow = fileRow + ',' + fieldValue;
            
            fieldValue = '' + obj.priceBook2IdVar;
            fileRow = fileRow + ',' + fieldValue;
            
            fieldValue = '' + obj.product2IdVar;
            fileRow = fileRow + ',' + fieldValue;
            
            fieldValue = '' + obj.unitPriceVar;
            fileRow = fileRow + ',' + fieldValue;
            
            fieldValue = '' + obj.currencyIsoCodeVar;
            fileRow = fileRow + ',' + fieldValue;
                
            fileRow = fileRow.replaceFirst(',','');
            csvFileString = csvFileString + fileRow + '\n';
        }        
        sendEmail();
    }
    
    public void sendEmail(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
        List<String> sendTo = new List<String>{emailVar};
        mail.setToAddresses(sendTo);
        
        // Step 4. Set email contents - you can use variables!
        mail.setSubject('Price Book Entry CSV File');
        String body = 'Dear Suresh, ';
        body += 'Please Find attachment of csv file. Count is: '+ wrapCount + '. For Catalog: '+ catalogLabel;
        mail.setHtmlBody(body);
        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName('PBE.csv');
        efa.setBody(Blob.valueOf(csvFileString));
        
        fileAttachments.add(efa);
        
        mail.setFileAttachments(fileAttachments);
        
        if(test.isRunningTest()){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
        
    }
    
    public class Wrap_PBE_Export{
        public string isActiveVar {get;set;}
        public string nameVar{get;set;}
        public string priceBook2IdVar{get;set;}
        public string product2IdVar{get;set;}
        public string unitPriceVar{get;set;}
        public string currencyIsoCodeVar{get;set;}        
    }
}