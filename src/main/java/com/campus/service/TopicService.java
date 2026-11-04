package com.campus.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Article;
import com.campus.entity.Topic;

import java.util.List;

/**
 * 话题 Service
 * status: 0待审核 1已上线 2已驳回 3已禁用
 */
public interface TopicService {

    /** 用户端：已上线话题分页（含关注状态） */
    IPage<Topic> pageOnline(long current, long size, String keyword, Long userId);

    /** 自媒体端：我创建的话题分页 */
    IPage<Topic> pageMine(long current, long size, Long creatorId, Integer status, String keyword);

    /** 管理端：全部话题分页 */
    IPage<Topic> pageAdmin(long current, long size, Integer status, String keyword);

    /** 首页热门话题（已上线且标记热门） */
    List<Topic> listHot(int limit);

    /** 所有已上线话题（写稿时选择用） */
    List<Topic> listOnline();

    /** 话题详情（含关注状态） */
    Topic detail(Long id, Long userId);

    /** 自媒体创建话题（直接进入待审核） */
    Long create(Topic topic, Long creatorId);

    /** 自媒体编辑话题（仅待审核 / 已驳回） */
    boolean update(Topic topic, Long creatorId);

    /** 提交审核：0/2 -> 0 */
    boolean submit(Long id, Long creatorId);

    /** 自媒体删除话题（仅待审核 / 已驳回，且没有文章引用） */
    boolean delete(Long id, Long creatorId);

    /** 管理员审核通过：0 -> 1 */
    boolean auditPass(Long id);

    /** 管理员审核驳回：0 -> 2 */
    boolean auditReject(Long id, String reason);

    /** 管理员设置/取消热门 */
    boolean toggleHot(Long id, Integer isHot);

    /** 管理员上线(1) / 禁用(3) */
    boolean changeStatus(Long id, Integer status);

    /** 管理员删除话题（有文章引用时拒绝） */
    boolean adminDelete(Long id);

    /** 管理员创建话题（创建后直接上线） */
    Long adminCreate(Topic topic, Long adminId);

    /** 管理员编辑话题（不改变状态） */
    boolean adminUpdate(Topic topic);

    /** 我创建的话题总数 */
    long countMine(Long creatorId);

    /** 待审核话题数 */
    long countPending();

    /** 关注/取消关注（返回是否已关注） */
    boolean toggleFollow(Long topicId, Long userId);

    /** 话题下的已发布文章分页 */
    IPage<Article> pageArticles(long current, long size, Long topicId, String keyword);
}
