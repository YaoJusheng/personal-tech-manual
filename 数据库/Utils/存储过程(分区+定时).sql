DROP PROCEDURE IF EXISTS AUTO_PARTITION_OF;

DELIMITER //
CREATE PROCEDURE AUTO_PARTITION_OF(IN $log_table_name VARCHAR(64), IN $range_hours INT)
COMMENT '自动创建和删除7天前的分区'
BEGIN

	-- $log_table_name 待分片的表名
	-- $range_hours 单片数据的时间长度(小时，尽量取能把24整除的值，如：1，2，3，4，6，8，12，24)
	-- $min_log_time 已有日志数据的最小时间，决定起始分片的时间，如果为 null 则自动取当天的零点

	-- DECLARE $base_dir VARCHAR(64);
	DECLARE $monthly_dir  VARCHAR(64);
	DECLARE $now INT; -- 当前时间戳
	DECLARE $zero_am INT; -- 明天零点
	DECLARE $stop_hour INT; -- 预创建终止时间戳
    DECLARE $sql_partition_template VARCHAR(500); -- 建分片的 SQL 模板
    DECLARE $sys_on_hour date;
    DECLARE $del_date date;
	DECLARE $cur_date date;

	DECLARE $partition_name VARCHAR(16); -- 新分片名字
    DECLARE $last_less_than_hour INT; -- 上一个分片的 less 值
	DECLARE $first_less_than_hour INT; -- 最小分区时间戳（ 首个分区 less 值）
	DECLARE $less_than_hour INT; -- 上一个分片的 less 值
	DECLARE $sql_tmp VARCHAR(500); -- 临时拼接的 SQL

	-- 数据文件和索引文件的存放目录
	-- SET $base_dir = CONCAT('/data/mysql/data/', DATABASE(), '/', $log_table_name, '/');

	-- 当前系统时间
	SET $now = UNIX_TIMESTAMP( NOW() );
	-- 今天零点(按天去余后再减掉8个时区偏差)
	SET $zero_am = $now - $now%86400 - 28800;
	-- 预创建分区的终止小时值(后天零点)
	SET $stop_hour =  $zero_am + 172800;

	-- 创建新分片的SQL模板
	SET $sql_partition_template = CHAR(10);
	SET $sql_partition_template = CONCAT($sql_partition_template, 'ALTER TABLE ', $log_table_name, ' ADD PARTITION (');
	SET $sql_partition_template = CONCAT($sql_partition_template, CHAR(10), 'PARTITION $partition_name VALUES LESS THAN ($less_than_hour)');
	SET $sql_partition_template = CONCAT($sql_partition_template, CHAR(10), ');');

	-- 查找上一个/最早分片的小时值
    SET $last_less_than_hour = NULL;
	SET $first_less_than_hour = NULL;

    -- 查询最早的分区时间
	SELECT MIN(PARTITION_DESCRIPTION) INTO $first_less_than_hour
    FROM INFORMATION_SCHEMA.PARTITIONS
	WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=$log_table_name;

    -- 查询上一个的分区时间
    SELECT MAX(PARTITION_DESCRIPTION) INTO $last_less_than_hour
    FROM INFORMATION_SCHEMA.PARTITIONS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=$log_table_name;
	-- ORDER BY PARTITION_ORDINAL_POSITION DESC LIMIT 1;

    -- 最近分区时间/结束时间
	IF $last_less_than_hour IS NULL OR $last_less_than_hour=0 THEN
		-- 没有记录，设置为第二天零点
    SET $last_less_than_hour = $zero_am + 86400;
    -- 预创建分区的终止小时值（后天零点： 48h）
		SET $stop_hour = $zero_am + 172800;
	ELSE
		-- 设置为已有最早记录的时间点后
		SET $last_less_than_hour = $min_log_time;
    -- 预创建分区的终止小时值（当前预创建起始分区时间24h后： 24h）
		SET $last_less_than_hour = $last_less_than_hour + 86400;

	END IF;

  -- (1) 删除旧分区
  SET $del_date = $sys_on_hour - INTERVAL 7 DAY;

  -- 方式一
  _DEL_PARTITION_LOOP_ : LOOP
    SET $cur_date = FROM_UNIXTIME($first_less_than_hour);

    IF $cur_date <= $del_date THEN
      SET $partition_name = DATE_FORMAT( FROM_UNIXTIME($first_less_than_hour - 3600*$range_hours), 'p%Y%m%d%H' );
      -- 删除7天前的分区
      SET $sql_tmp = CONCAT(CHAR(10), 'ALTER TABLE ', $log_table_name, ' DROP PARTITION ', $partition_name, ' ;');
      -- SET $sql_tmp = REPLACE($sql_tmp, '$log_table_name', $log_table_name);
      -- SET $sql_tmp = REPLACE($sql_tmp, '$partition_name', $partition_name);
      SET @stmt_sql = $sql_tmp;

      PREPARE stmt FROM @stmt_sql;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;

      SET $first_less_than_hour = $first_less_than_hour + 3600*$range_hours;
    ELSE
      LEAVE _DEL_PARTITION_LOOP_;
    END IF;

  END LOOP _DEL_PARTITION_LOOP_;

  -- 方式二
  -- IF $first_less_than_hour THEN
  --   SET $cur_date = FROM_UNIXTIME($first_less_than_hour);
  --   WHILE $cur_date <= $del_date DO
  --     SET $partition_name = DATE_FORMAT( FROM_UNIXTIME($first_less_than_hour - 3600*$range_hours), 'p%Y%m%d%H' );
  --     -- 删除7天前的分区
  --     SET $sql_tmp = CONCAT(CHAR(10), 'ALTER TABLE ', $log_table_name, ' DROP PARTITION ', $partition_name, ' ;');
  --     -- SET $sql_tmp = REPLACE($sql_tmp, '$log_table_name', $log_table_name);
  --     -- SET $sql_tmp = REPLACE($sql_tmp, '$partition_name', $partition_name);
  --     SET @stmt_sql = $sql_tmp;

  --     PREPARE stmt FROM @stmt_sql;
  --     EXECUTE stmt;
  --     DEALLOCATE PREPARE stmt;

  --     SET $first_less_than_hour = $first_less_than_hour + 3600*$range_hours;
  --     SET $cur_date = FROM_UNIXTIME($first_less_than_hour);

  --   END WHILE

  -- END IF;

  COMMIT;


	-- (2)循环预创建分区
	_PARTITION_LOOP_ : LOOP
		SET $less_than_hour = $last_less_than_hour;
		IF $less_than_hour >= $stop_hour THEN
			LEAVE _PARTITION_LOOP_;
		ELSE
      -- 创建后一天的分区
  		SET $partition_name = DATE_FORMAT( FROM_UNIXTIME($last_less_than_hour - 3600*$range_hours), 'p%Y%m%d%H' );

  		SET $sql_tmp = $sql_partition_template;
  		SET $sql_tmp = REPLACE($sql_tmp, '$partition_name', $partition_name);
  		SET $sql_tmp = REPLACE($sql_tmp, '$less_than_hour', $less_than_hour);

  		SET @stmt_sql = $sql_tmp;
  		PREPARE stmt FROM @stmt_sql;
  		EXECUTE stmt;
  		DEALLOCATE PREPARE stmt;

  		SET $last_less_than_hour = $less_than_hour + 3600*$range_hours;
    END IF;
	END LOOP _PARTITION_LOOP_;


	COMMIT ;

END
//
DELIMITER ;


-- 自动删除分区
DROP PROCEDURE IF EXISTS AUTO_DEL_PARTITION_OF;

DELIMITER //
CREATE PROCEDURE AUTO_DEL_PARTITION_OF(IN $log_table_name VARCHAR(64), IN $range_hours INT, IN $del_date INT,IN $stop_date INT)
COMMENT '自动删除分区'
BEGIN
  -- $log_table_name 待分片的表名
  -- $range_hours 单片数据的时间长度(小时，尽量取能把24整除的值，如：1，2，3，4，6，8，12，24)
  -- $del_date 删除分区的开始时间戳
  -- $stop_date 删除分区的结束时间戳
  DECLARE $partition_name VARCHAR(16); -- 分片名字
  DECLARE $first_less_than_hour INT; -- 最小分区时间戳（ 首个分区 less 值）
  DECLARE $sql_tmp VARCHAR(500); -- 临时拼接的 SQL

  -- 查询最早的分区时间
  SELECT MIN(PARTITION_DESCRIPTION) INTO $first_less_than_hour
  FROM INFORMATION_SCHEMA.PARTITIONS
  WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=$log_table_name AND PARTITION_DESCRIPTION>=$del_date;

  -- 循环删除
   _DEL_PARTITION_LOOP_ : LOOP

    IF $del_date <= $stop_date THEN
      SET $partition_name = DATE_FORMAT( FROM_UNIXTIME($first_less_than_hour - 3600*$range_hours), 'p%Y%m%d%H' );
      -- 删除分区
      SET $sql_tmp = CONCAT(CHAR(10), 'ALTER TABLE ', $log_table_name, ' DROP PARTITION ', $partition_name, ' ;');
      -- SET $sql_tmp = REPLACE($sql_tmp, '$log_table_name', $log_table_name);
      -- SET $sql_tmp = REPLACE($sql_tmp, '$partition_name', $partition_name);
      SET @stmt_sql = $sql_tmp;

      PREPARE stmt FROM @stmt_sql;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;

      SET $first_less_than_hour = $first_less_than_hour + 3600*$range_hours;
    ELSE
      LEAVE _DEL_PARTITION_LOOP_;
    END IF;

  END LOOP _DEL_PARTITION_LOOP_;

  COMMIT;

END
//
DELIMITER ;


-- 测试删除分区
-- SET $del_date = 1608656400;
-- SET $stop_date = 1608991200;
-- SET $log_table_name = 'heat_chart';
CALL AUTO_DEL_PARTITION_OF('heat_chart', 1, 1608656400, 1608991200)

-- 初始化分区
ALTER TABLE heat_chart PARTITION BY RANGE (UNIX_TIMESTAMP(start_time)) (
  PARTITION p2021010122
  VALUES less than(UNIX_TIMESTAMP('2020-01-01 23:00:00')) ENGINE = InnoDB
);

-- 定时事件
DROP EVENT IF EXISTS auto_create_del_partition_heat;

CREATE EVENT auto_create_del_partition_heat IF NOT EXISTS
ON SCHEDULE EVERY 1 DAY
-- ON SCHEDULE EVERY 1 HOUR
-- ON SCHEDULE EVERY 60 SECOND
-- STARTS '2020-12-31 23:00:00'
STARTS CURRENT_TIMESTAMP + INTERVAL 5 SECOND
ON COMPLETION PRESERVE
ENABLE
COMMENT '自动创建删除7天前的分区定时事件'
DO CALL AUTO_PARTITION_OF('heat_chart', 1)
