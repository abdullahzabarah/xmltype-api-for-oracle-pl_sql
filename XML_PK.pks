CREATE OR REPLACE PACKAGE DEV_ENV.xml_pk is
--Created by Abdullah Zabarah - 27/10/2019
-- Updated by Abdullah Zabarah 02/03/2020
-- Updated by Abdullah Zabarah 22/03/2020
-- Updated by Abdullah Zabarah 24/03/2020
function to_xml_format ( a_obj XML_OBJ ) return clob;
function to_xml_format ( a_array xml_array ) return clob;
function add_xml_column(  a_schema_name          varchar2 default SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
                         ,a_table_name           varchar2
                         ,a_column_name          varchar2
                         ,a_id_column_name       varchar2 default 'id'
                         ,a_id                   number
                         ,a_xml_path_name        varchar2
                         ,a_xml_column_name      varchar2
                         ,a_xml_column_value     clob
                         ,a_result           out varchar2 ) return boolean;

function modify_xml_column(  a_schema_name       varchar2 default SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
                         ,a_table_name           varchar2
                         ,a_column_name          varchar2
                         ,a_id_column_name       varchar2 default 'id'
                         ,a_id                   number
                         ,a_xml_path_name        varchar2
                         ,a_xml_column_name      varchar2
                         ,a_xml_column_value     clob
                         ,a_result           out varchar2 ) return boolean;
function delete_xml_column(  a_schema_name          varchar2 default SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
                         ,a_table_name           varchar2
                         ,a_column_name          varchar2
                         ,a_id_column_name       varchar2 default 'id'
                         ,a_id                   number
                         ,a_xml_path_name        varchar2
                         ,a_xml_column_name      varchar2
                         ,a_xml_column_value     clob
                         ,a_ret              out varchar2
                         ,a_result           out varchar2 ) return boolean;                         
end;
/