public with sharing class UserBadgeService {

    public static void calculateTrailmixProgress(List<trailheadapp__User_Badge__c> userBadgeList, Map<Id,trailheadapp__User_Badge__c> userBadgeOldMap){
       //Loop User Badges and group the completed badge Ids by User
        Set<Id> badgeIds = new Set<Id>();
        Map<Id, Set<Id>> badgeIdsByUser = new Map<Id, Set<Id>>();
        Map<Id,trailheadapp__User_Badge__c> userBadgeByBadge = new Map<Id,trailheadapp__User_Badge__c>();
        for(trailheadapp__User_Badge__c userBadge : userBadgeList) {
        badgeIds.add(userBadge.trailheadapp__Badge__c);
            userBadgeByBadge.put(userBadge.trailheadapp__Badge__c,userBadge);
            if(badgeIdsByUser.containsKey(userBadge.trailheadapp__User__c)){
                badgeIdsByUser.get(userBadge.trailheadapp__User__c).add(userBadge.trailheadapp__Badge__c);
            }else{
                badgeIdsByUser.put(userBadge.trailheadapp__User__c, new Set<Id>{ userBadge.trailheadapp__Badge__c });
            }
        }

        //Query Trailmix Badge and group the related trailmix by Badge
        Map<Id, Set<Id>> trailmixIdByBadgeId = new Map<Id, Set<Id>>();
       /* for(Trailmix_Badge__c trailmixBadge : [SELECT Id, Trailmix__c, Badge__c FROM Trailmix_Badge__c WHERE Badge__c IN :badgeIds]) {
            if(trailmixIdByBadgeId.containsKey(trailmixBadge.Badge__c)){
                trailmixIdByBadgeId.get(trailmixBadge.Badge__c).add(trailmixBadge.Trailmix__c);
            }else{
                trailmixIdByBadgeId.put(trailmixBadge.Badge__c, new Set<Id>{ trailmixBadge.Trailmix__c });
            }
        }
																*/

        Set<String> userTrailmixKeys = new Set<String>();
        for(Id userId : badgeIdsByUser.keySet()){
            for(Id badgeId : badgeIdsByUser.get(userId)){
                if(trailmixIdByBadgeId.containsKey(badgeId)){
					for(Id trailmixId : trailmixIdByBadgeId.get(badgeId)){
                		userTrailmixKeys.add(String.valueOf(userId) + String.valueOf(trailmixId));
               	 	} 
                }
                
            }
        }
	    // OTRO COMENTARIO
	    for(){
	    [SELECT]
	    };
	    
	    for(){
	    [ SELECT]
	    };
	    
	    for(){
	    [select]
	    };
	    
	    for(){
	    [ select]
	    }
	    
	    for(){
	    [ select]
	    }
	    
	    for(){
	    [SELECT]
	    };
	    
	    for(){
	    [ SELECT]
	    };
	    
	    for(){
	    [select]
	    };
	    
	    for(){
	    [ select]
	    }
	    
	    for(){
	    [ select]
	    }
	/* COMENTARIO
	
	
	
	
	
	
	
	
	
	
	
	asd
	dsa
	
	asd
	
	
	*/
        //Query user trailmix to update counters and put them in a map by key
        Map<String, trailheadapp__User_Trailmix__c> userTrailmixByKey = new Map<String, trailheadapp__User_Trailmix__c>();

        for(trailheadapp__User_Trailmix__c userTrailmix : [SELECT Id,trailheadapp__Trailmix__r.Total_Badge__c,Total_Badges_Trailmix__c,trailheadapp__Trailmix__r.Company_Trailmix__c,Company_Trailmix__c,Total_Badges_Completed__c, trailheadapp__User__c, trailheadapp__Trailmix__c, Key__c FROM trailheadapp__User_Trailmix__c WHERE Key__c IN :userTrailmixKeys]){
            userTrailmixByKey.put(userTrailmix.Key__c, userTrailmix);
        }

        //Finally update the counter values
        for(Id userId : badgeIdsByUser.keySet()){
            for(Id badgeId : badgeIdsByUser.get(userId)){
                if(trailmixIdByBadgeId.containsKey(badgeId)){
                    for(Id trailmixId : trailmixIdByBadgeId.get(badgeId)){ 
                        if(userTrailmixByKey.containsKey(String.valueOf(userId) + String.valueOf(trailmixId))){
                            trailheadapp__User_Trailmix__c currentUserTrailmix = userTrailmixByKey.get(String.valueOf(userId) + String.valueOf(trailmixId));

                            if(userBadgeOldMap.containsKey(userBadgeByBadge.get(badgeId).Id) && userBadgeOldMap.get(userBadgeByBadge.get(badgeId).Id).trailheadapp__Status__c == 'Completed' && userBadgeByBadge.get(badgeId).trailheadapp__Status__c != 'Completed')
                                currentUserTrailmix.Total_Badges_Completed__c -= 1;
                            
                            else{
                                if(userBadgeByBadge.get(badgeId).trailheadapp__Status__c== 'Completed')
                                    currentUserTrailmix.Total_Badges_Completed__c += 1;
                            }
                            
                        }          
                    }  
                }
            }
        }
        //Update the database
        update userTrailmixByKey.values();
    }

    public static void forceScheduleBootcampActivities(){
        // Fills a map with Bootcamp ID as KEY and List of related BootcampActivity as VALUE
        List<Bootcamp_Edition_Activity__c> bootcampActivities = [SELECT Date__c,Bootcamp__c,Badge__c FROM Bootcamp_Edition_Activity__c WHERE Date__c =:Date.today() AND Bootcamp__c != null];

        Map<Id, List<Bootcamp_Edition_Activity__c>> bootcampActivitiesByBootcamp = new Map<Id, List<Bootcamp_Edition_Activity__c>>();

        Set<Id> badgesList = new Set<Id>();
        for(Bootcamp_Edition_Activity__c bootcampActivity : bootcampActivities){
            if(!bootcampActivitiesByBootcamp.containsKey(bootcampActivity.Bootcamp__c)){  
                bootcampActivitiesByBootcamp.put(bootcampActivity.Bootcamp__c,new List<Bootcamp_Edition_Activity__c>{bootcampActivity});      
            }
            else{
                bootcampActivitiesByBootcamp.get(bootcampActivity.Bootcamp__c).add(bootcampActivity);
            }
            badgesList.add(bootcampActivity.Badge__c);
        }
        
        // Get bootcamps with related users
        Map<Id,Bootcamp__c> bootcamps = new Map<Id,Bootcamp__c>([SELECT id,(SELECT Student__c FROM User_Bootcamp_Editions__r) FROM Bootcamp__c WHERE Id IN :bootcampActivitiesByBootcamp.keySet()]);

        Set<Id> usersID = new Set<Id>();
        for(Bootcamp__c bootcamp : bootcamps.values()){
            for(User_Bootcamp_Edition__c userBootcampEdition : bootcamp.User_Bootcamp_Editions__r){
                usersID.add(userBootcampEdition.Student__c);
            }
        }
        List<trailheadapp__User_Badge__c> userBadges = [SELECT Id,trailheadapp__User__c, trailheadapp__Badge__c,trailheadapp__Status__c,trailheadapp__External_ID__c FROM trailheadapp__User_Badge__c WHERE trailheadapp__User__c IN : usersID AND trailheadapp__Badge__c IN : badgesList];
        Set<String> externalIDS = new Set<String>();
        List<trailheadapp__User_Badge__c> userBadgesToInsert = new List<trailheadapp__User_Badge__c>();
        
        for(trailheadapp__User_Badge__c userBadge : userBadges){
            externalIDS.add(userBadge.trailheadapp__External_ID__c); 
        }
        
        // Loop through users per bootcamp to create userBadge's record if it doesn't exist
        for(Id bootcampId : bootcampActivitiesByBootcamp.keySet()){
           for(User_Bootcamp_Edition__c userBootcampEdition : bootcamps.get(bootcampId).User_Bootcamp_Editions__r){
            for(Bootcamp_Edition_Activity__c bootcampActivity : bootcampActivitiesByBootcamp.get(bootcampId)){
                if(!externalIDS.contains(userBootcampEdition.Student__c +'-'+bootcampActivity.Badge__c)){
                    trailheadapp__User_Badge__c userBadge = new trailheadapp__User_Badge__c(
                        trailheadapp__User__c = userBootcampEdition.Student__c,
                        trailheadapp__Badge__c = bootcampActivity.Badge__c,
                        trailheadapp__Status__c = 'Assigned'
                    );
                    userBadgesToInsert.add(userBadge);
                    externalIDS.add(userBadge.trailheadapp__User__c+'-'+userBadge.trailheadapp__Badge__c);
                }
            }
           }   
        }
        insert userBadgesToInsert;
    }
}
