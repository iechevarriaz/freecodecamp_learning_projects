#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# echo $($PSQL "TRUNCATE users, number_guessing_game")
# echo $($PSQL "ALTER SEQUENCE number_guessing_game_game_id_seq RESTART WITH 1")
# echo $($PSQL "ALTER SEQUENCE users_user_id_seq RESTART WITH 1")



RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME


USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")


# Check if user is in db:
if [[ -z $USER_ID ]];
then
  # if username not been used before
  
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  
  
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM number_guessing_game WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN (number_of_guesses) FROM number_guessing_game WHERE user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi

echo "Guess the secret number between 1 and 1000:"

DATE=$(date +%Y-%m-%d)
TIME=$(date +%Hh:%Mmin)
COUNT=1
while [[ $INPUT != $RANDOM_NUMBER ]]
do
    read INPUT
    if [[ $INPUT =~ ^-?[0-9]+$ ]];
    then
      if [[ $RANDOM_NUMBER -lt $INPUT  ]];
      then
        echo "It's lower than that, guess again:"
        
      elif [[ $RANDOM_NUMBER -gt $INPUT ]];
      then
        echo "It's higher than that, guess again:"
      

      elif [[ $RANDOM_NUMBER -eq $INPUT ]];
      then
        echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
        INSERT_GAME=$($PSQL "INSERT INTO number_guessing_game(user_id, date, time, number_of_guesses) VALUES($USER_ID, '$DATE', '$TIME', $COUNT)")
      
      fi  

    else
    echo "That is not an integer, guess again:"
        
    fi
    let COUNT=COUNT+1
done

GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM number_guessing_game WHERE user_id=$USER_ID")
BEST_GAME=$($PSQL "SELECT MIN (number_of_guesses) FROM number_guessing_game WHERE user_id=$USER_ID")


UPDATE_USERS=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID")


