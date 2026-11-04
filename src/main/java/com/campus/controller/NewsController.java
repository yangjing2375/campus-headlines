package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;
import com.campus.entity.Channel;
import com.campus.entity.Comment;
import com.campus.entity.SysUser;
import com.campus.mapper.SysUserMapper;
import com.campus.service.*;
import com.campus.utils.R;
import com.campus.utils.SessionUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 学生端 - 资讯浏览 Controller（JSP 页面端）
 */
@Controller
@RequestMapping("/news")
public class NewsController {

    @Autowired private ArticleService articleService;
    @Autowired private ChannelService channelService;
    @Autowired private CommentService commentService;
    @Autowired private ArticleLikeService articleLikeService;
    @Autowired private ArticleFavoriteService articleFavoriteService;
    @Autowired private TopicService topicService;
    @Autowired private com.campus.mapper.ArticleMapper articleMapper;
    @Autowired private SysUserMapper userMapper;

    /** 首页 - 展示推荐流 */
    @GetMapping("/home")
    public String home(@RequestParam(defaultValue = "1") long page,
                       @RequestParam(defaultValue = "10") long size,
                       @RequestParam(required = false) Long channelId,
                       @RequestParam(required = false) String keyword,
                       Model model) {
        List<Channel> channels = channelService.listEnabled();
        IPage<Article> pageList = articleService.pagePublished(page, size, channelId, keyword);

        // 热门资讯 TOP8（综合热度 = 浏览 + 点赞 + 评论 倒序）
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
                Channel c = channelService.getById(a.getChannelId());
                if (c != null) a.setChannelName(c.getName());
            }
            if (a.getAuthorId() != null) {
                SysUser u = userMapper.selectById(a.getAuthorId());
                if (u != null) a.setAuthorName(u.getNickname() != null ? u.getNickname() : u.getUsername());
            }
        }

        // 置顶/紧急头条
        QueryWrapper<Article> topQw = new QueryWrapper<>();
        topQw.eq("status", 2).and(w -> w.eq("is_top", 1).or().eq("is_urgent", 1))
              .orderByDesc("is_top").orderByDesc("is_urgent").orderByDesc("publish_time").last("LIMIT 5");
        List<Article> topList = articleMapper.selectList(topQw);

        // Hero Banner（置顶优先，否则热门，取有封面的 5 篇）
        QueryWrapper<Article> bannerQw = new QueryWrapper<>();
        bannerQw.eq("status", 2).isNotNull("cover").orderByDesc("is_top").orderByDesc("view_count").last("LIMIT 5");
        List<Article> bannerList = articleMapper.selectList(bannerQw);

        model.addAttribute("channels", channels);
        model.addAttribute("pageList", pageList);
        model.addAttribute("currentChannel", channelId);
        model.addAttribute("keyword", keyword);
        model.addAttribute("hotList", hotList);
        model.addAttribute("topList", topList);
        model.addAttribute("bannerList", bannerList);
        model.addAttribute("hotTopics", topicService.listHot(8));
        return "student/home";
    }

    /** 资讯详情页 */
    @GetMapping("/detail/{id}")
    public String detail(@PathVariable Long id, Model model) {
        Article article = articleService.detail(id);
        if (article == null) return "redirect:/news/home";
        articleService.incrementView(id);
        model.addAttribute("article", article);

        SysUser login0 = SessionUtil.getLoginUser();
        List<Comment> comments = commentService.listTreeByArticle(id, login0 == null ? null : login0.getId());
        model.addAttribute("comments", comments);

        SysUser login = SessionUtil.getLoginUser();
        if (login != null) {
            model.addAttribute("liked", articleLikeService.isLiked(id, login.getId()));
            model.addAttribute("favorited", articleFavoriteService.isFavorited(id, login.getId()));
        } else {
            model.addAttribute("liked", false);
            model.addAttribute("favorited", false);
        }
        return "student/detail";
    }

    /** 点赞：返回最新状态与点赞数，供前端即时切换图标颜色 */
    @PostMapping("/like/{id}")
    @ResponseBody
    public R<?> like(@PathVariable Long id) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "请先登录");
        boolean liked = articleLikeService.toggleLike(id, login.getId());
        Article latest = articleMapper.selectById(id);
        java.util.Map<String, Object> data = new java.util.HashMap<>();
        data.put("liked", liked);
        data.put("likeCount", latest == null || latest.getLikeCount() == null ? 0 : latest.getLikeCount());
        return R.ok(liked ? "点赞成功" : "已取消点赞", data);
    }

    /** 收藏：返回最新状态与收藏数 */
    @PostMapping("/favorite/{id}")
    @ResponseBody
    public R<?> favorite(@PathVariable Long id) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "请先登录");
        boolean fav = articleFavoriteService.toggleFavorite(id, login.getId());
        Article latest = articleMapper.selectById(id);
        java.util.Map<String, Object> data = new java.util.HashMap<>();
        data.put("favorited", fav);
        data.put("favoriteCount", latest == null || latest.getFavoriteCount() == null ? 0 : latest.getFavoriteCount());
        return R.ok(fav ? "收藏成功" : "已取消收藏", data);
    }

    /** 搜索 */
    @GetMapping("/search")
    public String search(@RequestParam(required = false) String keyword,
                         @RequestParam(defaultValue = "1") long page,
                         @RequestParam(defaultValue = "10") long size,
                         Model model) {
        List<Channel> channels = channelService.listEnabled();
        IPage<Article> pageList = articleService.pagePublished(page, size, null, keyword);
        model.addAttribute("channels", channels);
        model.addAttribute("pageList", pageList);
        model.addAttribute("keyword", keyword);
        model.addAttribute("hotTopics", topicService.listHot(8));
        return "student/home";
    }

    /** 发表评论/回复 */
    @PostMapping("/comment")
    @ResponseBody
    public R<?> addComment(@RequestBody Comment comment) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "请先登录");
        try {
            commentService.add(comment.getArticleId(), login.getId(), comment.getContent(), comment.getParentId());
            return R.ok("评论成功");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 删除评论：本人或管理员（所有角色都可删自己的评论） */
    @PostMapping("/comment/delete/{id}")
    @ResponseBody
    public R<?> deleteComment(@PathVariable Long id) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "请先登录");
        try {
            boolean isAdmin = "ADMIN".equals(login.getRole());
            boolean ok = commentService.delete(id, login.getId(), isAdmin);
            return ok ? R.ok("删除成功") : R.fail("评论不存在");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 评论点赞/取消点赞：返回最新状态与点赞数 */
    @PostMapping("/comment/like/{id}")
    @ResponseBody
    public R<?> likeComment(@PathVariable Long id) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "请先登录");
        try {
            boolean liked = commentService.toggleLike(id, login.getId());
            Comment latest = commentService.getById(id);
            java.util.Map<String, Object> data = new java.util.HashMap<>();
            data.put("liked", liked);
            data.put("likeCount", latest == null || latest.getLikeCount() == null ? 0 : latest.getLikeCount());
            return R.ok(liked ? "点赞成功" : "已取消点赞", data);
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }
}
