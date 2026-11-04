package com.campus.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;

/**
 * 点赞 Service - 对应文档"互动功能：点赞"
 * 同一用户同一文章只能赞一次，toggle 切换状态
 */
public interface ArticleLikeService {
    /** 点赞/取消点赞，返回当前是否已点赞 */
    boolean toggleLike(Long articleId, Long userId);
    /** 查询是否已点赞 */
    boolean isLiked(Long articleId, Long userId);
    /** 我赞过的文章列表（分页） */
    IPage<Article> listUserLiked(long current, long size, Long userId);
}
