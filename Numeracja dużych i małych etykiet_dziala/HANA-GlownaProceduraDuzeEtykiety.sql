ALTER PROCEDURE EP_NumeracjaEtykietDuzych(IN WZ INT)

language sqlscript  
as

i int;
j int;
k int; 							-- dla pętli dużych etykiet
smallFullBoxQty int ; 			-- ile małych pełnych pojemników dla linijki dokumentu
bigboxqty int;   				-- ile dużych etykiet(palet) dla dokumentu
bigboxqtyline int;				-- ile dużych etykiet (palet) dla linijki dokumentu 
packqtyfromline int;			-- ile pojemników na paletach wysyłamy dla linijki dokumentu
_smallBoxeQtyPerPalette int;	-- ile małych pojemników zmieści się na palecie
_doclines int;					-- mapowanie linijek dokumentu od 0...n
_line int ;						-- linijka dokumentu
_roznica int;					-- 0 - wszystkie pełne w linijce, >0 - ostatni niepełny dla linijki
--_packQtyPerPalette int;		
_licznik int default 0;			-- liczy ile jest palet w  jednej linijce 
_licznik2 int default 0;		-- licznik dużych etykiet -
_maxLine int ;					-- przechowuje ilość dużych etykiet dla linijki - gdy licznik dobije do zmiennej to zatrzymuje inkrementacje

BEGIN

--drop table "#results";					-- dla sprawdzenia wyników inserta

create local temporary table "#results"
(
    "id" int ,
    "id2" int,
    "DocEntry" int ,
    "LineNum" int ,
    "ItemCode" nvarchar(25),
    "NumerEtykiety" int
  
);
/*
create local temporary table "#BigLabelNumbers"   -- dla sprawdzenia jak insert dużych etykiet działa
(
	"LineNum" int,
	"LabelNumber" int,
     "DocEntry" int 
);

*/

-- START  tabela w której jest trzymana renumeracja linijek dokumentu

   create local temporary table "#temp"   
  (
      id int,
      linenum int

   );   
INSERT INTO "#temp"  
          SELECT  -1 +  row_number() over (order by "LineNum") as "ID", "LineNum" as "LineNum" 
          FROM dln1 
          WHERE "DocEntry" = :wz ;

SELECT COUNT("ID") 
INTO _doclines 
FROM "#temp"; -- na koniec zapis ilości linijek do zmiennej

--KONIEC----------------          

--START  - ilość palet dla całego dokumentu

SELECT "bigBoxQty" 
INTO bigboxqty 
FROM ep_bigboxqty (:wz);  

--KONIEC--------------------

--START - pętla dla ilośći linijek

    FOR i IN 0..:_doclines -1  DO

--uzupełniamy zmienne

        SELECT linenum  							  INTO _line 					FROM    "#temp"  WHERE id = :i ; 
        SELECT "SmallFullBoxQty" 					  INTO smallFullBoxQty 			FROM 	ep_getboxesinformation (:wz, :_line);  
        SELECT "PackQty" 							  INTO packqtyfromline 			FROM 	ep_getpackqtyfromdockline (:wz, :_line);  
        SELECT "bigBoxQty" 							  INTO bigboxqtyline 			FROM 	EP_BIGBOXQTYFROMLINE (:wz , :_line);
        SELECT (:packqtyfromline - :smallFullBoxQty ) INTO _roznica 				FROM 	dummy;
		SELECT "SmallBoxeQtyPerPalette" 			  INTO _smallBoxeQtyPerPalette  FROM 	EP_GETPACKQTYPERPALETTE (:wz, :_line); 
        --select (:packqtyfromline / :bigboxqtyline) INTO _packQtyPerPalette from dummy;


--generujemy numery duzych etykiet i wpisujemy je do tabeli pomocniczej   

	FOR k IN 0..:bigboxqtyline DO
		INSERT INTO "TEST_20161207"."@EP_BIGLABELSNO_TEST"
			SELECT
				"EP_SEQ_NEM".nextval as "ID"
				,:_licznik2 as "Number"
				,:wz as "DocEntry"
				,:i as "LineNum"
				,(select max("LABELNO") from "TEST_20161207"."@EP_BIGLABELSNO_TEST") + 1 as "LabelNumber"
			FROM dummy;	
			_licznik2 = :_licznik2 + 1;
	END FOR;

-- and "NUMBER" = :_licznik
--KONIEC 

--zmienna dla licznika - nie wychodzi po za rozmiar
	SELECT count("NUMBER") INTO _maxLine 
	FROM  "TEST_20161207"."@EP_BIGLABELSNO_TEST" 
	WHERE "DOCENTRY" = :wz ;
		--AND "LINENUM" = :_line;  
--KONIEC 
	

INSERT INTO "@EP_NED_TEST"
--INSERT INTO "#results"

--START - SELECT DO DEBUGOWANIA
--select :_licznik as "Licznik", :i as "i" , :_line as "Line" , :_maxLine as "maxLine"  from dummy;
--end

SELECT
	"EP_SEQ_NEM".nextval ,
	"EP_SEQ_NEM".nextval ,
	G0."DocEntry",
	G0."LineNum",
	G0."ItemCode", 
	(select "LABELNO" from "@EP_BIGLABELSNO_TEST" where "DOCENTRY" = :wz and "NUMBER" = :_licznik) as "NumeEtykiety" 
FROM 
 (  SELECT	
      t0."DocEntry", t1."LineNum", t1."ItemCode", t1."PackQty", t1."Quantity",  row_number() over(order by t1."LineNum")+ :j  as "RowNumber" 
    FROM odln t0
             inner join dln1 t1 on t0."DocEntry" = t1."DocEntry"
             inner join oitm t2 on t1."ItemCode" = t2."ItemCode"
    WHERE t0."DocEntry" =:wz 
            and t1."LineNum" = :_line
            and t2."ItmsGrpCod" not in (157,160)
  ) G0
 ORDER BY "LineNum";
          
		IF(:_licznik < :_maxLine) then 
	   		 _licznik := :_licznik + 1;
	   	END IF;
  		
 END FOR;

select * from "#results" ;
 
 --jeszcze usuniemy tabele tymczasową
IF (:_doclines > 0) THEN
    DROP TABLE "#temp";
END IF;
 
drop table "#results";
 
 END;
 
 
 
 
 
 

                        
   