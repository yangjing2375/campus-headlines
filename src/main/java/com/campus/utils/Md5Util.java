package com.campus.utils;

import java.security.MessageDigest;

/**
 * MD5 密码加密工具类
 */
public class Md5Util {

    public static String encrypt(String source) {
        if (source == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] result = md.digest(source.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : result) {
                String hex = Integer.toHexString(b & 0xff);
                if (hex.length() == 1) sb.append('0');
                sb.append(hex);
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("MD5 encryption error", e);
        }
    }
}
