DROP TYPE xml_array;
CREATE OR REPLACE TYPE        col_obj AS OBJECT

(                                   /*Special use in WEB_SERVS_API*/
                                    
 col_name            varchar2(4000),    
 col_value           varchar2(4000),
      
CONSTRUCTOR
FUNCTION col_obj
RETURN SELF AS RESULT ) final;
--
-- col_obj  (Type Body) 
--
/
DROP TYPE BODY COL_OBJ;

CREATE OR REPLACE TYPE BODY        col_obj AS
CONSTRUCTOR FUNCTION col_obj
RETURN SELF AS RESULT  AS
BEGIN 
RETURN; 
END; 
end;
/



CREATE OR REPLACE TYPE xml_array AS VARRAY(1000) OF col_obj;
/

