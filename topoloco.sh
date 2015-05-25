#!/usr/local/bin/bash

#Declare associative arrays
declare -A fpScoreBoard=( ["escalera"]=0 ["duque"]=0 ["brinco"]=0 ["1"]=0 ["2"]=0 ["3"]=0 ["4"]=0 ["5"]=0 ["6"]=0 )
declare -A spScoreBoard=( ["escalera"]=0 ["duque"]=0 ["brinco"]=0 ["1"]=0 ["2"]=0 ["3"]=0 ["4"]=0 ["5"]=0 ["6"]=0 )

#Turn information
turnCount=0
TURNS=8
currentTurn=0
topoLoco=false
diceResult1=0
diceResult2=0
diceResult3=0
sortedResults=''
fpTotalScore=0
spTotalScore=0

#Display dices
function diceDisplay {
	user=''
	user=$(userTurn)
	echo "$user tiro los dados:"

	echo "------   ------   ------"
	echo "|  $1  |  |  $2  |  |  $3  |"
	echo "------   ------   ------"

	verifyTopoLoco $1 $2 $3
}

#Return the current user in turn
function userTurn {
	if [ $currentTurn -eq 1 ]
		then
			echo $fp
		else
			echo $sp
	fi
}

#Verify if dice roll is topo loco, if it is current user wins.
function verifyTopoLoco {
	if [ $1 = $2 -a $2 = $3 ]
		then
			user=''
			user=$(userTurn)
			topoLoco=true
			echo "TOPO LOCO!"
			echo "¡$user gana el juego!"
			exit
	fi
}

#Returns the total for the numbers that are repeated.
function playDuque {
	accum=0

	if [ $diceResult1 -eq $diceResult2 ]
		then
			accum=$((diceResult1 + diceResult2))
	elif [ $diceResult2 -eq $diceResult3 ]
		then
			accum=$((diceResult2 + diceResult3))
	elif [ $diceResult1 -eq $diceResult3 ]
		then 
			accum=$((diceResult1 + diceResult3))
	fi

	if [ $currentTurn -eq 1 ]
		then
			fpScoreBoard["duque"]=$accum
	else
		spScoreBoard["duque"]=$accum
	fi
}

function playEscalera {
	escalera=0

	if [ $((sortedResults[1] - sortedResults[0])) -eq 1 ] && [ $((sortedResults[2] - sortedResults[1])) -eq 1 ]
		then
			escalera=$((sortedResults[0] + sortedResults[1] + sortedResults[2]))
	fi

	if [ escalera > 0 ]
		then
			if [ $currentTurn -eq 1 ]
				then
					fpScoreBoard["escalera"]=$escalera
			else
				spScoreBoard["escalera"]=$escalera
			fi
	fi
}

function playBrinco {
	brinco=0

	if [ $((sortedResults[0] + 2)) = ${sortedResults[1]} ] || [ $((sortedResults[0] + 2)) = ${sortedResults[2]} ] || [ $((sortedResults[1] + 2)) =  ${sortedResults[2]} ]
		then
			brinco=$((sortedResults[0] + sortedResults[1] + sortedResults[2]))
	fi

	if [ brinco > 0 ]
		then
			if [ $currentTurn -eq 1 ]
				then
					fpScoreBoard["brinco"]=$brinco
			else
				spScoreBoard["brinco"]=$brinco
			fi
	fi
}

# Sorts the Dices in order
function sortResults {
    sortedResults=($1 $2 $3)

	if [ ${sortedResults[0]} -ge ${sortedResults[1]} ]; then
		temp=${sortedResults[0]}
		sortedResults[0]=${sortedResults[1]}
		sortedResults[1]=$temp
	fi
	if [ ${sortedResults[1]} -ge ${sortedResults[2]} ]; then
		temp=${sortedResults[1]}
		sortedResults[1]=${sortedResults[2]}
		sortedResults[2]=$temp
	fi
	if [ ${sortedResults[0]} -ge ${sortedResults[1]} ]; then
		temp=${sortedResults[0]}
		sortedResults[0]=${sortedResults[1]}
		sortedResults[1]=$temp
	fi

	return $arr
}

#Generate a random number
function randomNumbers {
	#Initialize
	diceResult1=$(( $RANDOM % 6 + 1 ))
	diceResult2=$(( $RANDOM % 6 + 1 ))
	diceResult3=$(( $RANDOM % 6 + 1 ))

	sortResults $diceResult1 $diceResult2 $diceResult3

	diceDisplay $diceResult1 $diceResult2 $diceResult3
}

#Display current user score board
function scoreBoards {
	user=''
	user=$(userTurn)
	score=0

	echo '***********************'
	echo "Papeleta de $user"

	if [ $currentTurn -eq 1 ]
		then
			for i in "${!fpScoreBoard[@]}"
				do
					score=$((score + ${fpScoreBoard[$i]}))
				  	echo $i ": " ${fpScoreBoard[$i]}
				done

		fpTotalScore=$score

		printf "\n"
		echo "Total de puntos: $fpTotalScore"
		printf "\n"
	else
		for i in "${!spScoreBoard[@]}"
			do
				score=$((score + ${spScoreBoard[$i]}))
			  	echo $i ": " ${spScoreBoard[$i]}
			done

		spTotalScore=$score

		printf "\n"
		echo "Total de puntos: $spTotalScore"
		printf "\n"
	fi

	echo '***********************'
}

#ME QUEDE AQUI, EL CURRENTUSERPLAYS NO ESTA SALIENDO BIEN!
function simplePlay {
	add=$(( $@ - 3 ))

	if [ $@ > 3 ]
		then
			counter=0
			if [ $currentTurn -eq 1 ]
				then
					fpScoreBoard[$add]=$add
				else
					spScoreBoard[$add]=$add
			fi
	fi
}

#Present play after dice roll
function presentPlays {
	scoreBoards

	printf "\n"
	echo "Seleccione su jugada:"
	echo "1: Escalera"
	echo "2: Duque"
	echo "3: Brinco"
	echo "4: 1"
	echo "5: 2"
	echo "6: 3"
	echo "7: 4"
	echo "8: 5"
	echo "9: 6"

	printf "\n"
	echo "Elección:"
	read play
	printf "\n"

	case $play in 
		1) playEscalera;;
		2) playDuque;;
		3) playBrinco;;
		[4-9]) simplePlay $play;;
		*) playEscalera
	esac
}

#Start Program

#Get basic information
echo "El juego del Topo Loco"

echo "Favor entre el nombre del primer jugador: "
read fp

echo "Favor entre el nombre del segundo jugador: "
read sp

echo
echo "$fp vs. $sp"
echo

while [ $turnCount -lt $TURNS -a $topoLoco = false ]
do
	if [ $(( $turnCount % 2 )) -eq 0 ];
		then
			currentTurn=1
		else
			currentTurn=2
	fi

	printf "\n"
	randomNumbers
	presentPlays

	scoreBoards

	turnCount=$(( $turnCount + 1 ))
done

echo "Resultado:"

currentTurn=1
user1=''
user1=$(userTurn)
echo "-------------------------"
echo "| Puntuación de $user1 : $fpTotalScore |"

currentTurn=2
user2=''
user2=$(userTurn)
echo "| Puntuación de $user2 : $spTotalScore |"
echo "-------------------------"


echo $fpTotalScore
echo $spTotalScore

if [ $fpTotalScore -gt $spTotalScore ]
	then
		echo "¡$user1 gana la partida!"
elif [ $fpTotalScore -lt $spTotalScore ]
	then
		echo "¡$user2 gana la partida!"
else
	echo "¡Hay un empate!"
fi