package com.campus.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.entity.CommentLike;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Set;

public interface CommentLikeMapper extends BaseMapper<CommentLike> {

    /** 查询某用户对一批评论的点赞记录（用于标记 liked 状态） */
    Set<Long> selectLikedCommentIds(@Param("userId") Long userId, @Param("commentIds") List<Long> commentIds);
}
