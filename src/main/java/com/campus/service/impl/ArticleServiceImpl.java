package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.entity.*;
import com.campus.mapper.*;
import com.campus.service.ArticleService;
import com.campus.utils.PageUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Service
public class ArticleServiceImpl implements ArticleService {

    @Autowired
    private ArticleMapper articleMapper;

    @Autowired
    private ArticleMaterialMapper articleMaterialMapper;

    @Autowired
    private MaterialMapper materialMapper;

    @Autowired
    private AuditLogMapper auditLogMapper;

    @Autowired
    private TopicMapper topicMapper;


    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createDraft(Article article) {
        if (article.getTitle() == null || article.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("标题不能为空");
        }
        validateTopic(article.getTopicId());
        article.setStatus(0); // 草稿
        if (article.getContent() == null) article.setContent("");
        if (article.getViewCount() == null) article.setViewCount(0);
        if (article.getLikeCount() == null) article.setLikeCount(0);
        if (article.getFavoriteCount() == null) article.setFavoriteCount(0);
        if (article.getCommentCount() == null) article.setCommentCount(0);
        if (article.getIsTop() == null) article.setIsTop(0);
        if (article.getIsUrgent() == null) article.setIsUrgent(0);
        articleMapper.insert(article);

        // 保存素材关联
        saveMaterials(article.getId(), article.getMaterialIds());
        return article.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean edit(Article article) {
        Article exist = articleMapper.selectById(article.getId());
        if (exist == null) throw new IllegalArgumentException("文章不存在");
        // 仅草稿(0)或已驳回(3)可编辑
        if (exist.getStatus() != 0 && exist.getStatus() != 3) {
            throw new IllegalArgumentException("当前状态不可编辑");
        }
        validateTopic(article.getTopicId());
        // 编辑后重置驳回原因
        article.setStatus(0);
        article.setRejectReason("");
        boolean ok = articleMapper.updateById(article) > 0;
        if (ok) {
            // 重建素材关联
            QueryWrapper<ArticleMaterial> qw = new QueryWrapper<>();
            qw.eq("article_id", article.getId());
            articleMaterialMapper.delete(qw);
            saveMaterials(article.getId(), article.getMaterialIds());
        }
        return ok;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean submitAudit(Long id, Long authorId) {
        Article exist = articleMapper.selectById(id);
        if (exist == null) throw new IllegalArgumentException("文章不存在");
        if (!exist.getAuthorId().equals(authorId)) throw new IllegalArgumentException("无权操作他人文章");
        if (exist.getStatus() != 0 && exist.getStatus() != 3) {
            throw new IllegalArgumentException("仅草稿或已驳回文章可提交审核");
        }
        Article update = new Article();
        update.setId(id);
        update.setStatus(1); // 待审核
        update.setRejectReason(null);
        return articleMapper.updateById(update) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean approve(Long id, Long auditorId) {
        Article exist = articleMapper.selectById(id);
        if (exist == null) throw new IllegalArgumentException("文章不存在");
        if (exist.getStatus() != 1) throw new IllegalArgumentException("仅待审核文章可通过");
        Article update = new Article();
        update.setId(id);
        update.setStatus(2); // 已发布
        update.setPublishTime(new Date());
        boolean ok = articleMapper.updateById(update) > 0;
        if (ok) {
            AuditLog log = new AuditLog();
            log.setArticleId(id);
            log.setAuditorId(auditorId);
            log.setAction(1); // 通过
            log.setRemark("审核通过");
            auditLogMapper.insert(log);
        }
        return ok;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean reject(Long id, Long auditorId, String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            throw new IllegalArgumentException("驳回时必须填写驳回理由");
        }
        Article exist = articleMapper.selectById(id);
        if (exist == null) throw new IllegalArgumentException("文章不存在");
        if (exist.getStatus() != 1) throw new IllegalArgumentException("仅待审核文章可驳回");
        Article update = new Article();
        update.setId(id);
        update.setStatus(3); // 已驳回
        update.setRejectReason(reason);
        boolean ok = articleMapper.updateById(update) > 0;
        if (ok) {
            AuditLog log = new AuditLog();
            log.setArticleId(id);
            log.setAuditorId(auditorId);
            log.setAction(2); // 驳回
            log.setRemark(reason);
            auditLogMapper.insert(log);
        }
        return ok;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean offline(Long id) {
        Article exist = articleMapper.selectById(id);
        if (exist == null) throw new IllegalArgumentException("文章不存在");
        if (exist.getStatus() != 2) throw new IllegalArgumentException("仅已发布文章可下架");
        Article update = new Article();
        update.setId(id);
        update.setStatus(4); // 已下架
        return articleMapper.updateById(update) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean delete(Long id, Long authorId) {
        Article exist = articleMapper.selectById(id);
        if (exist == null) return false;
        if (!exist.getAuthorId().equals(authorId)) throw new IllegalArgumentException("无权删除他人文章");
        if (exist.getStatus() != 0 && exist.getStatus() != 3) {
            throw new IllegalArgumentException("仅草稿或已驳回文章可删除");
        }
        // 删除素材关联
        QueryWrapper<ArticleMaterial> qw = new QueryWrapper<>();
        qw.eq("article_id", id);
        articleMaterialMapper.delete(qw);
        return articleMapper.deleteById(id) > 0;
    }

    @Override
    public IPage<Article> pageMine(long current, long size, Long authorId, Integer status,
                                   Long channelId, String startDate, String endDate, String keyword) {
        Page<Article> page = new Page<>(PageUtil.current(current), PageUtil.size(size));
        return articleMapper.selectMinePage(page, authorId, status, channelId, startDate, endDate, keyword);
    }

    @Override
    public IPage<Article> pagePublished(long current, long size, Long channelId, String keyword) {
        Page<Article> page = new Page<>(PageUtil.current(current), PageUtil.size(size));
        return articleMapper.selectPublishedPage(page, channelId, keyword);
    }

    @Override
    public IPage<Article> pageAdmin(long current, long size, Integer status, Long channelId,
                                    Long authorId, String keyword) {
        Page<Article> page = new Page<>(PageUtil.current(current), PageUtil.size(size));
        return articleMapper.selectAdminPage(page, status, channelId, authorId, keyword);
    }

    @Override
    public Article detail(Long id) {
        Article article = articleMapper.selectDetail(id);
        if (article == null) return null;
        // 关联素材
        QueryWrapper<ArticleMaterial> qw = new QueryWrapper<>();
        qw.eq("article_id", id).orderByAsc("sort_no");
        List<ArticleMaterial> ams = articleMaterialMapper.selectList(qw);
        List<Material> materials = new ArrayList<>();
        for (ArticleMaterial am : ams) {
            Material m = materialMapper.selectById(am.getMaterialId());
            if (m != null) materials.add(m);
        }
        article.setMaterials(materials);
        // 审核记录
        article.setAuditLogs(auditLogMapper.selectByArticleId(id));
        return article;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean incrementView(Long id) {
        Article exist = articleMapper.selectById(id);
        if (exist == null) return false;
        // 缺陷 BUG-05：改为数据库端原子自增，避免并发下读旧值+1 导致阅读量丢失
        UpdateWrapper<Article> uw = new UpdateWrapper<>();
        uw.eq("id", id).setSql("view_count = IFNULL(view_count, 0) + 1");
        return articleMapper.update(null, uw) > 0;
    }

    /** 校验所属话题：仅允许选择已上线话题 */
    private void validateTopic(Long topicId) {
        if (topicId == null) return;
        Topic topic = topicMapper.selectById(topicId);
        if (topic == null || topic.getStatus() == null || topic.getStatus() != 1) {
            throw new IllegalArgumentException("所选话题不存在或尚未上线");
        }
    }

    /** 保存文章-素材关联 */
    private void saveMaterials(Long articleId, List<Long> materialIds) {
        if (materialIds == null || materialIds.isEmpty()) return;
        int sort = 0;
        for (Long mid : materialIds) {
            if (mid == null) continue;
            ArticleMaterial am = new ArticleMaterial();
            am.setArticleId(articleId);
            am.setMaterialId(mid);
            am.setSortNo(sort++);
            articleMaterialMapper.insert(am);
        }
    }
}
