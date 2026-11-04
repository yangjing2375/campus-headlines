package com.campus.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Channel;

import java.util.List;

/**
 * 频道 Service - 对应文档"频道分类模块"
 */
public interface ChannelService {
    /** 新增频道 */
    boolean add(Channel channel);
    /** 更新频道 */
    boolean update(Channel channel);
    /** 删除频道 */
    boolean delete(Long id);
    /** 根据ID查询 */
    Channel getById(Long id);
    /** 启用状态的频道列表（用户端展示） */
    List<Channel> listEnabled();
    /** 全部分页（管理端） */
    IPage<Channel> pageList(long current, long size);
    /** 全部列表（不分页） */
    List<Channel> listAll();
}
