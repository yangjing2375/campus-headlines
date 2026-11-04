package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.entity.Channel;
import com.campus.mapper.ArticleMapper;
import com.campus.mapper.ChannelMapper;
import com.campus.service.ChannelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ChannelServiceImpl implements ChannelService {

    @Autowired
    private ChannelMapper channelMapper;

    @Autowired
    private ArticleMapper articleMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean add(Channel channel) {
        if (channel.getSort() == null) channel.setSort(0);
        if (channel.getStatus() == null) channel.setStatus(1);
        return channelMapper.insert(channel) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean update(Channel channel) {
        return channelMapper.updateById(channel) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean delete(Long id) {
        // 缺陷 BUG-03：删除频道前校验是否仍被文章引用，避免孤儿数据与外键报错
        QueryWrapper<com.campus.entity.Article> qw = new QueryWrapper<>();
        qw.eq("channel_id", id);
        if (articleMapper.selectCount(qw) > 0) {
            throw new IllegalArgumentException("该频道下仍有文章，无法删除");
        }
        return channelMapper.deleteById(id) > 0;
    }

    @Override
    public Channel getById(Long id) {
        return channelMapper.selectById(id);
    }

    @Override
    public List<Channel> listEnabled() {
        QueryWrapper<Channel> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByAsc("sort").orderByAsc("id");
        return channelMapper.selectList(qw);
    }

    @Override
    public IPage<Channel> pageList(long current, long size) {
        Page<Channel> page = new Page<>(current, size);
        QueryWrapper<Channel> qw = new QueryWrapper<>();
        qw.orderByAsc("sort").orderByAsc("id");
        return channelMapper.selectPage(page, qw);
    }

    @Override
    public List<Channel> listAll() {
        QueryWrapper<Channel> qw = new QueryWrapper<>();
        qw.orderByAsc("sort").orderByAsc("id");
        return channelMapper.selectList(qw);
    }
}
