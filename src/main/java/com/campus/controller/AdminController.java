package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.*;
import com.campus.mapper.*;
import com.campus.service.*;
import com.campus.utils.R;
import com.campus.utils.SessionUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * 管理员后台 Controller - 审核/管理/数据统计（JSP 页面端）
 */
@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired private ArticleService   articleService;
    @Autowired private ChannelService   channelService;
    @Autowired private CommentService   commentService;
    @Autowired private SysUserService   userService;
    @Autowired private TopicService     topicService;

    @Autowired private ArticleMapper    articleMapper;
    @Autowired private ChannelMapper    channelMapper;
    @Autowired private SysUserMapper    userMapper;
    @Autowired private CommentMapper    commentMapper;
    @Autowired private MediaApplyMapper mediaApplyMapper;
    @Autowired private TopicMapper      topicMapper;

    // ========== 1. 数据统计看板 ==========
    @GetMapping({"/", "/dashboard"})
    public String dashboard(@RequestParam(defaultValue = "7") int days, Model model) {

        // 热门资讯 TOP8：综合热度 = 浏览 + 点赞 + 评论
        QueryWrapper<Article> hotQw = new QueryWrapper<>();
        hotQw.eq("status", 2)
             .select("id", "title", "channel_id", "author_id", "source", "cover",
                     "view_count", "like_count", "comment_count", "favorite_count")
             .orderByDesc("view_count + like_count + comment_count")
             .last("LIMIT 8");
        List<Article> hotList = articleMapper.selectList(hotQw);
        // 补充频道/作者名
        for (Article a : hotList) {
            if (a.getChannelId() != null) {
                Channel c = channelMapper.selectById(a.getChannelId());
                if (c != null) a.setChannelName(c.getName());
            }
            if (a.getAuthorId() != null) {
                SysUser u = userMapper.selectById(a.getAuthorId());
                if (u != null) a.setAuthorName(u.getNickname() != null ? u.getNickname() : u.getUsername());
            }
        }

        model.addAttribute("hotList", hotList);
        model.addAllAttributes(buildDashboardData(days));
        return "admin/dashboard";
    }

    /** 看板数据接口：供页面动态刷新（统计卡片 + 图表） */
    @GetMapping("/dashboard/data")
    @ResponseBody
    public R<?> dashboardData(@RequestParam(defaultValue = "7") int days) {
        return R.ok(buildDashboardData(days));
    }

    /** 汇总看板数据：统计卡片 + 近 N 天发布趋势 + 稿件状态分布 + 频道发文分布 */
    private Map<String, Object> buildDashboardData(int days) {
        if (days != 7 && days != 14 && days != 30) days = 7;

        long totalReads = 0L, totalLikes = 0L, totalComments = 0L, totalFavs = 0L;
        for (Article a : articleMapper.selectList(null)) {
            totalReads    += a.getViewCount()     == null ? 0 : a.getViewCount();
            totalLikes    += a.getLikeCount()     == null ? 0 : a.getLikeCount();
            totalComments += a.getCommentCount()  == null ? 0 : a.getCommentCount();
            totalFavs     += a.getFavoriteCount() == null ? 0 : a.getFavoriteCount();
        }

        Map<String, Object> data = new HashMap<>();
        data.put("days", days);
        data.put("totalReads", totalReads);
        data.put("totalLikes", totalLikes);
        data.put("totalComments", totalComments);
        data.put("totalFavs", totalFavs);
        data.put("articleCount", articleMapper.selectCount(null));
        data.put("pendingCount", articleMapper.selectCount(new QueryWrapper<Article>().eq("status", 1)));
        data.put("commentCount", commentMapper.selectCount(null));
        data.put("userCount", userMapper.selectCount(null));
        data.put("topicCount", topicMapper.selectCount(null));
        data.put("pendingTopicCount", topicService.countPending());

        // 近 N 天发布趋势（已发布）
        java.time.LocalDate start = java.time.LocalDate.now().minusDays(days - 1);
        Map<String, Long> artDaily = toDailyMap(articleMapper.selectMaps(
                new QueryWrapper<Article>().select("DATE(publish_time) AS d", "COUNT(*) AS c")
                        .eq("status", 2).ge("publish_time", start.atStartOfDay())
                        .groupBy("DATE(publish_time)")));

        List<String> trendLabels = new ArrayList<>();
        List<Long> trendArticles = new ArrayList<>();
        java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("MM-dd");
        for (int i = days - 1; i >= 0; i--) {
            java.time.LocalDate d = java.time.LocalDate.now().minusDays(i);
            String key = d.toString();
            trendLabels.add(d.format(fmt));
            trendArticles.add(artDaily.getOrDefault(key, 0L));
        }
        data.put("trendLabels", trendLabels);
        data.put("trendArticles", trendArticles);

        // 稿件状态分布
        String[] statusNames = {"草稿", "待审核", "已发布", "已驳回", "已下架"};
        long[] statusValues = new long[5];
        for (Map<String, Object> row : articleMapper.selectMaps(
                new QueryWrapper<Article>().select("status", "COUNT(*) AS c").groupBy("status"))) {
            Object st = row.get("status");
            Object c = row.get("c");
            int idx = st == null ? -1 : ((Number) st).intValue();
            if (idx >= 0 && idx < 5 && c != null) statusValues[idx] = ((Number) c).longValue();
        }
        data.put("statusNames", java.util.Arrays.asList(statusNames));
        data.put("statusValues", statusValues);

        // 频道发文分布（已发布，前 6）
        List<Map<String, Object>> channelRows = articleMapper.selectMaps(
                new QueryWrapper<Article>().select("channel_id", "COUNT(*) AS c")
                        .eq("status", 2).groupBy("channel_id").orderByDesc("c").last("LIMIT 6"));
        List<String> channelLabels = new ArrayList<>();
        List<Long> channelValues = new ArrayList<>();
        for (Map<String, Object> row : channelRows) {
            Object cid = row.get("channel_id");
            Object c = row.get("c");
            String name = "未分类";
            if (cid != null) {
                Channel ch = channelMapper.selectById(((Number) cid).longValue());
                if (ch != null) name = ch.getName();
            }
            channelLabels.add(name);
            channelValues.add(c == null ? 0L : ((Number) c).longValue());
        }
        data.put("channelLabels", channelLabels);
        data.put("channelValues", channelValues);
        return data;
    }

    /** 把 DATE(publish_time) 分组结果转成 "yyyy-MM-dd" -> 数量 的 Map */
    private Map<String, Long> toDailyMap(List<Map<String, Object>> rows) {
        Map<String, Long> map = new HashMap<>();
        for (Map<String, Object> row : rows) {
            Object d = row.get("d");
            Object c = row.get("c");
            if (d != null && c != null) {
                map.put(String.valueOf(d), ((Number) c).longValue());
            }
        }
        return map;
    }

    // ========== 2. 审核中心 ==========
    @GetMapping("/audit")
    public String auditList(@RequestParam(defaultValue = "1") long page,
                            @RequestParam(defaultValue = "10") long size,
                            @RequestParam(required = false) Integer status,
                            @RequestParam(required = false) String keyword,
                            Model model) {
        IPage<Article> pageList = articleService.pageAdmin(page, size,
                status == null ? 1 : status, null, null, keyword);
        model.addAttribute("pageList", pageList);
        model.addAttribute("status", status);
        model.addAttribute("keyword", keyword);
        return "admin/audit";
    }

    /** 审核通过 */
    @PostMapping("/audit/pass/{id}")
    @ResponseBody
    public R<?> auditPass(@PathVariable Long id) {
        SysUser admin = SessionUtil.getLoginUser();
        boolean ok = articleService.approve(id, admin.getId());
        return ok ? R.ok("审核通过，已发布") : R.fail("操作失败");
    }

    /** 审核驳回 */
    @PostMapping("/audit/reject/{id}")
    @ResponseBody
    public R<?> auditReject(@PathVariable Long id, @RequestParam String reason) {
        SysUser admin = SessionUtil.getLoginUser();
        boolean ok = articleService.reject(id, admin.getId(), reason);
        return ok ? R.ok("已驳回") : R.fail("操作失败");
    }

    // ========== 2.1 稿件详情 ==========
    /** 审核 / 文章管理页的查看详情（返回 JSON，供前端弹窗渲染） */
    @GetMapping("/article/detail/{id}")
    @ResponseBody
    public R<?> articleDetail(@PathVariable Long id) {
        Article a = articleService.detail(id);
        if (a == null) return R.fail("稿件不存在");
        // 前端表格字段用 authorName / channelName
        if (a.getAuthorId() != null) {
            SysUser u = userMapper.selectById(a.getAuthorId());
            if (u != null) a.setAuthorName(u.getNickname() != null ? u.getNickname() : u.getUsername());
        }
        if (a.getChannelId() != null) {
            Channel c = channelMapper.selectById(a.getChannelId());
            if (c != null) a.setChannelName(c.getName());
        }
        return R.ok(a);
    }

    // ========== 3. 文章管理 ==========
    @GetMapping("/articles")
    public String articleList(@RequestParam(defaultValue = "1") long page,
                              @RequestParam(defaultValue = "10") long size,
                              @RequestParam(required = false) Long channelId,
                              @RequestParam(required = false) Integer status,
                              @RequestParam(required = false) String keyword,
                              Model model) {
        List<Channel> channels = channelService.listAll();
        IPage<Article> pageList = articleService.pageAdmin(page, size, status, channelId, null, keyword);
        model.addAttribute("channels", channels);
        model.addAttribute("pageList", pageList);
        model.addAttribute("channelId", channelId);
        model.addAttribute("status", status);
        model.addAttribute("keyword", keyword);
        return "admin/articles";
    }

    /** 置顶/取消置顶 */
    @PostMapping("/article/top/{id}")
    @ResponseBody
    public R<?> toggleTop(@PathVariable Long id, @RequestParam Integer isTop) {
        Article update = new Article();
        update.setId(id);
        update.setIsTop(isTop);
        return articleMapper.updateById(update) > 0 ? R.ok("操作成功") : R.fail("操作失败");
    }

    /** 紧急标红 */
    @PostMapping("/article/urgent/{id}")
    @ResponseBody
    public R<?> toggleUrgent(@PathVariable Long id, @RequestParam Integer isUrgent) {
        Article update = new Article();
        update.setId(id);
        update.setIsUrgent(isUrgent);
        return articleMapper.updateById(update) > 0 ? R.ok("操作成功") : R.fail("操作失败");
    }

    /** 下架 */
    @PostMapping("/article/offShelf/{id}")
    @ResponseBody
    public R<?> offShelf(@PathVariable Long id) {
        boolean ok = articleService.offline(id);
        return ok ? R.ok("已下架") : R.fail("操作失败");
    }

    /** 删除文章 */
    @PostMapping("/article/delete/{id}")
    @ResponseBody
    public R<?> deleteArticle(@PathVariable Long id) {
        return articleMapper.deleteById(id) > 0 ? R.ok("已删除") : R.fail("操作失败");
    }

    // ========== 4. 频道管理 ==========
    @GetMapping("/categories")
    public String categoryList(Model model) {
        List<Channel> list = channelService.listAll();
        model.addAttribute("categories", list);
        return "admin/categories";
    }

    @PostMapping("/category/add")
    @ResponseBody
    public R<?> addCategory(@RequestBody Channel channel) {
        boolean ok = channelService.add(channel);
        return ok ? R.ok("新增成功") : R.fail("操作失败");
    }

    @PostMapping("/category/update")
    @ResponseBody
    public R<?> updateCategory(@RequestBody Channel channel) {
        boolean ok = channelService.update(channel);
        return ok ? R.ok("更新成功") : R.fail("操作失败");
    }

    @PostMapping("/category/delete/{id}")
    @ResponseBody
    public R<?> deleteCategory(@PathVariable Long id) {
        boolean ok = channelService.delete(id);
        return ok ? R.ok("删除成功") : R.fail("操作失败");
    }

    // ========== 5. 用户管理 ==========
    @GetMapping("/users")
    public String userList(@RequestParam(defaultValue = "1") long page,
                           @RequestParam(defaultValue = "10") long size,
                           @RequestParam(required = false) String keyword,
                           @RequestParam(required = false) String role,
                           Model model) {
        IPage<SysUser> pageList = userService.pageList(page, size, keyword, role);
        for (SysUser u : pageList.getRecords()) u.setPassword(null);
        model.addAttribute("pageList", pageList);
        model.addAttribute("keyword", keyword);
        model.addAttribute("role", role);
        return "admin/users";
    }

    /** 封禁/解封用户 */
    @PostMapping("/user/status/{id}")
    @ResponseBody
    public R<?> toggleUserStatus(@PathVariable Long id, @RequestParam Integer status) {
        boolean ok = userService.updateStatus(id, status);
        return ok ? R.ok("操作成功") : R.fail("操作失败");
    }

    /** 分配角色 */
    @PostMapping("/user/role/{id}")
    @ResponseBody
    public R<?> updateUserRole(@PathVariable Long id, @RequestParam String role) {
        boolean ok = userService.updateRole(id, role);
        return ok ? R.ok("操作成功") : R.fail("操作失败");
    }

    // ========== 6. 评论管理 ==========
    @GetMapping("/comments")
    public String commentList(@RequestParam(defaultValue = "1") long page,
                              @RequestParam(defaultValue = "10") long size,
                              @RequestParam(required = false) String keyword,
                              Model model) {
        IPage<Comment> pageList = commentService.pageAdmin(page, size, keyword);
        model.addAttribute("pageList", pageList);
        model.addAttribute("keyword", keyword);
        return "admin/comments";
    }

    @PostMapping("/comment/delete/{id}")
    @ResponseBody
    public R<?> deleteComment(@PathVariable Long id) {
        boolean ok = commentService.adminDelete(id);
        return ok ? R.ok("删除成功") : R.fail("操作失败");
    }

    // ========== 7. 自媒体人申请审核 ==========
    @GetMapping("/media-applies")
    public String mediaApplies(@RequestParam(defaultValue = "1") long page,
                               @RequestParam(defaultValue = "10") long size,
                               @RequestParam(required = false) Integer status,
                               Model model) {
        QueryWrapper<MediaApply> qw = new QueryWrapper<>();
        if (status != null) qw.eq("status", status);
        qw.orderByDesc("id");
        IPage<MediaApply> pageList = mediaApplyMapper.selectPage(
                new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(page, size), qw);

        for (MediaApply m : pageList.getRecords()) {
            SysUser u = userMapper.selectById(m.getUserId());
            if (u != null) {
                m.setUserName(StringUtils.hasText(u.getNickname()) ? u.getNickname() : u.getUsername());
                m.setUserCollege(u.getCollege());
                m.setUserPhone(u.getPhone());
            }
        }

        model.addAttribute("pageList", pageList);
        model.addAttribute("status", status);
        model.addAttribute("pendingApply", mediaApplyMapper.selectCount(
                new QueryWrapper<MediaApply>().eq("status", 0)));
        model.addAttribute("passedApply", mediaApplyMapper.selectCount(
                new QueryWrapper<MediaApply>().eq("status", 1)));
        model.addAttribute("rejectedApply", mediaApplyMapper.selectCount(
                new QueryWrapper<MediaApply>().eq("status", 2)));
        return "admin/media-applies";
    }

    /** 通过申请：申请记录置为已通过，并把用户角色升级为自媒体人 */
    @PostMapping("/media/approve/{id}")
    @ResponseBody
    public R<?> approveMedia(@PathVariable Long id) {
        MediaApply apply = mediaApplyMapper.selectById(id);
        if (apply == null) return R.fail("申请记录不存在");
        if (apply.getStatus() != null && apply.getStatus() != 0) return R.fail("该申请已处理过");

        SysUser user = userMapper.selectById(apply.getUserId());
        if (user == null) return R.fail("申请人不存在");

        SysUser upd = new SysUser();
        upd.setId(user.getId());
        upd.setRole("MEDIA");
        userMapper.updateById(upd);

        MediaApply rec = new MediaApply();
        rec.setId(id);
        rec.setStatus(1);
        rec.setAuditorId(SessionUtil.getLoginUser().getId());
        rec.setAuditTime(new java.util.Date());
        mediaApplyMapper.updateById(rec);
        return R.ok("已通过，该用户已升级为自媒体人");
    }

    /** 驳回申请：必须填写驳回理由 */
    @PostMapping("/media/reject/{id}")
    @ResponseBody
    public R<?> rejectMedia(@PathVariable Long id, @RequestParam String reason) {
        MediaApply apply = mediaApplyMapper.selectById(id);
        if (apply == null) return R.fail("申请记录不存在");
        if (apply.getStatus() != null && apply.getStatus() != 0) return R.fail("该申请已处理过");
        String r = reason == null ? "" : reason.trim();
        if (r.isEmpty()) return R.fail("请填写驳回理由");
        if (r.length() > 255) return R.fail("驳回理由不能超过 255 字");

        MediaApply rec = new MediaApply();
        rec.setId(id);
        rec.setStatus(2);
        rec.setRejectReason(r);
        rec.setAuditorId(SessionUtil.getLoginUser().getId());
        rec.setAuditTime(new java.util.Date());
        mediaApplyMapper.updateById(rec);
        return R.ok("已驳回");
    }

    // ========== 8. 话题管理 ==========
    @GetMapping("/topics")
    public String topicList(@RequestParam(defaultValue = "1") long page,
                            @RequestParam(defaultValue = "10") long size,
                            @RequestParam(required = false) Integer status,
                            @RequestParam(required = false) String keyword,
                            Model model) {
        model.addAttribute("pageList", topicService.pageAdmin(page, size, status, keyword));
        model.addAttribute("status", status);
        model.addAttribute("keyword", keyword);
        model.addAttribute("pendingTopicCount", topicService.countPending());
        model.addAttribute("topicCount", topicMapper.selectCount(null));
        return "admin/topics";
    }

    /** 话题详情（编辑弹窗回填） */
    @GetMapping("/topic/detail/{id}")
    @ResponseBody
    public R<?> topicDetail(@PathVariable Long id) {
        Topic topic = topicService.detail(id, null);
        return topic != null ? R.ok(topic) : R.fail("话题不存在");
    }

    /** 新建 / 编辑话题（管理员创建的立即上线） */
    @PostMapping("/topic/save")
    @ResponseBody
    public R<?> topicSave(@RequestBody Topic topic) {
        try {
            if (topic.getId() == null) {
                Long id = topicService.adminCreate(topic, SessionUtil.getLoginUser().getId());
                return R.ok("话题已创建并上线", id);
            }
            boolean ok = topicService.adminUpdate(topic);
            return ok ? R.ok("话题已更新") : R.fail("保存失败");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 审核通过 */
    @PostMapping("/topic/pass/{id}")
    @ResponseBody
    public R<?> topicPass(@PathVariable Long id) {
        try {
            boolean ok = topicService.auditPass(id);
            return ok ? R.ok("审核通过，话题已上线") : R.fail("操作失败");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 审核驳回 */
    @PostMapping("/topic/reject/{id}")
    @ResponseBody
    public R<?> topicReject(@PathVariable Long id, @RequestParam String reason) {
        try {
            boolean ok = topicService.auditReject(id, reason);
            return ok ? R.ok("已驳回") : R.fail("操作失败");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 设置/取消热门 */
    @PostMapping("/topic/hot/{id}")
    @ResponseBody
    public R<?> topicHot(@PathVariable Long id, @RequestParam Integer isHot) {
        try {
            boolean ok = topicService.toggleHot(id, isHot);
            return ok ? R.ok(isHot == 1 ? "已设为热门" : "已取消热门") : R.fail("操作失败");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 上线 / 禁用 */
    @PostMapping("/topic/status/{id}")
    @ResponseBody
    public R<?> topicStatus(@PathVariable Long id, @RequestParam Integer status) {
        try {
            boolean ok = topicService.changeStatus(id, status);
            return ok ? R.ok(status == 1 ? "话题已上线" : "话题已禁用") : R.fail("操作失败");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 删除话题（有文章引用时拒绝） */
    @PostMapping("/topic/delete/{id}")
    @ResponseBody
    public R<?> topicDelete(@PathVariable Long id) {
        try {
            boolean ok = topicService.adminDelete(id);
            return ok ? R.ok("删除成功") : R.fail("话题不存在");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }
}
