trigger CreateProjectTrigger on Create_Project__e (after insert)
{
    new CreateProjectTriggerHandler().run();
}