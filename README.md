# CLICK
An infinitely generating clicker game, built in MySQL. 

## General Info
Commands:
```
call click;
call buyclick;
call autoclick;
call restart;
```

Use the click procedure to generate clicks and level up. There are 4 click checkpoints, or thresholds, per level: 25, 50, 75, 100. Each threshold grants additional cash per second. Once you reach the fourth threshold, you level up and the thresholds are multiplied by 10. So, the next phase is 250, 500, 750, 1000. This repeats infinitely.

| Clicks  | Cash / Sec Multiplier |
| ------------- | ------------- |
| 0  | Thresh 0  |
| 25  | Thresh 1 |
| 50  | Thresh 2  |
| 75  | Thresh 3  |
| 100  | Thresh 0  |
| 250  | Thresh 1  |
| 500  | Thresh 2  |
| 750  | Thresh 3  |
| 1000  | Thresh 0  |



### Buyclick
Increases the number of clicks per click. 

### Autoclick
Automatically clicks every 10 seconds. Multiple autoclicks can be purchased.
