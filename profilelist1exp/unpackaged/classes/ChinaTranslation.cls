/*

*Name: ChinaTranslation
*Purpose:Created for Translating Double Byte charaters into english By using Baidu Translation Api
CR Request:14806

*/

public class ChinaTranslation {
        private Lead leadRecord;
        public List<Lead> leadRecordList;
        public List<String> listd;
        public string legalCompanyName{set;get;}
        public string legalAdd1{set;get;}
        public string legalAdd2{set;get;}
        public string legalCountry{set;get;}
        public string legalCity{set;get;}
        public string legalPostalState{set;get;}
        public string legalPostalCode{set;get;}
        public string legalPostalSuburb{set;get;}
        public string legalPostalPhone{set;get;}
        public string legalPostalFax{set;get;}
        public string strmgLocalName{set;get;}
        public string strlocalAdd1{set;get;}
        public string strlocalAdd2{set;get;}
        public string strlocalCity{set;get;}
        public string strlocalState{set;get;}
        public string strlocalCountry{set;get;}
        public string sign1{set;get;}
        public string signature{set;get;}
        public string sign2{set;get;}
        public string str{set;get;}
        public string str1{set;get;}
        public string sign{set;get;}
        public string jsonBody{set;get;}
        public string appid{set;get;}
        public string Salt{set;get;}
        public string key{set;get;}
        public boolean flag{set;get;}
        public String resPonceIs{set;get;}
        public String resPonceIs1{set;get;}
        public Translation_Parser.TranslationParser ts{set;get;}
        public Translation_Parser.TranslationParser ts1{set;get;}
        
    public ChinaTranslation(ApexPages.StandardController controller) {
                 leadRecord = (Lead)controller.getRecord();  
             
        leadRecordList = [SELECT id,Master_Group_ID__c,Legal_Local_Company_Name__c,Legal_Local_Address_1__c,Legal_Local_Address_2__c,
                                  Legal_Local_Country__c,Legal_Local_City__c,Legal_Local_Postal_State__c,
                                  Legal_Local_Postal_Code__c,Legal_Local_Postal_Suburb__c,Legal_Local_Postal_Phone__c,Legal_Local_Postal_Fax__c,
                                  Postal_Company_Name__c,Postal_Address_1__c, Postal_Address_2__c,Postal_Country__c, Postal_City__c, 
                                  Postal_State__c,Postal_PostalCode__c,Postal_suburb__c,Postal_Phone__c, Postal_Fax__c,
                                  Sales_Relationship_Local_Company_Name__c,Sales_Relationship_Local_Address_1__c,Sales_Relationship_Local_Address_2__c,Sales_Relationship_Local_Country__c,
                                  Sales_Relationship_Local_City__c,Sales_Relationship_Local_State__c,Sales_Relationship_Local_Code__c,
                                  Sales_Relationship_Local_Suburb__c,Sales_Relationship_Local_Phone__c,Sales_Relationship_Local_Fax__c,
                                  Physical_Company_Name__c,Physical_Address_1__c,Physical_Address_2__c,Physical_Country__c,Physical_City__c,Physical_State__c,
                                  Physical_PostalCode__c,Physical_Suburb__c,Physical_Phone__c,Physical_Fax__c,Mg_Name__c,Mg_Address_Line_1__c,
                                  Mg_Address_Line_2__c,Mg_City__c,Mg_State__c,Mg_Country_Name__c,Mg_Local_Name__c,Mg_Local_Address_Line_1__c,
                                 Mg_Local_Address_Line_2__c,Mg_Local_City__c,Mg_Local_State__c,Mg_Local_Country_Name__c
                                FROM Lead
                                WHERE Id =:leadRecord.Id LIMIT 1];
             system.debug('====='+leadRecordList);
                                //WHERE Id =:leadId ];
                                
                        
            }

    
    
    public void translateState(){
        
        
       
       appid=System.label.Translation_API;
       Salt = '1502690863110';
       key=System.label.Translation_Key;
       system.debug(key);
      try{
       flag=true;
        for(Lead ld:leadRecordList){
                   legalCompanyName=ld.Legal_Local_Company_Name__c;             
                   legalAdd1 =ld.Legal_Local_Address_1__c; 
                   legalAdd2 =ld.Legal_Local_Address_2__c;
                   legalCountry = ld.Legal_Local_Country__c;
                   legalCity =ld.Legal_Local_City__c;
                   legalPostalState =ld.Legal_Local_Postal_State__c;  
                   legalPostalCode=ld.Legal_Local_Postal_Code__c;    
                   legalPostalSuburb=ld.Legal_Local_Postal_Suburb__c;
                   legalPostalPhone=ld.Legal_Local_Postal_Phone__c;
                   legalPostalFax=ld.Legal_Local_Postal_Fax__c; 
                   strmgLocalName =ld.Mg_Local_Name__c;
                   strlocalAdd1 =ld.Mg_Local_Address_Line_1__c;
                   strlocalAdd2 =ld.Mg_Local_Address_Line_2__c;
                   strlocalCity =ld.Mg_Local_City__c;
                   strlocalState =ld.Mg_Local_State__c;
                    strlocalCountry =ld.Mg_Country_Name__c;
                If(null!=ld.Sales_Relationship_Local_Country__c && System.Label.Lead_Legal_Local_Addr_Applicable_Countries.contains(ld.Sales_Relationship_Local_Country__c.toUpperCase()) && ld.Sales_Relationship_Local_Country__c !=NULL && ld.Sales_Relationship_Local_Country__c!='' && ld.Legal_Local_Country__c !=NULL && ld.Legal_Local_Country__c!='') { 
                        str=legalCompanyName+'\n'+legalAdd1+'\n'+legalAdd2+'\n'+legalCity+'\n'+legalPostalState+'\n'+strmgLocalName+'\n'+strlocalAdd1+'\n'+strlocalAdd2+'\n'+strlocalCity+'\n'+strlocalState;
                        str1=ld.Sales_Relationship_Local_Company_Name__c+'\n'+ld.Sales_Relationship_Local_Address_1__c+'\n'+ld.Sales_Relationship_Local_City__c;
                        str1=str1+'\n'+ld.Sales_Relationship_Local_State__c+'\n'+ld.Sales_Relationship_Local_Address_2__c;
                        system.debug('id==='+str);
                        system.debug('id++++++'+str1);
                        
               }
               else If(null!=ld.Sales_Relationship_Local_Country__c && System.Label.Lead_Legal_Local_Addr_Applicable_Countries.contains(ld.Sales_Relationship_Local_Country__c.toUpperCase()) && ld.Sales_Relationship_Local_Country__c !=NULL && ld.Sales_Relationship_Local_Country__c!='' ){
                str=ld.Sales_Relationship_Local_Company_Name__c+'\n'+ld.Sales_Relationship_Local_Address_1__c+'\n'+ld.Sales_Relationship_Local_City__c;
                str=str+'\n'+ld.Sales_Relationship_Local_State__c+'\n'+ld.Sales_Relationship_Local_Address_2__c;
                }
               else{
               str=legalCompanyName+'\n'+legalAdd1+'\n'+legalAdd2+'\n'+legalCity+'\n'+legalPostalState+'\n'+strmgLocalName+'\n'+strlocalAdd1+'\n'+strlocalAdd2+'\n'+strlocalCity+'\n'+strlocalState;
               system.debug('id==='+str);
               }
               If(null!=ld.Sales_Relationship_Local_Country__c && System.Label.Lead_Legal_Local_Addr_Applicable_Countries.contains(ld.Sales_Relationship_Local_Country__c.toUpperCase()) && ld.Sales_Relationship_Local_Country__c !=NULL && ld.Sales_Relationship_Local_Country__c!='' && ld.Legal_Local_Country__c !=NULL && ld.Legal_Local_Country__c!='') {      
             phsicalAndPostal();
            /* sign1=appid+str+Salt+Key;
                sign = encodingutil.convertToHex(crypto.generateDigest('md5',blob.valueOf(sign1)));
                String tralationText = encodingutil.urlEncode(str, 'UTF-8'); // Encoding with UTF-8
                Http p=new Http();
                HttpRequest Request=new HttpRequest();
                string endpoint='https://fanyi-api.baidu.com/api/trans/vip/translate?q='+tralationText +'&appid='+appid+'&to=en&sign='+sign+'&from=auto&salt='+Salt;
                Request.setEndPoint(endpoint);
                Request.setMethod('GET');
                Request.setTimeout(120000);
                HttpResponse response = new HttpResponse();
                if(!Test.isRunningTest()){
                   response =p.send(Request);
                }else{
                
                }
                resPonceIs = '';
               
               if(!Test.isRunningTest()){
               
                     resPonceIs  =   response.getBody();
                     system.debug('asd     '+resPonceIs);
                                  
                     
               }else{
               
                     resPonceIs = '{\"from\":\"kor\",\"to\":\"en\",\"trans_result\":[{\"src\":\"\\ud558\\uc774\\ud14c\\ud06c \\uc2dc\\ud2f0\",\"dst\":\"high tech city\"},{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"\\ud558\\uc774\\ub370\\ub77c\\ubc14\\ub4dc\",\"dst\":\"the lava).\"},{\"src\":\"\\ud154\\ub780\\uac00\\ub098\",\"dst\":\"the hotel is now\"},{\"src\":\"\\ud558\\uc774 \\ub370 \\ub77c \\ubc14\\ub4dc\",\"dst\":\"this is for you.\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"505001\",\"dst\":\"505001\"}]}'; 
                     system.debug('parse==='+resPonceIs); 
               }
               
               sign2=appid+str1+Salt+Key;
                signature = encodingutil.convertToHex(crypto.generateDigest('md5',blob.valueOf(sign2)));
                String tralationText1 = encodingutil.urlEncode(str1, 'UTF-8'); // Encoding with UTF-8
                Http p1=new Http();
                HttpRequest Request1=new HttpRequest();
                string endpoint1='https://fanyi-api.baidu.com/api/trans/vip/translate?q='+tralationText1 +'&appid='+appid+'&to=en&sign='+signature+'&from=auto&salt='+Salt;
                Request1.setEndPoint(endpoint1);
                Request1.setMethod('GET');
                Request1.setTimeout(120000);
                HttpResponse response1 = new HttpResponse();
                if(!Test.isRunningTest()){
                   response1 =p1.send(Request1);
                }else{
                
                }
               
                resPonceIs1 = '';
               
               if(!Test.isRunningTest()){
               
                     resPonceIs1  =   response1.getBody();
                     system.debug('asd 111    '+resPonceIs1);
                                  
                     
               }else{
               
                     resPonceIs1 = '{\"from\":\"kor\",\"to\":\"en\",\"trans_result\":[{\"src\":\"\\ud558\\uc774\\ud14c\\ud06c \\uc2dc\\ud2f0\",\"dst\":\"high tech city\"},{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"\\ud558\\uc774\\ub370\\ub77c\\ubc14\\ub4dc\",\"dst\":\"the lava).\"},{\"src\":\"\\ud154\\ub780\\uac00\\ub098\",\"dst\":\"the hotel is now\"},{\"src\":\"\\ud558\\uc774 \\ub370 \\ub77c \\ubc14\\ub4dc\",\"dst\":\"this is for you.\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"505001\",\"dst\":\"505001\"}]}'; 
                     system.debug('parse==='+resPonceIs1); 
               } */
               }
               
               else{
                sign1=appid+str+Salt+Key;
                sign = encodingutil.convertToHex(crypto.generateDigest('md5',blob.valueOf(sign1)));
                String tralationText = encodingutil.urlEncode(str, 'UTF-8'); // Encoding with UTF-8
                Http p=new Http();
                HttpRequest Request=new HttpRequest();
                string endpoint='https://fanyi-api.baidu.com/api/trans/vip/translate?q='+tralationText +'&appid='+appid+'&to=en&sign='+sign+'&from=auto&salt='+Salt;
                Request.setEndPoint(endpoint);
                Request.setMethod('GET');
                Request.setTimeout(120000);
                HttpResponse response = new HttpResponse();
                if(!Test.isRunningTest()){
                   response =p.send(Request);
                }else{
                
                }
                   resPonceIs = '';
               
               if(!Test.isRunningTest()){
               
                     resPonceIs  =   response.getBody();
                     system.debug('asd2222     '+resPonceIs);
                                  
                     
               }else{
               
                     resPonceIs = '{\"from\":\"kor\",\"to\":\"en\",\"trans_result\":[{\"src\":\"\\ud558\\uc774\\ud14c\\ud06c \\uc2dc\\ud2f0\",\"dst\":\"high tech city\"},{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"\\ud558\\uc774\\ub370\\ub77c\\ubc14\\ub4dc\",\"dst\":\"the lava).\"},{\"src\":\"\\ud154\\ub780\\uac00\\ub098\",\"dst\":\"the hotel is now\"},{\"src\":\"\\ud558\\uc774 \\ub370 \\ub77c \\ubc14\\ub4dc\",\"dst\":\"this is for you.\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"505001\",\"dst\":\"505001\"}]}'; 
                     system.debug('parse==='+resPonceIs); 
               }
               }
               If(null!=ld.Sales_Relationship_Local_Country__c && System.Label.Lead_Legal_Local_Addr_Applicable_Countries.contains(ld.Sales_Relationship_Local_Country__c.toUpperCase()) && ld.Sales_Relationship_Local_Country__c !=NULL && ld.Sales_Relationship_Local_Country__c!='' && ld.Legal_Local_Country__c !=NULL && ld.Legal_Local_Country__c!='') {
              
               ts = Translation_Parser.parse(resPonceIs );
               ts1 = Translation_Parser.parse(resPonceIs1 );
                System.debug('test1'+ts.trans_result[0].dst);
                }
                else{
               ts = Translation_Parser.parse(resPonceIs );
                }
                If(null!=ld.Sales_Relationship_Local_Country__c && System.Label.Lead_Legal_Local_Addr_Applicable_Countries.contains(ld.Sales_Relationship_Local_Country__c.toUpperCase()) && ld.Sales_Relationship_Local_Country__c !=NULL && ld.Sales_Relationship_Local_Country__c!='' && ld.Legal_Local_Country__c !=NULL && ld.Legal_Local_Country__c!='') {
                    populatePostalAndPhysical (ld,ts);
                    populatePostalAndPhysical2 (ld,ts1);
                    
                 }
              else If(null!=ld.Sales_Relationship_Local_Country__c && System.Label.Lead_Legal_Local_Addr_Applicable_Countries.contains(ld.Sales_Relationship_Local_Country__c.toUpperCase())&& ld.Sales_Relationship_Local_Country__c !=NULL ){ 
                   populatePhysical (ld,ts);
                
                 }
                 else{
                 populatePostal(ld,ts);
                 }
         
         
               if(ld.Postal_Address_2__c=='Null' || ld.Postal_Address_2__c=='null'|| ld.Postal_Address_2__c=='Is'||ld.Postal_Address_2__c=='zero'){
                                   ld.Postal_Address_2__c='';
                  }
               if(ld.Postal_Company_Name__c=='Null' || ld.Postal_Company_Name__c=='null'|| ld.Postal_Company_Name__c=='Is'|| ld.Postal_Company_Name__c=='zero'){
                                    ld.Postal_Company_Name__c='';
                   }
             if(ld.Physical_Company_Name__c=='Null' || ld.Physical_Company_Name__c=='null'|| ld.Physical_Company_Name__c=='Is'||ld.Physical_Company_Name__c=='zero'){
                                ld.Physical_Company_Name__c='';
             }
             if(ld.Physical_Address_1__c=='Null' || ld.Physical_Address_1__c=='null'|| ld.Physical_Address_1__c=='Is'||ld.Physical_Address_1__c=='zero'){
                                ld.Physical_Address_1__c='';
             }
             if(ld.Physical_Address_2__c=='Null' || ld.Physical_Address_2__c=='null'|| ld.Physical_Address_2__c=='Is'||ld.Physical_Address_2__c=='zero'){
                                ld.Physical_Address_2__c='';
             }
             if(ld.Physical_City__c=='Null' || ld.Physical_City__c=='null'|| ld.Physical_City__c=='Is'||ld.Physical_City__c=='zero'){
                                ld.Physical_City__c='';
             }
             if(ld.Physical_State__c=='Null' || ld.Physical_State__c=='null'|| ld.Physical_State__c=='Is'||ld.Physical_State__c=='zero'){
                                ld.Physical_State__c='';
             }
             If(null!=ld.Sales_Relationship_Local_Country__c && System.Label.Lead_Legal_Local_Addr_Applicable_Countries.contains(ld.Sales_Relationship_Local_Country__c.toUpperCase()) && ld.Sales_Relationship_Local_Country__c !=NULL && ld.Sales_Relationship_Local_Country__c!='' && ld.Legal_Local_Country__c !=NULL && ld.Legal_Local_Country__c!='' ){
               country__c cn = [select id from Country__c where Name=:ld.Legal_Local_Country__c limit 1];
               ld.postal_country__c =cn.id;
               country__c cn1 = [select id from Country__c where Name=:ld.Sales_Relationship_Local_Country__c limit 1];
              ld.Physical_Country__c=cn1.id;
              }
              else if(null!=ld.Sales_Relationship_Local_Country__c && System.Label.Lead_Legal_Local_Addr_Applicable_Countries.contains(ld.Sales_Relationship_Local_Country__c.toUpperCase())&& ld.Sales_Relationship_Local_Country__c !=NULL ){
              country__c cn1 = [select id from Country__c where Name=:ld.Sales_Relationship_Local_Country__c limit 1];
              ld.Physical_Country__c=cn1.id;
              }
              else{
              country__c cn = [select id from Country__c where Name=:ld.Legal_Local_Country__c limit 1];
               ld.postal_country__c =cn.id;
              }
                          
               System.debug('>>>>>> ld '+ld); 
              
              update ld;
              
               
            }
     }
         catch(exception e){
         flag=false;
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
          }
         
          }
        
         public PageReference redirect(){
        
            PageReference pageRef = new PageReference('/'+leadRecordList[0].Id);
            return pageRef;
        }
        public void phsicalAndPostal(){
                sign1=appid+str+Salt+Key;
                sign = encodingutil.convertToHex(crypto.generateDigest('md5',blob.valueOf(sign1)));
                String tralationText = encodingutil.urlEncode(str, 'UTF-8'); // Encoding with UTF-8
                Http p=new Http();
                HttpRequest Request=new HttpRequest();
                string endpoint='https://fanyi-api.baidu.com/api/trans/vip/translate?q='+tralationText +'&appid='+appid+'&to=en&sign='+sign+'&from=auto&salt='+Salt;
                Request.setEndPoint(endpoint);
                Request.setMethod('GET');
                Request.setTimeout(120000);
                HttpResponse response = new HttpResponse();
                if(!Test.isRunningTest()){
                   response =p.send(Request);
                }else{
                
                }
                resPonceIs = '';
               
               if(!Test.isRunningTest()){
               
                     resPonceIs  =   response.getBody();
                     system.debug('asd     '+resPonceIs);
                                  
                     
               }else{
               
                     resPonceIs = '{\"from\":\"kor\",\"to\":\"en\",\"trans_result\":[{\"src\":\"\\ud558\\uc774\\ud14c\\ud06c \\uc2dc\\ud2f0\",\"dst\":\"high tech city\"},{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"\\ud558\\uc774\\ub370\\ub77c\\ubc14\\ub4dc\",\"dst\":\"the lava).\"},{\"src\":\"\\ud154\\ub780\\uac00\\ub098\",\"dst\":\"the hotel is now\"},{\"src\":\"\\ud558\\uc774 \\ub370 \\ub77c \\ubc14\\ub4dc\",\"dst\":\"this is for you.\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"505001\",\"dst\":\"505001\"}]}'; 
                     system.debug('parse==='+resPonceIs); 
               }
               
               sign2=appid+str1+Salt+Key;
                signature = encodingutil.convertToHex(crypto.generateDigest('md5',blob.valueOf(sign2)));
                String tralationText1 = encodingutil.urlEncode(str1, 'UTF-8'); // Encoding with UTF-8
                Http p1=new Http();
                HttpRequest Request1=new HttpRequest();
                string endpoint1='https://fanyi-api.baidu.com/api/trans/vip/translate?q='+tralationText1 +'&appid='+appid+'&to=en&sign='+signature+'&from=auto&salt='+Salt;
                Request1.setEndPoint(endpoint1);
                Request1.setMethod('GET');
                Request1.setTimeout(120000);
                HttpResponse response1 = new HttpResponse();
                if(!Test.isRunningTest()){
                   response1 =p1.send(Request1);
                }else{
                
                }
               
                resPonceIs1 = '';
               
               if(!Test.isRunningTest()){
               
                     resPonceIs1  =   response1.getBody();
                     system.debug('asd 111    '+resPonceIs1);
                                  
                     
               }else{
               
                     resPonceIs1 = '{\"from\":\"kor\",\"to\":\"en\",\"trans_result\":[{\"src\":\"\\ud558\\uc774\\ud14c\\ud06c \\uc2dc\\ud2f0\",\"dst\":\"high tech city\"},{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"\\ud558\\uc774\\ub370\\ub77c\\ubc14\\ub4dc\",\"dst\":\"the lava).\"},{\"src\":\"\\ud154\\ub780\\uac00\\ub098\",\"dst\":\"the hotel is now\"},{\"src\":\"\\ud558\\uc774 \\ub370 \\ub77c \\ubc14\\ub4dc\",\"dst\":\"this is for you.\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"505001\",\"dst\":\"505001\"}]}'; 
                     system.debug('parse==='+resPonceIs1); 
               }
               }
        public void populatePostalAndPhysical1(Lead ld,List<string> listd){
                ld.Postal_Company_Name__c=listd[0] ;
                ld.Company=listd[0] ;//added on 15-9-17
                ld.Postal_Address_1__c = listd[1];
                ld.Postal_Address_2__c = listd[2];  
                ld.Postal_City__c=listd[3];
                ld.Postal_State__c=listd[4]; 
                ld.Postal_PostalCode__c=legalPostalCode; 
                ld.Postal_suburb__c=legalPostalSuburb;
                ld.Postal_Phone__c=legalPostalPhone;
                ld.Postal_Fax__c=legalPostalFax; 
            
               if(ld.Master_Group_ID__c == null){
                ld.Mg_Name__c=listd[5];    
                ld.Mg_Address_Line_1__c=listd[6];
                ld.Mg_Address_Line_2__c='test1';//listd[7];
                ld.Mg_City__c=listd[8];  
                ld.Mg_State__c=listd[9];
                }
                
                
                   
        }
         public void populatePostalAndPhysical3(Lead ld,List<string> listd){
                ld.Physical_Company_Name__c=listd[0];  
                ld.Physical_Address_1__c=listd[1]; 
                ld.Physical_City__c=listd[2]; 
                ld.Physical_State__c=listd[3];
                ld.Physical_Address_2__c=listd[4];
                 
                ld.Physical_PostalCode__c=ld.Sales_Relationship_Local_Code__c; 
                ld.Physical_Suburb__c=ld.Sales_Relationship_Local_Suburb__c;
                ld.Physical_Phone__c=ld.Sales_Relationship_Local_Phone__c;
                ld.Physical_Fax__c =ld.Sales_Relationship_Local_Fax__c;
                
                   
        }
        public void populatePostalAndPhysical2(Lead ld,Translation_Parser.TranslationParser ts1){
        listd = new List<String>();
         if(ts1.from_Z == ts1.to){
         for(String S:ts1.trans_result[0].dst.split('\n')){
         system.debug('sdfer    '+s);
         listd.add(s);
         
         }
         populatePostalAndPhysical3(ld,listd);
                
                }
            else{
                ld.Physical_Company_Name__c=ts1.trans_result[0].dst; 
                ld.Physical_Address_1__c=ts1.trans_result[1].dst; 
                ld.Physical_City__c=ts1.trans_result[2].dst; 
                ld.Physical_State__c=ts1.trans_result[3].dst;
                ld.Physical_Address_2__c=ts1.trans_result[4].dst;
                 
                ld.Physical_PostalCode__c=ld.Sales_Relationship_Local_Code__c; 
                ld.Physical_Suburb__c=ld.Sales_Relationship_Local_Suburb__c;
                ld.Physical_Phone__c=ld.Sales_Relationship_Local_Phone__c;
                ld.Physical_Fax__c =ld.Sales_Relationship_Local_Fax__c;
                }
                
                
        
        }
        
        public void populatePostalAndPhysical(Lead ld,Translation_Parser.TranslationParser ts){
        listd = new List<String>();
         if(ts.from_Z == ts.to){
         for(String S:ts.trans_result[0].dst.split('\n')){
         system.debug('sdfer    '+s);
         listd.add(s);
         
         }
         populatePostalAndPhysical1(ld,listd);
                
                }
            else{
                ld.Postal_Company_Name__c= ts.trans_result[0].dst;
                ld.Company= ts.trans_result[0].dst;//added on 15-9-17
                ld.Postal_Address_1__c = ts.trans_result[1].dst;
                ld.Postal_Address_2__c = ts.trans_result[2].dst;  
                ld.Postal_City__c=ts.trans_result[3].dst;
                ld.Postal_State__c=ts.trans_result[4].dst;
                ld.Postal_PostalCode__c=legalPostalCode; 
                ld.Postal_suburb__c=legalPostalSuburb;
                ld.Postal_Phone__c=legalPostalPhone;
                ld.Postal_Fax__c=legalPostalFax;
                
               if(ld.Master_Group_ID__c == null){
                ld.Mg_Name__c=ts.trans_result[5].dst; 
                ld.Mg_Address_Line_1__c=ts.trans_result[6].dst;
                ld.Mg_Address_Line_2__c=ts.trans_result[7].dst;
                ld.Mg_City__c=ts.trans_result[8].dst;
                ld.Mg_State__c=ts.trans_result[9].dst;
                }               
                 
                
                
        
        }
        }
        
        
        public void populatePhysical(Lead ld,Translation_Parser.TranslationParser ts){
        listd = new List<String>();
         if(ts.from_Z == ts.to){
         for(String S:ts.trans_result[0].dst.split('\n')){
         system.debug('sdfer    '+s);
         listd.add(s);
         
         }
         
                ld.Physical_Company_Name__c=listd[0]; 
                ld.Physical_Address_1__c=listd[1]; 
                ld.Physical_City__c=listd[2]; 
                ld.Physical_State__c=listd[3];
                ld.Physical_Address_2__c=listd[4];
                 
                ld.Physical_PostalCode__c=ld.Sales_Relationship_Local_Code__c; 
                ld.Physical_Suburb__c=ld.Sales_Relationship_Local_Suburb__c;
                ld.Physical_Phone__c=ld.Sales_Relationship_Local_Phone__c;
                ld.Physical_Fax__c =ld.Sales_Relationship_Local_Fax__c; 
         
                }
                else{
        
                ld.Physical_Company_Name__c=ts.trans_result[0].dst; 
                ld.Physical_Address_1__c=ts.trans_result[1].dst; 
                ld.Physical_City__c=ts.trans_result[2].dst; 
                ld.Physical_State__c=ts.trans_result[3].dst;
                ld.Physical_Address_2__c=ts.trans_result[4].dst;
                 
                ld.Physical_PostalCode__c=ld.Sales_Relationship_Local_Code__c; 
                ld.Physical_Suburb__c=ld.Sales_Relationship_Local_Suburb__c;
                ld.Physical_Phone__c=ld.Sales_Relationship_Local_Phone__c;
                ld.Physical_Fax__c =ld.Sales_Relationship_Local_Fax__c;
                }
        
        }
        
        public void populatePostal1(Lead ld,List<string> listd){
                ld.Postal_Company_Name__c= listd[0];
                ld.Company= listd[0];//added on 15-9-17
                
                ld.Postal_Address_1__c = listd[1];
                ld.Postal_Address_2__c = listd[2];  
                ld.Postal_City__c=listd[3];
                ld.Postal_State__c=listd[4]; 
                ld.Postal_PostalCode__c=legalPostalCode; 
                ld.Postal_suburb__c=legalPostalSuburb;
                ld.Postal_Phone__c=legalPostalPhone;
                ld.Postal_Fax__c=legalPostalFax;
            
                if(ld.Master_Group_ID__c == null){
                ld.Mg_Name__c=listd[5];       
                ld.Mg_Address_Line_1__c = listd[6];
                ld.Mg_Address_Line_2__c=listd[7];
                ld.Mg_City__c = listd[8];
                ld.Mg_State__c= listd[9];
                }
               
        
        }
        
        public void populatePostal(Lead ld,Translation_Parser.TranslationParser ts){
        listd = new List<String>();
         if(ts.from_Z == ts.to){
         for(String S:ts.trans_result[0].dst.split('\n')){
         system.debug('sdfer    '+s);
         listd.add(s);
         
         }
         
          populatePostal1(ld,listd);
         
                }
               else
               {
                
        
                ld.Postal_Company_Name__c= ts.trans_result[0].dst;
                ld.company= ts.trans_result[0].dst;
                
                system.debug(ld.Postal_Company_Name__c);//added on 15-9-17
                ld.Postal_Address_1__c = ts.trans_result[1].dst;
                system.debug(ld.Postal_Address_1__c);
                ld.Postal_Address_2__c = ts.trans_result[2].dst;  
                ld.Postal_City__c=ts.trans_result[3].dst;
                ld.Postal_State__c=ts.trans_result[4].dst;
               if(ld.Master_Group_ID__c == null){ 
                 ld.Mg_Name__c=ts.trans_result[5].dst;
                 ld.Mg_Address_Line_1__c =ts.trans_result[6].dst;
                 
                 ld.Mg_Address_Line_2__c=ts.trans_result[7].dst;
               if(ld.Mg_Address_Line_2__c=='null'){
                ld.Mg_Address_Line_2__c = '';
                 }
                 ld.Mg_City__c = ts.trans_result[8].dst;
                 ld.Mg_State__c = ts.trans_result[9].dst;
               }
                ld.Postal_PostalCode__c=legalPostalCode; 
                ld.Postal_suburb__c=legalPostalSuburb;
                ld.Postal_Phone__c=legalPostalPhone;
                ld.Postal_Fax__c=legalPostalFax; 
                }
                
        }
        
     //V1.0 Validate Double byte characters in company and address fields
     public static boolean validateDoubleByteRegExp(String addressField){
        String strAddressPattern=Label.Account_Name_Pattern;
        Pattern addressFieldsPattern = Pattern.compile(strAddressPattern);
        Matcher matcherInstance = addressFieldsPattern.matcher(addressField);
        system.debug(logginglevel.INFO,'Pattern Matching Result ' + matcherInstance.matches());
        return matcherInstance.matches();
    }

        
 }