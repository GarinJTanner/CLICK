DROP PROCEDURE IF EXISTS buyclick;
DELIMITER //
CREATE PROCEDURE buyclick()

BEGIN
DECLARE $click_mult,$current_cash,$current_time,$current_spent,$current_mult,$current_thresh,$current_tmult,$buyclick_cnt,$buyclick_cost,$purchase_diff,$purchase_time,$system,$time_case,$total_cash,$total_spent,$total_tmult,$total_time,$total_mult,$wallet LONGTEXT;


	-- ACTIVE
       		SET $current_time = (select timestampdiff(second,created_at, current_timestamp()) from click WHERE active=1),
                $current_mult = (select mult from click WHERE active=1),
				$current_tmult = (select sum($current_time*$current_mult)),
                $current_spent = (select cspent from click where active=1),
                $current_cash = (select sum($current_tmult-$current_spent));
			
			UPDATE click 
SET 
    time = $current_time,
    mult = $current_mult,
    tmult = $current_tmult,
    cash = (SELECT CONCAT('$', (FORMAT($current_cash, 2))))
WHERE
    active = 1;
       
       
                    
	-- TOTAL   
       
            SET $total_time = (select sum(time) from click where id!=1),
				$total_tmult = (select sum(tmult) from click WHERE id!=1),
                $total_spent = (select sum(cspent) from click WHERE id!=1),
                $total_cash = (select sum($total_tmult-$total_spent)),
                $wallet = CONCAT('$',(FORMAT($total_cash,2)));


			UPDATE click 
			SET 
				time = $total_time,
				tmult = $total_mult,
				cash = $wallet,
				cspent = $total_spent
			WHERE
				id = 1;           


		   SET $click_mult = (select clickmult from click where active=1),
			   $current_thresh = (select thresh from click where active=1);
           SET $buyclick_cnt  = (select floor($total_cash/($click_mult*$current_thresh))),
			   $buyclick_cost  = (select $buyclick_cnt*($click_mult*$current_thresh));

	-- SUCCESS --
case when $buyclick_cnt >= 1 THEN

               
			update click set cspent = cspent + $buyclick_cost, clickmult = clickmult + 1*$buyclick_cnt, cash = (select concat('$',(format($current_cash,2)))) WHERE active = 1;
			
           SET $total_mult = (select sum($current_time*$current_mult)),
				$current_cash = (select sum($total_tmult-$current_spent)),
                $total_time = (select sum(time) from click where id!=1),
				$total_tmult = (select sum(tmult) from click WHERE id!=1),
				$total_spent = (select sum(cspent) from click WHERE id!=1),
                $total_cash = (select sum($total_tmult-$total_spent)),
                $wallet = CONCAT('$',(FORMAT($total_cash,2))),
                $system = concat('Purchase successful. ',format($buyclick_cnt,0),' additional click(s) for $',(select format(sum($buyclick_cost),2)),'.');
            
			UPDATE click 
SET 
    time = $total_time,
    tmult = $total_mult,
    cash = $wallet,
    cspent = $total_spent
WHERE
    id = 1;           

	-- FAILURE --
when $buyclick_cnt < 1 or $buyclick_cnt is NULL THEN 											
                SET $current_time = (select timestampdiff(second,created_at, current_timestamp()) from click WHERE active=1),
					$current_mult = (select mult from click where active=1),
                    $total_cash = (select sum($total_tmult-$total_spent)),
                    $total_spent = (select sum(cspent) from click WHERE id!=1),
                    $purchase_diff = (select abs($total_cash-(($click_mult*$current_thresh)))),
					$purchase_time = (select $purchase_diff/$current_mult),
					$wallet = CONCAT('$',(select FORMAT($total_cash,2)));
					
                    
                   SET $time_case = (SELECT case 
		
     
   when  $purchase_time >=3600 and $purchase_time <216000 THEN (select time_format(sec_to_time($purchase_time),'%H hours, %i minutes, %S seconds.'))
		WHEN $purchase_time >=60 AND $purchase_time<3600 THEN (select time_format(sec_to_time($purchase_time),'%i minutes, %S seconds.'))
			ELSE (select concat(format($purchase_time,0), ' seconds.')) end);
            -- ELSE '1 minute.' end);
                        
																																																										
                        
		SET $system = concat('It looks like you are short by $',(select format($purchase_diff,2)),'.  Please wait ',$time_case,'...');
 else begin end;
end case;
SELECT 
    CONCAT('$', FORMAT($total_cash, 2)) AS 'cash',
    $system AS '';

end //
delimiter ;	

