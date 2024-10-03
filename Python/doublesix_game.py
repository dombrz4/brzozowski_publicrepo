# This script is a simple game where the user has to input the names of 2 players, and then the script will simulate the game of rolling a pair of dice for each player until they get a double six.
# The script will then print the results of the game, showing who won and how many attempts each player needed to get a double six.

import random

def get_roll_counter() -> int:
    '''
    Function rolls a pair of dice, and keeps rolling the dice again and again, until they roll a double six

    Returns:
        number of rolling attempts
    '''
    counter = 0
    while True:
        counter += 1
        die1 = random.randint(1, 6)
        die2 = random.randint(1, 6)
        if die1 == 6 and die2 == 6: 
            return counter


def print_game_results(name1: str, counter1: int, name2: str, counter2: int) -> None:
    '''
    Function prints the results of 'Double Six Dice Game' for 2 players

    Parameters:
        name1: name of the first player
        counter1: number of attempts of the first player until get DoubleSix    
        name2: name of the first player
        counter2: number of attempts of the first player until get DoubleSix
    Returns:
        None
    '''
    print("==========")
    if counter1 < counter2:
        print(f"Player {name1} won, with {counter1} double dice rolls!!!\nPlayer {name2} had {counter2} attempts")
    elif counter2 < counter1:
        print(f"Player {name2} won, with {counter2} double dice rolls!!!\nPlayer {name1} had {counter1} attempts")
    else:
        print(f"It's a draw. Both players took {counter1} attempts.")
    

print("__________________________\n|                          |\n|   Double Six Dice Game   |\n|__________________________|")
name1 = input("Enter the name of player 1 ...")
name2 = input("Enter the name of player 2 ...")
counter1 = get_roll_counter()
counter2 = get_roll_counter()
print_game_results(name1, counter1, name2, counter2)
