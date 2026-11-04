package com.campus.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Comment;
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface CommentMapper extends BaseMapper<Comment> {

    /** 按文章ID查询已发布评论（关联用户名） */
    List<Comment> selectByArticleId(@Param("articleId") Long articleId);

    /** 管理端评论分页（关联用户昵称、文章标题） */
    IPage<Comment> selectAdminPage(IPage<Comment> page, @Param("keyword") String keyword);
}
