
class CompareCount implements Comparator<MyWord>
{
  boolean isDescent = true;
  @Override
    public int compare(MyWord v1, MyWord v2)
  {

   if (v2.gettotalcount() > v1.gettotalcount())
   {
        return 1;
   }
   else if(v2.gettotalcount() < v1.gettotalcount())
   {
     return -1;
   }
   else
   {
         return 0;
   }
  }   
}
