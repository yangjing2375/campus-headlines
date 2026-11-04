package com.campus.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.SysUser;

/**
 * 用户 Service - 对应文档"公共模块：认证与 Token 鉴权"
 */
public interface SysUserService {
    /** 登录：返回用户（密码校验），失败返回 null */
    SysUser login(String username, String password);

    /** 注册：校验 username/phone 唯一性，默认角色 USER */
    boolean register(SysUser user);

    /** 根据ID查询 */
    SysUser getById(Long id);

    /** 根据用户名查询 */
    SysUser getByUsername(String username);

    /** 分页查询用户（关键词：昵称/用户名；角色筛选） */
    IPage<SysUser> pageList(long current, long size, String keyword, String role);

    /** 更新用户信息 */
    boolean update(SysUser user);

    /** 修改密码 */
    boolean updatePassword(Long id, String oldPwd, String newPwd);

    /** 启用/禁用用户 */
    boolean updateStatus(Long id, Integer status);

    /** 分配角色（USER/MEDIA/AUDITOR/ADMIN） */
    boolean updateRole(Long id, String role);
}
