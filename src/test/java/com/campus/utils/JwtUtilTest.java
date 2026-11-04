package com.campus.utils;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * JWT 工具类单元测试：对应测试用例 UC-005 / UC-006（Token 缺失、伪造）
 */
@DisplayName("JwtUtil - JWT 签发与校验")
class JwtUtilTest {

    @Test
    @DisplayName("签发的 Token 能被解析且携带 userId / username / role")
    void createTokenAndParse() {
        String token = JwtUtil.createToken(3L, "editor01", "MEDIA");
        assertNotNull(token);
        assertEquals(3, token.split("\\.").length, "Token 必须由 header.payload.signature 三段组成");

        Map<String, Object> claims = JwtUtil.parse(token);
        assertNotNull(claims, "合法 Token 应解析成功");
        assertEquals(3, ((Number) claims.get("userId")).intValue());
        assertEquals("editor01", claims.get("username"));
        assertEquals("MEDIA", claims.get("role"));
    }

    @Test
    @DisplayName("空 Token / 格式错误 Token 解析返回 null")
    void parseInvalidToken() {
        assertNull(JwtUtil.parse(null));
        assertNull(JwtUtil.parse("   "));
        assertNull(JwtUtil.parse("only-one-part"));
        assertNull(JwtUtil.parse("a.b.c"));
    }

    @Test
    @DisplayName("篡改 payload 后签名校验失败（UC-006）")
    void parseTamperedToken() {
        String token = JwtUtil.createToken(5L, "2023001", "USER");
        String[] parts = token.split("\\.");
        // 模拟把角色从 USER 改成 ADMIN
        String tampered = parts[0] + "." + parts[1].substring(0, parts[1].length() - 2) + "AD." + parts[2];
        assertNull(JwtUtil.parse(tampered), "篡改后的 Token 必须解析失败");
    }

    @Test
    @DisplayName("Bearer 前缀可正确截取，非 Bearer 原样返回")
    void resolveToken() {
        assertEquals("abc.def.ghi", JwtUtil.resolveToken("Bearer abc.def.ghi"));
        assertEquals("abc.def.ghi", JwtUtil.resolveToken("bearer abc.def.ghi"));
        assertEquals("abc.def.ghi", JwtUtil.resolveToken("  abc.def.ghi  "));
        assertNull(JwtUtil.resolveToken(null));
    }

    @Test
    @DisplayName("令牌有效期常量为 2 小时")
    void expireSeconds() {
        assertEquals(7200L, JwtUtil.EXPIRE_SECONDS);
        assertTrue(JwtUtil.EXPIRE_SECONDS > 0);
        assertFalse(JwtUtil.createToken(1L, "admin", "ADMIN").isEmpty());
    }
}
