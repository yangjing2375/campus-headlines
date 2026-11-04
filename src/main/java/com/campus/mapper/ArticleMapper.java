package com.campus.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;
import org.apache.ibatis.annotations.Param;

/**
 * 文章 Mapper - 自定义动态 SQL
 * 对应文档：文章多条件筛选（状态、频道、时间、关键词）使用 if/where 动态拼接
 */
public interface ArticleMapper extends BaseMapper<Article> {

    /** 带作者与频道名的详情查询 */
    Article selectDetail(@Param("id") Long id);

    /** 自媒体人个人文章多条件筛选分页（状态+频道+时间+关键词） */
    IPage<Article> selectMinePage(IPage<Article> page,
                                  @Param("authorId") Long authorId,
                                  @Param("status") Integer status,
                                  @Param("channelId") Long channelId,
                                  @Param("startDate") String startDate,
                                  @Param("endDate") String endDate,
                                  @Param("keyword") String keyword);

    /** 用户端：已发布文章分页（按频道+关键词） */
    IPage<Article> selectPublishedPage(IPage<Article> page,
                                       @Param("channelId") Long channelId,
                                       @Param("keyword") String keyword);

    /** 管理端：全站文章多条件分页（状态+频道+作者+关键词） */
    IPage<Article> selectAdminPage(IPage<Article> page,
                                   @Param("status") Integer status,
                                   @Param("channelId") Long channelId,
                                   @Param("authorId") Long authorId,
                                   @Param("keyword") String keyword);

    /** 话题下的已发布文章分页 */
    IPage<Article> selectPageByTopic(IPage<Article> page,
                                     @Param("topicId") Long topicId,
                                     @Param("keyword") String keyword);

}
