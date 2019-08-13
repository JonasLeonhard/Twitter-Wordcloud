/*
This Class Handles Twitter Request, Setup..

Use: 
create obj TwitterController --> tc.seach(w, 100); --> tc.getTweets();
 */

class TwitterController {

  ConfigurationBuilder cb; 
  Twitter twitter; 
  Query query; //used in search
  List tweets; //set in search
  String defaultlang = "lang:de "; //for eng "lang:en"
  String searchWord = "";
  TwitterController()
  {
    connectToTwitter();

    //default to:
    query = new Query(defaultlang);
  }
  void connectToTwitter()
  {
    //config for twitterobj
    cb = new ConfigurationBuilder();

    /*
    set unique credentials from http://developer.twitter.com: 
    
    
    
    
    
    
    !!!DONT SHARE - get your own keys on dev.twitter.com !!!
    ˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇ
     */
    cb.setOAuthConsumerKey("***********");
    cb.setOAuthConsumerSecret("************");
    cb.setOAuthAccessToken("******************************");
    cb.setOAuthAccessTokenSecret("******************************");
    /*
    ^^^^^^^^^^^^^^^^
    !!!DONT SHARE!!!
    
    
    
    
    
    
    */
    //main 'twitter' obj for Twitter Website interaction:
    twitter = new TwitterFactory(cb.build()).getInstance();
    println("TwitterController Exception: Auth is not set at TwitterController line 39, line 40, line 41, line 42");
  }
  void search(String word, int queryCount)
  {
    println("Search for " + word + " ; queryCount: " + queryCount + " ...");
    setQuery(defaultlang + word);
    searchWord = word; // this is called in WordDraw.DrawCount() for displaying the searchword
    try 
    {
      query.setCount(queryCount); 
      QueryResult result = twitter.search(query); //<-- search word
      tweets = result.getTweets(); //<-- save result in List
      print("query result saved in TwitterController.tweets --> getTweets()"+tweets.size());
    }
    catch (TwitterException te) 
    {
      println("Couldn't connect to TwitterAPI: " + te);
    };
    
  }

  List getTweets()
  {
    if (tweets==null)
    {
      print("getTweets Exception- TwitterController.search.result.getTweets()==null !");
      return null;
    } else 
    {
      return tweets;
    }
  }

  void setQuery(String search)
  {
    query = new Query(search);
  }
  
  int getTweetAmount()
  {
    return tweets.size();
  }
  
  void setLanguage(String languageString)
  {
    defaultlang = languageString;
  }
  
}//end of class
