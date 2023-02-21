# CLICK
An infinitely generating clicker game, built in MySQL. Think 'Adventure Capitalist.'

## Deployment
1. Run all three procedures. 
2. Run the following commands:
'''call restart;
   call click;
   call buyclick;
   call autoclick;'''

## General Info
There are 4 thresholds per level: 25, 50, 75, 100. Each threshold grants additional cash per second. Once you reach the fourth threshold, you level up and the thresholds are multiplied by 10. So, the next phase is 250, 500, 750, 1000. This repeats infinitely.

### Buyclick
Increases the number of clicks per click. Each cost $50. 

### Autoclick
Automatically clicks every 10 seconds. Multiple autoclicks can be purchased for $1000 each.
