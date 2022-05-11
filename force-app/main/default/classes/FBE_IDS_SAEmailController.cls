/**************
 *@ Class Name        : FBE_IDS_SAEmailController
 *@ Description       : This class is written to retrieve required email components for Resource Schedule Confirmation Email Template.
						Visualforce components that utilize this class : FBE_IDS_GetSANotes, FBE_IDS_GetWOSkills
						Test Code Coverage is achieved in Apex Class : FBE_IDS_SAEmailSendTest
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 08-20-2020
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script - Feature #7946971.
 ***************/
public with sharing class FBE_IDS_SAEmailController {							//public class FBE_IDS_SAEmailController checkmarks update
    public Id recordId {get; set;}
    
    public List<ContentNoteWrapper> getRelatedNotes(){
        List<ContentNoteWrapper> noteListWrapper = new List<ContentNoteWrapper>();
        
        if(recordId != null){
            Set<Id> contentIds = new Set<Id>();           
            
            for(ContentDocumentLink content : [SELECT ContentDocumentId
                                                     FROM ContentDocumentLink
                                                     WHERE LinkedEntityId =: recordId]){
                contentIds.add(content.ContentDocumentId);
            }
            
            if(contentIds != null){
                for(ContentNote eachNote : [SELECT Id, Content, Title, TextPreview
                                            FROM ContentNote
                                            WHERE Id IN :contentIds
                                            AND FileType = 'SNOTE'
                                            ORDER BY CreatedDate Desc])
                {
                    ContentNoteWrapper noteWrapper = new ContentNoteWrapper();
                    noteWrapper.strTitle = eachNote.Title;
                    noteWrapper.strNotes = eachNote.Content.toString().replaceAll( '<[^>]+>',' ' );
                    noteListWrapper.add(noteWrapper);
                    
                }
            }
        }
        return noteListWrapper;        
    }
    
    public class ContentNoteWrapper{
        @AuraEnabled
        public String strTitle{get;set;}
        @AuraEnabled
        public String strNotes{get;set;}
    }
    
    public List<SkillRequirement> getSkillRequirements(){
        List<SkillRequirement> skillList = new List<SkillRequirement>();
        if(recordId != null){
            skillList = [SELECT Id, Skill.MasterLabel, SkillLevel
                        FROM SkillRequirement
                        WHERE RelatedRecordId =: recordId];
        }
        
        return skillList;
    }
}