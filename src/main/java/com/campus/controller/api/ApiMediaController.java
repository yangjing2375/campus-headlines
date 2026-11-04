package com.campus.controller.api;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;
import com.campus.entity.Material;
import com.campus.entity.SysUser;
import com.campus.entity.Topic;
import com.campus.interceptor.TokenInterceptor;
import com.campus.service.ArticleService;
import com.campus.service.MaterialService;
import com.campus.service.TopicService;
import com.campus.utils.R;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;

/**
 * 自媒体端接口 - 对应文档 6.2（角色：MEDIA）
 */
@RestController
@RequestMapping("/api/media")
public class ApiMediaController {

    @Autowired
    private ArticleService articleService;

    @Autowired
    private MaterialService materialService;

    @Autowired
    private TopicService topicService;

    private SysUser currentUser(HttpServletRequest request) {
        return (SysUser) request.getAttribute(TokenInterceptor.ATTR_USER);
    }

    /** 创建文章（保存草稿） */
    @PostMapping("/articles")
    public R<Long> createArticle(@RequestBody Article article, HttpServletRequest request) {
        article.setAuthorId(currentUser(request).getId());
        Long id = articleService.createDraft(article);
        return R.ok("创建成功", id);
    }

    /** 编辑草稿文章 */
    @PutMapping("/articles/{id}")
    public R<?> updateArticle(@PathVariable Long id, @RequestBody Article article, HttpServletRequest request) {
        article.setId(id);
        article.setAuthorId(currentUser(request).getId());
        boolean ok = articleService.edit(article);
        return ok ? R.ok("更新成功") : R.fail("更新失败");
    }

    /** 提交审核 */
    @PostMapping("/articles/{id}/submit")
    public R<?> submitAudit(@PathVariable Long id, HttpServletRequest request) {
        boolean ok = articleService.submitAudit(id, currentUser(request).getId());
        return ok ? R.ok("已提交审核") : R.fail("提交失败");
    }

    /** 删除文章（仅草稿/已驳回） */
    @DeleteMapping("/articles/{id}")
    public R<?> deleteArticle(@PathVariable Long id, HttpServletRequest request) {
        boolean ok = articleService.delete(id, currentUser(request).getId());
        return ok ? R.ok("删除成功") : R.fail("删除失败");
    }

    /** 个人文章列表（多条件筛选+分页） */
    @GetMapping("/articles/mine")
    public R<IPage<Article>> mineArticles(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Long channelId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String keyword,
            HttpServletRequest request) {
        IPage<Article> page = articleService.pageMine(current, size, currentUser(request).getId(),
                status, channelId, startDate, endDate, keyword);
        return R.ok(page);
    }

    /** 查看自己文章详情 */
    @GetMapping("/articles/{id}")
    public R<Article> articleDetail(@PathVariable Long id) {
        Article article = articleService.detail(id);
        return article != null ? R.ok(article) : R.fail("文章不存在");
    }

    /** 上传素材 */
    @PostMapping("/materials/upload")
    public R<Material> uploadMaterial(@RequestParam("file") MultipartFile file, HttpServletRequest request) throws Exception {
        Material material = materialService.upload(file, currentUser(request).getId());
        return R.ok("上传成功", material);
    }

    /** 我的素材列表（分页、按类型筛选） */
    @GetMapping("/materials")
    public R<IPage<Material>> materials(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "12") long size,
            @RequestParam(required = false) String type,
            HttpServletRequest request) {
        IPage<Material> page = materialService.pageByUser(current, size, currentUser(request).getId(), type);
        return R.ok(page);
    }

    /** 删除素材 */
    @DeleteMapping("/materials/{id}")
    public R<?> deleteMaterial(@PathVariable Long id, HttpServletRequest request) {
        boolean ok = materialService.deleteIfUnused(id, currentUser(request).getId());
        return ok ? R.ok("删除成功") : R.fail("删除失败");
    }

    // ==================== 话题管理 ====================

    /** 已上线话题（写稿时选择用） */
    @GetMapping("/topics/online")
    public R<java.util.List<Topic>> onlineTopics() {
        return R.ok(topicService.listOnline());
    }

    /** 我创建的话题列表 */
    @GetMapping("/topics/mine")
    public R<IPage<Topic>> mineTopics(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword,
            HttpServletRequest request) {
        return R.ok(topicService.pageMine(current, size, currentUser(request).getId(), status, keyword));
    }

    /** 创建话题（提交后进入待审核） */
    @PostMapping("/topics")
    public R<Long> createTopic(@RequestBody Topic topic, HttpServletRequest request) {
        Long id = topicService.create(topic, currentUser(request).getId());
        return R.ok("话题已提交审核", id);
    }

    /** 编辑话题（仅待审核/已驳回） */
    @PutMapping("/topics/{id}")
    public R<?> updateTopic(@PathVariable Long id, @RequestBody Topic topic, HttpServletRequest request) {
        topic.setId(id);
        boolean ok = topicService.update(topic, currentUser(request).getId());
        return ok ? R.ok("更新成功") : R.fail("更新失败");
    }

    /** 提交话题审核 */
    @PostMapping("/topics/{id}/submit")
    public R<?> submitTopic(@PathVariable Long id, HttpServletRequest request) {
        boolean ok = topicService.submit(id, currentUser(request).getId());
        return ok ? R.ok("已提交审核") : R.fail("提交失败");
    }

    /** 删除话题 */
    @DeleteMapping("/topics/{id}")
    public R<?> deleteTopic(@PathVariable Long id, HttpServletRequest request) {
        boolean ok = topicService.delete(id, currentUser(request).getId());
        return ok ? R.ok("删除成功") : R.fail("删除失败");
    }
}
