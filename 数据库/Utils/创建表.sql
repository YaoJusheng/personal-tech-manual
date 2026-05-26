/*
 ...
 Date: 2021/01/01 22:00:00
*/


SET NAMES utf8mb4;

-- -------------------------
-- Table heat_chart
-- -------------------------
DROP TABLE IF EXISTS `heat_chart`;

CREATE TABLE `heat_chart` (
  `id` int(11) NOT NULL COMMENT 'id' AUTO_INCREAMENT,
  `start_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
  `addr` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'ip地址',
  `country` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '国家',
  `province` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '省份',
  `isp` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '运营商',
  `request` bigint(20) COLLATE utf8_general_ci NULL COMMENT '请求量',
  `isDelete` TINYINT(1) DEFAULT 0 COMMENT '是否删除(0/不删除,1/删除)',
  PRIMARY KEY (`id`, `start_time`) USING BTREE,
  KEY `region_isp` (`country`, `province`, `isp`)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;


SET FOREIGN_KEY_CHECKS=0;

-- -----------------------------------
-- Table structure for InspectionGroup
-- -----------------------------------
DROP TABLE IF EXISTS `user_service`.`InspectionProSet`;
CREATE TABLE `user_service`.`InspectionProSet`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '项目集名称',
  -- `sub_id` int DEFAULT 0 COMMENT '关联子项目集id',
  `parent_id` int DEFAULT 0 COMMENT '关联父项目集id',
  `service_start_date` DATE DEFAULT NULL COMMENT '服务周期（开始日期）',
  `service_end_date` DATE DEFAULT NULL COMMENT '服务周期（结束日期）',
  `service_product` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '服务产品（WAF/DDoS）',
  `service_bg` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '服务背景',
  `PM` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'PM',
  `creator` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人',
  `last_editor` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '最近编辑者',
  `isDelete` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0-不删除，1-删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uniq_name` (`name`) USING BTREE COMMENT '唯一项目集'
);


-- -----------------------------------
-- Table structure for InspectionProject(单个巡检项目)
-- -----------------------------------
DROP TABLE IF EXISTS `user_service`.`InspectionProject`;
CREATE TABLE `user_service`.`InspectionProject`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '项目名称',
  `proset_id` int NOT NULL COMMENT '关联项目集id',
  `customer_name` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户名称',
  `customer_cid` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户CID',
  `customer_uid` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户UID',
  -- `customer_domain` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户域名',
  `service_start_date` DATE DEFAULT NULL COMMENT '服务周期（开始日期）',
  `service_end_date` DATE DEFAULT NULL COMMENT '服务周期（结束日期）',
  `service_product` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '服务产品（WAF/DDoS等）',
  `service_pro_sta` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '服务产品规格',
  `service_bg` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '服务背景',
  `PM` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'PM',
  `TAM` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'TAM',
  `PDSA` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'PDSA',
  `Inspector` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '巡检人员',
  `customer_api` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户接口',
  `group_name` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '钉钉群名',
  `architecture` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '业务构架',
  `materials_link` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '巡检的材料oss链接',
  `creator` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人',
  `last_editor` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '最近编辑者',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `project_in_set` (`name`,`proset_id`) USING BTREE COMMENT '项目集+项目'
  -- CONSTRAINT `fk_InspectionProject_InspectionProSet` FOREIGN KEY (`proset_id`) REFERENCES `user_service`.`InspectionProSet` (`id`)
);
-- SET FOREIGN_KEY_CHECKS=1;

-- -----------------------------------
-- Table structure for InspectionGroup
-- -----------------------------------
DROP TABLE IF EXISTS `user_service`.`InspectionGroup`;
CREATE TABLE `user_service`.`InspectionGroup`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分组类型：高防巡检项、WAF巡检项...',
  `category` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类别：产品规格、业务转发、防护功能、安全事件...',
  `creator` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人',
  `last_editor` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '最近编辑者',
  `isDelete` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0-不删除，1-删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `group_category` (`name`,`category`) USING BTREE COMMENT '分组+类别'
);

-- -----------------------------------
-- Table structure for InspectionAtom
-- -----------------------------------
DROP TABLE IF EXISTS `user_service`.`InspectionAtom`;
CREATE TABLE `user_service`.`InspectionAtom`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `mode` enum('自动化检查','人工检查') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '自动化检查' COMMENT '巡检方式：自动巡检或人工巡检',
  `category_id` int NOT NULL COMMENT '巡检类别id',
  `product` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '产品类型：DDoS、WAF等',
  `atom_en` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '巡检原子-英文名',
  `atom_cn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '巡检原子-中文名',
  `atom_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'uid' COMMENT '原子类型：domain、ip、uid等',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '巡检原子描述',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '数据源类型：sls、odps、api等',
  `access_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '访问id',
  `secret_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '访问秘钥',
  `project` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT 'project',
  `logstore` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT 'sls的日志',
  `endpoint` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '域名前缀',
  `author` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '原子作者',
  `last_editor` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '原子最近编辑者',
  `isenable` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否启用：0-未启用，1-启用',
  `isDelete` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0-不删除，1-删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `atom_name`(`atom_en`) USING BTREE COMMENT '原子名唯一'
  -- CONSTRAINT `fk_InspectionAtom_InspectionGroup` FOREIGN KEY (`category_id`) REFERENCES `user_service`.`InspectionGroup` (`id`)
);

-- SET FOREIGN_KEY_CHECKS=1;

-- -----------------------------------
-- Table structure for 任务表
-- -----------------------------------
DROP TABLE IF EXISTS `InspectionHistory`;
CREATE TABLE `InspectionHistory`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `create_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '任务创建时间',
  `update_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '任务更新时间',
  `project_id` int NOT NULL COMMENT '关联项目id',
  `task_id` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '任务id',
  `mode` enum('自动化检查','人工检查') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '自动化检查' COMMENT '巡检方式：自动巡检或人工巡检',
  `product` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '巡检产品类型',
  `category_id` int(11) NOT NULL DEFAULT 0 COMMENT '巡检项id',
  `task_status` tinyint(1)  NOT NULL DEFAULT 0 COMMENT '巡检任务状态（0：正常; 1：异常）',
  `scan_type` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '巡检对象类型',
  `scan_obj` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '巡检对象',
  `parameter` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '任务入参',
  `categoryInfo` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '巡检项分类信息',
  `atomResult` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '原子运行检测结果返回内容',
  `creator` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人',
  `risk_num` int(11) NOT NULL DEFAULT 0 COMMENT '风险项数量',
  `risk_item` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '[]' COMMENT '风险项列表',
  `risk_treatment` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '[]' COMMENT '风险处理列表',
  `progress_bar` tinyint(3) unsigned zerofill NOT NULL DEFAULT 0 COMMENT '巡检进度条',
  -- `remark` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  -- `feed_person` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '反馈人',
  -- `accurate` tinyint(1) DEFAULT 0 COMMENT '是否准确(1/准确, 2/不准确, 0/无)',
  `last_editor` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '原子最近编辑者',
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE INDEX `task_name`(`task_id`,`mode`,`category_id`,`scan_obj`) USING BTREE COMMENT '巡检任务唯一性',
  -- CONSTRAINT `fk_InspectionHistory_InspectionProject` FOREIGN KEY (`project_id`) REFERENCES `user_service`.`InspectionProject` (`id`)
  KEY `scan_object` (`project_id`,`scan_obj`) USING BTREE COMMENT '对象的联合索引'
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------------------------
-- 根据远程数据库表 创建本地表 建立连接并同步数据
-- ----------------------------------------------
-- -----------------------------------
-- Remote Table structure for InspectionGroup
-- -----------------------------------
DROP TABLE IF EXISTS `user_service`.`RemoteInspectionGroup`;
CREATE TABLE `user_service`.`RemoteInspectionGroup`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分组类型：高防巡检项、WAF巡检项...',
  `product` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分组类型英文名...',
  `category` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类别：产品规格、业务转发、防护功能、安全事件...',
  `creator` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人',
  `last_editor` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '最近编辑者',
  `isDelete` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0-不删除，1-删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `group_category` (`name`,`category`) USING BTREE COMMENT '分组+类别'
)
ENGINE=FEDERATED
DEFAULT CHARSET=utf8mb4
CONNECTION='mysql://username:password@host:port<3306>/db/InspectionGroup';
