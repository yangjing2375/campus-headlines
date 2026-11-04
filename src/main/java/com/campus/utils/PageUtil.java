package com.campus.utils;

/**
 * 分页参数归一化工具（缺陷 BUG-02 修复）
 * current < 1 → 1；size < 1 → 10；size > 50 → 50（防止 page=-1 / size=100000 造成 SQL 异常或全表扫描）
 */
public final class PageUtil {

    /** 单页最大条数 */
    public static final long MAX_SIZE = 50L;

    private PageUtil() {
    }

    public static long current(long current) {
        return current < 1L ? 1L : current;
    }

    public static long size(long size) {
        if (size < 1L) {
            return 10L;
        }
        return Math.min(size, MAX_SIZE);
    }
}
