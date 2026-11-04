package com.campus.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;

/**
 * 文章 Service - 对应文档"文章状态机"与各端文章管理
 * status: 0草稿 1待审核 2已发布 3已驳回 4已下架
 */
public interface ArticleService {
    /** 保存草稿（新建） */
    Long createDraft(Article article);
    /** 编辑草稿/已驳回文章 */
    boolean edit(Article article);
    /** 提交审核：0/3 -> 1 */
    boolean submitAudit(Long id, Long authorId);
    /** 审核通过：1 -> 2，设置 publish_time，写 audit_log */
    boolean approve(Long id, Long auditorId);
    /** 审核驳回：1 -> 3，设置 reject_reason，写 audit_log */
    boolean reject(Long id, Long auditorId, String reason);
    /** 下架：2 -> 4 */
    boolean offline(Long id);
    /** 删除文章（仅草稿/已驳回，作者本人） */
    boolean delete(Long id, Long authorId);
    /** 自媒体人个人文章多条件分页 */
    IPage<Article> pageMine(long current, long size, Long authorId, Integer status,
                            Long channelId, String startDate, String endDate, String keyword);
    /** 用户端已发布文章分页（按频道+关键词） */
    IPage<Article> pagePublished(long current, long size, Long channelId, String keyword);
    /** 管理端全站文章多条件分页 */
    IPage<Article> pageAdmin(long current, long size, Integer status, Long channelId,
                             Long authorId, String keyword);
    /** 文章详情（含素材、审核记录） */
    Article detail(Long id);
    /** 阅读量 +1 */
    boolean incrementView(Long id);
}
