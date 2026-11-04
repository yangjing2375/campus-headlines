# GitHub Issues 缺陷单（8 条）

> 缺陷不只记在 Excel 里，同时登记为 Issue，形成「发现 → 提单 → 修复 → 回归 → 关闭」的完整生命周期。
> 下面是可以直接粘贴到 GitHub 的 Issue 内容（标题 / 标签 / 正文）。

建议先建 5 个标签：`bug`（红）、`security`（橙）、`P0`、`P1`、`P2`、`regression`（灰）。

---

## Issue 1 · BUG-01 未发布文章可被越权查看

- **标题**：`[BUG-01] 未发布的草稿/待审文章可通过用户端接口越权查看`
- **标签**：`bug` `security` `P1`
- **正文**：

```markdown
## 问题描述
`GET /api/user/articles/{id}` 只判断文章是否存在，未校验状态，导致 status=0/1/3/4 的稿件正文可被任意人查看。

## 复现步骤
1. editor01 登录，新建草稿，记下 id（如 70）
2. 退出登录
3. 请求 `GET /api/user/articles/70`

## 实际结果
HTTP 200，返回草稿标题与全文。

## 期望结果
业务码 404，提示「文章不存在或已下线」，不返回任何正文内容。

## 影响
内容未上线即泄露（信息泄露），并绕过审核流程。

## 修复
`ApiUserController#articleDetail` 增加 `status != 2 → R.fail(404, ...)`。

## 回归
`UC-065` 通过；Postman「异常-未发布文章不可访问」用例通过。
```

## Issue 2 · BUG-02 分页参数越界导致 500

- **标题**：`[BUG-02] 分页参数 current=-1 / size=100000 时接口报 500`
- **标签**：`bug` `P2`
- **要点**：负 offset 生成非法 LIMIT；超大 size 造成全表扫描。修复：新增 `PageUtil` 归一化（`current ≥ 1`，`1 ≤ size ≤ 50`），三处分页统一调用。回归用例 `UC-066`、`PageUtilTest`。

## Issue 3 · BUG-03 删除被引用频道报外键异常

- **标题**：`[BUG-03] 删除仍有文章的频道时返回 500（外键约束 1451）`
- **标签**：`bug` `P1`
- **要点**：`ChannelServiceImpl#delete` 直接 `deleteById`。修复：删除前统计 `channel_id` 下文章数，>0 抛业务异常返回 400「该频道下仍有文章，无法删除」。回归用例 `UC-058`。

## Issue 4 · BUG-04 并发点赞丢失更新

- **标题**：`[BUG-04] 同一文章并发点赞时 like_count 与明细不一致`
- **标签**：`bug` `P1`
- **要点**：「查旧值 → 内存 +1 → updateById」存在丢失更新；10 并发实测 7/10。修复：`setSql("like_count = IFNULL(like_count,0)+1")`。回归用例 `UC-020`。

## Issue 5 · BUG-05 并发访问详情阅读量丢失

- **标题**：`[BUG-05] 50 并发访问文章详情后 view_count 小于请求数`
- **标签**：`bug` `P2`
- **要点**：同 BUG-04 的读改写模式。修复：`incrementView` 改为原子自增。回归用例 `UC-021`。

## Issue 6 · BUG-06 上传仅校验扩展名

- **标题**：`[BUG-06] 素材上传只校验后缀，改名的非图片文件可上传成功`
- **标签**：`bug` `security` `P2`
- **要点**：`.jpg` 后缀 + HTML 内容可上传并被静态资源访问。修复：增加文件头 magic number 校验（jpg `FFD8FF`、png `89504E47`、gif `GIF8`、mp4 `ftyp`）。回归用例 `UC-043`。

## Issue 7 · BUG-07 存储型 XSS（遗留）

- **标题**：`[BUG-07] 文章正文未转义，存在存储型 XSS`
- **标签**：`bug` `security` `P0`
- **正文**：

```markdown
## 问题描述
`student/detail.jsp` 直接输出 `${article.content}`，正文中的脚本会被浏览器执行。

## 复现步骤
1. editor01 新建稿件，正文填入 `<script>alert('xss')</script>`
2. 管理员审核通过
3. 打开文章详情页 → 触发弹窗

## 期望结果
脚本被清洗或转义，不执行。

## 修复计划
- 服务端：引入 Jsoup `Safelist` 白名单清洗后再入库（推荐）
- 前端：`<c:out value="${article.content}" escapeXml="true"/>` 或仅允许安全标签
- 附加：管理后台增加 CSP 头

## 当前状态
遗留（demo 仅本地运行，未对外开放）
```

## Issue 8 · BUG-08 密码 MD5 无盐（遗留）

- **标题**：`[BUG-08] 用户密码使用无盐 MD5 存储`
- **标签**：`bug` `security` `P2`
- **要点**：32 位 MD5 可被彩虹表反查。修复计划：迁移 BCrypt（`{bcrypt}` 前缀识别），登录成功时对旧 MD5 平滑升级；演示数据保持兼容。回归用例 `UC-068`。

---

## 如何在 GitHub 上创建

**方式 A（推荐，可视化）**：仓库 → Issues → New issue → 选择模板 `Bug 报告` → 按上面内容填写 → 右侧添加 Labels → Create。

**方式 B（命令行，需安装 gh 并登录）**：

```bash
gh label create bug --color d73a4a
gh label create security --color d93f0b
gh label create P0 --color b60205
gh label create P1 --color e99695
gh label create P2 --color fef2c0

gh issue create --title "[BUG-01] 未发布的草稿可被越权查看" --label bug,security,P1 --body-file .github/ISSUE_TEMPLATE/bug_report.md
```

**方式 C（REST API）**：`POST https://api.github.com/repos/yangjing2375/<repo>/issues`，Header 带 `Authorization: Bearer <token>`，Body 传 `title / body / labels`。

> 建议：BUG-01~06 修复完成后创建并**立即关闭**（关闭时在评论里贴回归结果）；BUG-07、BUG-08 保持 Open，体现「缺陷不是全绿，遗留有跟踪」。
