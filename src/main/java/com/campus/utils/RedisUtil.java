package com.campus.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

/**
 * Redis 工具类 - 统一封装 RedisTemplate 常用操作
 * 对应文档"Redis 缓存：必做：Token 存储（登录态管理）"
 */
@Component
public class RedisUtil {

    /** Token 在 Redis 中的 key 前缀 */
    public static final String TOKEN_PREFIX = "login:token:";

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    /** 设置 key-value，指定过期时间（秒） */
    public void set(String key, String value, long timeoutSeconds) {
        redisTemplate.opsForValue().set(key, value, timeoutSeconds, TimeUnit.SECONDS);
    }

    /** 获取 value */
    public String get(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    /** 删除 key */
    public Boolean delete(String key) {
        return redisTemplate.delete(key);
    }

    /** 判断 key 是否存在 */
    public Boolean hasKey(String key) {
        return redisTemplate.hasKey(key);
    }

    /** 设置过期时间（秒） */
    public Boolean expire(String key, long timeoutSeconds) {
        return redisTemplate.expire(key, timeoutSeconds, TimeUnit.SECONDS);
    }

    /** 保存登录 Token：key = login:token:{userId}, value = token */
    public void saveToken(Long userId, String token) {
        set(TOKEN_PREFIX + userId, token, JwtUtil.EXPIRE_SECONDS);
    }

    /** 获取用户的登录 Token */
    public String getToken(Long userId) {
        return get(TOKEN_PREFIX + userId);
    }

    /** 删除用户的登录 Token（退出登录） */
    public void removeToken(Long userId) {
        delete(TOKEN_PREFIX + userId);
    }
}
