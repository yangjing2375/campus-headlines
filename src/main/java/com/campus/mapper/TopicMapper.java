package com.campus.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Topic;
import org.apache.ibatis.annotations.Param;

/**
 * 话题 Mapper - 自定义动态 SQL（带创建人、文章数、关注数统计）
 */
public interface TopicMapper extends BaseMapper<Topic> {

    /** 话题分页：按状态/创建人/关键词筛选，热门优先 */
    IPage<Topic> selectTopicPage(IPage<Topic> page,
                                 @Param("status") Integer status,
                                 @Param("creatorId") Long creatorId,
                                 @Param("keyword") String keyword,
                                 @Param("hotOnly") Integer hotOnly);

    /** 话题详情（含创建人、文章数、关注数） */
    Topic selectTopicDetail(@Param("id") Long id);
}
