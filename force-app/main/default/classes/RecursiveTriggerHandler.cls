/*
      Author    : Pawan K
      Company   : OAC Services, INC.
      Created   : 1/4/19
*/
global class RecursiveTriggerHandler
{
    public static boolean hasRun = false;
   
    public static boolean isFirstTime()
    {
        if(hasRun)
        {
            return false;
        }
        else
        {
            hasRun = true;
            return true;
        }
    }
}