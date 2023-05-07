# DemonCrawl Analyzer
 A program that analyzes DemonCrawl log files. It gives an overview of all quests you created,
 and can also show what percentage of runs made it to a victory.

## How to use
### Download
 To download the program, head over to the releases tab on the right and download the
 .zip file. Extract it to your computer, and then run the .exe file.
### Usage
 Once you have downloaded the program, you can run it by simply running the .exe
 file. Click "Initialize Analyzer" and it will read through your DemonCrawl logs folder
 and show relevant information, divided into different tabs.

## Features
### History
 This tab shows an overview of all quests you created.
 In every quest, it shows a list of stages you entered, and it shows your inventory
 whenever you entered or leaved a stage. It also shows your stats at the start of
 every stage.
### Wins
 This tab shows the amount of times you won or lost. It is divided per mastery and
 per profile, and a Global tab that shows all your quests, regardless of profile.
### Statistics
 This tab shows some statistics for all quests created in the last 100 sessions,
 split per profile. It shows the number of chests you opened, the number of artifacts
 collected, the number of items gained, the amount of lives restored and the amount
 of coins spent. Note that it does not include anything done while in Arena.
### Timeline
 This tab shows a calendar that shows your quests by their creation date. Each day
 that has at least 1 created quest on that day is green, and can be clicked on to
 show the quests created on that day, similar to the History tab.
### Filtering
 In the top-right corner, there is a button to filter quests based on when they
 were created or what kind of quest it is. You can specify a timeframe in which
 the quests were created, and/or specify the types of quests that are shown.
 Changing filters affects all tabs.
### Errors
 This tab shows all errors DemonCrawl has bypassed. When the game bypasses an error,
 it shows an alert to the player to view the log file for details. The Analyzer can read
 these details to generate an error log for you to report in the Discord server.
 **Note:** The Errors tab does **not** support filtering.

## Additional notes
- The Analyzer cannot see all quests you created. It can only go back as far as
  the earliest log file. By default, this means it can go back 100 sessions. There
  is a DemonCrawl setting to change this number, but increasing it will increase
  load times and disk space. Any data already collected will never be lost as long as
  the Analyzer is run at least once every 100 sessions.
- The Analyzer is currently **Windows-only**. This is simply because I don't know where
  log files are located on other platforms. If you are not on Windows, you can contact
  me to help me make the Analyzer available for other platforms as well.
- I'm still actively working on the Analyzer. This means I'll be updating it regularly.
  Because I can't think of everything that people may want, I'm open to any suggestions
  you may have!
- Whenever the Analyzer updates or parses new data, it first creates backups of the current
  data. If there is an error with the data shown, create a copy of your Backups folder
  (%appdata%\DemonCrawl Analyzer\Backups) and contact me about your issue.
