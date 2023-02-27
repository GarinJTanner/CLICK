# CLICK
An infinitely generating clicker game, built in MySQL. Inspired by games like, "Cookie Clicker," and "Adventure Capitalist." 

You being the game earning $1.00 per second. As you click, you earn more dollars per second. This information is stored in a single table using incrementing thresholds to document changes in time and money. Each row illustrates the time spent, changes in currency, cash-time multipliers, and a few other variables. This allows for the procedure to virtually progress even while the server is offline.

## General Info
Commands:
```
call click;
call buyclick;
call autoclick;
call restart;
```

Use the click procedure to generate clicks and level up. There are 4 click checkpoints, or thresholds, per level: 25, 50, 75, 100. Each threshold grants additional cash per second. Once you reach the fourth threshold, you level up and the thresholds are multiplied by 10. So, the next phase is 250, 500, 750, 1000. This repeats infinitely.

| Clicks  | Dollars Per Second |
| ------------- | ------------- |
| 0  | $1.00  |
| 25  | $2.50 |
| 50  | $6.25  |
| 75  | $15.62  |
| 100  | $39.06 |
| 250  | $97.66  |
| 500  | $244.14  |
| 750  | $610.35  |
| 2,500  | $1,525.88  |
| 5,000  | $3,814.70  |
| 7,500  | $9,536.74  |
| 10,000  | $23,841.86  |


### Buyclick
Increases the number of clicks per click. 

### Autoclick
Automatically clicks every 10 seconds. Multiple autoclicks can be purchased.
