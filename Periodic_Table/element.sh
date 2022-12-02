#/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ $1 ]];
then
 if [[ $1 =~ ^[0-9]+$ ]]
 then
  NAME=$(echo "$($PSQL "SELECT name FROM elements WHERE atomic_number=$1")" | sed 's/^ //')
 else
  NAME=$(echo "$($PSQL "SELECT name FROM elements WHERE symbol='$1' OR name='$1'")" | sed 's/^ //')
 fi

 if [[ -z $NAME ]]
 then
  echo "I could not find that element in the database."
  
 else
  ATOMIC_NUMBER=$(echo "$($PSQL "SELECT atomic_number FROM properties INNER JOIN elements USING (atomic_number) WHERE name='$NAME'")" | sed -e 's/^[ \t]*//')
  SYMBOL=$(echo "$($PSQL "SELECT symbol FROM properties INNER JOIN elements USING (atomic_number) WHERE name='$NAME'")" | sed 's/^ //')
  TYPE=$(echo "$($PSQL "SELECT type FROM properties INNER JOIN elements USING (atomic_number) INNER JOIN types USING (type_id) WHERE name='$NAME'")" | sed 's/^ //')
  MASS=$(echo "$($PSQL "SELECT atomic_mass FROM properties INNER JOIN elements USING (atomic_number) WHERE name='$NAME'")" | sed -e 's/^[ \t]*//')
  MELTING_POINT=$(echo "$($PSQL "SELECT melting_point_celsius FROM properties INNER JOIN elements USING (atomic_number) WHERE name='$NAME'")" | sed -e 's/^[ \t]*//')
  BOILING_POINT=$(echo "$($PSQL "SELECT boiling_point_celsius FROM properties INNER JOIN elements USING (atomic_number) WHERE name='$NAME'")" | sed -e 's/^[ \t]*//')
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
 fi

else
 echo "Please provide an element as an argument."

fi 

