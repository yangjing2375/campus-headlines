package com.campus.interceptor;

import com.campus.entity.SysUser;
import com.campus.utils.JwtUtil;
import com.campus.utils.R;
import com.campus.utils.RedisUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Map;

/**
 * Token 鉴权拦截器 - JWT 令牌鉴权 + Redis 登录态校验 + RBAC 角色权限
 *
 * 1. 从请求头 Authorization: Bearer xxx 中解析 JWT
 * 2. 校验 Redis 中是否存在该用户的有效 Token（必做：Token 存储于 Redis）
 * 3. 按 requiredRoles 做角色隔离（MEDIA / AUDITOR / ADMIN / USER）
 *
 * requiredRoles 为空表示只校验登录，不限制角色。
 */
public class TokenInterceptor implements HandlerInterceptor {

    /** 请求域中保存当前登录用户的 key */
    public static final String ATTR_USER = "tokenUser";

    private static final ObjectMapper MAPPER = new ObjectMapper();

    /** 允许访问的角色，逗号分隔，如 "AUDITOR,ADMIN" */
    private String requiredRoles = "";

    /** 是否可选登录：true 时无有效 Token 也放行（游客浏览），Controller 自行判断 */
    private boolean optional = false;

    @Autowired
    private RedisUtil redisUtil;

    public void setRequiredRoles(String requiredRoles) {
        this.requiredRoles = requiredRoles;
    }

    public void setOptional(boolean optional) {
        this.optional = optional;
    }

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {
        String token = JwtUtil.resolveToken(request.getHeader("Authorization"));
        Map<String, Object> claims = JwtUtil.parse(token);

        if (claims == null) {
            if (optional) {
                // 游客模式：放行，不设置用户
                return true;
            }
            writeJson(response, 401, "Token 无效或已过期，请重新登录");
            return false;
        }

        Object userIdObj = claims.get("userId");
        Long userId = userIdObj instanceof Number ? ((Number) userIdObj).longValue() : null;
        if (userId == null) {
            writeJson(response, 401, "Token 内容非法");
            return false;
        }

        // Redis 登录态校验：Token 必须与 Redis 中存储的一致，否则视为已登出/被踢
        String storedToken = redisUtil.getToken(userId);
        if (storedToken == null || !storedToken.equals(token)) {
            writeJson(response, 401, "登录已失效，请重新登录");
            return false;
        }

        String role = (String) claims.get("role");
        if (!roleAllowed(role)) {
            writeJson(response, 403, "当前角色无权访问该接口");
            return false;
        }

        SysUser user = new SysUser();
        user.setId(userId);
        user.setUsername((String) claims.get("username"));
        user.setRole(role);
        user.setStatus(1);
        request.setAttribute(ATTR_USER, user);
        return true;
    }

    private boolean roleAllowed(String role) {
        if (requiredRoles == null || requiredRoles.trim().isEmpty()) {
            return true;
        }
        if (role == null) return false;
        for (String item : requiredRoles.split(",")) {
            if (item.trim().equalsIgnoreCase(role)) {
                return true;
            }
        }
        return false;
    }

    private void writeJson(HttpServletResponse response, int code, String msg) throws Exception {
        response.setStatus(code);
        response.setContentType("application/json;charset=UTF-8");
        MAPPER.writeValue(response.getWriter(), R.fail(code, msg));
    }
}
