package com.campus.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;
import com.campus.entity.Channel;
import com.campus.entity.Material;
import com.campus.entity.SysUser;
import com.campus.entity.Topic;
import com.campus.service.ArticleService;
import com.campus.service.ChannelService;
import com.campus.service.MaterialService;
import com.campus.service.TopicService;
import com.campus.utils.R;
import com.campus.utils.SessionUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 自媒体端 Controller - 撰稿/草稿/素材管理（JSP 页面端）
 * 对应文档 2.1 自媒体端功能
 */
@Controller
@RequestMapping("/editor")
public class EditorController {

    @Autowired
    private ArticleService articleService;
    @Autowired
    private ChannelService channelService;
    @Autowired
    private MaterialService materialService;
    @Autowired
    private TopicService topicService;

    /** 控制台概览：各状态稿件统计 + 最近稿件 + 素材数量 */
    @GetMapping({"/", "/index"})
    public String index(Model model) {
        SysUser user = SessionUtil.getLoginUser();

        Map<String, Long> stats = new HashMap<>();
        long total = 0;
        for (int st = 0; st <= 4; st++) {
            long count = articleService.pageMine(1, 1, user.getId(), st, null, null, null, null).getTotal();
            stats.put("status" + st, count);
            total += count;
        }
        stats.put("all", total);

        IPage<Article> recent = articleService.pageMine(1, 6, user.getId(), null, null, null, null, null);
        model.addAttribute("stats", stats);
        model.addAttribute("recentArticles", recent);
        model.addAttribute("materialCount",
                materialService.pageByUser(1, 1, user.getId(), null).getTotal());
        model.addAttribute("topicCount", topicService.countMine(user.getId()));
        return "editor/index";
    }

    /** 写稿页面 */
    @GetMapping("/draft/new")
    public String newDraft(Model model) {
        model.addAttribute("channels", channelService.listEnabled());
        model.addAttribute("topics", topicService.listOnline());
        model.addAttribute("draft", new Article());
        model.addAttribute("materials", myImageMaterials());
        return "editor/draft-edit";
    }

    /** 编辑已有文章（仅草稿 / 已驳回可编辑） */
    @GetMapping("/draft/edit/{id}")
    public String editDraft(@PathVariable Long id, Model model) {
        SysUser user = SessionUtil.getLoginUser();
        Article article = articleService.detail(id);
        if (article == null || !user.getId().equals(article.getAuthorId())
                || (article.getStatus() != 0 && article.getStatus() != 3)) {
            return "redirect:/editor/drafts";
        }
        model.addAttribute("channels", channelService.listEnabled());
        model.addAttribute("topics", topicService.listOnline());
        model.addAttribute("draft", article);
        model.addAttribute("materials", myImageMaterials());
        return "editor/draft-edit";
    }

    /** 我的文章列表（多条件筛选 + 分页） */
    @GetMapping("/drafts")
    public String myDrafts(@RequestParam(defaultValue = "1") long page,
                           @RequestParam(defaultValue = "10") long size,
                           @RequestParam(required = false) Integer status,
                           @RequestParam(required = false) Long channelId,
                           @RequestParam(required = false) String keyword,
                           @RequestParam(required = false) String startDate,
                           @RequestParam(required = false) String endDate,
                           Model model) {
        SysUser user = SessionUtil.getLoginUser();
        IPage<Article> list = articleService.pageMine(page, size, user.getId(),
                status, channelId, startDate, endDate, keyword);

        Map<String, Long> stats = new HashMap<>();
        long total = 0;
        for (int st = 0; st <= 4; st++) {
            long count = articleService.pageMine(1, 1, user.getId(), st, null, null, null, null).getTotal();
            stats.put("status" + st, count);
            total += count;
        }
        stats.put("all", total);

        model.addAttribute("page", list);
        model.addAttribute("stats", stats);
        model.addAttribute("status", status);
        model.addAttribute("channelId", channelId);
        model.addAttribute("keyword", keyword);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("channels", channelService.listEnabled());
        return "editor/draft-list";
    }

    /** 保存草稿 */
    @PostMapping("/draft/save")
    @ResponseBody
    public R<?> saveDraft(@RequestBody Article article) {
        SysUser user = SessionUtil.getLoginUser();
        article.setAuthorId(user.getId());
        if (article.getId() == null) {
            Long id = articleService.createDraft(article);
            return R.ok("草稿保存成功", id);
        } else {
            boolean ok = articleService.edit(article);
            return ok ? R.ok("草稿已更新", article.getId()) : R.fail("该稿件当前状态不可编辑");
        }
    }

    /** 提交审核（必须先选择频道） */
    @PostMapping("/draft/submit/{id}")
    @ResponseBody
    public R<?> submit(@PathVariable Long id) {
        SysUser user = SessionUtil.getLoginUser();
        Article exist = articleService.detail(id);
        if (exist == null || !user.getId().equals(exist.getAuthorId())) {
            return R.fail("稿件不存在");
        }
        if (exist.getChannelId() == null) {
            return R.fail("提交审核前请先选择频道分类");
        }
        boolean ok = articleService.submitAudit(id, user.getId());
        return ok ? R.ok("已提交审核") : R.fail("提交失败，仅草稿或被驳回的稿件可提交");
    }

    /** 删除文章（仅草稿/被驳回） */
    @PostMapping("/draft/delete/{id}")
    @ResponseBody
    public R<?> delete(@PathVariable Long id) {
        SysUser user = SessionUtil.getLoginUser();
        boolean ok = articleService.delete(id, user.getId());
        return ok ? R.ok("删除成功") : R.fail("仅草稿或被驳回的稿件可删除");
    }

    /** 素材管理页面 */
    @GetMapping("/materials")
    public String materials(@RequestParam(defaultValue = "1") long page,
                            @RequestParam(defaultValue = "12") long size,
                            @RequestParam(required = false) String type,
                            Model model) {
        SysUser user = SessionUtil.getLoginUser();
        IPage<Material> list = materialService.pageByUser(page, size, user.getId(), type);
        model.addAttribute("page", list);
        model.addAttribute("type", type);
        return "editor/materials";
    }

    /** 文件上传 */
    @PostMapping("/upload")
    @ResponseBody
    public R<Material> upload(@RequestParam("file") MultipartFile file) {
        try {
            SysUser user = SessionUtil.getLoginUser();
            Material material = materialService.upload(file, user.getId());
            return R.ok("上传成功", material);
        } catch (Exception e) {
            return R.fail("上传失败：" + e.getMessage());
        }
    }

    /** 删除素材 */
    @PostMapping("/material/delete/{id}")
    @ResponseBody
    public R<?> deleteMaterial(@PathVariable Long id) {
        SysUser user = SessionUtil.getLoginUser();
        try {
            boolean ok = materialService.deleteIfUnused(id, user.getId());
            return ok ? R.ok("删除成功") : R.fail("删除失败");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    // ==================== 话题管理 ====================

    /** 我创建的话题列表 */
    @GetMapping("/topics")
    public String myTopics(@RequestParam(defaultValue = "1") long page,
                           @RequestParam(defaultValue = "10") long size,
                           @RequestParam(required = false) Integer status,
                           @RequestParam(required = false) String keyword,
                           Model model) {
        SysUser user = SessionUtil.getLoginUser();
        IPage<Topic> pageList = topicService.pageMine(page, size, user.getId(), status, keyword);

        Map<String, Long> stats = new HashMap<>();
        long total = topicService.countMine(user.getId());
        for (int st = 0; st <= 3; st++) {
            stats.put("status" + st,
                    topicService.pageMine(1, 1, user.getId(), st, null).getTotal());
        }
        stats.put("all", total);

        model.addAttribute("page", pageList);
        model.addAttribute("stats", stats);
        model.addAttribute("status", status);
        model.addAttribute("keyword", keyword);
        return "editor/topics";
    }

    /** 新建话题页面 */
    @GetMapping("/topic/new")
    public String newTopic(Model model) {
        model.addAttribute("topic", new Topic());
        return "editor/topic-edit";
    }

    /** 编辑话题页面（仅待审核 / 已驳回） */
    @GetMapping("/topic/edit/{id}")
    public String editTopic(@PathVariable Long id, Model model) {
        SysUser user = SessionUtil.getLoginUser();
        Topic topic = topicService.detail(id, null);
        if (topic == null || !user.getId().equals(topic.getCreatorId())
                || (topic.getStatus() != 0 && topic.getStatus() != 2)) {
            return "redirect:/editor/topics";
        }
        model.addAttribute("topic", topic);
        return "editor/topic-edit";
    }

    /** 保存话题（新建 / 编辑） */
    @PostMapping("/topic/save")
    @ResponseBody
    public R<?> saveTopic(@RequestBody Topic topic) {
        SysUser user = SessionUtil.getLoginUser();
        try {
            if (topic.getId() == null) {
                Long id = topicService.create(topic, user.getId());
                return R.ok("话题已提交审核", id);
            }
            boolean ok = topicService.update(topic, user.getId());
            return ok ? R.ok("话题已更新", topic.getId()) : R.fail("保存失败");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 提交话题审核 */
    @PostMapping("/topic/submit/{id}")
    @ResponseBody
    public R<?> submitTopic(@PathVariable Long id) {
        SysUser user = SessionUtil.getLoginUser();
        try {
            boolean ok = topicService.submit(id, user.getId());
            return ok ? R.ok("已提交审核") : R.fail("提交失败");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 删除话题 */
    @PostMapping("/topic/delete/{id}")
    @ResponseBody
    public R<?> deleteTopic(@PathVariable Long id) {
        SysUser user = SessionUtil.getLoginUser();
        try {
            boolean ok = topicService.delete(id, user.getId());
            return ok ? R.ok("删除成功") : R.fail("删除失败");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    // ==================== 私有方法 ====================

    /** 当前自媒体人的图片素材（写稿页封面/正文配图可选） */
    private List<Material> myImageMaterials() {
        SysUser user = SessionUtil.getLoginUser();
        return materialService.pageByUser(1, 100, user.getId(), "image").getRecords();
    }
}
