package com.campus.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Material;
import org.springframework.web.multipart.MultipartFile;

/**
 * 素材 Service - 对应文档"素材上传与素材列表管理"
 */
public interface MaterialService {
    /** 上传素材：限 jpg/png/gif/mp4，≤50MB，保存到本地并入库 */
    Material upload(MultipartFile file, Long userId) throws Exception;
    /** 按用户分页查询素材（type 可空） */
    IPage<Material> pageByUser(long current, long size, Long userId, String type);
    /** 删除素材（已被文章引用则不可删） */
    boolean deleteIfUnused(Long id, Long userId);
    /** 根据ID查询 */
    Material getById(Long id);
}
