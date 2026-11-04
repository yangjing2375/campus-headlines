package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.entity.Article;
import com.campus.entity.ArticleFavorite;
import com.campus.mapper.ArticleFavoriteMapper;
import com.campus.mapper.ArticleMapper;
import com.campus.service.ArticleFavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ArticleFavoriteServiceImpl implements ArticleFavoriteService {

    @Autowired
    private ArticleFavoriteMapper articleFavoriteMapper;

    @Autowired
    private ArticleMapper articleMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean toggleFavorite(Long articleId, Long userId) {
        QueryWrapper<ArticleFavorite> qw = new QueryWrapper<>();
        qw.eq("article_id", articleId).eq("user_id", userId);
        ArticleFavorite exist = articleFavoriteMapper.selectOne(qw);
        Article article = articleMapper.selectById(articleId);
        if (article == null) throw new IllegalArgumentException("文章不存在");

        if (exist != null) {
            articleFavoriteMapper.deleteById(exist.getId());
            Article update = new Article();
            update.setId(articleId);
            update.setFavoriteCount(Math.max(0, (article.getFavoriteCount() == null ? 0 : article.getFavoriteCount()) - 1));
            articleMapper.updateById(update);
            return false;
        } else {
            ArticleFavorite fav = new ArticleFavorite();
            fav.setArticleId(articleId);
            fav.setUserId(userId);
            articleFavoriteMapper.insert(fav);
            Article update = new Article();
            update.setId(articleId);
            update.setFavoriteCount((article.getFavoriteCount() == null ? 0 : article.getFavoriteCount()) + 1);
            articleMapper.updateById(update);
            return true;
        }
    }

    @Override
    public boolean isFavorited(Long articleId, Long userId) {
        if (userId == null) return false;
        QueryWrapper<ArticleFavorite> qw = new QueryWrapper<>();
        qw.eq("article_id", articleId).eq("user_id", userId);
        return articleFavoriteMapper.selectCount(qw) > 0;
    }

    @Override
    public IPage<Article> listUserFavorites(long current, long size, Long userId) {
        Page<ArticleFavorite> favPage = new Page<>(current, size);
        QueryWrapper<ArticleFavorite> qw = new QueryWrapper<>();
        qw.eq("user_id", userId).orderByDesc("create_time");
        IPage<ArticleFavorite> favorites = articleFavoriteMapper.selectPage(favPage, qw);

        // 将收藏记录转为文章列表
        Page<Article> articlePage = new Page<>(favorites.getCurrent(), favorites.getSize(), favorites.getTotal());
        java.util.List<Article> articles = new java.util.ArrayList<>();
        for (ArticleFavorite fav : favorites.getRecords()) {
            Article a = articleMapper.selectDetail(fav.getArticleId());
            if (a != null) articles.add(a);
        }
        articlePage.setRecords(articles);
        return articlePage;
    }
}
