package com.campus.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Comment;

import java.util.List;

/**
 * 评论 Service - 对应文档"互动功能：评论"
 * status: 0待审核 1已发布 2已删除
 */
public interface CommentService {
    /** 文章已发布评论列表（楼中楼树形结构，一级评论带 replies） */
    List<Comment> listTreeByArticle(Long articleId, Long loginUserId);
    /** 发表评论/回复（状态设为 1 已发布，简化实现） */
    Comment add(Long articleId, Long userId, String content, Long parentId);
    /** 删除评论（逻辑删除 status=2）：本人或管理员 */
    boolean delete(Long id, Long userId, boolean isAdmin);
    /** 评论点赞/取消点赞，返回最新点赞状态 */
    boolean toggleLike(Long commentId, Long userId);
    /** 按ID查询评论 */
    Comment getById(Long id);
    /** 管理端评论分页 */
    IPage<Comment> pageAdmin(long current, long size, String keyword);
    /** 管理端删除评论 */
    boolean adminDelete(Long id);
}
