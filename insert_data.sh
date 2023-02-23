#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams;")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != 'winner' ]]
  then
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    if [[ -z $WIN_ID ]]
    then
      INSERT_WIN_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_WIN_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams: $WINNER
      fi
      WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi
    if [[ -z $OPP_ID ]]
    then
      INSERT_OPP_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $INSERT_OPP_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams: $OPPONENT
      fi
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi

    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id='$WIN_ID' AND opponent_id='$OPP_ID';")
    if [[ -z $GAME_ID ]]
    then
      INSERT_DATA=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WIN_ID,$OPP_ID,$WINNER_GOALS,$OPPONENT_GOALS);")
      if [[ $INSERT_DATA == 'INSERT 0 1' ]]
      then
        echo Inserted data
      fi
    fi
  fi
done
