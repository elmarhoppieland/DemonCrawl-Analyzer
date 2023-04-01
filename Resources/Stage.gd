extends HistoryData
class_name Stage

## A DemonCrawl stage.

# ==============================================================================
## The name of the stage, without any stage mods.
var name := ""
## The name of the stage, including the first 2 stage mods.
var full_name := ""
## The mods of the stage. [br][br][b]Note:[/b] Only contains the first 2 stage mods.
var mods := PackedStringArray()
## The adjective of the stage, if applicable.
var adjective := ""

## The state of the quest when the stage is entered.
var enter: StageEnter
## The state of the quest when the stage is exited.
var exit: StageExit
## The state of the quest when the player dies.
var death: StageExit

## The time spent in the stage.
var time_spent := ""
# ==============================================================================
