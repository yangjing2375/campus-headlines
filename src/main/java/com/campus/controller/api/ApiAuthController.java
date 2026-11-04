package com.campus.controller.api;

import com.campus.entity.SysUser;
import com.campus.interceptor.TokenInterceptor;
import com.campus.service.SysUserService;
import com.campus.utils.JwtUtil;
import com.campus.utils.R;
import com.campus.utils.RedisUtil;
import com.campus.utils.SessionUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 公共认证接口 - 对应文档 6.1
 * POST /api/auth/register  注册（默认角色 USER）
 * POST /api/auth/login     登录（返回 JWT Token，存入 Redis）
 * POST /api/auth/logout    退出（清除 Redis Token）
 * GET  /api/auth/userinfo  获取当前用户信息
 */
@RestController
@RequestMapping("/api/auth")
public class ApiAuthController {

    @Autowired
    private SysUserService userService;

    @Autowired
    private RedisUtil redisUtil;

    @PostMapping("/register")
    public R<?> register(@RequestBody SysUser user) {
        boolean ok = userService.register(user);
        return ok ? R.ok("注册成功") : R.fail("注册失败");
    }

    @PostMapping("/login")
    public R<Map<String, Object>> login(@RequestBody SysUser loginUser) {
        SysUser user = userService.login(loginUser.getUsername(), loginUser.getPassword());
        if (user == null) {
            return R.fail(401, "用户名或密码错误");
        }
        // 同时写入 Session，保证 JSP 页面仍可正常使用
        SessionUtil.setLoginUser(user);

        String token = JwtUtil.createToken(user.getId(), user.getUsername(), user.getRole());
        // Token 存入 Redis（TTL = 2 小时）
        redisUtil.saveToken(user.getId(), token);

        user.setPassword(null);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("token", token);
        data.put("tokenType", "Bearer");
        data.put("expiresIn", JwtUtil.EXPIRE_SECONDS);
        data.put("user", user);
        return R.ok("登录成功", data);
    }

    @PostMapping("/logout")
    public R<?> logout(HttpServletRequest request) {
        SysUser tokenUser = (SysUser) request.getAttribute(TokenInterceptor.ATTR_USER);
        if (tokenUser != null && tokenUser.getId() != null) {
            redisUtil.removeToken(tokenUser.getId());
        }
        SessionUtil.removeLoginUser();
        return R.ok("已退出登录");
    }

    @GetMapping("/userinfo")
    public R<SysUser> userinfo(HttpServletRequest request) {
        SysUser tokenUser = (SysUser) request.getAttribute(TokenInterceptor.ATTR_USER);
        if (tokenUser == null) {
            return R.fail(401, "未登录");
        }
        SysUser user = userService.getById(tokenUser.getId());
        if (user == null) {
            return R.fail(401, "用户不存在");
        }
        user.setPassword(null);
        return R.ok(user);
    }
}
