# CLICK
An infinitely* generating clicker game, built in MySQL. Inspired by games like "Cookie Clicker" and "Adventure Capitalist." 

This project tests the limitations of MySQL. You will see that variables are declared as LONGTEXT. This is due to the limitations of the integer datatype. The game crashes as soon as you reach one centillion dollars.

You begin the game earning $1.00 per second. As you click, you earn additional money per second. This information is stored in a single table using incrementing thresholds to document changes in time and money. Each row illustrates the time spent, changes in currency, cash-time multipliers, and a few other variables. This allows for the procedure to virtually progress even while the server is offline.

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
| 100  | $156.25 |
| 250  | $390.62  |
| 500  | $976.56  |
| 750  | $2,441.40  |
| 1,000  | $24.414.06  |
| 2,500  | $61,035.15 |
| 5,000  | $152,587.89  |
| 7,500  | $381,469.72 |
| 10,000  | $3,814,697.26  |


### Buyclick
Increases the number of clicks per click. 

### Autoclick
Automatically clicks every 10 seconds. Multiple autoclicks can be purchased.
