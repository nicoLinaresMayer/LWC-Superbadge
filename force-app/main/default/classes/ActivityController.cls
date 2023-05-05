public with sharing class ActivityController {
    @AuraEnabled(cacheable = true)
    public static  List<ActivityService.ActivityStepsResultsWrapper> getActivityStepsWResults(Id activityId){
       return ActivityService.getActivityStepsWResults(activityId);
    }

    @AuraEnabled
    public static void checkStepAndCreateStepExResult(map<String,Object> step ){ 
        ActivityService.checkStepAndCreateStepExResult(step);
    }

    @AuraEnabled(cacheable = true)
    public static String getOrgLoginUrl(Id activityId){
      return  ActivityService.getOrgLoginUrl(activityId);
    }


    @AuraEnabled
    public static List<ClassWrapper> getClassesAnalysis(Id activityId){
        String endpoint = ActivityService.getRepoEndpoint(activityId);
        return ActivityService.getClassesAnalysis(ActivityService.getFileContentGitHub(endpoint));
    }
   

}