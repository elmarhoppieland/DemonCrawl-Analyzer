# Methods

## void history_load_batch(batch: HistoryFile.Batch)
Is called when loading a batch from the player's HistoryFile. A batch is a set of lines that occured
in the same second.
The method's argument 'batch' is mutable. This means changing anything in the batch (such as the order
of lines) will affect in what order the lines are processed. Note that this also changes in what order
the lines are process in other packages.


## void history_load_line(line: HistoryFile.LineData)
Is called when loading a line from the player's HistoryFile.
The method's argument 'line' is mutable. This means changing anything in the line will affect in what
order the lines are processed. Note that this also changes in what order the lines are process in other
packages.


## bool history_load_line_keep(line: HistoryFile.LineData)
Is called when loading a line from the player's HistoryFile, after calling history_load_line().
Should return whether this line should be kept in memory. If at least 1 package return true for a line,
the line is kept in memory.
