/*
Created Date: 09 September 2019

For STORY 7229574- Performance Improvement : Custom permission user check created for Process Builder
*/


public without sharing class BypassPBforCustomPermission{
  
  @InvocableMethod   
  public static void fakeCalling() {
    //System.debug('PB bypassed for Custom Permission');
      }
}