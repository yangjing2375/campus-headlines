package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.entity.Article;
import com.campus.entity.Comment;
import com.campus.entity.CommentLike;
import com.campus.mapper.ArticleMapper;
import com.campus.mapper.CommentLikeMapper;
import com.campus.mapper.CommentMapper;
import com.campus.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@Service
public class CommentServiceImpl implements CommentService {

    @Autowired
    private CommentMapper commentMapper;

    @Autowired
    private CommentLikeMapper commentLikeMapper;

    @Autowired
    private ArticleMapper articleMapper;

    @Override
    public List<Comment> listTreeByArticle(Long articleId, Long loginUserId) {
        return buildTree(commentMapper.selectByArticleId(articleId), loginUserId);
    }

    /** 组装楼中楼：一级评论 + 各自的回复（回复按时间正序），并标记当前用户点赞状态 */
    private List<Comment> buildTree(List<Comment> all, Long loginUserId) {
        // 标记当前登录用户已点赞的评论
        if (loginUserId != null && !all.isEmpty()) {
            List<Long> ids = new ArrayList<>();
            for (Comment c : all) ids.add(c.getId());
            Set<Long> likedIds = commentLikeMapper.selectLikedCommentIds(loginUserId, ids);
            for (Comment c : all) {
                c.setLiked(likedIds != null && likedIds.contains(c.getId()));
            }
        }

        List<Comment> roots = new ArrayList<>();
        List<Comment> replyList = new ArrayList<>();
        for (Comment c : all) {
            if (c.getParentId() == null) {
                c.setReplies(new ArrayList<>());
                roots.add(c);
            } else {
                replyList.add(c);
            }
        }
        // 回复挂到一级评论下（按时间正序）
        replyList.sort((a, b) -> a.getCreateTime().compareTo(b.getCreateTime()));
        for (Comment r : replyList) {
            for (Comment root : roots) {
                if (root.getId().equals(r.getParentId())) {
                    root.getReplies().add(r);
                    break;
                }
            }
        }
        return roots;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Comment add(Long articleId, Long userId, String content, Long parentId) {
        if (!StringUtils.hasText(content)) {
            throw new IllegalArgumentException("评论内容不能为空");
        }
        Article article = articleMapper.selectById(articleId);
        if (article == null) {
            throw new IllegalArgumentException("文章不存在");
        }
        Comment comment = new Comment();
        comment.setArticleId(articleId);
        comment.setUserId(userId);
        comment.setContent(content);
        comment.setStatus(1); // 简化：直接已发布

        // 回复：校验父评论存在且属于同一文章，记录被回复人
        if (parentId != null) {
            Comment parent = commentMapper.selectById(parentId);
            if (parent == null || parent.getStatus() != 1
                    || !parent.getArticleId().equals(articleId)) {
                throw new IllegalArgumentException("回复的评论不存在");
            }
            // 统一挂到一级评论下：回复的回复也指向根评论，@ 被回复人
            if (parent.getParentId() != null) {
                comment.setParentId(parent.getParentId());
                comment.setReplyUserId(parent.getUserId());
            } else {
                comment.setParentId(parentId);
                comment.setReplyUserId(parent.getUserId());
            }
        }
        commentMapper.insert(comment);

        // 文章评论数 +1
        Article update = new Article();
        update.setId(articleId);
        update.setCommentCount(article.getCommentCount() == null ? 1 : article.getCommentCount() + 1);
        articleMapper.updateById(update);

        return comment;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean delete(Long id, Long userId, boolean isAdmin) {
        Comment comment = commentMapper.selectById(id);
        if (comment == null) return false;
        if (!isAdmin && !comment.getUserId().equals(userId)) {
            throw new IllegalArgumentException("只能删除自己的评论");
        }
        return doLogicalDelete(comment);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean toggleLike(Long commentId, Long userId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment == null || comment.getStatus() != 1) {
            throw new IllegalArgumentException("评论不存在");
        }
        QueryWrapper<CommentLike> qw = new QueryWrapper<>();
        qw.eq("comment_id", commentId).eq("user_id", userId);
        CommentLike exist = commentLikeMapper.selectOne(qw);

        Comment update = new Comment();
        update.setId(commentId);
        if (exist != null) {
            commentLikeMapper.deleteById(exist.getId());
            update.setLikeCount(Math.max(0, (comment.getLikeCount() == null ? 0 : comment.getLikeCount()) - 1));
            commentMapper.updateById(update);
            return false;
        } else {
            CommentLike like = new CommentLike();
            like.setCommentId(commentId);
            like.setUserId(userId);
            commentLikeMapper.insert(like);
            update.setLikeCount((comment.getLikeCount() == null ? 0 : comment.getLikeCount()) + 1);
            commentMapper.updateById(update);
            return true;
        }
    }

    @Override
    public Comment getById(Long id) {
        return commentMapper.selectById(id);
    }

    @Override
    public IPage<Comment> pageAdmin(long current, long size, String keyword) {
        Page<Comment> page = new Page<>(current, size);
        return commentMapper.selectAdminPage(page, keyword);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean adminDelete(Long id) {
        Comment comment = commentMapper.selectById(id);
        if (comment == null) return false;
        return doLogicalDelete(comment);
    }

    /** 逻辑删除评论，并联动文章评论数 -1 */
    private boolean doLogicalDelete(Comment comment) {
        comment.setStatus(2);
        boolean ok = commentMapper.updateById(comment) > 0;
        if (ok && comment.getArticleId() != null) {
            Article article = articleMapper.selectById(comment.getArticleId());
            if (article != null && article.getCommentCount() != null && article.getCommentCount() > 0) {
                Article update = new Article();
                update.setId(article.getId());
                update.setCommentCount(article.getCommentCount() - 1);
                articleMapper.updateById(update);
            }
        }
        return ok;
    }
}
