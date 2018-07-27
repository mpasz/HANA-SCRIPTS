set schema "TEST_20161207"

delete from "@EP_BIGLABELSNO_TEST" where "DOCENTRY" = 1424;
delete from "@EP_BIGLABELSNO_TEST" where "DOCENTRY" = 1432;
delete from "@EP_BIGLABELSNO_TEST" where "DOCENTRY" = 1433;
delete from "@EP_BIGLABELSNO_TEST" where "DOCENTRY" = 1434;

CALL CT_NUMERACJA_ETYKIET_MALYCH_LPOJ_TEST (1424)
CALL CT_NUMERACJA_ETYKIET_MALYCH_LPOJ_TEST (1432)
CALL CT_NUMERACJA_ETYKIET_MALYCH_LPOJ_TEST (1433)
CALL CT_NUMERACJA_ETYKIET_MALYCH_LPOJ_TEST (1434)

select max("U_LabelNo") from "@CT_NEM"
select * from "@CT_NEM_TEST"
delete from "@CT_NEM_TEST"

select "DocNum" from ODLN where "DocEntry" = 1424 --463

select "DocEntry" from ODLN where "DocNum" = 468 -- 1432
select "DocEntry" from ODLN where "DocNum" = 469 -- 1433
select "DocEntry" from ODLN where "DocNum" = 470 -- 1434

select * from ep_getboxesinformation (1433, 0)
  select "bigBoxQty"  from EP_BIGBOXQTYFROMLINE (1424, 0);
  select "SmallFullBoxQty"  from ep_getboxesinformation (1424, 1)


call "EP_BIGlABELSINFORMATION" (1424 , 1)



		SELECT
           sum( case when floor(T4."U_Volume" / T1."Quantity") = 0 THEN T1."Quantity" / T4."U_Volume" 
                else  floor(T4."U_Volume" / T1."Quantity") END)  AS "bigBoxQty"
		FROM ODLN T0 
			INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry" 
			INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
			LEFT OUTER JOIN "@CT_OPAK_N" T3 ON T2."U_ItemPack" = T3."Code" 
			LEFT OUTER JOIN "@CT_OPAK_P" T4 ON T3."Code" = T4."Code" 
		WHERE T0."DocEntry" = 1424
            AND T1."LineNum" = 0
			AND T2."QryGroup3" = 'Y' 
			AND T2."ItmsGrpCod" NOT IN (157,160) 
			AND T4."U_PackType" LIKE '%ojemn%'; 
			
			
			
			
DROP TABLE "@EP_BIGLABELSNO_TEST"


select * from  "TEST_20161207"."@EP_BIGLABELSNO_TEST"
INSERT INTO "TEST_20161207"."@EP_BIGLABELSNO_TEST"
select "EP_SEQ_NEM".nextval ,'1', '1', '1', '8933' from dummy;


select * from ep_getboxesinformation (1433, 0)

ALTER FUNCTION TEST_20161207.EP_GetBoxesInformation
(
    IN WZ INT,
    IN LINE INT
)
RETURNS TABLE
(
    "SmallFullBoxQty"   INT,
    "QtyInDeficientBox" INT
)
LANGUAGE SQLSCRIPT
AS

    smallBoxSize  INT;
    maxPerPalette INT;
    lineDocQty          INT;
    _ilePelnych     INT;
    _roznica        INT;
    _niepelny       INT;
    _pelneQty		INT;

BEGIN
    select "smallBoxSize" into smallBoxSize from "EP_GET_SmallBoxSize" (:WZ, :LINE);
    select "maxPerPalette" into maxPerPalette  from "EP_GET_SmallBoxSize" (:WZ, :LINE);
    select "LineQty" into lineDocQty from  "TEST_20161207"."EP_GET_LineDocQty"(:WZ, :LINE);

      _ilePelnych := floor(:lineDocQty / :smallBoxSize);
      _pelneQty := (_ilePelnych * :smallBoxSize);
--      _roznica := :maxPerPalette - :lineDocQty;
		_roznica := :lineDocQty - _pelneQty;
--      _niepelny := :smallBoxSize - _roznica;
--		_niepelny := :lineDocQty - _roznica;

return SELECT :_ilePelnych "SmallFullBoxQty" , :_roznica "QtyInDeficientBox" from dummy;  

END;









