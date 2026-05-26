-- 1) 存储过程+定时事件
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

-- 2）触发器事件
CREATE TRIGGER triggerName
after/before insert/update/delete on <table>
for each row  -- 这句话在mysql是固定的
begin
 sql语句;
end;
