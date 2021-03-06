public class FAP_Location {

  public ID id {get; set;}
  public String name {get;set;}
  public Double latitude {get;set;}
  public Double longitude {get;set;}
  public String street {get;set;}
  public String city {get;set;}
  public String state {get;set;}
  public String postalCode {get;set;}
  public String country {get;set;}
  public String pointOfContactName{get; set;}
  public String phone{get;set;}
  public Integer serialNumber {get;set;}
  public List<FAP_FormField> detailFields{get; set;}

  public static FAP_Location build(Partner_Location__c partnerLocation){
    FAP_Location location   = new FAP_Location();
    location.Id     = partnerLocation.Id; 
    location.name    = partnerLocation.Name;
    location.latitude  = partnerLocation.Latitude__c;
    location.longitude  = partnerLocation.Longitude__c;
    location.street    = partnerLocation.Street__c;
    location.city    = partnerLocation.City__c;
    location.state    = partnerLocation.State_Province__c;
    location.postalCode  = partnerLocation.Postal_Code__c;
    location.country  = partnerLocation.Country__c;
    location.pointOfContactName=partnerLocation.Point_of_Contact_Name__c;
    location.phone=partnerLocation.Point_of_Contact_Phone__c;
    return location;
  }  
  
  public String toJSON(){
    return 
      '{'
      + '"id":' + FAP_JSONUtils.encode(this.id) 
      + ',"name":' + FAP_JSONUtils.encode(this.name) 
      + ',"latitude":' + this.latitude 
      + ',"longitude":' + this.longitude 
      + ',"street":' + FAP_JSONUtils.encode(this.street) 
      + ',"city":' + FAP_JSONUtils.encode(this.city) 
      + ',"state":' + FAP_JSONUtils.encode(this.state) 
      + ',"postalCode":' + FAP_JSONUtils.encode(this.postalCode) 
      + ',"country":' + FAP_JSONUtils.encode(this.country) 
      + ',"serialNumber":' + this.serialNumber 
      + '}';
  }


}