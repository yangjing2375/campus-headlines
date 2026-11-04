package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.entity.Article;
import com.campus.entity.ArticleLike;
import com.campus.mapper.ArticleLikeMapper;
import com.campus.mapper.ArticleMapper;
import com.campus.service.ArticleLikeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ArticleLikeServiceImpl implements ArticleLikeService {

    @Autowired
    private ArticleLikeMapper articleLikeMapper;

    @Autowired
    private ArticleMapper articleMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean toggleLike(Long articleId, Long userId) {
        QueryWrapper<ArticleLike> qw = new QueryWrapper<>();
        qw.eq("article_id", articleId).eq("user_id", userId);
        ArticleLike exist = articleLikeMapper.selectOne(qw);
        Article article = articleMapper.selectById(articleId);
        if (article == null) throw new IllegalArgumentException("文章不存在");

        if (exist != null) {
            // 取消点赞
            articleLikeMapper.deleteById(exist.getId());
            // 缺陷 BUG-04：计数改为数据库端原子自减，避免并发下丢失更新
            UpdateWrapper<Article> uw = new UpdateWrapper<>();
            uw.eq("id", articleId).setSql("like_count = GREATEST(IFNULL(like_count, 0) - 1, 0)");
            articleMapper.update(null, uw);
            return false;
        } else {
            // 点赞
            ArticleLike like = new ArticleLike();
            like.setArticleId(articleId);
            like.setUserId(userId);
            articleLikeMapper.insert(like);
            UpdateWrapper<Article> uw = new UpdateWrapper<>();
            uw.eq("id", articleId).setSql("like_count = IFNULL(like_count, 0) + 1");
            articleMapper.update(null, uw);
            return true;
        }
    }

    @Override
    public boolean isLiked(Long articleId, Long userId) {
        if (userId == null) return false;
        QueryWrapper<ArticleLike> qw = new QueryWrapper<>();
        qw.eq("article_id", articleId).eq("user_id", userId);
        return articleLikeMapper.selectCount(qw) > 0;
    }

    @Override
    public IPage<Article> listUserLiked(long current, long size, Long userId) {
        Page<ArticleLike> likePage = new Page<>(current, size);
        QueryWrapper<ArticleLike> qw = new QueryWrapper<>();
        qw.eq("user_id", userId).orderByDesc("create_time");
        IPage<ArticleLike> likes = articleLikeMapper.selectPage(likePage, qw);

        Page<Article> articlePage = new Page<>(likes.getCurrent(), likes.getSize(), likes.getTotal());
        java.util.List<Article> articles = new java.util.ArrayList<>();
        for (ArticleLike like : likes.getRecords()) {
            Article a = articleMapper.selectDetail(like.getArticleId());
            if (a != null) articles.add(a);
        }
        articlePage.setRecords(articles);
        return articlePage;
    }
}
