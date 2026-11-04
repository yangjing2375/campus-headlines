package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.entity.Article;
import com.campus.entity.Topic;
import com.campus.entity.TopicFollow;
import com.campus.mapper.ArticleMapper;
import com.campus.mapper.TopicFollowMapper;
import com.campus.mapper.TopicMapper;
import com.campus.service.TopicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TopicServiceImpl implements TopicService {

    @Autowired
    private TopicMapper topicMapper;
    @Autowired
    private TopicFollowMapper topicFollowMapper;
    @Autowired
    private ArticleMapper articleMapper;

    @Override
    public IPage<Topic> pageOnline(long current, long size, String keyword, Long userId) {
        Page<Topic> page = new Page<>(current, size);
        IPage<Topic> result = topicMapper.selectTopicPage(page, 1, null, keyword, null);
        fillFollowed(result.getRecords(), userId);
        return result;
    }

    @Override
    public IPage<Topic> pageMine(long current, long size, Long creatorId, Integer status, String keyword) {
        Page<Topic> page = new Page<>(current, size);
        return topicMapper.selectTopicPage(page, status, creatorId, keyword, null);
    }

    @Override
    public IPage<Topic> pageAdmin(long current, long size, Integer status, String keyword) {
        Page<Topic> page = new Page<>(current, size);
        return topicMapper.selectTopicPage(page, status, null, keyword, null);
    }

    @Override
    public List<Topic> listHot(int limit) {
        Page<Topic> page = new Page<>(1, limit);
        return topicMapper.selectTopicPage(page, 1, null, null, 1).getRecords();
    }

    @Override
    public List<Topic> listOnline() {
        QueryWrapper<Topic> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByDesc("is_hot").orderByDesc("create_time");
        return topicMapper.selectList(qw);
    }

    @Override
    public Topic detail(Long id, Long userId) {
        Topic topic = topicMapper.selectTopicDetail(id);
        if (topic != null) fillFollowed(java.util.Collections.singletonList(topic), userId);
        return topic;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long create(Topic topic, Long creatorId) {
        if (!StringUtils.hasText(topic.getTitle())) {
            throw new IllegalArgumentException("请填写话题名称");
        }
        topic.setId(null);
        topic.setTitle(topic.getTitle().trim());
        topic.setCreatorId(creatorId);
        topic.setStatus(0); // 待审核
        topic.setIsHot(0);
        topic.setRejectReason(null);
        topicMapper.insert(topic);
        return topic.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean update(Topic topic, Long creatorId) {
        Topic exist = topicMapper.selectById(topic.getId());
        if (exist == null) throw new IllegalArgumentException("话题不存在");
        if (!exist.getCreatorId().equals(creatorId)) throw new IllegalArgumentException("无权编辑他人话题");
        if (exist.getStatus() != 0 && exist.getStatus() != 2) {
            throw new IllegalArgumentException("仅待审核或已驳回的话题可编辑");
        }
        if (!StringUtils.hasText(topic.getTitle())) {
            throw new IllegalArgumentException("请填写话题名称");
        }
        Topic upd = new Topic();
        upd.setId(topic.getId());
        upd.setTitle(topic.getTitle().trim());
        upd.setDescription(topic.getDescription());
        upd.setCover(topic.getCover());
        boolean ok = topicMapper.updateById(upd) > 0;
        // 被驳回的话题修改后自动回到待审核，并清空驳回原因
        if (ok && exist.getStatus() == 2) {
            UpdateWrapper<Topic> uw = new UpdateWrapper<>();
            uw.eq("id", topic.getId()).set("status", 0).set("reject_reason", null);
            topicMapper.update(null, uw);
        }
        return ok;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean submit(Long id, Long creatorId) {
        Topic exist = topicMapper.selectById(id);
        if (exist == null) throw new IllegalArgumentException("话题不存在");
        if (!exist.getCreatorId().equals(creatorId)) throw new IllegalArgumentException("无权操作他人话题");
        if (exist.getStatus() != 0 && exist.getStatus() != 2) {
            throw new IllegalArgumentException("仅待审核或已驳回的话题可提交");
        }
        UpdateWrapper<Topic> uw = new UpdateWrapper<>();
        uw.eq("id", id).set("status", 0).set("reject_reason", null);
        return topicMapper.update(null, uw) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean delete(Long id, Long creatorId) {
        Topic exist = topicMapper.selectById(id);
        if (exist == null) return false;
        if (!exist.getCreatorId().equals(creatorId)) throw new IllegalArgumentException("无权删除他人话题");
        if (exist.getStatus() != 0 && exist.getStatus() != 2) {
            throw new IllegalArgumentException("仅待审核或已驳回的话题可删除");
        }
        if (countArticles(id) > 0) {
            throw new IllegalArgumentException("该话题下已有文章，无法删除");
        }
        QueryWrapper<TopicFollow> qw = new QueryWrapper<>();
        qw.eq("topic_id", id);
        topicFollowMapper.delete(qw);
        return topicMapper.deleteById(id) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean auditPass(Long id) {
        Topic exist = topicMapper.selectById(id);
        if (exist == null) throw new IllegalArgumentException("话题不存在");
        if (exist.getStatus() != 0) throw new IllegalArgumentException("仅待审核话题可通过");
        Topic upd = new Topic();
        upd.setId(id);
        upd.setStatus(1);
        boolean ok = topicMapper.updateById(upd) > 0;
        if (ok) {
            UpdateWrapper<Topic> uw = new UpdateWrapper<>();
            uw.eq("id", id).set("reject_reason", null);
            topicMapper.update(null, uw);
        }
        return ok;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean auditReject(Long id, String reason) {
        Topic exist = topicMapper.selectById(id);
        if (exist == null) throw new IllegalArgumentException("话题不存在");
        if (exist.getStatus() != 0) throw new IllegalArgumentException("仅待审核话题可驳回");
        Topic upd = new Topic();
        upd.setId(id);
        upd.setStatus(2);
        upd.setRejectReason(StringUtils.hasText(reason) ? reason.trim() : "话题内容不符合规范");
        return topicMapper.updateById(upd) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean toggleHot(Long id, Integer isHot) {
        Topic exist = topicMapper.selectById(id);
        if (exist == null) throw new IllegalArgumentException("话题不存在");
        Topic upd = new Topic();
        upd.setId(id);
        upd.setIsHot(isHot == null || isHot == 0 ? 0 : 1);
        return topicMapper.updateById(upd) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean changeStatus(Long id, Integer status) {
        Topic exist = topicMapper.selectById(id);
        if (exist == null) throw new IllegalArgumentException("话题不存在");
        if (status == null || status != 1 && status != 3) {
            throw new IllegalArgumentException("仅支持上线(1)或禁用(3)");
        }
        Topic upd = new Topic();
        upd.setId(id);
        upd.setStatus(status);
        boolean ok = topicMapper.updateById(upd) > 0;
        if (ok && status == 3) {
            Topic unhot = new Topic();
            unhot.setId(id);
            unhot.setIsHot(0);
            topicMapper.updateById(unhot);
        }
        return ok;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean adminDelete(Long id) {
        Topic exist = topicMapper.selectById(id);
        if (exist == null) return false;
        if (countArticles(id) > 0) {
            throw new IllegalArgumentException("该话题下已有文章，请先解除文章关联后再删除");
        }
        QueryWrapper<TopicFollow> qw = new QueryWrapper<>();
        qw.eq("topic_id", id);
        topicFollowMapper.delete(qw);
        return topicMapper.deleteById(id) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long adminCreate(Topic topic, Long adminId) {
        if (!StringUtils.hasText(topic.getTitle())) {
            throw new IllegalArgumentException("请填写话题名称");
        }
        topic.setId(null);
        topic.setTitle(topic.getTitle().trim());
        topic.setCreatorId(adminId);
        topic.setStatus(1); // 管理员创建直接上线
        topic.setIsHot(0);
        topic.setRejectReason(null);
        topicMapper.insert(topic);
        return topic.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean adminUpdate(Topic topic) {
        Topic exist = topicMapper.selectById(topic.getId());
        if (exist == null) throw new IllegalArgumentException("话题不存在");
        if (!StringUtils.hasText(topic.getTitle())) {
            throw new IllegalArgumentException("请填写话题名称");
        }
        Topic upd = new Topic();
        upd.setId(topic.getId());
        upd.setTitle(topic.getTitle().trim());
        upd.setDescription(topic.getDescription());
        upd.setCover(topic.getCover());
        return topicMapper.updateById(upd) > 0;
    }

    @Override
    public long countMine(Long creatorId) {
        QueryWrapper<Topic> qw = new QueryWrapper<>();
        qw.eq("creator_id", creatorId);
        return topicMapper.selectCount(qw);
    }

    @Override
    public long countPending() {
        QueryWrapper<Topic> qw = new QueryWrapper<>();
        qw.eq("status", 0);
        return topicMapper.selectCount(qw);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean toggleFollow(Long topicId, Long userId) {
        Topic topic = topicMapper.selectById(topicId);
        if (topic == null) throw new IllegalArgumentException("话题不存在");
        if (topic.getStatus() != 1) throw new IllegalArgumentException("该话题尚未上线");

        QueryWrapper<TopicFollow> qw = new QueryWrapper<>();
        qw.eq("topic_id", topicId).eq("user_id", userId);
        TopicFollow exist = topicFollowMapper.selectOne(qw);
        if (exist != null) {
            topicFollowMapper.deleteById(exist.getId());
            return false;
        }
        TopicFollow follow = new TopicFollow();
        follow.setTopicId(topicId);
        follow.setUserId(userId);
        topicFollowMapper.insert(follow);
        return true;
    }

    @Override
    public IPage<Article> pageArticles(long current, long size, Long topicId, String keyword) {
        Page<Article> page = new Page<>(current, size);
        return articleMapper.selectPageByTopic(page, topicId, keyword);
    }

    // ==================== 私有方法 ====================

    /** 批量标记当前用户是否已关注 */
    private void fillFollowed(List<Topic> topics, Long userId) {
        if (topics == null || topics.isEmpty()) return;
        if (userId == null) {
            for (Topic t : topics) t.setFollowed(false);
            return;
        }
        List<Long> ids = new ArrayList<>();
        for (Topic t : topics) ids.add(t.getId());
        QueryWrapper<TopicFollow> qw = new QueryWrapper<>();
        qw.eq("user_id", userId).in("topic_id", ids);
        Map<Long, Boolean> map = new HashMap<>();
        for (TopicFollow f : topicFollowMapper.selectList(qw)) map.put(f.getTopicId(), true);
        for (Topic t : topics) t.setFollowed(map.getOrDefault(t.getId(), false));
    }

    /** 话题下关联的文章数量（任意状态） */
    private long countArticles(Long topicId) {
        QueryWrapper<Article> qw = new QueryWrapper<>();
        qw.eq("topic_id", topicId);
        return articleMapper.selectCount(qw);
    }
}
