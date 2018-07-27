CREATE FUNCTION TEST_20161207.EP_BIGBOXQTYFROMLINE (IN WZ INT , IN LINE INT)
RETURNS TABLE
(
	"bigBoxQty" INT
)
LANGUAGE SQLSCRIPT
AS
	BEGIN RETURN
		SELECT
           sum( case when floor(T4."U_Volume" / T1."Quantity") = 0 THEN T1."Quantity" / T4."U_Volume" 
                else  floor(T4."U_Volume" / T1."Quantity") END)  AS "bigBoxQty"
		FROM ODLN T0 
			INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry" 
			INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
			LEFT OUTER JOIN "@CT_OPAK_N" T3 ON T2."U_ItemPack" = T3."Code" 
			LEFT OUTER JOIN "@CT_OPAK_P" T4 ON T3."Code" = T4."Code" 
		WHERE T0."DocEntry" = :WZ
            AND T1."LineNum" = :LINE
			AND T2."QryGroup3" = 'Y' 
			AND T2."ItmsGrpCod" NOT IN (157,160) 
			AND T4."U_PackType" LIKE '%ojemn%'; 
	 END;