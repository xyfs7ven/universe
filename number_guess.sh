#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

echo -e "Enter your username:"
read USER_NAME

username=$($PSQL "SELECT user_name FROM users WHERE user_name = '$USER_NAME'")

if [[ -z $username ]]
then
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  ADD_NEW_USER=$($PSQL "INSERT INTO users(games_played, best_game, user_name) VALUES(0, 0, '$USER_NAME')")
  GAMES_PLAYED=0
else
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_name='$username'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_name='$username'")
  echo "Welcome back, $username! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

GAME() {
  NUMBER_OF_TRIES=$((NUMBER_OF_TRIES+1))
  read USER_GUESS_NUMBER
  if [[ ! $USER_GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $USER_GUESS_NUMBER > $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $USER_GUESS_NUMBER < $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $USER_GUESS_NUMBER == $RANDOM_NUMBER ]]
  then
    GAMES_PLAYED=$((GAMES_PLAYED+1))
    if [[ ( -z $BEST_GAME ) || ($BEST_GAME > $NUMBER_OF_TRIES) ]]
    then
    BEST_GAME="$NUMBER_OF_TRIES"
    SAVE_BEST_GAME=$($PSQL "UPDATE users SET best_game = '$BEST_GAME' WHERE user_name='$USER_NAME'")
    fi
    SAVE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = '$GAMES_PLAYED' WHERE user_name='$USER_NAME'")
    echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    return 0
  fi
  GAME
}

GAME
