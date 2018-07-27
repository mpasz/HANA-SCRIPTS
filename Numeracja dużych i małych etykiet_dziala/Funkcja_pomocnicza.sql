CREATE FUNCTION TEST_20161207.EP_GetBoxesInformation
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