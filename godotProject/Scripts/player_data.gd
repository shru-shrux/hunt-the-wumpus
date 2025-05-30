extends Node

# key data for the player to be referenced throughout the game
var username = ""
var arrowCount = 3
var goldCount = 0
var wumpusKilled = false
var hasAntiBatEffect = false
var currentRoomNumber

# for achievements, tracked throughout game then data updated at end
var cavesVisited = 0
var triviaCorrect = 0
