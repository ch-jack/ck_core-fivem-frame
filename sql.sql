CREATE TABLE `ck_core` (
  `identifier` varchar(50) COLLATE utf8mb4_bin NOT NULL,-- steam标识符
  `name` varchar(22) COLLATE utf8mb4_bin DEFAULT NULL,-- steam名称
  `rolename` varchar(22) COLLATE utf8mb4_bin DEFAULT NULL,-- 角色名
  
  `money` int(11) DEFAULT 0,-- 现金
  `bank` int(11) DEFAULT 0,-- 银行卡
  `group` varchar(5) DEFAULT "user",-- 权限组
  
  `ip` varchar(22) COLLATE utf8mb4_bin DEFAULT NULL,-- ip
  `createtime` timestamp NOT NULL,-- 创角时间
  `logintime` timestamp NOT NULL,-- 加入时间
  `onlinetime` TinyText COLLATE utf8mb4_bin DEFAULT NULL,-- 在线时间
  
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


CREATE TABLE `ck_server` (-- 
  `id` tinyint(3) unsigned COLLATE utf8mb4_bin NOT NULL,-- 
  `serverdate` longtext COLLATE utf8mb4_bin DEFAULT NULL,
	
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
