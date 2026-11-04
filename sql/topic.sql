-- =====================================================================
-- 话题功能增量脚本（在 campus_headlines 库中执行一次即可）
-- 内容：news_topic 主题表、news_topic_follow 关注表、article.topic_id、演示数据
-- 说明：为避免与库中已有的旧版 topic / topic_like / topic_favorite 表冲突，
--       新版“话题主题”使用 news_topic、news_topic_follow 命名。
-- 话题状态：0待审核 1已上线 2已驳回 3已禁用
-- =====================================================================

USE `campus_headlines`;

-- ---------------------------------------------------------------------
-- 1. 话题主题表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `news_topic` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) NOT NULL COMMENT '话题名称',
  `description` varchar(500) DEFAULT NULL COMMENT '话题简介',
  `cover` varchar(255) DEFAULT NULL COMMENT '话题封面图',
  `creator_id` bigint(20) NOT NULL COMMENT '创建人(自媒体人/管理员)ID',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态: 0待审核 1已上线 2已驳回 3已禁用',
  `is_hot` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否热门: 1是 0否',
  `reject_reason` varchar(500) DEFAULT NULL COMMENT '驳回原因',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_creator_id` (`creator_id`),
  KEY `idx_is_hot` (`is_hot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='话题主题表';

-- ---------------------------------------------------------------------
-- 2. 话题关注表（用户关注/取关）
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `news_topic_follow` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `topic_id` bigint(20) NOT NULL COMMENT '话题ID(news_topic.id)',
  `user_id` bigint(20) NOT NULL COMMENT '关注用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_news_topic_user` (`topic_id`,`user_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_ntfollow_topic` FOREIGN KEY (`topic_id`) REFERENCES `news_topic` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ntfollow_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='话题关注表';

-- ---------------------------------------------------------------------
-- 3. 文章表增加所属话题（仅需执行一次；若已存在 topic_id 字段可跳过本段）
-- ---------------------------------------------------------------------
ALTER TABLE `article`
  ADD COLUMN `topic_id` bigint(20) DEFAULT NULL COMMENT '所属话题ID(一篇文章一个话题)' AFTER `channel_id`,
  ADD KEY `idx_topic_id` (`topic_id`),
  ADD CONSTRAINT `fk_article_news_topic` FOREIGN KEY (`topic_id`) REFERENCES `news_topic` (`id`) ON DELETE SET NULL;

-- ---------------------------------------------------------------------
-- 4. 演示话题（creator_id: 1=admin, 3=editor01, 4=editor02）
-- ---------------------------------------------------------------------
INSERT INTO `news_topic` (`id`, `title`, `description`, `cover`, `creator_id`, `status`, `is_hot`, `reject_reason`, `create_time`, `update_time`) VALUES
(1,'开学季','新学期、新气象，一起记录开学典礼、新生入学与校园初体验。',NULL,3,1,1,NULL,'2026-10-27 09:00:00','2026-10-27 09:00:00'),
(2,'人工智能与校园','聚焦 AI 技术、人工智能讲座与大学生如何理性使用 AI 工具。',NULL,3,1,1,NULL,'2026-10-27 09:10:00','2026-10-27 09:10:00'),
(3,'校园体育','篮球、足球、田径、游泳……为校园里的每一场赛事喝彩。',NULL,3,1,0,NULL,'2026-10-27 09:20:00','2026-10-27 09:20:00'),
(4,'2027届就业季','校招宣讲、双选会、考研与考公，陪毕业生走好关键一步。',NULL,4,1,0,NULL,'2026-10-27 09:30:00','2026-10-27 09:30:00'),
(5,'校园文化建设','文明校园、社团活动与第二课堂，共建校园文化。',NULL,3,0,0,NULL,'2026-10-27 18:00:00','2026-10-27 18:00:00'),
(6,'考研经验谈','考研备考经验与院校选择交流。',NULL,3,2,0,'话题简介过于简单，请补充完整后重新提交','2026-10-27 19:00:00','2026-10-27 19:20:00')
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`);

-- ---------------------------------------------------------------------
-- 5. 把已有文章关联到话题（按频道自动关联，仅已发布文章会在话题页展示）
-- ---------------------------------------------------------------------
UPDATE `article` SET `topic_id` = 1 WHERE `topic_id` IS NULL AND `status` = 2 AND `channel_id` = 1;
UPDATE `article` SET `topic_id` = 2 WHERE `topic_id` IS NULL AND `status` = 2 AND `channel_id` = 4;
UPDATE `article` SET `topic_id` = 3 WHERE `topic_id` IS NULL AND `status` = 2 AND `channel_id` = 8;
UPDATE `article` SET `topic_id` = 4 WHERE `topic_id` IS NULL AND `status` = 2 AND `channel_id` = 6;

-- ---------------------------------------------------------------------
-- 6. 演示关注数据（5、6 号用户关注开学季）
-- ---------------------------------------------------------------------
INSERT IGNORE INTO `news_topic_follow` (`topic_id`, `user_id`, `create_time`) VALUES
(1,5,'2026-10-27 09:40:00'),
(1,6,'2026-10-27 09:41:00'),
(2,5,'2026-10-27 09:42:00'),
(3,6,'2026-10-27 09:43:00');
