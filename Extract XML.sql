
     select *                                                                                                     
     from xml_table  l                                                                                                            
     , XMLTABLE ('//employees'                                                                                       
                               PASSING  ( (l.XML_COL) )
                               COLUMNS 
                               employee_name     varchar2(2000) PATH './employees/employee_name',
                               location_id       varchar2(2000) PATH './employees/location_id',
                               ar                varchar2(2000) PATH './ar',
                               fr                varchar2(2000) PATH './fr',                                                              
                               gb                varchar2(2000) PATH './gb'
                               ) xml_tab
     ;

select t.XML_COL
,      (t.XML_COL).extract('//employee_name/text()').getStringVal() empname
,      (t.XML_COL).extract('//location_id/text()').getStringVal() loc_id
,      (t.XML_COL).extract('//ar/text()').getStringVal() ar
,      (t.XML_COL).extract('//fr/text()').getStringVal() fr
,      (t.XML_COL).extract('//gb/text()').getStringVal() gb
 from xml_table t
 ;
 
 UPDATE xml_table 
 SET XML_COL =
   UPDATEXML((XML_COL),
   '//employees/employee_name/text()','Abdullah Zabarah')
   WHERE rownum = 1;



UPDATE xml_table 
SET XML_COL =
   DELETEXML(XML_COL, 
   '//languages/fr')
   WHERE rownum = 1;


UPDATE xml_table SET XML_COL =
   INSERTXMLAFTER(XML_COL,
   '//languages/ar',
   XMLType('<fr>LAY</fr>'))
   WHERE rownum = 1;
   

UPDATE xml_table SET XML_COL =
   INSERTCHILDXML(XML_COL,
   '//xml/languages','gb',
   XMLType('<gb>HHHH</gb>'))
   WHERE rownum = 1;   
--
--DBMS_XMLSTORE