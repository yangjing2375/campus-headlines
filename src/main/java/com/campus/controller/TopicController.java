package com.campus.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;
import com.campus.entity.SysUser;
import com.campus.entity.Topic;
import com.campus.service.TopicService;
import com.campus.utils.R;
import com.campus.utils.SessionUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 用户端 - 话题广场 Controller（JSP 页面端）
 * 游客可浏览话题列表/详情，登录后可关注/取关
 */
@Controller
@RequestMapping("/topic")
public class TopicController {

    @Autowired
    private TopicService topicService;

    /** 话题广场：已上线话题分页 */
    @GetMapping({"/list", "/"})
    public String list(@RequestParam(defaultValue = "1") long page,
                       @RequestParam(defaultValue = "12") long size,
                       @RequestParam(required = false) String keyword,
                       Model model) {
        SysUser login = SessionUtil.getLoginUser();
        IPage<Topic> pageList = topicService.pageOnline(page, size, keyword, login == null ? null : login.getId());
        model.addAttribute("pageList", pageList);
        model.addAttribute("keyword", keyword);
        return "student/topic-list";
    }

    /** 话题详情：话题信息 + 话题下已发布文章 */
    @GetMapping("/detail/{id}")
    public String detail(@PathVariable Long id,
                         @RequestParam(defaultValue = "1") long page,
                         @RequestParam(required = false) String keyword,
                         Model model) {
        SysUser login = SessionUtil.getLoginUser();
        Topic topic = topicService.detail(id, login == null ? null : login.getId());
        if (topic == null) return "redirect:/topic/list";

        boolean canView = topic.getStatus() != null && topic.getStatus() == 1;
        if (!canView && login != null) {
            canView = "ADMIN".equals(login.getRole()) || login.getId().equals(topic.getCreatorId());
        }
        if (!canView) return "redirect:/topic/list";

        IPage<Article> articlePage = topicService.pageArticles(page, 10, id, keyword);
        model.addAttribute("topic", topic);
        model.addAttribute("articlePage", articlePage);
        model.addAttribute("keyword", keyword);
        return "student/topic-detail";
    }

    /** 关注/取消关注 */
    @PostMapping("/follow/{id}")
    @ResponseBody
    public R<?> follow(@PathVariable Long id) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "请先登录");
        try {
            boolean followed = topicService.toggleFollow(id, login.getId());
            Topic latest = topicService.detail(id, login.getId());
            Map<String, Object> data = new HashMap<>();
            data.put("followed", followed);
            data.put("followerCount", latest == null || latest.getFollowerCount() == null ? 0 : latest.getFollowerCount());
            return R.ok(followed ? "已关注话题" : "已取消关注", data);
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }
}
