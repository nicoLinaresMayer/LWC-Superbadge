public with sharing class BootcampService {
    public static List<BootcampDataWrapper> getBootcampData(Id bcId){
        Bootcamp__c bootcamp = [SELECT Id, Bootcamp_Structure__c FROM Bootcamp__c WHERE Id = :bcId];

        List<User> userList = [SELECT Id, Name, (SELECT Id, trailheadapp__Trailmix__c, Total_Badges_Completed__c, Progress__c, Is_Mandatory__c, trailheadapp__Status__c FROM trailheadapp__User_Trailmixes__r ORDER BY Is_Mandatory__c DESC, Name ASC) FROM User WHERE Id IN (SELECT Student__c FROM User_Bootcamp_Edition__c WHERE Bootcamp__c = :bcId)];     

        List<trailheadapp__Trailmix__c> trailmixesBC = [SELECT Id, Name FROM trailheadapp__Trailmix__c WHERE Id IN (SELECT Trailmix__c FROM Trailmix_Bootcamp_Structure__c WHERE Bootcamp_Structure__c = :bootcamp.Bootcamp_Structure__c) ORDER BY Is_Mandatory__c DESC , Name];

       List<BootcampDataWrapper> studentsProgressWrapper = new List<BootcampDataWrapper>();

        for (User user : userList) {
            
            Map<Id, trailheadapp__User_Trailmix__c> userTrailmixByTrailmixId = new Map<Id, trailheadapp__User_Trailmix__c>();

            Integer userTrailmixesMandatoriesQty = 0;
            Integer userTrailmixesMandatoriesCompleted = 0;
            for (trailheadapp__User_Trailmix__c userTrailmix : user.trailheadapp__User_Trailmixes__r) {
                if (userTrailmix.Is_Mandatory__c) {
                    if(userTrailmix.trailheadapp__Status__c == 'Completed'){
                        userTrailmixesMandatoriesCompleted++;
                    }  
                    userTrailmixesMandatoriesQty++;
                } 
                userTrailmixByTrailmixId.put(userTrailmix.trailheadapp__Trailmix__c,userTrailmix);
            }
            
            List<userTrailmixWrapper> userTrailmixWrapperList = new List<userTrailmixWrapper>();

            for (trailheadapp__Trailmix__c trailmix : trailmixesBC) {
                userTrailmixWrapperList.add(new userTrailmixWrapper(
                        userTrailmixByTrailmixId.get(trailmix.Id)?.Id,
                        trailmix.Name,
                        userTrailmixByTrailmixId.get(trailmix.Id)?.Total_Badges_Completed__c,
                        userTrailmixByTrailmixId.get(trailmix.Id)?.Progress__c));
            }   
            studentsProgressWrapper.add(new BootcampDataWrapper(
                user.Name,
                user.Id,
                userTrailmixesMandatoriesQty,
                userTrailmixesMandatoriesCompleted,
                userTrailmixWrapperList
            ));
        }      
        studentsProgressWrapper.sort();
        return studentsProgressWrapper;
    }


    public static  List<trailheadapp__Badge__c> getCompanyBadges(Id bootcampId){

        Bootcamp__c bootcamp = [SELECT Id, Bootcamp_Structure__c FROM Bootcamp__c WHERE Id =:bootcampId];
 
        Set<Id> trailmixesIds = new Set<Id>();
        for (Trailmix_Bootcamp_Structure__c bs : [SELECT Id, Trailmix__c FROM Trailmix_Bootcamp_Structure__c WHERE Bootcamp_Structure__c = :bootcamp.Bootcamp_Structure__c AND Trailmix__r.Company_Trailmix__c = true]) {
            trailmixesIds.add(bs.Trailmix__c);
        }
 
        Set<Id> badgesIds = new Set<Id>();
        for (Trailmix_Badge__c trailmixBadge : [SELECT Id, Badge__c FROM Trailmix_Badge__c WHERE Trailmix__c IN :trailmixesIds]) {
            badgesIds.add(trailmixBadge.Badge__c);
        }
 
       return [SELECT id, Name FROM trailheadapp__Badge__c WHERE id IN :badgesIds];
    }


    public static List<String> getStudentsAssigned (Id userId){
        List<String> usersName = new List<String>();
        for(User_Bootcamp_Edition__c userBootcampEdition :[SELECT Student__r.Name, Name FROM User_Bootcamp_Edition__c WHERE Assistant__c =: userId]){
            usersName.add(userBootcampEdition.Student__r.Name);
        }
        return usersName;   
    }


    public static List<BadgesCompletedByStudentsWrapper> getBadgesCompletedByStudents(Id bootcampId, Boolean isSuperBadge){

        List<BadgesCompletedByStudentsWrapper> studentProgressList = new List<BadgesCompletedByStudentsWrapper>();

        Set<Id> usersIds = new Set<Id>();
        for (User_Bootcamp_Edition__c userBootcampEdition : [SELECT Id, Student__c, Name FROM User_Bootcamp_Edition__c WHERE  Bootcamp__c =:bootcampId]) {
            usersIds.add(userBootcampEdition.Student__c);
        }

        List<trailheadapp__Badge__c> companyBadgeList = getCompanyBadges(bootcampId);
        
        Map<Id, List<trailheadapp__User_Badge__c>> userBadgeListByUserId = new Map<Id, List<trailheadapp__User_Badge__c>>();

        for (trailheadapp__User_Badge__c userBadge : [SELECT Id, Name, trailheadapp__User__r.Name, trailheadapp__User__c FROM trailheadapp__User_Badge__c WHERE trailheadapp__User__c IN :usersIds AND trailheadapp__Badge__c IN :companyBadgeList AND trailheadapp__Status__c = 'Completed' AND trailheadapp__Badge__r.trailheadapp__Type__c = :isSuperBadge? 'Superbadge' : 'Module']) {
            if (userBadgeListByUserId.containsKey(userBadge.trailheadapp__User__c)){
                userBadgeListByUserId.get(userBadge.trailheadapp__User__c).add(userBadge);
            } else{
                userBadgeListByUserId.put(userBadge.trailheadapp__User__c, new List<trailheadapp__User_Badge__c>{userBadge});
            }
        }

        for (Id userId : userBadgeListByUserId.keySet()) {
            studentProgressList.add(new BadgesCompletedByStudentsWrapper (userBadgeListByUserId.get(userId)[0].trailheadapp__User__r.Name, userBadgeListByUserId.get(userId).size()));
        }
    
        studentProgressList.sort();
        return studentProgressList; 
    }


    @InvocableMethod(Label='createBootcampActivities')
    public static List<List<Id>> createBootcampActivitiesApexAction(List<List<Id>> bootcampListList){

        BootcampService.createBootcampActivities(bootcampListList[0]);
        List<List<Id>> listToReturn = new List<List<Id>>();
        for(Integer i = 0 ;i<bootcampListList.size(); i++){
            listToReturn.add(new List<Id>());
        }
        return listToReturn;
    }


    public static void createBootcampActivities(List<Id> bootcampsToRecalculate){
        // To insert the new activities related with a Bootcamp we delete the old ones
        delete [SELECT ID FROM Bootcamp_Edition_Activity__c WHERE Bootcamp__c IN :bootcampsToRecalculate AND Badge__c != null];

        List<Bootcamp__c> bootcampsWithDaysOff = [SELECT Id,Start_Date__c,End_Date__c,Bootcamp_Structure__c,(SELECT Id,Date__c FROM Days_Off__r) FROM Bootcamp__c WHERE Status__c != 'Completed' AND Id IN :bootcampsToRecalculate];
        
        // this map has the structure of the bootcamp with the structure of related activities
        Map<Id,Bootcamp_Structure__c> bootcampStructureById = new Map<Id,Bootcamp_Structure__c>([SELECT ID,(SELECT Id,Number_Day__c,Duration__c,Badge__c FROM Bootcamp_Structure_Activities__r) FROM Bootcamp_Structure__c WHERE Id IN (SELECT Bootcamp_Structure__c FROM Bootcamp__c WHERE Id IN :bootcampsToRecalculate)]);
        
        // Days off which applies to all active bootcamps 
        List<Date> generalDaysOff  = new List<Date>();
        for(Day_Off__c dayOff : [SELECT Id,Date__c FROM Day_Off__c WHERE Bootcamp_Edition__c = null]){
            generalDaysOff.add(dayOff.Date__c);
        }

        // create the list of Edition Activities to Insert
        List<Bootcamp_Edition_Activity__c> activitiesToInsert = new List<Bootcamp_Edition_Activity__c>();
        
        for(Bootcamp__c bootcamp : bootcampsWithDaysOff){
            List<Date> notAvailableDates = new List<Date>();
           
            //Add days off of current bootcamp to notAvailableDates
            for(Day_Off__c dayOff : bootcamp.Days_Off__r){
                notAvailableDates.add(dayOff.Date__c);
            }
            //Add general days off to notAvailableDates
            notAvailableDates.addAll(generalDaysOff);


            // This Map contain the Number Day and the Date for each Activities in the Bootcamp (Without Saturday, Sunday & DayOffs
            Map<Decimal, Date> dateByNumberDayOfBootcamp = new Map<Decimal, Date>();
            Integer numberDay = 1;
            for (Date bootcampDay = bootcamp.Start_Date__c ; bootcampDay <=  bootcamp.End_Date__c; bootcampDay = bootcampDay.addDays(1)) {

                DateTime bcDay = (DateTime)bootcampDay;
                String dayOfWeek = bcDay.addDays(1).format('E');
                if(dayOfWeek == 'Sun' || dayOfWeek == 'Sat' || notAvailableDates.contains(bootcampDay)){
                    continue;
                }
                dateByNumberDayOfBootcamp.put(numberDay, bootcampDay);
                numberDay++;                
            }

            // Loop through the Activities of the Structure
            for(Bootcamp_Structure_Activity__c activiy : bootcampStructureById.get(bootcamp.Bootcamp_Structure__c).Bootcamp_Structure_Activities__r){

                // Verify if the Duration of the Activity is Greater than 1 and create the amount of Edition Activities is necessary
                if(activiy.Duration__c > 1){
                    for(Integer i = 0 ; i < activiy.Duration__c ; i++){
                        activitiesToInsert.add(new Bootcamp_Edition_Activity__c(
                            Badge__c = activiy.Badge__c, 
                            Bootcamp__c = bootcamp.Id, 
                            Date__c = dateByNumberDayOfBootcamp.get(activiy.Number_Day__c+i)));
                    }  
                }
                else{
                    activitiesToInsert.add(new Bootcamp_Edition_Activity__c(
                        Badge__c = activiy.Badge__c, 
                        Bootcamp__c = bootcamp.Id, 
                        Date__c = dateByNumberDayOfBootcamp.get(activiy.Number_Day__c)));
                }
            }    
        }
        insert activitiesToInsert;
    }

    public class BootcampDataWrapper implements Comparable{
        @AuraEnabled
        public String userName {get;set;}
        @AuraEnabled
        public Id userId {get;set;}
        @AuraEnabled
        public Integer userTrailmixMandatoriesQty {get;set;}
        @AuraEnabled
        public Integer userTrailmixMandatoriesCompletedQty {get;set;}
        @AuraEnabled
        public Decimal mandatoriesProgress {get;set;}
        @AuraEnabled
        public List<userTrailmixWrapper> userTrailmixWrapperList {get;set;}

        public BootcampDataWrapper (String userName, Id userId, Integer userTrailmixMandatoriesQty, Integer userTrailmixMandatoriesCompletedQty,  List<userTrailmixWrapper> userTrailmixWrapperList){
            this.userName = userName;
            this.userId = userId;
            this.userTrailmixMandatoriesQty = userTrailmixMandatoriesQty;
            this.userTrailmixMandatoriesCompletedQty = userTrailmixMandatoriesCompletedQty;
            this.userTrailmixWrapperList = userTrailmixWrapperList;
            this.mandatoriesProgress = Math.round((Decimal)userTrailmixMandatoriesCompletedQty/userTrailmixMandatoriesQty*100);
        }

        public Integer compareTo(Object compareTo) {
            BootcampDataWrapper compareToEmp = (BootcampDataWrapper)compareTo;

            if (mandatoriesProgress == compareToEmp.mandatoriesProgress) return 0;
            if (mandatoriesProgress > compareToEmp.mandatoriesProgress) return 1;
            return -1; 
        }
    }

    public class userTrailmixWrapper{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Decimal totalBadgeCompleted {get;set;}
        @AuraEnabled
        public Decimal progress {get;set;}
        
        public userTrailmixWrapper (Id Id, String Name, Decimal totalBadgeCompleted, Decimal progress){
            this.Id = Id;
            this.Name = Name;
            this.totalBadgeCompleted = totalBadgeCompleted == null ? 0 : totalBadgeCompleted;
            this.progress = progress == null? 0 : progress;
        }
    }
 
    public class BadgesCompletedByStudentsWrapper implements Comparable{
        
        @AuraEnabled
        public String Name {get;set;}
        
        @AuraEnabled
        public Integer badgesCompleted{get;set;}

        public badgesCompletedByStudentsWrapper(String Name, Integer badgesCompleted){
            this.Name = Name;
            this.badgesCompleted = badgesCompleted;
        }

        public Integer compareTo(Object compareTo) {
            BadgesCompletedByStudentsWrapper compareToEmp = (BadgesCompletedByStudentsWrapper)compareTo;

            if (badgesCompleted == compareToEmp.badgesCompleted) return 0;
            if (badgesCompleted > compareToEmp.badgesCompleted) return 1;
            return -1; 
        }
    }
}