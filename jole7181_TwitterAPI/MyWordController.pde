/*
this Object handles drawing MyWords:
 -in a MyWord Cloud
 */
import java.util.*;
import java.io.*;


class MyWordController {

  /*
global Attributes - Aproach 01
   */
  IntDict MyWordcountdict;
  Status status;
  String []MyWords;
  /*
global Attributes - TF* IDF
   */
  int tfidfsamplesize = 2; // totaltweets/samplesize --> get first amount of tweets to compare with tfidf
  int numTweets;

  String [] txt;
  ArrayList<MyWord> counts;
  String [] allMyWords; //contains all the MyWords
  MyWord current;

  //filtering:
  String[] nums = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}; // to remove digits from the tweets
  String[][]allMyWordsfiltered;
  String[] erase; //stopWords.txt
  IntDict totalDict; //allWordsfiltered land here

  //finished list:
  ArrayList<MyWord> MyWordlist;

  //drawing:
  WordDraw wDraw = new WordDraw(); //for drawing arrays - used in 

  MyWordController()
  {
  }

  void tweetSetup()
  {
    numTweets = twC.getTweetAmount(); //== amountoftweets

    //filtering setup:
    allMyWordsfiltered = new String[numTweets][0];
    erase = loadStrings("stopwords.txt");
    totalDict = new IntDict(); //this saves all filtered MyWords - 


    preload();
  }
  void preload()
  {
    //load text: allMyWords

    String tweettxt = "";
    for (int i=0; i<twC.getTweets().size(); i++) 
    {  
      status = (Status)twC.getTweets().get(i); 
      tweettxt += status.getText();
    }//for end

    allMyWords = splitTokens(tweettxt.toLowerCase(), "\n  .?!"); 

    //filter MyWords
    //filter digits:
    for (int i = 0; i <nums.length; i ++) 
    {
      for (int j = 0; j <allMyWords.length; j ++) 
      {
        allMyWords[j] = allMyWords[j].replaceAll(nums[i], "");
      }
    }

    MyWordlist = new ArrayList<MyWord>();

    //count MyWords:if mywordlist contains word- increment count, else add to list
    for (int i=0; i<allMyWords.length; i++)
    {
      current = new MyWord(allMyWords[i]);
      //String currentMyWord = allMyWords[i];

      if (containsMyWord(MyWordlist, current.word))
      {
        current = getMyWord(MyWordlist, current.word);
        current.incrementtotalcount();
        if (i<allMyWords.length/tfidfsamplesize)
        {
          current.incrementsamplecount();
        }
      } else
      {
        if (i<allMyWords.length/tfidfsamplesize)
        {
          current.incrementsamplecount();
        }

        MyWordlist.add(current);//add MyWord to list totalcount is 1 for new MyWords
      }//ifelse end
    }//for end

    //REMOVE JUNK MyWordS WITH ERASE AND STOPMyWord.TXT
    MyWordlist = removeJunkMyWords(MyWordlist);




    //increment number of tweets containing MyWord
    boolean tweetcontains;
    for (int i = 0; i< numTweets; i++)
    {
      tweetcontains = false;
      Status currentTweet = (Status)twC.getTweets().get(i);
      String currenttext = currentTweet.getText();
      String[] currentMyWords = splitTokens(currenttext.toLowerCase(), "\n  .?!"); 

      for (int j = 0; j<currentMyWords.length; j++)
      {
        current = new MyWord(currentMyWords[j]);
        if (!tweetcontains && containsMyWord(MyWordlist, current.word))
        {
          //print("++");
          tweetcontains = true;
          current = MyWordlist.get(j);
          current.incrementnmbroftweetscontainingMyWord();
        }
      }
    }

    //counts total/sample count of all MyWords together for TF-
    int sampleall = 0;
    int countall = 0;
    for (int i = 0; i<MyWordlist.size(); i++)
    {
      MyWord w = MyWordlist.get(i);
      sampleall += w.samplecount;
      countall += w.totalcount;
    }

    //SET TFIDF FOR EACH MyWord:
    //print("SETTING IDF FOR EACH MyWord...");
    for (int i = 0; i<MyWordlist.size(); i++)
    {
      current = MyWordlist.get(i);
      current.setTF(countall);
      current.setIDF(current.totalcount, current.getnmbroftweetscontainingMyWord());
      current.setTFIDF(); //MyWordsintweets(samplesize), int amountoftweets, int nmbroftweetscontainingMyWord set?
    }



    /*
    //THIS PRINTS MyWordLIST:
     for (int i = 0; i<MyWordlist.size(); i++)
     {
     MyWord w = MyWordlist.get(i);
     //print(w.MyWord +":" +w.samplecount +"  -  ");
     //print("MyWord: "+w.MyWord);
     //print(w.getnmbroftweetscontainingMyWord());//###########
     print(" "+w.word+" : "+w.getTFIDF()+ " ");
     }
     //print("tfidf sample:"+sampleall + "-count:"+countall);
     //print("rev"+log(2 / 1));
     */

  
  }

  
  boolean containsMyWord(ArrayList<MyWord> MyWordlist, String MyWord) 
  {
    for (MyWord w : MyWordlist) 
    {
      if (w != null && w.word.equals(MyWord)) 
      {
        return true;
      }
    }
    return false;
  }

  MyWord getMyWord(ArrayList<MyWord> MyWordlist, String word)
  {
    for (MyWord w : MyWordlist)
    {
      if (w != null && w.word.equals(word))
      {
        return w;
      }
    }
    return null;
  }

  ArrayList<MyWord> removeJunkMyWords(ArrayList<MyWord> MyWordlist)
  {
    //removes MyWords with stopMyWords.txt
    for (int i = 0; i< erase.length; i++)
    {
      for (int j =0; j<MyWordlist.size(); j++)
      {
        MyWord current = MyWordlist.get(j);
        if (current!= null && current.word.equals(erase[i]))
        {
          MyWordlist.remove(j);
        }
      }
    }
    return MyWordlist;
  }

  void sortAllForDraw()
  {
    wDraw.sortForCloud(MyWordlist);
    wDraw.sortForCount(MyWordlist);
    wDraw.sortForLanguageC(MyWordlist);
  }
  void drawMyWordList(int showAmount)
  {
    //print("drawMyWordlist");
    //if state == wordcloud:
    wDraw.drawCloud(showAmount, twC.getTweets());
  }

  void drawTweetCount(int showAmount, String query)
  {
    //print("drawTweetCount");
    wDraw.drawTweetCount(showAmount, query);
  }

  void drawLanguageC(int showAmount)
  {
    //print("drawLanguageC");
    wDraw.drawLanguageC(showAmount);
  }
}
