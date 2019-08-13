// uses https://wordcram.org/ library

import java.util.Comparator; 

class WordDraw
{
  ArrayList<MyWord> wordsDrawn;

  //sorted lists:
  ArrayList<MyWord> sortedTFIDF;
  ArrayList<MyWord> sortedCount;
  ArrayList<MyWord> sortedLanguage;

  //hovered over word with mouse:
  MyWord mouseWord;
  Status currentstatus;

  //drawing tweet:
  //PROFILE PIC POSITION: (from middle of screen)
  int xoff = -500/2 +25 + 15; //-half window size +halfellipse rezized + offset
  int yoff = -380/2 +25 + 25;
  //PROFILE NAME POSITION:
  int xnameoff = 40;
  int ynameoff = -14;
  //TWEET TXT POSITION:
  int xtweetoff = 0;
  int ytweetoff = 25;
  //TWEET USERNAME POSITION:
  int xusernoff = 20;
  int yusernoff = 0;
  int xtimeoff = 195;

  boolean statusloaded = false;
  
  //draw coubt;
  int counttodraw;
  boolean counttodrawset = false;
    
  
  //clicked
  boolean hassearchedStatus = false;
  String lastSearchWord = "";
  
  static final int MOUSEUP = 0, MOUSEDOWN = 1; //states
  int state = MOUSEUP;
  
  WordDraw()
  {
    sortedTFIDF = new ArrayList<MyWord>();
    sortedCount = new ArrayList<MyWord>();
    sortedLanguage = new ArrayList<MyWord>();
  }

  void sortForCloud(ArrayList<MyWord> myWordlist)
  {
    //Sort by TF*IDF - DESCENDING
    print("sortForCloud");
    //Collections.sort(myWordlist);
    CompareTFIDF comparator= new CompareTFIDF();
    myWordlist.sort(comparator);
    sortedTFIDF = new ArrayList<MyWord>(myWordlist);

    /*
    for(MyWord w : sortedTFIDF)
     {
     print(w.word + " " + w.tfidf);
     }
     */
  }



  void sortForCount(ArrayList<MyWord> myWordlist)
  {
    print("sortForCount");
    CompareCount comparator = new CompareCount();
    myWordlist.sort(comparator);
    sortedCount = new ArrayList<MyWord>(myWordlist);

    /*
    //print counted list:
     for (MyWord w : sortedCount)
     {
     print(":"+w.gettotalcount());
     }
     */
  }

  void sortForLanguageC(ArrayList<MyWord> myWordlist)
  {
    print("sortForLanguageC");
    CompareLanguageC comparator = new CompareLanguageC();
    myWordlist.sort(comparator);
    sortedLanguage = new ArrayList<MyWord>(myWordlist);
  }
  void drawCloud(int showAmount, List status)
  {
    //print("WordDraw: drawing Cloud...");
    
    
    //DRAW WORDS WITH THEIR TFIDF COUNT IN DIFFERENT STAGES:
    float highestTFIDF = 0;
    //draw the first in the middle:
    //wordsDrawn = new ArrayList<MyWord>();

    if (showAmount < sortedTFIDF.size())
    {
      for (int i = 0; i< showAmount; i++)
      {
        MyWord current = sortedTFIDF.get(i);

        if (current.getTFIDF() > highestTFIDF)
        {
          highestTFIDF = current.getTFIDF();
        }

        if (current.getTFIDF() <100) //LOWEST TFIDFS:
        {
          fill(0, 100, 180);
          textSize(10);
        } else if (current.getTFIDF() < highestTFIDF) //MIDDLE TFIDFS
        {
          //fill(map(current.getTFIDF(), 0, 1000, 0, 255),0,0);
          fill(70, 170, 255);
          textSize(20);
        } else if (current.getTFIDF() == highestTFIDF) //HIGHEST TFIDFS
        {
          fill(255, 255, 255);
          textSize(45);
        }
        /*
        if (current.rX < width/2)
         {
         textAlign(LEFT);
         } else
         {
         textAlign(RIGHT);
         }
         */
        textAlign(CENTER);
        //wordsDrawn.add(current);

        //mouse interactivity!
        mouseCloudfill(current); //fill hovered over words purple
        current.drawAt(current.rX, current.rY);
      
      }
    } else
    {
      print("SHOWAMOUNT ERROR- TOO LARGE");
      fill(255,255,255);
      text("not enough tweets to show with SHOWAMOUNT = "+showAmount, width/2, height/2);
    }

    //draw TweetWindow of mouseover.word:
    mouseCloudtxt(mouseWord, sortedTFIDF);
  }

  private void mouseCloudfill(MyWord current)
  {
    /*MOUSE INTERACTIVITY*/
    if (mouseX > current.rX-35 && mouseX < current.rX +35 && mouseY > current.rY-8 && mouseY < current.rY+8)
    {
      //if mouse is over current Word, fill it pink:
      fill(150, 0, 90);
      mouseWord = current;//set mouseWord to draw on top later
      
      statusloaded = false; 
      
      
    }
  }

  private void mouseCloudtxt(MyWord current, ArrayList<MyWord> list)
  {
    //when clicking, draw tweet window with tweet of current word
    //if mouse is over current word, draw a text + search for the tweet containing the current word:
    if (current!= null && mouseX > current.rX-35 && mouseX < current.rX +35 && mouseY > current.rY-8 && mouseY < current.rY+8)
    {
      /*CLICKED INTERACTIVITY*/
      if(mousePressed == true)
      {
      
        //GET STATUS FOR TEXT DRAW:
        if(!statusloaded)
        {
        try
        {
          currentstatus = searchContaining(current.word, list); //<-- return null if error -sets statusloaded -sets lastSearchWord
        }
        catch(Exception e)
        {
          print(" searchContaning ERROR: "+e);
        }
        }
       
        if (statusloaded)
        {
          //shadow of window:
          strokeWeight(7);
          stroke(color(35, 35, 35));
          line(width/2+253, height/2-(380/2)+9, width/2+253, height/2+(380/2)+4);
          line(width/2-243, height/2+(380/2)+4, width/2+256, height/2+(380/2)+4);

          /*DRAW TWEET WINDOW:*/
          fill(255, 255, 255);//<-- background col
          strokeWeight(2);
          stroke(color(255, 255, 255));
          rectMode(CENTER);
          rect(width/2, height/2, 500, 380, 3); //<-- background window

          stroke(color(160, 170, 180)); //<-- line color
          line(width/2-252, height/2-(380/2), width/2+252, height/2-(380/2));//<-- line top
          line(width/2-252, height/2+(380/2), width/2+252, height/2+(380/2));//<-- line bot

          //DRAW PROFILE PICTURE:
          try
          {
            //setup
            imageMode(CENTER);
            ellipseMode(RADIUS);
            noStroke();
            PImage webImg = loadImage(currentstatus.getUser().get400x400ProfileImageURL(), "png");
            PGraphics maskImg;

            //create mask
            maskImg = createGraphics(400, 400);
            maskImg.beginDraw();
            maskImg.ellipse(width/4, height/4, 400, 400); //<-- mask ellipse
            maskImg.endDraw();
            webImg.mask(maskImg);

            //scale and draw
            webImg.resize(50, 50);
            image(webImg, width/2+xoff, height/2+yoff, 50, 50);
          }
          catch(Exception e)
          {
            //no img: draw placeholder
            fill(255, 0, 0);
            ellipse(width/2+xoff, height/2+yoff, 25, 25); 
            print("loadIMG ERROR"+e);
          }

          //DRAW PROFILE NAME:
          try
          {
            fill(0, 0, 0);
            textAlign(LEFT);
            textFont(myFontbold);
            textSize(12);
            text(currentstatus.getUser().getName(), width/2 +xoff + xnameoff, height/2 +yoff +ynameoff);
            //reset font:
            textFont(myFont);
            textSize(12);
          }
          catch(Exception e)
          {
            fill(255, 0, 0);
            textAlign(LEFT);
            textFont(myFontbold);
            textSize(12);
            text("Jimmy Lee", width/2+xoff+xnameoff, height/2 +yoff +ynameoff);

            print("Draw Profile ERROR: "+e);
            //reset font:
            textFont(myFont);
            textSize(12);
          }

          //DRAW @USERNAME & @TimePosted
          try
          {
            fill(color(160, 170, 180));
            textSize(13);
            textAlign(LEFT);
            //@Username
            text("@"+currentstatus.getUser().getScreenName(), width/2 +xoff + xnameoff + textWidth(currentstatus.getUser().getName())+xusernoff, height/2 +yoff +ynameoff +yusernoff);

            //@TimePosted
            textSize(9);
            text("•"+currentstatus.getUser().getCreatedAt(), width/2+xoff+xnameoff+textWidth(currentstatus.getUser().getName())+xusernoff +xtimeoff, height/2 +yoff+ynameoff+yusernoff);
          }
          catch(Exception e)
          {
            fill(color(160, 170, 180));
            textSize(13);
            textAlign(LEFT);
            //@Username ERR
            text("@Jimmy_Lee_theman", width/2 +xoff + xnameoff + 80 +xusernoff, height/2 +yoff +ynameoff +yusernoff);

            //@TimePosted ERR
            textSize(9);
            text("•"+"Tue Jan 30 10:17:11 CET 2018", width/2+xoff+xnameoff+ 60 +xusernoff +xtimeoff, height/2 +yoff+ynameoff+yusernoff);

            print("Draw @Username exception ERROR: "+e);
          }

          //DRAW TWEET TXT: 
          try
          {
            fill(0, 0, 0);
            textSize(15);  
            //text(currentstatus.getText(), width/2+xoff+xnameoff+xtweetoff, height/2+yoff+ynameoff+ytweetoff);
            rectMode(CENTER);
            text(currentstatus.getText(), width/2+30, height/2+10, 400, 320);
          }
          catch(Exception e)
          {
            print("Draw Tweet txt ERROR: "+e);
            fill(255, 0, 0);
            textSize(15);
            textAlign(LEFT);
            //width/2, height/2, 500, 380
            //rect(width/2+30, height/2+10, 400, 320);
            text("Jim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburgJim Lee is the best @HochschuleFlensburg", width/2+30, height/2+10, 400, 320);
          }
          
        }//end if(statusloaded)
        //end
      }
    }
    
  }

  Status searchContaining(String searchWord, ArrayList<MyWord> MyWordlist)
  {
    //gets the tweet containing "searchWord", returns it as twitterStatus or null if not found--> status.getText()
    print("search:::::->"+searchWord);
    for (int i = 0; i<twC.getTweets().size(); i++)
    {
      Status status = (Status)twC.getTweets().get(i);
      String statustxt = status.getText();


      if (statustxt.contains(searchWord))
      {
        print("contains!!!");
        for (MyWord wo : MyWordlist)
        {
          if (wo.word.contains(searchWord))
          {
            //print("word::"+wo.word);
            statusloaded = true; //global variable
            lastSearchWord = searchWord; //global variable
            print("SET SEARCHWORD:"+searchWord+"|"+lastSearchWord);
            return status;
          }
        }
      }
    }

    statusloaded = false;
    return null; //error
  }

  public void drawTweetCount(int showAmount, String query)
  {
    /*
    .totalwords
     .
     .
     ......wordsdrawn
     */
    //sortedCount.sort(new CompareCount());

    //print("WordDraw: drawing TweetCount...");
    //reset Textstuff
    textSize(20); 
    textAlign(LEFT);
    fill(70, 170, 255);
    stroke(color(70, 170, 255));

    //ATTRIBUTES
    float xpos = 75;
    float ypos = height - height/10;
    float xLength = width - 60 -75;
    float yHeight = ypos-75 ;
    MyWord firstWord = sortedCount.get(0);
    float gapamount = firstWord.gettotalcount();



    //print("         DEBUG!!:"+firstWord.getMyWord()+" "+firstWord.gettotalcount() + "             ");
    //make coord system
    strokeWeight(0.8);
    fill(255, 255, 255);
    text("Counting of most frequent Words in Tweets for #" + query, xpos, height/6-15); //y-text

    /*
    textSize(8);
     //draw y-axis lines
     int cy = 0;
     float gapbetweenY = yHeight/gapamount;
     float countaslinelength = 120;
     for(float j = 0; j<= yHeight; j+= gapbetweenY)
     {
     MyWord current = sortedCount.get(cy);
     strokeWeight(0.4);
     line(xpos, ypos - j, xpos -20, ypos - j);
     
     text(cy, xpos-20, ypos-j);
     text(current.word + ":"+current.gettotalcount(), xpos+40, ypos-j);
     
     strokeWeight(5);
     line(xpos,ypos-j, xpos+ current.totalcount, ypos-j);
     cy++;
     }
     */

    /*
    textSize(12);
     strokeWeight(3);
     int k = 0;
     for(MyWord w : sortedCount)
     {
     text(w.word +":"+w.gettotalcount(), width/8, k *35 + 100);
     line(width/8+20, k*35+100, (width/8+20) + ((width/8-20)/sortedCount.size()), k*35+100);
     k++;
     
     }
     */

    //
    /*
     float yL = 75 + height - height/10;
     float xL = 75 + width - width/10;
     int wordcounter = 0;
     int highestTotalCount = 0;
     for(MyWord w : sortedCount)
     {
     if(w.totalcount > highestTotalCount)
     {
     highestTotalCount = w.totalcount;
     
     line(75, 75 * wordcounter, xL, 75* wordcounter);
     wordcounter++;
     print("test"+wordcounter);
     }
     }
     */
    strokeWeight(8);
    textSize(12);
    int textSize = 12;
    int lastTotalCount = 0;
    int totalCountChanged = 0;
    int sameTotalCount=0;
    int highestTotalCount=0;
    String s = "";
    ArrayList wordswithcount = new ArrayList<MyWord>();

    for (MyWord w : sortedCount)
    {
      if (highestTotalCount < w.totalcount)
      {
        highestTotalCount = w.totalcount;
      }

      if (lastTotalCount != w.totalcount) //only works if sorted
      {
        wordswithcount = new ArrayList<MyWord>();
        if (w.totalcount > lastTotalCount) //highest totalamount
        {
          stroke(color(255, 0, 0));
          fill(color(255, 0, 0));
        } else
        {
          stroke(color(70, 170, 255)); //textColor for totalAmount
          fill(color(255, 255, 255));
        }
        //once the lastTotalCount changes:
        lastTotalCount = w.totalcount;
        totalCountChanged++;
        sameTotalCount=0;

        if(w.totalcount == counttodraw)//<--set the stroke of the current selection red
        {
          stroke(color(255,0,0));
        }
        
        stroke(color(70, 170, 255));
        fill(color(255,255,255));
        //mouse interactivity!
        mouseCount(w, highestTotalCount, totalCountChanged);
        
        line(75, height/6+(totalCountChanged*35), map(w.totalcount, 0, highestTotalCount, 75, width - 60), height/6+(totalCountChanged*35)); //draw a line for each totalcount 1,2,3....
        text(w.totalcount, 75, height/6-8 + (totalCountChanged* 35) ); //text that shows totalAmount for each line +68 yoffset
      } else if (lastTotalCount == w.totalcount)
      {
        //called for same totalCount:
        s = "";
        s+= w.word;
        sameTotalCount++;
      }
      
      
    }
    strokeWeight(0.8); //y-axis weight
    stroke(255, 255, 255);
    line(xpos, height/6, xpos, (height/6 + 30+(totalCountChanged*35))); //draw y-axis +30px offset
    /*
    //draw x-axis lines
     textSize(8);
     int c = 0;
     float gapbetweenX = xLength/gapamount;
     for (float i = 0; i<= xLength; i+= gapbetweenX)
     {
     strokeWeight(0.5);
     line(xpos + i, ypos, xpos + i, ypos + 20);
     text(c, xpos+i, ypos+20);
     c++;
     }
     */
  }
  private void mouseCount(MyWord w, int highestTotalCount, int totalCountChanged)
  {
    //always draw the count set when clicked --> or default draw -highestTotalCount
    
    if(!counttodrawset)//<-- initialize highestTotalCount as the initial count to draw
    {
      counttodrawset = true;
      counttodraw = highestTotalCount;
    }
    
    //DRAW counttodraw:
    String s = "";
    ArrayList<MyWord> words = new ArrayList<MyWord>();
    int tcount = 0;
        for(MyWord word : sortedCount)
        {
          if(word.totalcount == counttodraw)
          {
            s+= word.word+" ";
            words.add(word);
            tcount = word.totalcount;
          }
        }
        //draw rect with txt inside
        fill(255,255,255);
        noStroke();
        rectMode(CORNER);
        textAlign(LEFT);
        rect(width/2+30, height/2+10, 300, 300, 3); //<-- bounding rect
        fill(0,0,0);
        //text(s, width/2+30, height/2+40, 300, 300); //<-- count txt
        
        //draw each word with the total count
        int counter = 0;
        for(MyWord wrd : words)
        {
          text(wrd.word, width/2+30, height/2 + +40+ 10*counter, 300,300);
          counter ++;
        }
        fill(255,0,0);
        text("most frequent for: "+tcount, width/2+30, height/2+30);
        
        //bounding lines topbot
        stroke(color(160, 170, 180));
        strokeWeight(4);
        line(width/2+30, height/2+10, width/2 +330, height/2+10);//<-- top line
        line(width/2+30, height/2+310, width/2+330, height/2 +310);//<-- bottom line
        
        //draw shadow lines
        stroke(color(35,35,35));
        line(width/2+333, height/2+13, width/2+333, height/2 +313); //<-- right shadow
        line(width/2+34, height/2+314, width/2+331, height/2+314); //<-- left shadow
    
    /*MOUSE INTERACTIVITY HERE*/
    if (mouseX > 75 && mouseX < map(w.totalcount, 0, highestTotalCount, 75, width-60) && mouseY >height/6+(totalCountChanged*35)-5 && mouseY <height/6+(totalCountChanged*35) + 5)
    {
      print("IS INSIDE HOVER");
      //text("IS INSIDE HOVER"+ w.totalcount, 100, 100);
      fill(150, 0, 190);
      stroke(150, 0, 190);

      /*MOUSE CLICKED: CHANGE COUNTTODRAW TO CURRENTWORD*/
      if (mousePressed == true) 
      {
        counttodraw = w.totalcount;
      }
    }
    else //<-- if outside of selection
    {
      if(w.totalcount == counttodraw) //<-- if currentword is selected: red
      {
        stroke(color(255,0,0));
      }
      else //<-- if currentword is unselected: blue
      {
        stroke(color(70, 170, 255));
      }
    
    }
    strokeWeight(8); //reset
    
  }
  public void drawLanguageC(int showAmount)
  {
    //reset TextStuff
    textSize(10);
    textAlign(LEFT);
    fill(70, 170, 255);

    //print("WordDraw: drawing LanguageC");
    text("TESTDRAWLANGUAGEC", width/2, height/2);
    for (int i = 0; i< sortedLanguage.size(); i++)
    {
      MyWord current = sortedCount.get(i);
      text(current.word, width/2, i*35+100);
    }
  }


  boolean isDrawnAtPosition(MyWord drawnword, MyWord comparew, float posX, float posY)
  {
    float radiusa = drawnword.dia /2;
    float radiusb = textWidth(comparew.getMyWord())/ 2;
    float distance = dist(drawnword.posX, posX, drawnword.posY, posY);

    return distance < (radiusa + radiusb);
  }
  
}
