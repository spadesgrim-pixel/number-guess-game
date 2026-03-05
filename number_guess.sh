#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read USER

NUMBER_OF_GUESSES=0
RANDOM_NUMBER=$(( $RANDOM % 100 + 1 )) 


CHECK_INPUT() {
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
    read GUESS
    CHECK_INPUT $GUESS
  else 
    if [[ $1 -gt $RANDOM_NUMBER ]]
    then 
      (( NUMBER_OF_GUESSES++ ))
      LOWER_THAN
    elif [[ $1 -lt $RANDOM_NUMBER ]]
    then 
      (( NUMBER_OF_GUESSES++ ))
      HIGHER_THAN
    else
      (( NUMBER_OF_GUESSES++ ))
      echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job! 

      #add score to database 
      ADD_GAMES_PLAYED="$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USER'")"
      BEST_GAME="$($PSQL "SELECT best_game FROM users WHERE username = '$USER'")"
      if [[ $BEST_GAME -eq 0 ]]
      then 
        ADD_GAME="$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USER'")"
      elif [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
      then
        UPDATE_GAME="$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USER'")"
      fi
    fi
  fi
}

LOWER_THAN() {
  echo "It's lower than that, guess again:"
  read GUESS
  CHECK_INPUT $GUESS
}


HIGHER_THAN() {
  echo "It's higher than that, guess again:"
  read GUESS 
  CHECK_INPUT $GUESS
}


IN_DATABASE="$($PSQL "SELECT * FROM users WHERE username = '$USER'")"

if [[ -z $IN_DATABASE ]]
then 
  echo "Welcome, $USER! It looks like this is your first time here."

  #add to database 
  ADD_USER="$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USER',0,0)")"

  echo Guess the secret number between 1 and 1000:
  #guess 
  read GUESS
  
  CHECK_INPUT $GUESS
else 

  #get stats 
  GAMES_PLAYED="$($PSQL "SELECT games_played FROM users WHERE username = '$USER'")"
  PEAK_GAME="$($PSQL "SELECT best_game FROM users WHERE username = '$USER'")"
  
  echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $PEAK_GAME guesses."
  
  echo Guess the secret number between 1 and 1000:
  #guess 
  read GUESS
  
  CHECK_INPUT $GUESS
fi 
