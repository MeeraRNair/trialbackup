/**********************************************
Author         : B Uday Kiran
Date           : 01/06/2017
CR             : 
Description    : As part of Dell-EMC Integration there are changes for Partner Status Picklist
                 in Lead Object Values from Lead Object were Populated On to Account Object
                 (Lead ==> partner_status__c [picklist] ; Account ==> partner_relationship__c [Text])
                 in Apex Class for Some Functionality we are having hard coded Comparision 
                 eg : Partnerstatus =='Registered' so now These Logics were Removed From The Respective Logics and
                 all The Respective Classes Referring This Class , to Make The COde centralized we are using Custom labels
                 where The Respective Picklist Values Are Save with '#' separated Values
                    

**********************************************/

public class PartnerStatusUtilityClass{

    /***************Registered*****************************/
        public Static List<String> RegisteredTypeList(){
        
        
            return System.Label.Registered_Alternative_Values.split('#');     
        }
    
        public Static Boolean RegisteredTypeContains(String PassedValue){
        
            //check the Passed values contains in The respective custom lable String set 
            //and return the value
            return ReturnSetOfString(System.Label.Registered_Alternative_Values).contains(PassedValue);     
        }
    
        public Static Boolean RegisteredTypeNotContains(String PassedValue){
        
            //check the Passed values contains in The respective custom lable String set 
            //and return the value
            return !ReturnSetOfString(System.Label.Registered_Alternative_Values).contains(PassedValue);     
        }
    
    /***************End of Registered*****************************/
     
    /***************  Preferred    *****************************/
        public Static List<String> PreferredTypeList(){
        
        
            return System.Label.Preferred_Alternative_Values.split('#');     
        }
    
        public Static Boolean PreferredTypeContains(String PassedValue){
    
            return ReturnSetOfString(System.Label.Preferred_Alternative_Values).contains(PassedValue);   
        }
    
        public Static Boolean PreferredTypeNotContains(String PassedValue){
    
             return !ReturnSetOfString(System.Label.Preferred_Alternative_Values).contains(PassedValue);   
        }
    
    /***************End of Preferred*****************************/
     
    /***************  Premier      *****************************/
        public Static List<String> PremierTypeList(){
        
        
            return System.Label.Premier_Alternative_Values.split('#');     
        }
    
        public Static Boolean PremierTypeContains(String PassedValue){
    
            return ReturnSetOfString(System.Label.Premier_Alternative_Values).contains(PassedValue);  
        }
    
        public Static Boolean PremierTypeNotContains(String PassedValue){
    
            return !ReturnSetOfString(System.Label.Premier_Alternative_Values).contains(PassedValue);  
        }
    
    /***************End of Premier  *****************************/
    
    
    /***************  Certified   *****************************/
        

        public Static List<String> CertifiedTypeList(){
        
        
            return System.Label.Certified_Alternative_Values.split('#');     
        }
    
        public Static Boolean CertifiedTypeContains(String PassedValue){
    
            return ReturnSetOfString(System.Label.Certified_Alternative_Values).contains(PassedValue);   
        }
    
        public Static Boolean CertifiedTypeNotContains(String PassedValue){
    
             return !ReturnSetOfString(System.Label.Certified_Alternative_Values).contains(PassedValue);   
        }
    
    
    /***************End of Certified*****************************/
    
    /*************** Authorized   *****************************/
      
        public Static List<String> AuthorizedTypeList(){
        
        
            return System.Label.Authorized_Alternative_Values.split('#');     
        }
    
        public Static Boolean AuthorizedTypeContains(String PassedValue){
    
            return ReturnSetOfString(System.Label.Authorized_Alternative_Values).contains(PassedValue);   
        }
    
        public Static Boolean AuthorizedTypeNotContains(String PassedValue){
    
             return !ReturnSetOfString(System.Label.Authorized_Alternative_Values).contains(PassedValue);   
        }
    
    /***************End of Authorized*****************************/
     
        
        public Static Set<String> ReturnSetOfString(String Labelis){
        
            //Split the Custom Lable with '#'
            //And Pass Set of strings 
            list<String> AllValues = Labelis.split('#');
            set<String> AllLableValues = new set<String>();
        
            AllLableValues.addAll(AllValues);
       
            return AllLableValues;
    
    
        }


}