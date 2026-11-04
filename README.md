# 校园头条 · 校园新闻资讯系统（SSM）

> 技术栈：Spring 5.3 + SpringMVC + MyBatis / MyBatis-Plus + JSP + MySQL + Tomcat（纯 SSM，未使用 Spring Boot）

一个面向校园场景的新闻资讯平台，包含 **普通用户端、自媒体端、系统管理员端** 三套完整业务闭环，
并配套完整的 **测试用例、缺陷清单、缺陷复现与回归记录、Postman 接口测试集合、JUnit 自动化用例**。

---

## 一、项目简介

系统解决的是校园资讯「谁都能发、没人审核、发完就沉」的问题，核心业务链路：

```
自媒体人写稿 → 提交审核 → 管理员审核（通过 / 驳回并填写理由）→ 上线发布 → 用户浏览、点赞、收藏、评论、关注话题
```

三端职责：

| 端 | 主要能力 |
| --- | --- |
| 普通用户端（JSP 页面 + API） | 浏览频道新闻、搜索、查看详情、点赞、收藏、评论与回复、话题广场、关注话题、个人中心 |
| 自媒体端（需 MEDIA 角色） | 写稿 / 存草稿 / 提交审核 / 修改被驳回稿件、素材上传与管理、话题创建与提交审核 |
| 管理员端（需 ADMIN 角色） | 稿件审核（通过 / 驳回）、文章管理（上下架、置顶、删除）、频道管理、用户与角色管理、评论管理、话题审核（上线 / 禁用 / 热门）、数据看板 |

关键业务规则（均有对应测试用例覆盖）：

- 文章状态机：`0 草稿 → 1 待审核 → 2 已发布 / 3 已驳回（可改后重投）/ 4 已下架`
- 话题状态机：`0 待审核 → 1 已上线 / 2 已驳回 / 3 已禁用`
- 一篇稿件最多绑定 1 个话题，且只能选择 **已上线** 的话题
- 只有 `status=2` 的文章对用户端可见，草稿 / 待审 / 驳回 / 下架稿件不可通过用户端接口访问

---

## 二、技术栈

| 分类 | 技术 | 版本 |
| --- | --- | --- |
| 框架 | Spring（IoC / AOP / 声明式事务）、SpringMVC | 5.3.30 |
| 持久层 | MyBatis、MyBatis-Plus（分页插件、BaseMapper） | 3.5.13 / 3.5.3.1 |
| 视图 | JSP + JSTL + 原生 JS / CSS | JSTL 1.2 |
| 数据库 | MySQL（InnoDB，utf8mb4） | 8.0.12（兼容 5.7） |
| 连接池 | Druid | 1.2.16 |
| 鉴权 | JWT（HS256，JDK 原生实现）+ Redis 登录态 + RBAC 拦截器 | Jedis 3.8.0 |
| 文件上传 | Commons FileUpload / MultipartResolver | 1.4 |
| 构建部署 | Maven（war）+ Tomcat | 3.6+ / Tomcat 9 |
| 运行环境 | JDK | 1.8 |

技术点落位：

| 技术点 | 位置 |
| --- | --- |
| IoC / DI | Service 层 `@Service` + `@Autowired`；`applicationContext.xml` 配置 DataSource / SqlSessionFactory |
| AOP 日志切面 | `aspect/ServiceLogAspect.java` |
| 声明式事务 | Service 实现类 `@Transactional(rollbackFor = Exception.class)` |
| 全局异常处理 | `exception/GlobalExceptionHandler.java` + `BusinessException` |
| 拦截器鉴权 | `interceptor/LoginInterceptor`（Session）、`RoleInterceptor`（页面角色）、`TokenInterceptor`（API Token + Redis + 角色） |
| JWT | `utils/JwtUtil.java`（HS256 手写实现，无第三方依赖） |
| MyBatis 动态 SQL | `resources/mapper/*.xml` 中 `<where>` / `<if>` / `<choose>` / `resultMap` |
| 分页插件 | `MybatisPlusInterceptor` + `PaginationInnerInterceptor`（分页参数统一在 `utils/PageUtil` 归一化） |
| 文件上传 | `springmvc.xml` CommonsMultipartResolver + `MaterialServiceImpl.upload`（类型白名单 / 50MB / MD5 去重） |

---

## 三、运行方式（30 秒看懂，5 分钟跑起来）

### 1. 环境要求

| 组件 | 版本 | 说明 |
| --- | --- | --- |
| JDK | 1.8 | 编译级别 1.8，Tomcat 也用 JDK 1.8 启动 |
| MySQL | 5.7 / 8.0 | 默认 `root / root`，端口 3306 |
| Tomcat | 9.x | 端口 8081 |
| Maven | 3.6+ | 打包生成 `campus-headlines.war` |
| Redis | 3.x+ | 默认 `localhost:6379`，用于存放登录 Token |

### 2. 初始化数据库

```bash
# 方式 A：完整演示数据（推荐首次体验）
mysql -uroot -p campus_headlines < sql/init.sql

# 方式 B：仅建表 + 最小测试数据（结构验证 / 自动化测试用）
mysql -uroot -p campus_headlines < sql/schema.sql
```

> `sql/schema.sql` 由 `mysqldump --no-data` 导出，已在本机 MySQL 8.0.12 上实测可重复执行；
> 包含 14 张业务表与「3 种角色 / 6 个话题 / 4 篇已发布文章 / 3 条评论」的最小数据集。
> `sql/topic.sql` 为话题功能的增量脚本（`news_topic`、`news_topic_follow`、`article.topic_id`）。

### 3. 修改连接配置

`src/main/resources/jdbc.properties`：

```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/campus_headlines?useUnicode=true&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true
jdbc.username=root
jdbc.password=root
```

Redis 连接见 `src/main/resources/applicationContext.xml` 中的 `jedisConnectionFactory`。

### 4. 打包与部署

```bash
mvn clean package -DskipTests
# 将 target/campus-headlines.war 复制到 %TOMCAT_HOME%\webapps\，启动 Tomcat
```

访问：`http://localhost:8081/campus-headlines/`

IDEA 用户也可用 Smart Tomcat：Deployment 选 `campus-headlines:war exploded`，Context 填 `/campus-headlines`，端口 8081，JRE 选 JDK 1.8。

### 5. 测试账号

| 角色 | 账号 | 密码 | 可访问 |
| --- | --- | --- | --- |
| 管理员 | admin | 123456 | 管理后台 `/admin/**`、`/api/admin/**` |
| 自媒体（小编） | editor01 | 123456 | 自媒体后台 `/editor/**`、`/api/media/**` |
| 普通用户 | 2023001 | 123456 | 用户端 `/api/user/**` |

> 密码在库中以 MD5 存储（`123456` → `e10adc3949ba59abbe56e057f20f883e`）。
> 该存储方式已被记录为遗留缺陷 BUG-08，见 [缺陷清单](docs/缺陷清单.xlsx)。

---

## 四、我负责的部分

本项目为个人独立完成的课程设计，我承担 **全部开发与全部测试**：

| 阶段 | 我的工作 |
| --- | --- |
| 需求与设计 | 梳理三端角色与稿件状态机，设计 14 张表的库表结构（含外键、唯一索引、状态字段）与接口契约 |
| 后端开发 | SSM 整合、JWT + Redis 鉴权拦截器、文章/话题/评论/素材/频道/用户 6 个业务模块的 Service 与 Mapper、统一响应与全局异常 |
| 前端开发 | 三端 JSP 页面与交互（含话题广场、写稿页话题下拉、后台审核弹窗）、原生 JS 表单提交与分页 |
| 数据库 | 建表脚本、演示数据、话题功能增量迁移脚本，均为可重复执行脚本 |
| 测试（本人独立完成） | 编写 74 条测试用例并执行、发现 8 个缺陷（含 1 个存储型 XSS、1 个越权访问、1 个并发丢失更新）、提交缺陷单、修复后回归验证、编写测试报告 |
| 接口测试 | Postman 集合（登录自动注入 Token，12+ 接口带状态码 / 字段 / 错误提示断言） |
| 自动化 | JUnit 5 单元测试（JWT 签发与篡改、MD5、分页归一化、统一响应），GitHub Actions 自动执行 |

---

## 五、测试资料索引

> 共 **74 条用例 / 8 个缺陷**（6 已修复关闭、2 遗留待优化），所有缺陷均已修复并通过回归验证。

| 文件 | 内容 | 用途 |
| --- | --- | --- |
| [docs/测试用例.xlsx](docs/测试用例.xlsx) | 74 条用例：用例编号 / 模块 / 标题 / 前置条件 / 步骤 / 预期 / 实际 / 通过失败 / 关联缺陷 | 测试设计能力与执行记录 |
| [docs/缺陷清单.xlsx](docs/缺陷清单.xlsx) | 8 条缺陷：ID / 标题 / 模块 / 复现步骤 / 严重程度 / 优先级 / 状态 / 修复说明 | 缺陷发现与闭环 |
| [docs/测试报告.md](docs/测试报告.md) | 测试范围、用例执行统计、缺陷严重度分布、遗留问题、结论 | 测试闭环意识 |
| [docs/测试数据.md](docs/测试数据.md) | 边界与异常数据设计（空值 / 超长 / 特殊字符 / 并发 / 文件类型） | 用例设计的依据 |
| [docs/接口测试说明.md](docs/接口测试说明.md) | Postman 集合导入与运行步骤、断言清单 | 接口测试可复现 |
| [postman/](postman/) | `CampusHeadlines.postman_collection.json` + 环境变量文件 | 导入即可运行 |
| [docs/GitHub-Issues缺陷单.md](docs/GitHub-Issues缺陷单.md) | 8 条 Issue 的标题 / 标签 / 正文模板 | 缺陷生命周期管理 |
| [src/test/java](src/test/java) | JUnit 5 自动化用例（16 个测试方法） | 从「了解自动化」到「能跑」 |
| [.github/workflows/maven-test.yml](.github/workflows/maven-test.yml) | 提交即跑单元测试 | 工程素养 |
| [sql/schema.sql](sql/schema.sql) | 建表 + 最小测试数据 | 数据库可复现 |

执行自动化测试：

```bash
mvn test
```

---

## 六、接口清单

统一响应结构：

```json
{ "code": 200, "msg": "success", "data": {} }
```

`code`：200 成功、400 参数/业务错误、401 未登录或 Token 失效、403 无权限、404 不存在、500 系统异常。
接口鉴权：请求头 `Authorization: Bearer {token}`。

### 6.1 认证 `/api/auth`（无需 Token）

| 方法 | 地址 | 说明 |
| --- | --- | --- |
| POST | `/api/auth/register` | 注册普通用户 |
| POST | `/api/auth/login` | 登录，返回 `data.token` |
| POST | `/api/auth/logout` | 注销（删除 Redis 中的 Token） |
| GET | `/api/auth/userinfo` | 当前登录用户信息 |

### 6.2 用户端 `/api/user`（游客可浏览，互动需登录）

| 方法 | 地址 | 说明 |
| --- | --- | --- |
| GET | `/api/user/channels` | 启用的频道列表 |
| GET | `/api/user/articles?current=1&size=10&channelId=&keyword=` | 已发布文章分页 |
| GET | `/api/user/articles/{id}` | 文章详情（仅 status=2；阅读量 +1） |
| POST | `/api/user/articles/{id}/like` | 点赞 / 取消点赞 |
| POST | `/api/user/articles/{id}/favorite` | 收藏 / 取消收藏 |
| GET | `/api/user/articles/{id}/comments` | 评论列表（楼中楼） |
| POST | `/api/user/articles/{id}/comments` | 发表评论 / 回复 |
| GET | `/api/user/favorites` | 我的收藏 |
| GET | `/api/user/topics` | 话题广场（已上线） |
| GET | `/api/user/topics/hot` | 热门话题 |
| GET | `/api/user/topics/{id}` | 话题详情（文章数 / 关注数） |
| GET | `/api/user/topics/{id}/articles` | 话题下文章分页 |
| POST | `/api/user/topics/{id}/follow` | 关注 / 取消关注话题 |

### 6.3 自媒体端 `/api/media`（需 MEDIA）

| 方法 | 地址 | 说明 |
| --- | --- | --- |
| GET | `/api/media/articles/mine?current=&size=&status=&keyword=` | 我的稿件分页 |
| GET | `/api/media/articles/{id}` | 稿件详情（本人） |
| POST | `/api/media/articles` | 新建草稿（可带 `topicId`） |
| PUT | `/api/media/articles/{id}` | 修改草稿 / 被驳回稿件 |
| POST | `/api/media/articles/{id}/submit` | 提交审核（0 → 1） |
| DELETE | `/api/media/articles/{id}` | 删除稿件 |
| POST | `/api/media/materials/upload` | 上传素材（multipart `file`） |
| GET | `/api/media/materials` | 我的素材 |
| DELETE | `/api/media/materials/{id}` | 删除未被引用的素材 |
| GET | `/api/media/topics/online` | 可选的已上线话题（写稿下拉） |
| GET | `/api/media/topics/mine` | 我创建的话题 |
| POST | `/api/media/topics` | 创建话题（待审核） |
| PUT | `/api/media/topics/{id}` | 修改话题 |
| POST | `/api/media/topics/{id}/submit` | 提交话题审核 |
| DELETE | `/api/media/topics/{id}` | 删除话题 |

### 6.4 管理端 `/api/admin`（需 ADMIN）

| 方法 | 地址 | 说明 |
| --- | --- | --- |
| GET | `/api/admin/articles/pending` | 待审核稿件 |
| POST | `/api/admin/articles/{id}/approve` | 审核通过（→2） |
| POST | `/api/admin/articles/{id}/reject` | 驳回（→3，Body `{"reason":"..."}`） |
| POST | `/api/admin/articles/{id}/offline` | 下架（→4） |
| GET | `/api/admin/articles` | 全部文章分页 |
| DELETE | `/api/admin/articles/{id}` | 删除文章 |
| GET | `/api/admin/users` | 用户列表 |
| PUT | `/api/admin/users/{id}/status` | 启用 / 禁用用户 |
| PUT | `/api/admin/users/{id}/role` | 修改角色 |
| GET / POST | `/api/admin/channels` | 频道查询 / 新增 |
| PUT / DELETE | `/api/admin/channels/{id}` | 修改 / 删除频道（被引用时拒绝删除） |
| GET | `/api/admin/comments` | 评论管理 |
| DELETE | `/api/admin/comments/{id}` | 删除评论 |
| GET | `/api/admin/statistics` | 看板统计 |
| GET | `/api/admin/topics` | 话题管理列表 |
| GET | `/api/admin/topics/{id}` | 话题详情 |
| POST | `/api/admin/topics/{id}/approve` | 话题审核通过（→1） |
| POST | `/api/admin/topics/{id}/reject` | 话题驳回（→2） |
| PUT | `/api/admin/topics/{id}/status` | 上线 / 禁用（1 / 3） |
| PUT | `/api/admin/topics/{id}/hot` | 设为热门 |
| DELETE | `/api/admin/topics/{id}` | 删除话题 |

---

## 七、数据库表

| 表 | 说明 |
| --- | --- |
| `sys_user` | 用户，`role` 为字符串 `USER / MEDIA / AUDITOR / ADMIN` |
| `channel` | 新闻频道（8 个），`status` 1 启用 0 停用 |
| `article` | 文章 / 稿件统一表，`status` 0 草稿 1 待审 2 已发布 3 驳回 4 下架；外键 `author_id`、`channel_id`、`topic_id` |
| `material` | 素材（图片 / 视频），`md5` 去重 |
| `article_material` | 文章与素材多对多，`ON DELETE CASCADE` |
| `comment` / `comment_like` | 评论、评论点赞 |
| `audit_log` | 审核记录（通过 / 驳回 + 备注） |
| `media_apply` | 自媒体入驻申请 |
| `article_like` / `article_favorite` | 文章点赞、收藏（`(article_id,user_id)` 唯一） |
| `news_topic` / `news_topic_follow` | 话题、话题关注（`(topic_id,user_id)` 唯一） |

完整 DDL 与测试数据见 [sql/schema.sql](sql/schema.sql)。

---

## 八、目录结构

```
campus-headlines
├── docs/                        测试用例、缺陷清单、测试报告等测试资料
├── postman/                     Postman 集合与环境文件
├── sql/
│   ├── init.sql                 完整演示数据
│   ├── schema.sql               建表 + 最小测试数据
│   └── topic.sql                话题功能增量脚本
├── src/main/java/com/campus
│   ├── aspect/                  AOP 日志切面
│   ├── controller/              页面控制器
│   │   └── api/                 JSON 接口（Token 鉴权）
│   ├── entity/ mapper/ service/ 领域层
│   ├── interceptor/             登录 / 角色 / Token / 接口日志拦截器
│   └── utils/                   R、JwtUtil、Md5Util、PageUtil、RedisUtil
├── src/main/resources           配置 + Mapper XML
├── src/main/webapp              JSP 页面（student / editor / admin）与静态资源
├── src/test/java                JUnit 5 单元测试
└── pom.xml
```

---

## 九、已知问题与遗留缺陷

| 缺陷 | 状态 | 说明 |
| --- | --- | --- |
| BUG-07 文章正文未转义，存在存储型 XSS | 遗留 | 富文本正文按 HTML 原样渲染。后续方案：引入 HTML 白名单过滤（如 Jsoup Safelist），或前端改用 `c:out` + 服务端清洗 |
| BUG-08 密码 MD5 无盐存储 | 遗留 | 演示项目沿用课程初始化数据。后续方案：BCrypt + 登录时兼容旧 MD5 并异步升级 |

其余 6 个缺陷（越权访问未发布文章、分页参数越界、频道删除未校验引用、点赞并发丢失更新、阅读量并发丢失更新、素材仅校验扩展名）已修复并回归通过，
修复点已在代码中注释 `缺陷 BUG-xx`，可用 `git log` / `git grep BUG-` 追溯。

---

## 十、常见问题

1. `Address already in use: bind`：端口 8081 / 8005 被占用，先关闭已运行的 Tomcat。
2. 控制台 `java.exe` 是 JDK 17：在 Project Structure 与 Smart Tomcat 中把 JDK 改为 1.8。
3. 登录提示用户名或密码错误：确认已执行 `sql/init.sql` 或 `sql/schema.sql`，密码为 `123456`。
4. 页面无样式：确认部署包含 `static` 目录，且访问路径带 `/campus-headlines` 前缀。
5. 接口返回 401「登录已失效」：Redis 中 Token 被覆盖（同账号在别处登录）或已注销，重新登录即可。
6. 接口返回 500 且日志出现 `Unknown column 'a.topic_id'`：数据库未执行 `sql/topic.sql`（话题功能增量迁移）。
