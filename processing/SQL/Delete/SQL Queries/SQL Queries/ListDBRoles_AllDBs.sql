USE [master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

declare @dbname varchar(200)
declare @mSql1 varchar(8000)

CREATE TABLE #DBROLES
(
DBName sysname not null,
UserName sysname not null,
db_owner varchar(3) not null,
db_accessadmin varchar(3) not null,
db_securityadmin varchar(3) not null,
db_ddladmin varchar(3) not null,
db_datareader varchar(3) not null,
db_datawriter varchar(3) not null,
db_denydatareader varchar(3) not null,
db_denydatawriter varchar(3) not null,
)

DECLARE DBName_Cursor CURSOR FOR
	SELECT name
	FROM master.dbo.sysdatabases
	WHERE name not in ('mssecurity','tempdb','model','msdb')
	ORDER by name

OPEN DBName_Cursor
FETCH NEXT FROM DBName_Cursor INTO @dbname
WHILE @@FETCH_STATUS = 0

BEGIN
	SET @mSQL1 = ' INSERT into #DBROLES ( DBName, UserName, db_owner, db_accessadmin,
	db_securityadmin, db_ddladmin, db_datareader, db_datawriter,
	db_denydatareader, db_denydatawriter )
	SELECT '+''''+@dbName+''''+ ' as DBName ,UserName, '+char(13)+ '
		Max(CASE RoleName WHEN ''db_owner'' THEN ''Yes'' ELSE ''No'' END) AS db_owner,
		Max(CASE RoleName WHEN ''db_accessadmin '' THEN ''Yes'' ELSE ''No'' END) AS db_accessadmin ,
		Max(CASE RoleName WHEN ''db_securityadmin'' THEN ''Yes'' ELSE ''No'' END) AS db_securityadmin,
		Max(CASE RoleName WHEN ''db_ddladmin'' THEN ''Yes'' ELSE ''No'' END) AS db_ddladmin,
		Max(CASE RoleName WHEN ''db_datareader'' THEN ''Yes'' ELSE ''No'' END) AS db_datareader,
		Max(CASE RoleName WHEN ''db_datawriter'' THEN ''Yes'' ELSE ''No'' END) AS db_datawriter,
		Max(CASE RoleName WHEN ''db_denydatareader'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatareader,
		Max(CASE RoleName WHEN ''db_denydatawriter'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatawriter
	FROM (
		SELECT b.name as UserName, c.name as RoleName
		FROM ' + @dbName+'.dbo.sysmembers a '+char(13)+ '
		JOIN '+ @dbName+'.dbo.sysusers b '+char(13)+ '
		ON a.memberuid = b.uid 
		JOIN '+@dbName+'.dbo.sysusers c
		ON a.groupuid = c.uid )s
		GROUP by UserName
		ORDER by UserName'

EXECUTE (@mSql1)

FETCH NEXT FROM DBName_Cursor INTO @dbname
END
CLOSE DBName_Cursor
DEALLOCATE DBName_Cursor

SELECT * 
FROM #DBRoles
ORDER BY DBName
DROP TABLE #DBROLES

