CREATE procedure EP_NumeracjaEtykietMalychLPoj(in wz int)

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

begin

/*drop table "#results";					-- dla sprawdzenia wyników inserta

create local temporary table "#results"
(
    "id" int ,
    "id2" int,
    "DocEntry" int ,
    "LineNum" int ,
    "ItemCode" nvarchar(25),
    "NumerEtykiety" int,
    "IlośćPojemnik" int
  
);

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

    FOR i IN 0..:_doclines -1 DO

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
--KONIEC 

--zmienna dla licznika - nie wychodzi po za rozmiar
	SELECT count("NUMBER") INTO _maxLine 
	FROM  "TEST_20161207"."@EP_BIGLABELSNO_TEST" 
	WHERE "DOCENTRY" = :wz AND "LINENUM" = :_line;  
--KONIEC 
	

--teraz do pętli dla małyj pojemników
        FOR j IN 0..:packqtyfromline -1 DO

--START - SELECT DO DEBUGOWANIA
				 --select :_licznik as "Licznik", :j as "J" , :smallFullBoxQty as "smallFullBoxQty" , :_roznica as "roznica", :_line as "Line" , :_maxLine as "maxLine"  from dummy; 
--END

            INSERT INTO "@CT_NEM_TEST"
            --INSERT INTO "#results"
                    
                        SELECT
                             "EP_SEQ_NEM".nextval ,
                             "EP_SEQ_NEM".nextval ,
							h1."DocEntry", h1."LineNum", h1."ItemCode", 
							(select "LABELNO" from "@EP_BIGLABELSNO_TEST" where "DOCENTRY" = :wz and "NUMBER" = :_licznik) as "NumeEtykiety" ,
                            case when (:j <= :smallFullBoxQty and :_roznica =0) then h1."PojemnoscPojemnika"
                                    else CASE WHEN (:_roznica > 0 and :j < :smallFullBoxQty) THEN  h1."PojemnoscPojemnika"
                                         else CASE WHEN (:_roznica > 0 and :j = :smallFullBoxQty) THEN (select "QtyInDeficientBox" from ep_getboxesinformation (:wz, :_line)) 
                            end
                          end 
                     end as "IlośćPojemnik"
                FROM	
                     (
                        
                        SELECT --zwraca liczbę etykie duzych (palet) dla linii WZ i lineid kolejnej palety
                                    g0."DocEntry", g0."LineNum", g0."ItemCode",
                                    g0."Quantity",
                                    --, (select max("U_LabelNo") from "@CT_NEM") + row_number()over(order by g0."LineNum") as "PalNo"
                                    g0."RowNumber"
                                    ,''
                                FROM 
                                    (
                                        SELECT	
                                        t0."DocEntry", t1."LineNum", t1."ItemCode", t1."PackQty", t1."Quantity",  row_number() over(order by t1."LineNum")+ :j  as "RowNumber" 
                                        FROM odln t0
                                        		inner join dln1 t1 on t0."DocEntry" = t1."DocEntry"
                                       			 inner join oitm t2 on t1."ItemCode" = t2."ItemCode"
                                        WHERE t0."DocEntry" =:wz 
                                                and t1."LineNum" = :_line
                                                and t2."ItmsGrpCod" not in (157,160)
                                    ) g0
                         

                        --            (
                        --            select top 1000 --tabela wykorzystywana do wybrania odpowiedniej ilości linii
                        --               row_number()over() as "Licznik"
                        --                from oitm
                        --            ) g1

                        --        where 1 >= g1."Licznik" --warunek wybrania odpowiedniej ilości linii
                                order by "LineNum"
                            ) h0
                                inner join 
                     (SELECT  --zwraca liczbę etykie malych (pojemnik) dla linii WZ i lineid kolejnego pojemnika
                                    g0."DocEntry", g0."LineNum", g0."ItemCode", g0."PackQty"
                                    , row_number()over(partition by g0."LineNum" order by g0."LineNum") as "PojNo"
                                    ,g0."PojemnoscPojemnika" , g0."MaxNaPalete" 
                                FROM 
                                    (
                                          SELECT
                                            t0."DocEntry", t1."LineNum", t1."ItemCode", t1."PackQty"
                                            ,(t4."U_Volume" / t4."U_QtyInPack") "PojemnoscPojemnika"
                                            ,t4."U_Volume" "MaxNaPalete"
                                          FROM odln t0
                                          		 inner join dln1 t1 on t0."DocEntry" = t1."DocEntry"
                                          		 inner join oitm t2 on t1."ItemCode" = t2."ItemCode"
                                           		 left outer join "@CT_OPAK_N" t3 on t2."U_ItemPack" = t3."Code"
                                           		 left outer join "@CT_OPAK_P" t4 on t3."Code" = t4."Code"
                                          WHERE t0."DocEntry" = :wz 
                                                    and t1."LineNum" = :_line
                                                    and t2."QryGroup3" = 'Y' 
                                                    and t2."ItmsGrpCod" not in (157,160)  
                                                    and t4."U_PackType" like '%ojemn%'

                                    ) g0

                    --  (select top 1000
                   --     row_number()over() as "Licznik" --tabela wykorzystywana do wybrania odpowiedniej ilości linii
                   --    from oitm) g1
                  --   where 1 >= g1."Licznik" --warunek wybrania odpowiedniej ilości linii
                     order by "LineNum") h1 on h0."DocEntry" = h1."DocEntry" and h0."LineNum" = h1."LineNum";
                     
              IF (:j = :_smallBoxeQtyPerPalette -1) then 
              	_licznik := :_licznik + 1;
              END IF;
			
			-- jeśli więcej palet w jednej linijce musimy zwiększyć ilość pojemników w palecie
              IF (:j > :_smallBoxeQtyPerPalette -1 ) then  
              	_smallBoxeQtyPerPalette := :_smallBoxeQtyPerPalette * 2;
              END IF;
        
         END FOR; --wychodzimy z petli dla malych pojemników
         
         	IF(:_licznik < :_maxLine) then 
	   		 _licznik := :_licznik + 1;
	   		END IF;
	   		
END FOR; -- wychodzimy z pętli dla linijek dokumentu 

--select * from "TEST_20161207"."@EP_BIGLABELSNO_TEST";
--select * from "#results" ;

--jeszcze usuniemy tabele tymczasową
IF (:_doclines > 0) THEN
    DROP TABLE "#temp";
 END IF;

--drop table "#results";
--drop table "#BigLabelNumbers";

END;