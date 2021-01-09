public with sharing class PaginationExtensionContact {

       public PaginationExtensionContact (ApexPages.StandardController controller) {
 dis = false;
    }

    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public boolean dis{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 10;
                string queryString = 'Select firstName,Lastname, Country__C from Contact';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
    
    Public List<Contact> getContacts(){
        List<Contact> accList = new List<Contact>();
        for(Contact a : (List<Contact>)setCon.getRecords())
            accList.add(a);
        return accList;
    }
    
    public pageReference fetchContacts() {
        dis = true;
        setCon = null;
        getContacts();
        setCon.setPageNumber(1);
        return null;
    }
    
    public pageReference refresh() {
        setCon = null;
        getContacts();
        setCon.setPageNumber(1);
        return null;
    }

}