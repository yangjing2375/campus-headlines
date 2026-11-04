package com.campus.utils;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * 分页归一步工具单元测试：对应测试用例 UC-066（缺陷 BUG-02 回归）
 */
@DisplayName("PageUtil - 分页参数归一化（BUG-02 回归）")
class PageUtilTest {

    @Test
    @DisplayName("current < 1 时归一为 1")
    void currentLessThanOne() {
        assertEquals(1L, PageUtil.current(-1L));
        assertEquals(1L, PageUtil.current(0L));
        assertEquals(3L, PageUtil.current(3L));
    }

    @Test
    @DisplayName("size < 1 时使用默认 10")
    void sizeLessThanOne() {
        assertEquals(10L, PageUtil.size(0L));
        assertEquals(10L, PageUtil.size(-5L));
    }

    @Test
    @DisplayName("size 超过 50 时被截断，防止全表扫描")
    void sizeTooLarge() {
        assertEquals(50L, PageUtil.size(100000L));
        assertEquals(50L, PageUtil.size(51L));
        assertEquals(20L, PageUtil.size(20L));
    }

    @Test
    @DisplayName("边界值 1 与 50 原样保留")
    void boundaryValues() {
        assertEquals(1L, PageUtil.size(1L));
        assertEquals(50L, PageUtil.size(50L));
        assertEquals(PageUtil.MAX_SIZE, PageUtil.size(Long.MAX_VALUE));
    }
}
