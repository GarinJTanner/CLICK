DROP PROCEDURE IF EXISTS autoclick;
DELIMITER //
CREATE PROCEDURE autoclick()

BEGIN
DECLARE $autoclick_cnt,$autoclick_cost,$current_active,$active_switch,$after_purchase,$clickmult,$current_cash,$current_time,$current_spent,$current_mult,$current_tmult,$purchase_cost,$purchase_diff,$purchase_time,$system,$thresh,$time_case,$time_cost,$total_cash,$total_spent,$total_mult,$total_tmult,$total_time,$wallet LONGTEXT; 


	CALL CLICK;
 	-- GLOBAL  
            SET $thresh = (select thresh from click where active = 1),
				$total_time = (select sum(time) from click where id!=1),
				$total_tmult = (select sum(tmult) from click WHERE id!=1),
				$total_spent = (select sum(cspent) from click WHERE id!=1),
                $total_cash = (select sum($total_tmult-$total_spent));
			SET $autoclick_cnt = (select floor($total_cash/($thresh*1000))),
				$autoclick_cost = (select $autoclick_cnt*($thresh*1000));
                
			UPDATE click SET cash = concat('$',format($total_cash,2)), 
                             time = $total_time,
                             tmult = $total_tmult,
                             cspent = $total_spent
                             WHERE id=1;  


	-- SUCCESS --
case when $total_cash >= $autoclick_cost THEN
			update click set cspent = cspent + $autoclick_cost, autoclick = autoclick + 1*$autoclick_cnt, updated_at = current_timestamp, cash = (select concat('$',(format($current_cash,2)))) WHERE active = 1;
			
           SET $total_mult = (select sum($current_time*$current_mult)),
				$current_cash = (select sum($total_tmult-$current_spent)),
                $current_time = (select replace(sum($wallet-$autoclick_cost/$current_mult),'-','')),
                $total_time = (select sum(time) from click where id!=1),
				$total_tmult = (select sum(tmult) from click WHERE id!=1),
				$total_spent = (select sum(cspent) from click WHERE id!=1),
                $total_cash = (select sum($total_tmult-$total_spent)),
                $wallet = CONCAT('$',(FORMAT($total_cash,2))),
                $system = concat('Purchase successful. ',format($autoclick_cnt,0),' additional autoclick(s) for $',(select format(sum($autoclick_cost),2)),'. You will now automatically click every 10 seconds.');
            
			UPDATE click SET time = $total_time, tmult = $total_mult, cash = $wallet, cspent = $total_spent+$autoclick_cost WHERE id=1;           

	-- FAILURE--
when $total_cash<$autoclick_cost THEN 											
                SET $current_time = (select timestampdiff(second,created_at, current_timestamp()) from click WHERE active=1),
					$current_mult = (select mult from click where active=1),
					$time_cost = (select replace(sum($total_cash-$autoclick_cost)/$current_mult,'-','')),
                    $total_cash = (select sum($total_mult-$total_spent)),
                    $total_spent = (select sum(cspent) from click WHERE id!=1),
                    $purchase_cost = (select $autoclick_cost),

                    $purchase_diff = (select sum($purchase_cost-$total_cash)),
					$purchase_time = (select $purchase_diff/$current_mult),
					$wallet = CONCAT('$',(select FORMAT($total_cash,2)));
					
                    
                   SET $time_case = (SELECT case 
		
     
   when  $purchase_time >=3600 and $purchase_time <216000 THEN (select time_format(sec_to_time($purchase_time),'%H hours, %i minutes, %S seconds.'))
		WHEN $purchase_time >=60 AND $purchase_time<3600 THEN (select time_format(sec_to_time($purchase_time),'%i minutes, %S seconds.'))
			ELSE '1 minute.' end);
                        
																																																										
                        
		SET $system = concat('It looks like you are short by $',(select format($purchase_diff,2)),'.  Please wait ',$time_case,'...');
 else begin end;
end case;
select 
		concat(format($autoclick_cost,2)) as 'total cost', concat('$',format($total_cash,2)) as'cash', $system as '';

end //
delimiter ;	
