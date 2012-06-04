/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/62695*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */

// tweetography beta: mapping you and your world

import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.providers.*;

//import processing.opengl.*; 
import codeanticode.glgraphics.*;

import wordcram.*;
import wordcram.text.*;
import controlP5.*;
PFont plain, italics, bold;

de.fhpotsdam.unfolding.Map map;

ControlP5 controlP5;
ArrayList<City> cities = new ArrayList<City>();
City[] selectedCities = new City[0];
City[] aggregate = new City[0];
int imageWidth = 900;
int imageHeight = 600;
int margin = 40;
int plot_x1, plot_x2, plot_y1, plot_y2;
WordCram wordCram;
String bigString;
boolean analyze = false;
boolean time = false;
boolean test = false;
int[] button = new int[4];
int counter = 1;
boolean pressed = false;
color newCol = #00688B;

// selection tool variables
int sizeSelection = 50;

void setup() {
  background(0);
  plain = loadFont("plain.vlw");
  italics = loadFont("italic.vlw");
  bold = loadFont("bold.vlw");
  
  
  // add controlP5 interface
  controlP5 = new ControlP5(this);
  controlP5.addButton("Home", 10, 10, 20, 80, 19); 
  controlP5.addButton("Analyze", 10, 10, 60, 80, 19);
  controlP5.addButton("Play", 10, 10, 100, 80, 19); 
  controlP5.addButton("Mood", 10, 10, 140, 80, 19); 
  
  // plot size
  size(970, 768);
  smooth();
  
  //map
  map = new de.fhpotsdam.unfolding.Map(this, new OpenStreetMap.CloudmadeProvider("6af2f3a3e8bc4a5f88c86b72c8246476", 63568));
  //map = new de.fhpotsdam.unfolding.Map(this, 0, 0, width, height, new customMBTilesMapProvider("jdbc:sqlite:" + dataPath("tiles/control-room.mbtiles") + ""));
  //map = new de.fhpotsdam.unfolding.Map(this, 0, 0, width, height, new MapBox.ControlRoomProvider());
  
  
  Location centerLocation = new Location(40, 10);
  map.zoomAndPanTo(centerLocation, 2);
  MapUtils.createDefaultEventDispatcher(this, map);
  
  // adjustments
  plot_x1 = 0;
  plot_x2 = 1400;
  plot_y1 = 0;
  plot_y2 = 800;
  button[0] = plot_x2 + 210;
  button[1] = plot_y2 - 70;
  button[2] = plot_x2 + 260;
  button[3] = plot_y2;
  
  
  // filling the screen a bit.
  for (City c:loadCitiesFromCsv("cities/us.csv")) {
    smooth();
    cities.add(c);
  }
  noStroke();
}

void draw() {
  
  if (analyze == true) {
    if (wordCram.hasMore()) {
      wordCram.drawNext();
    }
    else {
    float sumStatuses = 0;
    float sumFollowers = 0;
    float sumFriends = 0;
    float sumMood = 0;
    for(City c:selectedCities) {
      sumStatuses += c.statuses;
      sumFollowers += c.followers;
      sumFriends += c.friends;
      sumMood += c.mood;
    }
    int l = selectedCities.length;
    sumStatuses = sumStatuses/l;
    sumFollowers = sumFollowers/l;
    sumFriends = sumFriends/l;
    sumMood = sumMood/l;
    smooth();
    textSize(20);
    
    rectMode(CORNER);
    fill(50);
    rect(0, 695, width, 200);
    
    fill(#FF6103);
    int y = 725;
    textAlign(CENTER);
    smooth();
    textFont(plain, 20);
    text("Average no. of statuses", width/8, y);
    text("Average no. of followers", 1.47*width/4, y);
    text("Average no. of friends", 2.5*width/4, y);
    text("Average mood (0-4)", 3.5*width/4, y);
    
    fill(180);
    text(sumStatuses, width/8, y+30);
    text(sumFollowers, 1.47*width/4, y+30);
    text(sumFriends, 2.5*width/4, y+30);
    text(sumMood, 3.5*width/4, y+30);
    }
  }
  else {
  map.draw();
  title();
  legend();
  
  if (time == false) {
    for (City c:cities) {
      c.tick();
      float xy[] = map.getScreenPositionFromLocation(new Location(c.lat, c.lng));
      float x = xy[0];
      float y = xy[1];
      float markerRadius = constrain(map.getZoom()/10, 1, 20) * 4;
    }
    hover();
    selectionCircle();
  }
  else {
    aggregate = (City[]) append(aggregate, cities.get(cities.size()-counter));
    for (City c:aggregate) {
      c.col = newCol;
      c.tick();
    }
    City c = cities.get(cities.size()-counter);
    float xy[] = map.getScreenPositionFromLocation(new Location(c.lat, c.lng));
    float x = xy[0];
    float y = xy[1];
    fill(#FF6600, 150);
    noStroke();
    ellipse(x, y, 20, 20);
    fill(#FF6600);
    textFont(plain);
    String s = cities.get(cities.size()-counter).datetime;
    int first = s.indexOf('/');
    int next = s.lastIndexOf('/');
    String the_month = getMonthForInt(int(s.substring(0, first)));
    String the_day = s.substring(first+1, next);
    String the_time = s.substring(next+4);     
    textAlign(RIGHT);
    textSize(20);
    text(the_month + " " + the_day, width-30, 710);
    fill(0);
    text(the_time + " (24 hr)", width-30, 740);
    
    counter++;
    if (counter > cities.size()) {
      time = false;
      counter = 1;
      aggregate = new City[0];
    }
  }
  }
 
}

void keyPressed() {
  if (key == '=') 
    map.zoomLevelIn();
  if (key == '_')
    map.zoomLevelOut();
  if (key == 'h') {
    Location centerLocation = new Location(40, 10);
    map.zoomAndPanTo(centerLocation, 2);
  }
  if (key == 'r') {
    selectedCities = new City[0];
    time = false;
    Location centerLocation = new Location(40, 10);
    map.zoomAndPanTo(centerLocation, 2);
    for (City c:cities)
      c.col = newCol;
  } 
}

String getMonthForInt(int m) {
    String month = "invalid";
    DateFormatSymbols dfs = new DateFormatSymbols();
    String[] months = dfs.getMonths();
    if (m >= 0 && m <= 11 ) {
        month = months[m-1];
    }
    return month;
}

boolean near(float x, float y, float diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if(sqrt(sq(disX) + sq(disY)) < diameter/2 ) 
    return true;
  else 
    return false;
}


// tweet selection

void selectionCircle() {
  if (mouseX > plot_x1 && mouseX < plot_x2 && mouseY > plot_y1 && mouseY < plot_y2) {
      
      if (mouseX > 150 && mouseY > 150) {
        // draw bounding box
        ellipseMode(CENTER); stroke(0); strokeWeight(1); fill(0, 50); smooth();
        ellipse(mouseX, mouseY, sizeSelection, sizeSelection);
      }
  } 
}

void mouseClicked() {
  float circleX, circleY;
  if (mouseX > plot_x1 && mouseX < plot_x2 && mouseY > plot_y1 && mouseY < plot_y2) {
     // draw bounding box
      if (mouseX < 161 && mouseY < 156) {}
      else {
        ellipseMode(CENTER); stroke(0); strokeWeight(1); fill(0, 50); smooth();
        ellipse(mouseX, mouseY, sizeSelection, sizeSelection);
      }
  }
  
  for (City c:cities) {
    float xy[] = map.getScreenPositionFromLocation(new Location(c.lat, c.lng));
    float x = xy[0];
    float y = xy[1];
    if (near(x, y, sizeSelection)) {
      c.col = #FF6103;
      selectedCities = (City[]) append(selectedCities, c);
    }
  }
} 

void hover() {
  for (City c:cities) {
    float xy[] = map.getScreenPositionFromLocation(new Location(c.lat, c.lng));
    float x = xy[0];
    float y = xy[1];
    if (near(x, y, sizeSelection)) {
      textFont(plain, 15);
      fill(0);
      text(c.tweet, 75, 740);
      textFont(plain, 12);
      text("[ " + c.datetime + " ]", 75, 760);
      
      break;
    }
  }
}

void Analyze() {
  if (selectedCities.length != 0) {
    getWordCram();
    background(0);
    smooth();
    analyze = true;
  }
}

void title() {
  textAlign(LEFT);
  textFont(plain);
  textSize(70);
  fill(#FF6103);
  if (!analyze) {
    PImage logo = loadImage("logo.png");
    image(logo, width-6.6*margin, 10, width/4, height/11);
    //text("tweetography", width-width/3, 80);
  }
  else
    text("inspection", width-width/3, 80);
}

void legend() {
  
  fill(#FF6600);
  textFont(italics, 15);
  int spacer = 600;
  fill(0);
  textFont(plain, 15);
  text("[ arrows ] to pan", 10, spacer+20);
  text("[ +/- ] to zoom", 10, spacer+40);
  text("[ r ] to refresh", 10, spacer+60);
  text("[ 'CLICK' ] to select tweets", 10, spacer+80);
  
  textFont(italics, 15);
  fill(#FF6600);
  text("tweet >>>", 10, 740);
  
  fill(0);
  textFont(plain, 15);
  text("return to map", 100, 20+12);
  text("inspect the data", 100, 60+12);
  text("tweets over time", 100, 100+12); 
  text("gauge global mood", 100, 140+12); 
}

void Home() {
  analyze = false;
  selectedCities = new City[0];
  wordCram = null;
  Location centerLocation = new Location(40, 10);
  map.zoomAndPanTo(centerLocation, 2);
  for (City c:cities)
      c.col = newCol;
}

void Play() {
  if (pressed) {
    time = false;
    pressed = false;
    aggregate = new City[0];
    
  }
  else if (analyze == false) {
    time = true;
    pressed = true;
  }
}

void Mood() {
  if (analyze == false) {
    for (City c: cities) {
      int mood = c.mood;
      if (mood==0)
        c.col = #CD0000;
      else if (mood==2) 
        c.col =  #0276FD;
      else
        c.col = #66CD00;
    }
  }
}
    
    

void getWordCram() {
  // append strings
  String[] tweets = new String[0];
  for (City c: selectedCities)
    tweets = append(tweets, c.tweet);  
  bigString = join(tweets, ","); 
  background(0);
  wordCram = new WordCram(this)
    .fromTextString(bigString)
    .withFonts(PFont.list())
    .withPlacer(Placers.centerClump())
    .sizedByWeight(12, 60)
    .withColors(color(234, 21, 122), color (0, 112, 192), color (26, 179, 159));
  //wordCram.drawAll();
  //saveFrame("cram.png");
}
