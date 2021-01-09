/*
History:
Version     Date                Modified By         CR#         Description     
--------------------------------------------------------------------------------------
1.0                                                             Created
1.2         23-May-2019       Abhinav                         Modified conditions
*/
public class CarouselController {


    //bof - v1.2
    @AuraEnabled 
    public static List<Carousel_Configuration__c> getCarouselRecords() {
        String usrPersona = '';
        Integer rowCount = 0;
        String strQuery = '';
        usrPersona = [SELECT User_Persona__c FROM User WHERE Id = :UserInfo.getUserId()][0].User_Persona__c;
        /*if(!String.isBlank(usrPersona)) {
            rowCount = (Integer) [SELECT Count(Id) cnt FROM Carousel_Configuration__c WHERE Active__c = True AND Type__c = 'Slider' AND Persona__c INCLUDES (:usrPersona)][0].get('cnt');
        }*/
        
        strQuery = 'SELECT Id, Description__c, Header__c, Image_Onclick_URL__c, Type__c, (SELECT ContentDocumentId, ContentDocument.FileType, LinkedEntityId FROM ContentDocumentLinks), Active__c, Persona__c FROM Carousel_Configuration__c WHERE Active__c = True';

        //if(rowCount > 0) {
        if(!String.isBlank(usrPersona)) {
            strQuery += ' AND ((Type__c = \'Slider\' AND (Persona__c INCLUDES (:usrPersona) OR Persona__c = \'\')) OR (Type__c = \'Fixed\'))';
        } else {
            strQuery += ' AND ((Type__c = \'Slider\' AND Persona__c = \'\') OR (Type__c = \'Fixed\'))';
        }

        return Database.query(strQuery);
    }
    //eof - v1.2

    //bof - v1.2
    /*@AuraEnabled 
    public static List<Carousel_Configuration__c> getCarouselRecords(){
        return [Select 
                        Id,
                        Description__c,
                        Header__c,
                        Image_Onclick_URL__c,
                        Type__c,
                        (
                        SELECT ContentDocumentId, ContentDocument.FileType,
                               LinkedEntityId  
                            FROM ContentDocumentLinks
                        ),
                        Active__c 
                  
                FROM 
                        Carousel_Configuration__c 
                WHERE
                         Active__c = True];
    }*/
    //eof - v1.2
}