-- ============================================================
-- 校园头条 · 校园新闻资讯系统 数据库结构（schema.sql）
-- 生成方式：mysqldump --no-data（源库 MySQL 8.0.12）
-- 说明：包含建表语句 + 最小测试数据；可直接在 MySQL 5.7 / 8.0 执行
-- 执行：mysql -uroot -p campus_headlines < sql/schema.sql
-- ============================================================

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `sys_user`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sys_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) NOT NULL COMMENT '学号/工号(登录账号)',
  `password` varchar(100) NOT NULL COMMENT '密码(MD5加密)',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `college` varchar(100) DEFAULT NULL COMMENT '院系',
  `role` varchar(20) NOT NULL DEFAULT 'USER' COMMENT '角色: USER/MEDIA/AUDITOR/ADMIN',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态: 1启用 0禁用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `channel`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channel` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '频道名称',
  `code` varchar(30) DEFAULT NULL COMMENT '频道编码',
  `sort` int(11) NOT NULL DEFAULT '0' COMMENT '排序',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '启用状态: 1启用 0禁用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='新闻频道表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(200) NOT NULL COMMENT '标题',
  `summary` varchar(500) DEFAULT NULL COMMENT '摘要',
  `content` text NOT NULL COMMENT '正文(富文本HTML)',
  `cover` varchar(255) DEFAULT NULL COMMENT '封面图URL',
  `video_url` varchar(255) DEFAULT NULL COMMENT '视频URL',
  `channel_id` bigint(20) DEFAULT NULL COMMENT '所属频道ID(草稿可为空)',
  `topic_id` bigint(20) DEFAULT NULL COMMENT '所属话题ID(一篇文章一个话题)',
  `author_id` bigint(20) NOT NULL COMMENT '作者(自媒体人)ID',
  `source` varchar(100) DEFAULT NULL COMMENT '来源',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态: 0草稿 1待审核 2已发布 3已驳回 4已下架',
  `reject_reason` varchar(500) DEFAULT NULL COMMENT '驳回原因',
  `view_count` int(11) NOT NULL DEFAULT '0' COMMENT '阅读量',
  `like_count` int(11) NOT NULL DEFAULT '0' COMMENT '点赞数',
  `favorite_count` int(11) NOT NULL DEFAULT '0' COMMENT '收藏数',
  `comment_count` int(11) NOT NULL DEFAULT '0' COMMENT '评论数',
  `is_top` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否置顶: 1是 0否',
  `is_urgent` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否紧急: 1是 0否',
  `publish_time` datetime DEFAULT NULL COMMENT '发布时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_channel_id` (`channel_id`),
  KEY `idx_author_id` (`author_id`),
  KEY `idx_status` (`status`),
  KEY `idx_is_top` (`is_top`),
  KEY `idx_topic_id` (`topic_id`),
  CONSTRAINT `fk_article_author` FOREIGN KEY (`author_id`) REFERENCES `sys_user` (`id`),
  CONSTRAINT `fk_article_channel` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`id`),
  CONSTRAINT `fk_article_news_topic` FOREIGN KEY (`topic_id`) REFERENCES `news_topic` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章表(草稿/审核/发布统一)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `material`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `material` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(255) NOT NULL COMMENT '原文件名',
  `url` varchar(500) NOT NULL COMMENT '访问URL/存储路径',
  `type` varchar(20) NOT NULL COMMENT '类型: image/video',
  `size` bigint(20) NOT NULL DEFAULT '0' COMMENT '文件大小(字节)',
  `md5` varchar(32) DEFAULT NULL COMMENT '文件MD5哈希，用于去重',
  `user_id` bigint(20) NOT NULL COMMENT '上传者ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  CONSTRAINT `fk_material_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='素材表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article_material`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article_material` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `article_id` bigint(20) NOT NULL COMMENT '文章ID',
  `material_id` bigint(20) NOT NULL COMMENT '素材ID',
  `sort_no` int(11) NOT NULL DEFAULT '0' COMMENT '排序号',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_article_material` (`article_id`,`material_id`),
  KEY `idx_material_id` (`material_id`),
  CONSTRAINT `fk_am_article` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_am_material` FOREIGN KEY (`material_id`) REFERENCES `material` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章素材关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comment`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `article_id` bigint(20) DEFAULT NULL COMMENT '所属文章ID(话题评论时为空)',
  `user_id` bigint(20) NOT NULL COMMENT '评论用户ID',
  `content` varchar(500) NOT NULL COMMENT '评论内容',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态: 0待审核 1已发布 2已删除',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `parent_id` bigint(20) DEFAULT NULL COMMENT '父评论ID',
  `reply_user_id` bigint(20) DEFAULT NULL COMMENT '被回复用户ID',
  `like_count` int(11) NOT NULL DEFAULT '0' COMMENT '点赞数',
  `topic_id` bigint(20) DEFAULT NULL COMMENT '所属话题ID(话题评论时非空)',
  PRIMARY KEY (`id`),
  KEY `idx_article_id` (`article_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_topic_id` (`topic_id`),
  CONSTRAINT `fk_comment_article` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='评论表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comment_like`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment_like` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `comment_id` bigint(20) NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_comment` (`user_id`,`comment_id`),
  KEY `idx_comment_id` (`comment_id`),
  CONSTRAINT `fk_clike_comment` FOREIGN KEY (`comment_id`) REFERENCES `comment` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_clike_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='评论点赞表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `audit_log`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `article_id` bigint(20) NOT NULL COMMENT '文章ID',
  `auditor_id` bigint(20) NOT NULL COMMENT '审核人ID',
  `action` tinyint(4) NOT NULL COMMENT '操作: 1通过 2驳回',
  `remark` varchar(500) DEFAULT NULL COMMENT '审核备注/驳回理由',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_article_id` (`article_id`),
  KEY `idx_auditor_id` (`auditor_id`),
  CONSTRAINT `fk_audit_article` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_audit_auditor` FOREIGN KEY (`auditor_id`) REFERENCES `sys_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='审核记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `media_apply`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media_apply` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '申请人ID',
  `reason` varchar(500) NOT NULL COMMENT '申请理由',
  `intro` varchar(500) DEFAULT NULL COMMENT '擅长领域/简介',
  `contact` varchar(100) DEFAULT NULL COMMENT '联系方式',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0待审核 1已通过 2已驳回',
  `reject_reason` varchar(255) DEFAULT NULL COMMENT '驳回理由',
  `auditor_id` bigint(20) DEFAULT NULL COMMENT '审核人ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='自媒体人申请';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article_like`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article_like` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `article_id` bigint(20) NOT NULL COMMENT '文章ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_article` (`user_id`,`article_id`),
  KEY `idx_article_id` (`article_id`),
  CONSTRAINT `fk_like_article` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_like_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='点赞表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article_favorite`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article_favorite` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `article_id` bigint(20) NOT NULL COMMENT '文章ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_article` (`user_id`,`article_id`),
  KEY `idx_article_id` (`article_id`),
  CONSTRAINT `fk_fav_article` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收藏表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `news_topic`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news_topic` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '话题名称',
  `description` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '话题简介',
  `cover` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '话题封面图',
  `creator_id` bigint(20) NOT NULL COMMENT '创建人(自媒体人/管理员)ID',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态: 0待审核 1已上线 2已驳回 3已禁用',
  `is_hot` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否热门: 1是 0否',
  `reject_reason` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '驳回原因',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_creator_id` (`creator_id`),
  KEY `idx_is_hot` (`is_hot`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='话题主题表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `news_topic_follow`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news_topic_follow` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `topic_id` bigint(20) NOT NULL COMMENT '话题ID(news_topic.id)',
  `user_id` bigint(20) NOT NULL COMMENT '关注用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_news_topic_user` (`topic_id`,`user_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_ntfollow_topic` FOREIGN KEY (`topic_id`) REFERENCES `news_topic` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ntfollow_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='话题关注表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-04 14:27:07

-- ============================================================
-- 测试数据（最小可运行集）
-- 覆盖 3 种角色、6 个话题（含待审核/已驳回）、4 篇已发布文章、3 条评论
-- 完整演示数据请另执行 sql/init.sql；本文件只保证「建表 + 每张表都有数据」
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;

-- 测试账号：1 管理员ADMIN / 3 自媒体MEDIA / 5、6 普通用户USER（密码均为 123456，MD5 存储）
INSERT INTO `sys_user` VALUES (1,'admin','e10adc3949ba59abbe56e057f20f883e','系统管理员',NULL,'13800000001','宣传部','ADMIN',1,'2026-10-27 08:38:49','2026-10-27 08:38:49'),(3,'editor01','e10adc3949ba59abbe56e057f20f883e','张记者',NULL,'13800000003','记者团','MEDIA',1,'2026-10-27 08:38:49','2026-10-27 08:38:49'),(5,'2023001','e10adc3949ba59abbe56e057f20f883e','小杨','/static/uploads/avatar/202610/91e2a23791d24997ae36c894d0ffd80b.png','13800000005','计算机学院','USER',1,'2026-10-27 08:38:49','2026-10-27 20:47:42'),(6,'2023002','e10adc3949ba59abbe56e057f20f883e','小明同学',NULL,'13800000006','计算机学院','USER',1,'2026-10-27 08:38:49','2026-10-27 13:05:39');

-- 8 个新闻频道（1 校园要闻 / 2 院系动态 / 3 通知公告 / 4 学术讲座 / 5 社团活动 / 6 招生就业 / 7 校园生活 / 8 体育赛事）
INSERT INTO `channel` VALUES (1,'校园要闻','SCHOOL_NEWS',1,1,'2026-10-27 08:38:49'),(2,'院系动态','COLLEGE_NEWS',2,1,'2026-10-27 08:38:49'),(3,'通知公告','NOTICE',3,1,'2026-10-27 08:38:49'),(4,'学术讲座','LECTURE',4,1,'2026-10-27 08:38:49'),(5,'社团活动','CLUB',5,1,'2026-10-27 08:38:49'),(6,'招生就业','RECRUITMENT',6,1,'2026-10-27 08:38:49'),(7,'校园生活','CAMPUS_LIFE',7,1,'2026-10-27 08:38:49'),(8,'体育赛事','SPORTS',8,1,'2026-10-27 08:38:49');

-- 6 个话题：1-4 已上线、5 待审核、6 已驳回（覆盖状态流转）
INSERT INTO `news_topic` VALUES (1,'开学季','新学期、新气象，一起记录开学典礼、新生入学与校园初体验。',NULL,3,1,1,NULL,'2026-10-27 09:00:00','2026-10-27 09:00:00'),(2,'人工智能与校园','聚焦 AI 技术、人工智能讲座与大学生如何理性使用 AI 工具。',NULL,3,1,1,NULL,'2026-10-27 09:10:00','2026-10-27 09:10:00'),(3,'校园体育','篮球、足球、田径、游泳……为校园里的每一场赛事喝彩。',NULL,3,1,0,NULL,'2026-10-27 09:20:00','2026-10-27 09:20:00'),(4,'2027届就业季','校招宣讲、双选会、考研与考公，陪毕业生走好关键一步。',NULL,4,1,0,NULL,'2026-10-27 09:30:00','2026-10-27 09:30:00'),(5,'校园文化建设','文明校园、社团活动与第二课堂，共建校园文化。',NULL,3,0,0,NULL,'2026-10-27 18:00:00','2026-10-27 18:00:00'),(6,'考研经验谈','考研备考经验与院校选择交流。',NULL,3,2,0,'话题简介过于简单，请补充完整后重新提交','2026-10-27 19:00:00','2026-10-27 19:20:00');

-- 话题关注记录
INSERT INTO `news_topic_follow` VALUES (1,1,5,'2026-10-27 09:40:00'),(2,1,6,'2026-10-27 09:41:00'),(3,2,5,'2026-10-27 09:42:00'),(4,3,6,'2026-10-27 09:43:00');

-- 4 篇已发布文章（status=2），其中 1、4 已绑定话题
INSERT INTO `article` VALUES (1,'我校2026年秋季开学典礼隆重举行','9月1日上午，我校在体育馆隆重举行2026年秋季开学典礼，校长XXX教授发表重要讲话。','<p>金秋九月，丹桂飘香。9月1日上午，我校2026年秋季开学典礼在体育馆隆重举行。</p><p>校长XXX教授在讲话中回顾了过去一学年学校取得的成绩，并对全体师生提出了新的期望。</p>','/static/uploads/material/202610/1.jpg',NULL,1,1,3,'校宣传部',2,NULL,1330,57,24,4,1,0,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-11-04 13:53:44'),(2,'关于2026-2027学年第一学期选课通知','教务处发布本学期选课安排，提醒同学们按时完成选课。','<p>各位同学：</p><p>2026-2027学年第一学期选课工作将于本周六上午8:00正式开始，请同学们登录教务系统按时完成选课。</p>','/static/uploads/material/202610/2.jpg',NULL,3,NULL,3,'教务处',2,NULL,910,35,12,5,1,1,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-10-29 17:05:52'),(3,'计算机学院成功举办第十届程序设计大赛','我院第十届程序设计大赛圆满落幕，共评选出一等奖3名，二等奖6名，三等奖12名。','<p>为培养学生的编程能力和算法思维，计算机学院于上周六成功举办了第十届程序设计大赛。</p>','/static/uploads/material/202610/3.jpg',NULL,2,NULL,4,'计算机学院',2,NULL,579,28,9,1,0,0,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-10-29 10:05:14'),(4,'本周三图书馆四楼举办考研英语讲座','知名考研辅导专家张教授将分享考研英语高分技巧。','<p>讲座时间：本周三下午2:30-4:00</p><p>讲座地点：图书馆四楼学术报告厅</p>','/static/uploads/material/202610/4.jpg',NULL,4,2,4,'研究生部',2,NULL,453,19,7,0,0,0,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-11-04 13:53:44');

-- 3 条文章评论（含楼中楼 parent_id）
INSERT INTO `comment` VALUES (1,1,5,'开学典礼太隆重了，新校长讲话很有激情！',2,'2026-10-27 08:38:49',NULL,NULL,1,NULL),(2,1,6,'期待新学年的课程安排～',1,'2026-10-27 08:38:49',NULL,NULL,0,NULL),(3,2,5,'选课系统又要抢了，手速慢的伤不起...',1,'2026-10-27 08:38:49',NULL,NULL,0,NULL);

SET FOREIGN_KEY_CHECKS = 1;
