-- You may use the dev_env schema in the cloud shared with you  earlier.
-- xml_table is just an example, you may use the targeted schema name and table with the column name as well...
drop table xml_table;
create table xml_table (

id                                    number                   not null,  /*BD_NODE_ID*/
row_version                           integer                  not null,
status                                number                    default 1   not null,
xml_info                              xmltype,     -- This field will contain any farther info within the row
created                               date                     not null,
created_by                            varchar2(255)            not null,
updated                               date                     ,
updated_by                            varchar2(255)              
) ;


-- triggers
create or replace trigger xml_table_trg
    before insert or update 
    on xml_table
    for each row
begin
    if :new.id is null then
        :new.id := GET_MAX_IDENTIFIER('xml_table');
    end if;
    if inserting then
        :new.row_version := 1;
    elsif updating then
        :new.row_version := nvl(:old.row_version,0) + 1;
    end if;
    if inserting then
        :new.created := sysdate;
        :new.created_by := nvl(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := nvl(sys_context('APEX$SESSION','APP_USER'),user);
end xml_table_trg;
/



insert into xml_table(xml_info) values(('<xml><bene><bene_name></bene_name><location_id>15</location_id></bene></xml>'));
commit;



--<xml>
--  <employees>
--    <employee_name>John Smith</employee_name>
--    <location_id>15</location_id>
--  </employees>
--  <languages>
--    <ar>???????</ar>
--    <fr>lay</fr>
--  </languages>
--</xml>
--;

declare
v_result varchar2(1000);
begin 
if not 
xml_pk.add_xml_column(  a_table_name          => 'xml_table'
                       ,a_column_name         => 'xml_info'
                       ,a_id_column_name      => 'id'
                       ,a_id                  => 1
                       ,a_xml_path_name       => '/xml/bene/bene_name'
                       ,a_xml_column_name     => 'ArabicName'
                       ,a_xml_column_value    => '�����'
                       ,a_result              => v_result 
                       ) then 
raise_application_error (-20001,v_result);

end if;

:v_result := v_result;

end;
      
declare
v_result varchar2(1000);
begin 
if not 
xml_pk.modify_xml_column(  a_table_name          => 'xml_table'
                       ,a_column_name         => 'xml_info'
                       ,a_id_column_name      => 'id'
                       ,a_id                  => 1
                       ,a_xml_path_name       => '/xml/bene/bene_name'
                       ,a_xml_column_name     => 'ArabicName'
                       ,a_xml_column_value    => '����'
                       ,a_result              => v_result 
                       ) then 
raise_application_error (-20001,v_result);

end if;

:v_result := v_result;

end;
  

declare
v_result varchar2(1000);
begin 
if not 
xml_pk.delete_xml_column(  a_table_name          => 'xml_table'
                       ,a_column_name         => 'xml_info'
                       ,a_id_column_name      => 'id'
                       ,a_id                  => 1
                       ,a_xml_path_name       => '/xml/bene/bene_name'
                       ,a_xml_column_name     => 'ArabicName'
                       ,a_xml_column_value    => '����'
                       ,a_ret                 => :ret
                       ,a_result              => v_result 
                       ) then 
raise_application_error (-20001,v_result);

end if;

:v_result := v_result;

end;           

select * from xml_table;       


     select *                                                                                                     
     from xml_table  l                                                                                                            
     , XMLTABLE ('//xml'                                                                                       
                               PASSING  ( (l.xml_info) )
                               COLUMNS 
                               bene_name     varchar2(2000) PATH './bene/bene_name/arabicname',
                               location_id       varchar2(2000) PATH './bene/location_id',
                               ar                varchar2(2000) PATH './ar',
                               fr                varchar2(2000) PATH './fr',                                                              
                               gb                varchar2(2000) PATH './gb'
                               ) xml_tab
     ;

select t.xml_info
,      (t.xml_info).extract('//arabicname/text()').getStringVal() arabic_name
,      (t.xml_info).extract('//location_id/text()').getStringVal() loc_id
,      (t.xml_info).extract('//ar/text()').getStringVal() ar
,      (t.xml_info).extract('//fr/text()').getStringVal() fr
,      (t.xml_info).extract('//gb/text()').getStringVal() gb
 from xml_table t
 ;   
 
 
 
select x.xml_info.extract('//arabicname/text()').getStringVal() c
 from xml_table x;
 
 
 select * from xml_table;