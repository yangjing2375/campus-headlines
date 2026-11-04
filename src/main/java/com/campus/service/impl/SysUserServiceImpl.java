package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.entity.SysUser;
import com.campus.mapper.SysUserMapper;
import com.campus.service.SysUserService;
import com.campus.utils.Md5Util;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class SysUserServiceImpl implements SysUserService {

    @Autowired
    private SysUserMapper userMapper;

    @Override
    public SysUser login(String username, String password) {
        if (username != null) username = username.trim();
        if (password != null) password = password.trim();
        SysUser user = userMapper.selectByUsername(username);
        if (user == null) return null;
        if (user.getStatus() != null && user.getStatus() == 0) return null;
        if (!Md5Util.encrypt(password).equals(user.getPassword())) return null;
        return user;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean register(SysUser user) {
        // 校验用户名唯一
        if (userMapper.selectByUsername(user.getUsername()) != null) {
            throw new IllegalArgumentException("该学号或手机号已被注册");
        }
        // 校验手机号唯一
        if (StringUtils.hasText(user.getPhone())) {
            QueryWrapper<SysUser> qw = new QueryWrapper<>();
            qw.eq("phone", user.getPhone());
            if (userMapper.selectCount(qw) > 0) {
                throw new IllegalArgumentException("手机号已被注册");
            }
        }
        // 默认角色 USER，启用状态
        if (!StringUtils.hasText(user.getRole())) user.setRole("USER");
        if (user.getStatus() == null) user.setStatus(1);
        user.setPassword(Md5Util.encrypt(user.getPassword()));
        return userMapper.insert(user) > 0;
    }

    @Override
    public SysUser getById(Long id) {
        return userMapper.selectById(id);
    }

    @Override
    public SysUser getByUsername(String username) {
        return userMapper.selectByUsername(username);
    }

    @Override
    public IPage<SysUser> pageList(long current, long size, String keyword, String role) {
        Page<SysUser> page = new Page<>(current, size);
        QueryWrapper<SysUser> qw = new QueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            qw.and(w -> w.like("username", keyword).or().like("nickname", keyword));
        }
        if (StringUtils.hasText(role)) {
            qw.eq("role", role);
        }
        qw.orderByDesc("create_time");
        return userMapper.selectPage(page, qw);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean update(SysUser user) {
        return userMapper.updateById(user) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updatePassword(Long id, String oldPwd, String newPwd) {
        SysUser user = userMapper.selectById(id);
        if (user == null) return false;
        if (!Md5Util.encrypt(oldPwd).equals(user.getPassword())) return false;
        SysUser update = new SysUser();
        update.setId(id);
        update.setPassword(Md5Util.encrypt(newPwd));
        return userMapper.updateById(update) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateStatus(Long id, Integer status) {
        SysUser user = new SysUser();
        user.setId(id);
        user.setStatus(status);
        return userMapper.updateById(user) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateRole(Long id, String role) {
        SysUser user = new SysUser();
        user.setId(id);
        user.setRole(role);
        return userMapper.updateById(user) > 0;
    }
}
