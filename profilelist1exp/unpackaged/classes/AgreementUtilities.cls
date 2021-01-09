global class AgreementUtilities{ 
    public static void fetchAgreement(Map<Id,echosign_dev1__SIGN_Agreement__c> mapNewAgreement,Map<Id,echosign_dev1__SIGN_Agreement__c> mapOldAgreement){
        Set<Id> agreementIds = new Set<Id>();
        for(echosign_dev1__SIGN_Agreement__c obj:mapNewAgreement.values()){
            System.Debug('New Status##'+obj.echosign_dev1__Status__c);
            System.Debug('Old Status##'+mapOldAgreement.get(obj.Id).echosign_dev1__Status__c);
            System.Debug('POP Line Item##'+obj.POP_Line_Item__c);
            System.Debug('New PDF##'+obj.echosign_dev1__SignedPDF__c);
            System.Debug('Old PDF##'+mapOldAgreement.get(obj.Id).echosign_dev1__SignedPDF__c);
            if(obj.echosign_dev1__Status__c != null && obj.echosign_dev1__Status__c == 'Signed' && obj.POP_Line_Item__c != null && obj.echosign_dev1__SignedPDF__c !=null && obj.echosign_dev1__SignedPDF__c != mapOldAgreement.get(obj.Id).echosign_dev1__SignedPDF__c){
                agreementIds.add(obj.Id);
            }
        }
        System.Debug('agreementIds##'+agreementIds);
        if(!agreementIds.isEmpty()){
            attachAgreementToPOPV(agreementIds);
        }
    }
    @future(callout=true)
    public static void  attachAgreementToPOPV(Set<ID> agreementIds){
        System.Debug('agreementIds in Asynchronous Method##'+agreementIds);
        Map<String,echosign_dev1__SIGN_Agreement__c> mapSignedAgreements = new Map<String,echosign_dev1__SIGN_Agreement__c>();
        for(echosign_dev1__SIGN_Agreement__c signedAgreements:[SELECT Id,echosign_dev1__Status__c,POP_Line_Item__c,echosign_dev1__SignedPDF__c FROM echosign_dev1__SIGN_Agreement__c Where Id IN:agreementIds and echosign_dev1__Status__c ='Signed' and POP_Line_Item__c != null]){
                mapSignedAgreements.put(signedAgreements.Id,signedAgreements);
        }
        System.Debug('mapSignedAgreements##'+mapSignedAgreements);
        List<Attachment> lstAttachment = new List<Attachment>();
        if(mapSignedAgreements.size() > 0){
            Http http = new Http();
            HttpResponse res;
            HttpRequest req;
            for(String objStr:agreementIds){
                System.Debug('Entered##');
                req = new HttpRequest();
                res = new HttpResponse();
                System.Debug('URL##'+mapSignedAgreements.get(objStr).echosign_dev1__SignedPDF__c);
                String contenType;
                if(mapSignedAgreements.get(objStr).echosign_dev1__SignedPDF__c != null){
                      if(mapSignedAgreements.get(objStr).echosign_dev1__SignedPDF__c.contains('.pdf')){
                          contenType = 'application/pdf';
                      }
                      else if(mapSignedAgreements.get(objStr).echosign_dev1__SignedPDF__c.contains('.png')){
                          contenType = 'image/png';
                      }
                      else if(mapSignedAgreements.get(objStr).echosign_dev1__SignedPDF__c.contains('.jpg')){
                          contenType = 'image/jpg';
                      }
                      else if(mapSignedAgreements.get(objStr).echosign_dev1__SignedPDF__c.contains('.gif')){
                          contenType = 'image/gif';
                      }
                      else if(mapSignedAgreements.get(objStr).echosign_dev1__SignedPDF__c.contains('.html')){
                          contenType = 'text/html';
                      }

                      req = buildRequest(mapSignedAgreements.get(objStr).echosign_dev1__SignedPDF__c,contenType);
                        if(Limits.getCallouts() < Limits.getLimitCallouts()){
                             if(!Test.isRunningTest()){
                                res = http.send(req); 
                             }
                             else{
                                 res.setHeader('Content-Type', 'image/png');
                                 res.setBody('[{"success":true}]');
                                 res.setStatusCode(200);
                             }
                             Attachment objAttach = createAttachment(mapSignedAgreements.get(objStr).POP_Line_Item__c,res.getBodyAsBlob(),contenType);
                             lstAttachment.add(objAttach);
                        }
                }
            }
        }
        //Insert Attachment.
        System.Debug('lstAttachment##'+lstAttachment);
        if(!lstAttachment.isEmpty()){
            insert lstAttachment;
        }
   }
   public static HttpRequest buildRequest(string endpoint,string contentType){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', contentType);
        req.setHeader('Charset', 'UTF-8');
        return req;
   }
   public static Attachment createAttachment(string parentId,Blob image,string contentType){
        Attachment n = new Attachment();
        n.ParentId = parentId;
        n.Name = 'myImage.jpg';
        n.Body = image;
        n.contentType = contentType;
        return n;
   }
}