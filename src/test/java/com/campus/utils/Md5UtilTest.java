package com.campus.utils;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

/**
 * MD5 工具类单元测试：对应测试用例 UC-004（演示账号密码 123456）
 */
@DisplayName("Md5Util - 密码摘要")
class Md5UtilTest {

    @Test
    @DisplayName("123456 的 MD5 与数据库初始化数据一致")
    void encryptKnownValue() {
        assertEquals("e10adc3949ba59abbe56e057f20f883e", Md5Util.encrypt("123456"));
    }

    @Test
    @DisplayName("入参为 null 时返回 null，不抛异常")
    void encryptNull() {
        assertNull(Md5Util.encrypt(null));
    }

    @Test
    @DisplayName("摘要固定 32 位小写，且相同明文结果稳定")
    void digestFormat() {
        String a = Md5Util.encrypt("campus-headlines");
        String b = Md5Util.encrypt("campus-headlines");
        assertEquals(a, b);
        assertEquals(32, a.length());
        assertEquals(a.toLowerCase(), a);
    }
}
