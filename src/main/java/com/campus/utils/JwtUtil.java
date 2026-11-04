package com.campus.utils;

import com.fasterxml.jackson.databind.ObjectMapper;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * JWT 令牌工具类（HS256）
 * 对应考核方案技术点：JWT 令牌鉴权 / 自媒体端 Token 鉴权
 *
 * 令牌结构：Base64Url(header).Base64Url(payload).Base64Url(HMAC-SHA256 签名)
 * 仅依赖 JDK 自带 API，兼容 JDK 8 与 JDK 17，不额外引入 jar。
 */
public class JwtUtil {

    /** 签名密钥（课程设计演示用，生产环境应放在配置中心） */
    private static final String SECRET = "campus-headlines-jwt-secret-key-2026-ssm";

    /** 令牌有效期：2 小时（秒） */
    public static final long EXPIRE_SECONDS = 7200L;

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private JwtUtil() {
    }

    /**
     * 生成 Token
     * @param userId   用户ID
     * @param username 用户名
     * @param role     角色字符串：USER / MEDIA / AUDITOR / ADMIN
     */
    public static String createToken(Long userId, String username, String role) {
        try {
            Map<String, Object> header = new LinkedHashMap<>();
            header.put("alg", "HS256");
            header.put("typ", "JWT");

            long now = System.currentTimeMillis() / 1000;
            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("userId", userId);
            payload.put("username", username);
            payload.put("role", role);
            payload.put("iat", now);
            payload.put("exp", now + EXPIRE_SECONDS);

            String h = encode(MAPPER.writeValueAsBytes(header));
            String p = encode(MAPPER.writeValueAsBytes(payload));
            String content = h + "." + p;
            return content + "." + encode(sign(content));
        } catch (Exception e) {
            throw new RuntimeException("JWT 令牌生成失败", e);
        }
    }

    /**
     * 校验并解析 Token
     * @return 载荷 Map；Token 为空、签名错误或已过期时返回 null
     */
    @SuppressWarnings("unchecked")
    public static Map<String, Object> parse(String token) {
        if (token == null || token.trim().isEmpty()) {
            return null;
        }
        String[] parts = token.trim().split("\\.");
        if (parts.length != 3) {
            return null;
        }
        try {
            byte[] expected = sign(parts[0] + "." + parts[1]);
            byte[] actual = Base64.getUrlDecoder().decode(parts[2]);
            // 使用 MessageDigest.isEqual 做恒定时间比较，防止时序攻击
            if (!MessageDigest.isEqual(expected, actual)) {
                return null;
            }
            Map<String, Object> payload =
                    MAPPER.readValue(Base64.getUrlDecoder().decode(parts[1]), Map.class);
            Object exp = payload.get("exp");
            if (exp instanceof Number
                    && ((Number) exp).longValue() * 1000L < System.currentTimeMillis()) {
                return null;   // 令牌已过期
            }
            return payload;
        } catch (Exception e) {
            return null;
        }
    }

    /** 从 Authorization 头中截取 Bearer 之后的令牌 */
    public static String resolveToken(String authorization) {
        if (authorization == null) {
            return null;
        }
        String value = authorization.trim();
        if (value.toLowerCase().startsWith("bearer ")) {
            return value.substring(7).trim();
        }
        return value;
    }

    private static String encode(byte[] bytes) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static byte[] sign(String content) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        return mac.doFinal(content.getBytes(StandardCharsets.UTF_8));
    }
}
