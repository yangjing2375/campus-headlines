package com.campus.controller.api;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.*;
import com.campus.interceptor.TokenInterceptor;
import com.campus.mapper.ArticleMapper;
import com.campus.mapper.ChannelMapper;
import com.campus.mapper.SysUserMapper;
import com.campus.service.*;
import com.campus.utils.R;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理后台接口 - 对应文档 6.4（角色：AUDITOR / ADMIN）
 */
@RestController
@RequestMapping("/api/admin")
public class ApiAdminController {

    @Autowired
    private ArticleService articleService;

    @Autowired
    private SysUserService userService;

    @Autowired
    private ChannelService channelService;

    @Autowired
    private CommentService commentService;

    @Autowired
    private TopicService topicService;

    @Autowired
    private ArticleMapper articleMapper;

    @Autowired
    private SysUserMapper sysUserMapper;

    @Autowired
    private ChannelMapper channelMapper;

    private SysUser currentUser(HttpServletRequest request) {
        return (SysUser) request.getAttribute(TokenInterceptor.ATTR_USER);
    }

    // ===================== 审核管理 =====================

    /** 待审核文章列表（分页） */
    @GetMapping("/articles/pending")
    public R<IPage<Article>> pendingArticles(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size) {
        IPage<Article> page = articleService.pageAdmin(current, size, 1, null, null, null);
        return R.ok(page);
    }

    /** 审核通过 */
    @PostMapping("/articles/{id}/approve")
    public R<?> approve(@PathVariable Long id, HttpServletRequest request) {
        boolean ok = articleService.approve(id, currentUser(request).getId());
        return ok ? R.ok("审核通过") : R.fail("操作失败");
    }

    /** 审核驳回 */
    @PostMapping("/articles/{id}/reject")
    public R<?> reject(@PathVariable Long id,
                       @RequestBody(required = false) Map<String, String> body,
                       HttpServletRequest request) {
        String reason = body == null ? "" : body.getOrDefault("reason", "");
        boolean ok = articleService.reject(id, currentUser(request).getId(), reason);
        return ok ? R.ok("已驳回") : R.fail("操作失败");
    }

    /** 下架文章 */
    @PostMapping("/articles/{id}/offline")
    public R<?> offline(@PathVariable Long id) {
        boolean ok = articleService.offline(id);
        return ok ? R.ok("已下架") : R.fail("操作失败");
    }

    // ===================== 用户管理 =====================

    /** 用户列表 */
    @GetMapping("/users")
    public R<IPage<SysUser>> users(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String role) {
        IPage<SysUser> page = userService.pageList(current, size, keyword, role);
        // 脱敏
        for (SysUser u : page.getRecords()) u.setPassword(null);
        return R.ok(page);
    }

    /** 启用/禁用用户 */
    @PutMapping("/users/{id}/status")
    public R<?> updateUserStatus(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Integer status = body.get("status") == null ? null : ((Number) body.get("status")).intValue();
        boolean ok = userService.updateStatus(id, status);
        return ok ? R.ok("操作成功") : R.fail("操作失败");
    }

    /** 分配角色 */
    @PutMapping("/users/{id}/role")
    public R<?> updateUserRole(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String role = body == null ? null : body.get("role");
        boolean ok = userService.updateRole(id, role);
        return ok ? R.ok("角色已更新") : R.fail("操作失败");
    }

    // ===================== 频道管理 =====================

    /** 频道列表 */
    @GetMapping("/channels")
    public R<List<Channel>> channels() {
        return R.ok(channelService.listAll());
    }

    /** 新增频道 */
    @PostMapping("/channels")
    public R<Channel> addChannel(@RequestBody Channel channel) {
        channelService.add(channel);
        return R.ok("新增成功", channel);
    }

    /** 更新频道 */
    @PutMapping("/channels/{id}")
    public R<?> updateChannel(@PathVariable Long id, @RequestBody Channel channel) {
        channel.setId(id);
        boolean ok = channelService.update(channel);
        return ok ? R.ok("更新成功") : R.fail("更新失败");
    }

    /** 删除频道 */
    @DeleteMapping("/channels/{id}")
    public R<?> deleteChannel(@PathVariable Long id) {
        boolean ok = channelService.delete(id);
        return ok ? R.ok("删除成功") : R.fail("删除失败");
    }

    // ===================== 文章管理 =====================

    /** 全站文章列表（多条件） */
    @GetMapping("/articles")
    public R<IPage<Article>> articles(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Long channelId,
            @RequestParam(required = false) Long authorId,
            @RequestParam(required = false) String keyword) {
        IPage<Article> page = articleService.pageAdmin(current, size, status, channelId, authorId, keyword);
        return R.ok(page);
    }

    /** 删除文章 */
    @DeleteMapping("/articles/{id}")
    public R<?> deleteArticle(@PathVariable Long id) {
        Article article = articleMapper.selectById(id);
        if (article == null) return R.fail("文章不存在");
        articleMapper.deleteById(id);
        return R.ok("删除成功");
    }

    // ===================== 评论管理 =====================

    /** 评论列表 */
    @GetMapping("/comments")
    public R<IPage<Comment>> comments(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) String keyword) {
        IPage<Comment> page = commentService.pageAdmin(current, size, keyword);
        return R.ok(page);
    }

    /** 删除评论 */
    @DeleteMapping("/comments/{id}")
    public R<?> deleteComment(@PathVariable Long id) {
        boolean ok = commentService.adminDelete(id);
        return ok ? R.ok("删除成功") : R.fail("删除失败");
    }

    // ===================== 数据统计 =====================

    /** 数据统计 */
    @GetMapping("/statistics")
    public R<Map<String, Object>> statistics() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("articleCount", articleMapper.selectCount(null));
        data.put("userCount", sysUserMapper.selectCount(null));
        data.put("channelCount", channelMapper.selectCount(null));
        data.put("topicCount", topicService.pageAdmin(1, 1, null, null).getTotal());
        data.put("pendingTopicCount", topicService.countPending());

        // 各频道文章分布
        QueryWrapper<Channel> cqw = new QueryWrapper<>();
        cqw.eq("status", 1);
        List<Channel> channels = channelMapper.selectList(cqw);
        java.util.List<Map<String, Object>> channelDist = new java.util.ArrayList<>();
        for (Channel c : channels) {
            QueryWrapper<Article> aqw = new QueryWrapper<>();
            aqw.eq("channel_id", c.getId()).eq("status", 2);
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("channelId", c.getId());
            item.put("channelName", c.getName());
            item.put("count", articleMapper.selectCount(aqw));
            channelDist.add(item);
        }
        data.put("channelDistribution", channelDist);
        return R.ok(data);
    }

    // ===================== 话题管理 =====================

    /** 话题列表（按状态 / 关键词） */
    @GetMapping("/topics")
    public R<IPage<Topic>> topics(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword) {
        return R.ok(topicService.pageAdmin(current, size, status, keyword));
    }

    /** 话题详情 */
    @GetMapping("/topics/{id}")
    public R<Topic> topicDetail(@PathVariable Long id) {
        Topic topic = topicService.detail(id, null);
        return topic != null ? R.ok(topic) : R.fail("话题不存在");
    }

    /** 审核通过 */
    @PostMapping("/topics/{id}/approve")
    public R<?> approveTopic(@PathVariable Long id) {
        boolean ok = topicService.auditPass(id);
        return ok ? R.ok("审核通过，话题已上线") : R.fail("操作失败");
    }

    /** 审核驳回 */
    @PostMapping("/topics/{id}/reject")
    public R<?> rejectTopic(@PathVariable Long id,
                            @RequestBody(required = false) Map<String, String> body) {
        String reason = body == null ? "" : body.getOrDefault("reason", "");
        boolean ok = topicService.auditReject(id, reason);
        return ok ? R.ok("已驳回") : R.fail("操作失败");
    }

    /** 上线 / 禁用 */
    @PutMapping("/topics/{id}/status")
    public R<?> updateTopicStatus(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Integer status = body.get("status") == null ? null : ((Number) body.get("status")).intValue();
        boolean ok = topicService.changeStatus(id, status);
        return ok ? R.ok("操作成功") : R.fail("操作失败");
    }

    /** 设置 / 取消热门 */
    @PutMapping("/topics/{id}/hot")
    public R<?> updateTopicHot(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Integer isHot = body.get("isHot") == null ? 0 : ((Number) body.get("isHot")).intValue();
        boolean ok = topicService.toggleHot(id, isHot);
        return ok ? R.ok("操作成功") : R.fail("操作失败");
    }

    /** 删除话题（有文章引用时拒绝） */
    @DeleteMapping("/topics/{id}")
    public R<?> deleteTopic(@PathVariable Long id) {
        boolean ok = topicService.adminDelete(id);
        return ok ? R.ok("删除成功") : R.fail("话题不存在");
    }
}
