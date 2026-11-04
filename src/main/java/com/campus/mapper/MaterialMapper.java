package com.campus.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.campus.entity.Material;
import org.apache.ibatis.annotations.Param;

public interface MaterialMapper extends BaseMapper<Material> {

    /** 按上传人 + 类型 分页查询素材 */
    IPage<Material> selectByUserPage(IPage<Material> page,
                                     @Param("userId") Long userId,
                                     @Param("type") String type);

    /** 按用户 + 文件MD5 查找已有素材（用于上传去重） */
    Material selectByUserAndMd5(@Param("userId") Long userId, @Param("md5") String md5);
}
