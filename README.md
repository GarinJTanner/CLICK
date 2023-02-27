# CLICK
An infinitely generating clicker game, built in MySQL. Inspired by games like, "Cookie Clicker," and "Adventure Capitalist." 

You being the game earning $1.00 per second. As you click, you earn more dollars per second. This information is stored in a single table using incrementing thresholds to document changes in time and money. Each row illustrates the time spent, the money earned, and the progress of progress of time. Variables of time are stored in tables, allowing for the procedure to virtually progress even while the server is offline.

## General Info
Commands:
```
call click;
call buyclick;
call autoclick;
call restart;
```

Use the click procedure to generate clicks and level up. There are 4 click checkpoints, or thresholds, per level: 25, 50, 75, 100. Each threshold grants additional cash per second. Once you reach the fourth threshold, you level up and the thresholds are multiplied by 10. So, the next phase is 250, 500, 750, 1000. This repeats infinitely.

| Clicks  | Threshold |
| ------------- | ------------- |
| 0  | Thresh 1  |
| 25  | Thresh 1 |
| 50  | Thresh 1  |
| 75  | Thresh 1  |
| 100  | Thresh 10  |
| 250  | Thresh 10  |
| 500  | Thresh 10  |
| 750  | Thresh 10  |
| 2500  | Thresh 100  |
| 5000  | Thresh 100  |
| 7500  | Thresh 100  |
| 10000  | Thresh 100  |


### Buyclick
Increases the number of clicks per click. 

### Autoclick
Automatically clicks every 10 seconds. Multiple autoclicks can be purchased.
