CREATE OR REPLACE PACKAGE BODY DEV_ENV.xml_pk is
--Created by Abdullah Zabarah - 27/10/2019
-- Updated by Abdullah Zabarah 02/03/2020
-- Updated by Abdullah Zabarah 22/03/2020
-- Updated by Abdullah Zabarah 24/03/2020
function to_xml_format ( a_obj XML_OBJ ) return clob 
is 
v_xml_  clob;
begin
v_xml_ :=  XMLTYPE(a_obj).getClobVal();
--select  deletexml (xmltype(v_xml_)   ,'//*[not(text())][not(*)]').getClobVal() into v_xml_ from dual;
select  xmltype(deletexml (xmltype(v_xml_)   ,'//*[not(text())][not(*)]').getStringVal()).getClobVal() into v_xml_ from dual;
return v_xml_;
end; 


function to_xml_format ( a_array xml_array ) return clob 
is 
v_xml_  clob;
v_formated_col_name     varchar2(4000);
v_formated_col_value    varchar2(4000);
v_formated_xml          varchar2(4000) := '<XML_INFO>';
ndx_    number := 0;
begin

for i in 1.. a_array.count
loop
ndx_ := ndx_ +1;
v_formated_col_name := replace(a_array(i).col_name,' ','_');
v_formated_col_value:= a_array(i).col_value;
v_formated_xml := v_formated_xml || '<'||v_formated_col_name|| '>'|| v_formated_col_value || '</'||v_formated_col_name||'>';

--v_xml_ :=  XMLTYPE(v_formated_xml).getClobVal();
end loop;
v_formated_xml := v_formated_xml ||  '/<XML_INFO>';
return v_formated_xml;
select  xmltype(deletexml (xmltype(v_xml_)   ,'//*[not(text())][not(*)]').getStringVal()).getClobVal() into v_xml_ from dual;
return v_xml_;
end;

--    function my_xml_table (a_rec xml_pk.xml_rcrd) return xml_tbl_type pipelined 
--    is 
--    begin 
--    pipe row (a_rec);
--    end;

--    function to_xml_format(a_rec xml_pk.xml_rcrd)   return clob
--    is
--    l_ref   sys_refcursor;
--    v_rec xml_pk.xml_rcrd;
--    l_xmltype       xmltype;
--
--    begin 
--    v_rec := a_rec;
----    v_rec.frm_agent_ser     := 1;
----    v_rec.frm_user_id       := '2';
----    v_rec.user_pass         := 'Test';
----    v_rec.pyo_agt_ser       := 'Hello World';
----    v_rec.pyo_agt_brn_ser   := Sysdate;
----    v_rec.trans_no          := systimestamp;
--
--    open l_ref for select * from table(my_xml_table (v_rec));  -- this is pipelined function as above 
--    l_xmltype := xmltype(l_ref);
--
--    return l_xmltype.getClobVal();
--
--    exception 
--        when others then return 'Got error when trying to collect xml'; 
--
--    end;

function delete_xml_column(   a_schema_name          varchar2 default SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
                             ,a_table_name           varchar2
                             ,a_column_name          varchar2
                             ,a_id_column_name       varchar2 default 'id'
                             ,a_id                   number
                             ,a_xml_path_name        varchar2
                             ,a_xml_column_name      varchar2
                             ,a_xml_column_value     clob
                             ,a_ret              out varchar2
                             ,a_result           out varchar2 ) return boolean
                         is 
v_sql               varchar2(4000);
v_xml_path_name     varchar2(4000):= lower( a_xml_path_name );
v_xml_column_name   varchar2(4000):= lower(  a_xml_column_name ); 
v_ret               varchar2(4000);

v_sql_get_old_val               varchar2(4000);
v_old_value         varchar2(4000);
begin

    -- Check if the column has value already 
    v_sql_get_old_val := 
    ' select x.' || a_column_name || '.extract(''//'||v_xml_column_name||'/text()'').getStringVal() c
     from ' || a_schema_name || '.' || a_table_name || ' x';

    execute immediate v_sql_get_old_val  INTO v_old_value;
    if v_old_value is null then 
        a_result :=v_xml_column_name || ' node value is not exist nothing to delete!!!';
        return false;    
    end if;   
v_sql := 
'
update ' || a_schema_name|| '.'|| a_table_name || 
'
set ' || a_column_name || 
'
= replace(' || a_column_name || ',' || '''<'|| v_xml_column_name || '>'||v_old_value||'</' || v_xml_column_name || '>'',null)' ||
' where ' || a_id_column_name || '=' || a_id || ' returning ' ||  a_id_column_name || ' into :ret ' ;
--    a_result :=v_sql;
--    return false;
execute immediate v_sql RETURNING INTO a_ret;

-- Check if column value
if a_ret is null then 
    a_result :='Nothing to Delete, please check the used parameters!!!';
    return false;
end if;    
a_result :='Success';
return true;

exception 
    when others then 
        a_result := sqlerrm;
        return false;
end;  



function do_xml_column(  a_schema_name          varchar2 default SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
                         ,a_table_name           varchar2
                         ,a_column_name          varchar2
                         ,a_id_column_name       varchar2 default 'id'
                         ,a_id                   number
                         ,a_xml_path_name        varchar2
                         ,a_xml_column_name      varchar2
                         ,a_xml_column_value     clob
                         ,a_operation_flag       varchar2 default 'I'
                         ,a_result           out varchar2 ) return boolean
                         is 
v_chk_sql           varchar2(4000);
v_has_value         varchar2(4000);

v_sql_get_old_val               varchar2(4000);
v_old_value         varchar2(4000);

v_sql               varchar2(4000);
v_xml_path_name     varchar2(4000):= lower( a_xml_path_name );
v_xml_column_name   varchar2(4000):= lower(  a_xml_column_name ); 
v_ret               varchar2(4000);
v_operation_flag    varchar2(1):= upper(a_operation_flag);
begin

if v_operation_flag = 'I' then 
    -- Check if the column has value already 
    v_chk_sql := 
    ' select x.' || a_column_name || '.extract(''//'||v_xml_column_name||'/text()'').getStringVal() c
     from ' || a_schema_name || '.' || a_table_name || ' x';

    execute immediate v_chk_sql  INTO v_has_value;
    if v_has_value is not null then 
        a_result :='Value ' || a_xml_column_value || ' is already there, please use modify_xml_column instead!!!';
        return false;    
    end if;
elsif v_operation_flag = 'U' then
    -- Check if the column has value already 
/*    v_sql_get_old_val := 
    ' select x.' || a_column_name || '.extract(''//'||v_xml_column_name||'/text()'').getStringVal() c
     from ' || a_schema_name || '.' || a_table_name || ' x';

    execute immediate v_sql_get_old_val  INTO v_old_value;

            v_old_value := ltrim(rtrim( v_old_value)); 
    if v_old_value is null then 
            a_result :=v_xml_column_name || ' node value is not exist nothing to update!!!';
            return false;    
        end if;*/
        null;
end if;

v_sql := 
'
update ' || a_schema_name|| '.'|| a_table_name || 
'
set ' || a_column_name || 
'
= INSERTCHILDXML(' || a_column_name || ',' || 
''''||v_xml_path_name||''',''' || v_xml_column_name || ''','||
' XMLType(''<'|| v_xml_column_name || '>' || a_xml_column_value || '</' || v_xml_column_name || '>''))' || 
' where ' || a_id_column_name || '=' || a_id || ' returning ' ||  a_id_column_name || ' into :ret ' ;


execute immediate v_sql RETURNING INTO v_ret;

-- Check if column value
if v_ret is null then 
    a_result :='Nothing to '||case when v_operation_flag = 'I' then 'Insert' when v_operation_flag ='U' then 'Update' when v_operation_flag ='D' then 'Delete' else '<Operation>' end ||', please check the used parameters!!!';
    return false;
end if;    
a_result :='Success';
return true;
exception 
    when others then 
        a_result := sqlerrm;
        return false;
end;  

function add_xml_column(  a_schema_name          varchar2 default SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
                         ,a_table_name           varchar2
                         ,a_column_name          varchar2
                         ,a_id_column_name       varchar2 default 'id'
                         ,a_id                   number
                         ,a_xml_path_name        varchar2
                         ,a_xml_column_name      varchar2
                         ,a_xml_column_value     clob
                         ,a_result           out varchar2 ) return boolean
                         is 
v_chk_sql           varchar2(4000);
v_has_value         varchar2(4000);

v_sql               varchar2(4000);
v_xml_path_name     varchar2(4000):= lower( a_xml_path_name );
v_xml_column_name   varchar2(4000):= lower(  a_xml_column_name ); 
v_ret               varchar2(4000);
begin

return do_xml_column(   a_schema_name      => a_schema_name     
                       ,a_table_name       => a_table_name      
                       ,a_column_name      => a_column_name     
                       ,a_id_column_name   => a_id_column_name  
                       ,a_id               => a_id              
                       ,a_xml_path_name    => a_xml_path_name   
                       ,a_xml_column_name  => a_xml_column_name 
                       ,a_xml_column_value => a_xml_column_value
                       ,a_operation_flag   => 'I'  
                       ,a_result           => a_result    
                       );      
    
exception 
    when others then 
        a_result := sqlerrm;
        return false;
end;   

function modify_xml_column(  a_schema_name          varchar2 default SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
                         ,a_table_name           varchar2
                         ,a_column_name          varchar2
                         ,a_id_column_name       varchar2 default 'id'
                         ,a_id                   number
                         ,a_xml_path_name        varchar2
                         ,a_xml_column_name      varchar2
                         ,a_xml_column_value     clob
                         ,a_result           out varchar2 ) return boolean
                         is 
v_chk_sql           varchar2(4000);
v_has_value         varchar2(4000);

v_sql               varchar2(4000);
v_xml_path_name     varchar2(4000):= lower( a_xml_path_name );
v_xml_column_name   varchar2(4000):= lower(  a_xml_column_name ); 
v_ret               varchar2(4000);
begin

-- first Delete node value
if not xml_pk.delete_xml_column(    a_schema_name          => a_schema_name                  
                                   ,a_table_name          => a_table_name                   
                                   ,a_column_name         => a_column_name                  
                                   ,a_id_column_name      => a_id_column_name               
                                   ,a_id                  => a_id                           
                                   ,a_xml_path_name       => a_xml_path_name                
                                   ,a_xml_column_name     => a_xml_column_name              
                                   ,a_xml_column_value    => a_xml_column_value             
                                   ,a_ret                 => v_ret                          
                                   ,a_result              => a_result                       
                       )                                     
then 
        a_result := replace(a_result,'delete','<update>');
        return false;
end if;            

-- do update the node value 
return do_xml_column(   a_schema_name      => a_schema_name     
                       ,a_table_name       => a_table_name      
                       ,a_column_name      => a_column_name     
                       ,a_id_column_name   => a_id_column_name  
                       ,a_id               => a_id              
                       ,a_xml_path_name    => a_xml_path_name   
                       ,a_xml_column_name  => a_xml_column_name 
                       ,a_xml_column_value => a_xml_column_value
                       ,a_operation_flag   => 'U'  
                       ,a_result           => a_result    
                       );   
exception 
    when others then 
        a_result := sqlerrm;
        return false;
end;  
                      
end xml_pk;
/