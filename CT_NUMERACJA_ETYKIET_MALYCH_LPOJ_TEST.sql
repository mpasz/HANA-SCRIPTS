ALTER PROCEDURE CT_NUMERACJA_ETYKIET_MALYCH_LPOJ_TEST (IN WZ INT)

LANGUAGE SQLSCRIPT  
AS

i INT;
j INT;
ilePelnych INT ;
bigBoxQty INT;
smallFullBoxQty INT;
smallIncopleteBoxQty INT;
packQtyFromDock INT;
_docLines INT;
_autoincrementID INT;

BEGIN

select "#TEMP_ID".nextval into _autoincrementID  from dummy;

   create local temporary table "#temp" 
  (
       ID INT,
       LineNum INT 
   );

        INSERT INTO "#temp"  VALUES(
            :_autoincrementID, select "LineNum" from DLN1 where "DocEntry" = :WZ );
        

  //  select count(*) INTO _docLines from "#temp";
    
//select "SmallFullBoxQty" INTO ilePelnych from "EP_GetBoxesInformation" (:WZ, 5);
//select "SmallFullBoxQty" INTO ilePelnych from "EP_GetBoxesInformation" (:WZ, 6);  

//select ilePelnych from dummy;


FOR i IN 1..:_docLines DO 
    
    select "SmallFullBoxQty" INTO ilePelnych from "EP_GetBoxesInformation" (:WZ, (select "ID" from "#temp" where "ID" = :i));
	select * INTO bigBoxQty from "TEST_20161207"."EP_BigBoxQty" (:WZ);
	select * INTO smallFullBoxQty from "TEST_20161207"."EP_SmallFullBoxQty" (:WZ);
	select * INTO packQtyFromDock from "TEST_20161207"."EP_GetPackQtyFromDock" (:WZ);

select ilePelnych , bigBoxQty, smallFullBoxQty, packQtyFromDock from dummy;
drop table "#temp";
/*
    FOR j IN 1..:packQtyFromDock DO

    --INSERT INTO "@CT_NEM_TEST"

                SELECT
                    --RIGHT(CONCAT('0000000000',(SELECT MAX("Code") FROM "@CT_NEM") + ROW_NUMBER()OVER(ORDER BY H1."LineNum", H0."PalNo", H1."PojNo")),10),
                    --RIGHT(CONCAT('0000000000',(SELECT MAX("Code") FROM "@CT_NEM") + ROW_NUMBER()OVER(ORDER BY H1."LineNum", H0."PalNo", H1."PojNo")),10),
                     "EP_SEQ_NEM".nextval ,
                     "EP_SEQ_NEM".nextval ,
                    H1."DocEntry", H1."LineNum", H1."ItemCode", 
                    (SELECT MAX("U_LabelNo") FROM "@CT_NEM") + ROW_NUMBER()OVER(ORDER BY H1."LineNum", H0."PalNo", H1."PojNo") AS "NumerEtykiety",
                    CASE WHEN :j <= smallFullBoxQty THEN H1."PojemnoscPojemnika"
                        ELSE (select "QtyInDeficientBox" from "EP_GetBoxesInformation" (:WZ, :_docLines) ) END AS "IloœæPojemnik"

        FROM	
             (SELECT --zwraca liczbê etykie duzych (palet) dla linii WZ i lineid kolejnej palety
                            G0."DocEntry", G0."LineNum", G0."ItemCode",
                            G0."Quantity", ROW_NUMBER()OVER(ORDER BY G0."LineNum") AS "PalNo"
                            ,''
                        FROM 
                            (SELECT	
                                T0."DocEntry", T1."LineNum", T1."ItemCode", T1."PackQty", T1."Quantity", '' 
                                FROM ODLN T0
                                INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry"
                                INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
                                WHERE T0."DocEntry" =:WZ AND T2."ItmsGrpCod" NOT IN (157,160)
                            ) G0,

                            (
                            SELECT TOP 1000 --tabela wykorzystywana do wybrania odpowiedniej iloœci linii
                                ROW_NUMBER()OVER() AS "Licznik"
                                FROM OITM
                            ) G1

                        WHERE :bigBoxQty >= G1."Licznik" --warunek wybrania odpowiedniej iloœci linii
                        ORDER BY "LineNum"
                    ) H0
                        INNER JOIN 
             (SELECT  --zwraca liczbê etykie malych (pojemnik) dla linii WZ i lineid kolejnego pojemnika
                            G0."DocEntry", G0."LineNum", G0."ItemCode", G0."PackQty", ROW_NUMBER()OVER(PARTITION BY G0."LineNum" ORDER BY G0."LineNum") AS "PojNo"
                            ,G0."PojemnoscPojemnika" , G0."MaxNaPalete" 
                        FROM 
                            (
                                  SELECT
                                    T0."DocEntry", T1."LineNum", T1."ItemCode", T1."PackQty"
                                    --CEILING((T1."Quantity"/T4."U_Volume")*T4."U_QtyInPack") AS "NumPerMsr"
                                    ,(T4."U_Volume" / T4."U_QtyInPack") "PojemnoscPojemnika"
                                    ,T4."U_Volume" "MaxNaPalete"
                                  FROM ODLN T0
                                   INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry"
                                   INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
                                   LEFT OUTER JOIN "@CT_OPAK_N" T3 ON T2."U_ItemPack" = T3."Code"
                                   LEFT OUTER JOIN "@CT_OPAK_P" T4 ON T3."Code" = T4."Code"
                                  WHERE T0."DocEntry" = :WZ AND T2."QryGroup3" = 'Y' AND T2."ItmsGrpCod" NOT IN (157,160)  AND T4."U_PackType" LIKE '%ojemn%' 
                            ) G0,

              (SELECT TOP 1000
                ROW_NUMBER()OVER() AS "Licznik" --tabela wykorzystywana do wybrania odpowiedniej iloœci linii
               FROM OITM) G1
             WHERE 1 >= G1."Licznik" --warunek wybrania odpowiedniej iloœci linii
             ORDER BY "LineNum") H1 ON H0."DocEntry" = H1."DocEntry" AND H0."LineNum" = H1."LineNum";

        END FOR;*/
   END FOR;

END;




//