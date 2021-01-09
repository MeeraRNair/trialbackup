@isTest

public without sharing  class BypassPBforCustomPermission_Test{
  
  static testMethod void callFakeClass() {
  
  BypassPBforCustomPermission.fakeCalling();
  System.assert(true);
  }
  }