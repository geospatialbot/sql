SELECT  SDP.state_desc ,
        SDP.permission_name ,
        SSU.[name] AS "Schema" ,
        SSO.[name] ,
        SSO.[type]
FROM    sys.sysobjects SSO
        INNER JOIN sys.database_permissions SDP ON SSO.id = SDP.major_id
        INNER JOIN sys.sysusers SSU ON SSO.uid = SSU.uid
ORDER BY SSU.[name] ,
        SSO.[name]
