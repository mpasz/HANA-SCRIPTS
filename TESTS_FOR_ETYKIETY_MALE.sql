CT_NUMERACJA_ETYKIET_MALYCH_LPOJ_TEST (IN WZ INT)

CALL CT_NUMERACJA_ETYKIET_MALYCH_LPOJ_TEST (1424) // dwie linijki 
CALL CT_NUMERACJA_ETYKIET_MALYCH_LPOJ_TEST (1425) // jedna linijka

select * from TEST_20161207."EP_BIGBOXQTY" ()

delete from "@CT_NEM_TEST"

select * from "@CT_NEM_TEST" ORDER BY   "U_LineNum" , "U_LabelNo"

select t1."LineNum" , * from ODLN t0 
            inner join DLN1 t1 on t0."DocEntry" = t1."DocEntry"
where t0."DocNum" = 463 //1424

select t1."LineNum" , * from ODLN t0  
            inner join DLN1 t1 on t0."DocEntry" = t1."DocEntry"
where t0."DocNum" = 464  //1425




call EP_BIGlABELSINFORMATION (1424, 0);