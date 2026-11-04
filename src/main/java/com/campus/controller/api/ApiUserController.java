package com.campus.controller.api;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;
import com.campus.entity.Channel;
import com.campus.entity.Comment;
import com.campus.entity.SysUser;
import com.campus.entity.Topic;
import com.campus.interceptor.TokenInterceptor;
import com.campus.service.*;
import com.campus.utils.R;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户端接口 - 对应文档 6.3（角色：USER / 游客）
 * 游客可访问：channels、articles 列表/详情、comments 列表
 * 需登录：like、favorite、comments POST、favorites
 */
@RestController
@RequestMapping("/api/user")
public class ApiUserController {

    @Autowired
    private ChannelService channelService;

    @Autowired
    private ArticleService articleService;

    @Autowired
    private CommentService commentService;

    @Autowired
    private ArticleLikeService articleLikeService;

    @Autowired
    private ArticleFavoriteService articleFavoriteService;

    @Autowired
    private TopicService topicService;

    private SysUser currentUser(HttpServletRequest request) {
        return (SysUser) request.getAttribute(TokenInterceptor.ATTR_USER);
    }

    /** 需要登录的接口使用：未登录返回 401 */
    private SysUser requireUser(HttpServletRequest request) {
        SysUser user = currentUser(request);
        if (user == null) {
            throw new com.campus.exception.BusinessException(401, "请先登录");
        }
        return user;
    }

    /** 频道列表（游客可访问） */
    @GetMapping("/channels")
    public R<List<Channel>> channels() {
        return R.ok(channelService.listEnabled());
    }

    /** 文章列表（按频道、分页、关键词；游客可访问） */
    @GetMapping("/articles")
    public R<IPage<Article>> articles(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Long channelId,
            @RequestParam(required = false) String keyword) {
        IPage<Article> page = articleService.pagePublished(current, size, channelId, keyword);
        return R.ok(page);
    }

    /** 文章详情（阅读量+1；游客可访问，仅已发布文章） */
    @GetMapping("/articles/{id}")
    public R<Article> articleDetail(@PathVariable Long id) {
        Article article = articleService.detail(id);
        // 缺陷 BUG-01：草稿/待审/驳回/已下架文章不允许通过用户端接口越权查看
        if (article == null || article.getStatus() == null || article.getStatus() != 2) {
            return R.fail(404, "文章不存在或已下线");
        }
        articleService.incrementView(id);
        return R.ok(article);
    }

    /** 点赞/取消点赞（需登录） */
    @PostMapping("/articles/{id}/like")
    public R<Map<String, Object>> like(@PathVariable Long id, HttpServletRequest request) {
        boolean liked = articleLikeService.toggleLike(id, requireUser(request).getId());
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("liked", liked);
        return R.ok(data);
    }

    /** 收藏/取消收藏（需登录） */
    @PostMapping("/articles/{id}/favorite")
    public R<Map<String, Object>> favorite(@PathVariable Long id, HttpServletRequest request) {
        boolean favorited = articleFavoriteService.toggleFavorite(id, requireUser(request).getId());
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("favorited", favorited);
        return R.ok(data);
    }

    /** 评论列表（游客可访问，楼中楼树形） */
    @GetMapping("/articles/{id}/comments")
    public R<List<Comment>> comments(@PathVariable Long id) {
        return R.ok(commentService.listTreeByArticle(id, null));
    }

    /** 发表评论/回复（需登录） */
    @PostMapping("/articles/{id}/comments")
    public R<Comment> addComment(@PathVariable Long id,
                                 @RequestBody Map<String, String> body,
                                 HttpServletRequest request) {
        String content = body == null ? null : body.get("content");
        Long parentId = null;
        if (body != null && body.get("parentId") != null && !body.get("parentId").isEmpty()) {
            parentId = Long.valueOf(body.get("parentId"));
        }
        Comment comment = commentService.add(id, requireUser(request).getId(), content, parentId);
        return R.ok("评论成功", comment);
    }

    /** 我的收藏列表（需登录） */
    @GetMapping("/favorites")
    public R<IPage<Article>> favorites(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            HttpServletRequest request) {
        IPage<Article> page = articleFavoriteService.listUserFavorites(current, size, requireUser(request).getId());
        return R.ok(page);
    }

    // ==================== 话题（游客可浏览，登录后可关注） ====================

    /** 话题广场：已上线话题分页 */
    @GetMapping("/topics")
    public R<IPage<Topic>> topics(@RequestParam(defaultValue = "1") long current,
                                  @RequestParam(defaultValue = "12") long size,
                                  @RequestParam(required = false) String keyword,
                                  HttpServletRequest request) {
        SysUser user = currentUser(request);
        return R.ok(topicService.pageOnline(current, size, keyword, user == null ? null : user.getId()));
    }

    /** 热门话题 */
    @GetMapping("/topics/hot")
    public R<List<Topic>> hotTopics(@RequestParam(defaultValue = "8") int limit) {
        return R.ok(topicService.listHot(limit));
    }

    /** 话题详情 */
    @GetMapping("/topics/{id}")
    public R<Topic> topicDetail(@PathVariable Long id, HttpServletRequest request) {
        SysUser user = currentUser(request);
        Topic topic = topicService.detail(id, user == null ? null : user.getId());
        if (topic == null || topic.getStatus() == null || topic.getStatus() != 1) {
            return R.fail("话题不存在或未上线");
        }
        return R.ok(topic);
    }

    /** 话题下的文章列表 */
    @GetMapping("/topics/{id}/articles")
    public R<IPage<Article>> topicArticles(@PathVariable Long id,
                                           @RequestParam(defaultValue = "1") long current,
                                           @RequestParam(defaultValue = "10") long size,
                                           @RequestParam(required = false) String keyword) {
        return R.ok(topicService.pageArticles(current, size, id, keyword));
    }

    /** 关注/取消关注（需登录） */
    @PostMapping("/topics/{id}/follow")
    public R<Map<String, Object>> followTopic(@PathVariable Long id, HttpServletRequest request) {
        boolean followed = topicService.toggleFollow(id, requireUser(request).getId());
        Topic latest = topicService.detail(id, requireUser(request).getId());
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("followed", followed);
        data.put("followerCount", latest == null || latest.getFollowerCount() == null ? 0 : latest.getFollowerCount());
        return R.ok(data);
    }
}
