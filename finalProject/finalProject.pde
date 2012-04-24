// tweetography beta: mapping you and your world

import processing.opengl.*;

import codeanticode.glgraphics.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.mapdisplay.AbstractMapDisplay;
import de.fhpotsdam.unfolding.tiles.MBTilesLoaderUtils;
import de.fhpotsdam.unfolding.geo.MercatorProjection;
import wordcram.*;
import wordcram.text.*;
import controlP5.*;
PFont plain, italics;

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
int[] button = new int[4];
int counter = 1;
MultiList the_list;

// selection tool variables
int sizeSelection = 50;

void setup() {
  background(0);
  plain = loadFont("plain.vlw");
  italics = loadFont("italic.vlw");
  // add controlP5 interface
  controlP5 = new ControlP5(this);
  controlP5.addButton("Home", 10, 10, 20, 80, 19); 
  controlP5.addButton("Analyze", 10, 10, 60, 80, 19);
  controlP5.addButton("Play", 10, 10, 100, 80, 19); 
  controlP5.addButton("Mood", 10, 10, 140, 80, 19); 
  
  // plot size
  size(1400, 800);
  map = new de.fhpotsdam.unfolding.Map(this, 0, 0, width, height, new customMBTilesMapProvider("jdbc:sqlite:" + dataPath("tiles/control-room.mbtiles") + "")); 
  plot_x1 = 0;
  plot_x2 = 1400;
  plot_y1 = 0;
  plot_y2 = 800;
  button[0] = plot_x2 + 210;
  button[1] = plot_y2 - 70;
  button[2] = plot_x2 + 260;
  button[3] = plot_y2;
  map.setTweening(true);
  Location centerLocation = new Location(40, 10);
  map.zoomAndPanTo(centerLocation, 2);
  MapUtils.createDefaultEventDispatcher(this, map);

  // filling the screen a bit.
  for (City c:loadCitiesFromCsv("cities/us.csv")) {
    cities.add(c);
  }
  noStroke();
}

void draw() {
  
  if (analyze == false) {
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
      selectionCircle();
    }
    else {
      calendar();
      aggregate = (City[]) append(aggregate, cities.get(cities.size()-counter));
      for (City c:aggregate) {
        c.col = #FFFFFF;
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
      textMode(CENTER);
      textSize(20);
      text(the_month + " " + the_day, width-160, 630);
      fill(#FFFFFF);
      text(the_time + " (24 hr)", width-173, 680);
      
      counter++;
      if (counter > cities.size()) {
        time = false;
        counter = 0;
      }
    }
  }
  else {
    
     // wordcram
     
     PImage title;
     title = loadImage("cram.png");
     image(title, 0, 0);
     title();
     // basicStats
     float sumStatuses = 0;
     float sumFollowers = 0;
     float sumFriends = 0;
     float sumMood = 0;
     for(City c : selectedCities) {
       sumStatuses += c.statuses;
       sumFollowers += c.followers;
       sumFriends += c.friends;
       sumMood += c.mood;
     }
     sumStatuses = sumStatuses/selectedCities.length;
     sumFollowers = sumFollowers/selectedCities.length;
     sumFriends = sumFriends/selectedCities.length;
     sumMood = sumMood/selectedCities.length;
     
     textSize(20);
     fill(#FFFFFF);
     int x = 157;
     int y = 750;
     text(sumStatuses, x-75, y);
     text(sumFollowers, 3.3*x-75, y);
     text(sumFriends, 5.7*x-75, y);
     text(sumMood, 8*x-75, y);
     
     fill(#FF6103);
     y = 725;
     textMode(RIGHT);
     text("Average no. of statuses", x-75, y);
     text("Average no. of followers", 3.3*x-75, y);
     text("Average no. of friends", 5.7*x-75, y);
     text("Average mood (0-4)", 8*x-75, y);
     
     fill(#FF6103);
     textMode(LEFT);
     textSize(40);
     y+=20;
     text("*", x-105, y);
     text("*", 3.3*x-105, y);
     text("*", 5.7*x-105, y);
     text("*", 8*x-105, y);
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
    Location centerLocation = new Location(40, 10);
    map.zoomAndPanTo(centerLocation, 2);
    for (City c:cities)
      c.col = #FFFFFF;
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
        ellipseMode(CENTER); stroke(#FFFFFF); strokeWeight(1); fill(#FFFFFF, 50); smooth();
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
        ellipseMode(CENTER); stroke(#FFFFFF); strokeWeight(1); fill(#FFFFFF, 50); smooth();
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

void Analyze() {
  float x = mouseX;
  float y = mouseY;
  if (selectedCities.length != 0) {
    getWordCram();
    background(#FFFFFF);
    analyze = true;
  }
  else {
    fill(#FFFFFF);
    textFont(italics);
    textSize(15);
    text("please select some tweets", 10, 150);
  }
}

void title() {
  textMode(LEFT);
  textFont(plain);
  textSize(70);
  fill(#FF6103);
  if (!analyze) 
    text("tweetography", width-width/3, 80);
  else
    text("inspection", width-width/3, 80);
}

void calendar() {
  rectMode(CORNERS);
  fill(110, 40);
  rect(width-200, 610, width-50, 640);
  rect(width-200, 660, width-50, 690); 
} 

void legend() {
  fill(#FF6600);
  textFont(italics);
  textSize(15);
  text("map interface", 20, 660);
  fill(#FFFFFF);
  textFont(plain);
  textSize(15);
  text("up, down, right, left arrows to pan", 20, 680);
  text("-, + keys to zoom", 20, 700);
  text("'h' to resize, 'r' to refresh", 20, 720);
  text("'click' to select tweets", 20, 740);
  text("return to map", 100, 20+12);
  text("inspect the data", 100, 60+12);
  text("tweets over time", 100, 100+12); 
  text("gauge global mood", 100, 140+12); 
}

void Home() {
  analyze = false;
}

void Play() {
  if (analyze == false)
    time = true;
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
        c.col = #33FF33;
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
  wordCram.drawAll();
  saveFrame("cram.png");
}
