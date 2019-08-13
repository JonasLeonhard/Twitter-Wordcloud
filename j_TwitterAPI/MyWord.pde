class MyWord
{
  //sorting:
  float tf;
  float idf;
  float tfidf;
  String word;
  int totalcount; //incremented in MyWordcontroller
  int samplecount; //amount of times the MyWord apears in a given sample size i.e ~~irst 20 tweets
  int nmbroftweetscontainingMyWord; //incremented in MyWordcontroller
  
  //showing newest tweet with word in it
  int tweetNr;
  boolean hasNr = false;
  
  //drawing:
  float posX, posY, dia;
  
  float rX, rY; //random pos for drawCloud
  MyWord(String w)
  {
    word = w;
    totalcount = 1;
    samplecount = 0;
    nmbroftweetscontainingMyWord = 1;
    dia = textWidth(word);
    
    rX =getRandomX();
    rY =getRandomY();
  }


  MyWord get()
  {
    return this;
  }
  void setTF(int myWordsintweets)
  {
    tf = myWordsintweets / totalcount;
  }

  void setIDF(int amountoftweets, int nmbroftweetscontainingMyWord)
  {
    idf = log(amountoftweets / nmbroftweetscontainingMyWord);
  }

  void setTFIDF()
  {
    tfidf = tf * idf;
  }
  float getTFIDF()
  {
    return tfidf;
  }
  int gettotalcount()
  {
    return totalcount;
  }

  void incrementtotalcount()
  {
    totalcount++;
  }

  void setsamplecount(int count)
  {
    samplecount = count;
  }

  int getsamplecount()
  {
    return samplecount;
  }

  void incrementsamplecount()
  {
    samplecount++;
  }

  void incrementnmbroftweetscontainingMyWord()
  {
    nmbroftweetscontainingMyWord++;
  }
  int getnmbroftweetscontainingMyWord()
  {
    return nmbroftweetscontainingMyWord;
  }
  String getMyWord()
  {
    return word;
  }

  void drawAt(float x, float y)
  {
    posX = x;
    posY = Y;
    //textAlign(CENTER);
    //text(word + " "+tfidf, x, y);
    text(word, x, y);
  }
  
  float getRandomX()
  {
    return random(60, width -60);
  }
  float getRandomY()
  {
    return random(100, height -80);
  }
  
  void setTweetNr(int i)
  {
      tweetNr = i;
  }  
}
