-- MySQL dump 10.13  Distrib 5.7.26, for Win64 (x86_64)
--
-- Host: localhost    Database: campus_headlines
-- ------------------------------------------------------
-- Server version	8.0.12

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
-- Current Database: `campus_headlines`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `campus_headlines` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `campus_headlines`;

--
-- Table structure for table `article`
--

DROP TABLE IF EXISTS `article`;
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
  CONSTRAINT `fk_article_author` FOREIGN KEY (`author_id`) REFERENCES `sys_user` (`id`),
  CONSTRAINT `fk_article_channel` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章表(草稿/审核/发布统一)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article`
--

LOCK TABLES `article` WRITE;
/*!40000 ALTER TABLE `article` DISABLE KEYS */;
INSERT INTO `article` VALUES (1,'我校2026年秋季开学典礼隆重举行','9月1日上午，我校在体育馆隆重举行2026年秋季开学典礼，校长XXX教授发表重要讲话。','<p>金秋九月，丹桂飘香。9月1日上午，我校2026年秋季开学典礼在体育馆隆重举行。</p><p>校长XXX教授在讲话中回顾了过去一学年学校取得的成绩，并对全体师生提出了新的期望。</p>','/static/uploads/material/202610/1.jpg',NULL,1,3,'校宣传部',2,NULL,1280,57,24,4,1,0,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-10-28 09:40:13'),(2,'关于2026-2027学年第一学期选课通知','教务处发布本学期选课安排，提醒同学们按时完成选课。','<p>各位同学：</p><p>2026-2027学年第一学期选课工作将于本周六上午8:00正式开始，请同学们登录教务系统按时完成选课。</p>','/static/uploads/material/202610/2.jpg',NULL,3,3,'教务处',2,NULL,894,34,12,3,1,1,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-10-28 09:40:13'),(3,'计算机学院成功举办第十届程序设计大赛','我院第十届程序设计大赛圆满落幕，共评选出一等奖3名，二等奖6名，三等奖12名。','<p>为培养学生的编程能力和算法思维，计算机学院于上周六成功举办了第十届程序设计大赛。</p>','/static/uploads/material/202610/3.jpg',NULL,2,4,'计算机学院',2,NULL,572,28,9,1,0,0,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-10-28 09:40:13'),(4,'本周三图书馆四楼举办考研英语讲座','知名考研辅导专家张教授将分享考研英语高分技巧。','<p>讲座时间：本周三下午2:30-4:00</p><p>讲座地点：图书馆四楼学术报告厅</p>','/static/uploads/material/202610/4.jpg',NULL,4,4,'研究生部',2,NULL,446,19,7,0,0,0,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-10-28 09:40:13'),(5,'关于校园网临时维护的通知','因网络升级改造，今晚22:00-次日凌晨2:00校园网将暂停服务。','<p>各位师生：</p><p>学校网络中心将于今晚22:00至次日凌晨2:00对核心交换机进行升级改造。</p>','/static/uploads/material/202610/5.jpg',NULL,3,3,'网络中心',2,NULL,2104,45,18,4,0,1,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-10-28 09:40:13'),(6,'我校学子在全国大学生数学建模竞赛中获一等奖','我校计算机学院代表队荣获2026年全国大学生数学建模竞赛全国一等奖。','<p>在刚刚结束的2026年全国大学生数学建模竞赛中，我校代表队荣获全国一等奖！</p>','/static/uploads/material/202610/6.jpg',NULL,7,4,'计算机学院',2,NULL,988,67,31,0,1,0,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-10-28 09:40:13'),(7,'2026年校园歌手大赛决赛精彩回顾','昨晚，我校2026年校园歌手大赛决赛在学生活动中心圆满落幕。','<p>历时一个多月的校园歌手大赛终于落下帷幕！来自音乐系的李同学凭借一首《青花瓷》摘得桂冠。</p>','/static/uploads/material/202610/7.jpg',NULL,5,4,'校团委',2,NULL,321,12,5,0,0,0,'2026-10-27 08:38:49','2026-10-27 08:38:49','2026-10-28 09:40:13'),(8,'关于2027届毕业生双选会的通知','本届双选会将于11月15日在体育馆举行，预计有200+企业参会。','<p>学校将于11月15日在体育馆举办大型双选会，届时将有200余家知名企业到场招聘。</p>','/static/uploads/material/202610/8.jpg',NULL,6,3,'就业指导中心',2,NULL,0,0,0,0,0,0,'2026-10-27 14:10:34','2026-10-27 08:38:49','2026-10-28 09:40:13'),(9,'校园足球联赛火热进行中','我校2026年校园足球联赛正在火热进行，欢迎同学们到场加油！','<p>我校2026年校园足球联赛正如火如荼地进行着。比赛时间：每周末下午2:00</p>','/static/uploads/material/202610/9.jpg',NULL,8,4,'校体育部',0,NULL,0,0,0,0,0,0,NULL,'2026-10-27 08:38:49','2026-10-28 09:40:13'),(12,'我校2026级新生入学教育圆满结束','为期三天的新生入学教育在学校体育馆圆满闭幕，全体2026级新生参加了本次活动。','<p>为期三天的新生入学教育在学校体育馆圆满闭幕。全体2026级新生参加了本次活动，通过系列讲座、团队建设和校园参观，新生们对学校的办学理念、规章制度和校园文化有了全面的了解。</p>','/static/uploads/material/202610/12.jpg',NULL,1,1,'校园头条',2,NULL,320,45,28,12,0,0,'2026-10-20 09:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(13,'校长在2026级新生开学典礼上的讲话','校长寄语广大新生：立大志、明大德、成大才、担大任，在青春的赛道上奋力奔跑。','<p>校长在开学典礼上发表了题为《不负韶华 筑梦前行》的重要讲话，寄语广大新生要立大志、明大德、成大才、担大任，在青春的赛道上奋力奔跑。</p>','/static/uploads/material/202610/13.jpg',NULL,1,1,'校园头条',2,NULL,560,89,45,23,0,0,'2026-10-18 10:30:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(14,'学校成功举办建校50周年校庆活动','五十载春华秋实，半世纪砥砺奋进。建校50周年校庆活动隆重举行。','<p>五十载春华秋实，半世纪砥砺奋进。学校建校50周年校庆活动隆重举行，来自全国各地的校友代表、离退休老教师和在校师生齐聚一堂，共襄盛典。</p>','/static/uploads/material/202610/14.jpg',NULL,1,1,'校园头条',2,NULL,890,156,78,45,0,0,'2026-10-15 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(15,'教育部督导组莅临我校检查指导工作','教育部本科教育教学审核评估专家组一行9人莅临我校，开展为期5天的现场评估工作。','<p>教育部本科教育教学审核评估专家组一行9人莅临我校，开展为期5天的现场评估工作。专家组通过听取汇报、查阅资料、随堂听课、师生访谈等方式，对我校本科教育教学工作进行了全面检查。</p>','/static/uploads/material/202610/15.jpg',NULL,1,1,'校园头条',2,NULL,210,34,18,7,0,1,'2026-10-12 11:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(16,'我校与多所海外高校签订合作协议','我校与美国、英国、德国等多个国家的知名高校签订了合作办学和学生交换协议。','<p>我校与美国、英国、德国等多个国家的知名高校签订了合作办学和学生交换协议，进一步拓展了学校的国际影响力和合作空间。</p>','/static/uploads/material/202610/16.jpg',NULL,1,1,'校园头条',2,NULL,180,28,15,5,0,0,'2026-10-10 16:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(17,'第十届校园文化艺术节盛大开幕','主题为\"青春向党·艺彩飞扬\"的第十届校园文化艺术节在学校大礼堂盛大开幕。','<p>主题为\"青春向党·艺彩飞扬\"的第十届校园文化艺术节在学校大礼堂盛大开幕。本届艺术节将持续一个月，涵盖音乐、舞蹈、戏剧、书画等多种艺术形式。</p>','/static/uploads/material/202610/17.jpg',NULL,1,1,'校园头条',2,NULL,430,67,32,18,0,0,'2026-10-08 19:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(18,'学校召开2026年秋季学期教学工作会议','会议总结了上学期教学工作，部署了本学期重点任务，强调要全面提高人才培养质量。','<p>学校召开2026年秋季学期教学工作会议。会议总结了上学期教学工作，部署了本学期重点任务，强调要全面提高人才培养质量，深化教育教学改革。</p>','/static/uploads/material/202610/18.jpg',NULL,1,1,'校园头条',2,NULL,150,22,11,4,0,0,'2026-10-05 09:30:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(19,'计算机学院举办AI人工智能专题讲座','清华大学李教授应邀来我校计算机学院作人工智能前沿技术专题讲座。','<p>清华大学李教授应邀来我校计算机学院作人工智能前沿技术专题讲座。讲座围绕大语言模型、多模态AI、AGI等热点话题展开，吸引了全校300余名师生聆听。</p>','/static/uploads/material/202610/19.jpg',NULL,2,1,'校园头条',2,NULL,456,78,35,19,0,0,'2026-10-25 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(20,'机械工程学院开展企业实践实训活动','机械工程学院2024级全体学生赴三一重工、中联重科等企业开展为期两周的实训。','<p>机械工程学院2024级全体学生赴三一重工、中联重科等企业开展为期两周的实训活动。通过实地参观和动手实践，同学们深入了解了现代制造业的生产流程和技术要求。</p>','/static/uploads/material/202610/20.jpg',NULL,2,1,'校园头条',2,NULL,234,45,22,8,0,0,'2026-10-22 09:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(21,'经济管理学院举办创新创业大赛','第二届\"互联网+\"大学生创新创业大赛校赛启动，全院共收到参赛作品120余件。','<p>经济管理学院举办第二届\"互联网+\"大学生创新创业大赛校赛。全院共收到参赛作品120余件，涵盖智能制造、数字经济、乡村振兴等多个领域。</p>','/static/uploads/material/202610/21.jpg',NULL,2,1,'校园头条',2,NULL,312,56,28,14,0,0,'2026-10-19 15:30:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(22,'外国语学院承办外语配音大赛','第十届校园外语配音大赛由外国语学院承办，吸引了来自全校16个学院的80余支队伍参赛。','<p>第十届校园外语配音大赛由外国语学院承办。比赛吸引了来自全校16个学院的80余支队伍参赛，最终评选出一二三等奖共20支队伍。</p>','/static/uploads/material/202610/22.jpg',NULL,2,1,'校园头条',2,NULL,198,34,16,6,0,0,'2026-10-16 18:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(23,'物理学院在Nature子刊发表重要成果','我校物理学院研究团队在Nature Physics发表关于量子纠缠的重要研究成果。','<p>我校物理学院研究团队在Nature Physics发表关于量子纠缠的重要研究成果。该成果被国际同行评价为\"量子信息科学领域的突破性进展\"。</p>','/static/uploads/material/202610/23.jpg',NULL,2,1,'校园头条',2,NULL,678,112,56,28,0,0,'2026-10-13 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(24,'化学学院开放日活动吸引千余名中学生','化学学院举办实验室开放日，吸引了来自全省20余所中学的1200余名师生前来参观。','<p>化学学院举办实验室开放日活动。活动吸引了来自全省20余所中学的1200余名师生前来参观，同学们亲手体验了趣味化学实验。</p>','/static/uploads/material/202610/24.jpg',NULL,2,1,'校园头条',2,NULL,167,28,14,5,0,0,'2026-10-11 09:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(25,'艺术学院举办毕业作品展览','艺术学院2027届毕业生作品展览在校美术馆隆重开幕，共展出作品300余件。','<p>艺术学院2027届毕业生作品展览在校美术馆隆重开幕。展览汇集了绘画、雕塑、设计、摄影等多种艺术形式的作品共300余件。</p>','/static/uploads/material/202610/25.jpg',NULL,2,1,'校园头条',2,NULL,245,42,20,9,0,0,'2026-10-09 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(26,'关于2026年国庆节放假安排的通知','根据国务院办公厅通知精神，结合学校实际，现将国庆节放假安排通知如下。','<p>根据国务院办公厅通知精神，结合学校实际，现将2026年国庆节放假安排通知如下：10月1日至7日放假调休，共7天。请各单位做好假期值班安排。</p>','/static/uploads/material/202610/26.jpg',NULL,3,1,'校园头条',2,NULL,780,23,15,8,0,0,'2026-09-28 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(27,'关于举办2026年度职称评审工作的通知','学校启动2026年度教师职称评审工作，评审范围包括教授、副教授、讲师。','<p>学校启动2026年度教师职称评审工作。评审范围包括教授、副教授、讲师三个级别，申报截止日期为11月15日。</p>','/static/uploads/material/202610/27.jpg',NULL,3,1,'校园头条',2,NULL,234,12,8,3,0,0,'2026-10-20 09:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(28,'关于开展全校消防安全检查的通知','为切实做好校园消防安全工作，学校决定于本月底前开展一次全面的消防安全检查。','<p>为切实做好校园消防安全工作，学校决定于10月25日至30日开展一次全面的消防安全检查。重点检查学生宿舍、实验室、食堂等场所。</p>','/static/uploads/material/202610/28.jpg',NULL,3,1,'校园头条',2,NULL,189,9,5,2,0,0,'2026-10-21 11:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(29,'关于图书馆系统升级维护的通知','图书馆将于本周六晚进行系统升级，届时馆藏查询和续借服务将暂停使用。','<p>图书馆将于10月28日22:00至次日8:00进行系统升级维护。维护期间，馆藏查询、网上续借等服务将暂停使用。</p>','/static/uploads/material/202610/29.jpg',NULL,3,1,'校园头条',2,NULL,156,8,4,2,0,0,'2026-10-24 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(30,'关于2026-2027学年国家奖学金评审的通知','学校启动2026-2027学年国家奖学金、国家励志奖学金和国家助学金的评审工作。','<p>学校启动2026-2027学年国家奖学金、国家励志奖学金和国家助学金的评审工作。请各学院按照相关规定认真组织评审。</p>','/static/uploads/material/202610/30.jpg',NULL,3,1,'校园头条',2,NULL,567,18,12,6,0,0,'2026-10-22 09:30:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(31,'关于举办校园招聘会的通知','学校将于11月15日举办2027届毕业生秋季校园招聘会，预计有300余家企业参展。','<p>学校将于11月15日在体育馆举办2027届毕业生秋季校园招聘会。预计将有来自全国各地的300余家企业参展，提供就业岗位8000余个。</p>','/static/uploads/material/202610/31.jpg',NULL,3,1,'校园头条',2,NULL,423,15,10,5,0,0,'2026-10-25 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(32,'诺贝尔物理学奖得主LIGO科学合作体来校讲学','2017年诺贝尔物理学奖得主LIGO科学合作体成员之一的Barry Barish教授来校作学术报告。','<p>2017年诺贝尔物理学奖得主、LIGO科学合作体成员Barry Barish教授应邀来校，作题为《引力波的发现与未来》的学术报告，全校500余名师生聆听了报告。</p>','/static/uploads/material/202610/32.jpg',NULL,4,1,'校园头条',2,NULL,890,134,67,32,0,0,'2026-10-26 09:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(33,'院士讲坛：张院士谈碳中和技术','中国工程院张院士做客院士讲坛，深度解读碳中和战略与关键技术。','<p>中国工程院张院士做客我校院士讲坛，作题为《碳中和战略与关键技术》的学术报告，系统阐述了我国碳中和的战略路径和核心技术。</p>','/static/uploads/material/202610/33.jpg',NULL,4,1,'校园头条',2,NULL,456,78,34,16,0,0,'2026-10-23 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(34,'长江学者特聘教授解读数字经济','长江学者特聘教授、北京大学李教授作题为《数字经济时代的机遇与挑战》的学术讲座。','<p>长江学者特聘教授、北京大学李教授应邀作题为《数字经济时代的机遇与挑战》的学术讲座，深入剖析了数字经济的发展趋势和治理框架。</p>','/static/uploads/material/202610/34.jpg',NULL,4,1,'校园头条',2,NULL,324,56,23,11,0,0,'2026-10-20 10:30:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(35,'青年学者论坛：机器学习前沿','第十期青年学者论坛聚焦机器学习前沿问题，来自全校的青年学者参加了本次论坛。','<p>第十期青年学者论坛聚焦机器学习前沿问题，来自计算机、数学、统计等多个学院的青年学者参加了本次论坛，论坛收到论文40余篇。</p>','/static/uploads/material/202610/35.jpg',NULL,4,1,'校园头条',2,NULL,178,32,14,6,0,0,'2026-10-17 15:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(36,'文学名家进校园：莫言作品研讨会','著名作家莫言应邀来校参加作品研讨会，与师生分享创作心得和文学感悟。','<p>著名作家莫言应邀来校参加作品研讨会，与师生分享创作心得和文学感悟。研讨会吸引了近800名文学爱好者参与。</p>','/static/uploads/material/202610/36.jpg',NULL,4,1,'校园头条',2,NULL,678,112,45,23,0,0,'2026-10-14 19:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(37,'国际学术前沿讲座：量子计算','国际著名量子计算专家、麻省理工学院Aram Harrow教授来校作学术报告。','<p>国际著名量子计算专家、麻省理工学院Aram Harrow教授应邀来校作题为《量子算法的最新进展》的学术报告。</p>','/static/uploads/material/202610/37.jpg',NULL,4,1,'校园头条',2,NULL,289,48,21,9,0,0,'2026-10-11 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(38,'名师讲坛：如何写好学术论文','我校国家级教学名师王教授做客名师讲坛，讲授学术论文写作的核心技巧和规范。','<p>我校国家级教学名师王教授做客名师讲坛，从选题、文献综述、研究方法、写作规范等多个方面，系统讲授了学术论文写作的核心技巧。</p>','/static/uploads/material/202610/38.jpg',NULL,4,1,'校园头条',2,NULL,245,42,18,8,0,0,'2026-10-08 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(39,'吉他社举办校园民谣音乐节','校园吉他社联合民谣音乐社共同举办第三届校园民谣音乐节，15支校园乐队参演。','<p>校园吉他社联合民谣音乐社共同举办第三届校园民谣音乐节。本届音乐节以\"青春民谣·唱响校园\"为主题，共有来自全校的15支校园乐队参演。</p>','/static/uploads/material/202610/39.jpg',NULL,5,1,'校园头条',2,NULL,567,98,45,23,0,0,'2026-10-24 19:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(40,'摄影协会组织秋季采风活动','摄影协会组织会员赴岳麓山、橘子洲头等景点进行秋季摄影采风活动。','<p>摄影协会组织50余名会员赴岳麓山、橘子洲头等景点进行秋季摄影采风活动。活动后将举办采风作品展览和评选。</p>','/static/uploads/material/202610/40.jpg',NULL,5,1,'校园头条',2,NULL,234,45,20,8,0,0,'2026-10-21 08:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(41,'志愿者协会开展社区服务活动','校志愿者协会组织200余名志愿者开展\"敬老爱老\"社区服务系列活动。','<p>校志愿者协会组织200余名志愿者开展\"敬老爱老\"社区服务系列活动。志愿者们分别前往3个社区养老院和1个残疾人康复中心进行服务。</p>','/static/uploads/material/202610/41.jpg',NULL,5,1,'校园头条',2,NULL,345,67,32,14,0,0,'2026-10-18 09:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(42,'辩论社在全国大学生辩论赛中获奖','我校辩论社代表队在第十九届全国大学生辩论赛中荣获亚军，创历史最佳战绩。','<p>我校辩论社代表队在第十九届全国大学生辩论赛中荣获亚军，创历史最佳战绩。参赛队员由来自6个学院的8名本科生和研究生组成。</p>','/static/uploads/material/202610/42.jpg',NULL,5,1,'校园头条',2,NULL,789,134,56,28,0,0,'2026-10-15 16:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(43,'动漫社举办秋日同人祭','校动漫社举办第六届秋日同人祭活动，吸引了校内外千余名动漫爱好者参与。','<p>校动漫社举办第六届秋日同人祭活动。本届同人祭包含cosplay表演、手办展览、同人志即卖会等丰富内容，吸引了校内外千余名动漫爱好者参与。</p>','/static/uploads/material/202610/43.jpg',NULL,5,1,'校园头条',2,NULL,456,78,34,16,0,0,'2026-10-12 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(44,'书画协会举办迎新书画展','校书画协会举办迎新书画展，展出作品200余件，涵盖国画、书法、篆刻等多种形式。','<p>校书画协会举办迎新书画展。本次展览共展出作品200余件，涵盖国画、书法、篆刻、油画等多种艺术形式。</p>','/static/uploads/material/202610/44.jpg',NULL,5,1,'校园头条',2,NULL,189,34,15,6,0,0,'2026-10-09 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(45,'天文社组织月全食观测活动','本年度唯一一次月全食光临，校天文社组织百余名师生进行夜间观测活动。','<p>本年度唯一一次月全食光临我国上空，校天文社组织百余名师生在学校天文台进行了长达4小时的夜间观测活动。</p>','/static/uploads/material/202610/45.jpg',NULL,5,1,'校园头条',2,NULL,678,112,54,25,0,0,'2026-10-08 20:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(46,'2027届毕业生秋季校园招聘会预告','学校将于11月15日举办2027届毕业生秋季校园招聘会，300余家企业携8000+岗位来袭。','<p>学校将于11月15日在体育馆举办2027届毕业生秋季校园招聘会。本次招聘会预计将有来自全国各地的300余家企业参展，提供就业岗位8000余个。</p>','/static/uploads/material/202610/46.jpg',NULL,6,1,'校园头条',2,NULL,567,34,23,12,0,0,'2026-10-26 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(47,'字节跳动2027届校招宣讲会进校园','字节跳动2027届校园招聘宣讲会在学校大礼堂举行，提供技术、产品、运营等多类岗位。','<p>字节跳动2027届校园招聘宣讲会在学校大礼堂举行。本次校招提供技术研发、产品经理、运营、设计等多类岗位，招聘规模创历史新高。</p>','/static/uploads/material/202610/47.jpg',NULL,6,1,'校园头条',2,NULL,789,45,31,18,0,0,'2026-10-24 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(48,'国家公务员考试备考指导讲座','中公教育名师来校举办国家公务员考试备考指导讲座，讲解行测申论答题技巧。','<p>中公教育名师来校举办国家公务员考试备考指导讲座。讲座围绕行测五大模块和申论写作进行系统讲解，现场发放备考资料千余份。</p>','/static/uploads/material/202610/48.jpg',NULL,6,1,'校园头条',2,NULL,434,23,16,8,0,0,'2026-10-22 19:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(49,'2027届毕业生考研动员大会召开','学校召开2027届毕业生考研动员大会，考研录取率连续五年保持在40%以上。','<p>学校召开2027届毕业生考研动员大会。大会介绍了近五年考研形势、学校考研支持政策和备考策略，我校考研录取率连续五年保持在40%以上。</p>','/static/uploads/material/202610/49.jpg',NULL,6,1,'校园头条',2,NULL,512,28,19,10,0,0,'2026-10-19 09:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(50,'华为公司来校举办专场招聘会','华为技术有限公司来校举办2027届毕业生专场招聘会，提供研发、销售、供应链等全系列岗位。','<p>华为技术有限公司来校举办2027届毕业生专场招聘会。本次招聘涵盖研发、销售、供应链、财务等全系列岗位，计划招聘人数超过200人。</p>','/static/uploads/material/202610/50.jpg',NULL,6,1,'校园头条',2,NULL,678,38,26,14,0,0,'2026-10-17 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(51,'选调生报考政策解读讲座','省委组织部来校举办选调生报考政策解读讲座，今年全省计划招录选调生300名。','<p>省委组织部来校举办选调生报考政策解读讲座。2027年全省计划招录选调生300名，定向重点高校选拔优秀毕业生到基层工作。</p>','/static/uploads/material/202610/51.jpg',NULL,6,1,'校园头条',2,NULL,245,15,10,5,0,0,'2026-10-14 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(52,'大学生求职面试技巧培训','就业指导中心举办大学生求职面试技巧培训，涵盖自我介绍、结构化面试、无领导小组讨论等。','<p>就业指导中心举办大学生求职面试技巧培训。培训涵盖自我介绍、结构化面试、无领导小组讨论、压力面试等多种面试形式的应对技巧。</p>','/static/uploads/material/202610/52.jpg',NULL,6,1,'校园头条',2,NULL,356,19,13,7,0,0,'2026-10-11 19:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(53,'学校与10家知名企业共建就业实习基地','学校与华为、腾讯、三一重工等10家知名企业签署协议，共建大学生就业实习基地。','<p>学校与华为、腾讯、三一重工等10家知名企业签署校企合作协议，共建大学生就业实习基地。每年将有千余名学生进入基地实习实训。</p>','/static/uploads/material/202610/53.jpg',NULL,6,1,'校园头条',2,NULL,389,22,14,8,0,0,'2026-10-09 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(54,'我校食堂被评为全国高校百佳食堂','学校第三食堂因菜品丰富、价格实惠、服务优质，获评\"全国高校百佳食堂\"称号。','<p>学校第三食堂因菜品丰富、价格实惠、服务优质，被中国高等教育学会后勤管理分会评为\"全国高校百佳食堂\"。</p>','/static/uploads/material/202610/54.jpg',NULL,7,1,'校园头条',2,NULL,378,67,32,15,0,0,'2026-10-25 12:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(55,'校园WiFi全面升级 网速提升10倍','学校完成校园无线网络全面升级改造，带宽从1Gbps提升至10Gbps，实现全校无缝覆盖。','<p>学校投资2000万元完成校园无线网络全面升级改造。升级后带宽从1Gbps提升至10Gbps，实现全校所有区域无缝Wi-Fi覆盖。</p>','/static/uploads/material/202610/55.jpg',NULL,7,1,'校园头条',2,NULL,512,89,45,22,0,0,'2026-10-22 08:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(56,'新图书馆即将投入使用 藏书量翻倍','投资3亿元的新图书馆将于年底前投入使用，藏书量从200万册增加到400万册。','<p>投资3亿元的新图书馆将于年底前正式投入使用。新馆建筑面积3.5万平方米，藏书量从200万册增加到400万册，阅览座位3000余个。</p>','/static/uploads/material/202610/56.jpg',NULL,7,1,'校园头条',2,NULL,789,134,67,31,0,0,'2026-10-20 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(57,'校园共享单车新增1000辆','为方便师生出行，学校与共享单车公司合作，在校园内新增投放1000辆共享单车。','<p>为方便师生校园出行，学校与共享单车公司合作，在校园内新增投放1000辆共享单车。目前校园内共享单车总量已达3000辆。</p>','/static/uploads/material/202610/57.jpg',NULL,7,1,'校园头条',2,NULL,346,56,28,13,0,0,'2026-10-17 16:00:00','2026-10-27 10:50:54','2026-10-28 09:40:50'),(58,'心理咨询中心推出线上预约服务','学校心理咨询中心推出线上预约系统，学生可通过微信公众号或小程序预约心理咨询。','<p>学校心理咨询中心正式推出线上预约系统。学生可通过微信公众号或小程序方便快捷地预约心理咨询服务，中心每学期接待学生超过2000人次。</p>','/static/uploads/material/202610/58.jpg',NULL,7,1,'校园头条',2,NULL,178,28,14,6,0,0,'2026-10-14 09:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(59,'学生公寓安装空调 今夏全校覆盖','学校投资5000万元为所有学生公寓安装空调，实现学生宿舍空调全覆盖。','<p>学校投资5000万元为所有学生公寓安装空调。本次改造涉及12栋学生公寓共3000余间宿舍，提前完成了原定计划，今夏已全部投入使用。</p>','/static/uploads/material/202610/59.jpg',NULL,7,1,'校园头条',2,NULL,890,156,78,38,0,0,'2026-10-10 14:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(60,'校园\"第二课堂\"学分认定新规出台','学校出台新版\"第二课堂\"学分认定管理办法，志愿服务、创新创业等均纳入认定范围。','<p>学校出台新版\"第二课堂\"学分认定管理办法。新办法将志愿服务、创新创业、文体活动、社会实践等都纳入学分认定范围。</p>','/static/uploads/material/202610/60.jpg',NULL,7,1,'校园头条',2,NULL,289,48,23,11,0,0,'2026-10-07 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(61,'我校女篮夺得全国大学生篮球联赛冠军','我校女篮在CUBA全国总决赛中以82:78击败卫冕冠军清华大学队，时隔三年再次夺得总冠军。','<p>我校女篮在第二十八届CUBA全国大学生篮球联赛总决赛中，以82:78击败卫冕冠军清华大学队，时隔三年再次夺得总冠军。队长当选赛事MVP。</p>','/static/uploads/material/202610/61.jpg',NULL,8,1,'校园头条',2,NULL,1234,234,112,56,0,0,'2026-10-25 21:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(62,'新生运动会精彩瞬间回顾','2026级新生运动会顺利闭幕，1200余名新生参加了田赛、径赛和趣味项目共26个比赛项目。','<p>2026级新生运动会顺利闭幕。本届运动会共有1200余名新生参赛，设田赛、径赛和趣味运动项目共26个比赛项目，3人次打破校记录。</p>','/static/uploads/material/202610/62.jpg',NULL,8,1,'校园头条',2,NULL,678,112,54,26,0,0,'2026-10-22 17:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(63,'校足球队晋级全国大学生足球联赛八强','我校足球队在全国大学生足球联赛南区决赛中战胜对手，成功晋级全国八强。','<p>我校足球队在全国大学生足球联赛南区决赛中，以2:1战胜强敌，成功晋级全国八强。这是我校足球队历史最佳战绩。</p>','/static/uploads/material/202610/63.jpg',NULL,8,1,'校园头条',2,NULL,567,89,42,21,0,0,'2026-10-19 20:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(64,'乒乓球协会举办新生杯乒乓球赛','校乒乓球协会举办\"新生杯\"乒乓球比赛，吸引了来自全校30多个学院的200余名新生参加。','<p>校乒乓球协会举办\"新生杯\"乒乓球比赛。本次比赛设男子单打、女子单打和混合双打三个项目，吸引了来自全校30多个学院的200余名新生参加。</p>','/static/uploads/material/202610/64.jpg',NULL,8,1,'校园头条',2,NULL,234,45,21,9,0,0,'2026-10-16 15:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(65,'我校学子在全国大学生田径锦标赛上获金牌','我校田径队在全国大学生田径锦标赛上斩获2金3银2铜，团体总分位列全国高校前五。','<p>我校田径队在全国大学生田径锦标赛上斩获2金3银2铜。其中，李同学打破了女子100米全国大学生记录，张同学夺得男子跳高金牌。</p>','/static/uploads/material/202610/65.jpg',NULL,8,1,'校园头条',2,NULL,890,156,67,32,0,0,'2026-10-13 16:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(66,'3V3篮球联赛火热进行中','校园3V3篮球联赛正在如火如荼地进行，全校共56支队伍报名参赛。','<p>校园3V3篮球联赛正在如火如荼地进行。本届联赛吸引了全校56支队伍报名参赛，设常规赛和季后赛两个阶段。</p>','/static/uploads/material/202610/66.jpg',NULL,8,1,'校园头条',2,NULL,345,67,32,14,0,0,'2026-10-10 18:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(67,'秋季校园马拉松报名开启','第二届校园秋季马拉松报名正式开启，比赛设全程、半程和迷你马三个组别。','<p>第二届校园秋季马拉松报名正式开启。本届赛事设全程马拉松、半程马拉松和迷你马拉松三个组别，预计参赛规模将超过3000人。</p>','/static/uploads/material/202610/67.jpg',NULL,8,1,'校园头条',2,NULL,456,78,34,16,0,0,'2026-10-08 10:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(68,'校游泳队在省大学生游泳赛上勇夺10金','我校游泳队在湖南省大学生游泳锦标赛上勇夺10枚金牌，金牌数位列全省第一。','<p>我校游泳队在湖南省大学生游泳锦标赛上表现出色，勇夺10枚金牌、6枚银牌、4枚铜牌，金牌数位列全省参赛高校第一。</p>','/static/uploads/material/202610/68.jpg',NULL,8,1,'校园头条',2,NULL,289,48,23,11,0,0,'2026-10-05 16:00:00','2026-10-27 10:50:54','2026-10-28 09:40:13'),(69,'计算机专业学术讲座圆满举办','讲座分享专业知识，助力学子深耕计算机领域。','我院举办计算机主题学术讲座。主讲老师结合当下技术发展趋势，向同学们介绍专业相关知识，分享学习方法。同学们认真聆听，积极交流探讨。本次讲座有效拓宽了同学们的专业眼界，收获良好反响。','/static/uploads/material/202610/69.jpg',NULL,4,3,'张记者',3,'内容有点少',0,0,0,0,0,0,NULL,'2026-10-27 13:21:40','2026-10-28 09:40:13'),(73,'计算机前沿技术分享学术讲座顺利开展','本次讲座聚焦计算机前沿技术，为同学们拓展专业视野。','为帮助同学们了解行业前沿动态，夯实专业基础，我院组织开展计算机前沿技术主题学术讲座。\n讲座中，主讲人围绕相关技术发展现状、应用场景以及未来发展方向展开细致讲解，结合实际案例拆解技术原理，分享学习与项目实践经验。在互动交流环节，同学们积极提出学习中遇到的疑问，主讲人逐一耐心解答，现场氛围热烈。\n此次讲座搭建了良好的学习交流平台，让大家进一步明晰专业发展方向，激发了同学们的科研兴趣与学习热情。','/static/uploads/material/202610/1e217c3f407344d0b39cd8a0b744f09a.png',NULL,4,3,'张记者',1,'',0,0,0,0,0,0,NULL,'2026-10-27 14:08:36','2026-10-27 14:09:01'),(74,'计算机协会开展趣味编程社团活动','计算机协会组织趣味编程活动，丰富同学们课余生活，提升编程实践兴趣。','<p>为丰富校园文化生活，营造轻松有趣的专业学习氛围，我校计算机协会开展趣味编程主题社团活动。</p><p>活动现场，社团成员齐聚一堂。负责人向大家介绍本次活动流程，设置编程小游戏、代码小挑战、技术交流分享等环节。同学们分组协作，互相讨论思路，动手完成简易代码任务，在趣味挑战中感受编程的魅力。在自由交流环节，大家分享学习中遇到的难题，交流学习经验，互帮互助，现场氛围轻松活跃。</p><p>本次社团活动，跳出枯燥的理论学习模式，以趣味互动激发同学们对计算机专业的热爱，拉近社员之间的距离，进一步增强社团凝聚力。</p>','/static/uploads/material/202610/1e217c3f407344d0b39cd8a0b744f09a.png',NULL,5,3,'记者团',2,NULL,10,0,0,0,0,0,'2026-10-27 15:41:55','2026-10-27 15:33:54','2026-10-27 16:50:00'),(75,'我校文明校园创建工作有序开展','学校开展文明校园建设活动，引导学子树立文明新风。','近日，我校积极推进文明校园创建工作，多措并举培育校园文明新风。\n学校组织开展文明宣传、校园环境维护等活动，倡导同学们讲文明、守礼仪，自觉维护校园秩序与卫生。广大同学积极响应，主动参与到文明实践当中。\n本次活动增强了同学们的文明素养，推动形成文明有礼、积极向上的校园风气。','/static/uploads/material/202610/1dcb587028534e988636d58dd36f4f04.png',NULL,1,3,'新闻组',2,'',4,0,0,0,0,0,'2026-10-27 16:39:44','2026-10-27 15:53:38','2026-10-27 18:24:16'),(76,'警惕 AI 写作误区，引导学子理性使用人工智能工具','针对学生使用 AI 全篇代写作文被 AI 检测识别现象，我校开展引导教育，倡导合理、规范运用 AI。','<p>随着人工智能工具快速普及，不少同学尝试借助 AI 辅助学习。近期出现部分同学直接使用 AI 全篇生成作文、作业，最终被 AI 检测工具识别的情况，引发大家对于 AI 使用边界与学术诚信的讨论。</p><p>人工智能是高效的学习辅助工具，可以用来拓宽思路、查阅资料、修改润色文稿，但不能替代独立思考与自主创作。直接依靠 AI 完成整篇文章，不仅无法锻炼写作、思辨能力，还违背学术诚信要求，会带来相应的学业风险。</p><p>我校以此案例为契机，面向同学们开展学风教育，明确 AI 使用规范：鼓励大家善用 AI 启发想法、辅助修改，但坚决杜绝 AI 全篇代写、抄袭式完成作业。教师也在课堂上引导同学们分清 “辅助” 和 “代做” 的界限，重视独立思考，坚守学术诚信底线。</p><p>在此呼吁全体同学，树立正确的学习观念，理性使用 AI 工具，把人工智能当成助力自我提升的帮手，而不是投机取巧的捷径，自觉维护优良学风。</p>','/static/uploads/material/202610/a7aa317c7bc14882b6f0c92dbe9b7687.png','/static/uploads/material/202610/c3364123fc22461aaebbe5415fc1c72d.mp4',1,3,'校团委',2,NULL,5,0,0,0,0,0,'2026-10-27 19:03:05','2026-10-27 18:52:48','2026-10-27 20:22:42');
/*!40000 ALTER TABLE `article` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article_favorite`
--

DROP TABLE IF EXISTS `article_favorite`;
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收藏表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article_favorite`
--

LOCK TABLES `article_favorite` WRITE;
/*!40000 ALTER TABLE `article_favorite` DISABLE KEYS */;
INSERT INTO `article_favorite` VALUES (1,5,1,'2026-10-27 08:38:49'),(2,5,2,'2026-10-27 08:38:49'),(4,6,4,'2026-10-27 08:38:49'),(5,7,1,'2026-10-27 08:38:49'),(10,6,3,'2026-10-27 12:49:02'),(11,12,1,'2026-10-27 12:53:27');
/*!40000 ALTER TABLE `article_favorite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article_like`
--

DROP TABLE IF EXISTS `article_like`;
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='点赞表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article_like`
--

LOCK TABLES `article_like` WRITE;
/*!40000 ALTER TABLE `article_like` DISABLE KEYS */;
INSERT INTO `article_like` VALUES (1,5,1,'2026-10-27 08:38:49'),(2,5,3,'2026-10-27 08:38:49'),(4,6,2,'2026-10-27 08:38:49'),(5,7,5,'2026-10-27 08:38:49'),(12,6,1,'2026-10-27 12:49:54'),(14,12,1,'2026-10-27 12:53:15');
/*!40000 ALTER TABLE `article_like` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article_material`
--

DROP TABLE IF EXISTS `article_material`;
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
-- Dumping data for table `article_material`
--

LOCK TABLES `article_material` WRITE;
/*!40000 ALTER TABLE `article_material` DISABLE KEYS */;
/*!40000 ALTER TABLE `article_material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
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
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (3,8,1,1,'审核通过','2026-10-27 14:10:33'),(4,69,1,2,'内容有点少','2026-10-27 14:17:20'),(5,74,1,1,'审核通过','2026-10-27 15:41:55'),(6,75,1,1,'审核通过','2026-10-27 16:39:43'),(7,76,1,1,'审核通过','2026-10-27 19:03:04');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channel`
--

DROP TABLE IF EXISTS `channel`;
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='新闻频道表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channel`
--

LOCK TABLES `channel` WRITE;
/*!40000 ALTER TABLE `channel` DISABLE KEYS */;
INSERT INTO `channel` VALUES (1,'校园要闻','SCHOOL_NEWS',1,1,'2026-10-27 08:38:49'),(2,'院系动态','COLLEGE_NEWS',2,1,'2026-10-27 08:38:49'),(3,'通知公告','NOTICE',3,1,'2026-10-27 08:38:49'),(4,'学术讲座','LECTURE',4,1,'2026-10-27 08:38:49'),(5,'社团活动','CLUB',5,1,'2026-10-27 08:38:49'),(6,'招生就业','RECRUITMENT',6,1,'2026-10-27 08:38:49'),(7,'校园生活','CAMPUS_LIFE',7,1,'2026-10-27 08:38:49'),(8,'体育赛事','SPORTS',8,1,'2026-10-27 08:38:49');
/*!40000 ALTER TABLE `channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment`
--

DROP TABLE IF EXISTS `comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `article_id` bigint(20) NOT NULL COMMENT '所属文章ID',
  `user_id` bigint(20) NOT NULL COMMENT '评论用户ID',
  `content` varchar(500) NOT NULL COMMENT '评论内容',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态: 0待审核 1已发布 2已删除',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `parent_id` bigint(20) DEFAULT NULL COMMENT '父评论ID',
  `reply_user_id` bigint(20) DEFAULT NULL COMMENT '被回复用户ID',
  `like_count` int(11) NOT NULL DEFAULT '0' COMMENT '点赞数',
  PRIMARY KEY (`id`),
  KEY `idx_article_id` (`article_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_comment_article` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='评论表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment`
--

LOCK TABLES `comment` WRITE;
/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
INSERT INTO `comment` (`id`, `article_id`, `user_id`, `content`, `status`, `create_time`, `parent_id`, `reply_user_id`, `like_count`) VALUES
(1,1,5,'开学典礼太隆重了，新校长讲话很有激情！',1,'2026-10-27 08:38:49',NULL,NULL,1),
(2,1,6,'期待新学年的课程安排～',1,'2026-10-27 08:38:49',NULL,NULL,0),
(3,2,5,'选课系统又要抢了，手速慢的伤不起...',1,'2026-10-27 08:38:49',NULL,NULL,0),
(4,3,6,'恭喜获奖的同学！明年我也要参加！',1,'2026-10-27 08:38:49',NULL,NULL,0),
(5,5,7,'今晚有论文要写，希望网络早点恢复',1,'2026-10-27 08:38:49',NULL,NULL,0),
(8,1,12,'牛！',1,'2026-10-27 12:27:37',NULL,NULL,0),
(9,1,12,'对，我也是这样认为的',1,'2026-10-27 18:34:08',1,5,0);
/*!40000 ALTER TABLE `comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment_like`
--

DROP TABLE IF EXISTS `comment_like`;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='评论点赞表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_like`
--

LOCK TABLES `comment_like` WRITE;
/*!40000 ALTER TABLE `comment_like` DISABLE KEYS */;
INSERT INTO `comment_like` VALUES (1,12,1,'2026-10-27 18:34:12');
/*!40000 ALTER TABLE `comment_like` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material`
--

DROP TABLE IF EXISTS `material`;
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
-- Dumping data for table `material`
--

LOCK TABLES `material` WRITE;
/*!40000 ALTER TABLE `material` DISABLE KEYS */;
INSERT INTO `material` VALUES (3,'4.png','/static/uploads/material/202610/5f5d2f2d48a64ddbbca04c4390106691.png','image',269764,'e04c13483adb3f7ab65b486551823783',3,'2026-10-27 14:07:20'),(4,'1.png','/static/uploads/material/202610/1e217c3f407344d0b39cd8a0b744f09a.png','image',332171,'c63e73944ba0fddefb3c75ac3fd788d9',3,'2026-10-27 14:08:21'),(6,'cat.png','/static/uploads/material/202610/1dcb587028534e988636d58dd36f4f04.png','image',36822,'17ee9d587745586db40573fda9751ed5',3,'2026-10-27 16:37:15'),(7,'1.mp4','/static/uploads/material/202610/c3364123fc22461aaebbe5415fc1c72d.mp4','video',6630700,'2eb635c46c3ce5d76adfb285fbbdecba',3,'2026-10-27 18:38:29'),(8,'7.png','/static/uploads/material/202610/a7aa317c7bc14882b6f0c92dbe9b7687.png','image',482681,'b886bc9454ec7fbfffecf14ae84cfba7',3,'2026-10-27 18:52:38');
/*!40000 ALTER TABLE `material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `media_apply`
--

DROP TABLE IF EXISTS `media_apply`;
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
-- Dumping data for table `media_apply`
--

LOCK TABLES `media_apply` WRITE;
/*!40000 ALTER TABLE `media_apply` DISABLE KEYS */;
INSERT INTO `media_apply` VALUES (1,12,'长期关注，希望自己也能成为其中的一员','校园活动摄影','18982537159',2,'理由过于简单',1,'2026-10-27 20:43:52','2026-10-27 20:44:35'),(2,12,'我对校园生活摄影非常感兴趣，并且擅长','校园活动摄影','18982537159',1,NULL,1,'2026-10-27 20:45:40','2026-10-27 20:46:10');
/*!40000 ALTER TABLE `media_apply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
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
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,'admin','e10adc3949ba59abbe56e057f20f883e','系统管理员',NULL,'13800000001','宣传部','ADMIN',1,'2026-10-27 08:38:49','2026-10-27 08:38:49'),(2,'auditor','e10adc3949ba59abbe56e057f20f883e','吴老师',NULL,'13800000002','计算机学院','ADMIN',1,'2026-10-27 08:38:49','2026-10-27 14:39:03'),(3,'editor01','e10adc3949ba59abbe56e057f20f883e','张记者',NULL,'13800000003','记者团','MEDIA',1,'2026-10-27 08:38:49','2026-10-27 08:38:49'),(4,'editor02','e10adc3949ba59abbe56e057f20f883e','李宣传',NULL,'13800000004','计算机学院','MEDIA',1,'2026-10-27 08:38:49','2026-10-27 08:38:49'),(5,'2023001','e10adc3949ba59abbe56e057f20f883e','小杨','/static/uploads/avatar/202610/91e2a23791d24997ae36c894d0ffd80b.png','13800000005','计算机学院','USER',1,'2026-10-27 08:38:49','2026-10-27 20:47:42'),(6,'2023002','e10adc3949ba59abbe56e057f20f883e','小明同学',NULL,'13800000006','计算机学院','USER',1,'2026-10-27 08:38:49','2026-10-27 13:05:39'),(7,'2023003','e10adc3949ba59abbe56e057f20f883e','小张',NULL,'13800000007','外语学院','USER',1,'2026-10-27 08:38:49','2026-10-27 08:38:49'),(8,'2026999','e10adc3949ba59abbe56e057f20f883e','测试同学','/static/img/avatars/a3.svg','13800009999',NULL,'USER',1,'2026-10-27 11:55:01','2026-10-27 11:55:01'),(9,'2023004','e10adc3949ba59abbe56e057f20f883e','嘻嘻','/static/img/avatars/a3.svg',NULL,'计算机信息学院','USER',1,'2026-10-27 11:59:29','2026-10-27 11:59:29'),(12,'2023005','e10adc3949ba59abbe56e057f20f883e','嘿嘿','/static/uploads/avatar/202610/fd6373e65e854c2d96020b06e3b9683e.png',NULL,'计算机信息学院','MEDIA',1,'2026-10-27 12:13:08','2026-10-27 20:46:09');
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-28  9:43:34
