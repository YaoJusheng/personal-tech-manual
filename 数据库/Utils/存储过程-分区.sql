CREATE PROCEDURE AutoPartition()
	BEGIN
	  DECLARE v_sysdate date;
	  DECLARE v_mindate date;
	  DECLARE v_maxdate date;
	  DECLARE v_pt varchar(20);
	  DECLARE v_maxval varchar(20);
	  DECLARE i int;
	  DECLARE sub_i int default 1;
	  DECLARE sub_max int default {$sub_partition_num};
	  DECLARE sub_v_pt varchar(20);
	  DECLARE sub_less_than_time int;

	  /*增加新分区*/
	  SELECT FROM_UNIXTIME(max(partition_description)) AS val
	  INTO   v_maxdate
	  FROM   INFORMATION_SCHEMA.PARTITIONS
	  WHERE  TABLE_NAME = 'files';

	  set v_sysdate = sysdate();

	  WHILE v_maxdate <= (v_sysdate + INTERVAL 1 DAY) DO
		SET v_pt = date_format(v_maxdate,'%Y%m%d');
		SET v_maxval = date_format(v_maxdate, '%Y-%m-%d');

		/*sub_max个子分区*/
		SET sub_i = 1;
		-- select sub_i;
		WHILE (sub_i <= sub_max) DO

			SET sub_less_than_time = UNIX_TIMESTAMP(v_maxdate)  + (86400 DIV sub_max) * sub_i;
			SET sub_v_pt = concat(v_pt , sub_i);

			SET @sql = concat('alter table files add partition (partition p', sub_v_pt, ' values less than(',sub_less_than_time,'))');
			-- SELECT @sql;
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;

			SET sub_i = sub_i + 1;
		END WHILE;
		/*子分区 结束*/

		SET v_maxdate = v_maxdate + INTERVAL 1 DAY;
	  END WHILE;

	  /*删除旧分区*/
	  SELECT FROM_UNIXTIME(min(partition_description)) AS val
	  INTO   v_mindate
	  FROM   INFORMATION_SCHEMA.PARTITIONS
	  WHERE  TABLE_NAME = 'files';

	  WHILE v_mindate <= (v_sysdate - INTERVAL 3 DAY) DO
		SET v_pt = date_format(v_mindate,'%Y%m%d');

		/*sub_max个子分区*/
		SET sub_i = 1;
		-- select sub_i;
		WHILE (sub_i <= sub_max) DO

			SET @sql = concat('alter table files drop partition p', v_pt , sub_i);
			-- SELECT @sql;
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;

			SET sub_i = sub_i + 1;

		END WHILE;

		SET v_mindate = v_mindate + INTERVAL 1 DAY;
	  END WHILE;

	  COMMIT ;
	END
