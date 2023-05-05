public with sharing class BootcampController {
    @AuraEnabled(cacheable = true)
    public static List<BootcampService.BootcampDataWrapper> getBootcampData(Id bcId){
        return BootcampService.getBootcampData(bcId);
    }
    
    @AuraEnabled(cacheable = true)
    public static  List<trailheadapp__Badge__c> getCompanyBadges(Id bootcampId){
       return BootcampService.getCompanyBadges(bootcampId);
    }

    @AuraEnabled(cacheable = true)
    public static  List<BootcampService.BadgesCompletedByStudentsWrapper> getBadgesCompletedByStudents(Id bootcampId, Boolean isSuperBadge){
       return BootcampService.getBadgesCompletedByStudents(bootcampId, isSuperBadge);
    }

    @AuraEnabled(cacheable = false)
    public static List<String> getStudentsOfCurrentUser (){
        return BootcampService.getStudentsAssigned(UserInfo.getUserId());
    } 

}