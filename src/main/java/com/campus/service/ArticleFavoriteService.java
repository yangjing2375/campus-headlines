package com.campus.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;

/**
 * 收藏 Service - 对应文档"互动功能：收藏"
 */
public interface ArticleFavoriteService {
    /** 收藏/取消收藏，返回当前是否已收藏 */
    boolean toggleFavorite(Long articleId, Long userId);
    /** 查询是否已收藏 */
    boolean isFavorited(Long articleId, Long userId);
    /** 我的收藏列表（分页） */
    IPage<Article> listUserFavorites(long current, long size, Long userId);
}
