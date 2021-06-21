float snakeSpeed;
PVector veloc= new PVector(snakeSpeed, 0);
PVector pos = new PVector ( 10, 10);
PVector lastTurn = pos.copy();
PVector velocBeforeLastTurn = veloc.copy();
int lastTurnDirection = 0; //( 0 for UP, 1 for RIGHT, 2 for DOWN, 3 for LEFT)

ArrayList<PVector> snakeCells = new ArrayList<PVector>();
ArrayList<PVector> candies = new ArrayList<PVector>();
float candySize = 10;

float snakeWidth = 20;
float snakeLenght = 0;
float snakeMinimumSize = 100;
int cellsToAddWhenGrowing = 100;

color fillVal = color(126);


boolean snakeIsGrowing = false;
int remainingCellsToAdd = 0;

boolean weAreGameOver = true;

PFont font;  

int previouskeyCode;

int lastKeypressed;

void setup()
{
  size(480, 480);
  background(51);
 // stroke(222);
  fill(111);
  

  
  font = createFont("Arial",32,true);
  
  drawGameOver();
}

void draw() {
  


  if(!weAreGameOver)
  {
    clear();
    textFont(font,16); 
  
      //stroke(222);
      pos.add(veloc);
      snakeLenght +=veloc.mag();
      //println(snakeLenght);
      
      updateSnakeCells();
      
      checkCollisionWithWalls();
      checkCollisionWithSelf();
      
      drawSnake();
      drawCandies();
      
      checkCollisionSnakeCandies();
      
      growSnake();
    //float remainingLenghtToCut = snakeSpeed;
  }
}

void doGameOver()
{
  weAreGameOver = true;
  drawGameOver();
}

void drawGameOver()
{
    fill(240);        
    text("Game Over",width/2 - 50,height/3 - 50);
    text("Press R to start game",width/2 - 50,height/2 - 50);
}

void startGame()
{
  snakeIsGrowing = false;
  remainingCellsToAdd = 0;
 
  snakeSpeed = 5;
  veloc= new PVector(snakeSpeed, 0);
  pos = new PVector ( 10, 10);
  lastTurn = pos.copy();
  snakeLenght = 0;
  velocBeforeLastTurn = veloc.copy();
  lastTurnDirection = 0; //( 0 for UP, 1 for RIGHT, 2 for DOWN, 3 for LEFT)
  lastKeypressed = RIGHT;
  
  snakeCells = new ArrayList<PVector>();
  candies = new ArrayList<PVector>();
  
    snakeCells.add(pos.copy());
  
  candies.add( new PVector ( 222, 222));
  
  previouskeyCode = 0;

}

void keyPressed() 
{
    if(weAreGameOver)
    {
      if (key == 'r' || key == 'R')
        {
        weAreGameOver = false;
        println("R is pressed");
        startGame();
        return;
        }
    }
    else
    {
  if (key == CODED && keyCode != lastKeypressed) //to prevent windows repeat keys 
  {
    PVector newVeloc =  new PVector (0,0);
    println(keyCode);
    switch (keyCode)
    {
      case UP: newVeloc.set(0,-snakeSpeed);  break;
      case DOWN: newVeloc.set(0, snakeSpeed);  break;
      case LEFT: newVeloc.set(-snakeSpeed, 0);  break;
      case RIGHT: newVeloc.set(snakeSpeed, 0);
    }
    //println("codigos:",previouskeyCode, " : ", keyCode);
    if( keyCode != previouskeyCode) {
      if (isNewVelocValid(newVeloc, veloc))
      {
        velocBeforeLastTurn.set(veloc.copy());
        veloc.set(newVeloc.copy());
        println("New veloc ", newVeloc);
        lastTurn = pos.copy();
        previouskeyCode = keyCode;
      }
    }
    lastKeypressed = keyCode;
  }
    }
}

boolean isNewVelocValid(PVector newVeloc, PVector oldVeloc)
{
  //Check for too Tight Bend
  
  float angleBetweenBeforeTurnAndNew = PVector.angleBetween(newVeloc, velocBeforeLastTurn);
  //println("angle:", angleBetweenBeforeTurnAndNew);
  if (angleBetweenBeforeTurnAndNew >PI -0.1 &&  angleBetweenBeforeTurnAndNew < PI + 0.1)
  {
    if ( pos.dist(lastTurn) < snakeWidth  + 2)
    {
      println("tOO SHARP");
      return false;
    }
  } 
  //Check for 180 degrees turn
  float angleNewVelocOldVeloc = PVector.angleBetween(newVeloc, oldVeloc);
  if (angleNewVelocOldVeloc >PI -0.1 &&  angleBetweenBeforeTurnAndNew < PI + 0.1)
    return false;
    
  return true;
}

void drawSnake()
{
  fill (222);
  //draw Body
  int i;
  for (i = 0; i < snakeCells.size() - 1; i++)
  {
    rect(snakeCells.get(i).x - snakeWidth/2, snakeCells.get(i).y - snakeWidth/2, snakeWidth, snakeWidth);
  }
  
   //draw Head
  fill (222, 50, 50);
  rect(snakeCells.get(i).x - snakeWidth/2, snakeCells.get(i).y - snakeWidth/2, snakeWidth, snakeWidth);
}

void updateSnakeCells ()
{
  PVector nextCellPos =  snakeCells.get(snakeCells.size()-1).copy(); //last
  PVector speedToAdd = veloc.copy();
  
  speedToAdd.normalize();
  
  for (int i = 0; i < veloc.mag(); i++) {
    nextCellPos.add(speedToAdd);
  
    snakeCells.add(nextCellPos);
  
    if((snakeLenght > snakeMinimumSize) && remainingCellsToAdd == 0)
    {
      snakeCells.remove(0);
    }
    remainingCellsToAdd--;
    if(remainingCellsToAdd < 0) remainingCellsToAdd = 0;
  }
}

void growSnake()
{
  if( remainingCellsToAdd > 0) {
   // snakeCells.add( snakeCells.get(0).copy());
    remainingCellsToAdd --;
  }
}

void checkCollisionWithWalls()
{
  if (pos.x + snakeWidth / 2 > width ||
      pos.x - snakeWidth / 2 < 0 ||
      pos.y - snakeWidth / 2 < 0 ||
      pos.y + snakeWidth / 2 > height
      )
        doGameOver();
}

void checkCollisionWithSelf()
{
    for (int i = 0; i < snakeCells.size() - 50; i++) //this is very ugly, ignores the last 50 cells. Not good, but works for this framerate...
    {
        if ( areColliding(pos, snakeWidth, snakeWidth, snakeCells.get(i), snakeWidth, snakeWidth)) {
          doGameOver();
         // println("SELFCOLLISION");
          return;
        }
  }
}

void drawCandies()
{
  fill (222, 50, 50 );
  noStroke();
  
  for (PVector candy : candies )
  {
    rect ( candy.x - candySize/2, candy.y - candySize/2, candySize, candySize);
  }
}

void createNewCandy()
{
   candies.add( new PVector ( random (0 + candySize/2, width - candySize/2), random (0 + candySize/2, height -candySize/2)));
}

boolean areColliding(PVector obj1Pos, float obj1Width, float obj1Height, PVector obj2Pos, float obj2Width, float obj2Height)
{
  float obj1Top = obj1Pos.y - obj1Height / 2;
  float obj1Bottom = obj1Pos.y + obj1Height / 2;
  float obj1Left = obj1Pos.x - obj1Width / 2;
  float obj1Right = obj1Pos.x + obj1Width / 2;
  
  float obj2Top = obj2Pos.y - obj2Height / 2;
  float obj2Bottom = obj2Pos.y + obj2Height / 2;
  float obj2Left = obj2Pos.x - obj2Width / 2;
  float obj2Right = obj2Pos.x + obj2Width / 2;
  
  if (obj2Left <= obj1Right && obj2Right >= obj1Left
      &&
      obj2Bottom >= obj1Top && obj2Top <= obj1Bottom)
      return true;
 
  return false;
}


void checkCollisionSnakeCandies()
{
      for (int i = 0; i < candies.size(); i++) {
        if ( areColliding(pos, snakeWidth, snakeWidth, candies.get(i), candySize, candySize)) {
          candies.remove(i);
          createNewCandy();
  //        createNewCandy();
          remainingCellsToAdd += cellsToAddWhenGrowing;
          return;
        }
      }
}
