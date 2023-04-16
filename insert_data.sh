#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
i=1
while read line
do
  if (( $i > 1 ))
  then
  OLD_IFS="$IFS"
  IFS=","
  array=($line)
  IFS="$OLD_IFS"
  result=$($PSQL "select name from teams where name = '${array[2]}'")
  if [[ $result == '' ]]
  then
    $($PSQL "insert into teams(name) values ('${array[2]}')")
  fi
  result2=$($PSQL "select name from teams where name = '${array[3]}'")
  if [[ $result2 == '' ]]
  then
    $($PSQL "insert into teams(name) values ('${array[3]}')")
  fi
  else
  i=2
  fi
done < games.csv


j=1
while read line
do
  if (( $j > 1 ))
  then
  OLD_IFS="$IFS"
  IFS=","
  array=($line)
  IFS="$OLD_IFS"
  winner_id=$($PSQL "select team_id from teams where name = '${array[2]}'")
  opponent_id=$($PSQL "select team_id from teams where name = '${array[3]}'")
  $($PSQL "insert into games(year,round,winner_goals,opponent_goals,winner_id,opponent_id) values (${array[0]},'${array[1]}',${array[4]},${array[5]},$winner_id,$opponent_id)")
  else
  j=2
  fi
done < games.csv
