/*
How to Use this Application:
-search for more or less tweets with the QUERYAMOUNT slider
-Show more or less words with the showamount slider

Type a searchword into the Searchfield, press enter

TweetCloud: shows a tweetcloud for the searchword
-hover over a word and press the left mouse button to show the tweet containing the current hovered over word (!*bugged sometimes*!)

TweetCount: shows most frequent words with their total count
-left click on a bar to change the list of words with that total count to the right
 */



/*
Application Author: Jonas Leonhard, 611179, Hochschule Flensburg
 Course: Generative Gestaltung
 */

/*
Sources: 
 TwitterAPI Library: http://twitter4j.org/en/index.html
 controlP5 Library from http://www.sojamo.de/libraries/controlP5/
 Loading Circle: https://www.openprocessing.org/sketch/108437/
 */

/*
Import TwitterAPI Library from http://twitter4j.org/en/index.html
 a guide to setup the API can be found at  http://blog.blprnt.com/blog/blprnt/updated-quick-tutorial-processing-twitter
 Import controlP5 Library from http://www.sojamo.de/libraries/controlP5/
 */
import twitter4j.conf.*;
import twitter4j.api.*;
import twitter4j.*;
import java.util.*;
import controlP5.*;



/*
global Attributes - Twitter
 */
TwitterController twC;

/*
global Attributes - UI
 */
ControlP5 uiControl;
int queryAmount = 1000;
int showAmount = 350;
String searchQuery = "#HelloWorld";
Textfield searchfield;
PFont myFont, myFontbold;
Button de, en, non; //language buttons
Button tweetcloud, tweetcount; //, tweetlanguagecount; //modi button
Slider s, s2;
Boolean langDE = true, langEN = false, langNON = false; //DONT CHANGE WITHOUT CHANGIN .setColor(ccol); to correct button
CColor inactiveCcol, ccol;

/*
global Attributes - WordController
 */
MyWordController wordController;

/*
STATES:
 */
static final int NOSTATE = 0, TWEET_CLOUD = 1, TWEET_COUNT = 2, TWEET_LANGUAGE = 3; //states
int state = TWEET_CLOUD;
boolean hasTweetData = false, startscreen = true;

/*
LOADING CIRCLE
 */
float[] arcStartPositions = new float[3];
float arcBoundSize, arcMaxBoundSize = 60;
float arcLength = 0;

boolean loadingCircle = false, hasLoaded = false;

//StartScreen:
PImage Img;
int screencounter = 0;
boolean lineon = false;
/*

 */
void setup() {
  size(800, 800, P3D);
  //fullScreen(P3D);
  background(40, 40, 40);

  //loading circle setup
  smooth(); //shapes with anialias edges
  for (int i = 0; i < arcStartPositions.length; i++) {
    arcStartPositions[i] = PI / 8 * i;
  }

  //font setup:
  myFont = createFont("Palanquin-Regular", 60);
  myFontbold = createFont("Palanquin-Bold", 60);

  textFont(myFont);

  //UI stuff
  uiControl = new ControlP5(this);
  setUpUI();

  //twitterstuff
  twC = new TwitterController();

  //Wordstuff
  wordController = new MyWordController();

  tweetcloud(); //default mode to start with

  //startscreen:
  Img = loadImage("TwitterLogo.png");
  Img.resize(833 / 8, 677 / 8);
}

void draw() {
  if (showAmount > queryAmount / 2) //keep showamount above queryamount
  {
    showAmount = queryAmount / 2;
    s.setValue(queryAmount);
    s2.setValue(showAmount / 2);
  }

  if (startscreen) {
    textAlign(CENTER);
    textSize(20);
    background(40, 40, 40);
    text("search for a #Tweet in the searchbar to start", width / 2, height / 2);
    stroke(color(255, 255, 255));
    if (frameCount % 50 == 0) {
      lineon = !lineon;
    }

    if (lineon) {
      line(width / 2 - 210, height / 2 + 40, width / 2 - 210, height / 2 - 50);
    }

    textAlign(LEFT);
    imageMode(CENTER);
    image(Img, width / 2, height / 2 - 200);

    if (searchfield.isFocus()) {
      textSize(10);
      text("-the amount of searched tweets", 175, 20);
      text("-the amount of shown tweets", 175, 40);
      text("switch between languages-", 465, 20);
      text("-to show all tweets as a Cloud", 60, 71);
      text("-to sum all words as a graph", 60, 101);
    }
    screencounter++;

  }

  if (loadingCircle) {
    pushMatrix();
    translate(width / 2 - 30, height / 2 - 30);
    loadingCircle();
    popMatrix();
    if (hasLoaded) {
      //gets called once at the end of Thread SubmitSearch() -> requestDataThread
      print("hasloadedlastFrame");
      background(40, 40, 40);
      CheckRedraw();
      hasLoaded = false; //reset for next loading SubmitSearch()
      loadingCircle = false;
    }
  } else if (state == TWEET_COUNT && hasTweetData && !loadingCircle) {
    background(40, 40, 40);
    wordController.drawTweetCount(showAmount, twC.searchWord);
  } else if (state == TWEET_CLOUD && hasTweetData && !loadingCircle) {
    background(40, 40, 40);
    wordController.drawMyWordList(showAmount);
  }
}

void setUpUI() {
  //init ControlP5
  ccol = new CColor();
  ccol.setBackground(color(255, 0, 0)); //red as active background color

  inactiveCcol = new CColor();


  /*
  Add UI elements
   */
  tweetcloud = uiControl.addButton("tweetcloud")
    .setValue(0).setPosition(10, 60)
    .setSize(40, 15)
    .setColor(ccol);

  tweetcount = uiControl.addButton("tweetcount")
    .setValue(0).setPosition(10, 90)
    .setSize(40, 15);

  /*
  tweetlanguagecount = uiControl.addButton("languagecount")
    .setValue(0).setPosition(10, 120)
    .setSize(40, 15)
    ;
    */

  de = uiControl.addButton("lang_de")
    .setValue(0)
    .setPosition((width / 2 + width / 4), 10)
    .setSize(40, 15)
    .setColor(ccol);

  en = uiControl.addButton("lang_en")
    .setValue(0)
    .setPosition((width / 2 + width / 4 + 50), 10)
    .setSize(40, 15);


  /*Button*/
  non = uiControl.addButton("lang_non")
    .setValue(0)
    .setPosition((width / 2 + width / 4 + 100), 10)
    .setSize(40, 15);



  s = uiControl.addSlider("queryAmount", 1, 10000, queryAmount, 10, 10, 100, 10);

  s2 = uiControl.addSlider("showAmount", 1, 1000, showAmount, 10, 30, 100, 10); //min, to max value, default, posx, posy, width, height
  searchfield = uiControl.addTextfield("searchfield").setPosition(width / 2 - 50, 10).setSize(100, 20).setAutoClear(false); //searchfield.getText() called in SubmitSearch, when ENTER && isInFocus()
}

public void lang_de() {
  println("UI lang_de!");

  langDE = true;
  langEN = false;
  langNON = false;

  de.setColor(ccol);
  en.setColor(inactiveCcol);
  non.setColor(inactiveCcol);

  twC.setLanguage("lang:de ");
}
public void lang_en() {
  println("UI lang_en!");

  langEN = true;
  langDE = false;
  langNON = false;

  en.setColor(ccol);
  de.setColor(inactiveCcol);
  non.setColor(inactiveCcol);

  twC.setLanguage("lang:en ");
}
public void lang_non() {
  println("UI lang_non!");
  langNON = true;
  langDE = false;
  langEN = false;

  non.setColor(ccol);
  de.setColor(inactiveCcol);
  en.setColor(inactiveCcol);

  twC.setLanguage("");
}

public void tweetcloud() {
  state = TWEET_CLOUD;
  tweetcloud.setColor(ccol);
  tweetcount.setColor(inactiveCcol);
  //tweetlanguagecount.setColor(inactiveCcol);
  background(40, 40, 40);

  if (hasTweetData) {
    wordController.drawMyWordList(showAmount);
  }
  print("tweetloud");
}

public void tweetcount() {
  state = TWEET_COUNT;
  tweetcloud.setColor(inactiveCcol);
  tweetcount.setColor(ccol);
  //tweetlanguagecount.setColor(inactiveCcol);
  background(40, 40, 40);

  if (hasTweetData) {
    wordController.drawTweetCount(showAmount, twC.searchWord);
  }
  print("tweetcount");
}

public void languagecount() {
  state = TWEET_LANGUAGE;
  tweetcloud.setColor(inactiveCcol);
  tweetcount.setColor(inactiveCcol);
  //tweetlanguagecount.setColor(ccol);
  background(40, 40, 40);

  if (hasTweetData) {
    wordController.drawLanguageC(showAmount);
  }
}

void SubmitSearch() {
  thread("requestData"); //open a thread for data request, draw loading circle as long as data is loading ( thread sets hasloaded = true, to draw outside of thread)
}

void CheckRedraw() {
  if (state == TWEET_CLOUD) {
    wordController.drawMyWordList(showAmount); //draws wordlist
  } else if (state == TWEET_COUNT) {
    wordController.drawTweetCount(showAmount, twC.searchWord);
  } else if (state == TWEET_LANGUAGE) {
    wordController.drawLanguageC(showAmount);
  }
}

void keyPressed() {
  //detect searchfield submit
  if (searchfield.isFocus() && key == ENTER) {
    SubmitSearch();
  } //ifend
}

void loadingCircle() {
  /*Source: https://www.openprocessing.org/sketch/108437/*/
  /*
  Draws a loadingCircle when called, called in draw() when SubmitSearch() starts the Thread requestData()
   */
  background(40, 40, 40);
  fill(40, 40, 40);

  arcBoundSize = arcMaxBoundSize;
  for (float s: arcStartPositions) {
    arcLength = random(PI, 8 * PI / 6);
    color c = color(random(0, 255), random(0, 255), random(0, 255));
    stroke(c);
    strokeWeight(4);
    arc(arcMaxBoundSize / 2, arcMaxBoundSize / 2, arcBoundSize, arcBoundSize, s, s + arcLength);
    arcBoundSize -= 10;
  }
  for (int i = 0; i < arcStartPositions.length; i++) {
    arcStartPositions[i] += PI / 5;
  }
}

void requestData() {

  print("requestDataThread");
  loadingCircle = true; //start loading animation in draw while loading
  //do request here:
  searchQuery = uiControl.get(Textfield.class, "searchfield").getText();
  twC.search(searchQuery, queryAmount);
  print("Submit SearchQuery: " + searchQuery + " ...");
  wordController.tweetSetup(); //gets wordlist ready 

  print("state:" + state);
  wordController.sortAllForDraw();

  hasTweetData = true; //bool shows that data is there
  hasLoaded = true;
  startscreen = false;
}
