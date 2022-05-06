-- DEPLOY --

drop procedure if exists restart;

DELIMITER //
CREATE PROCEDURE restart()
BEGIN


drop table if exists click; 
create table click 
(id BIGINT UNSIGNED auto_increment primary key,
	clicks LONGTEXT,
    cash LONGTEXT,
    time LONGTEXT,
    mult LONGTEXT,
    tmult LONGTEXT,
    cspent LONGTEXT,
	created_at datetime default current_timestamp,
    updated_at datetime,
    level LONGTEXT,
    clickmult LONGTEXT,
    autoclick LONGTEXT,
    thresh LONGTEXT,
    thresh_init SMALLINT,
active SMALLINT DEFAULT 0)
auto_increment=2 engine=myisam; 

					
                  
insert into click (id,clicks,cash,time,tmult,cspent)								  							 		 values (1,0,'$0.00',0,0,0);
insert into click (id,clicks,cash,time,mult,tmult,cspent,level,clickmult,autoclick,thresh,thresh_init,active,created_at) values (2,0,'$0.00',0,1,0,0,1,1,1,1,0,1,current_timestamp);
insert into click (id,clicks,cash,time,mult,tmult,cspent,level,clickmult,autoclick,thresh,thresh_init) 		 			 values (3,0,'$0.00',0,1,0,0,1,1,1,1,0);  



select 'CLICK RESTARTED' AS '';
end //
DELIMITER ;
call restart; 							


-- CLICK --
DROP PROCEDURE IF EXISTS click;
DELIMITER //
CREATE PROCEDURE click()
begin 
DECLARE $active,$active_switch,$autoclick,$autoclickamount,$clicks,$clicker,$click_count,$clickmult,$current_cash,$current_level,$current_mult,$current_spent,$current_time,$current_tmult,$next_level,$system,$thresh,$thresh1,$thresh2,$thresh3,$thresh4,$thresh_init,$thresh_next,$title,$total_cash,$total_spent,$total_time,$total_tmult LONGTEXT;


-- ACTIVE
			SET	$autoclick = (select format(sum((select timestampdiff(second,updated_at,current_timestamp()) from click WHERE active=1)/10),0)),
				$autoclickamount = (select autoclick from click where active=1),
				$clickmult = (select clickmult from click where active=1),
				$current_time = (select timestampdiff(second,created_at,current_timestamp()) from click WHERE active=1),
                $current_mult = (select mult from click WHERE active=1),
                $current_tmult = $current_time*$current_mult,
                $current_spent = (select cspent from click where active=1),
				$current_cash = $current_tmult-$current_spent,
                $current_level = (select level from click where active=1),
                $next_level = (select level + 1 from click where active=1);
                
                
CASE WHEN $autoclick >1 THEN

	SET $autoclick = $autoclick*$autoclickamount,
		$clicker = ($clickmult*$autoclick);
	UPDATE click SET updated_at = current_timestamp where active=1;

	 WHEN $autoclick <1 or $autoclick is null THEN
	SET $clicker = ($clickmult);

					ELSE BEGIN END;
					END CASE;
                
                
       -- click         
			UPDATE click SET clicks = clicks +1*$clicker, 
							 clickmult = $clickmult,
						     time = $current_time, 
                             tmult = $current_tmult,
                             cash = concat('$',format($current_cash,2))
                             WHERE active = 1;
            
            
-- GLOBAL
            SET $active = (select id from click WHERE active=1),
				$active_switch = (select id from click WHERE id>$active order by id desc limit 1),
				$clicks = (SELECT sum(clicks) from click where id!=1),
                $click_count = (select clicks from click where active=1),
                $thresh = (select thresh from click where active=1),
				$thresh1 = (select sum($THRESH*25)),
				$thresh2 = (select sum($THRESH*50)),
                $thresh3 = (select sum($THRESH*75)),
                $thresh4 = (select sum($THRESH*100)),
				$thresh_init = (select thresh_init from click where id=$active),
                $thresh_next = (select thresh *10 from click where id=$active),
				$total_time = (select sum(time) from click where id!=1),
				$total_tmult = (select sum(tmult) from click WHERE id!=1),
				$total_spent = (select sum(cspent) from click WHERE id!=1),
                $total_cash = (select sum($total_tmult-$total_spent));
                
			UPDATE click SET clicks = $clicks, 
							 cash = concat('$',format($total_cash,2)), 
                             time = $total_time,
                             tmult = $total_tmult,
                             cspent = $total_spent
                             WHERE id=1;  

set $autoclick = (select autoclick from click where active=1);


						   
	CASE WHEN (select sum(clicks) from click where id!=1)>= $thresh4 and $thresh_init = 3 THEN
                UPDATE click SET clickmult = $clickmult, autoclick = $autoclick, created_at = current_timestamp, THRESH = $thresh_next, level = $next_level, mult = $current_mult*2.5, thresh_init = 0, active=1 WHERE id=$active_switch;
                SET $system = 'LEVEL UP!';
                insert into click (clicks,cash,time,tmult,mult,cspent,level,clickmult,thresh_init,thresh) values (0,'$0.00',0,0,$current_mult,0,$next_level,$clickmult,0,$thresh_next);
                UPDATE click SET active=0 WHERE id=$active;
                
               SET $thresh_init = (select thresh_init from click where id=$active_switch);

                
		WHEN (select sum(clicks) from click where id!=1) >= $thresh3 and $thresh_init = 2 THEN
				SET $system = '2.5x MULTIPLIER';
                insert into click (clicks,cash,time,tmult,mult,cspent,level,clickmult,thresh_init,thresh) values (0,'$0.00',0,0,$current_mult,0,$current_level,$clickmult,0,$thresh);
				UPDATE click SET clickmult = $clickmult, autoclick = $autoclick, created_at = current_timestamp, mult = $current_mult*2.5,thresh_init = 3, active=1 WHERE id=$active_switch;
                UPDATE click SET active=0 WHERE id=$active;
               SET $thresh_init = (select thresh_init from click where id=$active_switch);
                
		WHEN (select sum(clicks) from click where id!=1) >= $thresh2 and $thresh_init = 1 THEN
				SET $system = (select '2.5x MULTIPLIER'); 
                insert into click (clicks,cash,time,tmult,mult,cspent,level,clickmult,thresh_init,thresh) values (0,'$0.00',0,0,$current_mult,0,$current_level,$clickmult,0,$thresh);
				UPDATE click SET clickmult = $clickmult, autoclick = $autoclick, created_at = current_timestamp, mult = $current_mult*2.5,thresh_init = 2, active=1 WHERE id=$active_switch;
                UPDATE click SET active=0 WHERE id=$active;
                SET $thresh_init = (select thresh_init from click where id=$active_switch);
            
                
		WHEN (select sum(clicks) from click where id!=1) >= $thresh1 and $thresh_init = 0 THEN
				insert into click (clicks,cash,time,tmult,mult,cspent,level,clickmult,thresh_init,thresh) values (0,'$0.00',0,0,$current_mult,0,$current_level,$clickmult,0,$thresh);
				UPDATE click SET clickmult = $clickmult, autoclick = $autoclick, created_at = current_timestamp, mult = $current_mult*2.5,thresh_init = 1, active = 1 WHERE id=$active_switch;	
                UPDATE click SET active=0 WHERE id=$active;
                SET $system = (select '2.5x MULTIPLIER');
                SET $thresh_init = (select thresh_init from click where id=$active_switch);
			ELSE BEGIN END;
            END CASE;
       
case										
		WHEN length((concat('$',format($total_cash,2))))>=409 																THEN		 SET $title = 			('Centillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=405 AND length((concat('$',format($total_cash,2)))) < 		409 THEN 		 SET $title = 			('Novemnonagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=401 AND length((concat('$',format($total_cash,2)))) < 		405 THEN 		 SET $title = 			('Octononagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=397 AND length((concat('$',format($total_cash,2)))) < 		401 THEN 		 SET $title = 			('Septennonagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=393 AND length((concat('$',format($total_cash,2)))) < 		397 THEN 		 SET $title = 			('Sexnonagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=389 AND length((concat('$',format($total_cash,2)))) < 		393 THEN 		 SET $title = 			('Quinnonagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=385 AND length((concat('$',format($total_cash,2)))) < 		389 THEN 		 SET $title = 			('Quattuornonagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=381 AND length((concat('$',format($total_cash,2)))) < 		385 THEN 		 SET $title = 			('Trenonagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=377 AND length((concat('$',format($total_cash,2)))) < 		381 THEN 		 SET $title = 			('Duononagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=373 AND length((concat('$',format($total_cash,2)))) < 		377 THEN 		 SET $title = 			('Unnonagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=369 AND length((concat('$',format($total_cash,2)))) < 		373 THEN 		 SET $title = 			('Nonagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=365 AND length((concat('$',format($total_cash,2)))) < 		369 THEN 		 SET $title = 			('Novemoctogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=361 AND length((concat('$',format($total_cash,2)))) < 		365 THEN 		 SET $title = 			('Octooctogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=357 AND length((concat('$',format($total_cash,2)))) < 		361 THEN 		 SET $title = 			('Septenoctogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=353 AND length((concat('$',format($total_cash,2)))) < 		357 THEN 		 SET $title = 			('Sexoctogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=349 AND length((concat('$',format($total_cash,2)))) < 		353 THEN 		 SET $title = 			('Quinoctogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=345 AND length((concat('$',format($total_cash,2)))) < 		349 THEN 		 SET $title = 			('Quattuoroctogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=341 AND length((concat('$',format($total_cash,2)))) < 		345 THEN 		 SET $title = 			('Treoctogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=337 AND length((concat('$',format($total_cash,2)))) < 		341 THEN 		 SET $title = 			('Duooctogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=333 AND length((concat('$',format($total_cash,2)))) < 		337 THEN 		 SET $title = 			('Unoctogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=329 AND length((concat('$',format($total_cash,2)))) < 		333 THEN 		 SET $title = 			('Octogintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=325 AND length((concat('$',format($total_cash,2)))) < 		329 THEN 		 SET $title = 			('Novemseptuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=321 AND length((concat('$',format($total_cash,2)))) < 		325 THEN 		 SET $title = 			('Octoseptuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=317 AND length((concat('$',format($total_cash,2)))) < 		321 THEN 		 SET $title = 			('Septenseptuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=313 AND length((concat('$',format($total_cash,2)))) < 		317 THEN 		 SET $title = 			('Sexseptuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=309 AND length((concat('$',format($total_cash,2)))) < 		313 THEN 		 SET $title = 			('Quinseptuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=305 AND length((concat('$',format($total_cash,2)))) < 		309 THEN 		 SET $title = 			('Quattuorseptuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=301 AND length((concat('$',format($total_cash,2)))) < 		305 THEN 		 SET $title = 			('Treseptuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=297 AND length((concat('$',format($total_cash,2)))) < 		301 THEN 		 SET $title = 			('Duoseptuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=293 AND length((concat('$',format($total_cash,2)))) < 		297 THEN 		 SET $title = 			('Unseptuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=289 AND length((concat('$',format($total_cash,2)))) < 		293 THEN 		 SET $title = 			('Septuagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=285 AND length((concat('$',format($total_cash,2)))) < 		289 THEN 		 SET $title = 			('Novemsexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=281 AND length((concat('$',format($total_cash,2)))) < 		285 THEN 		 SET $title = 			('Octosexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=277 AND length((concat('$',format($total_cash,2)))) < 		281 THEN 		 SET $title = 			('Septensexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=273 AND length((concat('$',format($total_cash,2)))) < 		277 THEN 		 SET $title = 			('Sexsexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=269 AND length((concat('$',format($total_cash,2)))) < 		273 THEN 		 SET $title = 			('Quinsexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=265 AND length((concat('$',format($total_cash,2)))) < 		269 THEN 		 SET $title = 			('Quattuorsexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=261 AND length((concat('$',format($total_cash,2)))) < 		265 THEN 		 SET $title = 			('Tresexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=257 AND length((concat('$',format($total_cash,2)))) < 		261 THEN 		 SET $title = 			('Duosexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=253 AND length((concat('$',format($total_cash,2)))) < 		257 THEN 		 SET $title = 			('Unsexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=249 AND length((concat('$',format($total_cash,2)))) < 		253 THEN 		 SET $title = 			('Sexagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=245 AND length((concat('$',format($total_cash,2)))) < 		249 THEN 		 SET $title = 			('Novemquinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=241 AND length((concat('$',format($total_cash,2)))) < 		245 THEN 		 SET $title = 			('Octoquinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=237 AND length((concat('$',format($total_cash,2)))) < 		241 THEN 		 SET $title = 			('Septenquinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=233 AND length((concat('$',format($total_cash,2)))) < 		237 THEN 		 SET $title = 			('Sexquinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=229 AND length((concat('$',format($total_cash,2)))) < 		233 THEN 		 SET $title = 			('Quinquinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=225 AND length((concat('$',format($total_cash,2)))) < 		229 THEN 		 SET $title = 			('Quattuorquinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=221 AND length((concat('$',format($total_cash,2)))) < 		225 THEN 		 SET $title = 			('Trequinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=217 AND length((concat('$',format($total_cash,2)))) < 		221 THEN 		 SET $title = 			('Duoquinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=213 AND length((concat('$',format($total_cash,2)))) < 		217 THEN 		 SET $title = 			('Unquinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=209 AND length((concat('$',format($total_cash,2)))) < 		213 THEN 		 SET $title = 			('Quinquagintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=205 AND length((concat('$',format($total_cash,2)))) < 		209 THEN 		 SET $title = 			('Novemquadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=201 AND length((concat('$',format($total_cash,2)))) < 		205 THEN 		 SET $title = 			('Octoquadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=197 AND length((concat('$',format($total_cash,2)))) < 		201 THEN 		 SET $title = 			('Septenquadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=193 AND length((concat('$',format($total_cash,2)))) < 		197 THEN 		 SET $title = 			('Sexquadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=189 AND length((concat('$',format($total_cash,2)))) < 		193 THEN 		 SET $title = 			('Quinquadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=185 AND length((concat('$',format($total_cash,2)))) < 		189 THEN 		 SET $title = 			('Quattuorquadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=181 AND length((concat('$',format($total_cash,2)))) < 		185 THEN 		 SET $title = 			('Trequadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=177 AND length((concat('$',format($total_cash,2)))) < 		181 THEN 		 SET $title = 			('Duoquadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=173 AND length((concat('$',format($total_cash,2)))) < 		177 THEN 		 SET $title = 			('Unquadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=169 AND length((concat('$',format($total_cash,2)))) < 		173 THEN 		 SET $title = 			('Quadragintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=165 AND length((concat('$',format($total_cash,2)))) < 		169 THEN 		 SET $title = 			('Novemtrigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=161 AND length((concat('$',format($total_cash,2)))) < 		165 THEN 		 SET $title = 			('Octotrigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=157 AND length((concat('$',format($total_cash,2)))) < 		161 THEN 		 SET $title = 			('Septentrigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=153 AND length((concat('$',format($total_cash,2)))) < 		157 THEN 		 SET $title = 			('Sextrigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=149 AND length((concat('$',format($total_cash,2)))) < 		153 THEN 		 SET $title = 			('Quintrigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=145 AND length((concat('$',format($total_cash,2)))) < 		149 THEN 		 SET $title = 			('Quattuortrigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=141 AND length((concat('$',format($total_cash,2)))) < 		145 THEN 		 SET $title = 			('Tretrigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=137 AND length((concat('$',format($total_cash,2)))) < 		141 THEN 		 SET $title = 			('Duotrigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=133 AND length((concat('$',format($total_cash,2)))) < 		137 THEN 		 SET $title = 			('Untrigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=129 AND length((concat('$',format($total_cash,2)))) < 		133 THEN 		 SET $title = 			('Trigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=125 AND length((concat('$',format($total_cash,2)))) < 		129 THEN 		 SET $title = 			('Novemvigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=121 AND length((concat('$',format($total_cash,2)))) < 		125 THEN 		 SET $title = 			('Octovigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=117 AND length((concat('$',format($total_cash,2)))) < 		121 THEN 		 SET $title = 			('Septenvigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=113 AND length((concat('$',format($total_cash,2)))) < 		117 THEN 		 SET $title = 			('Sexvigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=109 AND length((concat('$',format($total_cash,2)))) < 		113 THEN 		 SET $title = 			('Quinvigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=105 AND length((concat('$',format($total_cash,2)))) < 		109 THEN 		 SET $title = 			('Quattuorvigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=101 AND length((concat('$',format($total_cash,2)))) < 		105 THEN 		 SET $title = 			('Trevigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=97 AND length((concat('$',format($total_cash,2)))) < 		101 THEN 		 SET $title = 			('Duovigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=93 AND length((concat('$',format($total_cash,2)))) < 		97 THEN 		 SET $title = 			('Unvigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=89 AND length((concat('$',format($total_cash,2)))) < 		93 THEN 		 SET $title = 			('Vigintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=85 AND length((concat('$',format($total_cash,2)))) < 		89 THEN 		 SET $title = 			('Novemdecillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=81 AND length((concat('$',format($total_cash,2)))) < 		85 THEN 		 SET $title = 			('Octodecillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=77 AND length((concat('$',format($total_cash,2)))) < 		81 THEN 		 SET $title = 			('Septendecillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=73 AND length((concat('$',format($total_cash,2)))) < 		77 THEN 		 SET $title = 			('Sexdecillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=69 AND length((concat('$',format($total_cash,2)))) < 		73 THEN 		 SET $title = 			('Quindecillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=65 AND length((concat('$',format($total_cash,2)))) < 		69 THEN 		 SET $title = 			('Quattuordecillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=61 AND length((concat('$',format($total_cash,2)))) < 		65 THEN 		 SET $title = 			('Tredecillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=57 AND length((concat('$',format($total_cash,2)))) < 		61 THEN 		 SET $title = 			('Duodecillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=53 AND length((concat('$',format($total_cash,2)))) < 		57 THEN 		 SET $title = 			('Undecillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=49 AND length((concat('$',format($total_cash,2)))) < 		53 THEN 		 SET $title = 			('Decillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=45 AND length((concat('$',format($total_cash,2)))) < 		49 THEN 		 SET $title = 			('Nonillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=41 AND length((concat('$',format($total_cash,2)))) < 		45 THEN 		 SET $title = 			('Octillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=37 AND length((concat('$',format($total_cash,2)))) < 		41 THEN 		 SET $title = 			('Septillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=33 AND length((concat('$',format($total_cash,2)))) < 		37 THEN 		 SET $title = 			('Sextillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=29 AND length((concat('$',format($total_cash,2)))) < 		33 THEN 		 SET $title = 			('Quintillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=25 AND length((concat('$',format($total_cash,2)))) < 		29 THEN 		 SET $title = 			('Quadrillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=21 AND length((concat('$',format($total_cash,2)))) < 		25 THEN 		 SET $title = 			('Trillionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=17 AND length((concat('$',format($total_cash,2)))) < 		21 THEN 		 SET $title = 			('Billionaire');	
		WHEN length((concat('$',format($total_cash,2))))>=13 AND length((concat('$',format($total_cash,2)))) < 		17 THEN 		 SET $title = 			('Millionaire');	
        WHEN length((concat('$',format($total_cash,2))))<13 							       THEN 		 SET $title = (' ');



	else begin end; end case;
      

	SET $current_level = ( select level from click where active=1),
		$current_mult = ( select mult from click where active=1);
		-- UI				
select  $title as'',concat('$',format($total_cash,2)) as cash, concat('$', format($current_mult,2)) as CPS, $clicks as clicks, $current_level as level, $system as message;

 END //
 delimiter ;
 
 
